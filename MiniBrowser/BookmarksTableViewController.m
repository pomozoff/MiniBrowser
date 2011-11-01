//
//  BookmarksTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "BookmarkSaveTableViewController.h"

@interface BookmarksTableViewController()

@property (nonatomic, retain) UIBarButtonItem *clearHistoryButton;
@property (nonatomic) NSInteger lastNumberOfRows;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;

@end

@implementation BookmarksTableViewController

@synthesize clearHistoryButton = _clearHistoryButton;
@synthesize lastNumberOfRows = _lastNumberOfRows;
@synthesize dateFormatter = _dateFormatter;

@synthesize delegateController = _delegateController;
@synthesize bookmarksStorage = _bookmarksStorage;
@synthesize currentFolder = _currentFolder;

- (UIBarButtonItem *)clearHistoryButton
{
    if (!_clearHistoryButton) {
        _clearHistoryButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear History"
                                                               style:UIBarButtonItemStylePlain
                                                              target:self
                                                              action:@selector(clearHistoryFolderPressed:)];
    }
    
    return _clearHistoryButton;
}

- (BookmarkItem *)currentFolder
{
    if (!_currentFolder) {
        _currentFolder = [self.bookmarksStorage.rootFolder retain];
        _currentFolder.delegateController = self;
    }
    
    return _currentFolder;
}

- (NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"HH:mm";
        _dateFormatter.timeZone = [NSTimeZone localTimeZone];
    }
    return _dateFormatter;
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
    
    BOOL isHistoryFolder = [self.currentFolder isEqualToBookmark:self.bookmarksStorage.historyFolder];

    self.title = self.currentFolder.name;
    self.navigationItem.rightBarButtonItem = isHistoryFolder ? self.clearHistoryButton : self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    if (!self.delegateController.isIPad) {
        UIBarButtonItem *closeBookmarksButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                                 style:UIBarButtonItemStyleDone
                                                                                target:self
                                                                                action:@selector(closeBookmarksPressed:)];
        
        self.toolbarItems = [NSArray arrayWithObject:closeBookmarksButton];
        [closeBookmarksButton release];
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)freeProperties
{
    self.bookmarksStorage = nil;
    self.currentFolder = nil;
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

    if ( [self.currentFolder isEqualToBookmark:self.bookmarksStorage.historyFolder] )
    {
        [self.bookmarksStorage arrangeHistoryContentByDate];
        [self.tableView reloadData];
    }
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
        UIBarButtonItem *newFolderButton = [[UIBarButtonItem alloc] initWithTitle:@"New Folder"
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(newFolderPressed:)];
        
        self.navigationItem.leftBarButtonItem = newFolderButton;
        [newFolderButton release];
    } else {
        self.navigationItem.leftBarButtonItem = nil;
    }
}

- (void)closeBookmarksPressed:(UIBarButtonItem *)sender
{
    
}

