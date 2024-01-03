package com.example.example_android.util

import android.content.Context
import android.content.SharedPreferences
import com.example.example_android.MyApplication
import com.example.example_android.appContext

/**
 * SharedPreference tool
 * @author patrick
 */
object SPUtil {
    //tag of SP file name.
    private const val KEY_FILE_NAME_DEFAULT = "idodemo"

    /**
     * put data into SP file what you wanna to save.
     * @param key | String
     * @param value | T
     * @param fileName | String
     */
    fun <T> putAValue(
        key: String,
        value: T,
        fileName: String = KEY_FILE_NAME_DEFAULT,
        context: (() -> Context?)? = null
    ) {

        getEditor(
            fileName,
            context?.invoke() ?: appContext
        )?.let { editor ->
            when (value) {
                is String -> {
                    editor.putString(key, value)
                }
                is Boolean -> {
                    editor.putBoolean(key, value)
                }
                is Int -> {
                    editor.putInt(key, value)
                }
                is Long -> {
                    editor.putLong(key, value)
                }
                is Float -> {
                    editor.putFloat(key, value)
                }
                is Enum<*> -> {
                    editor.putString(key, value.name)
                }
            }
            editor.apply()
        }

    }

    /**
     * get data from the SP file what you had saved.
     * @param key | String
     * @param defaultValue | T
     * @param fileName | String
     */
    fun <T> getAValue(
        key: String,
        defaultValue: T,
        fileName: String = KEY_FILE_NAME_DEFAULT
    ): Comparable<*>? {

        val sharedPreference = appContext
            ?.getSharedPreferences("sp_$fileName", Context.MODE_PRIVATE)
        sharedPreference?.let { preference ->
            return when (defaultValue) {
                is String -> {
                    preference.getString(key, defaultValue)
                }
                is Boolean -> {
                    preference.getBoolean(key, defaultValue)
                }
                is Int -> {
                    preference.getInt(key, defaultValue)
                }
                is Long -> {
                    preference.getLong(key, defaultValue)
                }
                is Float -> {
                    preference.getFloat(key, defaultValue)
                }
                is Enum<*> -> {
                    preference.getString(key, defaultValue.name)
                }
                else -> {
                    throw IllegalArgumentException("This type of data cannot be saved!")
                }
            }
        }
        return null

    }

    /**
     * remove a data from the SP file what you had saved.
     * @param key | String
     * @param fileName | String
     */
    fun remove(
        key: String,
        fileName: String = KEY_FILE_NAME_DEFAULT,
        context: (() -> Context?)? = null
    ) {
        getEditor(fileName, context?.invoke() ?: appContext)?.remove(key)
    }

    /**
     * clear all data in the SP file that you had saved into.
     * @param fileName | String
     */
    fun clear(fileName: String = KEY_FILE_NAME_DEFAULT, context: (() -> Context?)? = null) {
        getEditor(fileName, context?.invoke() ?: appContext)?.clear()
    }

    /**
     * inner function for supporting SP.
     * @param fileName | String
     */
    private fun getEditor(fileName: String, context: Context?): SharedPreferences.Editor? {
        val sharedPreference = context?.applicationContext
            ?.getSharedPreferences("sp_$fileName", Context.MODE_PRIVATE)
        return sharedPreference?.edit()
    }

}
