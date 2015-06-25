//
//  AppDelegate.m
//  RSRCManager
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "AppDelegate.h"
#import "RSRCManager.h"
#import "PreviewCollectionView.h"

#import <AppSandboxFileAccess/AppSandboxFileAccess.h>

#import <Quartz/Quartz.h>   // for QLPreviewPanel

@interface AppDelegate () <QLPreviewPanelDataSource, QLPreviewPanelDelegate, QuickLookCollectionViewDelegate>

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet PreviewCollectionView *collectionView;
@property (weak) IBOutlet NSProgressIndicator *spinerView;
@property (weak) IBOutlet NSTextField *exportPath;
@property (weak) IBOutlet NSComboBox *typesBox;

@property (nonatomic, assign) BOOL hasResources;
@property (nonatomic, strong) ResourceEntities *selectedResource;

- (IBAction)openFile:(id)sender;

- (IBAction)exportSelectedResources:(id)sender;
- (IBAction)exportAllResources:(id)sender;

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
	_hasResources = NO;
	_selectedResource = nil;
}

#pragma mark - Actions

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
	self.hasResources = NO;
	
    [self.spinerView startAnimation:self];
    [self.collectionView setHidden:YES];
	
    RSRCManager *resourceManager = [[RSRCManager alloc] initWithFilePath:[self.resourceURL path]];
    __weak typeof(self) weakSelf = self;
    
    resourceManager.successCompletionBlock = ^(NSDictionary *resources) {
    
        if (resources.count)
        {
            weakSelf.resourceData = resources;
            [weakSelf.typesBox removeAllItems];
            
            [weakSelf.typesBox addItemsWithObjectValues:[resources allKeys]];
            
            [weakSelf.typesBox selectItemAtIndex:0];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf.collectionView setHidden:NO];
            [weakSelf.spinerView stopAnimation:weakSelf];
        });
		
		weakSelf.hasResources = weakSelf.typesBox.numberOfItems > 0;
    };
    
    [resourceManager parseData];
}

- (void)updateData:(NSMutableArray *)obj
{
	self.selectedResource = nil;
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

- (IBAction)exportSelectedResources:(id)sender
{
	[self saveResource:self.selectedResource];
}

- (IBAction)toggleQuickLook:(id)sender
{
	[self didPressSpacebarForCollectionView:self.collectionView];
}

- (void)saveResource:(ResourceEntities *)resourceEntity
{
    AppSandboxFileAccess *fileAccess = [AppSandboxFileAccess fileAccess];
    [fileAccess persistPermissionPath:self.exportPath.stringValue];
    
    BOOL accessAllowed = [fileAccess accessFilePath:self.exportPath.stringValue persistPermission:YES withBlock:^{
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:self.exportPath.stringValue isDirectory:nil])
        {
            NSError *error;
            
            if (![[NSFileManager defaultManager] createDirectoryAtPath:self.exportPath.stringValue withIntermediateDirectories:YES attributes:nil error:&error])
            {
                NSLog(@"Error can't create dir - %@: %@", self.exportPath.stringValue, error.localizedDescription);
                
                return;
            }
        }
        
        NSBitmapImageRep *imgRep = [[resourceEntity.image representations] objectAtIndex: 0];
        NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
        
        [data writeToFile:[NSString stringWithFormat:@"%@/%@.png", self.exportPath.stringValue, resourceEntity.name]
               atomically:NO];
    }];
    
    if (!accessAllowed) {
        NSLog(@"Sad Wookie");
    }
    
	
}

#pragma mark - NSComboBoxDelegate

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	NSComboBox *box = [notification object];
	NSArray *resources = self.resourceData[box.objectValueOfSelectedItem];
	
	[self performSelectorOnMainThread:@selector(updateData:) withObject:resources waitUntilDone:YES];
}

#pragma mark - Preference

+ (void)initialize
{
	// Create a dictionary
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	// Put defaults in the dictionary
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
	NSString* theDesktopPath = [paths objectAtIndex:0];
    theDesktopPath = [theDesktopPath stringByAppendingPathComponent:@"RSRCManagerExport"];
    
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

#pragma mark - QuickLookCollectionViewDelegate

- (void)didChangedSelectionCollectionItemView:(NSCollectionViewItem *)collectionViewItem
{
	if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
	{
		[[QLPreviewPanel sharedPreviewPanel] reloadData];
		
		//need delay for write data
        dispatch_async(dispatch_get_main_queue(), ^{
            [[QLPreviewPanel sharedPreviewPanel] refreshCurrentPreviewItem];
        });
	}
	
	self.selectedResource = collectionViewItem.representedObject;
}

- (void)didPressSpacebarForCollectionView:(NSCollectionView *)collectionView
{
	if (!collectionView.content.count)
	{
		return;
	}
	
	if ([QLPreviewPanel sharedPreviewPanelExists] && [[QLPreviewPanel sharedPreviewPanel] isVisible])
	{
		[[QLPreviewPanel sharedPreviewPanel] orderOut:nil];
	}
	else
	{
		[[QLPreviewPanel sharedPreviewPanel] makeKeyAndOrderFront:nil];
		[[QLPreviewPanel sharedPreviewPanel] reloadData];
	}
}

#pragma mark - Preview
#pragma mark - Quick Look panel support


- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
	return 1;
}

- (id<QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
	ResourceEntities *res = self.collectionView.content[self.collectionView.selectionIndexes.firstIndex];
	
	NSBitmapImageRep *imgRep = [[res.image representations] objectAtIndex: 0];
	NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
	
	NSString* tempPath = NSTemporaryDirectory();
	NSString *filePath = [NSString stringWithFormat:@"%@/Preview.png", tempPath];
	
	[data writeToFile:filePath atomically:NO];
	
	return [[NSURL alloc] initFileURLWithPath:filePath];
}

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
	return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
	panel.dataSource = self;
	panel.delegate = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
	panel.dataSource = nil;
	panel.delegate = nil;
}

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
	if ([event type] == NSKeyDown)
	{
		[self.collectionView keyDown:event];
		return YES;
	}
	
	return NO;
}

@end
