//
//  BookmarkGroupsTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 14.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkGroupsTableViewController.h"
#import "BookmarkSaveTableViewProtocol.h"

@interface BookmarkGroupsTableViewController()

@property (nonatomic, retain) NSArray *groupsList;

@end

@implementation BookmarkGroupsTableViewController

@synthesize bookmarkParent = _bookmarkParent;
@synthesize groupsList = _groupsList;

- (NSArray *)groupsList
{
    if (!_groupsList) {
        NSMutableArray *tmpList = [[NSMutableArray alloc] init];
        
        for (BookmarkItem *bookmark in self.bookmarkParent.content) {
            if (bookmark.group) {
                [tmpList addObject:bookmark];
            }
        }
        
        _groupsList = [[NSArray arrayWithArray:tmpList] retain];
        [tmpList release];
    }
    
    return _groupsList;
}

- (void)setBookmarkParent:(BookmarkItem *)newParent
{
    [_bookmarkParent release];
    _bookmarkParent = newParent;
    
    self.groupsList = nil;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

#define CONTENT_SETTINGS_WIDTH 330.0f
#define CONTENT_SETTINGS_HEIGHT 352.0f
- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(CONTENT_SETTINGS_WIDTH, CONTENT_SETTINGS_HEIGHT);
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)freeProperties
{
    self.bookmarkParent = nil;
}

- (void)viewDidUnload
{
    [self freeProperties];
    
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowsCount = self.groupsList.count;
    
    // Return the number of rows in the section.
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkGroupCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    BookmarkItem *groupBookmark = [self.groupsList objectAtIndex:indexPath.row];
    cell.textLabel.text = groupBookmark.name;
    cell.accessoryType = groupBookmark.group ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    for (UIViewController *viewController in self.navigationController.viewControllers) {
        if (![viewController isKindOfClass:[BookmarkGroupsTableViewController class]]) {
            [tmpArray addObject:viewController];
            
            if ([viewController conformsToProtocol:@protocol(BookmarkSaveTableViewProtocol)]) {
                BookmarkItem *groupBookmark = [self.groupsList objectAtIndex:indexPath.row];
                id <BookmarkSaveTableViewProtocol> saveTableViewController = (id <BookmarkSaveTableViewProtocol>)viewController;
                
                [saveTableViewController moveBookmarkToGroup:groupBookmark];
            }
        }
    }
    
    [self.navigationController setViewControllers:tmpArray animated:YES];
    
    [tmpArray release];
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *groupBookmark = [self.groupsList objectAtIndex:indexPath.row];
    BookmarkGroupsTableViewController *groupsTable = [[BookmarkGroupsTableViewController alloc] init];
    
    groupsTable.bookmarkParent = groupBookmark;
    groupsTable.title = groupBookmark.name;
    [self.navigationController pushViewController:groupsTable animated:YES];
    
    [groupsTable release];
}

@end
