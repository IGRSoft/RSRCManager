//
//  ResourceEntities.h
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "ResourceEntities.h"
#import <AppKit/AppKit.h>

@interface ResourceEntities ()
{
	NSImage  *_image;
	NSString *_name;
}

@end

@implementation ResourceEntities

@synthesize name = _name;
@synthesize image = _image;

- (NSString *)name
{
    if (!_name)
	{
        _name = @"unknown";
    }
	
	return _name;
}

- (NSImage *)image
{
    if (!_image)
	{
        _image = [NSImage imageNamed:@""];
    }
	
	return _image;
}

@end
