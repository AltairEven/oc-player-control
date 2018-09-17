//
//  ALSVideoPlayerViewController.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/27.
//

#import "ALSVideoPlayerViewController.h"

@interface UIButton (ALSVPCTapExt)

@end

@implementation UIButton (ALSVPCTapExt)

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = self.bounds;
    //若原热区小于44x44，则放大热区，否则保持原大小不变
    CGFloat widthDelta = MAX(44.0 - bounds.size.width, 0);
    CGFloat heightDelta = MAX(44.0 - bounds.size.height, 0);
    bounds = CGRectInset(bounds, -0.5 * widthDelta, -0.5 * heightDelta);
    return CGRectContainsPoint(bounds, point);
}

@end

#define ALSVPC_IMAGE(imageName)   [[UIImage imageNamed:[NSString stringWithFormat:@"ALSVPCUIResource.bundle/%@", imageName]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]

#define ALSVPC_THEMECOLOR   [UIColor colorWithRed:255.0/255.0 green:200.0/255.0 blue:50.0/255.0 alpha:1]

@interface ALSVideoPlayerViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (unsafe_unretained, nonatomic) IBOutlet UIView *controllerBGView;
@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *bottomControlPanel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *rightControlPanel;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *liveBottomControlPanel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *shareButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *backButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *currentTimeLabel;

//buttonControlPanel
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *playButton;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *elapsedTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet ALSVPCSlideView *progressSlider;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *totalTimeLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *fullScreenButton;

//rightControlPanel
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *previousButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *nextButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *cutButton;

//liveBottomControlPanel
@property (unsafe_unretained, nonatomic) IBOutlet ALSVPCSlideView *liveProgressSlider;
@property (weak, nonatomic) IBOutlet UILabel *liveStateLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *liveFullScreenButton;

//extension control panel
@property (unsafe_unretained, nonatomic) IBOutlet UIView *ext_BGView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ext_BackButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *ext_finished_panel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ext_finished_ReplayButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ext_finished_CutButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIView *ext_error_panel;
@property (weak, nonatomic) IBOutlet UIImageView *ext_error_imageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ext_error_imageViewHeight;
@property (unsafe_unretained, nonatomic) IBOutlet UILabel *ext_error_label;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *ext_error_refreshButton;
@property (weak, nonatomic) IBOutlet UIImageView *guideImageView;

- (void)resetControlsWithControllerType:(ALSVideoPlayerViewControllerType)type mode:(ALSVideoPlayerViewControllerMode)mode andState:(ALSVideoPlayerViewControllerState)state;

- (NSString *)lengthStringOfTimeInterval:(NSTimeInterval)interval;
- (NSString *)timeStringOfDate:(NSDate *)date;

- (void)renderGradientForView:(UIView *)view withDisplayFrame:(CGRect)frame startPoint:(CGPoint)start endPoint:(CGPoint)end colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations;

@end

@implementation ALSVideoPlayerViewController

#pragma mark Super methods

