package com.example.example_android.activity

import LoadingManager
import android.app.Activity
import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.provider.MediaStore
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.core.net.toFile
import androidx.documentfile.provider.DocumentFile
import com.example.example_android.R
import com.example.example_android.base.BaseActivity
import com.example.example_android.util.GetFilePathFromUri
import com.idosmart.enums.IDOTransStatus
import com.idosmart.enums.IDOTransType
import com.idosmart.model.IDOMusicFolderItem
import com.idosmart.model.IDOMusicInfoModel
import com.idosmart.model.IDOMusicItem
import com.idosmart.model.IDOMusicOpearteParamModel
import com.idosmart.model.IDOMusicOperateModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.pigeon_implement.IDOTransMusicModel
import com.idosmart.pigeon_implement.IDOTransNormalModel
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOTransBaseModel
import kotlinx.android.synthetic.main.activity_music_transfer.etAddMusicId
import kotlinx.android.synthetic.main.activity_music_transfer.etAddSheetId
import kotlinx.android.synthetic.main.activity_music_transfer.etMusicId
import kotlinx.android.synthetic.main.activity_music_transfer.etMusicName
import kotlinx.android.synthetic.main.activity_music_transfer.etMusicPath
import kotlinx.android.synthetic.main.activity_music_transfer.etResult
import kotlinx.android.synthetic.main.activity_music_transfer.etSheetId
import kotlinx.android.synthetic.main.activity_music_transfer.etSheetName
import kotlinx.android.synthetic.main.activity_music_transfer.music_clean_transfer
import kotlinx.android.synthetic.main.activity_music_transfer.music_progressBar
import java.io.File

class MusicTransferActivity : BaseActivity() {
    private val TAG = "MusicTransferActivity"
    private var cancelPre = false
    private var getMusicPath: String? = null
    private var idoMusicInfoModel: IDOMusicInfoModel? = null
    private var musicIndex: List<Int>? = mutableListOf()
    var loadingManager = LoadingManager(this)
    override fun getLayoutId(): Int {
        return R.layout.activity_music_transfer
    }

    private val REQUEST_CODE_FILE_CHOOSER = 1

    override fun initView() {
        super.initView()

        if (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3) {
            etResult.setText(R.string.music_start_query_music)
            Cmds.getBleMusicInfo().send {
                if (it.error.code == 0) {
                    etResult.setText(it.res?.toJsonString())
                    idoMusicInfoModel = it.res

                }
            }
        }

    }

    fun btNewSheet(view: View) {
        var folderId: Int? = null
        if (idoMusicInfoModel != null) {
            folderId =
                idoMusicInfoModel?.folderItems?.get(idoMusicInfoModel?.folderItems?.size!! - 1)?.folderId?.plus(
                    1
                )
        } else {
            folderId = 1
        }
        musicOperate(
            0,
            2,
            folderId!!,
            getMusicPath!!,
            etSheetName.text.toString()
        ).let {
            loadingManager.show()
            Cmds.setMusicOperate(it).send {
                loadingManager.dismiss()
                if (it.error.code == 0) {
                    toast("Playlist created successfully")
                    etSheetName.setHint(R.string.music_tips_input_sheet_id)
                } else {
                    // 失败
                    toast("Playlist creation failed")
                }
            }

        }
    }

    fun btDeleteSheet(view: View) {
        musicOperate(
            0,
            1,
            etSheetId.text.toString().toInt()!!,
            getMusicPath!!,
            etSheetName.text.toString()
        ).let {
            loadingManager.show()
            Cmds.setMusicOperate(it).send {
                loadingManager.dismiss()

                if (it.error.code == 0) {
                    toast("Playlist deleted successfully")
                    etSheetName.setHint(R.string.music_tips_input_sheet_id)
                } else {
                    // 失败
                    toast("Playlist deletion failed")
                }
            }
        }

    }

    fun btSelectMusicFile(view: View) {
        val intent = Intent(Intent.ACTION_GET_CONTENT)
        intent.type = "audio/mp3/*"
        startActivityForResult(intent, REQUEST_CODE_FILE_CHOOSER)
    }

