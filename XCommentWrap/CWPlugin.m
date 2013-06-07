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

static const NSUInteger CWCodeCommentMaxColumn = 80;

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
    [_pluginBundle release];
    [super dealloc];
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
    NSRange totalRange;
    NSRange lineRange;
    NSString *commentBlock = [textView selectedCommentBlockWithOptions:CWCommentBlockOptionBackSearching
                                                                 range:&totalRange
                                                     selectedLineRange:&lineRange];

    if (!commentBlock) return;

    NSString *formatScriptPath = [self.pluginBundle pathForResource:@"format" ofType:@"el"];
    NSString *formattedCommentBlock = [NSTask outputForLaunchPath:@"/usr/bin/env"
                                                        arguments:@[ @"emacs", @"--script", formatScriptPath, @"c++-mode" ]
                                                            input:commentBlock];

    if (lineRange.length > CWCodeCommentMaxColumn + 1) {
        [textView.textStorage replaceCharactersInRange:totalRange withString:formattedCommentBlock];

        NSRange selectedRange = textView.selectedRange;
        selectedRange.location--;
        textView.selectedRange = selectedRange;
    }
}

@end
