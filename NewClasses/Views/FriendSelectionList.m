
//! \file   FriendSelectionList.m
//! \brief  UIView based class that let select a friend in a list.
//__________________________________________________________________________________________________

#import "FriendSelectionList.h"
#import "Alert.h"
#import "FriendRecord.h"
#import "Colors.h"
#import "EditView.h"
#import "FriendListItemStateView.h"
#import "GlobalParameters.h"
#import "ParseUser.h"
#import "PopLabel.h"
#import "StillImageCapture.h"
#import "ThreeDotsPseudoButtonView.h"
#import "TopBarView.h"
#import "FriendSelectionView.h"
//__________________________________________________________________________________________________

#define REFRESH_THRESHOLD_OFFSET -50
//__________________________________________________________________________________________________


//! UIView based class that let select a friend in a list.
@implementation FriendSelectionList
{
    NSIndexPath*  SelectedItem;
    BOOL          TouchActive;
    BOOL          Completed;
    BOOL          ParseRefreshActive;
    NSArray*      RecentFriendsList;
    NSArray*      AllFriendsList;
    NSMutableArray* arrayOfPeopleInSection;
    NSMutableArray* arrayOfSectionTitles;
    NSInteger     MaxRecentFriends;
}
//____________________

//! Initialize the object however it has been created.
-(void)Initialize
{
    [super Initialize];
    indexTitles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];

    GlobalParameters* parameters  = GetGlobalParameters();
    self.separatorColor           = Transparent;
    self.backgroundColor          = parameters.friendsListBackgroundColor;
    self.rowHeight                = parameters.friendsListRowHeight;
    self.sectionHeaderHeight      = parameters.friendsListHeaderHeight;
    RecentFriendsList             = [NSMutableArray arrayWithCapacity:10];
    AllFriendsList                = [NSMutableArray arrayWithCapacity:10];
    arrayOfPeopleInSection        = [[NSMutableArray alloc]init];
    arrayOfSectionTitles          = [[NSMutableArray alloc]init];
    SelectedItem                  = nil;
    TouchActive                   = NO;
    Completed                     = NO;
    ParseRefreshActive            = NO;
    StateViewHidden               = NO;
    StateViewOnRight              = NO;
    ShowSectionHeaders            = NO;
    UseDotsVsState                = NO;
    SimulateButton                = NO;
    IgnoreUnreadMessages          = NO;
    MaxRecentFriends              = INT_MAX;
    
    RefreshRequest = ^
    { // Default action: do nothing!
    };
    TouchTapped = ^(NSInteger row)
    { // Default action: do nothing!
    };
    TouchStarted = ^(CGPoint point, NSInteger row)
    { // Default action: do nothing!
    };
    TouchEnded = ^(CGPoint point, NSInteger row)
    { // Default action: do nothing!
    };
    ProgressCancelled = ^(CGPoint point, NSInteger row)
    { // Default action: do nothing!
    };
    ProgressCompleted = ^(CGPoint point, NSInteger row)
    { // Default action: do nothing!
    };
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

- (void)layout
{
}
//__________________________________________________________________________________________________

- (void)layoutSubviews
{
    [super  layoutSubviews];
    [self   layout];
}
//__________________________________________________________________________________________________

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    //  CGFloat row = indexPath.row;
    return self.rowHeight;
}
//__________________________________________________________________________________________________

- (void)tableView:(UITableView*)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    
    GlobalParameters* parameters          = GetGlobalParameters();
    header.textLabel.textAlignment        = NSTextAlignmentLeft;
    header.textLabel.textColor            = parameters.friendsListHeaderTextColor;
    header.textLabel.font                 = [UIFont fontWithName:@"AvenirNext-Demibold" size:13];
    header.textLabel.centerY              = header.height / 2;
    header.textLabel.left                 = parameters.friendsListHeaderTextLeftMargin;
    header.backgroundView.backgroundColor = parameters.friendsListHeaderBackgroundColor;
    
}
//__________________________________________________________________________________________________

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(AllFriendsList == contactsNotUsers)
    {
        return [arrayOfSectionTitles objectAtIndex:section];
        
    }
    else
    {
        if (ShowSectionHeaders)
        {
            GlobalParameters* parameters  = GetGlobalParameters();
            switch (section)
            {
                case 0:
                    return parameters.friendsListRecentSectionHeaderTitle;
                case 1:
                    return parameters.friendsListAllSectionHeaderTitle;
                
                default:
                    break;
            }
        }
    }
    return nil;
}
//__________________________________________________________________________________________________

