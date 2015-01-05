//
//  PreviewCollectionView.m
//  RSRCManager
//
//  Created by Vitalii Parovishnyk on 12/22/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import "PreviewCollectionView.h"
#import "AppDelegate.h"

@implementation PreviewCollectionView

- (void)keyDown:(NSEvent *)theEvent
{
	NSString *key = [theEvent charactersIgnoringModifiers];
	if ([key isEqual:@" "])
	{
		if ([self.qlDelegate respondsToSelector:@selector(didPressSpacebarForCollectionView:)])
		{
			[self.qlDelegate didPressSpacebarForCollectionView:self];
		}
	}
	else
	{
		[super keyDown:theEvent];
	}
}

- (void)didChangedSelectionCollectionItemView:(NSCollectionViewItem *)collectionViewItem
{
	if ([self.qlDelegate respondsToSelector:@selector(didChangedSelectionCollectionItemView:)])
	{
		[self.qlDelegate didChangedSelectionCollectionItemView:collectionViewItem];
	}
}

@end
