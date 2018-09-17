//
//  ALSVPCEvent.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/11.
//  Copyright © 2018 Alisports. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ALSVideoPlayerStateReady,
    ALSVideoPlayerStatePlaying,
    ALSVideoPlayerStatePause,
    ALSVideoPlayerStateLoading,
    ALSVideoPlayerStateFinished,
    ALSVideoPlayerStateError,
    ALSVideoPlayerStateExit
}ALSVideoPlayerState;

//////////////////Getters//////////////////////

@protocol ALSVPCPlayerInfo

- (NSTimeInterval)duration;
- (NSTimeInterval)currentTime;
- (CGFloat)volume;
- (CGFloat)brightness;
- (CGFloat)speed;
- (UIView *)renderingView;
- (ALSVideoPlayerState)state;

@end

//////////////////Setters//////////////////////

@protocol ALSVPCPlayAction

- (void)play;
- (void)pause;
- (void)seekTo:(NSTimeInterval)pos;
- (void)preload:(NSTimeInterval)pos;
- (void)stop;

@end

@protocol ALSVPCMediaControl

- (void)setSourcePath:(NSString *)path;
- (void)setSourceUrl:(NSURL *)url;
- (void)setVolume:(CGFloat)volume;
- (void)setBrightness:(CGFloat)brightness;
- (void)setSpeed:(CGFloat)speed;

@end

@protocol ALSVPCUITransform

- (void)setFrame:(CGRect)frame;

@end

@protocol ALSVPCCallback

- (void)setPlayerStateChangeCallback:(void(^)(ALSVideoPlayerState state))callback;
- (void)setPlayerTimeChangeCallback:(void(^)(NSTimeInterval current, NSTimeInterval total))callback;

@end
