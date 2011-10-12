//
//  BookmarksTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "BookmarksStorageProtocol.h"
#import "BookmarksStorage.h"

@interface BookmarksTableViewController()

@property (nonatomic, retain) id <BookmarksStorageProtocol> bookmarksStorage;
@property (nonatomic, retain) BookmarkItem *currentBookmarkGroup;

@end

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

- (id)bookmarksStorage
{
    if (!_bookmarksStorage) {
        _bookmarksStorage = [[BookmarksStorage alloc] init];
    }
    
    return _bookmarksStorage;
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.currentBookmarkGroup.name;
    
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

#define POPOVER_WIDTH 400
#define POPOVER_HEIGHT 500
- (CGSize)contentSizeForViewInPopover
{
    return CGSizeMake(POPOVER_WIDTH, POPOVER_HEIGHT);
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
    cell.accessoryType = currentBookmark.group ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    
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
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentBookmarkGroup];

    if (currentBookmark.group) {
        BookmarksTableViewController *newBookmarksTVC = [[BookmarksTableViewController alloc] init];
        
        newBookmarksTVC.delegateController = self.delegateController;
        newBookmarksTVC.currentBookmarkGroup = currentBookmark;
        [self.navigationController pushViewController:newBookmarksTVC animated:YES];
        
        [newBookmarksTVC release];
    } else {
        [self.delegateController closePopupsAndLoadUrl:currentBookmark.url];
    }
}

@end
