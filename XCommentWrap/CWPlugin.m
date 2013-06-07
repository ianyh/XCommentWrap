//
//  CWPlugin.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/6/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "CWPlugin.h"

@interface CWPlugin ()
@property (nonatomic, strong) NSBundle *pluginBundle;

@property (nonatomic, strong) NSRegularExpression *singleLinePrefixExpression;
@property (nonatomic, strong) NSRegularExpression *multiLineStartPrefixExpression;
@property (nonatomic, strong) NSRegularExpression *multiLinePrefixExpression;

@property (nonatomic, assign) BOOL wrapping;

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

        _wrapping = NO;

        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(applicationDidFinishLaunching:)
                                                   name:NSApplicationDidFinishLaunchingNotification
                                                 object:nil];
    }
    return self;
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_singleLinePrefixExpression release];
    [_multiLineStartPrefixExpression release];
    [_multiLinePrefixExpression release];
    [super dealloc];
}
   
#pragma mark Notification Handlers

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    [NSNotificationCenter.defaultCenter removeObserver:self
                                                  name:NSApplicationDidFinishLaunchingNotification
                                                object:nil];

    static NSString *simplePrefixPattern = @"^\\s*(//)\\s*";
    static NSString *multiLineStartPattern = @"^\\s*(/\\*)\\s*";
    static NSString *multiLinePattern = @"^(\\s*(\\*)\\s*)";

    self.singleLinePrefixExpression = [NSRegularExpression regularExpressionWithPattern:simplePrefixPattern options:0 error:NULL];
    self.multiLineStartPrefixExpression = [NSRegularExpression regularExpressionWithPattern:multiLineStartPattern options:0 error:NULL];
    self.multiLinePrefixExpression = [NSRegularExpression regularExpressionWithPattern:multiLinePattern options:0 error:NULL];

    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textDidChange:)
                                               name:NSTextDidChangeNotification
                                             object:nil];
}

- (void)textDidChange:(NSNotification *)notification {
    if (self.wrapping) return;

    static NSString *sourceEditorClassName = @"DVTSourceTextView";
    if (![notification.object isKindOfClass:NSClassFromString(sourceEditorClassName)]) return;

    NSTextView *textView = (NSTextView *)notification.object;  

    if (textView.selectedRanges.count != 1) return;

    NSRange selectedRange = [textView.selectedRanges[0] rangeValue];
    NSRange paragraphRange = [textView.textStorage.string paragraphRangeForRange:selectedRange];
    if (paragraphRange.length < 80) return;

    NSRange totalRange = paragraphRange;

    if (paragraphRange.location == NSNotFound) return;

    NSString *paragraphString = [textView.textStorage.string substringWithRange:paragraphRange];
    if (![self commentPrefixWithLineString:paragraphString]) return;
    NSMutableString *commentBlock = [[NSMutableString alloc] initWithString:paragraphString];

    NSRange previousParagraphRange = { .location = paragraphRange.location - 1, .length = 0 };
    while (previousParagraphRange.location < textView.textStorage.string.length) {
        previousParagraphRange = [textView.textStorage.string paragraphRangeForRange:previousParagraphRange];
        if (previousParagraphRange.location == NSNotFound) break;

        paragraphString = [textView.textStorage.string substringWithRange:previousParagraphRange];
        if (![self commentPrefixWithLineString:paragraphString]) break;

        [commentBlock insertString:paragraphString atIndex:0];

        totalRange.location = previousParagraphRange.location;
        totalRange.length += previousParagraphRange.length;

        previousParagraphRange.location = previousParagraphRange.location - 1;
        previousParagraphRange.length = 0;
    }

//    NSRange nextParagraphRange = { .location = paragraphRange.location + paragraphRange.length, .length = 0 };
//    while (nextParagraphRange.location < textView.textStorage.string.length) {
//        nextParagraphRange = [textView.textStorage.string paragraphRangeForRange:nextParagraphRange];
//        if (nextParagraphRange.location == NSNotFound) break;
//
//        paragraphString = [textView.textStorage.string substringWithRange:nextParagraphRange];
//        if (![self commentPrefixWithLineString:paragraphString]) break;
//
//        [commentBlock appendString:paragraphString];
//
//        totalRange.length += nextParagraphRange.length;
//
//        nextParagraphRange.location = nextParagraphRange.location + nextParagraphRange.length;
//        nextParagraphRange.length = 0;
//    }

    NSString *formatScriptPath = [self.pluginBundle pathForResource:@"format" ofType:@"el"];
    NSPipe *inputPipe = [NSPipe pipe];
    NSPipe *outputPipe = [NSPipe pipe];
    NSTask *formatTask = [[NSTask alloc] init];

    formatTask.launchPath = @"/usr/bin/env";
    formatTask.arguments = @[ @"emacs", @"--script", formatScriptPath, @"c++-mode"];
    formatTask.standardInput = inputPipe;
    formatTask.standardOutput = outputPipe;

    NSFileHandle *writeHandle = [inputPipe fileHandleForWriting];
    [writeHandle writeData:[commentBlock dataUsingEncoding:NSASCIIStringEncoding]];
    [writeHandle closeFile];

    [formatTask launch];

    NSFileHandle *readHandle = [outputPipe fileHandleForReading];
    NSData *data = [readHandle readDataToEndOfFile];

    NSString *formattedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    if (paragraphRange.length > 81) {
        [textView.textStorage replaceCharactersInRange:totalRange withString:formattedString];
        NSRange selectedRange = textView.selectedRange;
        selectedRange.location--;
        textView.selectedRange = selectedRange;
    }
}

- (NSString *)commentPrefixWithLineString:(NSString *)lineString {
    NSRange lineStringRange = NSMakeRange(0, lineString.length);
    NSTextCheckingResult *singleLinePrefixMatch = [self.singleLinePrefixExpression firstMatchInString:lineString options:0 range:lineStringRange];
    if (singleLinePrefixMatch) return [lineString substringWithRange:singleLinePrefixMatch.range];
    NSTextCheckingResult *multiLinePrefixMatch = [self.multiLinePrefixExpression firstMatchInString:lineString options:0 range:lineStringRange];
    if (multiLinePrefixMatch) return [lineString substringWithRange:multiLinePrefixMatch.range];

    NSTextCheckingResult *multiLineStartPrefixMatch = [self.multiLineStartPrefixExpression firstMatchInString:lineString options:0 range:lineStringRange];
    if (!multiLineStartPrefixMatch) return nil;

    NSString *prefix = [lineString substringWithRange:multiLineStartPrefixMatch.range];
    prefix = [prefix stringByReplacingOccurrencesOfString:@"/" withString:@" " options:0 range:NSMakeRange(0, prefix.length)];
    return prefix; 
}

@end
