package com.example.example_android.activity

//import com.example.example_android.adapter.NotificationIconAdapter
import LoadingManager
import android.app.Notification
import android.graphics.drawable.Drawable
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.example_android.R
import com.example.example_android.adapter.NotificationIconAdapter
import com.example.example_android.base.BaseActivity
import com.example.example_android.data.MessageNotifyState
import com.example.example_android.data.TranIconBean
import com.google.gson.Gson
import com.idosmart.enums.IDOLogType
import com.idosmart.enums.IDOStatusNotification
import com.idosmart.model.IDOAppIconItemModel
import com.idosmart.model.IDOBleDeviceModel
import com.idosmart.model.IDODeviceNotificationModel
import com.idosmart.model.IDOFastMsgItem
import com.idosmart.model.IDOFastMsgSettingModel
import com.idosmart.model.IDOFastMsgUpdateModel
import com.idosmart.model.IDOFastMsgUpdateParamModel
import com.idosmart.model.IDONoticeMesaageParamItem
import com.idosmart.model.IDONoticeMesaageParamModel
import com.idosmart.model.IDONoticeMessageStateItemItem
import com.idosmart.model.IDONoticeMessageStateParamModel
import com.idosmart.model.IDONotificationStatusParamModel
import com.idosmart.pigeon_implement.Cmds
import com.idosmart.protocol_channel.sdk
import com.idosmart.protocol_sdk.IDOBridgeDelegate
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_allow
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_clos
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_clos_back
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_content
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_ll
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_sendMsg
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_sendMsg_quick
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_pop_silent
import kotlinx.android.synthetic.main.activity_notification_icon_transfer.app_notification_rv
import java.io.File
import java.util.concurrent.ConcurrentHashMap
import kotlin.math.log

class NotificationIconTransferActivity : BaseActivity() {
    private val TAG = "NotificationIconTransfer"
    var apps = mutableListOf<TranIconBean>()
    var mClickedApp: TranIconBean? = null
    lateinit var notificationIconAdapter: NotificationIconAdapter
    private lateinit var loadingManager: LoadingManager

    //设备支持的语言
    private val languages: List<Int> = ArrayList()


    override fun getLayoutId(): Int {
        return R.layout.activity_notification_icon_transfer
    }


