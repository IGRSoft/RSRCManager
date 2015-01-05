//
//  ResourceManager.m
//  RSRCManager
//
//  Created by Vitalii Parovishnyk on 12/22/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "ResourceManager.h"

@interface ResourceManager ()

@end

@implementation ResourceManager

@synthesize filePath;
@synthesize startDataPosition;
@synthesize startInfoPosition;
@synthesize resourceData;

- (id)initWithFilePath:(NSString *)aPath
{
    self = [super init];
    if (self)
    {
        self.filePath = aPath;
    }
    
    return self;
}

#pragma mark - Private

- (unsigned)parseIntFromData:(NSData *)data
{
    NSString *dataDescription = [data description];
    NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
    
    unsigned intData = 0;
    NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
    [scanner scanHexInt:&intData];
    
    return intData;
}

- (void)parseData
{
    NSAssert(NO, @"Rewrite Me");
}

- (NSFileHandle *)readFile
{
    NSFileHandle *file = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
    
    if (file == nil)
    {
        NSLog(@"Failed to open file");
    }
    
    self.startDataPosition = [self parseIntFromData:[file readDataOfLength:BYTE_4]];
    
    NSUInteger dontKnow = [self parseIntFromData:[file readDataOfLength:BYTE_4]];
    dontKnow = dontKnow; //remove warning
    
    NSUInteger infoOffset = [self parseIntFromData:[file readDataOfLength:BYTE_4]];
    
    NSUInteger metaInfoLenght = 28;
    self.startInfoPosition = self.startDataPosition + infoOffset + metaInfoLenght;
    
    return file;
}

@end
