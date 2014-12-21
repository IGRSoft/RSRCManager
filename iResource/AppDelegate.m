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
@property (nonatomic, strong) NSMutableArray *resourceData;

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
	__weak typeof(self) weakSelf = self;
	
	dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
	dispatch_async(queue, ^{
		
		NSFileHandle *file;
		NSData *databuffer;
		
		file = [NSFileHandle fileHandleForReadingAtPath:[weakSelf.resourceURL path]];
		
		if (file == nil)
			NSLog(@"Failed to open file");
		
		databuffer = [file readDataToEndOfFile];
		
		weakSelf.resourceData = [[NSMutableArray alloc] init];
		
		NSData *pattern = [@"PNG " dataUsingEncoding:NSUTF8StringEncoding];
		NSRange range = [databuffer rangeOfData:pattern options:0 range:NSMakeRange(0, databuffer.length)];
		
		NSUInteger pngInfoPos = range.location + range.length;
		[file seekToFileOffset:pngInfoPos];
		
		NSUInteger readBytes = 2;
		NSUInteger idOffsetBytes = 10;
		
		NSUInteger count = [weakSelf parseIntFromData:[file readDataOfLength:readBytes]];
		
		pngInfoPos += (readBytes + readBytes);
		[file seekToFileOffset:pngInfoPos];
		
		NSMutableArray *IDs = [NSMutableArray array];
		for (NSInteger i = 0; i <= count; ++i)
		{
			NSUInteger resourceId = [weakSelf parseIntFromData:[file readDataOfLength:readBytes]];
			[IDs addObject:@(resourceId)];
			
			pngInfoPos += (idOffsetBytes + readBytes);
			[file seekToFileOffset:pngInfoPos];
		}
		
		NSUInteger startPosition = 256;
		readBytes = 4;
		
		[file seekToFileOffset:startPosition];
		for (NSInteger i = 0; i <= count; ++i)
		{
			NSUInteger size = [weakSelf parseIntFromData:[file readDataOfLength:readBytes]];
			
			startPosition += readBytes;
			[file seekToFileOffset:startPosition];
			
			NSData *data = [file readDataOfLength:size];
			NSImage *result = [[NSImage alloc] initWithData:data];
			
			if (result)
			{
				ResourceEntities *item = [[ResourceEntities alloc] init];
				item.image = result;
				item.name = [NSString stringWithFormat:@"%@", IDs[i]];
				
				[self.resourceData addObject:item];
			}
			
			[weakSelf performSelectorOnMainThread:@selector(updateData:) withObject:weakSelf.resourceData waitUntilDone:YES];
			
			startPosition += size;
			[file seekToFileOffset:startPosition];
		}
		
		[file closeFile];
	});
}

- (unsigned)parseIntFromData:(NSData *)data
{
	NSString *dataDescription = [data description];
	NSString *dataAsString = [dataDescription substringWithRange:NSMakeRange(1, [dataDescription length]-2)];
	
	unsigned intData = 0;
	NSScanner *scanner = [NSScanner scannerWithString:dataAsString];
	[scanner scanHexInt:&intData];
	
	return intData;
}

- (void)updateData:(NSMutableArray *)obj
{
    [_collectionView setContent:obj];
}

- (IBAction)exportAllResources:(id)sender
{
	[self.spinerView startAnimation:self];
	[self.collectionView setHidden:YES];
	
	for (ResourceEntities *item in self.resourceData)
	{
		[self saveResource:item];
	}
	
	[self.collectionView setHidden:NO];
	[self.spinerView stopAnimation:self];
}

- (void)saveResource:(ResourceEntities *)resourceEntity
{
	if (![[NSFileManager defaultManager] fileExistsAtPath:self.exportPath.stringValue isDirectory:nil])
	{
		[[NSFileManager defaultManager] createDirectoryAtPath:self.exportPath.stringValue withIntermediateDirectories:YES attributes:nil error:nil];
	}
	
	NSBitmapImageRep *imgRep = [[resourceEntity.image representations] objectAtIndex: 0];
	NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
	
	[data writeToFile: [NSString stringWithFormat:@"%@/%@.png", self.exportPath.stringValue, resourceEntity.name] atomically: NO];
}

#pragma mark - Preference
+ (void)initialize
{
	// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	// Put defaults in the dictionary
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
	NSString* theDesktopPath = [paths objectAtIndex:0];
	defaultValues[@"ExportPath"] = theDesktopPath;
	
	// Register the dictionary of defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults: defaultValues];
}

@end
