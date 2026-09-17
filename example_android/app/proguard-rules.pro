# =============================================================================
# example_android —— 接入方 App 侧 ProGuard / R8 规则模板
#
# 本 Demo 开启 minifyEnabled，用于验证 IDO Native SDK AAR 在 R8 下的行为。
# 接入方可按下列分段抄到自家 app/proguard-rules.pro，并只打开自己用到的段。
#
# 说明：
# - SDK AAR（protocol_channel / flutter_bluetooth / native_channel）会通过
#   consumerProguardFiles 自动合并；App 侧勿再写「整包 kotlin.** /
#   android.app.Activity / io.flutter.**」等全局 keep，否则会拉低 Google Play
#   DEX 优化覆盖率。
# - 本 Demo 直接依赖 flutter_embedding AAR（非 flutter.gradle 全量注入路径）：
#   Embedding JNI 入口靠库内 @Keep + 下方 keepattributes；勿手写整包 keep。
# - Zephyr / MCUmgr：keep + dontwarn 已在 native_channel consumer-rules.pro；
#   Native AAR（打包态 compileOnly）接入方按需 implementation 'mcumgr-ble:1.5.2'（须 1.5.x）。
#   Flutter path 默认随库传递，无需再写。
# =============================================================================

# ---------- 调试栈（Demo 建议打开；正式包可按需关闭）----------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# ---------- 必选：Gson / 反射 / @Keep 元数据 ----------
# SDK Model 与 App 若用 Gson，需保留签名与注解；字段 keep 由 SDK consumer 规则
# 中的 com.idosmart.** 覆盖。App 自有 Gson bean 请自行 -keep。
# *Annotation* 亦保证 Embedding 等库的 androidx.annotation.Keep 生效。
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses, EnclosingMethod
-dontwarn com.google.gson.**

# ---------- Flutter Embedding（Native 宿主；勿整包 -keep io.flutter.**）----------
# 对齐 Flutter 官方 flutter_proguard_rules.pro 的 dontwarn（本 Demo 不经 flutter.gradle 全量注入）
-dontwarn io.flutter.plugin.**
# Embedding 引用 Play Core SplitCompat；未接 Play Feature Delivery 时抑制缺类告警
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ---------- 必选：本 Demo 直接依赖的 OkHttp / Okio ----------
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ---------- 必选：native_channel 传递引用但 flatDir AAR 未带上的可选类 ----------
# Alexa 上行等路径引用 commons-io；未单独 implementation 时用 dontwarn 即可
# （若业务会走到该路径，请在 build.gradle 增加 commons-io 依赖，而不是仅 dontwarn）。
-dontwarn org.apache.commons.io.**
-dontwarn org.slf4j.impl.StaticLoggerBinder
-dontwarn org.slf4j.**

# =============================================================================
# Nordic Legacy / Secure DFU（no.nordicsemi.android:dfu）
# =============================================================================
# 使用条件：build.gradle 中取消注释
#   implementation 'no.nordicsemi.android:dfu:2.5.0'
# flutter_bluetooth AAR consumer 已含 keep + dontwarn；下列为兜底（未合并到
# 新 AAR / flatDir 旧包时仍可编过）。未集成时保留 -dontwarn 即可。
#-keep class no.nordicsemi.android.dfu.** { *; }
#-dontwarn no.nordicsemi.android.dfu.**
#-dontwarn no.nordicsemi.android.error.**

# =============================================================================
# Nordic Zephyr / MCUmgr DFU（no.nordicsemi.android:mcumgr-ble:1.5.2）
# =============================================================================
# keep + dontwarn 已由 native_channel AAR 的 consumer-rules.pro 自动合并；App 勿重复。
# Native AAR 打包态为 compileOnly，使用 startDFU 时在 build.gradle 声明（须 1.5.x）：
#   implementation 'no.nordicsemi.android:mcumgr-ble:1.5.2'

# =============================================================================
# 其它平台 OTA（按需）
# =============================================================================
# 未使用 Realtek / Sifli 等路径时无需 keep；若 App 直接反射相关类再补充。
#-keep class com.realsil.** { *; }
#-dontwarn com.realsil.**
