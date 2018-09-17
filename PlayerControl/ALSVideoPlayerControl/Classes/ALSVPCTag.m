//
//  ALSVPCTag.m
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/5/2.
//

#import "ALSVPCTag.h"

@implementation ALSVPCTag

+ (instancetype)tagWithRange:(NSRange)range color:(UIColor *)color {
    ALSVPCTag *tag = [[ALSVPCTag alloc] init];
    tag.range = range;
    tag.color = color;
    return tag;
}


@end
