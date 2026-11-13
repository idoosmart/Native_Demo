package com.example.example_android.util.download;

import android.text.TextUtils;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;
import okhttp3.ResponseBody;

/**
 * @Author: ym
 * @ClassName: DownloadManager
 * @Description: 下载管理类 / Download manager class
 * @Package: com.ido.life.data
 * @CreateDate: 2020/5/8 0008 19:21
 */
public class DownloadManager {
    private static final String TAG = "DownloadManager";
    private static final int BUFFER_SIZE = 1024;

    /**
     * 下载文件
     * Download a file
     *
     * @param url      下载url / Download url
     * @param path     文件保存路径 / File save path
     * @param listener
     */
    public static void download(String url, final String path, final DownloadListener listener) {
        if (TextUtils.isEmpty(url)) {
            downloadFailed(path, ErrorCode.CODE_FILE_NOT_EXIT, "download url is empty", listener);
            return;
        }
        if (listener != null) {
            listener.onDownloadStart();
        }
        try {
            OkHttpClient client = HttpUtil.getHttpClient();
            Request request = new Request.Builder()
                    //访问路径
                    //Request URL
                    .url(url)
                    .build();
            client.newCall(request).enqueue(new Callback() {
                @Override
                public void onFailure(Call call, IOException e) {
                    e.printStackTrace();
                    downloadFailed(path, ErrorCode.CODE_WRITE_FILE_ERROR, "download failed", listener);
                }

                @Override
                public void onResponse(Call call, Response response) throws IOException {
                    writeFileFromIS(new File(path), response.body(), listener);
                }
            });

        } catch (Exception e) {
            e.printStackTrace();
            downloadFailed(path, ErrorCode.CODE_WRITE_FILE_ERROR, "download failed", listener);
        }
    }

    /**
     * 将流写入文件中
     * Write the stream to a file
     *
     * @param file
     * @param body
     * @param listener
     */
    private static void writeFileFromIS(File file, ResponseBody body, DownloadListener listener) {
        //标识是否下载成功
        //Flag for whether the download succeeded
        boolean isSuccess = false;
        if (body == null) {
            downloadFailed(file.getAbsolutePath(), ErrorCode.CODE_FILE_NOT_EXIT, "file not exist", listener);
            return;
        }

        //创建文件
        //Create the file
        if (!file.exists()) {
            File parentFile = file.getParentFile();
            if (parentFile == null) {
                downloadFailed(file.getAbsolutePath(), ErrorCode.CODE_FILE_NOT_EXIT, "file path not exist", listener);
                return;
            }
            if (!parentFile.exists())
                parentFile.mkdirs();
            try {
                file.createNewFile();
            } catch (IOException e) {
                e.printStackTrace();
                downloadFailed(file.getAbsolutePath(), ErrorCode.CODE_CREATE_FILE_ERROR, "createNewFile IOException : " + e.getMessage(), listener);
                return;
            }
        }
        InputStream is = body.byteStream();
        long contentLength = body.contentLength();
        OutputStream bos = null;
        long currentLength = 0;
        try {
            bos = new BufferedOutputStream(new FileOutputStream(file));
            byte[] data = new byte[BUFFER_SIZE];
            int len;
            int lastProgress = 0;
            while ((len = is.read(data)) != -1) {
                bos.write(data, 0, len);
                currentLength += len;
                int progress = (int) (100f * currentLength / contentLength);
                if (listener != null && progress > lastProgress) {
                    //计算当前下载进度
                    //Calculate the current download progress
                    listener.onDownloadProgress(progress);
                    lastProgress = progress;
                }
            }
            bos.flush();
            isSuccess = true;
        } catch (IOException e) {
            e.printStackTrace();
            downloadFailed(file.getAbsolutePath(), ErrorCode.CODE_WRITE_FILE_ERROR, "write file IOException : " + e.getMessage(), listener);
        } finally {
            try {
                is.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
            try {
                if (bos != null) {
                    bos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
            if (listener != null && isSuccess) {
                //下载完成，并返回保存的文件路径
                //Download finished, return the saved file path
                listener.onDownloadFinish(file.getAbsolutePath());
            }
        }
    }

    /**
     * 下载失败
     * Download failed
     *
     * @param listener
     * @param code
     * @param msg
     */
    private static void downloadFailed(String path, int code, String msg, DownloadListener listener) {
        deleteFile(path);
        if (listener != null) {
            listener.onDownloadFailed(code, msg);
        }
    }

    public static boolean deleteFile(String path) {
        if (null == path) {
            return true;
        }
        boolean ret = true;

        File file = new File(path);
        if (file.exists()) {
            ret = file.delete();
        }
        return ret;
    }


    /**
     * 以下回调均在子线程，如果需要更新UI，需要切换到主线程
     * All callbacks below run on a worker thread; switch to the main thread to update the UI
     */
    public interface DownloadListener {

        /**
         * 开始下载
         * Download started
         */
        void onDownloadStart();

        /**
         * 下载进度
         * Download progress
         *
         * @param progress
         */
        void onDownloadProgress(int progress);

        /**
         * 下载完成
         * Download finished
         *
         * @param path
         */
        void onDownloadFinish(String path);

        /**
         * 下载失败
         * Download failed
         *
         * @param errCode
         * @param errInfo
         */
        void onDownloadFailed(int errCode, String errInfo);
    }
}