- (instancetype)init {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ALSVPCUIResource" ofType:@".bundle"];
    self = [super initWithNibName:@"ALSVideoPlayerViewController" bundle:[NSBundle bundleWithPath:path]];
    if (self) {
        _type = ALSVideoPlayerViewControllerTypeNormal;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [ALSVPCSlideView class];//防止xib没有link导致的崩溃
    // Do any additional setup after loading the view from its nib.
    UIColor *topColor = [UIColor clearColor];
    UIColor *bottomColor = [[UIColor blackColor] colorWithAlphaComponent:1];
    CGRect frame = CGRectMake(0, 0, 1000, CGRectGetHeight(self.bottomControlPanel.bounds));
    [self renderGradientForView:self.bottomControlPanel withDisplayFrame:frame startPoint:CGPointMake(0.5, 0) endPoint:CGPointMake(0.5, 1) colors:@[topColor, bottomColor] locations:nil];
    self.bottomControlPanel.layer.masksToBounds = YES;
    
    [self.progressSlider setTrackHeight:10];
    [self.progressSlider setThumbImage:ALSVPC_IMAGE(@"alsvpc_slidetap") forState:UIControlStateNormal];
    [self.progressSlider setThumbImage:ALSVPC_IMAGE(@"alsvpc_slidetap") forState:UIControlStateHighlighted];
    [self.progressSlider setMinimumTrackTintColor:ALSVPC_THEMECOLOR];
    [self.progressSlider setMaximumTrackTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    [self.progressSlider setMinimumValue:0];
    
    [self.liveProgressSlider setTrackHeight:10];
    [self.liveProgressSlider setThumbImage:ALSVPC_IMAGE(@"alsvpc_slidetap") forState:UIControlStateNormal];
    [self.liveProgressSlider setThumbImage:ALSVPC_IMAGE(@"alsvpc_slidetap") forState:UIControlStateHighlighted];
    [self.liveProgressSlider setMinimumTrackTintColor:ALSVPC_THEMECOLOR];
    [self.liveProgressSlider setMaximumTrackTintColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1]];
    [self.liveProgressSlider setMinimumValue:0];
    [self.liveProgressSlider setMaximumValue:1];
    [self.liveProgressSlider setValue:1 animated:YES];
    [self.liveProgressSlider setUserInteractionEnabled:NO];
    
    [self setTotalLength:_totalLength];
    [self setTimeElapsed:_timeElapsed];
    [self setTags:_tags];
    [self setCurrentDate:_currentDate];
    
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchBegan) forControlEvents:UIControlEventTouchDown];
    [self.progressSlider addTarget:self action:@selector(progressSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
    [self.progressSlider addTarget:self action:@selector(progressSliderTouchEnd) forControlEvents:UIControlEventTouchUpOutside];
//    [self.liveProgressSlider addTarget:self action:@selector(liveProgressSliderTouchBegan) forControlEvents:UIControlEventTouchDown];
//    [self.liveProgressSlider addTarget:self action:@selector(liveProgressSliderValueChanged) forControlEvents:UIControlEventValueChanged];
//    [self.liveProgressSlider addTarget:self action:@selector(liveProgressSliderTouchEnd) forControlEvents:UIControlEventTouchUpInside];
//    [self.liveProgressSlider addTarget:self action:@selector(liveProgressSliderTouchEnd) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.tipsLabel setText:@"啊噢，直播已结束~"];
    [self.shareButton setImage:ALSVPC_IMAGE(@"alsvpc_share") forState:UIControlStateNormal];
    [self.backButton setImage:ALSVPC_IMAGE(@"alsvpc_back") forState:UIControlStateNormal];
    [self.playButton setImage:ALSVPC_IMAGE(@"alsvpc_play") forState:UIControlStateNormal];
    [self.fullScreenButton setImage:ALSVPC_IMAGE(@"alsvpc_enterfullscreen") forState:UIControlStateNormal];
    [self.previousButton setImage:ALSVPC_IMAGE(@"alsvpc_previous_normal") forState:UIControlStateNormal];
    [self.previousButton setImage:ALSVPC_IMAGE(@"alsvpc_previous_disable") forState:UIControlStateDisabled];
    [self.nextButton setImage:ALSVPC_IMAGE(@"alsvpc_next_normal") forState:UIControlStateNormal];
    [self.nextButton setImage:ALSVPC_IMAGE(@"alsvpc_next_disable") forState:UIControlStateDisabled];
    [self.cutButton setImage:ALSVPC_IMAGE(@"alsvpc_cut_normal") forState:UIControlStateNormal];
    [self.cutButton setImage:ALSVPC_IMAGE(@"alsvpc_cut_disable") forState:UIControlStateDisabled];
    [self.liveFullScreenButton setImage:ALSVPC_IMAGE(@"alsvpc_enterfullscreen") forState:UIControlStateNormal];
    [self.ext_BackButton setImage:ALSVPC_IMAGE(@"alsvpc_back") forState:UIControlStateNormal];
    [self.ext_finished_ReplayButton setImage:ALSVPC_IMAGE(@"alsvpc_replay") forState:UIControlStateNormal];
    [self.ext_finished_CutButton setImage:ALSVPC_IMAGE(@"alsvpc_cut_normal") forState:UIControlStateNormal];
    [self.ext_finished_CutButton setImage:ALSVPC_IMAGE(@"alsvpc_cut_disable") forState:UIControlStateDisabled];
    
    [self resetControlsWithControllerType:_type mode:_mode andState:_state];
    
    [self.guideImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnGuide:)]];
    self.showGuide = NO;
    
    [self.cutButton setHidden:YES];//一期需求不要展示
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Private methods

