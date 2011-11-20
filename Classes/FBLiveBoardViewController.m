//
//  FBLiveBoardViewController.m
//  FBLiveBoard
//
//  Created by Angelo Kaichen Huang on 11/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FBLiveBoardViewController.h"
#import "AQGridView.h"
#import "FBLiveBoardIconCell.h"
#import "FBLiveBoardAppDelegate.h"

@implementation FBLiveBoardViewController

@synthesize activityIndicator = _activityIndicator;
@synthesize messageLabel = _messageLabel;
@synthesize messageView = _messageView;
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark - Private

- (void) showActivityIndicator
{
    if (![_activityIndicator isAnimating]) {
        [_activityIndicator startAnimating];   
    }
}

/*
 * This method hides the activity indicator
 * and enables user interaction once more.
 */
- (void) hideActivityIndicator
{
    if ([_activityIndicator isAnimating]) {
        [_activityIndicator stopAnimating];   
    }
}

/*
 * Helper method to return the picture endpoint for a given Facebook
 * object. Useful for displaying user, friend, or location pictures.
 */
- (UIImage *) imageForObject:(NSString *)objectID {
    // Get the object image
    NSString *url = [[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",objectID];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [url release];
    return image;
}


/*
 * This method is used to display API confirmation and
 * error messages to the user.
 */
-(void)showMessage:(NSString *)message
{
    
    CGRect labelFrame = _messageView.frame;
    labelFrame.origin.y = [UIScreen mainScreen].bounds.size.height - self.navigationController.navigationBar.frame.size.height - 20;
    _messageView.frame = labelFrame;
    _messageLabel.text = message;
    _messageView.hidden = NO;
    
    // Use animation to show the message from the bottom then
    // hide it.
    [UIView animateWithDuration:0.5
                          delay:1.0
                        options: UIViewAnimationCurveEaseOut
                     animations:^{
                         CGRect labelFrame = _messageView.frame;
                         labelFrame.origin.y -= labelFrame.size.height;
                         _messageView.frame = labelFrame;
                     } 
                     completion:^(BOOL finished){
                         if (finished) {
                             [UIView animateWithDuration:0.5
                                                   delay:3.0
                                                 options: UIViewAnimationCurveEaseOut
                                              animations:^{
                                                  CGRect labelFrame = _messageView.frame;
                                                  labelFrame.origin.y += _messageView.frame.size.height;
                                                  _messageView.frame = labelFrame;
                                              } 
                                              completion:^(BOOL finished){
                                                  if (finished) {
                                                      _messageView.hidden = YES;
                                                      _messageLabel.text = @"";  
                                                  }
                                              }];
                         }
                     }];
}

-(void)showAlert:(NSString *)message
{
    UIAlertView *alertView = [[UIAlertView alloc] 
                              initWithTitle:@"FBLiveBoard" 
                              message:message 
                              delegate:self 
                              cancelButtonTitle:@"OK" 
                              otherButtonTitles:nil, 
                              nil];
    [alertView show];
    [alertView release];
}

-(BOOL)isAccessTokenError:(NSError *) error {
    if ([[error domain] isEqualToString:@"facebookErrDomain"] && [error code] == 10000 ) {
        NSDictionary *userInfo = [error userInfo];
        NSDictionary *errorAsDictionary = [userInfo objectForKey:@"error"];
        if ([[errorAsDictionary objectForKey:@"type"] isEqualToString:@"OAuthException"]) {
            //Invalid access token
            return YES;         
        }
    }
    if ([[error domain] isEqualToString:@"facebookErrDomain"] && ([error code] == 110 || [error code] == 190)) {
        //Error accessing access token
        return YES;         
    }
    return NO;
}

/*
 * This method hides the message, only needed if view closed
 * and animation still going on.
 */
-(void)hideMessage
{
    _messageView.hidden = YES;
    _messageLabel.text = @"";
}


#pragma mark -
#pragma mark Facebook API Calls

/*
 * Graph API: Method to post friends wall.
 */
- (void) postFeedToGraphFriends:(NSString *)fId {
    // Do not set current API as this is commonly called by other methods
    FBLiveBoardAppDelegate *delegate = (FBLiveBoardAppDelegate *) [[UIApplication sharedApplication] delegate];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"How's going?",@"message",fId,@"target_id",nil];
    
    [[delegate facebook] requestWithGraphPath:[NSString stringWithFormat:@"%@/feed/",fId] andParams:params andHttpMethod:@"POST" andDelegate:self];
    
    NSLog( @"Post to friend's feed fId: %@", fId );
//    [[delegate facebook] requestWithGraphPath:@"149253681843478/feed" andParams:params andHttpMethod:@"POST" andDelegate:self];
    
}

/*
 * Graph API: post friends wall
 */
- (void) postFriendsWall:(NSString *)fId {
    currentAPICall = kPostFeedFriend;
    [self postFeedToGraphFriends:fId];
}

-(void)pokeFriends
{
    if ([_chosen_icons count] <= 0) {
        [self showAlert:@"Oops, select one friend to send."];
    } else {
        for (NSUInteger i=0; i<[_chosen_icons count]; i++) {
            currentPostFriendIdx = i;
            // The object's image
            UIImage *icon = [_chosen_icons objectAtIndex:i];
            NSString *friendID = [_cacheIcon objectForKey:icon];
            [self postFriendsWall:friendID];
            
        }
    }
}


/*
 * Graph API: Method to get the user's friends.
 */
- (void) apiGraphFriends {
    [self showActivityIndicator];
    // Do not set current API as this is commonly called by other methods
    FBLiveBoardAppDelegate *delegate = (FBLiveBoardAppDelegate *) [[UIApplication sharedApplication] delegate]; 
    [[delegate facebook] requestWithGraphPath:@"me/friends" andDelegate:self];
}

/*
 * Graph API: Get the user's friends
 */
- (void) getUserFriends {
    currentAPICall = kAPIGraphUserFriends;
    [self apiGraphFriends];
}

- (void) logoutButtonClicked {
    FBLiveBoardAppDelegate *delegate = (FBLiveBoardAppDelegate *) [[UIApplication sharedApplication] delegate]; 
    [[delegate facebook] logout:self];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = NSLocalizedString(@"FB LiveBoard", @"Controller Title: FB LiveBoard");
        
        self.navigationItem.rightBarButtonItem = 
        	[[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Poke", @"Poke fb friends")
        									  style:UIBarButtonItemStylePlain
        									 target:self 
        									 action:@selector(pokeFriends)] autorelease];
        
        self.navigationItem.leftBarButtonItem = 
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Logout", @"Logout")
                                          style:UIBarButtonItemStylePlain
                                         target:self 
                                         action:@selector(logoutButtonClicked)] autorelease];
        
        _cacheIcon = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadView {
    [super loadView];
    
    // Activity Indicator
    int xPosition = (self.view.bounds.size.width / 2.0) - 15.0;
    int yPosition = (self.view.bounds.size.height / 2.0) - 15.0;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(xPosition, yPosition, 30, 30)];
    _activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [self.view addSubview:_activityIndicator];
    
    // Message Label for showing confirmation and status messages
