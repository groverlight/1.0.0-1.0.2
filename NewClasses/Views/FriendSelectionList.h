
//! \file   FriendSelectionList.h
//! \brief  UIView based class that let select a friend in a list.
//__________________________________________________________________________________________________

#import <UIKit/UIKit.h>
#import "Blocks.h"
#import "TableView.h"
//__________________________________________________________________________________________________

//! UIView based class that let select a friend in a list.
@interface FriendSelectionList : TableView <UIScrollViewDelegate>
{
@public
  BlockAction         RefreshRequest;
  BlockIntAction      TouchTapped;
  BlockPointIntAction TouchStarted;
  BlockPointIntAction TouchEnded;
  BlockPointIntAction ProgressCancelled;
  BlockPointIntAction ProgressCompleted;
  BOOL                StateViewHidden;
  BOOL                StateViewOnRight;
  BOOL                ShowSectionHeaders;
  BOOL                UseBlankState;
  BOOL                UseDotsVsState;
  BOOL                SimulateButton;
  BOOL                IgnoreUnreadMessages;
}
//____________________

@property NSArray*  recentFriends;
@property NSArray*  allFriends;
@property NSInteger maxNumRecentFriends;
//____________________

- (void)clearSelection;
//____________________

@end
//__________________________________________________________________________________________________