- (void)setTotalLength:(NSTimeInterval)total {
    _totalLength = total;
    [self.totalTimeLabel setText:[self lengthStringOfTimeInterval:total]];
    [self.progressSlider setMaximumValue:total];
}

- (void)setTimeElapsed:(NSTimeInterval)elapsed {
    [self setTimeElapsed:elapsed animated:NO];
}

- (void)setTags:(NSArray <ALSVPCTag *>*)tags {
    _tags = [tags copy];
    if (self.type == ALSVideoPlayerViewControllerTypeNormal) {
        //只有未剪辑视频才打标
        [self.progressSlider setTags:tags];
        [self resetControlsWithControllerType:_type mode:_mode andState:_state];
    }
}

- (void)setHasCut:(BOOL)has {
    _hasCut = has;
    [self.cutButton setEnabled:!has];
}

- (void)setCurrentDate:(NSDate *)date {
    _currentDate = [date copy];
    [self.currentTimeLabel setText:[self timeStringOfDate:date]];
}

- (void)setType:(ALSVideoPlayerViewControllerType)type {
    _type = type;
    [self resetControlsWithControllerType:_type mode:_mode andState:_state];
}

- (void)setMode:(ALSVideoPlayerViewControllerMode)mode {
    _mode = mode;
    [self resetControlsWithControllerType:_type mode:_mode andState:_state];
}

- (void)setState:(ALSVideoPlayerViewControllerState)state {
    _state = state;
    [self resetControlsWithControllerType:_type mode:_mode andState:_state];
}

- (void)setShowGuide:(BOOL)showGuide {
    _showGuide = showGuide;
    [self.guideImageView setHidden:!showGuide];
}

