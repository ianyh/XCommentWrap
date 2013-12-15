//
//  CWPlugin.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/6/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "CWPlugin.h"

#import "NSTask+InputOutput.h"
#import "NSTextView+CommentBlocks.h"

@interface CWPlugin ()
@property (nonatomic, strong) NSBundle *pluginBundle;

- (instancetype)init DEPRECATED_ATTRIBUTE;

- (void)applicationDidFinishLaunching:(NSNotification *)notification;
- (void)textDidChange:(NSNotification *)notification;
@end

@implementation CWPlugin

#pragma mark Lifecycle

+ (void)pluginDidLoad:(NSBundle *)pluginBundle {
    static CWPlugin *sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[CWPlugin alloc] initWithBundle:pluginBundle];
    });
}

- (instancetype)init { return nil; }

- (instancetype)initWithBundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        self.pluginBundle = bundle;

        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(applicationDidFinishLaunching:)
                                                   name:NSApplicationDidFinishLaunchingNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
   
#pragma mark Notification Handlers

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:NSApplicationDidFinishLaunchingNotification
                                                object:nil];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textDidChange:)
                                               name:NSTextDidChangeNotification
                                             object:nil];
}

- (void)textDidChange:(NSNotification *)notification {
    static NSString *sourceEditorClassName = @"DVTSourceTextView";
    if (![notification.object isKindOfClass:NSClassFromString(sourceEditorClassName)]) return;

    NSTextView *textView = notification.object;

    // If the text view doesn't need reformatting we have no work to do.
    if (!textView.needsCommentReformat) return;

    NSRange totalRange;
    NSString *commentBlock = [textView selectedCommentBlockWithOptions:CWCommentBlockOptionBackSearching
                                                                 range:&totalRange];

    // If there's no comment block to format we have no work to do.
    if (!commentBlock) return;

    // Ottherwise we format it through emacs using c++-mode (which is close to
    // an objc-mode and comes standard).
    NSString *formatScriptPath = [self.pluginBundle pathForResource:@"format" ofType:@"el"];
    NSString *formattedCommentBlock = [NSTask outputForLaunchPath:@"/usr/bin/env"
                                                        arguments:@[ @"emacs", @"--script", formatScriptPath, @"c++-mode" ]
                                                            input:commentBlock];

    // Replace the comment block with the emacs formatted block.
    [textView.textStorage replaceCharactersInRange:totalRange withString:formattedCommentBlock];

    // The formatted comment block includes a breakline at the end. This is
    // necessary for including a new line but still maintaining relative
    // relationship with the rest of the code. But we want our cursor to be at
    // the end of the comment, not on the next line. So we move the cursor
    // back a position.
    NSRange selectedRange = textView.selectedRange;
    selectedRange.location--;
    textView.selectedRange = selectedRange;
}

@end
