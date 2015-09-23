
//! \file   SendToFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "SendToFriendSelectionView.h"
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@implementation SendToFriendSelectionView
{
  NSInteger SelectedFriend;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
  [super Initialize];
  GlobalParameters* parameters  = GetGlobalParameters();
  ListName.text                 = parameters.friendsSendToLabelTitle;
  self.showSectionHeaders       = YES;
  self.useBlankState            = NO;
  self.ignoreUnreadMessages     = YES;
  self.maxNumRecentFriends      = GetGlobalParameters().friendsMaxRecentFriends;
}
//__________________________________________________________________________________________________

- (void)dealloc
{
  [self cleanup];
}
//__________________________________________________________________________________________________

- (void)cleanup
{
}
//__________________________________________________________________________________________________

- (void)updateFriendsLists
{
  self.recentFriends  = GetTimeSortedFriendRecords();
  self.allFriends     = GetNameSortedFriendRecords();
  [FriendsList ReloadTableData];
}
//__________________________________________________________________________________________________

@end
