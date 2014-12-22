//
//  ResourceManager_Protocol.h
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/22/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#define BYTE_2 2
#define BYTE_4 4

@protocol ResourceManagerProtocol <NSObject>

@property (nonatomic, strong) NSString              *filePath;
@property (nonatomic, strong) NSMutableDictionary   *resourceData;

@property (nonatomic, assign) NSUInteger startDataPosition;
@property (nonatomic, assign) NSUInteger startInfoPosition;

- (unsigned)parseIntFromData:(NSData *)data;
- (NSFileHandle *)readFile;

@end
