//
//  AppDelegate.m
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "AppDelegate.h"
#import "ResourceEntities.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (void)awakeFromNib
{
    [_collectionView setSelectable:YES];
    [NSThread detachNewThreadSelector:@selector(gatherAppData) toTarget:self withObject:nil];
}

- (void)gatherAppData
{
    NSMutableArray *_appData = [[NSMutableArray alloc]init];
	
	NSFileManager *_fm = [NSFileManager defaultManager];
	NSString *path = @"/Applications";
	NSArray *contents = [_fm contentsOfDirectoryAtPath:path error:nil];
	
	for (NSString *string in contents)
	{
		if ([[string pathExtension]isEqualToString:@"app"])
		{
			NSString *fullPath = [path stringByAppendingPathComponent:string];
			ResourceEntities *item = [[ResourceEntities alloc]init];
		
			NSImage *image = [[NSWorkspace sharedWorkspace]iconForFile:fullPath];
			item.image = image;
			item.name = [string stringByDeletingPathExtension];
			
			[_appData addObject:item];
		}
	}
	
    [self performSelectorOnMainThread:@selector(updateData:) withObject:_appData waitUntilDone:YES];
}

- (void)updateData:(NSMutableArray *)obj
{
    [_collectionView setContent:obj];
}

@end