- (void)DidSelectRow:(NSIndexPath*)indexPath;
{ // Do nothing!
}
//__________________________________________________________________________________________________

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(AllFriendsList == contactsNotUsers)
        {
            return [arrayOfSectionTitles count];
        }
    else
        {
        return 2;
        }
}
//__________________________________________________________________________________________________

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(AllFriendsList == contactsNotUsers)
        {
            if (section == 0)
            {
                if(RecentFriendsList.count < 6)
                {
                    return [RecentFriendsList count];
                }
                else
                {
                    return 5;
                }
            }
            else
            {
            return [[arrayOfPeopleInSection objectAtIndex:section] count];
            }
        
        }
    else
        {
    
        switch (section)
            {
                    case 0:
                        //          NSLog(@"%p, numberOfRowsInSection 0: %d", self, (int)RecentFriendsList.count);
                    return RecentFriendsList.count;
                    case 1:
            //    NSLog(@"%p, numberOfRowsInSection 1: %d", self, (int)AllFriendsList.count);
                        return AllFriendsList.count;
                    default:
                        break;
            }
            return 0;
          }
}
//__________________________________________________________________________________________________

- (CGPoint)calculatePoint:(CGPoint)point fromIndexPath:(NSIndexPath*)indexPath
{
    CGRect rect = [self rectForRowAtIndexPath:indexPath];
    //  NSLog(@"point: %f, rect: %f, (%f)", point.y, rect.origin.y, point.y + rect.origin.y + self.top);
    point.y += rect.origin.y + self.top;
    return [self convertPoint:point fromView:self];
}
//__________________________________________________________________________________________________

- (void)updateCellSelection:(TableViewCell*)cell
{
    NSIndexPath* indexPath = [self indexPathForCell:cell];
   
    GlobalParameters* parameters = GetGlobalParameters();
    if ((SelectedItem != nil) && (![SelectedItem isEqual:indexPath]))
    {
        TableViewCell*            oldCell   = (TableViewCell*)[self cellForRowAtIndexPath:SelectedItem];
        PopLabel*                 fullName  = [oldCell getCellItemAtIndex:0];
        FriendListItemStateView*  stateView = [oldCell getCellItemAtIndex:1];
        fullName.font                       = parameters.friendsUsernameFont;
        [stateView animateToState:E_FriendProgressState_Unselected completion:^
         {
         }];
    }
    SelectedItem        = indexPath;
    PopLabel* fullName  = [cell getCellItemAtIndex:0];
    fullName.font       = parameters.friendsUsernameMediumFont;
    fullName.textColor = parameters.friendsSelectedUsernameTextColor;
}
//__________________________________________________________________________________________________

