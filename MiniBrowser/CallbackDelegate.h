//
//  CallbackDelegate.h
//  MiniBrowser
//
//  Created by Антон Помозов on 25.02.12.
//  Copyright (c) 2012 Alma. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CallbackDelegate <NSObject>

- (NSString *)urlCallBack:(NSString *)sourceUrl navigationType:(UIWebViewNavigationType)navigationType;

@end
