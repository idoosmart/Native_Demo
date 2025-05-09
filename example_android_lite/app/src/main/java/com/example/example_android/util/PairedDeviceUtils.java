package com.example.example_android.util;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.os.Build;
import android.text.TextUtils;

import com.clj.fastble.logs.LogTool;

import java.lang.reflect.Method;
import java.util.Set;

/**
 * Created by zhouzj on 2018/1/23.
 */

public class PairedDeviceUtils {
    public static boolean isPaired(String macAddress) {
        return getPairedDevice(macAddress) != null;
    }

    public static BluetoothDevice getPairedDevice(String macAddress) {
        if (TextUtils.isEmpty(macAddress)) return null;
        try {
            Set<BluetoothDevice> bluetoothDeviceSet = BluetoothAdapter.getDefaultAdapter().getBondedDevices();
            for (BluetoothDevice device : bluetoothDeviceSet) {
                if (macAddress.equals(device.getAddress())) {
                    return device;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public static BluetoothDevice getPairedDeviceByEndWithString(String suffix) {
        try {
            Set<BluetoothDevice> bluetoothDeviceSet = BluetoothAdapter.getDefaultAdapter().getBondedDevices();
            for (BluetoothDevice device : bluetoothDeviceSet) {
                if (device != null && !TextUtils.isEmpty(device.getAddress()) && device.getAddress().endsWith(suffix)) {
                    return device;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return null;
    }

    public static String getAllPairedDeviceInfo() {
        String pairedInfos = "phone has paired list:\n";
        try {
            Set<BluetoothDevice> bluetoothDeviceSet = BluetoothAdapter.getDefaultAdapter().getBondedDevices();
            for (BluetoothDevice device : bluetoothDeviceSet) {
                if (device != null) {
                    String test = null;
                    pairedInfos += device.getAddress() + "/" + device.getName() + "/" + device.getBondState() + "\n";
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return pairedInfos;
    }

    public static boolean removeBondState(String macAddress) {
        BluetoothDevice device = getPairedDevice(macAddress);
        if (device != null) {
            boolean removeResult = removeBondState(device);
            LogTool.p("PairedDeviceUtils", "removeBondState removeResult : " + removeResult);
            return removeResult;
        }
        return true;
    }

    public static boolean removeBondState(BluetoothDevice device) {
        try {
            LogTool.p("PairedDeviceUtils", "removeBondState: " + device.getBondState());
            Method m = device.getClass().getMethod("removeBond",
                    (Class[]) null);
            m.invoke(device, (Object[]) null);

            return isPaired(device.getAddress());
        } catch (Exception e) {
            LogTool.e("PairedDeviceUtils", e.getMessage());
        }
        return false;
    }


    public static boolean isConnected(BluetoothDevice device) {
        BluetoothAdapter bluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        if (bluetoothAdapter == null) {
            return false;
        }
        //得到BluetoothDevice的Class对象
        Class<BluetoothDevice> bluetoothDeviceClass = BluetoothDevice.class;
        try {//得到连接状态的方法
            Method method = bluetoothDeviceClass.getDeclaredMethod("isConnected", (Class[]) null);
            //打开权限
            method.setAccessible(true);
            return (boolean) method.invoke(device, (Object[]) null);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * 修改系统权限，不然就有些反射被系统限制了
     */
    public static void initSystemPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            return;
        }
        LogTool.e("PairedDeviceUtils", "initSystemPermission......");
        try {
            Method forName = Class.class.getDeclaredMethod("forName", String.class);
            Method getDeclaredMethod = Class.class.getDeclaredMethod("getDeclaredMethod", String.class, Class[].class);
            Class<?> vmRuntimeClass = (Class<?>) forName.invoke(null, "dalvik.system.VMRuntime");
            Method getRuntime = (Method) getDeclaredMethod.invoke(vmRuntimeClass, "getRuntime", null);
            Method setHiddenApiExemptions = (Method) getDeclaredMethod.invoke(vmRuntimeClass, "setHiddenApiExemptions",
                    new Class[]{String[].class});
            Object sVmRuntime = getRuntime.invoke(null);
            setHiddenApiExemptions.invoke(sVmRuntime, new Object[]{new String[]{"L"}});
        } catch (Throwable e) {
            LogTool.e("PairedDeviceUtils", "initSystemPermission.....error.");
        }
    }

    /**
     * 创建绑定，系统的创建绑定不能带参数，默认模式是            TRANSPORT_AUTO 0, 但是bt 连接需要走经典模式，TRANSPORT_BREDR1
     *
     * @param device
     */
    public static void createBond(BluetoothDevice device) {
        try {
            LogTool.p("PairedDeviceUtils", "createBond: " + device);
            Method m = device.getClass().getMethod("createBond",
                    Integer.TYPE);
            m.invoke(device, BluetoothDevice.TRANSPORT_BREDR);

        } catch (Exception e) {
            LogTool.e("PairedDeviceUtils", e.getMessage());
        }
    }
}
