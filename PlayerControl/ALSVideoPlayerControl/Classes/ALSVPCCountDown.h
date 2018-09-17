//
//  ATCountDown.h
//  Alisports
//
//  Created by 钱烨 on 3/30/15.
//  Copyright (c) 2015 Altair. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ALSVPCCountDown : NSObject

@property (nonatomic, assign) NSTimeInterval leftTime;

- (instancetype)initWithLeftTimeInterval:(NSTimeInterval)timeLeft;

- (void)startCountDownWithCurrentTimeLeft:(void(^)(NSTimeInterval currentTimeLeft))currentBlock;

- (void)startCountDownWithCurrentTimeLeft:(void(^)(NSTimeInterval currentTimeLeft))currentBlock completion:(void(^)(void))completion;

- (void)stopCountDown;

@end
