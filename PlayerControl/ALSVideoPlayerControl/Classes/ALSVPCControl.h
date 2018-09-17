//
//  ALSVideoPlayer.h
//  ALSVideoPlayerControl
//
//  Created by Altair on 2018/4/11.
//  Copyright © 2018 Alisports. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALSVPCActions.h"

#define ALSVPC(controlLayerInstance, __protocol__) \
((controlLayerInstance && [controlLayerInstance isKindOfClass:[ALSVPCControl class]])?  \
((id<__protocol__>)([controlLayerInstance control:@protocol(__protocol__)])):nil)

@interface ALSVPCControl : NSObject

- (id)control:(Protocol*)control;

@end
