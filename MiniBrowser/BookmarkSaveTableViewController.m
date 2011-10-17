//
//  BookmarkSaveTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkSaveTableViewController.h"
#import "BookmarkSaveModel.h"
#import "BookmarkGroupsTableViewController.h"

@interface BookmarkSaveTableViewController()

@property (nonatomic, retain) BookmarkSaveModel *bookmarkSaveModel;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *urlField;

@end

@implementation BookmarkSaveTableViewController

@synthesize bookmark = _bookmark;
@synthesize bookmarksStorage = _bookmarksStorage;

@synthesize bookmarkSaveModel = _bookmarkSaveModel;
@synthesize nameField = _nameField;
@synthesize urlField = _urlField;
@synthesize tableViewParent = _tableViewParent;
@synthesize indexPath = _indexPath;

- (BookmarkSaveModel *)bookmarkSaveModel
{
    if (!_bookmarkSaveModel) {
        _bookmarkSaveModel = [[BookmarkSaveModel alloc] init];
    }
    
    return _bookmarkSaveModel;
}

- (BookmarkItem *)bookmark
{
    if (!_bookmark) {
        _bookmark = [[BookmarkItem alloc] initWithName:@"" url:@"" group:NO permanent:NO parentId:nil];
    }
    
    return _bookmark;
}

#define CELL_FIELD_TOP_MARGINE 12.0f
#define CELL_FIELD_HEIGHT 21.0f
#define CELL_FIELD_WIDTH_PERCENT 85.0f

- (CGRect)createRectForTextFieldInCell
{
    CGSize boundsSize = self.view.bounds.size;
    CGFloat fieldWidth = boundsSize.width * CELL_FIELD_WIDTH_PERCENT / 100;
    CGFloat fieldLeftMargine = (boundsSize.width - fieldWidth) / 2;
    
    CGRect rect = CGRectMake(fieldLeftMargine, CELL_FIELD_TOP_MARGINE, fieldWidth, CELL_FIELD_HEIGHT);
    
    return rect;
}

- (UITextField *)nameField
{
    if (!_nameField) {
        _nameField = [[UITextField alloc] initWithFrame:[self createRectForTextFieldInCell]];
        _nameField.adjustsFontSizeToFitWidth = YES;
        _nameField.textColor = [UIColor blackColor];
        _nameField.placeholder = @"Name";
        _nameField.keyboardType = UIKeyboardTypeDefault;
        _nameField.returnKeyType = UIReturnKeyDefault;
        _nameField.autocorrectionType = UITextAutocorrectionTypeDefault;
        _nameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _nameField.textAlignment = UITextAlignmentLeft;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameField.enabled = YES;
        _nameField.text = self.bookmark.name;
        _nameField.delegate = self;
    }
    
    return _nameField;
}

- (UITextField *)urlField
{
    if (!_urlField) {
        _urlField = [[UITextField alloc] initWithFrame:[self createRectForTextFieldInCell]];
        _urlField.adjustsFontSizeToFitWidth = YES;
        _urlField.textColor = [UIColor blackColor];
        _urlField.placeholder = self.bookmark.isGroup ? @"Group" : @"URL";
        _urlField.keyboardType = UIKeyboardTypeURL;
        _urlField.returnKeyType = UIReturnKeyDefault;
        _urlField.autocorrectionType = UITextAutocorrectionTypeNo;
        _urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _urlField.textAlignment = UITextAlignmentLeft;
        _urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _urlField.enabled = !self.bookmark.isGroup;
        _urlField.text = self.bookmark.url;
        _urlField.delegate = self;
    }
    
    return _urlField;
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

- (void)forcePopoverSize {
    CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
    CGSize fakeMomentarySize = CGSizeMake(currentSetSizeForPopover.width - 1.0f, currentSetSizeForPopover.height - 1.0f);
    self.contentSizeForViewInPopover = fakeMomentarySize;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
/*    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(cancelBookmarkSaving:)];
    
    self.navigationItem.leftBarButtonItem = cancelButton;

    [cancelButton release];
*/
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                   style:UIBarButtonItemStyleDone
                                                                  target:self
                                                                  action:@selector(doneBookmarkSaving:)];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    
    [doneButton release];
}

- (void)freeProperties
{
    self.bookmarkSaveModel = nil;
    self.bookmark = nil;
    self.bookmarksStorage = nil;
    
    self.nameField = nil;
    self.urlField = nil;
    
    self.tableViewParent = nil;
    self.indexPath = nil;
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
    
    [self forcePopoverSize];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    CGSize currentSetSizeForPopover = self.contentSizeForViewInPopover;
    self.contentSizeForViewInPopover = currentSetSizeForPopover;
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

/*
- (void)cancelBookmarkSaving:(UIBarButtonItem *)sender
{
    [self.bookmarksStorage deleteBookmark:self.bookmark];
    [self.navigationController popViewControllerAnimated:YES];
}
*/

- (void)doneBookmarkSaving:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Bookmark

- (void)configureTheCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath forBookmark:(BookmarkItem *)bookmark
{
    switch (indexPath.section) {
        case 0: { // Bookmark name and url
            switch (indexPath.row) {
                case 0: { // Bookmark name
                    [cell addSubview:self.nameField];
                    break;
                }
                    
                case 1: { // Bookmark url
                    if (self.bookmark.isGroup) {
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    
                    [cell addSubview:self.urlField];
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        case 1: { // Bookmark group
            switch (indexPath.row) {
                case 0: { // Bookmark group
                    BookmarkItem *bookmarkParent = [self.bookmarksStorage bookmarkById:bookmark.parentId];
                    cell.textLabel.text = bookmarkParent.name;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    
                    break;
                }
                    
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionsCount = self.bookmarkSaveModel.sectionsCount;
    return sectionsCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.bookmarkSaveModel numberOfRowsForSection:section];
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureTheCell:cell atIndexPath:indexPath forBookmark:self.bookmark];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canEdit = !(self.bookmark.group && indexPath.section == 0 && indexPath.row == 1);
    // Return NO if you do not want the specified item to be editable.
    return canEdit;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
    if (indexPath.section == 1 && indexPath.row == 0) { // group cell selected
        BookmarkGroupsTableViewController *groupsTable = [[BookmarkGroupsTableViewController alloc] init];
        
        BookmarkItem *bookmarkParent = [self.bookmarksStorage bookmarkById:self.bookmark.parentId];
        
        groupsTable.bookmark = self.bookmark;
        groupsTable.bookmarkParent = bookmarkParent;
        groupsTable.title = bookmarkParent.name;
        groupsTable.bookmarksStorage = self.bookmarksStorage;
        groupsTable.saveTableViewController = self;
        
        [self.navigationController pushViewController:groupsTable animated:YES];
        
        [groupsTable release];
    }
}

#pragma mark - Text Field view delegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.nameField) {
        self.bookmark.name = textField.text;
    } else if (textField == self.urlField) {
        self.bookmark.url = textField.text;
    }
    
    if (self.indexPath) {
        [self.tableViewParent reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.indexPath]
                                    withRowAnimation:UITableViewRowAnimationRight];
    }
}

#pragma mark - BookmarkSaveTableViewProtocol

- (void)moveBookmarkToGroup:(BookmarkItem *)groupBookmark
{
    [self.bookmarksStorage moveBookmark:self.bookmark toGroup:groupBookmark];
    
    NSIndexPath *groupIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:groupIndexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
}

@end
