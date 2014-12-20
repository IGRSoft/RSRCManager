//
//  ResourceCollectionItemView.m
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "ResourceCollectionItemView.h"
#import "ResourceEntities.h"

@implementation ResourceCollectionItemView

@synthesize isSelected = _isSelected;

- (instancetype)initWithFrame:(NSRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code here.
	}
	
	return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	NSRect imageRect = NSMakeRect(5,5, self.frame.size.width - 10,self.frame.size.height - 10);
	
	NSBezierPath* imageRoundedRectanglePath = [NSBezierPath bezierPathWithRoundedRect:imageRect xRadius: 4 yRadius: 4];
	NSColor* fillColor = nil;
	NSColor* strokeColor = nil;
	NSColor *filedColor = nil;
	
	if (_isSelected)
	{
		fillColor = [NSColor colorWithCalibratedRed: 0.851 green: 0.851 blue: 0.851 alpha: 1];
		strokeColor = [NSColor colorWithCalibratedRed: 0.408 green: 0.592 blue: 0.855 alpha: 1];
		
		filedColor = [NSColor blackColor];
	}
	else
	{
		fillColor = [NSColor clearColor];
		strokeColor = [NSColor colorWithCalibratedRed: 0.749 green: 0.749 blue: 0.749 alpha: 1];
		filedColor = [NSColor grayColor];
	}
	
	[fillColor setFill];
	[imageRoundedRectanglePath fill];
	[strokeColor setStroke];
	
	[super drawRect:dirtyRect];
}


- (void)setIsSelected:(BOOL)isSelected
{
	_isSelected = isSelected;
	[self setNeedsDisplay:YES];
}

@end


@implementation ResourceCollectionItem

- (void)setSelected:(BOOL)selected
{
	[(ResourceCollectionItemView *)[self view] setIsSelected:selected];
	[super setSelected:selected];
}

- (IBAction)exportFile:(id)sender
{
	ResourceEntities *res = self.collectionView.content[self.collectionView.selectionIndexes.firstIndex];
	
	NSBitmapImageRep *imgRep = [[res.image representations] objectAtIndex: 0];
	NSData *data = [imgRep representationUsingType: NSPNGFileType properties: nil];
	
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES );
	NSString* theDesktopPath = [paths objectAtIndex:0];
	[data writeToFile: [NSString stringWithFormat:@"%@/%@.png", theDesktopPath, res.name] atomically: NO];
}

@end