    override fun initView() {
        super.initView()

        //解绑数据要调用sdk.messageIcon.resetIconInfoData方法清除icon本地缓存

        loadingManager = LoadingManager(this)

        sdk.bridge.setupBridge(BleData(), IDOLogType.DEBUG)
        Log.d(TAG, "getFastMsgDataV3: ${sdk.funcTable.getFastMsgDataV3}")
        //功能表判断该设备是否支持消息快捷回复功能
        if (!sdk.funcTable.getFastMsgDataV3) {
            app_notification_pop_sendMsg_quick.visibility = View.GONE
        }
        loadingManager.show()
        //获取应用列表之前需要给出应用列表读取权限以及在配置清单文件中给出对应权限才能正常拿到所有应用
        sdk.messageIcon.firstGetAppInfo(force = true) { it ->
            loadingManager.dismiss()

            it.forEach {
                val file = File(it.iconLocalPath)
                if (it.isDefault!!) {
                    apps.add(
                        TranIconBean(
                            it.evtType,
                            it.packName,
                            it.appName,
                            Drawable.createFromPath(file.path),
                            1,
                            it.state,
                            it.isUpdateAppIcon
                        )
                    )
                } else {
                    apps.add(
                        TranIconBean(
                            it.evtType,
                            it.packName,
                            it.appName,
                            Drawable.createFromPath(file.path),
                            3,
                            it.state,
                            it.isUpdateAppIcon
                        )
                    )
                }
            }

            //添加默认应用
            setNotificationState(1, true)
            //刷新应用列表
            setNotificationState(3, true)

            notificationIconAdapter = NotificationIconAdapter(this, apps)
            app_notification_rv.adapter = notificationIconAdapter
            app_notification_rv.layoutManager = LinearLayoutManager(this)
            notificationIconAdapter.setOnItemClickListener(object :
                NotificationIconAdapter.OnItemClickListener {
                override fun onItemClick(position: Int) {
                    mClickedApp = apps[position]
                    app_notification_pop_ll.visibility = View.VISIBLE

                    //允许通知
                    app_notification_pop_allow.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 1
                        setNotificationState(2, false)
                    }
                    //静默通知
                    app_notification_pop_silent.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 2
                        setNotificationState(2, false)
                    }
                    //关闭通知
                    app_notification_pop_clos.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 3
                        setNotificationState(2, false)
                    }
                    //快捷回复通知
                    app_notification_pop_sendMsg_quick.setOnClickListener {
                        loadingManager.show()
                        sendMsg(app_notification_pop_content.text.toString(), 1)
                    }
                    //发送普通通知
                    app_notification_pop_sendMsg.setOnClickListener {
                        loadingManager.show()
                        sendMsg(app_notification_pop_content.text.toString(), 0)
                    }

                }
            })
        }

        app_notification_pop_clos_back.setOnClickListener {
            app_notification_pop_ll.visibility = View.GONE
        }

        //获取设备支持语言库
        if (sdk.funcTable.getSupportGetUnit) {
            getLanguageLibrary()
        }
    }


    private fun getLanguageLibrary() {
        Cmds.getUnit().send { it ->
            if (it.error.code == 0) {
                // 成功
                Log.d(TAG, "getLanguageLibrary: ${it.res?.language}")

            } else {
                // 失败
                Log.d(TAG, "getLanguageLibrary: ${it.res?.toJsonString()}")
            }
        }
    }

    //快捷消息回复回调
    inner class BleData : IDOBridgeDelegate {
        override fun listenStatusNotification(status: IDOStatusNotification) {
            println("listenStatusNotification $status");
        }

        override fun checkDeviceBindState(macAddress: String): Boolean {
            return false
        }

        override fun listenDeviceNotification(status: IDODeviceNotificationModel) {
            println("listenDeviceNotification $status");
            // 快速短信回复
            if (status.controlEvt == 580 && status.controlJson != null) {
                println("status.controlJson: ${status.controlJson}")
                val gson = Gson()
                val msgItem = gson.fromJson(status.controlJson, IDOFastMsgUpdateModel::class.java)
                // 1 表示来电快捷回复
                if (msgItem.msgType == 1) {
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(
                        1,
                        msgItem.msgID,
                        msgItem.msgType,
                        msgItem.msgNotice
                    )
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                } else {
                    // 第三方消息
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果
                    // val isSuccess = if (回复结果) 1 else 0
                    var param = IDOFastMsgUpdateParamModel(
                        1,
                        msgItem.msgID,
                        msgItem.msgType,
                        msgItem.msgNotice
                    )
                    Cmds.setFastMsgUpdate(param).send {
                        println("setFastMsgUpdate ${it.res?.toJsonString()}")
                    }
                }
            }
        }
    }


    /**
     * msg: 发送的内容
     * msgID: 0->普通通知  1:快捷回复消息
     *
     * */
    private fun sendMsg(msg: String, msgID: Int) {

        if (msgID != 0) {

            val param = IDOFastMsgSettingModel(
                0, listOf(
                    IDOFastMsgItem(1, "test1"),
                    IDOFastMsgItem(2, "test2"),
                    IDOFastMsgItem(3, "test3"),
                    IDOFastMsgItem(4, "test4"),
                    IDOFastMsgItem(5, "test5")
                )
            )
            //设置默认快捷消息回复列表
            Cmds.setDefaultQuickMsgReplyList(param).send {
                if (it.error.code == 0) {
                    // 成功
                    // it.res is IDOCmdSetResponseModel

                } else {
                    // 失败
                    toast("快捷消息回复列表设置失败～")
                }
            }
        }

        /**
         * 每次下发通知消息，执行事件类型
         * 事件类型就是上面items获取到的，事件类型和每个APP应用关联的，所以告诉事件类型就知道哪个应用的通知
         * 下发这个事件类型，为判断APP图标是否更新到，如果未更新APP图标，SDK则会下发对应的APP图标
         * 实体类参数解释请参考开发说明文档
         *
         * verison	Int	协议库版本号
         * osPlatform	Int	系统0：无效，1：Android，2：iOS
         * evtType	Int	当前模式 0：无效，1：消息提醒
         * notifyType	Int	消息枚举类型 最大值：20000
         * msgID	Int	消息ID 仅当evt_type为消息提醒且msg_ID不为0时有效
         * appItemsLen	Int	国家/地区数量和语言详细信息
         * contact	String	联系人姓名（最大 63 字节）
         * phoneNumber	String	电话号码（最大 31 字节）
         * msgData	String	消息内容（最大249字节）
         * items: IDONoticeMesaageParamItem 语言列表
         *      language	Int	语言类型
         *      name	String	国家对应的应用名称（最大49字节）
         * */
        sdk.messageIcon.androidSendMessageIconToDevice(eventType = mClickedApp?.evtType!!) { success ->
            Cmds.setNoticeAppName(
                IDONoticeMesaageParamModel(
                    1,
                    1,
                    mClickedApp?.evtType!!,
                    msgID,
                    1,
                    mClickedApp?.appName!!,
                    "",
                    msg,
                    listOf(
                        //此处语言类型与应用名需要根据实际情况进行修改
                        IDONoticeMesaageParamItem(2, mClickedApp?.appName!!)
                    )
                )
            ).send {
                if (it.error.code == 0) {
                    loadingManager.dismiss()
                    app_notification_pop_ll.visibility = View.GONE
                    toast("发送成功～")
                } else {
                    toast("发送失败～")
                }
            }
        }

    }


    private fun setNotificationState(operat: Int, first: Boolean) {
        var idoNoticeMessageStateItemItem = mutableListOf<IDONoticeMessageStateItemItem>()
        //是否第一次进入
        if (first) {
            //改变默认支持应用状态
            apps.forEach {
                if (it.status == 1) {
                    idoNoticeMessageStateItemItem.add(
                        IDONoticeMessageStateItemItem(it.evtType!!, it.status!!, 0)
                    )
                }
            }
        } else {
            //单次选中应用状态更新
            idoNoticeMessageStateItemItem.add(
                IDONoticeMessageStateItemItem(mClickedApp?.evtType!!, mClickedApp?.status!!, 0)
            )
        }
        /**
         * 动态通知操作
         * operat：1：添加 2:修改 3:查询
         * allOnOff:
         *      仅添加和修改
         *      整体通知开关
         *      1：开启所有通知
         *      0：关闭所有通知
         * allSendNum:
         *      总发送包数
         *      分批发送超过100个包
         *      all_send_num = now_send_index表示发送完成
         * nowSendIndex:当前发送顺序
         * items:	IDONoticeMessageStateItem 集合
         *          evtType：事件号
         *          notifyState：通知状态  1：允许通知 2：静默通知 3：关闭通知
         *          picFlag：回复时适用，将此参数设置为0  0：无效  1：下载对应图片  2：无对应图片
         * */
        Cmds.setNoticeMessageState(
            IDONoticeMessageStateParamModel(
                idoNoticeMessageStateItemItem.size,
                operat,
                3,
                idoNoticeMessageStateItemItem.size,
                1,
                1,
                idoNoticeMessageStateItemItem
            )
        ).send { it ->
            loadingManager.dismiss()
            if (it.res?.errCode == 0) {
                //每次修改状态后查询一次应用列表，刷新列表状态
                if (operat != 3) {
                    setNotificationState(3, false)
                } else {
                    //通过状态列表刷新当前应用通知状态
                    for (item1 in apps) {
                        val matchingItem = it.res?.items?.find { it.evtType == item1.evtType }
                        if (matchingItem != null) {
                            item1.status = matchingItem.notifyState
                        }
                    }
                    notificationIconAdapter.notifyDataSetChanged()
                    app_notification_pop_ll.visibility = View.GONE
                    toast("状态修改成功～")

                }
            } else {
                toast("状态修改失败～")
                app_notification_pop_ll.visibility = View.GONE
            }
        }


    }
}