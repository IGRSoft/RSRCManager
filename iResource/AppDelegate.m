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

- (IBAction)openFile:(id)sender;

@property (nonatomic, strong) NSURL *resourceURL;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
	// Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void)awakeFromNib
{
    [_collectionView setSelectable:YES];
    [NSThread detachNewThreadSelector:@selector(gatherAppData) toTarget:self withObject:nil];
}

- (IBAction)openFile:(id)sender
{
	NSOpenPanel* openPanel = [NSOpenPanel openPanel];
	openPanel.title = @"Choose a .RSRC resource file";
	
	openPanel.showsResizeIndicator = YES;
	openPanel.showsHiddenFiles = NO;
	openPanel.canChooseDirectories = NO;
	openPanel.canCreateDirectories = NO;
	openPanel.allowsMultipleSelection = NO;
	openPanel.allowedFileTypes = @[@"rsrc"];
	
	//this launches the dialogue
	NSInteger returnCode = [openPanel runModal];
	
	if (returnCode == NSModalResponseOK)
	{
		//get the selected file URLs
		self.resourceURL = openPanel.URLs[0];
		[self gatherAppData];
		
		NSDocument *document = [[NSDocument alloc] init];
		document.fileURL = self.resourceURL;
		[[NSDocumentController sharedDocumentController] addDocument:document];
	}
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
	return YES;
}
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
	self.resourceURL = [NSURL URLWithString:[filenames firstObject]];
	[self gatherAppData];
}

- (void)gatherAppData
{
	FSRef fsRef;
	bool OK = CFURLGetFSRef((__bridge CFURLRef)self.resourceURL, &fsRef);
	if (!OK)
	{
		return;
	}
	
	ResFileRefNum refNum;
	OSStatus status = FSOpenResourceFile(&fsRef, 0, NULL, fsRdPerm, &refNum);
	if (status != noErr)
	{
		return;
	};
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
	dispatch_async(queue, ^{
	
		ResType theType = 'PNG ';
		ResourceCount count = CountResources(theType);
		
		NSMutableArray *_appData = [[NSMutableArray alloc]init];
		
		for (int x = 1; x <= count; ++x)
		{
			Handle resource = Get1IndResource(theType, x);
			if (resource)
			{
				ResID theID;
				ResType theType;
				Str255     name;
				
				GetResInfo(resource, &theID, &theType, name);
				
				// Hay guise, did you know we don't need to call HLock() on Mac OS X? Groovy!
				NSData *data = [NSData dataWithBytes:*resource length:GetHandleSize(resource)];
				NSImage *result = [[NSImage alloc] initWithData:data];
				
				if (result)
				{
					ResourceEntities *item = [[ResourceEntities alloc] init];
					item.image = result;
					item.name = [NSString stringWithFormat:@"%@", @(theID)];
					
					[_appData addObject:item];
					[self performSelectorOnMainThread:@selector(updateData:) withObject:_appData waitUntilDone:YES];
				}
				
				ReleaseResource(resource);
			}
		}
		
		CloseResFile(refNum);
	
	});
	
}

- (void)updateData:(NSMutableArray *)obj
{
    [_collectionView setContent:obj];
}

@end
