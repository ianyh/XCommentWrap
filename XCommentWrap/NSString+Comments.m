//
//  NSString+Comments.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSString+Comments.h"

@implementation NSString (Comments)

- (BOOL)isComment {
    static NSRegularExpression *commentPrefixExpression;

    if (!commentPrefixExpression) {
        static NSString *commentPrefixPattern = @"^\\s*(//|/\\*|\\*)\\s*";
        commentPrefixExpression = [[NSRegularExpression regularExpressionWithPattern:commentPrefixPattern options:0 error:NULL] retain];
    }
    
    return ([commentPrefixExpression numberOfMatchesInString:self options:0 range:NSMakeRange(0, self.length)] > 0);
}

@end
