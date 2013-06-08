//
//  NSTextView+CommentBlocks.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSTextView+CommentBlocks.h"

#import "NSString+Comments.h"

NSUInteger CWCommentMaxColumn = 80;

@implementation NSTextView (CommentBlocks)

- (BOOL)needsCommentReformat {
    // If there are multiple selections or a single non-zero length selection
    // we don't bother with formatting.
    if (self.selectedRanges.count != 1 || self.selectedRange.length > 0) return NO;

    // Find the range of the current line.
    NSRange lineRange = [self.textStorage.string lineRangeForRange:self.selectedRange];

    // If there is no such reasonable range then we have nothing to format.
    if (lineRange.location == NSNotFound) return NO;

    // If the line isn't a comment don't bother with formatting.
    NSString *lineString = [self.textStorage.string substringWithRange:lineRange];
    if (!lineString.isComment) return NO;

    // Otherwise we need to format if the line is too long.
    return lineRange.length > CWCommentMaxColumn;
}

- (NSString *)selectedCommentBlockWithOptions:(CWCommentBlockOptions)options range:(NSRange *)range {
    // If there are multiple selections or a single non-zero length selection
    // we can't construct a comment block.
    if (self.selectedRanges.count != 1 || self.selectedRange.length > 0) return nil;

    NSRange lineRange = [self.textStorage.string lineRangeForRange:self.selectedRange];
    if (lineRange.location == NSNotFound) return nil;
    
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

    return [commentBlock autorelease];
}

@end
