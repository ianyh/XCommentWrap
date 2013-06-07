//
//  NSTask+InputOutputTest.m
//  XCommentWrap
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSTask+InputOutput.h"

#import "Kiwi.h"

SPEC_BEGIN(NSTask_InputOutputTest)

describe(@"NSTask InputOutput Category", ^{
    it(@"should grab stdout from a simple echo command", ^{
        NSString *input = @"foo bar !baz";
        NSString *output = [NSTask outputForLaunchPath:@"/usr/bin/env" arguments:@[ @"echo", @"-n", input ] input:nil];
        EXP_expect(output).to.equal(input);
    });
});

SPEC_END
