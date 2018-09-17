//
//  ViewController.m
//  IJKTest
//
//  Created by Altair on 2018/4/23.
//  Copyright © 2018 Alisports. All rights reserved.
//

#import "ViewController.h"
#import "ALSVideoPlayerControl.h"

@interface ViewController () <ALSVideoPlayerViewDelegate>

@property (nonatomic, strong) ALSVideoPlayerView *playerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *tags = @[
                      [ALSVPCTag tagWithRange:NSMakeRange(627, 12) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(639, 7) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(646, 7) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(656, 5) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(669, 29) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(698, 3) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(704, 9) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(713, 3) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(717, 3) color:[UIColor blueColor]],
                      [ALSVPCTag tagWithRange:NSMakeRange(720, 3) color:[UIColor blueColor]]
                      ];
    
//    NSString *url = @"http://flv2.bn.netease.com/videolib3/1604/28/fVobI0704/SD/fVobI0704-mobile.mp4";
    NSString *url = @"http://vod-p3.alisports.com/ba88b520663a45d281abf8ce47214f09/b778bdc1fd0b46b7906906ded27953d4-17bc3cb0e31acdec05952d28e0657619-od-S00000001-100000.m3u8";
    self.playerView = [[ALSVideoPlayerView alloc] initWithFrame:CGRectMake(0, 0, 320, 180)];
    [ALSVideoPlayerControlling(self.playerView, ALSVPCMediaControl) setSourceUrl:[NSURL URLWithString:url]];
    [self.playerView setTags:tags];
    self.playerView.viewController = self;
    self.playerView.delegate = self;
    [self.view addSubview:self.playerView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    
}

- (BOOL)prefersStatusBarHidden {
    if (self.playerView.isFullscreen && self.playerView.controlsHidden) {
        return YES;
    }
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ALSVideoPlayerViewDelegate

- (void)didHideControlsOfPlayerView:(ALSVideoPlayerView *)view {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didShowControlsOfPlayerView:(ALSVideoPlayerView *)view {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)playerViewDidEnterFullscreen:(ALSVideoPlayerView *)view {
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)playerViewDidExitFullscreen:(ALSVideoPlayerView *)view {
    [self setNeedsStatusBarAppearanceUpdate];
}

@end