- (void)BuildCellContent:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    PseudoButtonView* pseudoButton      = UseDotsVsState? [ThreeDotsPseudoButtonView new]: [FriendListItemStateView  new];
    PopLabel*         fullName          = [PopLabel new];
    UIView*           topSeparatorLine  = [UIView   new];
    UIView*           botSeparatorLine  = [UIView   new];
    [cell addCellItem:fullName];
    [cell addCellItem:pseudoButton];
    [cell addCellItem:topSeparatorLine];
    [cell addCellItem:botSeparatorLine];
    pseudoButton->UseBlankState       = UseBlankState;
    GlobalParameters* parameters      = GetGlobalParameters();
    fullName.font                     = parameters.friendsUsernameFont;
    fullName.textColor                = parameters.friendsUsernameTextColor;
    fullName.textAlignment            = NSTextAlignmentCenter;
    topSeparatorLine.backgroundColor  = (ShowSectionHeaders || (indexPath.row > 0))? Transparent: parameters.friendsListSeparatorColor;
    botSeparatorLine.backgroundColor  = (ShowSectionHeaders && (indexPath.section == 0) && ([self tableView:self numberOfRowsInSection:indexPath.section] == indexPath.row + 1))? Transparent: parameters.friendsListSeparatorColor;
    
    PseudoButtonView* myPseudoButton  = pseudoButton;
    TableViewCell*    mycell          = cell;
    
    pseudoButton->AnimationDone = ^
    {
        Completed = YES;
        NSInteger index = [self getIndex:cell.tableSection and:cell.tableRow];
        //    NSLog(@"stateView->ProgressDone: %d, %d, %d", (int)mycell.tableSection, (int)mycell.tableRow, (int)index);
        ProgressCompleted([self calculatePoint:myPseudoButton.center fromIndexPath:indexPath], index);
    };
    cell->MainContentViewTapped = ^
    {
        if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
        {
            Completed = NO;
            if (!TouchActive)
            {//NSLog(@"I touched a button, and i liked it3");
                if (!StateViewHidden)
                {
                    if (SimulateButton)
                    {
                        [pseudoButton animateToState:E_FriendProgressState_InProgress completion:^
                         {
                         }];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                       {
                                           [pseudoButton animateToState:E_FriendProgressState_Unselected completion:^
                                            {
                                            }];
                                       });
                    }
                    else
                    {
                                   NSLog(@"Tappable Sound");
                        [self updateCellSelection:mycell];
                        [pseudoButton animateToState:E_FriendProgressState_Selected completion:^
                         {
                         }];
                    }
                   
                     NSInteger index = [self getIndex:mycell.tableSection and:mycell.tableRow];
                    TouchTapped(index);
                }
            }
        }
    };
    cell->MainContentViewPanTouchAction = ^
    {
        if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
        {
            Completed = NO;
            TouchActive = YES;
                  //NSLog(@"MainContentViewPanTouchAction");
            [pseudoButton animateToState:E_FriendProgressState_InProgress completion:^
             {

             }];
            if (!SimulateButton)
            {

                [self updateCellSelection:mycell];
            }
                       NSInteger index = [self getIndex:mycell.tableSection and:mycell.tableRow];
            TouchStarted([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
        }
    };
    cell->MainContentViewPanStartAction = ^(CGFloat offset)
    {
        if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
        {
            //      Completed = NO; // Commented as it would lead to not stop playback in activity list or not sending message in send list.
        }
        //    NSLog(@"MainContentViewPanStartAction");
    };
    cell->MainContentViewPanningAction = ^(CGFloat offset)
    {
        //    NSLog(@"MainContentViewPanningAction");
    };
    cell->MainContentViewPanEndAction = ^(CGFloat offset)
    {
        if (!UseBlankState || (pseudoButton.state != E_FriendProgressState_Blank))
        {
            TouchActive = NO;
            if (SimulateButton)
            {
                if (!StateViewHidden)
                {
                    [pseudoButton animateToState:E_FriendProgressState_Unselected completion:^
                     {
                     }];
                    NSInteger index = [self getIndex:mycell.tableSection and:mycell.tableRow];
                    TouchEnded([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
                }
            }
            else
            {
                //        NSLog(@"MainContentViewPanEndAction");
                if (Completed)
                {
                    NSLog(@"MainContentViewPanEndAction after progress completion");
                    NSInteger index = [self getIndex:mycell.tableSection and:mycell.tableRow];
                    TouchEnded([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
                }
                else
                {
                    NSLog(@"MainContentViewPanEndAction before progress completion");
                    [pseudoButton cancelAnimation];
                    NSInteger index = [self getIndex:mycell.tableSection and:mycell.tableRow];
                    ProgressCancelled([self calculatePoint:pseudoButton.center fromIndexPath:indexPath], index);
                }
                [pseudoButton animateToState:E_FriendProgressState_Selected completion:^
                 {
                 }];
            }
        }
    };
}
//__________________________________________________________________________________________________

- (void)InitCell:(TableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{

        if(AllFriendsList == contactsNotUsers)
        {
            FriendRecord* record;
            if (cell.tableSection == 0)
            {
                if(RecentFriendsList.count > 0)
                {
                record = [RecentFriendsList objectAtIndex:cell.tableRow];
                }
                //NSLog(@"Recent%@", RecentFriendsList);
                //NSLog(@"record%@", record.fullName);
            }
            else
            {
                record =[[arrayOfPeopleInSection objectAtIndex:cell.tableSection] objectAtIndex:cell.tableRow];
            }
                PopLabel*                 fullName      = [cell getCellItemAtIndex:0];
                FriendListItemStateView*  pseudoButton  = [cell getCellItemAtIndex:1];
                pseudoButton.hidden                     = StateViewHidden;
                if (record.fullName == nil)
                {
                    record.fullName = @"<unassigned 3>";
                }
                fullName.text       = record.fullName;
                BOOL isSelectedItem = ((SelectedItem != nil) && [SelectedItem isEqual:indexPath]);
                if ((!IgnoreUnreadMessages && (record.numUnreadMessages > 0)) || (IgnoreUnreadMessages && isSelectedItem))
                {
                    [pseudoButton setState:E_FriendProgressState_Selected animated:NO];
                    fullName.font = GetGlobalParameters().friendsUsernameMediumFont;
                }
                else
                {
                    [pseudoButton setState:E_FriendProgressState_Unselected animated:NO];
                    fullName.font = GetGlobalParameters().friendsUsernameFont;
                }
            
        }
        else
        {
            //  NSLog(@"%p InitCell atIndexPath: [%d, %d], %d, %d", self, (int)indexPath.section, (int)indexPath.row, (int)RecentFriendsList.count, (int)AllFriendsList.count);
            FriendRecord*             record        = [((cell.tableSection == 0)? RecentFriendsList: AllFriendsList) objectAtIndex:cell.tableRow];
            PopLabel*                 fullName      = [cell getCellItemAtIndex:0];
            FriendListItemStateView*  pseudoButton  = [cell getCellItemAtIndex:1];
            pseudoButton.hidden                     = StateViewHidden;
            if (record.fullName == nil)
            {
                record.fullName = @"<unassigned 3>";
            }
            fullName.text       = record.fullName;
            BOOL isSelectedItem = ((SelectedItem != nil) && [SelectedItem isEqual:indexPath]);
            if ((!IgnoreUnreadMessages && (record.numUnreadMessages > 0)) || (IgnoreUnreadMessages && isSelectedItem))
            {
                [pseudoButton setState:E_FriendProgressState_Selected animated:NO];
                fullName.font = GetGlobalParameters().friendsUsernameMediumFont;
            }
            else
            {
                [pseudoButton setState:E_FriendProgressState_Unselected animated:NO];
                fullName.font = GetGlobalParameters().friendsUsernameFont;
            }
         }
    
}
//__________________________________________________________________________________________________

- (void)LayoutCell:(TableViewCell*)cell;
{
    PopLabel*                 fullName          = [cell getCellItemAtIndex:0];
    FriendListItemStateView*  pseudoButton      = [cell getCellItemAtIndex:1];
    UIView*                   topSeparatorLine  = [cell getCellItemAtIndex:2];
    UIView*                   botSeparatorLine  = [cell getCellItemAtIndex:3];
    GlobalParameters*         parameters        = GetGlobalParameters();
    //  BOOL isSelected         = (SelectedItem != nil) && (SelectedItem.section == cell.tableSection) && (SelectedItem.row == cell.tableRow);
    pseudoButton.size       = [pseudoButton sizeThatFits:self.size];
    fullName.width          = [fullName sizeThatFits:self.size].width;
    fullName.height         = fullName.font.lineHeight;
    fullName.bottom         = cell.height / 2;
    topSeparatorLine.width  = cell.width - 2 * parameters.friendsListSeparatorBorderMargin;
    topSeparatorLine.height = parameters.friendsListSeparatorHeight;
    topSeparatorLine.top    = 0;
    topSeparatorLine.left   = 0;
    botSeparatorLine.width  = cell.width - 2 * parameters.friendsListSeparatorBorderMargin;
    botSeparatorLine.height = parameters.friendsListSeparatorHeight;
    botSeparatorLine.bottom = cell.height;
    botSeparatorLine.left   = 0;
    pseudoButton.centerY       = cell.height / 2;
    if (StateViewOnRight)
    {
        pseudoButton.right = cell.width - parameters.friendsStateViewRightMargin;
    }
    else
    {
        pseudoButton.left = parameters.friendsStateViewLeftMargin;
    }
    [topSeparatorLine centerHorizontally];
    [botSeparatorLine centerHorizontally];
    [fullName centerHorizontally];
    [fullName centerVertically];
    
    if (SimulateButton)
    {
        cell.touchRectangle = pseudoButton.frame;
    }
}
//__________________________________________________________________________________________________
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    NSArray* IndexTitles = @[@"Recent",@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    if (AllFriendsList == contactsNotUsers)
        {
            

            return IndexTitles;
        }
    return nil;
}
//__________________________________________________________________________________________________
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSLog(@"index, %lu", index);
    return [arrayOfSectionTitles indexOfObject:title];
}
//__________________________________________________________________________________________________
- (NSArray *)indexLettersForStrings:(NSArray *)records {
    NSMutableArray *letters = [NSMutableArray array];
    [letters addObject:@"Recent"];
    NSString *currentLetter = nil;
    for (FriendRecord* record in records) {
        if (record.fullName.length > 0) {
            NSString *letter = [record.fullName substringToIndex:1];
            if (![letter isEqualToString:currentLetter]) {
                [letters addObject:letter];
                currentLetter = letter;
            }
        }
    }
    arrayOfSectionTitles = (NSMutableArray*)[NSArray arrayWithArray:letters];
    [self getArrayofPeopleinSection:arrayOfSectionTitles];
    return [NSArray arrayWithArray:letters];
}
//__________________________________________________________________________________________________
-(void)getArrayofPeopleinSection:(NSArray *)sections
{
    arrayOfPeopleInSection = [[NSMutableArray alloc]init];
    for (NSString *letter in sections)
        {
        NSMutableArray *sectionPeople = [[NSMutableArray alloc]init];
        for (FriendRecord *record in AllFriendsList)
            {
                
                if([letter isEqualToString: [record.fullName substringToIndex:1]])
                {
                    [sectionPeople addObject:record];
                }
                
            }
            [arrayOfPeopleInSection addObject:sectionPeople];
        }
   // NSLog(@"Array of People: %@", arrayOfPeopleInSection);
}
//__________________________________________________________________________________________________

- (void)setRecentFriends:(NSArray *)recentFriends
{
    RecentFriendsList = recentFriends;
    [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSArray*)recentFriends
{
    return RecentFriendsList;
}
//__________________________________________________________________________________________________

- (void)setAllFriends:(NSArray *)allFriends
{
    if (allFriends == nil)
    {
        AllFriendsList = [NSArray array];
    }
    else
    {
        AllFriendsList = allFriends;
        [self indexLettersForStrings:AllFriendsList];
    }
    [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSArray*)allFriends
{
    return AllFriendsList;
}
//__________________________________________________________________________________________________

- (void)setMaxNumRecentFriends:(NSInteger)maxNumRecentFriends
{
    MaxRecentFriends = maxNumRecentFriends;
       [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (NSInteger)maxNumRecentFriends
{
    return MaxRecentFriends;
}
//__________________________________________________________________________________________________

- (void)clearSelection
{
    SelectedItem = nil;
    [self ReloadTableData];
}
//__________________________________________________________________________________________________

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!ParseRefreshActive && (scrollView.contentOffset.y < GetGlobalParameters().friendsListParseRefreshThresholdOffset))
    {
        ParseRefreshActive = YES;
        RefreshRequest();
    }
    //  NSLog(@"scrollViewDidScroll: %6.2f, %6.2f", scrollView.contentOffset.x, scrollView.contentOffset.y);
}
//__________________________________________________________________________________________________

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    ParseRefreshActive = NO;
}
//__________________________________________________________________________________________________
-(NSInteger) getIndex:(NSInteger)tableSection and:(NSInteger)tableRow
{
    
    NSInteger indexCounter = 0;
    for ( int i = 0; i < tableSection; i++)
    {
        
        
        indexCounter = indexCounter + [[arrayOfPeopleInSection objectAtIndex:i] count];
        NSLog(@"people count %lu", indexCounter);
        
    }
    NSLog(@"%lu", indexCounter);
    NSInteger index = 0;
    if (tableSection == 0 )
    {
        index = tableRow;
    }
    else
    {
        index = indexCounter + tableRow + [RecentFriendsList count];
    }
    
    return index;
}

@end
