# =============================================================================
# example_android_lite —— 接入方 App 侧 ProGuard / R8 规则模板
# example_android_lite —— integrator App-side ProGuard / R8 rules template
#
# 参考 example_android；本 Demo 为 Lite（外置 BLE / FastBleLib，无内置
# Based on example_android; this Demo is the Lite variant (external BLE / FastBleLib, no built-in
# flutter_bluetooth）。开启 minifyEnabled 后用于验证 Lite AAR 在 R8 下的行为。
# flutter_bluetooth). With minifyEnabled on, it is used to verify how the Lite AAR behaves under R8.
# 接入方可按下列分段抄到自家 app/proguard-rules.pro，并只打开自己用到的段。
# Integrators can copy the sections below into their own app/proguard-rules.pro and enable only the ones they use.
#
# 说明：
# Description:
# - SDK AAR（protocol_channel / native_channel 等）会通过 consumerProguardFiles
# - SDK AARs (protocol_channel / native_channel, etc.) are merged through consumerProguardFiles
#   自动合并；App 侧勿再写「整包 kotlin.** / android.app.Activity /
#   automatically; the App side must not add global keeps such as 'whole-package kotlin.** / android.app.Activity /
#   io.flutter.**」等全局 keep，否则会拉低 Google Play DEX 优化覆盖率。
#   io.flutter.**' and other global keep rules, otherwise Google Play DEX optimization coverage drops.
# - 本 Demo 直接依赖 flutter_embedding AAR（非 flutter.gradle 全量注入路径）：
# - This Demo depends on the flutter_embedding AAR directly (not the flutter.gradle full-injection path):
#   Embedding JNI 入口靠库内 @Keep + 下方 keepattributes；勿手写整包 keep。
#   Embedding JNI entry points rely on in-library @Keep + the keepattributes below; do not hand-write whole-package keep rules.
# - Zephyr / MCUmgr：keep + dontwarn 已在 native_channel consumer-rules.pro；
# - Zephyr / MCUmgr: keep + dontwarn are already in native_channel consumer-rules.pro;
#   Native AAR（打包态 compileOnly）接入方按需 implementation 'mcumgr-ble:1.5.2'（须 1.5.x）。
#   Native AAR (packaged mode, compileOnly): integrators add implementation 'mcumgr-ble:1.5.2' on demand (requires 1.5.x).
#   Flutter path 默认随库传递，无需再写。
#   Flutter path includes it transitively by default; no need to add it again.
# - Lite 默认无 flutter_bluetooth；若自行接入 Nordic Legacy DFU，见下方 DFU 段。
# - Lite has no flutter_bluetooth by default; if you integrate Nordic Legacy DFU yourself, see the DFU section below.
# =============================================================================

# ---------- 调试栈（Demo 建议打开；正式包可按需关闭）----------
# ---------- Debug stack trace (recommended on for the Demo; can be turned off in release builds) ----------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ---------- 必选：Gson / 反射 / @Keep 元数据 ----------
# ---------- Required: Gson / reflection / @Keep metadata ----------
# SDK Model 与 App 若用 Gson，需保留签名与注解；字段 keep 由 SDK consumer 规则
# SDK Model and App need Signature and annotations kept if they use Gson; field keep rules are covered by the SDK consumer rules
# 中的 com.idosmart.** 覆盖。App 自有 Gson bean 请自行 -keep。
# for com.idosmart.**. For the App's own Gson bean classes, add -keep yourself.
# *Annotation* 亦保证 Embedding 等库的 androidx.annotation.Keep 生效。
# *Annotation* also ensures that Embedding and other libraries' androidx.annotation.Keep takes effect.
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses, EnclosingMethod
-dontwarn com.google.gson.**

# ---------- Flutter Embedding（Native 宿主；勿整包 -keep io.flutter.**）----------
# ---------- Flutter Embedding (Native host; do not blanket -keep io.flutter.**) ----------
# 对齐 Flutter 官方 flutter_proguard_rules.pro 的 dontwarn（本 Demo 不经 flutter.gradle 全量注入）
# Aligned with Flutter's official flutter_proguard_rules.pro dontwarn entries (this Demo does not go through the flutter.gradle full-injection path)
-dontwarn io.flutter.plugin.**
# Embedding 引用 Play Core SplitCompat；未接 Play Feature Delivery 时抑制缺类告警
# Embedding references Play Core SplitCompat; suppress missing-class warnings when Play Feature Delivery is not integrated
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ---------- 必选：本 Demo 直接依赖的 OkHttp / Okio ----------
# ---------- Required: this Demo directly depends on OkHttp / Okio ----------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ---------- 必选：native_channel 传递引用但 flatDir AAR 未带上的可选类 ----------
# ---------- Required: optional classes referenced transitively by native_channel but not bundled in the flatDir AAR ----------
# Alexa 上行等路径引用 commons-io；未单独 implementation 时用 dontwarn 即可
# Alexa upload and similar paths reference commons-io; if it is not added as a separate implementation, dontwarn is enough
# （若业务会走到该路径，请在 build.gradle 增加 commons-io 依赖，而不是仅 dontwarn）。
# (If your business logic reaches that path, edit build.gradle to add the commons-io dependency instead of only dontwarn).
-dontwarn org.apache.commons.io.**
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.**

# ---------- 必选：Lite 外置 BLE（FastBleLib）----------
# ---------- Required: Lite external BLE (FastBleLib) ----------
-keep class com.clj.fastble.** { *; }
-dontwarn com.clj.fastble.**

# =============================================================================
# Nordic Legacy / Secure DFU（no.nordicsemi.android:dfu）
# =============================================================================
# Lite 默认无 flutter_bluetooth。若 App 自行使用 Nordic 传统 DFU，在
# Lite has no flutter_bluetooth by default. If the App itself uses the Nordic legacy DFU, in
# build.gradle 取消注释：
# build.gradle uncomment:
#   implementation 'no.nordicsemi.android:dfu:2.5.0'
# 未集成时保留 -dontwarn，避免其它 AAR 引用 nordicsemi 时 R8 缺类。
# When not integrated, keep -dontwarn so R8 does not miss classes when other AARs reference nordicsemi.
#-keep class no.nordicsemi.android.dfu.** { *; }
-dontwarn no.nordicsemi.android.dfu.**
-dontwarn no.nordicsemi.android.error.**

# =============================================================================
# Nordic Zephyr / MCUmgr DFU（no.nordicsemi.android:mcumgr-ble:1.5.2）
# =============================================================================
# keep + dontwarn 已由 native_channel AAR 的 consumer-rules.pro 自动合并；App 勿重复。
# keep + dontwarn are already merged automatically from the native_channel AAR consumer-rules.pro; do not repeat them in the App.
# Native AAR 打包态为 compileOnly，使用 startDFU 时在 build.gradle 声明（须 1.5.x）：
# Native AAR packaged mode uses compileOnly; when using startDFU, declare it in build.gradle (requires 1.5.x):
#   implementation 'no.nordicsemi.android:mcumgr-ble:1.5.2'

# =============================================================================
# 其它平台 OTA（按需）
# Other platform OTA (on demand)
# =============================================================================
#-keep class com.realsil.** { *; }
#-dontwarn com.realsil.**
