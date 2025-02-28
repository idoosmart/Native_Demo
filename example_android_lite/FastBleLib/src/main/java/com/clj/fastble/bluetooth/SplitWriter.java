package com.clj.fastble.bluetooth;


import android.os.Handler;
import android.os.HandlerThread;
import android.os.Message;
import android.util.Log;

import com.clj.fastble.BleManager;
import com.clj.fastble.callback.BleWriteCallback;
import com.clj.fastble.data.BleMsg;
import com.clj.fastble.exception.BleException;
import com.clj.fastble.exception.OtherException;
import com.clj.fastble.utils.BleLog;
import com.clj.fastble.utils.HexUtil;

import java.util.LinkedList;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedDeque;
import java.util.concurrent.atomic.AtomicBoolean;

public class SplitWriter {

    private static class Data {
        public byte[] mData;
        public int mWriteType;

        public Data(byte[] mData, int mWriteType) {
            this.mData = mData;
            this.mWriteType = mWriteType;
        }
    }

    private HandlerThread mHandlerThread;
    private Handler mHandler;

    private BleBluetooth mBleBluetooth;
    private String mUuid_service;
    private String mUuid_write;
    private Data mSendingData;
    private boolean mSendNextWhenLastSuccess;
    private long mIntervalBetweenTwoPackage;
    private BleWriteCallback mCallback;
    private Queue<Data> mDataQueue = new ConcurrentLinkedDeque<>();
    private AtomicBoolean mSending = new AtomicBoolean(false);
    private int mTotalNum;

    public SplitWriter() {
        mHandlerThread = new HandlerThread("splitWriter");
        mHandlerThread.start();

        mHandler = new Handler(mHandlerThread.getLooper()) {
            @Override
            public void handleMessage(Message msg) {
                super.handleMessage(msg);
                if (msg.what == BleMsg.MSG_SPLIT_WRITE_NEXT) {
                    Log.d("","send next");
                    write();
                }
            }
        };
    }

    public void splitWrite(BleBluetooth bleBluetooth,
                           String uuid_service,
                           String uuid_write,
                           byte[] data,
                           int writeType,
                           boolean sendNextWhenLastSuccess,
                           long intervalBetweenTwoPackage,
                           BleWriteCallback callback) {
        mBleBluetooth = bleBluetooth;
        mUuid_service = uuid_service;
        mUuid_write = uuid_write;
        mSendNextWhenLastSuccess = sendNextWhenLastSuccess;
        mIntervalBetweenTwoPackage = intervalBetweenTwoPackage;
        mCallback = callback;
        Log.e("Splite","发送数据："+HexUtil.formatHexString(data,true));
        splitWrite(data, writeType);
    }

    private void splitWrite(byte[] data, int writeType) {
        mDataQueue.add(new Data(data, writeType));
        write();
    }

    private void write() {
        Log.d("SplitWriter","queue size = "+mDataQueue.size());
        if (mSending.get()) {
            Log.d("SplitWriter", "is sending: " + HexUtil.formatHexString(mSendingData.mData, true));
            return;
        }
        mSending.set(true);
        if (mDataQueue.peek() == null) {
            mSending.set(false);
            return;
        }

        mSendingData = mDataQueue.poll();
        if (mSendingData == null||mSendingData.mData==null){
            mSending.set(false);
            return;
        }
        Log.d("SplitWriter","send => "+HexUtil.formatHexString(mSendingData.mData,true));
        mBleBluetooth.newBleConnector()
                .withUUIDString(mUuid_service, mUuid_write)
                .writeCharacteristic(
                        mSendingData.mData,
                        new BleWriteCallback() {
                            @Override
                            public void onWriteSuccess(int current, int total, byte[] justWrite) {
                                Log.d("BLEData","onWriteSuccess: "+HexUtil.formatHexString(justWrite,true));
                                if (mCallback != null) {
                                    mCallback.onWriteSuccess(0, mTotalNum, justWrite);
                                }
                                mSending.set(false);
                                if (mSendNextWhenLastSuccess) {
                                    Message message = mHandler.obtainMessage(BleMsg.MSG_SPLIT_WRITE_NEXT);
                                    mHandler.sendMessageDelayed(message, mIntervalBetweenTwoPackage);
                                }

                            }

                            @Override
                            public void onWriteFailure(BleException exception) {
                                Log.e("BLEData","onWriteFailure: "+exception);
                                if (mCallback != null) {
                                    mCallback.onWriteFailure(new OtherException("exception occur while writing: " + exception.getDescription()));
                                }
                                mSending.set(false);
                                if (mSendNextWhenLastSuccess) {
                                    Message message = mHandler.obtainMessage(BleMsg.MSG_SPLIT_WRITE_NEXT);
                                    mHandler.sendMessageDelayed(message, mIntervalBetweenTwoPackage);
                                }

                            }
                        },
                        mUuid_write, mSendingData.mWriteType);

        if (!mSendNextWhenLastSuccess) {
            mSending.set(false);
            Message message = mHandler.obtainMessage(BleMsg.MSG_SPLIT_WRITE_NEXT);
            mHandler.sendMessageDelayed(message, mIntervalBetweenTwoPackage);
        }
    }

    private void release() {
        mHandlerThread.quit();
        mHandler.removeCallbacksAndMessages(null);
    }

    private static Queue<byte[]> splitByte(byte[] data, int count) {
        if (count > 20) {
            BleLog.w("Be careful: split count beyond 20! Ensure MTU higher than 23!");
        }
        Queue<byte[]> byteQueue = new LinkedList<>();
        int pkgCount;
        if (data.length % count == 0) {
            pkgCount = data.length / count;
        } else {
            pkgCount = Math.round(data.length / count + 1);
        }

        if (pkgCount > 0) {
            for (int i = 0; i < pkgCount; i++) {
                byte[] dataPkg;
                int j;
                if (pkgCount == 1 || i == pkgCount - 1) {
                    j = data.length % count == 0 ? count : data.length % count;
                    System.arraycopy(data, i * count, dataPkg = new byte[j], 0, j);
                } else {
                    System.arraycopy(data, i * count, dataPkg = new byte[count], 0, count);
                }
                byteQueue.offer(dataPkg);
            }
        }

        return byteQueue;
    }


}
