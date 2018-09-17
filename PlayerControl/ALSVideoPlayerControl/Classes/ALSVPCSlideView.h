//
//  ALSVPCProgressView.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/27.
//

#import <UIKit/UIKit.h>
#import "ALSVPCTag.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALSVPCSlideView : UISlider

@property (nonatomic, copy, nullable) NSArray <ALSVPCTag *>* tags;

@property (nonatomic, copy, readonly, nullable) NSArray <ALSVPCTag *>* renderingTags;   //sorted

@property (nonatomic, readonly) NSInteger currentTagIndex;  //index of tag where thumb at, if not in tag area, returns -1.
@property (nonatomic, readonly) NSInteger nextTagIndex;  //index of next near tag where thumb at, if no next, returns -1.
@property (nonatomic, readonly) NSInteger previousTagIndex;  //index of previous tag where thumb at, if no previous, returns -1.

@property (nonatomic, assign) CGFloat trackHeight;  //min is 1.0, default is 2.0;

- (void)slideToNextTagAnimated:(BOOL)animated;
- (void)slideToPreviousTagAnimated:(BOOL)animated;
- (void)slideToTagAtIndex:(NSInteger)index animated:(BOOL)animated;    //if tag at index not found, nothing happened

@end

NS_ASSUME_NONNULL_END
