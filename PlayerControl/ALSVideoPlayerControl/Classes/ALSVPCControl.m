//
//  ALSVideoPlayer.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/11.
//  Copyright © 2018 Alisports. All rights reserved.
//

#import "ALSVPCControl.h"
#import "ALSVideoPlayerController.h"

@interface ALSVPCControl ()

@property (nonatomic, strong) ALSVideoPlayerController *controller;

@end

@implementation ALSVPCControl

- (instancetype)init {
    self = [super init];
    if (self) {
        self.controller = [[ALSVideoPlayerController alloc] init];
    }
    return self;
}

- (id)control:(Protocol *)control {
    return self.controller;
}

@end
