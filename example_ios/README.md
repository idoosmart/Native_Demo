# IDODemo Instructions

Introduction to Demo, SDK description and events to note
Choose between IDOSDK-full and IDOSDK-lite according to the actual scenario

SDK API documentation: https://idoosmart.github.io/Native_GitBook/zh/

> ##### IDOSDK-full
>
> Complete SDK, built-in Bluetooth library, ready to use
>
> ##### IDOSDK-lite
>
> Simple SDK, removes Bluetooth library related dependencies, bridges with external Bluetooth library, and is no different from full

### IDODemo-Manual

Manually integrate SDK into IDODemo-Manual project, which uses Target to distinguish two ways to use IDOSDK

IDODemoFull - Use built-in Bluetooth library

IDODemoLite - Use custom Bluetooth library

Execute script to pull corresponding SDK before use:

```shell
cd IDODemo-Manual
sh clone_sdk.sh
```

Open `IDODemo.xcworkspace`

### IDODemo-Cocoapods

Use Cococapods to integrate SDK into IDODemo-Manual project, and use Target to distinguish two ways of using IDOSDK

IDODemoFull - Use built-in Bluetooth library

IDODemoLite - Use custom Bluetooth library

Execute the script to pull the corresponding SDK before use:

```shell
cd IDODemo-Cocoapods
pod install
```

Open `IDODemo.xcworkspace`
