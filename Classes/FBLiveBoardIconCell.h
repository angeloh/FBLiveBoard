//
//  FBLiveBoardIconCell.h
//  FBLiveBoard
//
//  Created by Angelo Kaichen Huang on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AQGridViewCell.h"

@interface FBLiveBoardIconCell : AQGridViewCell
{
    UIImageView * _iconView;
}
@property (nonatomic, retain) UIImage * icon;

@end
