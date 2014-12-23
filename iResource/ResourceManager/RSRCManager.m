//
//  RSRCManager.m
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/22/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import <AppKit/AppKit.h>

#import "RSRCManager.h"
#import "ResourceEntities.h"

@interface RSRCManager ()

@end

@implementation RSRCManager

@synthesize filePath;
@synthesize resourceData;

- (id)initWithFilePath:(NSString *)aPath
{
    self = [super initWithFilePath:aPath];
    if (self)
    {
        
    }
    
    return self;
}

- (void)parseData
{
    __weak typeof(self) weakSelf = self;
    
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        
        NSFileHandle *file = [weakSelf readFile];
        weakSelf.resourceData = [NSMutableDictionary dictionary];
        
        [file seekToFileOffset:weakSelf.startInfoPosition];
        
        NSUInteger resourceTypeCount = [weakSelf parseIntFromData:[file readDataOfLength:BYTE_2]]; //Aditional resources
        
        ++resourceTypeCount;
        
        for (NSUInteger i = 0; i < resourceTypeCount; ++i)
        {
            NSString *type = [NSString stringWithUTF8String:[[file readDataOfLength:BYTE_4] bytes]];
            
            if (type)
            {
                NSUInteger count = [weakSelf parseIntFromData:[file readDataOfLength:BYTE_2]];
                
                [file readDataOfLength:BYTE_2];
                
                weakSelf.resourceData[type] = @(++count);
            }
        }
        
        NSMutableDictionary *IDs = [NSMutableDictionary dictionary];
        
        for(NSString *type in [resourceData allKeys])
        {
            NSMutableArray *IDList = [NSMutableArray array];
            for (NSUInteger i = 0; i < [weakSelf.resourceData[type] integerValue] ; ++i)
            {
                NSUInteger resourceId = [weakSelf parseIntFromData:[file readDataOfLength:BYTE_2]];
                [IDList addObject:@(resourceId)];
                
                [file readDataOfLength:BYTE_2 * 5]; //read trash
            }
            
            IDs[type] = IDList;
        }
        
        [file seekToFileOffset:weakSelf.startDataPosition];
        
        for (NSString *type in [resourceData allKeys])
        {
            NSMutableArray *resources = [NSMutableArray array];
            
            for (NSInteger i = 0; i < [weakSelf.resourceData[type] integerValue]; ++i)
            {
                NSUInteger size = [weakSelf parseIntFromData:[file readDataOfLength:BYTE_4]];
                
                NSData *data = [file readDataOfLength:size];
                NSImage *result = [[NSImage alloc] initWithData:data];
                
                if (result)
                {
                    ResourceEntities *item = [[ResourceEntities alloc] init];
                    item.image = result;
                    item.name = [NSString stringWithFormat:@"%@", IDs[type][i]];
                    
                    [resources addObject:item];
                }
            }
            
            weakSelf.resourceData[type] = resources;
        }
        
        [file closeFile];
        
        if (weakSelf.successCompletionBlock)
        {
            weakSelf.successCompletionBlock(weakSelf.resourceData);
        }
    }];
    
    [operation start];
}

@end
