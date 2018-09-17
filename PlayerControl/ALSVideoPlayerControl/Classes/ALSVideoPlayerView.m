//
//  ALSVideoPlayerView.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/26.
//

#import "ALSVideoPlayerView.h"
#import "ALSVPCControl.h"
#import "ALSVideoPlayerViewController.h"
#import <objc/runtime.h>
#import "ALSVPCCountDown.h"

@interface ALSVideoPlayerView () <ALSVideoPlayerViewControllerDelegate>

@property (nonatomic, strong) ALSVPCControl *videoPlayerControl;

@property (nonatomic, strong, readonly) ALSVideoPlayerViewController *playerViewController;

@property (nonatomic, assign) CGRect lastFrame;

@property (nonatomic, strong) ALSVPCCountDown *timer;

@property (nonatomic, assign) ALSVideoPlayerViewControllerState realControllerState;

@property (nonatomic, assign) BOOL draggingSlide;

- (void)playerInit;

- (void)handlePlayerStateChange:(ALSVideoPlayerState)state;

- (CGAffineTransform)getTransformWithOrientation:(UIInterfaceOrientation)orientation;

- (void)transfromToOrientation:(UIInterfaceOrientation)orientation;

- (void)refreshPlayerControlsAppearance;

@end

@implementation ALSVideoPlayerView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self playerInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self playerInit];
        [self.playerViewController.view setFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self playerInit];
    }
    return self;
}

#pragma mark Super methods

- (void)layoutSubviews {
    [super layoutSubviews];
    [[ALSVPC(self.videoPlayerControl, ALSVPCPlayerInfo) renderingView] setFrame:self.bounds];
    [self.playerViewController.view setFrame:self.bounds];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.timer stopCountDown];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    [self refreshPlayerControlsAppearance];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark Public methods

- (id)controlling:(Protocol *)control {
    return [self.videoPlayerControl control:control];
}

- (void)enterFullscreen:(UIInterfaceOrientation)orientation {
    if (self.playerViewController.mode == ALSVideoPlayerViewControllerModeFullscreen) {
        return;
    }
    [self transfromToOrientation:orientation];
    [self.playerViewController setMode:ALSVideoPlayerViewControllerModeFullscreen];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerViewDidEnterFullscreen:)]) {
        [self.delegate playerViewDidEnterFullscreen:self];
    }
}

- (void)exitFullscreen {
    if (self.playerViewController.mode == ALSVideoPlayerViewControllerModeNormal) {
        return;
    }
    [self transfromToOrientation:UIInterfaceOrientationPortrait];
    [self.playerViewController setMode:ALSVideoPlayerViewControllerModeNormal];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playerViewDidExitFullscreen:)]) {
        [self.delegate playerViewDidExitFullscreen:self];
    }
}

- (void)setPlaceholderImage:(UIImage *)image {
    [self.playerViewController.backgroundImageView setImage:image];
}

- (void)showGuide:(BOOL)show {
    self.playerViewController.showGuide = show;
}

#pragma mark Private methods

- (void)setViewController:(UIViewController *)viewController {
    _viewController = viewController;
    Method methodOriginal = class_getInstanceMethod([self.viewController class], @selector(shouldAutorotate));
    Method method = class_getInstanceMethod([self class], @selector(viewControllerShouldAutorotate));
    method_exchangeImplementations(methodOriginal, method);
}

- (void)setTags:(NSArray<ALSVPCTag *> *)tags {
    _tags = [tags copy];
    [self.playerViewController setTags:tags];
}

- (void)setViewType:(ALSVideoPlayerViewType)viewType {
    _viewType = viewType;
    [self.playerViewController setType:(ALSVideoPlayerViewControllerType)viewType];
}