//    CGFloat yLabelViewOffset = self.view.bounds.size.height-self.navigationController.navigationBar.frame.size.height-30;
//    _messageView = [[UIView alloc] 
//                    initWithFrame:CGRectMake(0, yLabelViewOffset, self.view.bounds.size.width, 30)];
//    _messageView.backgroundColor = [UIColor lightGrayColor];
//    
//    UIView *messageInsetView = [[UIView alloc] initWithFrame:CGRectMake(1, 1, self.view.bounds.size.width-1, 28)]; 
//    messageInsetView.backgroundColor = [UIColor colorWithRed:255.0/255.0
//                                                       green:248.0/255.0
//                                                        blue:228.0/255.0 
//                                                       alpha:1];
//    _messageLabel = [[UILabel alloc] 
//                     initWithFrame:CGRectMake(4, 1, self.view.bounds.size.width-10, 26)];
//    _messageLabel.text = @"";
//    _messageLabel.font = [UIFont fontWithName:@"Helvetica" size:14.0];
//    _messageLabel.backgroundColor = [UIColor colorWithRed:255.0/255.0
//                                                    green:248.0/255.0
//                                                     blue:228.0/255.0 
//                                                    alpha:0.6];
//    [messageInsetView addSubview:_messageLabel];
//    [_messageView addSubview:messageInsetView];    
//    [messageInsetView release];
//    _messageView.hidden = YES;
//    [self.view addSubview:_messageView];
    
    _emptyCellIndex = NSNotFound;
    
    self.view.autoresizesSubviews = YES;
    
    CGFloat navHigh = self.navigationController.navigationBar.frame.size.height;
    
    // background goes in first
    UIImageView * background = [[UIImageView alloc] initWithFrame: CGRectMake(0.0, 150.0 - navHigh, self.view.frame.size.width, self.view.frame.size.height - 150.0 + navHigh)];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    background.contentMode = UIViewContentModeCenter;
    background.image = [UIImage imageNamed: @"background.png"];
    
    [self.view addSubview: background];
    
    // grid view sits on top of the background image
    //    _gridView = [[AQGridView alloc] initWithFrame: self.view.bounds];
    
    _gridView = [[AQGridView alloc] initWithFrame: CGRectMake(0.0, 150.0 - navHigh, self.view.frame.size.width, self.view.frame.size.height - 150.0 + navHigh)];
    _gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _gridView.backgroundColor = [UIColor clearColor];
    _gridView.opaque = NO;
    _gridView.dataSource = self;
    _gridView.delegate = self;
    
    // cancel touches of content
    _gridView.canCancelContentTouches = NO;
    //    _gridView.scrollEnabled = YES;
    //    _gridView.autoresizesSubviews = YES;
    
    _gridHeaderView = [[AQGridView alloc] initWithFrame: CGRectMake(0.0, 0.0, self.view.frame.size.width, 150.0)];
    _gridHeaderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    _gridHeaderView.backgroundColor = [UIColor whiteColor];
    _gridHeaderView.opaque = NO;
    _gridHeaderView.dataSource = self;
    
    if ( UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) )
    {
        // bring 1024 in to 1020 to make a width divisible by five
        _gridView.leftContentInset = 2.0;
        _gridView.rightContentInset = 2.0;
        _gridHeaderView.leftContentInset = 2.0;
        _gridHeaderView.rightContentInset = 2.0;
    }
    
    [self.view addSubview: _gridView];
    [self.view addSubview: _gridHeaderView];
    
    // add our gesture recognizer to the grid view
    UILongPressGestureRecognizer * gr = [[UILongPressGestureRecognizer alloc] initWithTarget: self action: @selector(moveActionGestureRecognizerStateChanged:)];
    gr.minimumPressDuration = 0.2;
    gr.delegate = self;
    
    //    UIPanGestureRecognizer *gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveActionGestureRecognizerStateChanged:)];
    //    [gr setMaximumNumberOfTouches:2];
    //    [gr setDelegate:self];
    
    [_gridView addGestureRecognizer: gr];
    [gr release];
    
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    if ( _chosen_icons == nil )
    {
        _chosen_icons = [[NSMutableArray alloc] initWithCapacity: 20];
    }
    
    if ( _icons == nil )
    {
        _icons = [[NSMutableArray alloc] initWithCapacity: 20];
        [self getUserFriends];
        
//        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0.0, 0.0, 72.0, 72.0)
//                                                         cornerRadius: 18.0];
//        
//        CGFloat saturation = 0.6, brightness = 0.7;
//        for ( NSUInteger i = 1; i <= 20; i++ )
//        {
//            UIColor * color = [UIColor colorWithHue: (CGFloat)i/20.0
//                                         saturation: saturation
//                                         brightness: brightness
//                                              alpha: 1.0];
//            
//            UIGraphicsBeginImageContext( CGSizeMake(72.0, 72.0) );
//            
//            // clear background
//            [[UIColor clearColor] set];
//            UIRectFill( CGRectMake(0.0, 0.0, 72.0, 72.0) );
//            
//            // fill the rounded rectangle
//            [color set];
//            [path fill];
//            
//            UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            // put the image into our list
//            [_icons addObject: image];
//        }

    }
    
    [_gridView reloadData];
    [_gridHeaderView reloadData];
}


// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return NO;
}

- (void) willRotateToInterfaceOrientation: (UIInterfaceOrientation) toInterfaceOrientation
                                 duration: (NSTimeInterval) duration
{
    if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) )
    {
        // width will be 768, which divides by four nicely already
        NSLog( @"Setting left+right content insets to zero" );
        _gridView.leftContentInset = 0.0;
        _gridView.rightContentInset = 0.0;
    }
    else
    {
        // width will be 1024, so subtract a little to get a width divisible by five
        NSLog( @"Setting left+right content insets to 2.0" );
        _gridView.leftContentInset = 2.0;
        _gridView.rightContentInset = 2.0;
    }
}

/*
 * This method handles any clean up needed if the view
 * is about to disappear.
 */
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Hide the activitiy indicator
    [self hideActivityIndicator];
    // Hide the message.
//    [self hideMessage];
}

- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    NI_RELEASE_SAFELY(_gridHeaderView);
    NI_RELEASE_SAFELY(_gridView);
}

- (void) dealloc
{
    NI_RELEASE_SAFELY(_activityIndicator);
//    NI_RELEASE_SAFELY(_messageView);
//    NI_RELEASE_SAFELY(_messageLabel);
    NI_RELEASE_SAFELY(_icons);
    NI_RELEASE_SAFELY(_chosen_icons);
    NI_RELEASE_SAFELY(_gridHeaderView);
    NI_RELEASE_SAFELY(_gridView);
    NI_RELEASE_SAFELY(_cacheIcon);
    [super dealloc];
}

