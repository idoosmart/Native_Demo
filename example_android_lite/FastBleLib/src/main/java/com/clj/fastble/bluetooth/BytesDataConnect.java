package com.clj.fastble.bluetooth;

import android.annotation.SuppressLint;
import android.bluetooth.BluetoothGatt;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattService;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;

import com.clj.fastble.data.BleDevice;
import com.clj.fastble.logs.ConnectConstants;
import com.clj.fastble.logs.LogTool;
import com.clj.fastble.utils.HexUtil;

import java.lang.reflect.Field;
import java.util.LinkedList;
import java.util.UUID;

/**
 * Created by asus on 2018/1/17.
 */

abstract class BytesDataConnect {

    private static final int WHAT_SEND_NO_ANSWER_TIMEOUT = 1;
    private static final int WHAT_SEND_ERROR = 2;

    private static final int WHAT_SEND_Next = 3;

    /**
     * 发送过去之后，无响应的超时时间
     */
    private static final long TIME_SEND_TIMEOUT = 2 * 60 * 1000;

    private static final int MAX_CMD_QUEUE_SIZE = 20;
    /**
     * 待发送数据命令 队列
     */
    private LinkedList<ByteDataRequest> mCmdDataQueue = new LinkedList<>();

    private final Object mLock = new Object();

    ByteDataRequest currentByteDataRequest;
    /**
     * 是否正在发送数据
     */
    private boolean mIsSendingCmdData = false;

    /**
     * 是否正在重发数据
     */
    private boolean mIsReSendData = false;
    /**
     * 连续写入失败的次数
     */
    private int mWriteDataFailedCount = 0;
    private int mWriteDataFailedMax = 20;

    private BluetoothGattCharacteristic mWriteNormalGattCharacteristic;
    private BluetoothGattCharacteristic mWriteHealthGattCharacteristic;

    protected String uuid_service;
    protected String uuid_write;

    private Handler mHandler = new Handler(Looper.getMainLooper()) {
        @Override
        public void handleMessage(Message msg) {
            if (msg.what == WHAT_SEND_NO_ANSWER_TIMEOUT && mIsSendingCmdData) {
                mIsSendingCmdData = false;
                mWriteDataFailedCount++;
                if (mWriteDataFailedCount > mWriteDataFailedMax) {
                    LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] last send out time, mCmdDataQueue.size() > 20, clear and " +
                            "disconnect");
                    clearQueueAndDisconnect();
                } else {
                    LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] no respond on last cmd, send next ...");
                    sendNextCmdData();
                }
            } else if (msg.what == WHAT_SEND_ERROR) {
                LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send error  delay send ...");
                mIsSendingCmdData = false;
                sendNextCmdData();
            } else if (msg.what == WHAT_SEND_Next) {
                sendNextCmdData();
            }
        }
    };

    protected boolean isCanSendData() {
        return true;
    }

    protected void clearQueueAndDisconnect() {
        LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] clearQueueAndDisconnect");
        mCmdDataQueue.clear();
    }

//    private void handleWriteFailedStatus(){
//        mIsSendingCmdData = false;
//        if (mCmdDataQueue.size() > MAX_CMD_QUEUE_SIZE){
//            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] handleWriteFailedStatus, mCmdDataQueue.size() > 10, clear and
//            disconnect");
//            clearQueueAndDisconnect();
//        }else {
//            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] handleWriteFailedStatus, send next ...");
//            sendNextCmdData();
//        }
//    }

    private synchronized void handleFileTranDataFailedStatus(byte[] failedData) {
        if (!isCanSendData()) {
            mIsReSendData = false;
            mWriteDataFailedCount = 0;
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] handleWriteFailedStatus(), isCanSendData = false. send failed");
            return;
        }

        mWriteDataFailedCount++;
        if (mWriteDataFailedCount > mWriteDataFailedMax) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] handleWriteFailedStatus, mSendFailedCount > 20, clear and disconnect");
            clearQueueAndDisconnect();
            mIsReSendData = false;
            mWriteDataFailedCount = 0;
            return;
        }

        //有的时候写入过快，会导致失败，所以这里重发
        //重发时必须要保证顺序不能变（像文件传输相关命令，不能错乱，错乱了就会导致传输失败）
        //只重发“文件传输相关的命令” + Alexa语音命令
        if (isFileTranCmd(failedData) || isSendAlexaVoiceCmd(failedData)) {
            synchronized (mLock) {
                mIsReSendData = true;
                mCmdDataQueue.addFirst(currentByteDataRequest);
                LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] isFileTranCmd  mIsReSendData:" + mIsReSendData);
                resendData(failedData);
            }
        } else {
            //出现写入error 的时候延时发送指令
            mHandler.sendEmptyMessageDelayed(WHAT_SEND_ERROR, 1000);

        }
    }

    private synchronized void sendNextCmdData() {
        if (mIsSendingCmdData) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] sendNextCmdData is ing");
            return;
        }

        if (mIsReSendData) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] retrySendData is ing");
            return;
        }
        if (mCmdDataQueue.size() == 0) {
            return;
        }
        mIsSendingCmdData = true;
        currentByteDataRequest = getDataFromQueue();
        if (currentByteDataRequest == null || currentByteDataRequest.getSendData() == null) {
            //没有升级的时候才发送next ,如果在升级就不用发了，不然上面handler error出发了就死循环
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] sendNextCmdData data is null|| siche update");
            mIsSendingCmdData = false;
            sendNextCmdData();
            return;
        }
        LogTool.p(ConnectConstants.LOG_TGA,
                "[BytesDataConnect] send => " + HexUtil.formatHexString(currentByteDataRequest.getSendData(), true));
        if (!isCanSendData()) {
            mIsSendingCmdData = false;
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send(), isCanSendData = false. send failed");
            return;
        }
        sendData();
        //    sendDataDelayTime = CommonUtils.getSendDataDelayTime();
  /*     if(sendDataDelayTime==0){
           sendData(data);
           dataAddToRecord(data);
       }else {
           mHandler.postDelayed(new Runnable() {
               @Override
               public void run() {
                   sendData(data);
                   dataAddToRecord(data);
               }
           },sendDataDelayTime);
       }*/


