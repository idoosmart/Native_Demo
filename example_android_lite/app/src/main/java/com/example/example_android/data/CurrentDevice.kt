package com.example.example_android.data

import com.clj.fastble.data.BleDevice

object CurrentDevice {
    lateinit var bleDevice: BleDevice

    val uuid_service: String = "00000aF0-0000-1000-8000-00805f9b34fb"
    val uuid_ty = "0000FD50-0000-1000-8000-00805f9b34fb"
    val uuid_characteristic_notify: String = "00000aF7-0000-1000-8000-00805f9b34fb"
    val uuid_characteristic_write: String = "00000aF6-0000-1000-8000-00805f9b34fb"
    val uuid_dfu = "00001530-1212-efde-1523-785feabcd123"
    val uuid_dfu_ef59 = "0000fe59-0000-1000-8000-00805f9b34fb"
}