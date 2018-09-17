//
//  ALSVPCTag.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/5/2.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface ALSVPCTag : NSObject

@property (nonatomic, assign) NSRange range;

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, copy, nullable) NSDictionary *userInfo;

+ (instancetype)tagWithRange:(NSRange)range color:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
