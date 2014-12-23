//
//  ResourceCollectionItemView.m
//  iResource
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "ResourceCollectionItemView.h"
#import "ResourceEntities.h"
#import "PreviewCollectionView.h"
#import "AppDelegate.h"

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
		fillColor = [NSColor colorWithCalibratedWhite:0.850 alpha:1.000];
		strokeColor = [NSColor colorWithCalibratedRed:0.400 green:0.650 blue:0.900 alpha:1.000];
		
		filedColor = [NSColor blackColor];
	}
	else
	{
		fillColor = [NSColor clearColor];
		strokeColor = [NSColor colorWithCalibratedWhite:0.850 alpha:1.000];
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
	
	PreviewCollectionView *cv = (PreviewCollectionView *)self.collectionView;
	[cv didChangedSelectionCollectionItemView:self];
}

- (IBAction)exportFile:(id)sender
{
	ResourceEntities *res = self.representedObject;
	
	AppDelegate *app = [[NSApplication sharedApplication] delegate];
	[app saveResource:res];
}

@end
