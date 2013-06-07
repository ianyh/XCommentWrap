//
//  XCommentWrapTests.m
//  XCommentWrapTests
//
//  Created by Ian Ynda-Hummel on 6/7/13.
//  Copyright (c) 2013 Ian Ynda-Hummel. All rights reserved.
//

#import "NSString+Comments.h"

#import "Expecta.h"
#import "Kiwi.h"

SPEC_BEGIN(CommentStrings)

describe(@"NSString Comments Category", ^{
    it(@"should recognize single line comments", ^{
        EXP_expect(@"//".isComment).to.beTruthy();
        EXP_expect(@"    //".isComment).to.beTruthy();
        EXP_expect(@"//        ".isComment).to.beTruthy();
        EXP_expect(@"   //   ".isComment).to.beTruthy();
    });

    it(@"should recognize multi-line comments", ^{
        EXP_expect(@"/*".isComment).to.beTruthy();
        EXP_expect(@"*".isComment).to.beTruthy();
        EXP_expect(@"*/".isComment).to.beTruthy();
        EXP_expect(@"   /*****        ".isComment).to.beTruthy();
        EXP_expect(@"   *****   ".isComment).to.beTruthy();
        EXP_expect(@"   *****/   ".isComment).to.beTruthy();
    });

    it(@"should not recognize single-line comments at the end of a line", ^{
        EXP_expect(@"NSString *foo //".isComment).notTo.beTruthy();
    });

    it(@"should not recognize multi-line comments starting at the end of a line", ^{
        EXP_expect(@"NSString *foo /*".isComment).notTo.beTruthy();
    });
});

SPEC_END