    fun btAddMusic(view: View) {
        var musicId: Int? = 0
        if (idoMusicInfoModel != null) {
            musicId =
                idoMusicInfoModel?.musicItems?.get(idoMusicInfoModel?.musicItems?.size!! - 1)?.musicId?.plus(
                    1
                )
        } else {
            musicId = 1
        }

        var musicName = etMusicName.text.toString()
        //删除重复歌曲/Remove duplicate songs
        idoMusicInfoModel?.musicItems?.forEach {
            if (musicName == it.musicName || musicId == it.musicId) {
                musicOperate(1, 0, musicId!!, getMusicPath!!, musicName).let { isOk ->
                    Cmds.setMusicOperate(isOk).send {
                        if (it.error.code == 0) {
                            Log.d(TAG, "btAddMusic: Delete the song successfully")
                        } else {
                            Log.d(TAG, "btAddMusic: Failure to delete song")
                        }
                    }
                }
            }
        }

        //添加歌曲至设备/ Add a song to the device
        musicOperate(2, 0, musicId!!, getMusicPath!!, musicName).let {
            Cmds.setMusicOperate(it).send {
                if (it.error.code == 0) {
                    Log.d(TAG, "btAddMusic: Added song successfully")

                } else {
                    Log.d(TAG, "btAddMusic: Added song successfully")
                }
            }

        }


        var items = mutableListOf<IDOTransBaseModel>()

        if (getMusicPath != null) {
            items.add(
                IDOTransMusicModel(
                    getMusicPath!!,
                    etMusicName.text.toString(),
                    GetFilePathFromUri.getFileSize(getMusicPath).toInt(),
                    musicId,
                    null,
                    false
                )
            )
            Log.d(TAG, "btAddMusic: " + getMusicPath!!)

        }
        loadingManager.show()

        // 调用传输
        val cancellable = sdk.transfer.transferFiles(
            items, cancelPre,
            { currentIndex, totalCount, currentProgress, totalProgress ->
                Log.d(TAG, "传输中${totalProgress}/$currentProgress...")

                music_progressBar.setProgress((totalProgress * 100).toInt(), true)

            },
            { currentIndex: Int, status: IDOTransStatus, errorCode: Int?, finishingTime: Int? ->
                if (status != IDOTransStatus.FINISHED || errorCode != 0) {
                    Log.d(TAG, "传输失败:$errorCode")
                }
            },
            { resultList ->
                resultList.forEach {
                    loadingManager.dismiss()
                    if (it) {
                        //传输成功
                        Log.d(TAG, "btAddMusic: 传输成功")
                        toast("传输完成")

                    } else {
                        //传输失败
                        Log.d(TAG, "btAddMusic: 传输失败")

                        toast("传输失败")
                    }
                }
            })


        music_clean_transfer.setOnClickListener {
            cancellable?.cancel()
        }
    }

    fun btDeleteMusic(view: View) {
        loadingManager.show()
        idoMusicInfoModel?.musicItems?.forEach {
            if (it.musicId == etMusicId.text.toString().toInt()) {
                //删除歌曲
                musicOperate(
                    1,
                    0,
                    etMusicId.text.toString().toInt(),
                    "",
                    it.musicName
                ).let { isOk ->
                    Cmds.setMusicOperate(isOk).send {
                        if (it.error.code == 0) {
                            loadingManager.dismiss()
                            Log.d(TAG, "btAddMusic: 删除歌曲成功")
                        } else {
                            Log.d(TAG, "btAddMusic: 删除歌曲失败")
                        }
                    }
                }
            }
        }

    }

    fun btAddMusic2Folder(view: View) {
        idoMusicInfoModel?.folderItems?.forEach {
            if (it.folderId == etAddSheetId.text.toString().toInt()) {
                val param =
                    IDOMusicOpearteParamModel(
                        0,
                        4,
                        IDOMusicFolderItem(
                            etAddSheetId.text.toString().toInt(),
                            1,
                            it.folderName,
                            listOf(etAddMusicId.text.toString().toInt())
                        ),
                        null
                    )

                //删除歌曲
                Cmds.setMusicOperate(param).send {

                    if (it.error.code == 0) {
                        Log.d(TAG, "btAddMusic: 歌曲移动成功")
                    } else {
                        Log.d(TAG, "btAddMusic: 歌曲移动失败")
                    }
                }
            }
        }
    }

    fun btQueryMusic(view: View) {
        if (sdk.funcTable.getSupportV3BleMusic && sdk.funcTable.getSupportGetBleMusicInfoVerV3) {
            etResult.setText(R.string.music_start_query_music)
            Cmds.getBleMusicInfo().send {
                if (it.error.code == 0) {
                    etResult.setText(it.res?.toJsonString())
                    idoMusicInfoModel = it.res
                }
            }
        }

    }
    //歌曲操作实体修改方法/ Song manipulation entity modification method
    private fun musicOperate(
        musicOperate: Int,
        folderOperate: Int,
        id: Int,
        path: String,
        name: String
    ): IDOMusicOpearteParamModel {
        val param =
            IDOMusicOpearteParamModel(
                musicOperate,
                folderOperate,
                IDOMusicFolderItem(
                    id,
                    1,
                    name,
                    musicIndex!!
                ),
                IDOMusicItem(
                    id!!,
                    GetFilePathFromUri.getFileSize(path).toInt(),
                    name,
                    ""
                )
            )
        Log.d(TAG, "musicOperate: ${param.toJsonString()}")
        return param
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_CODE_FILE_CHOOSER && resultCode == Activity.RESULT_OK) {

            var uri = data?.data

            getMusicPath = GetFilePathFromUri.getFileAbsolutePath(this, uri)
            etMusicPath.setText(getMusicPath)

        }
    }


}