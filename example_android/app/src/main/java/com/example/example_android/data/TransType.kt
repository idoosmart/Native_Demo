package com.example.example_android.data

import com.idosmart.protocol_channel.sdk

/**
 * 文件传输类型枚举，参考 iOS TransferFileVC.swift 中的 TransType
 * File transfer type enum, mirrors iOS TransferFileVC.swift and its TransType
 * 统一管理各传输类型允许的文件后缀和提示信息
 * Centrally manages the allowed file extensions and hint messages for each transfer type
 */
enum class TransType {
    MP3,
    WALLPAPER,
    CONTACT,
    WATCH_FACE,
    OTA,
    APP,
    GPS,
    GPS_FW;

    fun title(): String = when (this) {
        MP3 -> "Transfer Music Upload music"
        WALLPAPER -> "Wallpaper watch face"
        CONTACT -> "Upload contacts"
        WATCH_FACE -> "Watch face upgrade"
        OTA -> "Firmware upgrade"
        APP -> "App"
        GPS -> "GPS"
        GPS_FW -> "GPS Firmware"
    }

    /** 允许的文件后缀列表 */
    /** List of allowed file extensions */
    fun allowedExtensions(): List<String> = when (this) {
        MP3 -> listOf("mp3")
        WALLPAPER -> listOf("png", "jpg", "jpeg")
        CONTACT -> listOf("json")
        WATCH_FACE -> emptyList()
        OTA -> when (sdk.device.platform) {
            98, 99 -> listOf("zip")
            else -> listOf("zip", "bin", "fw")
        }
        APP -> listOf("app")
        GPS -> listOf("dat")
        GPS_FW -> listOf("gps")
    }

    /** 文件选择提示 */
    /** File selection hint */
    fun fileHint(): String {
        val exts = allowedExtensions().joinToString(" / ") { ".$it" }
        return when (this) {
            MP3 -> "Select music file ($exts)\nNote: Only 44.1k sample rate"
            WALLPAPER -> "Select wallpaper image ($exts)"
            CONTACT -> "Select contact file ($exts)"
            OTA -> "Select firmware file ($exts)"
            APP -> "Select app file ($exts)"
            GPS -> "Select EPO file ($exts)"
            GPS_FW -> "Select GPS firmware ($exts)"
            WATCH_FACE -> ""
        }
    }

    /** OTA 醒目警告提示 */
    /** OTA prominent warning message */
    fun otaWarning(): String {
        return "注意：需使用正确的固件文件，错误的固件包会导致安装失败，严重的会导致设备变砖无法开机！\nWARNING: Use the correct firmware file. An incorrect firmware package may cause installation failure or brick the device! / Note: use the correct firmware file. A wrong firmware package will fail to install and may even brick the device so it cannot boot!\nWARNING: Use the correct firmware file. An incorrect firmware package may cause installation failure or brick the device!"
    }

    /** 校验文件后缀是否合法 */
    /** Check whether the file extension is valid */
    fun isExtensionValid(fileName: String): Boolean {
        val allowed = allowedExtensions()
        if (allowed.isEmpty()) return true
        val ext = fileName.substringAfterLast('.', "").lowercase()
        return allowed.any { it.equals(ext, ignoreCase = true) }
    }
}