- (void)resetControlsWithControllerType:(ALSVideoPlayerViewControllerType)type mode:(ALSVideoPlayerViewControllerMode)mode andState:(ALSVideoPlayerViewControllerState)state {
    NSTimeInterval animationInterval = 0.5;
    //隐藏控件
    [self.ext_BGView setHidden:YES];
    if (state == ALSVideoPlayerViewControllerStateHide) {
        [UIView animateWithDuration:animationInterval animations:^{
            [self.controllerBGView setAlpha:0];
        } completion:^(BOOL finished) {
            [self.controllerBGView setHidden:YES];
        }];
        return;
    } else {
        [UIView animateWithDuration:animationInterval animations:^{
            [self.controllerBGView setAlpha:1];
            [self.controllerBGView setHidden:NO];
        } completion:nil];
    }
    [self.previousButton setHidden:(self.tags.count > 0) ? NO : YES];
    [self.nextButton setHidden:(self.tags.count > 0) ? NO : YES];
    [self.tipsLabel setHidden:YES];
    //针对不同type
    [self.bottomControlPanel setHidden:(type == ALSVideoPlayerViewControllerTypeLive) ? YES : NO];
    [self.rightControlPanel setHidden:(type == ALSVideoPlayerViewControllerTypeNormal) ? NO : YES];
    [self.liveBottomControlPanel setHidden:(type == ALSVideoPlayerViewControllerTypeLive) ? NO : YES];
    [self.shareButton setHidden:(type == ALSVideoPlayerViewControllerTypeCut) ? NO : YES];
    [self.ext_error_label setText:(type == ALSVideoPlayerViewControllerTypeLive) ? @"直播信号异常" : @"点播信号异常"];
    //针对不同mode
    if (self.mode == ALSVideoPlayerViewControllerModeFullscreen) {
        [self.fullScreenButton setImage:ALSVPC_IMAGE(@"alsvpc_exitfullscreen") forState:UIControlStateNormal];
        [self.backButton setHidden:NO];
//        [self.currentTimeLabel setHidden:YES];
    } else {
        [self.fullScreenButton setImage:ALSVPC_IMAGE(@"alsvpc_enterfullscreen") forState:UIControlStateNormal];
        [self.backButton setHidden:YES];
//        [self.currentTimeLabel setHidden:(type == ALSVideoPlayerViewControllerTypeLive) ? NO : YES];
    }
    //针对不同state
    switch (state) {
        case ALSVideoPlayerViewControllerStateReady:
        {
            [self.playButton setImage:ALSVPC_IMAGE(@"alsvpc_play") forState:UIControlStateNormal];
            [self.liveStateLabel setText:@"LIVE"];
            [self.liveStateLabel setTextColor:ALSVPC_THEMECOLOR];
        }
            break;
        case ALSVideoPlayerViewControllerStatePlaying:
        {
            [self.playButton setImage:ALSVPC_IMAGE(@"alsvpc_pause") forState:UIControlStateNormal];
            [self.liveStateLabel setText:@"LIVE"];
            [self.liveStateLabel setTextColor:ALSVPC_THEMECOLOR];
        }
            break;
        case ALSVideoPlayerViewControllerStatePause:
        {
            [self.playButton setImage:ALSVPC_IMAGE(@"alsvpc_play") forState:UIControlStateNormal];
            [self.liveStateLabel setText:@"LIVE"];
            [self.liveStateLabel setTextColor:ALSVPC_THEMECOLOR];
        }
            break;
        case ALSVideoPlayerViewControllerStateFinished:
        {
            [self.controllerBGView setHidden:(type == ALSVideoPlayerViewControllerTypeLive) ? NO : YES];
            [self.ext_BGView setHidden:NO];
            [self.ext_BackButton setHidden:YES];
            [self.ext_finished_panel setHidden:NO];
            [self.ext_error_panel setHidden:YES];
            [self.liveStateLabel setText:@"OVER"];
            [self.liveStateLabel setTextColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
            [self.tipsLabel setHidden:NO];
        }
            break;
        case ALSVideoPlayerViewControllerStateHide:
        {
            //hidden
            [self.controllerBGView setHidden:YES];
            [self.ext_BGView setHidden:YES];
        }
            break;
        case ALSVideoPlayerViewControllerStateError:
        {
            //error
            [self.controllerBGView setHidden:YES];
            [self.ext_BGView setHidden:NO];
            [self.ext_BackButton setHidden:YES];
            [self.ext_finished_panel setHidden:YES];
            [self.ext_error_panel setHidden:NO];
            self.ext_error_imageViewHeight.constant = 0;
            [self.ext_error_refreshButton setTitle:@"刷新试试" forState:UIControlStateNormal];
        }
            break;
        case ALSVideoPlayerViewControllerStateCutFailed:
        {
            //cut failed
            [self.controllerBGView setHidden:YES];
            [self.ext_BGView setHidden:NO];
            [self.ext_BackButton setHidden:YES];
            [self.ext_finished_panel setHidden:YES];
            [self.ext_error_panel setHidden:NO];
            self.ext_error_imageViewHeight.constant = 80;
            [self.ext_error_imageView setImage:ALSVPC_IMAGE(@"alsvpc_cut_error")];
            [self.ext_error_label setText:@"哎呀！一键剪辑失败了"];
            [self.ext_error_refreshButton setTitle:@"再试试看" forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
}

- (NSString *)lengthStringOfTimeInterval:(NSTimeInterval)interval {
    if (interval < 0) {
        return @"--:--";
    }
    NSUInteger min = interval / 60;
    NSUInteger sec = (NSUInteger)interval % 60;
    
    NSString *minString = nil;
    NSString *secString = nil;
    if (min < 10) {
        minString = [NSString stringWithFormat:@"0%lu", (unsigned long)min];
    } else {
        minString = [NSString stringWithFormat:@"%lu", (unsigned long)min];
    }
    if (sec < 10) {
        secString = [NSString stringWithFormat:@"0%lu", (unsigned long)sec];
    } else {
        secString = [NSString stringWithFormat:@"%lu", (unsigned long)sec];
    }
    return [NSString stringWithFormat:@"%@:%@", minString, secString];
}

- (NSString *)timeStringOfDate:(NSDate *)date {
    if (!date || ![date isKindOfClass:[NSDate class]]) {
        return nil;
    }
    if (!self.dateFormatter) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    
    NSString *timeString = [self.dateFormatter stringFromDate:date];
    return [NSString stringWithFormat:@"\t%@\t", timeString];
}

- (void)renderGradientForView:(UIView *)view withDisplayFrame:(CGRect)frame startPoint:(CGPoint)start endPoint:(CGPoint)end colors:(NSArray<UIColor *> *)colors locations:(NSArray<NSNumber *> *)locations {
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    gradient.startPoint = start;
    gradient.endPoint = end;
    if (colors) {
        NSMutableArray *temp = [[NSMutableArray alloc] init];
        for (UIColor *color in colors) {
            [temp addObject:(id)(color.CGColor)];
        }
        gradient.colors = temp;
    }
    gradient.locations = locations;
    gradient.contentsGravity = kCAGravityResize;
    [view.layer insertSublayer:gradient atIndex:0];
}

- (void)tappedOnGuide:(id)sender {
    self.showGuide = NO;
}

#pragma mark Controls events

- (IBAction)playButtonClicked:(id)sender {
    if (self.state == ALSVideoPlayerViewControllerStatePlaying) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedPauseButtonOfController:)]) {
            [self.delegate didClickedPauseButtonOfController:self];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedPlayButtonOfController:)]) {
            [self.delegate didClickedPlayButtonOfController:self];
        }
    }
}

