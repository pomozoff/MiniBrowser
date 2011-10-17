//
//  BookmarkSaveModel.m
//  MiniBrowser
//
//  Created by Антон Помозов on 11.10.11.
//  Copyright 2011 Alma. All rights reserved.
//

#import "BookmarkSaveModel.h"

@interface BookmarkSaveModel()

@property (nonatomic, retain) NSArray *sections;

@end

@implementation BookmarkSaveModel

@synthesize sectionsCount = _sectionsCount;

@synthesize sections = _sections;

NSString *const sectionItemDescription = @"Item description";
NSString *const sectionGroup = @"Group";

- (NSArray *)sections
{
    if (!_sections) {
        NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
        NSString *userDefaultsValuesPath = [mainBundlePath stringByAppendingPathComponent:@"BookmarkSaveTable.plist"];
        NSDictionary *tmpSavePref = [NSDictionary dictionaryWithContentsOfFile:userDefaultsValuesPath];
        _sections = [[tmpSavePref objectForKey:@"Preferences"] retain];
    }
    
    return _sections;
}

- (NSInteger)sectionsCount
{
    NSInteger count = self.sections.count;
    return count;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSInteger)numberOfRowsForSection:(NSInteger)section forBookmark:(BookmarkItem *)bookmark
{
    NSDictionary *currentSection = [self.sections objectAtIndex:section];
    NSArray *titles = [currentSection objectForKey:@"Title"];
    NSInteger numberOfRows = titles.count;
    
    if (section == 0 && bookmark.isGroup) {
        numberOfRows--;
    }
    
    return numberOfRows;
}

- (void)dealloc
{
    self.sections = nil;
    
    [super dealloc];
}

@end