//        boolean result = writeBytes(data);
//        if (!result){
//            handleWriteFailedStatus(data);
//            return;
//        }
//        //只要有一次写入成功，就清零
//        mWriteDataFailedCount = 0;
//
//        if (isNoNeedWaitResponseCmd(data)){
//            mIsSendingCmdData = false;
//            sendNextCmdData();
//        }else {
//            mIsSendingCmdData = true;
//            mHandler.sendEmptyMessageDelayed(WHAT_SEND_NO_ANSWER_TIMEOUT, TIME_SEND_TIMEOUT);
//        }

    }


    //从队列拿数据
    private ByteDataRequest getDataFromQueue() {
        synchronized (mLock) {
            return mCmdDataQueue.poll();
        }
    }


    private void resendData(final byte[] data) {
        //post到队列里，延时一会
        mHandler.postDelayed(new Runnable() {
            @Override
            public void run() {
                LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] retry send => " + HexUtil.formatHexString(data, true));
                mIsReSendData = false;
                mIsSendingCmdData = false;
                sendNextCmdData();
            }
        }, 300);

    }

    private void sendData() {
        boolean result = writeBytes();
        if (!result) {
//            if (isFileTranCmd(data)) {
//                handleFileTranDataFailedStatus(data);
//            }else {
//                mIsSendingCmdData = false;
//                sendNextCmdData();
//            }

            handleFileTranDataFailedStatus(currentByteDataRequest.getSendData());
            return;
        }
        //只要有一次写入成功，就清零
        mWriteDataFailedCount = 0;
        //只要重发(写入)没有成功，就不会走到这里来
        mIsReSendData = false;
        LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] mIsReSendData " + mIsReSendData);
