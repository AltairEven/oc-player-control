//
//  ALSVideoPlayerView.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/26.
//

#import <UIKit/UIKit.h>
#import "ALSVPCTag.h"

#define ALSVideoPlayerControlling(videoPlayerViewInstance, __protocol__) \
((videoPlayerViewInstance && [videoPlayerViewInstance isKindOfClass:[ALSVideoPlayerView class]])?  \
((id<__protocol__>)([videoPlayerViewInstance controlling:@protocol(__protocol__)])):nil)

@class ALSVideoPlayerView;


typedef enum {
    ALSVideoPlayerViewTypeNormal,
    ALSVideoPlayerViewTypeCut,
    ALSVideoPlayerViewTypeLive
}ALSVideoPlayerViewType;

@protocol ALSVideoPlayerViewDelegate <NSObject>

@optional

- (void)didHideControlsOfPlayerView:(ALSVideoPlayerView *)view;

- (void)didShowControlsOfPlayerView:(ALSVideoPlayerView *)view;

- (void)playerViewDidEnterFullscreen:(ALSVideoPlayerView *)view;

- (void)playerViewDidExitFullscreen:(ALSVideoPlayerView *)view;

- (void)didClickedShareButtonOnPlayerView:(ALSVideoPlayerView *)view;

- (void)willStartDraggingProgressSliderOnPlayerView:(ALSVideoPlayerView *)view;
- (void)progressSliderValueChanged:(NSTimeInterval)value onPlayerView:(ALSVideoPlayerView *)view;
- (void)didStopDraggingProgressSliderOnPlayerView:(ALSVideoPlayerView *)view;

- (void)didClickedCutButtonOnPlayerView:(ALSVideoPlayerView *)view;

- (void)didClickedRefreshButtonOnPlayerView:(ALSVideoPlayerView *)view;

- (void)didClickedRetryButtonOnPlayerView:(ALSVideoPlayerView *)view;

@end

@interface ALSVideoPlayerView : UIView

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, copy) NSArray <ALSVPCTag *>*tags;

@property (nonatomic, readonly) BOOL isFullscreen;

@property (nonatomic, readonly) BOOL controlsHidden;

@property (nonatomic, weak) id<ALSVideoPlayerViewDelegate> delegate;

@property (nonatomic, assign) ALSVideoPlayerViewType viewType;

- (id)controlling:(Protocol*)control;

- (void)enterFullscreen:(UIInterfaceOrientation)orientation;

- (void)exitFullscreen;

- (void)setPlaceholderImage:(UIImage *)image;

- (void)showGuide:(BOOL)show;

@end