//#pragma mark -
//#pragma mark touch events

//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
//{
//	if (draggedImage != nil)
//	{
//		UITouch *touch = [[event allTouches] anyObject];
//		
//		if (CGRectContainsPoint(targetImage.frame, [touch locationInView:self.view]))
//		{
//			targetImage.image = draggedImage.image;
//		}
//		
//		[draggedImage removeFromSuperview];
//		[draggedImage release];
//		draggedImage = nil;
//	}
//}

#pragma mark -
#pragma mark UIGestureRecognizer Delegate/Actions

- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer *) gestureRecognizer
{
    CGPoint location = [gestureRecognizer locationInView: _gridView];
    if ( [_gridView indexForItemAtPoint: location] < [_icons count] )
        return ( YES );
    
    // touch is outside the bounds of any icon cells, so don't start the gesture
    return ( NO );
}

- (void) moveActionGestureRecognizerStateChanged: (UIGestureRecognizer *) recognizer
{
    switch ( recognizer.state )
    {
        default:
        case UIGestureRecognizerStateFailed:
            // do nothing
            break;
            
        case UIGestureRecognizerStatePossible:
        case UIGestureRecognizerStateCancelled:
        {
            [_gridView beginUpdates];
            
            if ( _emptyCellIndex != _dragOriginIndex )
            {
                [_gridView moveItemAtIndex: _emptyCellIndex toIndex: _dragOriginIndex withAnimation: AQGridViewItemAnimationFade];
            }
            
            _emptyCellIndex = _dragOriginIndex;
            
            // move the cell back to its origin
            [UIView beginAnimations: @"SnapBack" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect f = _draggingCell.frame;
            f.origin = _dragOriginCellOrigin;
            _draggingCell.frame = f;
            
            [UIView commitAnimations];
            
            [_gridView endUpdates];
            
            break;
        }
            
        case UIGestureRecognizerStateEnded:
        {
            CGFloat border = 150 - self.navigationController.navigationBar.frame.size.height;
            CGPoint pointInParent = [recognizer locationInView: self.view];
            
            CGPoint p = [recognizer locationInView: _gridView];
            NSUInteger index = [_gridView indexForItemAtPoint: p];
			if ( index == NSNotFound )
			{
				// index is the last available location
				index = [_icons count] - 1;
			}
            
            // update the data store
            id obj = [[_icons objectAtIndex: _dragOriginIndex] retain];
            [_icons removeObjectAtIndex: _dragOriginIndex];
            
            if (pointInParent.y < border) {
                [_gridHeaderView beginUpdates];
                [_chosen_icons addObject:obj];
                [_gridHeaderView endUpdates];
                [_gridHeaderView reloadData];
                
                [_gridView beginUpdates];
                [_gridView deleteItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
                                               withAnimation: AQGridViewItemAnimationNone];
                
                // move the cell back to its origin
                [UIView beginAnimations: @"SnapBack" context: NULL];
                [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
                [UIView setAnimationDuration: 0.5];
                [UIView setAnimationDelegate: self];
                [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
                
                CGRect f = _draggingCell.frame;
                f.origin = _dragOriginCellOrigin;
                _draggingCell.frame = f;
                
                [UIView commitAnimations];
                
                [_gridView endUpdates];
                
                [_gridView reloadData];
                
                [obj release];
                break;
            } else {
                [_icons insertObject: obj atIndex: index];
                [obj release];
            }
            
            if ( index != _emptyCellIndex )
            {
                [_gridView beginUpdates];
                [_gridView moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                [_gridView endUpdates];
            }
            
            // move the real cell into place
            [UIView beginAnimations: @"SnapToPlace" context: NULL];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration: 0.5];
            [UIView setAnimationDelegate: self];
            [UIView setAnimationDidStopSelector: @selector(finishedSnap:finished:context:)];
            
            CGRect r = [_gridView rectForItemAtIndex: _emptyCellIndex];
            CGRect f = _draggingCell.frame;
            f.origin.x = r.origin.x + floorf((r.size.width - f.size.width) * 0.5);
//            f.origin.y = r.origin.y + floorf((r.size.height - f.size.height) * 0.5) - _gridView.contentOffset.y;
            // grid view might be not in origin 0, 0
            f.origin.y = r.origin.y + floorf((r.size.height - f.size.height) * 0.5) - _gridView.contentOffset.y + _gridView.frame.origin.y;
            NSLog( @"Gesture ended-- moving to %@", NSStringFromCGRect(f) );
            _draggingCell.frame = f;
            
            _draggingCell.transform = CGAffineTransformIdentity;
            _draggingCell.alpha = 1.0;
            
            [UIView commitAnimations];
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            NSUInteger index = [_gridView indexForItemAtPoint: [recognizer locationInView: _gridView]];
            _emptyCellIndex = index;    // we'll put an empty cell here now
            
            // find the cell at the current point and copy it into our main view, applying some transforms
            AQGridViewCell * sourceCell = [_gridView cellForItemAtIndex: index];
            CGRect frame = [self.view convertRect: sourceCell.frame fromView: _gridView];
            _draggingCell = [[FBLiveBoardIconCell alloc] initWithFrame: frame reuseIdentifier: @""];
            _draggingCell.icon = [_icons objectAtIndex: index];
            [self.view addSubview: _draggingCell];
            
            // grab some info about the origin of this cell
            _dragOriginCellOrigin = frame.origin;
            _dragOriginIndex = index;
            
            [UIView beginAnimations: @"" context: NULL];
            [UIView setAnimationDuration: 0.2];
            [UIView setAnimationCurve: UIViewAnimationCurveEaseOut];
            
            // transformation-- larger, slightly transparent
            _draggingCell.transform = CGAffineTransformMakeScale( 1.2, 1.2 );
            _draggingCell.alpha = 0.7;
            
            // also make it center on the touch point
            _draggingCell.center = [recognizer locationInView: self.view];
            
            [UIView commitAnimations];
            
            // reload the grid underneath to get the empty cell in place
            [_gridView reloadItemsAtIndices: [NSIndexSet indexSetWithIndex: index]
                              withAnimation: AQGridViewItemAnimationNone];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            // update draging cell location
            _draggingCell.center = [recognizer locationInView: self.view];
            
            // don't do anything with content if grid view is in the middle of an animation block
            if ( _gridView.isAnimatingUpdates )
                break;
            
            // update empty cell to follow, if necessary
            NSUInteger index = [_gridView indexForItemAtPoint: [recognizer locationInView: _gridView]];
			
			// don't do anything if it's over an unused grid cell
			if ( index == NSNotFound )
			{
				// snap back to the last possible index
				index = [_icons count] - 1;
			}
			
            if ( index != _emptyCellIndex )
            {
                NSLog( @"Moving empty cell from %u to %u", _emptyCellIndex, index );
                
                // batch the movements
                [_gridView beginUpdates];
                
                // move everything else out of the way
                if ( index < _emptyCellIndex )
                {
                    for ( NSUInteger i = index; i < _emptyCellIndex; i++ )
                    {
                        NSLog( @"Moving %u to %u", i, i+1 );
                        [_gridView moveItemAtIndex: i toIndex: i+1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                else
                {
                    for ( NSUInteger i = index; i > _emptyCellIndex; i-- )
                    {
                        NSLog( @"Moving %u to %u", i, i-1 );
                        [_gridView moveItemAtIndex: i toIndex: i-1 withAnimation: AQGridViewItemAnimationFade];
                    }
                }
                
                [_gridView moveItemAtIndex: _emptyCellIndex toIndex: index withAnimation: AQGridViewItemAnimationFade];
                _emptyCellIndex = index;
                
                [_gridView endUpdates];
            }
            
            break;
        }
    }
}

- (void) finishedSnap: (NSString *) animationID finished: (NSNumber *) finished context: (void *) context
{
    NSIndexSet * indices = [[NSIndexSet alloc] initWithIndex: _emptyCellIndex];
    _emptyCellIndex = NSNotFound;
    
    // load the moved cell into the grid view
    [_gridView reloadItemsAtIndices: indices withAnimation: AQGridViewItemAnimationNone];
    
    // dismiss our copy of the cell
    [_draggingCell removeFromSuperview];
    NI_RELEASE_SAFELY(_draggingCell);
    
    [indices release];
}

#pragma mark -
#pragma mark GridView Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) gridView
{
    if ([gridView isEqual:_gridView]) {
        return ( [_icons count] );
    } else {
        return ( [_chosen_icons count] );
    }
    
}

- (AQGridViewCell *) gridView: (AQGridView *) gridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * EmptyIdentifier = @"EmptyIdentifier";
    static NSString * CellIdentifier = @"CellIdentifier";
    
    if ( index == _emptyCellIndex && [gridView isEqual:_gridView])
    {
        NSLog( @"Loading empty cell at index %u", index );
        AQGridViewCell * hiddenCell = [gridView dequeueReusableCellWithIdentifier: EmptyIdentifier];
        if ( hiddenCell == nil )
        {
            // must be the SAME SIZE AS THE OTHERS
            // Yes, this is probably a bug. Sigh. Look at -[AQGridView fixCellsFromAnimation] to fix
            hiddenCell = [[[AQGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0)
                                                reuseIdentifier: EmptyIdentifier] autorelease];
        }
        
        hiddenCell.hidden = YES;
        return ( hiddenCell );
    }
    
    FBLiveBoardIconCell * cell = (FBLiveBoardIconCell *)[gridView dequeueReusableCellWithIdentifier: CellIdentifier];
    if ( cell == nil )
    {
        cell = [[[FBLiveBoardIconCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 72.0, 72.0) reuseIdentifier: CellIdentifier] autorelease];
    }
    
    if ([gridView isEqual:_gridView]) {
        cell.icon = [_icons objectAtIndex: index];
    } else {
        cell.icon = [_chosen_icons objectAtIndex: index];
    }
    
    return ( cell );
}

- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) gridView
{
    return ( CGSizeMake(100.0, 100.0) );
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object. The resulting object may be a dictionary, an array, a string,
 * or a number, depending on the format of the API response. If you need access
 * to the raw response, use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
    [self hideActivityIndicator];
    if ([result isKindOfClass:[NSArray class]] && ([result count] > 0)) {
        result = [result objectAtIndex:0];
    }
    switch (currentAPICall) {
        case kAPIGraphUserFriends:
        {
            NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:1];
            NSArray *resultData = [result objectForKey:@"data"];
            
            if ([resultData count] > 0) {
                for (NSUInteger i=0; i<[resultData count] && i < 50; i++) {
                    [friends addObject:[resultData objectAtIndex:i]];
                    // The object's image
                    UIImage *image = [self imageForObject:[[resultData objectAtIndex:i] objectForKey:@"id"]];
                    [_cacheIcon setObject:[[resultData objectAtIndex:i] objectForKey:@"id"] forKey:image];
                    [_icons addObject:image];
                }
                [_gridView reloadData];
            } else {
                [self showAlert:@"You have no friends."];
            }
            [friends release];
            break;
        }
        case kPostFeedFriend:
        {
            if (currentPostFriendIdx == ([_chosen_icons count] - 1)) {
                NSLog(@"You just poked friends!");
                [self showAlert:@"You just poked friends!"];
                for (NSUInteger i=0; i<[_chosen_icons count]; i++) {
                    [_icons addObject:[_chosen_icons objectAtIndex:i]];
                }
                [_chosen_icons removeAllObjects];
                [_gridHeaderView reloadData];
                [_gridView reloadData];
            }
        }
        default:
            break;
    }
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
    if ([self isAccessTokenError:error]) {
        [self logoutButtonClicked];
        
        NSLog(@"Try again to login");
        
        FBLiveBoardAppDelegate *delegate = (FBLiveBoardAppDelegate *) [[UIApplication sharedApplication] delegate]; 
        
        // check fb token
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"FBAccessTokenKey"] 
            && [defaults objectForKey:@"FBExpirationDateKey"]) {
            delegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
            delegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
        }
        
        if (![delegate.facebook isSessionValid]) {
            NSArray *permissions = [[NSArray alloc] initWithObjects:
                                    @"user_likes", 
                                    @"read_stream",
                                    @"publish_stream",
                                    nil];
            [delegate.facebook authorize:permissions];
            [permissions release];
        }

    }
    
};

#pragma mark - FBDialogDelegate Methods

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
    switch (currentAPICall) {
        case kDialogFeedUser:
        case kDialogFeedFriend:
        case kPostFeedFriend:
        {
            [self showAlert:@"Published feed successfully."];
            break;
        }
        default:
            break;
    }
}

- (void) dialogDidNotComplete:(FBDialog *)dialog {
    NSLog(@"Dialog dismissed.");
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error {
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"Err details: %@", [error description]);
    if ([self isAccessTokenError:error]) {
        [self logoutButtonClicked];
    }
}

#pragma mark - FBSessionDelegate Methods

- (void)fbDidLogin {
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    
    FBLiveBoardAppDelegate *delegate = (FBLiveBoardAppDelegate *) [[UIApplication sharedApplication] delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[delegate.facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[delegate.facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
    [self getUserFriends];
    [_gridHeaderView reloadData];
    [_gridView reloadData];
}

- (void) fbDidLogout {
    [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    [_icons removeAllObjects];
    [_chosen_icons removeAllObjects];
    [_gridHeaderView reloadData];
    [_gridView reloadData];
}
@end
