package com.example.example_android.util

import android.database.Cursor
import android.text.TextUtils
import android.util.Log
import java.io.BufferedInputStream
import java.io.BufferedOutputStream
import java.io.ByteArrayOutputStream
import java.io.Closeable
import java.io.File
import java.io.IOException
import java.io.InputStream
import java.io.InputStreamReader
import java.io.OutputStream
import java.io.OutputStreamWriter
import java.io.Reader
import java.io.Writer

object IOUtil {

    fun closeQuietly(closeable: Closeable?) {
        if (closeable != null) {
            try {
                closeable.close()
            } catch (ignored: Throwable) {
                Log.d(ignored.message, ignored.message!!)
            }
        }
    }

    fun closeQuietly(cursor: Cursor?) {
        if (cursor != null) {
            try {
                cursor.close()
            } catch (ignored: Throwable) {
                Log.d(ignored.message, ignored.message!!)
            }
        }
    }

    @Throws(IOException::class)
    fun readBytes(`in`: InputStream): ByteArray? {
        var `in` = `in`
        if (`in` !is BufferedInputStream) {
            `in` = BufferedInputStream(`in`)
        }
        var out: ByteArrayOutputStream? = null
        return try {
            out = ByteArrayOutputStream()
            val buf = ByteArray(1024)
            var len: Int
            while (`in`.read(buf).also { len = it } != -1) {
                out.write(buf, 0, len)
            }
            out.toByteArray()
        } finally {
            closeQuietly(out)
        }
    }

    @Throws(IOException::class)
    fun readBytes(`in`: InputStream, skip: Long, size: Int): ByteArray? {
        var skip = skip
        var result: ByteArray? = null
        if (skip > 0) {
            var skipped: Long = 0
            while (skip > 0 && `in`.skip(skip).also { skipped = it } > 0) {
                skip -= skipped
            }
        }
        result = ByteArray(size)
        for (i in 0 until size) {
            result[i] = `in`.read().toByte()
        }
        return result
    }

    @Throws(IOException::class)
    fun readStr(`in`: InputStream?): String? {
        return readStr(`in`, "UTF-8")
    }

    @Throws(IOException::class)
    fun readStr(`in`: InputStream?, charset: String?): String? {
        var `in` = `in`
        var charset = charset
        if (TextUtils.isEmpty(charset)) charset = "UTF-8"
        if (`in` !is BufferedInputStream) {
            `in` = BufferedInputStream(`in`)
        }
        val reader: Reader = InputStreamReader(`in`, charset)
        val sb = StringBuilder()
        val buf = CharArray(1024)
        var len: Int
        while (reader.read(buf).also { len = it } >= 0) {
            sb.append(buf, 0, len)
        }
        return sb.toString()
    }

    @Throws(IOException::class)
    fun writeStr(out: OutputStream?, str: String?) {
        writeStr(out, str, "UTF-8")
    }

    @Throws(IOException::class)
    fun writeStr(out: OutputStream?, str: String?, charset: String?) {
        var charset = charset
        if (TextUtils.isEmpty(charset)) charset = "UTF-8"
        val writer: Writer = OutputStreamWriter(out, charset)
        writer.write(str)
        writer.flush()
    }

    @Throws(IOException::class)
    fun copy(`in`: InputStream, out: OutputStream) {
        var `in` = `in`
        var out = out
        if (`in` !is BufferedInputStream) {
            `in` = BufferedInputStream(`in`)
        }
        if (out !is BufferedOutputStream) {
            out = BufferedOutputStream(out)
        }
        var len = 0
        val buffer = ByteArray(1024)
        while (`in`.read(buffer).also { len = it } != -1) {
            out.write(buffer, 0, len)
        }
        out.flush()
    }

    fun deleteFileOrDir(path: File?): Boolean {
        if (path == null || !path.exists()) {
            return true
        }
        if (path.isFile) {
            return path.delete()
        }
        val files = path.listFiles()
        if (files != null) {
            for (file in files) {
                deleteFileOrDir(file)
            }
        }
        return path.delete()
    }

    /**
     * 关闭IO.可用于任何IO类的close操作
     * @param closeable
     */
    fun close(closeable: Closeable?) {
        var closeable = closeable
        if (closeable != null) {
            try {
                closeable.close()
                closeable = null
            } catch (e: IOException) {
                e.printStackTrace()
            }
        }
    }

}