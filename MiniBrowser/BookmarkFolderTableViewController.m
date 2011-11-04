//
//  BookmarkFolderTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 14.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkFolderTableViewController.h"

@interface BookmarkFolderTableViewController()

@property (nonatomic, retain) NSArray *treeList;

@end

@implementation BookmarkFolderTableViewController

@synthesize bookmark = _bookmark;
@synthesize bookmarkParent = _bookmarkParent;
@synthesize bookmarksStorage = _bookmarksStorage;
@synthesize saveTableViewController = _saveTableViewController;
@synthesize treeList = _treeList;

- (NSArray *)treeList
{
    if (!_treeList) {
        _treeList = [[self.bookmarksStorage bookmarkFoldersWithoutBranch:self.bookmark] retain];
    }
    
    return _treeList;
}

- (void)setBookmarkParent:(BookmarkItem *)newParent
{
    [_bookmarkParent release];
    _bookmarkParent = newParent;
    [_bookmarkParent retain];
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
    self.bookmark = nil;
    self.bookmarkParent = nil;
    self.bookmarksStorage = nil;
    self.saveTableViewController = nil;
    self.treeList = nil;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self freeProperties];
    [super viewDidUnload];
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
    [self freeProperties];

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
    NSInteger rowsCount = self.treeList.count;
    
    // Return the number of rows in the section.
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkFolderCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    NSDictionary *bookmarkData = [self.treeList objectAtIndex:indexPath.row];
    BookmarkItem *bookmarkFolder = [bookmarkData objectForKey:@"bookmark"];
    NSInteger length = [[bookmarkData objectForKey:@"level"] intValue];
    
    NSString *prefix = @"";
    for (NSInteger i = 0; i < length; ++i) {
        prefix = [prefix stringByAppendingString:@"  "];
    }
    
    cell.textLabel.text = [prefix stringByAppendingString:bookmarkFolder.name];
    
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
    NSDictionary *bookmarkData = [self.treeList objectAtIndex:indexPath.row];
    BookmarkItem *bookmarkFolder = [bookmarkData objectForKey:@"bookmark"];
    [self.saveTableViewController moveBookmarkToFolder:bookmarkFolder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    [self freeProperties];
    [super dealloc];
}

@end