- (void)progressSliderTouchBegan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStartDraggingProgressSliderOfController:)]) {
        [self.delegate willStartDraggingProgressSliderOfController:self];
    }
}

- (void)progressSliderValueChanged {
    [self setTimeElapsed:self.progressSlider.value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderValueChanged:ofController:)]) {
        [self.delegate progressSliderValueChanged:self.progressSlider.value ofController:self];
    }
}

- (void)progressSliderTouchEnd {
    [self setTimeElapsed:self.progressSlider.value];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStopDraggingProgressSliderOfController:)]) {
        [self.delegate didStopDraggingProgressSliderOfController:self];
    }
}

- (IBAction)fullscreenButtonClicked:(id)sender {
    switch (self.mode) {
        case ALSVideoPlayerViewControllerModeNormal:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedEnterFullscreenButtonOfController:)]) {
                [self.delegate didClickedEnterFullscreenButtonOfController:self];
            }
        }
            break;
        case ALSVideoPlayerViewControllerModeFullscreen:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedExitFullscreenButtonOfController:)]) {
                [self.delegate didClickedExitFullscreenButtonOfController:self];
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)previousButtonClicked:(id)sender {
    ALSVPCTag *previousTag = [self.progressSlider.renderingTags objectAtIndex:self.progressSlider.previousTagIndex];
    [self setTimeElapsed:previousTag.range.location animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedPreviousButtonWithValueChanged:ofController:)]) {
        [self.delegate didClickedPreviousButtonWithValueChanged:previousTag.range.location ofController:self];
    }
}

