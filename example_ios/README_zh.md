# IDODemo 使用说明

介绍Demo、SDK说明及注意事件
IDOSDK-full和IDOSDK-lite根据实际场景二选一

SDK API文档：https://idoosmart.github.io/Native_GitBook/zh/



> ##### IDOSDK-full
>
> 完整SDK，内置蓝牙库，开箱即用
>
> ##### IDOSDK-lite
>
> 简版SDK，移除蓝牙库相关依赖，与外部蓝牙库桥接后使用，其它与full无区别



### IDODemo-Manual

手动集成SDK到IDODemo-Manual项目，该项目使用Target区分两种IDOSDK使用方式

IDODemoFull - 使用内置蓝牙库

IDODemoLite - 使用自定义蓝牙库方式

使用前执行脚本拉取对应的SDK:

```shell
cd IDODemo-Manual
sh clone_sdk.sh
```

打开 `IDODemo.xcworkspace`



### IDODemo-Cocoapods

使用Cococapods 集成SDK到 IDODemo-Manual项目，使用Target区分两种IDOSDK使用方式

IDODemoFull - 使用内置蓝牙库

IDODemoLite - 使用自定义蓝牙库方式

使用前执行脚本拉取对应的SDK:

```shell
cd IDODemo-Cocoapods
pod install
```

打开 `IDODemo.xcworkspace`
