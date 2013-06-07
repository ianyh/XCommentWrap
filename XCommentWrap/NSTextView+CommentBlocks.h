//
//  NSTextView+CommentBlocks.h
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import <Cocoa/Cocoa.h>

// Options for searching for comments in a text view.
typedef NS_OPTIONS(NSInteger, CWCommentBlockOptions) {
    // If this option is provided the comment block includes lines of comments
    // contiguously preceding the selected line.
    CWCommentBlockOptionBackSearching = 1 << 0,
    // If this option is provided the comment block includes lines of comments
    // contiguously following the selected line.
    CWCommentBlockOptionsForwardSearching = 1 << 1,
};

@interface NSTextView (CommentBlocks)

// This method returns the currently selected comment block if it exists.
//
// options - Options to use when constructing the comment block. By default the
//           comment block will always includes the currently selected line of
//           comment.
//
// range - An optional pointer to an NSRange struct that will be filled out with
//         the range of the total text view's text that the comment block
//         contains.
//
// selectedLineRange - An optional pointer to an NSRange struct that will be
//                     filled out with the range of the total text taken up the
//                     selected line.
//
// This method returns nil if no comment block could be constructed. This can
// happen if there is currently a non-zero length selection or if the cursor is
// not currently on a line of comments.
- (NSString *)selectedCommentBlockWithOptions:(CWCommentBlockOptions)options range:(NSRange *)range selectedLineRange:(NSRange *)selectedLineRange;

@end
