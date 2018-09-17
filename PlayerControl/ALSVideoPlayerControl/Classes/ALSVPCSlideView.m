//
//  ALSVPCProgressView.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/27.
//

#import "ALSVPCSlideView.h"

@interface ALSVPCSlideView ()

@property (nonatomic, strong) UIView *tagBGView;

@property (nonatomic, strong) NSArray <UIView *>*tagViews;

@property (nonatomic, assign) BOOL tagsDrawn;

@property (nonatomic, assign) BOOL trackViewMasked;

@end

@implementation ALSVPCSlideView
@synthesize currentTagIndex = _currentTagIndex;

#pragma mark Private methods

- (void)setTags:(NSArray<ALSVPCTag *> *)tags {
    _tags = tags;
    [self.tagViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.tagsDrawn = NO;
    _renderingTags = [_tags sortedArrayUsingComparator:^NSComparisonResult(ALSVPCTag *_Nonnull obj1, ALSVPCTag *_Nonnull obj2) {
        return (obj1.range.location > obj2.range.location);
    }];
    [self setNeedsDisplay];
}

- (NSRange)renderingRangeOfTag:(ALSVPCTag *)tag {
    CGFloat maxLength = self.maximumValue - self.minimumValue;
    if (maxLength <= 0) {
        return NSMakeRange(NSNotFound, 0);
    }
    CGFloat renderingLocation = tag.range.location * (self.bounds.size.width / maxLength);
    CGFloat renderingLength = (tag.range.length / maxLength) * self.bounds.size.width;
    if ((renderingLocation + renderingLength) > self.bounds.size.width) {
        renderingLength = self.bounds.size.width - renderingLocation + 1;
    }
    return NSMakeRange(renderingLocation, renderingLength);
}

- (CGFloat)trackHeight {
    if (_trackHeight < 1) {
        return 2.0;
    }
    return _trackHeight;
}

- (NSInteger)currentTagIndex {
    for (NSInteger index = 0; index < self.renderingTags.count; index ++) {
        ALSVPCTag *tag = [self.renderingTags objectAtIndex:index];
        if (NSLocationInRange(self.value, tag.range)) {
            //在范围内
            return index;
        }
    }
    return -1;
}

- (NSInteger)previousTagIndex {
    NSInteger previous = -1;
    if (self.currentTagIndex >= 0) {
        previous = self.currentTagIndex - 1;
        return previous;
    }
    //不在任何范围内
    for (NSInteger index = 0; index < self.renderingTags.count; index ++) {
        ALSVPCTag *tag = [self.renderingTags objectAtIndex:index];
        if (self.value > (tag.range.location + tag.range.length)) {
            previous = index;
        } else {
            break;
        }
    }
    return previous;
}

- (NSInteger)nextTagIndex {
    NSInteger next = -1;
    if (self.currentTagIndex >= 0 && self.currentTagIndex < (self.renderingTags.count - 1)) {
        next = self.currentTagIndex + 1;
        return next;
    }
    //不在任何范围内
    for (NSInteger index = 0; index < self.renderingTags.count; index ++) {
        ALSVPCTag *tag = [self.renderingTags objectAtIndex:index];
        if (self.value < tag.range.location) {
            next = index;
            break;
        }
    }
    return next;
}

#pragma mark Public methods

- (void)slideToNextTagAnimated:(BOOL)animated {
    [self slideToTagAtIndex:self.nextTagIndex animated:animated];
}

- (void)slideToPreviousTagAnimated:(BOOL)animated {
    [self slideToTagAtIndex:self.previousTagIndex animated:animated];
}

- (void)slideToTagAtIndex:(NSInteger)index animated:(BOOL)animated {
    if (index < 0 || index >= self.renderingTags.count) {
        return;
    }
    ALSVPCTag *tag = [self.renderingTags objectAtIndex:index];
    [self setValue:tag.range.location animated:animated];
    _currentTagIndex = index;
}

#pragma mark Super methods

// 设置最大值
- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0, CGRectGetWidth(self.frame)/ 2, CGRectGetHeight(self.frame) / 2);
}
// 设置最小值
- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds {
    return CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}

// 控制slider的宽和高，这个方法才是真正的改变slider滑道的高的
- (CGRect)trackRectForBounds:(CGRect)bounds {
    return CGRectMake(0, (CGRectGetHeight(self.frame) - self.trackHeight) / 2.0, CGRectGetWidth(self.frame), self.trackHeight);
}

// 改变滑块的触摸范围
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    return CGRectInset([super thumbRectForBounds:bounds trackRect:rect value:value], 5, 5);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.tagViews.count > 0) {
        //重新调整背景的frame
        self.tagBGView.frame = [self trackRectForBounds:self.bounds];
        //重新调整tag views的frame
        for (NSUInteger index = 0;index < self.tagViews.count; index ++) {
            UIView *tagView = [self.tagViews objectAtIndex:index];
            NSRange renderingRange = [self renderingRangeOfTag:[self.renderingTags objectAtIndex:index]];
            tagView.frame = CGRectMake(renderingRange.location, 0, renderingRange.length, self.tagBGView.bounds.size.height);
        }
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [super drawRect:rect];
    
    if (!self.tagsDrawn && [self.renderingTags count] > 0) {
        //存在未绘制的tag views的情况下开始绘制
        if (!self.tagBGView) {
            self.tagBGView = [[UIView alloc] initWithFrame:[self trackRectForBounds:self.bounds]];
            [self.tagBGView setBackgroundColor:[UIColor clearColor]];
            [self.tagBGView setUserInteractionEnabled:NO];
            //由于UISlider绘制之前，没有subview，所以需要在绘制后添加tag背景视图
            [self insertSubview:self.tagBGView atIndex:self.subviews.count - 1];
        }
        NSMutableArray *add = [[NSMutableArray alloc] init];
        for (ALSVPCTag *tag in self.renderingTags) {
            NSRange renderingRange = [self renderingRangeOfTag:tag];
            UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(renderingRange.location, 0, renderingRange.length, self.tagBGView.bounds.size.height)];
            [tagView setBackgroundColor:tag.color];
            tagView.layer.cornerRadius = tagView.frame.size.height / 2;
            tagView.layer.masksToBounds = YES;
            [self.tagBGView addSubview:tagView];
            [add addObject:tagView];
        }
        self.tagViews = [add copy];
        self.tagsDrawn = YES;
    }
}


//- (void)didAddSubview:(UIView *)subview {
//    [super didAddSubview:subview];
//    if (!self.trackViewMasked && self.subviews.count == 2) {
//        subview.layer.cornerRadius = self.trackHeight / 2;
//        subview.layer.masksToBounds = YES;
//        self.trackViewMasked = YES;
//    }
//}

@end