- (void)playerInit {
    //播放器
    self.videoPlayerControl = [[ALSVPCControl alloc] init];
    [ALSVPC(self.videoPlayerControl, ALSVPCCallback) setPlayerStateChangeCallback:^(ALSVideoPlayerState state) {
        [self handlePlayerStateChange:state];
    }];
    [ALSVPC(self.videoPlayerControl, ALSVPCCallback) setPlayerTimeChangeCallback:^(NSTimeInterval current, NSTimeInterval total) {
        if (!self.draggingSlide) {
            [self.playerViewController setTimeElapsed:current];
            [self.playerViewController setTotalLength:total];
        }
    }];
    //控件
    _playerViewController = [[ALSVideoPlayerViewController alloc] init];
    [self.playerViewController setType:(ALSVideoPlayerViewControllerType)_viewType];
    self.playerViewController.delegate = self;
    self.playerViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.playerViewController.view];
}

- (void)handlePlayerStateChange:(ALSVideoPlayerState)state {
    switch (state) {
        case ALSVideoPlayerStateReady:
        {
            [[ALSVPC(self.videoPlayerControl, ALSVPCPlayerInfo) renderingView] removeFromSuperview];
            UIView *playerView = [ALSVPC(self.videoPlayerControl, ALSVPCPlayerInfo) renderingView];
            if (playerView) {
                [self insertSubview:playerView atIndex:0];
            }
            [self setRealControllerState:ALSVideoPlayerViewControllerStateReady];
        }
            break;
        case ALSVideoPlayerStatePlaying:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStatePlaying];
        }
            break;
        case ALSVideoPlayerStateLoading:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStatePause];
        }
            break;
        case ALSVideoPlayerStatePause:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStatePause];
        }
            break;
        case ALSVideoPlayerStateFinished:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStateFinished];
        }
            break;
        case ALSVideoPlayerStateError:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStateError];
        }
            break;
        case ALSVideoPlayerStateExit:
        {
            [self setRealControllerState:ALSVideoPlayerViewControllerStateFinished];
        }
            break;
        default:
            break;
    }
    [self refreshPlayerControlsAppearance];
}

- (CGAffineTransform)getTransformWithOrientation:(UIInterfaceOrientation)orientation
{
    if (orientation == UIInterfaceOrientationPortrait) {
        return CGAffineTransformIdentity;
    } else if (orientation == UIInterfaceOrientationLandscapeLeft){
        return CGAffineTransformMakeRotation(-M_PI_2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight){
        return CGAffineTransformMakeRotation(M_PI_2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(M_PI);
    }
    return CGAffineTransformIdentity;
}

- (void)transfromToOrientation:(UIInterfaceOrientation)orientation {
    if (self.viewController) {
        //设置了承载的UIViewController，则使用设置状态栏的方法
        [[UIApplication sharedApplication] setStatusBarOrientation:orientation animated:YES];
        
//        __weak typeof(self) weakSelf = self;
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            _lastFrame = self.frame;
            CGRect rectInWindow = [self convertRect:self.bounds toView:[UIApplication sharedApplication].keyWindow];
            [self removeFromSuperview];
            self.frame = rectInWindow;
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            
            [UIView animateWithDuration:0.3 animations:^{
                [self setTransform:[self getTransformWithOrientation:orientation]];
                self.bounds = CGRectMake(0, 0, CGRectGetHeight(self.superview.bounds), CGRectGetWidth(self.superview.bounds));
                self.center = CGPointMake(CGRectGetMidX(self.superview.bounds), CGRectGetMidY(self.superview.bounds));
                [self layoutIfNeeded];
            } completion:^(BOOL finished) {
                NSLog(@"%@", self);
            }];
        } else {
            //竖屏
            [UIView animateWithDuration:0.3 animations:^{
                [self setTransform:[self getTransformWithOrientation:orientation]];
                self.frame = self.lastFrame;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                [self.viewController.view addSubview:self];
            }];
        }
    } else if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        //旋转设备
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
        
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            //横屏
            _lastFrame = self.frame;
            self.frame = self.superview.bounds;
        } else {
            //竖屏
            self.frame = self.lastFrame;
        }
    }
}

