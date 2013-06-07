//
//  NSTask+InputOutput.h
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTask (InputOutput)

+ (NSString *)outputForLaunchPath:(NSString *)launchPath
                        arguments:(NSArray *)arguments
                            input:(NSString *)input;

@end