- (void)newFolderPressed:(UIBarButtonItem *)sender
{
    BookmarkSaveTableViewController *bookmarkSaveTVC = [[BookmarkSaveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    
    BookmarkItem *newFolder = [[BookmarkItem alloc] initWithName:@""
                                                             url:nil
                                                            date:[NSDate date]
                                                          folder:YES
                                                       permanent:NO];
    
    bookmarkSaveTVC.title = @"Edit Folder";
    bookmarkSaveTVC.bookmark = newFolder;
    bookmarkSaveTVC.bookmarksStorage = self.bookmarksStorage;
    bookmarkSaveTVC.tableViewParent = self.tableView;
    bookmarkSaveTVC.currentFolder = self.currentFolder;
    
    newFolder.delegateController = self;
    
    [newFolder release];
    
    [self.navigationController pushViewController:bookmarkSaveTVC animated:YES];
    
    [bookmarkSaveTVC release];
}

- (void)clearHistoryFolderPressed:(UIBarButtonItem *)sender
{
    [self.bookmarksStorage clearFolder:self.bookmarksStorage.historyFolder];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionsCount = self.bookmarksStorage.sectionsCount;
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.bookmarksStorage bookmarksCountForParent:self.currentFolder];
/*
    if ( [self.currentFolder isEqualToBookmark:self.bookmarksStorage.historyFolder] && (self.lastNumberOfRows != numberOfRows) )
    {
        [self.bookmarksStorage arrangeHistoryContentByDate];
        [self.tableView reloadData];
        self.lastNumberOfRows = numberOfRows;
    }
*/    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkStorageCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
    NSString *bookmarkTime = [self.dateFormatter stringFromDate:currentBookmark.date];
    BookmarkItem *currentFolderParent = [self.bookmarksStorage bookmarkById:self.currentFolder.parentId];
    BOOL isInHistoryFolder = (self.currentFolder == self.bookmarksStorage.historyFolder) || (currentFolderParent == self.bookmarksStorage.historyFolder);

    cell.textLabel.text = currentBookmark.name;
    cell.detailTextLabel.text = (!currentBookmark.isFolder && isInHistoryFolder) ? [NSString stringWithFormat:@"%@ at %@", currentBookmark.url, bookmarkTime] : @"";
    cell.detailTextLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    cell.accessoryType = currentBookmark.isFolder ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.editingAccessoryType = currentBookmark.isPermanent ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;

    UITableViewCellSelectionStyle selectionStyle = currentBookmark == self.bookmarksStorage.historyFolder ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleBlue;
    cell.selectionStyle = selectionStyle;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
    BOOL mayEdit = currentBookmark == self.bookmarksStorage.historyFolder ? NO : YES;
    
    return mayEdit;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
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
    [self.bookmarksStorage moveBookmarkAtPosition:fromIndexPath toPosition:toIndexPath insideFolder:self.currentFolder];
}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
    BOOL canOrder = !bookmark.isPermanent;
    return canOrder;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)source
       toProposedIndexPath:(NSIndexPath *)destination {
    BookmarkItem *targetBookmark = [self.bookmarksStorage bookmarkAtIndex:destination forParent:self.currentFolder];
    NSIndexPath *result = targetBookmark.isPermanent ? source : destination;
    
    return result;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *bookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
    UITableViewCellEditingStyle style = bookmark.isPermanent ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
    
    return style;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BookmarkItem *currentBookmark = [self.bookmarksStorage bookmarkAtIndex:indexPath forParent:self.currentFolder];
    currentBookmark.delegateController = self;
    
    if (self.tableView.editing) {
        if (currentBookmark == self.bookmarksStorage.historyFolder) {
            return;
        }
        
        BookmarkSaveTableViewController *bookmarkSaveTVC = [[BookmarkSaveTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
        
        bookmarkSaveTVC.title = @"Edit Bookmark";
        bookmarkSaveTVC.bookmark = currentBookmark;
        bookmarkSaveTVC.bookmarksStorage = self.bookmarksStorage;
        bookmarkSaveTVC.tableViewParent = self.tableView;
        bookmarkSaveTVC.currentFolder = self.currentFolder;
        bookmarkSaveTVC.currentFolder.delegateController = self;
        
        [self.navigationController pushViewController:bookmarkSaveTVC animated:YES];
        
        [bookmarkSaveTVC release];
    } else {
        if (currentBookmark.isFolder) {
            BookmarksTableViewController *newBookmarksTVC = [[BookmarksTableViewController alloc] init];
            
            newBookmarksTVC.delegateController = self.delegateController;
            newBookmarksTVC.bookmarksStorage = self.bookmarksStorage;
            newBookmarksTVC.currentFolder = currentBookmark;
            
            [self.navigationController pushViewController:newBookmarksTVC animated:YES];
            
            [newBookmarksTVC release];
        } else {
            [self.delegateController closePopupsAndLoadUrl:currentBookmark.url];
        }
    }
}

#pragma mark - Bookmark Item delegate

- (void)reloadBookmarksInFolder:(BookmarkItem *)bookmarkFolder
{
    if (bookmarkFolder && [self.currentFolder isEqualToBookmark:bookmarkFolder]) {
        [self.tableView reloadData];
    }
}

@end
