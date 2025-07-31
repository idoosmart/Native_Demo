# Update log

IDOSDK version update log



## Resources

Document: [Chinese](https://idoosmart.github.io/Native_GitBook/zh/) | [English](https://idoosmart.github.io/Native_GitBook/en/)

Demo: [Gitee](https://gitee.com/idoosmart/Native_Demo) | [Github](https://github.com/idoosmart/Native_Demo)

Android SDK: [Gitee](https://gitee.com/idoosmart/android_sdk) | [Github](https://github.com/idoosmart/android_sdk)

iOS SDK： [Gitee](https://gitee.com/idoosmart/ios_sdk_full) | [Github](https://github.com/idoosmart/ios_sdk_full)



## 4.4.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/31</span>

##### Update content:

- Support 16 KB page sizes (android)；
- *Upgrade flutter engine version [to upgrade](http://idoosmart.github.io/Native_GitBook/en/doc/IDOSDK.html?h=Use%20SDK%20version%204.4.0%20and%20above)



## 4.3.1<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/11</span>

##### Update content:

- bugfix;
- adapt new features;



## 4.3.1<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/11</span>

##### Update content:

- bugfix;
- adapt new features;



## 4.3.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/07/03</span>

##### Update content:

- bugfix;
- Adapt new functions;



## 4.2.14<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/06/17</span>

##### Update content:

- bugfix;
- Adapt new functions;



## 4.2.13<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/06/10</span>

##### Update content:

- bugfix;
- Adapt new functions;



## 4.2.11<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### Update content:

- bugfix;
- Adapt new functions;



## 4.2.10<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### Update content:

- bugfix;



## 4.2.9<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### Update content:

- Adapt new functions;
- Optimize some functions;



## 4.2.8<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/18</span>

##### Update content:

- Added APP basic information settings (only for devices that support this function);
- Optimized some functions;



## 4.2.7<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/03/17</span>

##### Update content:

- Remove unnecessary background location permission configuration of Bluetooth library (Android);
- Automatic EPO upgrade adds hot start parameter update request every 30 minutes (valid when automatic EPO upgrade is enabled);
- Optimize some functions;



## 4.2.6<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/02/25</span>

##### Update content:

- Fix the abnormal data parsing problem returned by Cmds.getSportTypeV3();
- Adjust the timeout of single data synchronization (10s -> 30s);



## 4.2.5 (Android only) <span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/02/11</span>

##### Update content:

- Fixed the issue that the status is called back twice after the BT pairing is canceled.



## 4.2.5 (iOS only) <span style="font-size:15px;color:gray;">&nbsp;&nbsp;2025/01/17</span>

##### Update content:

- Added internationalization support to the Demo.

- Fixed the issue of dynamic/static message icons and the redirection problem after failure to fetch on the notification list page in the Demo.

- Resolved the issue where the markDisconnect method was not being called when Bluetooth was turned off.

  

## 4.2.4<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/12/28</span>

##### Update content:

- Improve the app to start outdoor cycling, and add mobile phone GPS signal and distance parameters;

- Add dynamic message icon and notification switch setting complete example (iOS);

- Add static message notification switch complete example (iOS);



## 4.2.3<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/12/05</span>

##### Update content:

- Add future time data cleaning logic to the heart rate data of the day of data synchronization (only for some old devices);

- Adjust the data synchronization timeout to 120 seconds (only for some old devices)

  

## 4.2.2<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/28</span>

##### Update content:

- Added update of deviceState delegatge callback when Bluetooth is turned off in the phone system settings (iOS);

  

## 4.2.1<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/19</span>

##### Update content:

- Remove the built-in tencent icon (Android);
- Modify some parameters in the IDOHeartModeParamModel construction method to be optional;



## 4.2.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/14</span>

##### Updates:

- Compatible with Android14 (Android);

- Solve framework signature problem (iOS);

- Adjust the management method of icon_assets.bundle resource package (pay attention when manually integrating) (iOS);



## 4.1.0<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/11/07</span>

##### Update content:

- Added new function table;

- Solved the problem of data synchronization status not being refreshed;

- Solved the problem of Android non-main thread call exception;



## 4.0.46<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/10/25</span>

##### Update content:

- Fixed the problem of converting world clock setting interface parameter entity to json (android);

- Added support for specifying priority in the alarm interface;



## 4.0.45<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/10/14</span>

##### Update content:

- Upgrade the dial-related so library of the specified platform (android);

- Add icon_assets.bundle resource file loading exception capture (iOS);

- Fix some known bugs;



## 4.0.44<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/09/12</span>

##### Update content:

- Upgrade the OTA-related so library of the specified platform (android);

- Fix the hot start parameter setting;



## 4.0.43<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/09/05</span>

##### Update content:

- Optimize data synchronization and block invalid data return;

- The epo upgrade retry function is adjusted to retry every step, and the number of times can be specified;

- Add thread safety processing to the interface and support non-main thread calls;

## 4.0.42<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/26</span>

##### Update content:

- Add wind attribute windForce to v3 weather entity;

- Optimize file transfer speed;

- Fix the problem that single data synchronization cannot synchronize data;



## 4.0.41<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/16</span>

##### Update content:

- Add EPO upgrade management interface;



## 4.0.40<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/08/09</span>

##### Update content:

- Added acc algorithm log and gps algorithm log file acquisition interface;

- Built-in EPO automatic update function (supported by some devices);

## 4.0.39 (iOS only)<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/22</span>

##### Update content:

- Fixed the problem of incomplete return of default app application information for loading cache (ios);



## 4.0.38<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/22</span>

##### Update content:

- Added interface for setting default app application information list (ios);



## 4.0.37<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/17</span>

##### Update content:

- Added BT connection status notification (android);

- Open access to audio sampling rate interface;

- Fixed issues related to message icons;



## 4.0.36<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/16</span>

##### Update content:

- Fixed the problem that IDOBleDeviceModel read-only attributes cannot be assigned (android);

- Adjusted some attributes of the music entity class to optional attributes



## 4.0.35<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/11</span>

##### Update content:

- Add mini program operation interface (get version, start mini program);



## 4.0.34<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/04</span>

##### Update content:

- Add mini program upgrade function;



## 4.0.33<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/07/01</span>

##### Update content:

- Adapt to new BLE service characteristics;



## 4.0.32<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/06/26</span>

##### Update content:

- Solve the problem of abnormal reading of default message icon;



## 4.0.31<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/06/20</span>

##### Update content:

- Adapt to OTA upgrade of new devices;



## 4.0.30<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/05/30</span>

##### Update content:

- Add synchronization interface for data of specified type;

- Add sn, btName, gpsPlatform fields to device information;

- Added interfaces for obtaining smart heart rate mode, obtaining blood oxygen switch, obtaining pressure switch, and setting the default message application list;
- Fixed the problem of invalid call to BT pairing (Android)
- Fixed the problem of flash back when obtaining alarm due to abnormal data returned by firmware
- Fixed the problem of being unable to modify device volume



## 4.0.29<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/05/14</span>

##### Update content:

- Solve some package conflicts (Android)
- Fixed the problem of real-time motion display failure (Android)
- Fixed the problem of real-time motion agent not being called back (iOS)
- Removed path_provider_xx third-party library



## 4.0.28<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/24</span>

##### Update content:

- The keyword enum in the package name is replaced with enums (enum is a reserved word in Java) (Android)
- Device binding successfully adds the logic of clearing v3 health data cache



## 4.0.27<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/24</span>

##### Update content:

- Fix the time zone and week parameter errors in the time setting interface



## 4.0.26<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/18</span>

##### Update content:

- Supplementary interface: Get unit, set hot start parameters, get spp mtu length
- Fix Bluetooth library logging issues



## 4.0.25<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/11</span>

##### Update content:

- Fix the problem of weather setting failure



## 4.0.24<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/10</span>

##### Update content:

- Supplement [Quick Message Reply](https://idoosmart.github.io/Native_GitBook/zh/doc/logicDescription/quickMsgReplyList.html), default quick message reply list command (android)

- Adapt the unbinding function
- Fix the abnormal parameter problem of some command interfaces of iOS Objective-C (iOS)



## 4.0.23<span style="font-size:15px;color:gray;">&nbsp;&nbsp;2024/04/03</span>

##### Update content:

- Add weekly repetition parameters to the pressure switch interface entity

- Fix the json serialization problem of setting the notification center (android)

- Add 20 bytes to the reply data of the non-v3 protocol in the protocol library



## 4.0.22<span style="font-size:12px;">&nbsp;&nbsp;2024/03/29</span>

##### Update content:

- Fix some json parsing exceptions
- Fix the parsing problem of alarm and reminder weekly reminders
- Adjust the entity attributes to read and write (iOS)



## 4.0.21<span style="font-size:12px;">&nbsp;&nbsp;2024/03/26</span>

##### Update content:

- Solve some json field parsing issues
- Add start/end photo taking interface (Android)



## 4.0.20<span style="font-size:12px;">&nbsp;&nbsp;2024/03/21</span>

##### Update content:

- Add Bluetooth library log export interface

- Improve the interface for canceling the current binding request

- Fix some field errors of weather entity (iOS)



## 4.0.19<span style="font-size:12px;">&nbsp;&nbsp;2024/03/08</span>

##### Update content:

- Add APP to send pairing result command interface

- Add APP to send binding result method interface

- Adapt to the binding process requirements of customized projects



## 4.0.18 (android only)

##### Update content:

- Public device information acquisition interface



## 4.0.18 (iOS only)

##### Update content:

- Adapt OC (supplement swift classes optional attributes that OC cannot adapt)



## 4.0.17

##### Update content:

- Supplementary interface:

- Get the default sport type - getDefaultSportType

- Get the default sport type V3 - getSportTypeV3

- Get the BT connected phone model - getBtConnectPhoneModel

- Set a water drinking reminder - setDrinkWaterRemind

- Set a menstrual period reminder - setMenstruationRemind

- Set a pressure switch - setStressSwitch

- Set the voice assistant switch - setVoiceAssistantOnOff

- Set the do not disturb mode - setNotDisturb

- Set the menu list - setMenuList

- Set the sport type sort - setSportSortV3

- Set the firmware call quick reply switch - setCallQuickReplyOnOff

- Add version information (sdk.info.versionLib)

##### iOS:

- Add proxy method:

```swift
/// Query the binding status based on the device macAddress
func checkDeviceBindState(macAddress: String) -> Bool
```

- Adapt to OC

##### Android:

- Add proxy method:

```kotlin
/// Query the binding status based on the device macAddress
func checkDeviceBindState(macAddress: String): Boolean
```
