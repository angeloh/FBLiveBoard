//
//  FBLiveBoardViewController.h
//  FBLiveBoard
//
//  Created by Angelo Kaichen Huang on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AQGridView.h"
#import "FBConnect.h"

@class FBLiveBoardIconCell;

typedef enum apiCall {
    kAPILogout,
    kAPIGraphUserPermissionsDelete,
    kDialogPermissionsExtended,
    kDialogRequestsSendToMany,
    kAPIGetAppUsersFriendsNotUsing,
    kAPIGetAppUsersFriendsUsing,
    kAPIFriendsForDialogRequests,
    kDialogRequestsSendToSelect,
    kAPIFriendsForTargetDialogRequests,
    kDialogRequestsSendToTarget,
    kDialogFeedUser,
    kAPIFriendsForDialogFeed,
    kDialogFeedFriend,
    kPostFeedFriend,
    kAPIGraphUserPermissions,
    kAPIGraphMe,
    kAPIGraphUserFriends,
    kDialogPermissionsCheckin,
    kDialogPermissionsCheckinForRecent,
    kDialogPermissionsCheckinForPlaces,
    kAPIGraphSearchPlace,
    kAPIGraphUserCheckins,
    kAPIGraphUserPhotosPost,
    kAPIGraphUserVideosPost,
} apiCall;

@interface FBLiveBoardViewController : UIViewController <
    AQGridViewDataSource, 
    AQGridViewDelegate, 
    UIGestureRecognizerDelegate,
    FBRequestDelegate>
{
    int currentAPICall;
    
    NSMutableArray * _icons;
    NSMutableArray * _chosen_icons;

    AQGridView * _gridView;
    AQGridView * _gridHeaderView;
    
    NSUInteger _emptyCellIndex;
    
    NSUInteger _dragOriginIndex;
    CGPoint _dragOriginCellOrigin;
    
    FBLiveBoardIconCell * _draggingCell;
    
    UIActivityIndicatorView *_activityIndicator;
    UILabel *_messageLabel;
    UIView *_messageView;
    
    NSMutableDictionary *_cacheIcon;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *messageLabel;
@property (nonatomic, retain) UIView *messageView;

@end
