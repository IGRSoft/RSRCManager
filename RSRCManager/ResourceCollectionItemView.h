//
//  ResourceCollectionItemView.h
//  RSRCManager
//
//  Created by Vitalii Parovishnyk on 12/20/14.
//  Copyright (c) 2014 IGR Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ResourceCollectionItemView : NSView
{
	BOOL _isSelected;
}
@property (nonatomic, assign) BOOL isSelected;

@end


@interface ResourceCollectionItem : NSCollectionViewItem

@end