/*        if (isNoNeedWaitResponseCmd(data)){
            mIsSendingCmdData = false;
            sendNextCmdData();
        }else {*/
        mHandler.sendEmptyMessageDelayed(WHAT_SEND_NO_ANSWER_TIMEOUT, TIME_SEND_TIMEOUT);
        //  }
    }

    @SuppressLint("MissingPermission")
    private boolean writeBytes() {
        final BluetoothGattCharacteristic characteristic = getGattWriteCharacteristic();
        LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send() platform:" + currentByteDataRequest.getPlatform());
        if (characteristic != null && (BluetoothGattCharacteristic.PROPERTY_WRITE & characteristic.getProperties()) > 0) {
            characteristic.setValue(currentByteDataRequest.getSendData());

            if (isNoNeedWaitResponseCmd(currentByteDataRequest.getSendData())) {
                characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_NO_RESPONSE);
            } else {
                characteristic.setWriteType(BluetoothGattCharacteristic.WRITE_TYPE_DEFAULT);
            }
        } else {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send(), characteristic error!");
            return false;
        }

        int properties = characteristic.getProperties();

        if ((properties & 0xC) == 0) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send(), characteristic.properties error!");
            return false;
        }

        boolean result = false;
        try {
            result = getRealGatt().writeCharacteristic(characteristic);//之前的写法，当读写操作频繁时，容易报 [BytesDataConnect] send(),
            if (!result) {
                LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send(), writeCharacteristic() error!");
            }
        } catch (Exception e) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] send(), writeCharacteristic() Exception!");
        }

        return result;
    }

    protected abstract BluetoothGatt getRealGatt();

    protected abstract BluetoothGattCharacteristic getGattWriteCharacteristic();

    private BluetoothGattCharacteristic getGattCharacteristic(BluetoothGatt gatt) {
        if (mWriteNormalGattCharacteristic == null) {
            mWriteNormalGattCharacteristic = getCharacteristic(gatt, UUID.fromString(uuid_service), UUID.fromString(uuid_write));
        }

        return mWriteNormalGattCharacteristic;
    }

    private static BluetoothGattCharacteristic getCharacteristic(BluetoothGatt gatt, UUID serviceId, UUID characteristicId) {
        if (gatt == null) {
            return null;
        }
        BluetoothGattService service = gatt.getService(serviceId);
        if (service == null) {
            return null;
        }
        BluetoothGattCharacteristic c = service.getCharacteristic(characteristicId);
        return c;
    }

    private boolean isNoNeedWaitResponseCmd(byte[] cmd) {
        //针对Agps文件的协议、Alexa语音
        return (cmd[0] & 0xff) == 0xD1 || (cmd[0] & 0xff) == 0x13;
    }

    /**
     * 是否为 文件传输的命令
     *
     * @param cmd
     * @return
     */
    private boolean isFileTranCmd(byte[] cmd) {
        return (cmd[0] & 0xff) == 0xD1;
    }

    /**
     * 是否为 下发Alexa语音的命令、设备获取登录状态
     *
     * @param cmd
     * @return
     */
    private boolean isSendAlexaVoiceCmd(byte[] cmd) {
        return (cmd[0] & 0xff) == 0x13 || (cmd[0] & 0xff) == 0x11;
    }

    /**
     * 是否为 同步时间指令
     *
     * @param cmd
     * @return
     */
    private boolean isSendTimeCmd(byte[] cmd) {
        return (cmd[0] & 0xff) == 0x03 && (cmd[1] & 0xff) == 0x01;
    }

    private void receiverDeviceData(byte[] values) {
        LogTool.p(ConnectConstants.LOG_TGA, "[BytesDataConnect] receive <= " + HexUtil.formatHexString(values, true));
    }

    protected void addCmdData(ByteDataRequest request, boolean isForce) {
        if (request == null || request.getSendData() == null) {
            LogTool.e(ConnectConstants.LOG_TGA, "[BytesDataConnect] onAddCmd() ignore, data is null");
            return;
        }
        //长度存储1min 中，防止重复，解决c库，5s内没收到回复，或者500ms没收到发送成功的回应，导致指令重复（消息提醒重复）
        byte[] cmd = request.getSendData();
        LogTool.p(ConnectConstants.LOG_TGA, "[BytesDataConnect] addCmdData( " + HexUtil.formatHexString(cmd, true) + ")");
        //时间指令优先发，不然时间会有延时
        if (isSendTimeCmd(cmd)) {
            isForce = true;
        }
        int size = mCmdDataQueue.size();
        synchronized (mLock) {
            if (isForce) {
                mCmdDataQueue.addFirst(request);
            } else {
                mCmdDataQueue.add(request);
            }
        }
        LogTool.p(ConnectConstants.LOG_TGA, "[BytesDataConnect] addCmdData que size = " + size);
        if (size < 2) {
            mHandler.sendEmptyMessage(WHAT_SEND_Next);
        }
    }

    protected void reset() {
        destroy();
    }

    private void destroy() {
        mCmdDataQueue.clear();
        mIsSendingCmdData = false;
        mIsReSendData = false;
        mWriteDataFailedCount = 0;
        mHandler.removeCallbacksAndMessages(null);
        mWriteHealthGattCharacteristic = null;
        mWriteNormalGattCharacteristic = null;
    }

    protected void deviceResponseOnLastSend(byte[] values, int status) {
        if (status == BluetoothGatt.GATT_SUCCESS) {
            LogTool.p(ConnectConstants.LOG_TGA,
                    "[BytesDataConnect] onDeviceResponseOnLastSend( " + HexUtil.formatHexString(values, true) + ")");
        } else {
            LogTool.e(ConnectConstants.LOG_TGA,
                    "[BytesDataConnect] onDeviceResponseOnLastSend[failed]( " + HexUtil.formatHexString(values, true) + ")");
        }

        mIsSendingCmdData = false;
        mHandler.removeMessages(WHAT_SEND_NO_ANSWER_TIMEOUT);
//        handleCmdDataQueue();
//        CommonUtils.runOnMainThread(new Runnable() {
//            @Override
//            public void run() {
//                sendNextCmdData();
//            }
//        });
        sendNextCmdData();

    }

}
