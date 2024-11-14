//
//  TestOC.m
//  IDODemo
//
//  Created by hc on 2024/1/9.
//

#import "TestOC.h"

@implementation TestOC

+ (void)initialize {
    sdkoc = [IDOSDK shared];
}

- (void)testCommand {
    
    [Cmdoc getBtName:^(CmdError * _Nonnull err, NSString * _Nullable btName) {
        if (err.isOK) {
            NSLog(@"获取成功 btName:%@", btName);
        }else {
            NSLog(@"btName 获取失败");
        }
    }];
    
    [Cmdoc getBatteryInfo:^(CmdError * _Nonnull err, IDOBatteryInfoModel * _Nullable obj) {
        if (err.isOK) {
            NSLog(@"电量信息获取成功 obj:%@", obj);
        }else {
            NSLog(@"电量信息获取失败");
        }
    }];
    
    [sdkoc.device refreshDeviceInfoWithForced:true completion:^(BOOL rs) {
        NSLog(@"手动刷新设备信息：%d", rs);
    }];
    
}

- (void)testSync {
    [sdkoc.syncData startSyncWithFuncProgress:^(double progress) {
        NSLog(@"Progress: %.2f%%", progress);
    } funcData:^(enum IDOSyncDataType type, NSString * _Nonnull jsonStr, NSInteger errCode) {
        if (errCode == 0) {
            NSLog(@"Sync type: %ld json:%@", (long)type, jsonStr);
        }else {
            NSLog(@"Sync type: %ld Error code:%ld", (long)type, (long)errCode);
        }
    } funcCompleted:^(NSInteger errorCode) {
        if (errorCode == 0) {
            NSLog(@"Sync done");
        }else {
            NSLog(@"Sync failure, error:%ld", errorCode);
        }
        
    }];
    
}


@end
