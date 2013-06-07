//
//  NSTask+InputOutput.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSTask+InputOutput.h"

@implementation NSTask (InputOutput)

+ (NSString *)outputForLaunchPath:(NSString *)launchPath
                        arguments:(NSArray *)arguments
                            input:(NSString *)input {
    NSTask *task = [[NSTask alloc] init];
    NSPipe *inputPipe = [NSPipe pipe];
    NSPipe *outputPipe = [NSPipe pipe];

    task.launchPath = launchPath;
    task.arguments = arguments;
    task.standardInput = inputPipe;
    task.standardOutput = outputPipe;

    NSFileHandle *writeHandle = inputPipe.fileHandleForWriting;
    [writeHandle writeData:[input dataUsingEncoding:NSASCIIStringEncoding]];
    [writeHandle closeFile];

    [task launch];

    NSFileHandle *readHandle = outputPipe.fileHandleForReading;
    NSData *data = [readHandle readDataToEndOfFile];
    [readHandle closeFile];

    NSString *formattedString = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];

    [task release];

    return [formattedString autorelease];
}

@end
