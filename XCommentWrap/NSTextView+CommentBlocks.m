//
//  NSTextView+CommentBlocks.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSTextView+CommentBlocks.h"

#import "NSString+Comments.h"

@implementation NSTextView (CommentBlocks)

- (NSString *)selectedCommentBlockWithOptions:(CWCommentBlockOptions)options range:(NSRange *)range selectedLineRange:(NSRange *)selectedLineRange {
    // If there are multiple selections or a single non-zero length selection
    // we can't construct a comment block.
    if (self.selectedRanges.count != 1 || self.selectedRange.length > 0) return nil;

    NSRange lineRange = [self.textStorage.string lineRangeForRange:self.selectedRange];
    if (lineRange.location == NSNotFound) return nil;
//    if (paragraphRange.length < 81) return nil;
    
    NSRange totalRange = lineRange;
    
    NSString *lineString = [self.textStorage.string substringWithRange:lineRange];
    if (!lineString.isComment) return nil;

    NSMutableString *commentBlock = [[NSMutableString alloc] initWithString:lineString];

    if (options & CWCommentBlockOptionBackSearching) {
        NSRange previousLineRange = { .location = lineRange.location - 1, .length = 0 };
        while (previousLineRange.location < self.textStorage.string.length) {
            previousLineRange = [self.textStorage.string lineRangeForRange:previousLineRange];
            if (previousLineRange.location == NSNotFound) break;

            lineString = [self.textStorage.string substringWithRange:previousLineRange];
            if (!lineString.isComment) break;
            
            [commentBlock insertString:lineString atIndex:0];

            totalRange.location = previousLineRange.location;
            totalRange.length += previousLineRange.length;

            previousLineRange.location = previousLineRange.location - 1;
            previousLineRange.length = 0;
        }
    }

    if (options & CWCommentBlockOptionsForwardSearching) {
        NSRange nextLineRange = { .location = lineRange.location + lineRange.length, .length = 0 };
        while (nextLineRange.location < self.textStorage.string.length) {
            nextLineRange = [self.textStorage.string lineRangeForRange:nextLineRange];
            if (nextLineRange.location == NSNotFound) break;
            
            lineString = [self.textStorage.string substringWithRange:nextLineRange];
            if (!lineString.isComment) break;
            
            [commentBlock appendString:lineString];
            
            totalRange.length += nextLineRange.length;
            
            nextLineRange.location = nextLineRange.location + nextLineRange.length;
            nextLineRange.length = 0;
        }
    }

    if (range) *range = totalRange;
    if (selectedLineRange) *selectedLineRange = lineRange;

    return commentBlock;
}

@end
