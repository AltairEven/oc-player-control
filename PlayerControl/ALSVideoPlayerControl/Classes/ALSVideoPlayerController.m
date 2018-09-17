//
//  ALSVideoPlayerController.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/18.
//  Copyright © 2018 Alisports. All rights reserved.
//

#import "ALSVideoPlayerController.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "ALSVPCCountDown.h"

@interface ALSVideoPlayerController ()

@property (nonatomic, strong) IJKFFMoviePlayerController *player;

@property (nonatomic, copy) void(^ stateCallback)(ALSVideoPlayerState state);

@property (nonatomic, assign) ALSVideoPlayerState currentState;

@property (nonatomic, copy) void(^ timeCallback)(NSTimeInterval current, NSTimeInterval total);

@property (nonatomic, strong) ALSVPCCountDown *timer;

- (void)timerWork:(BOOL)dowork finished:(BOOL)finished;

@end

@implementation ALSVideoPlayerController

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStateDidChanched:) name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinished:) name:IJKMPMoviePlayerPlaybackDidFinishNotification object:nil];
    }
    return self;
}

#pragma mark Private methods

- (void)setCurrentState:(ALSVideoPlayerState)currentState {
    _currentState = currentState;
    if (self.stateCallback) {
        self.stateCallback(currentState);
    }
}

- (void)playerStateDidChanched:(NSNotification *)notify {
    IJKFFMoviePlayerController *controller = notify.object;
    switch (controller.playbackState) {
        case IJKMPMoviePlaybackStatePlaying:
        {
            self.currentState = ALSVideoPlayerStatePlaying;
            [self timerWork:YES finished:NO];
        }
            break;
        case IJKMPMoviePlaybackStatePaused:
        {
            self.currentState = ALSVideoPlayerStatePause;
            [self timerWork:NO finished:NO];
        }
            break;
        case IJKMPMoviePlaybackStateStopped:
        {
            self.currentState = ALSVideoPlayerStateFinished;
            [self timerWork:NO finished:YES];
        }
            break;
        default:
        {
            self.currentState = ALSVideoPlayerStateLoading;
            [self timerWork:NO finished:NO];
        }
            break;
    }
}

- (void)playbackDidFinished:(NSNotification *)notify {
    NSDictionary *userInfo = notify.userInfo;
    switch ([[userInfo objectForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] integerValue]) {
        case IJKMPMovieFinishReasonPlaybackEnded:
        {
            self.currentState = ALSVideoPlayerStateFinished;
            [self timerWork:YES finished:NO];
        }
            break;
        case IJKMPMovieFinishReasonPlaybackError:
        {
            self.currentState = ALSVideoPlayerStateError;
            [self timerWork:NO finished:NO];
        }
            break;
        case IJKMPMovieFinishReasonUserExited:
        {
            self.currentState = ALSVideoPlayerStateExit;
            [self timerWork:NO finished:YES];
        }
            break;
        default:
        {
            self.currentState = ALSVideoPlayerStateFinished;
            [self timerWork:NO finished:NO];
        }
            break;
    }
}

- (void)timerWork:(BOOL)dowork finished:(BOOL)finished {
    if (finished) {
        [self.timer stopCountDown];
        if (self.timeCallback) {
            self.timeCallback(self.player.duration, self.player.duration);
        }
        return;
    }
    if (dowork) {
        if (!self.timer) {
            self.timer = [[ALSVPCCountDown alloc] init];
        }
        [self.timer setLeftTime:self.player.duration - self.player.currentPlaybackTime + 60];
        [self.timer startCountDownWithCurrentTimeLeft:^(NSTimeInterval currentTimeLeft) {
            if (self.timeCallback) {
                self.timeCallback(self.player.currentPlaybackTime, self.player.duration);
            }
        }];
    } else {
        [self.timer stopCountDown];
        if (self.timeCallback) {
            self.timeCallback(self.player.currentPlaybackTime, self.player.duration);
        }
    }
}

#pragma mark ALSVPCPlayerInfo

- (NSTimeInterval)duration {
    return self.player.duration;
}

- (NSTimeInterval)currentTime {
    return self.player.currentPlaybackTime;
}

- (CGFloat)volume {
    return self.player.playbackVolume;
}

- (CGFloat)brightness {
    return 0;
}

- (CGFloat)speed {
    return 1;
}

- (UIView *)renderingView {
    return self.player.view;
}

- (ALSVideoPlayerState)state {
    return _currentState;
}

#pragma mark ALSVPCPlayAction

- (void)play {
    [self.player play];
    [self timerWork:YES finished:NO];
}

- (void)pause {
    [self.player pause];
    self.currentState = ALSVideoPlayerStatePause;
    [self timerWork:NO finished:NO];
}

- (void)seekTo:(NSTimeInterval)pos {
    [self.player setCurrentPlaybackTime:(self.player.duration - pos) ? pos : self.player.duration];
    [self timerWork:NO finished:NO];
}

- (void)preload:(NSTimeInterval)pos {
    
}

- (void)stop {
    [self.player stop];
    self.currentState = ALSVideoPlayerStateFinished;
    [self timerWork:NO finished:YES];
}

#pragma mark ALSVPCMediaControl

- (void)setSourcePath:(NSString *)path {
    
}

- (void)setSourceUrl:(NSURL *)url {
    if (self.player) {
        [self.player stop];
        [self.player.view removeFromSuperview];
        self.player = nil;
    }
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    [options setOptionIntValue:1 forKey:@"enable-accurate-seek" ofCategory:kIJKFFOptionCategoryPlayer];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    [self.player prepareToPlay];
    self.currentState = ALSVideoPlayerStateReady;
}

- (void)setVolume:(CGFloat)volume {
    [self.player setPlaybackVolume:volume];
}

- (void)setBrightness:(CGFloat)brightness {
    
}

- (void)setSpeed:(CGFloat)speed {
    
}

#pragma mark ALSVPCUITransform

- (void)enterFullscreen:(UIInterfaceOrientation)orientation {
    
}

- (void)exitFullscreen {
    
}

- (void)setFrame:(CGRect)frame {
    self.player.view.frame = frame;
}

#pragma mark ALSVPCCallback

- (void)setPlayerStateChangeCallback:(void (^)(ALSVideoPlayerState))callback {
    _stateCallback = callback;
}

- (void)setPlayerTimeChangeCallback:(void (^)(NSTimeInterval, NSTimeInterval))callback {
    _timeCallback = callback;
}

@end
