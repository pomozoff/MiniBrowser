//
//  BookmarksTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "BookmarkSaveTableViewController.h"

@implementation BookmarksTableViewController

@synthesize delegateController = _delegateController;

@synthesize bookmarksStorage = _bookmarksStorage;
@synthesize currentBookmarkGroup = _currentBookmarkGroup;

- (BookmarkItem *)currentBookmarkGroup
{
    if (!_currentBookmarkGroup) {
        _currentBookmarkGroup = [self.bookmarksStorage rootItem];
    }
    
    return _currentBookmarkGroup;
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

    self.title = self.currentBookmarkGroup.name;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)freeProperties
{
    self.bookmarksStorage = nil;
    self.currentBookmarkGroup = nil;
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        UIBarButtonItem *newFolderButton = [[UIBarButtonItem alloc] initWithTitle:@"New folder button"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(newFolderPressed:)];
        
        self.navigationItem.leftBarButtonItem = newFolderButton;
        [newFolderButton release];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)newFolderPressed:(UIBarButtonItem *)sender
{
    BookmarkSaveTableViewController *bookmarkSaveTVC = [[BookmarkSaveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    BookmarkItem *newFolder = [[BookmarkItem alloc] initWithName:@"" url:nil group:YES permanent:NO parentId:self.currentBookmarkGroup.itemId];
    
    [self.bookmarksStorage addBookmark:newFolder toGroup:self.currentBookmarkGroup];

    NSInteger numberOfRows = [self.bookmarksStorage bookmarksCountForParent:self.currentBookmarkGroup];
    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:(numberOfRows - 1) inSection:0];
    
    bookmarkSaveTVC.title = @"Edit Folder";
    bookmarkSaveTVC.bookmark = newFolder;
    bookmarkSaveTVC.bookmarksStorage = self.bookmarksStorage;
    bookmarkSaveTVC.tableViewParent = self.tableView;
    bookmarkSaveTVC.indexPath = newIndexPath;
    
    newFolder.delegateBookmark = self;
    
    [newFolder release];
    
    NSArray *arrayPaths = [NSArray arrayWithObject:newIndexPath];
    [self.tableView insertRowsAtIndexPaths:arrayPaths withRowAnimation:UITableViewRowAnimationRight];
    
    [self.navigationController pushViewController:bookmarkSaveTVC animated:YES];
    
    [bookmarkSaveTVC release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionsCount = self.bookmarksStorage.sectionsCount;
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.bookmarksStorage bookmarksCountForParent:self.currentBookmarkGroup];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkStorageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];

    cell.textLabel.text = currentBookmark.name;
    cell.detailTextLabel.text = currentBookmark.url;
    cell.accessoryType = currentBookmark.isGroup ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.editingAccessoryType = currentBookmark.isPermanent ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
    
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];
        [self.bookmarksStorage deleteBookmark:bookmark];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    [self.bookmarksStorage moveBookmarkAtPosition:fromIndexPath toPosition:toIndexPath insideGroup:self.currentBookmarkGroup];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];
    BOOL canOrder = !bookmark.isPermanent;
    return canOrder;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)source
       toProposedIndexPath:(NSIndexPath *)destination {
    BookmarkItem *targetBookmark = [self.bookmarksStorage bookmarkAtIndex:destination forParent:self.currentBookmarkGroup];
    NSIndexPath *result = targetBookmark.isPermanent ? source : destination;
    
    return result;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];
    UITableViewCellEditingStyle style = bookmark.isPermanent ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    
    return style;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];
    
    if (self.tableView.editing) {
        BookmarkSaveTableViewController *bookmarkSaveTVC = [[BookmarkSaveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        bookmarkSaveTVC.title = @"Edit Bookmark";
        bookmarkSaveTVC.bookmark = currentBookmark;
        bookmarkSaveTVC.bookmarksStorage = self.bookmarksStorage;
        bookmarkSaveTVC.tableViewParent = self.tableView;
        bookmarkSaveTVC.indexPath = indexPath;
        
        currentBookmark.delegateBookmark = self;
        
        [self.navigationController pushViewController:bookmarkSaveTVC animated:YES];
        
        [bookmarkSaveTVC release];
    } else {
        if (currentBookmark.isGroup) {
            BookmarksTableViewController *newBookmarksTVC = [[BookmarksTableViewController alloc] init];
            
            newBookmarksTVC.delegateController = self.delegateController;
            newBookmarksTVC.bookmarksStorage = self.bookmarksStorage;
            newBookmarksTVC.currentBookmarkGroup = currentBookmark;
            [self.navigationController pushViewController:newBookmarksTVC animated:YES];
            
            [newBookmarksTVC release];
        } else {
            [self.delegateController closePopupsAndLoadUrl:currentBookmark.url];
        }
    }
}

#pragma mark - Bookmark Item delegate

- (void)reloadBookmarksForGroup:(BookmarkItem *)bookmarkGroup
{
    if (bookmarkGroup && [self.currentBookmarkGroup isEqualToBookmark:bookmarkGroup]) {
        [self.tableView reloadData];
    }
}

@end
