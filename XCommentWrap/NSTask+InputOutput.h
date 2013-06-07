//
//  NSTask+InputOutput.h
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (InputOutput)

// Method for easily getting stdout of a task.
//
// launchPath - The exectubable to run. Must not be nil.
// arguments  - The arguments to pass to the executable. Can be nil.
// input      - String input to provide as stdin for the task. Can be nil.
+ (NSString *)outputForLaunchPath:(NSString *)launchPath
                        arguments:(NSArray *)arguments
                            input:(NSString *)input;

@end
