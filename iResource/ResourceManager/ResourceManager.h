//
//  ResourceManager.h
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/22/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResourceManager_Protocol.h"
#import "ResourceEntities.h"

typedef void (^ResourceManagerSuccessCompletionBlock) (NSDictionary *resources);
typedef void (^ResourceManagerFailedCompletionBlock) (NSDictionary *resources);

@interface ResourceManager : NSObject <ResourceManagerProtocol>

- (id)initWithFilePath:(NSString *)aPath;

@property (nonatomic, copy)   ResourceManagerSuccessCompletionBlock successCompletionBlock;
@property (nonatomic, copy)   ResourceManagerFailedCompletionBlock failedCompletionBlock;

- (void)parseData;

@end
