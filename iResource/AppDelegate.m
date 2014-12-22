//
//  AppDelegate.m
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "AppDelegate.h"
#import "RSRCManager.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSCollectionView *collectionView;
@property (weak) IBOutlet NSProgressIndicator *spinerView;
@property (weak) IBOutlet NSTextField *exportPath;
@property (weak) IBOutlet NSComboBox *typesBox;

- (IBAction)openFile:(id)sender;

- (void)gatherResources;

@property (nonatomic, strong) NSURL *resourceURL;
@property (nonatomic, strong) NSDictionary *resourceData;

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
		[self gatherResources];
		
		NSDocument *document = [[NSDocument alloc] init];
		document.fileURL = self.resourceURL;
		[[NSDocumentController sharedDocumentController] addDocument:document];
	}
}

- (void)gatherResources
{
    [self.spinerView startAnimation:self];
    [self.collectionView setHidden:YES];
    
    RSRCManager *resourceManager = [[RSRCManager alloc] initWithFilePath:[self.resourceURL path]];
    __weak typeof(self) weakSelf = self;
    
    resourceManager.successCompletionBlock = ^(NSDictionary *resources) {
    
        weakSelf.resourceData = resources;
        [weakSelf.typesBox removeAllItems];
        
        [weakSelf.typesBox addItemsWithObjectValues:[resources allKeys]];
        
        [weakSelf.typesBox selectItemAtIndex:0];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.collectionView setHidden:NO];
            [weakSelf.spinerView stopAnimation:weakSelf];
        });
    };
    
    [resourceManager parseData];
}

- (void)updateData:(NSMutableArray *)obj
{
    [_collectionView setContent:obj];
}

- (IBAction)exportAllResources:(id)sender
{
	[self.spinerView startAnimation:self];
	[self.collectionView setHidden:YES];
	
    NSArray *resources = self.resourceData[self.typesBox.stringValue];
    
	for (ResourceEntities *item in resources)
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

#pragma mark - NSApplicationDelegate

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
    return YES;
}
- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    self.resourceURL = [NSURL URLWithString:[filenames firstObject]];
    [self gatherResources];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *box = [notification object];
    NSArray *resources = self.resourceData[box.objectValueOfSelectedItem];
    
    [self performSelectorOnMainThread:@selector(updateData:) withObject:resources waitUntilDone:YES];
}

@end