- (IBAction)nextButtonClicked:(id)sender {
    ALSVPCTag *nextTag = [self.progressSlider.renderingTags objectAtIndex:self.progressSlider.nextTagIndex];
    [self setTimeElapsed:nextTag.range.location animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedNextButtonWithValueChanged:ofController:)]) {
        [self.delegate didClickedNextButtonWithValueChanged:nextTag.range.location ofController:self];
    }
}

- (IBAction)cutButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedCutButtonOfController:)]) {
        [self.delegate didClickedCutButtonOfController:self];
    }
}

- (IBAction)shareButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedShareButtonOfController:)]) {
        [self.delegate didClickedShareButtonOfController:self];
    }
}

- (IBAction)backButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedBackButtonOfController:)]) {
        [self.delegate didClickedBackButtonOfController:self];
    }
}

- (void)liveProgressSliderTouchBegan {
    if (self.delegate && [self.delegate respondsToSelector:@selector(willStartDraggingProgressSliderOfController:)]) {
        [self.delegate willStartDraggingProgressSliderOfController:self];
    }
}

- (void)liveProgressSliderValueChanged {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressSliderValueChanged:ofController:)]) {
        [self.delegate progressSliderValueChanged:self.liveProgressSlider.value ofController:self];
    }
}

- (void)liveProgressSliderTouchEnd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStopDraggingProgressSliderOfController:)]) {
        [self.delegate didStopDraggingProgressSliderOfController:self];
    }
}

- (IBAction)liveFullscreenButtonClicked:(id)sender {
    switch (self.mode) {
        case ALSVideoPlayerViewControllerModeNormal:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedEnterFullscreenButtonOfController:)]) {
                [self.delegate didClickedEnterFullscreenButtonOfController:self];
            }
        }
            break;
        case ALSVideoPlayerViewControllerModeFullscreen:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedExitFullscreenButtonOfController:)]) {
                [self.delegate didClickedExitFullscreenButtonOfController:self];
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)extBackButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedBackButtonOfController:)]) {
        [self.delegate didClickedBackButtonOfController:self];
    }
}

- (IBAction)extFinishedReplayButtonClciked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedReplayButtonOfController:)]) {
        [self.delegate didClickedReplayButtonOfController:self];
    }
}

- (IBAction)extFinishedCutButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedCutButtonOfController:)]) {
        [self.delegate didClickedCutButtonOfController:self];
    }
}

- (IBAction)extErrorRefreshButtonClicked:(id)sender {
    if (self.state == ALSVideoPlayerViewControllerStateError) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedRefreshButtonOfController:)]) {
            [self.delegate didClickedRefreshButtonOfController:self];
        }
    }
    if (self.state == ALSVideoPlayerViewControllerStateCutFailed) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didClickedRetryButtonOfController:)]) {
            [self.delegate didClickedRetryButtonOfController:self];
        }
    }
}

#pragma mark Public methods

- (instancetype)initWithType:(ALSVideoPlayerViewControllerType)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ALSVPCUIResource" ofType:@".bundle"];
    self = [super initWithNibName:@"ALSVideoPlayerViewController" bundle:[NSBundle bundleWithPath:path]];
    if (self) {
        _type = type;
    }
    return self;
}

+ (instancetype)controllerWithType:(ALSVideoPlayerViewControllerType)type {
    ALSVideoPlayerViewController *controller = [[ALSVideoPlayerViewController alloc] initWithType:type];
    return controller;
}

- (void)setTimeElapsed:(NSTimeInterval)timeElapsed animated:(BOOL)animated {
    _timeElapsed = timeElapsed;
    [self.elapsedTimeLabel setText:[self lengthStringOfTimeInterval:timeElapsed]];
    if (self.type == ALSVideoPlayerViewControllerTypeNormal || self.type == ALSVideoPlayerViewControllerTypeCut) {
        [self.progressSlider setValue:timeElapsed animated:animated];
    }
    [self.previousButton setEnabled:self.progressSlider.previousTagIndex >= 0];
    [self.nextButton setEnabled:self.progressSlider.nextTagIndex >= 0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
