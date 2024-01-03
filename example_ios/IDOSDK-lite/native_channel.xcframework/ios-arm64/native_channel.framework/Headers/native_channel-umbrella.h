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
#import "AlexaDownStream.h"
#import "AlexaStreamManager.h"
#import "AlexaUpStream.h"
#import "Alexa.g.h"

FOUNDATION_EXPORT double native_channelVersionNumber;
FOUNDATION_EXPORT const unsigned char native_channelVersionString[];

