//
//  BookmarkSaveTableViewController.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkSaveTableViewController.h"
#import "BookmarkSaveModel.h"
#import "BookmarksStorageProtocol.h"

@interface BookmarkSaveTableViewController()

@property (nonatomic, retain) BookmarkSaveModel *bookmarkSaveModel;
@property (nonatomic, retain) UITextField *nameField;
@property (nonatomic, retain) UITextField *urlField;

@end

@implementation BookmarkSaveTableViewController

@synthesize bookmarkSaveModel = _bookmarkSaveModel;
@synthesize bookmark = _bookmark;
@synthesize nameField = _nameField;
@synthesize urlField = _urlField;

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

- (UITextField *)nameField
{
    if (!_nameField) {
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(60, 12, 225, 21)];
        _nameField.adjustsFontSizeToFitWidth = YES;
        _nameField.textColor = [UIColor blackColor];
        _nameField.backgroundColor = [UIColor greenColor];
        _nameField.placeholder = @"Name";
        _nameField.keyboardType = UIKeyboardTypeDefault;
        _nameField.returnKeyType = UIReturnKeyDefault;
        _nameField.autocorrectionType = UITextAutocorrectionTypeDefault;
        _nameField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
        _nameField.textAlignment = UITextAlignmentLeft;
        _nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _nameField.enabled = YES;
        _nameField.delegate = self;
        _nameField.text = self.bookmark.name;
    }
    
    return _nameField;
}

- (UITextField *)urlField
{
    if (!_urlField) {
        _urlField = [[UITextField alloc] initWithFrame:CGRectMake(60, 12, 225, 21)];
        _urlField.adjustsFontSizeToFitWidth = YES;
        _urlField.textColor = [UIColor blackColor];
        _urlField.placeholder = @"URL";
        _urlField.keyboardType = UIKeyboardTypeURL;
        _urlField.returnKeyType = UIReturnKeyDefault;
        _urlField.autocorrectionType = UITextAutocorrectionTypeNo;
        _urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _urlField.textAlignment = UITextAlignmentLeft;
        _urlField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _urlField.enabled = YES;
        _urlField.delegate = self;
        _urlField.text = self.bookmark.url;
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
#define CONTENT_SETTINGS_HEIGHT 175.0f
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
}

- (void)freeProperties
{
    self.bookmarkSaveModel = nil;
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
                    //cell.textLabel.text = bookmark.parentId;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
