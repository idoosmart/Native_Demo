//
//  TestOC.h
//  IDODemo
//
//  Created by hc on 2024/1/9.
//

#import <Foundation/Foundation.h>

#import <protocol_channel/protocol_channel-Swift.h>

static id<IDOSdkInterface> _Nullable sdkoc;

NS_ASSUME_NONNULL_BEGIN


@interface TestOC : NSObject


/// 测试基础指令
- (void)testCommand;

/// 测试数据同步
- (void)testSync;

@end

NS_ASSUME_NONNULL_END