- (void)refreshPlayerControlsAppearance {
    if (self.playerViewController.state == ALSVideoPlayerViewControllerStateHide) {
        [self.playerViewController setState:self.realControllerState];
        if (self.delegate && [self.delegate respondsToSelector:@selector(didShowControlsOfPlayerView:)]) {
            [self.delegate didShowControlsOfPlayerView:self];
        }
    }
    if ([ALSVPC(self.videoPlayerControl, ALSVPCPlayerInfo) state] == ALSVideoPlayerStatePlaying) {
        if (!self.timer) {
            self.timer = [[ALSVPCCountDown alloc] init];
        }
        [self.timer setLeftTime:5];
        [self.timer startCountDownWithCurrentTimeLeft:nil completion:^{
            [self.playerViewController setState:ALSVideoPlayerViewControllerStateHide];
            if (self.delegate && [self.delegate respondsToSelector:@selector(didHideControlsOfPlayerView:)]) {
                [self.delegate didHideControlsOfPlayerView:self];
            }
        }];
    }
}

- (BOOL)viewControllerShouldAutorotate {
    return NO;
}

- (void)setRealControllerState:(ALSVideoPlayerViewControllerState)realControllerState {
    _realControllerState = realControllerState;
    if (self.playerViewController.state != ALSVideoPlayerViewControllerStateHide) {
        self.playerViewController.state = realControllerState;
    }
}

- (BOOL)isFullscreen {
    return (self.playerViewController.mode == ALSVideoPlayerViewControllerModeFullscreen);
}

- (BOOL)controlsHidden {
    return (self.playerViewController.state == ALSVideoPlayerViewControllerStateHide);
}

#pragma mark ALSVideoPlayerViewControllerDelegate

- (void)willHideController:(ALSVideoPlayerViewController *)controller {
    
}

- (void)willShowController:(ALSVideoPlayerViewController *)controller {
    
}

- (void)didClickedBackButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self exitFullscreen];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedShareButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self refreshPlayerControlsAppearance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedShareButtonOnPlayerView:)]) {
        [self.delegate didClickedShareButtonOnPlayerView:self];
    }
}

- (void)didClickedPlayButtonOfController:(ALSVideoPlayerViewController *)controller {
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) play];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedPauseButtonOfController:(ALSVideoPlayerViewController *)controller {
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) pause];
    [self refreshPlayerControlsAppearance];
}

- (void)willStartDraggingProgressSliderOfController:(ALSVideoPlayerViewController *)controller {
    self.draggingSlide = YES;
    [self.timer stopCountDown];
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStartDraggingProgressSliderOnPlayerView:)]) {
        [self.delegate willStartDraggingProgressSliderOnPlayerView:self];
    }
}

- (void)progressSliderValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderValueChanged:onPlayerView:)]) {
        [self.delegate progressSliderValueChanged:value onPlayerView:self];
    }
}

- (void)didStopDraggingProgressSliderOfController:(ALSVideoPlayerViewController *)controller {
//    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) pause];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) seekTo:controller.timeElapsed];
//    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) play]; 
    self.draggingSlide = NO;
    [self refreshPlayerControlsAppearance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStopDraggingProgressSliderOnPlayerView:)]) {
        [self.delegate didStopDraggingProgressSliderOnPlayerView:self];
    }
}

- (void)didClickedEnterFullscreenButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self enterFullscreen:UIInterfaceOrientationLandscapeRight];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedExitFullscreenButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self exitFullscreen];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedPreviousButtonWithValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller {
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) pause];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) seekTo:value];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) play];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedNextButtonWithValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller {
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) pause];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) seekTo:value];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) play];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedCutButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self refreshPlayerControlsAppearance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedCutButtonOnPlayerView:)]) {
        [self.delegate didClickedCutButtonOnPlayerView:self];
    }
}

- (void)didClickedReplayButtonOfController:(ALSVideoPlayerViewController *)controller {
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) pause];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) seekTo:0];
    [ALSVPC(self.videoPlayerControl, ALSVPCPlayAction) play];
    [self refreshPlayerControlsAppearance];
}

- (void)didClickedRefreshButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self refreshPlayerControlsAppearance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedRefreshButtonOnPlayerView:)]) {
        [self.delegate didClickedRefreshButtonOnPlayerView:self];
    }
}

- (void)didClickedRetryButtonOfController:(ALSVideoPlayerViewController *)controller {
    [self refreshPlayerControlsAppearance];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedRetryButtonOfController:)]) {
        [self.delegate didClickedRetryButtonOnPlayerView:self];
    }
}

@end
