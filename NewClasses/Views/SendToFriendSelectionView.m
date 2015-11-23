
//! \file   SendToFriendSelectionView.m
//! \brief  UIView based class that show a list of friends and some other objects.
//__________________________________________________________________________________________________

#import "SendToFriendSelectionView.h"
#import "FriendRecord.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "FriendSelectionView.h"
#import "VideoViewController.h"
//__________________________________________________________________________________________________

//! UIView based class that show a list of friends and some other objects.
@implementation SendToFriendSelectionView

{
  NSInteger SelectedFriend;
  UITableView *tableView;
    NSMutableArray *sectionTitles;
    NSMutableArray *sectionPeople;
    NSMutableArray *person;
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
   // NSLog(@"contacts: %@", contactsNotUsers);
    self.allFriends     = contactsNotUsers;
  self->FriendsList.contentOffset = CGPointMake(0, 0- FriendsList.contentInset.top);
    
  [self->FriendsList ReloadTableData];



}
//__________________________________________________________________________________________________

@end
