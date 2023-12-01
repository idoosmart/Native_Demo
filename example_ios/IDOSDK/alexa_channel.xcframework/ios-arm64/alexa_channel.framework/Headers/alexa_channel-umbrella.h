#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AlexaChannelImpl.h"
#import "AlexaChannelPlugin.h"
#import "AlexaDownStream.h"
#import "AlexaStreamManager.h"
#import "AlexaUpStream.h"
#import "AlexaChannel.g.h"

FOUNDATION_EXPORT double alexa_channelVersionNumber;
FOUNDATION_EXPORT const unsigned char alexa_channelVersionString[];

