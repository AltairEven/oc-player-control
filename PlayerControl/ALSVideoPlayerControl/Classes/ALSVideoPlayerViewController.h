//
//  ALSVideoPlayerViewController.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/27.
//

#import <UIKit/UIKit.h>
#import "ALSVPCSlideView.h"

typedef enum {
    //准备
    ALSVideoPlayerViewControllerStateReady,
    //播放中
    ALSVideoPlayerViewControllerStatePlaying,
    //暂停
    ALSVideoPlayerViewControllerStatePause,
    //播放完成
    ALSVideoPlayerViewControllerStateFinished,
    //隐藏控件
    ALSVideoPlayerViewControllerStateHide,
    //播放错误
    ALSVideoPlayerViewControllerStateError,
    //剪辑失败
    ALSVideoPlayerViewControllerStateCutFailed,
}ALSVideoPlayerViewControllerState;

typedef enum {
    ALSVideoPlayerViewControllerModeNormal,
    ALSVideoPlayerViewControllerModeFullscreen
}ALSVideoPlayerViewControllerMode;

typedef enum {
    ALSVideoPlayerViewControllerTypeNormal,
    ALSVideoPlayerViewControllerTypeCut,
    ALSVideoPlayerViewControllerTypeLive
}ALSVideoPlayerViewControllerType;

@class ALSVideoPlayerViewController;

@protocol ALSVideoPlayerViewControllerDelegate <NSObject>

@optional

- (void)willHideController:(ALSVideoPlayerViewController *)controller;
- (void)willShowController:(ALSVideoPlayerViewController *)controller;

- (void)didClickedBackButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedShareButtonOfController:(ALSVideoPlayerViewController *)controller;

- (void)didClickedPlayButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedPauseButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)willStartDraggingProgressSliderOfController:(ALSVideoPlayerViewController *)controller;
- (void)progressSliderValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller;
- (void)didStopDraggingProgressSliderOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedEnterFullscreenButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedExitFullscreenButtonOfController:(ALSVideoPlayerViewController *)controller;

- (void)didClickedPreviousButtonWithValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedNextButtonWithValueChanged:(NSTimeInterval)value ofController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedCutButtonOfController:(ALSVideoPlayerViewController *)controller;

- (void)didClickedReplayButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedRefreshButtonOfController:(ALSVideoPlayerViewController *)controller;
- (void)didClickedRetryButtonOfController:(ALSVideoPlayerViewController *)controller;

@end

@interface ALSVideoPlayerViewController : UIViewController

@property (nonatomic, assign) ALSVideoPlayerViewControllerType type;

@property (nonatomic, assign) ALSVideoPlayerViewControllerMode mode;

@property (nonatomic, assign) ALSVideoPlayerViewControllerState state;

@property (nonatomic, weak) id<ALSVideoPlayerViewControllerDelegate> delegate;

@property (nonatomic, assign) NSTimeInterval totalLength;

@property (nonatomic, assign) NSTimeInterval timeElapsed;

@property (nonatomic, copy) NSArray <ALSVPCTag *> *tags;

@property (nonatomic, assign) BOOL hasCut;

@property (nonatomic, copy) NSDate *currentDate;

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

@property (nonatomic, assign) BOOL showGuide;


- (instancetype)initWithType:(ALSVideoPlayerViewControllerType)type;

+ (instancetype)controllerWithType:(ALSVideoPlayerViewControllerType)type;

- (void)setTimeElapsed:(NSTimeInterval)timeElapsed animated:(BOOL)animated;

@end
