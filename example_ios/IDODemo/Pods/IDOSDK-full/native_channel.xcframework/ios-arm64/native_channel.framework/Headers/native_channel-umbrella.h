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
#import "native_channel.h"
#import "Alexa.g.h"
#import "Sifli.g.h"
#import "IDOUpdateSFManager.h"

FOUNDATION_EXPORT double native_channelVersionNumber;
FOUNDATION_EXPORT const unsigned char native_channelVersionString[];

