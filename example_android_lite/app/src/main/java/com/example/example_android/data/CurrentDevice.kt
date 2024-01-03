package com.example.example_android.data

import com.clj.fastble.data.BleDevice

object CurrentDevice {
    lateinit var bleDevice:BleDevice

     val uuid_service:String = "00000aF0-0000-1000-8000-00805f9b34fb"
     val uuid_characteristic_notify:String = "00000aF7-0000-1000-8000-00805f9b34fb"
     val uuid_characteristic_write:String = "00000aF6-0000-1000-8000-00805f9b34fb"
}