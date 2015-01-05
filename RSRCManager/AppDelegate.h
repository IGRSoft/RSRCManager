//
//  AppDelegate.h
//  RSRCManager
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class ResourceEntities;

@interface AppDelegate : NSObject <NSApplicationDelegate>

- (void)saveResource:(ResourceEntities *)resourceEntity;

- (IBAction)toggleQuickLook:(id)sender;

@end
