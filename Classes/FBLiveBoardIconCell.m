//
//  FBLiveBoardIconCell.m
//  FBLiveBoard
//
//  Created by Angelo Kaichen Huang on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FBLiveBoardIconCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation FBLiveBoardIconCell
- (id) initWithFrame: (CGRect) frame reuseIdentifier:(NSString *) reuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: reuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.0, 0.0, 72.0, 72.0)
                                                     cornerRadius: 18.0];
    
    _iconView = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)];
    _iconView.backgroundColor = [UIColor clearColor];
    _iconView.opaque = NO;
    _iconView.layer.shadowPath = path.CGPath;
    _iconView.layer.shadowRadius = 20.0;
    _iconView.layer.shadowOpacity = 0.4;
    _iconView.layer.shadowOffset = CGSizeMake( 20.0, 20.0 );
    
    [self.contentView addSubview: _iconView];
    
    self.contentView.backgroundColor = [UIColor clearColor];
    self.backgroundColor = [UIColor clearColor];
    
    self.contentView.opaque = NO;
    self.opaque = NO;
    
    // set exclusiveTouch to YES
    self.contentView.exclusiveTouch = YES;
    self.exclusiveTouch = YES;
    
    self.selectionStyle = AQGridViewCellSelectionStyleNone;
    
    return ( self );
}

- (void) dealloc
{
    [_iconView release];
    [super dealloc];
}

- (UIImage *) icon
{
    return ( _iconView.image );
}

- (void) setIcon: (UIImage *) anIcon
{
    _iconView.image = anIcon;
}

@end
