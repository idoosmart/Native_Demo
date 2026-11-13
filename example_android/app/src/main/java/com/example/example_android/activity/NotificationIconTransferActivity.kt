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
import com.idosmart.model.IDOOtaDeviceModel
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
    //Languages supported by the device
    private val languages: List<Int> = ArrayList()


    override fun getLayoutId(): Int {
        return R.layout.activity_notification_icon_transfer
    }


    override fun initView() {
        super.initView()

        //解绑数据要调用sdk.messageIcon.resetIconInfoData方法清除icon本地缓存
        //When unbinding, call the sdk.messageIcon.resetIconInfoData method to clear the local icon cache

        loadingManager = LoadingManager(this)

        sdk.bridge.setupBridge(BleData(), IDOLogType.DEBUG)
        Log.d(TAG, "getFastMsgDataV3: ${sdk.funcTable.getFastMsgDataV3}")
        //功能表判断该设备是否支持消息快捷回复功能
        //Check the function table to see whether the device supports message quick reply
        if (!sdk.funcTable.getFastMsgDataV3) {
            app_notification_pop_sendMsg_quick.visibility = View.GONE
        }
        loadingManager.show()
        //获取应用列表之前需要给出应用列表读取权限以及在配置清单文件中给出对应权限才能正常拿到所有应用
        //Before getting the app list, grant the app-list read permission and declare the corresponding permission in the manifest, otherwise not all apps can be retrieved
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
            //Add default apps
            setNotificationState(1, true)
            //刷新应用列表
            //Refresh the app list
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
                    //Allow notifications
                    app_notification_pop_allow.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 1
                        setNotificationState(2, false)
                    }
                    //静默通知
                    //Silent notifications
                    app_notification_pop_silent.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 2
                        setNotificationState(2, false)
                    }
                    //关闭通知
                    //Turn off notifications
                    app_notification_pop_clos.setOnClickListener {
                        loadingManager.show()
                        mClickedApp?.status = 3
                        setNotificationState(2, false)
                    }
                    //快捷回复通知
                    //Quick reply notification
                    app_notification_pop_sendMsg_quick.setOnClickListener {
                        loadingManager.show()
                        sendMsg(app_notification_pop_content.text.toString(), 1)
                    }
                    //发送普通通知
                    //Send a normal notification
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
        //Get the language library supported by the device
        if (sdk.funcTable.getSupportGetUnit) {
            getLanguageLibrary()
        }
    }


    private fun getLanguageLibrary() {
        Cmds.getUnit().send { it ->
            if (it.error.code == 0) {
                // 成功
                // Succeeded
                Log.d(TAG, "getLanguageLibrary: ${it.res?.language}")

            } else {
                // 失败
                // Failed
                Log.d(TAG, "getLanguageLibrary: ${it.res?.toJsonString()}")
            }
        }
    }

    //快捷消息回复回调
    //Quick message reply callback
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
            // Quick SMS reply
            if (status.controlEvt == 580 && status.controlJson != null) {
                println("status.controlJson: ${status.controlJson}")
                val gson = Gson()
                val msgItem = gson.fromJson(status.controlJson, IDOFastMsgUpdateModel::class.java)
                // 1 表示来电快捷回复
                // 1 means incoming call quick reply
                if (msgItem.msgType == 1) {
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果 / TODO: call the android system here to send the quick reply to the third-party app and get the reply result
                    // val isSuccess = if (回复结果) 1 else 0
                    // val isSuccess = if (reply result) 1 else 0
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
                    // Third-party message
                    // TODO：此处调用android系统发送快捷回复到第三app，并获取到回复结果 / TODO: call the android system here to send the quick reply to the third-party app and get the reply result
                    // val isSuccess = if (回复结果) 1 else 0
                    // val isSuccess = if (reply result) 1 else 0
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

        override fun listenWaitingOtaDevice(otaDevice: IDOOtaDeviceModel) {
            println("listenWaitingOtaDevice ${otaDevice.toString()}");
        }
    }




    /**
     * msg: 发送的内容
     * msg: content to send
     * msgID: 0->普通通知  1:快捷回复消息
     * msgID: 0->normal notification  1:quick reply message
     *
     * */
    private fun sendMsg(msg: String, msgID: Int) {

        if (msgID != 0) {

            val param = IDOFastMsgSettingModel(
                1, listOf(
                    IDOFastMsgItem(1, "ok"),
                )
            )
            //设置默认快捷消息回复列表
            //Set the default quick message reply list
            Cmds.setDefaultQuickMsgReplyList(param).send {
                if (it.error.code == 0) {
                    // 成功
                    // Succeeded
                    // it.res is IDOCmdSetResponseModel

                } else {
                    // 失败
                    // Failed
                    toast("快捷消息回复列表设置失败～ / Failed to set the quick message reply list")
                }
            }
        }

        /**
         * 每次下发通知消息，执行事件类型
         * Each time a notification message is sent, execute the event type
         * 事件类型就是上面items获取到的，事件类型和每个APP应用关联的，所以告诉事件类型就知道哪个应用的通知
         * The event type is the one obtained from items above; each event type is associated with an APP, so the event type tells which app the notification belongs to
         * 下发这个事件类型，为判断APP图标是否更新到，如果未更新APP图标，SDK则会下发对应的APP图标
         * Send this event type to check whether the APP icon has been updated; if not, the SDK sends the corresponding APP icon
         * 实体类参数解释请参考开发说明文档
         * For the entity class parameters, refer to the development documentation
         *
         * verison	Int	协议库版本号
         * verison	Int	Protocol library version number
         * osPlatform	Int	系统0：无效，1：Android，2：iOS
         * osPlatform	Int	System 0: invalid, 1: Android, 2: iOS
         * evtType	Int	当前模式 0：无效，1：消息提醒
         * evtType	Int	Current mode 0: invalid, 1: message reminder
         * notifyType	Int	消息枚举类型 最大值：20000
         * notifyType	Int	Message enum type, max: 20000
         * msgID	Int	消息ID 仅当evt_type为消息提醒且msg_ID不为0时有效
         * msgID	Int	Message ID, valid only when evt_type is message reminder and msg_ID is not 0
         * appItemsLen	Int	国家/地区数量和语言详细信息
         * appItemsLen	Int	Number of countries/regions and language details
         * contact	String	联系人姓名（最大 63 字节）
         * contact	String	Contact name (max 63 bytes)
         * phoneNumber	String	电话号码（最大 31 字节）
         * phoneNumber	String	Phone number (max 31 bytes)
         * msgData	String	消息内容（最大249字节）
         * msgData	String	Message content (max 249 bytes)
         * items: IDONoticeMesaageParamItem 语言列表
         * items: IDONoticeMesaageParamItem language list
         *      language	Int	语言类型
         *      language	Int	Language type
         *      name	String	国家对应的应用名称（最大49字节）
         *      name	String	App name for the country (max 49 bytes)
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
                    "13888888888",
                    msg,
                    listOf(
                        //此处语言类型与应用名需要根据实际情况进行修改
                        //The language type and app name here must be changed according to the actual situation
                        IDONoticeMesaageParamItem(2, mClickedApp?.appName!!)
                    )
                )
            ).send {
                if (it.error.code == 0) {
                    loadingManager.dismiss()
                    app_notification_pop_ll.visibility = View.GONE
                    toast("发送成功～ / Send succeeded")
                } else {
                    toast("发送失败～ / Send failed")
                }
            }
        }

    }


    private fun setNotificationState(operat: Int, first: Boolean) {
        var idoNoticeMessageStateItemItem = mutableListOf<IDONoticeMessageStateItemItem>()
        //是否第一次进入
        //Whether entering for the first time
        if (first) {
            //改变默认支持应用状态
            //Change the status of default supported apps
            apps.forEach {
                if (it.status == 1) {
                    idoNoticeMessageStateItemItem.add(
                        IDONoticeMessageStateItemItem(it.evtType!!, it.status!!, 0)
                    )
                }
            }
        } else {
            //单次选中应用状态更新
            //Update the status of a single selected app
            idoNoticeMessageStateItemItem.add(
                IDONoticeMessageStateItemItem(mClickedApp?.evtType!!, mClickedApp?.status!!, 0)
            )
        }
        /**
         * 动态通知操作
         * Dynamic notification operation
         * operat：1：添加 2:修改 3:查询
         * operat: 1: add 2:modify 3:query
         * allOnOff:
         *      仅添加和修改
         *      Add and modify only
         *      整体通知开关
         *      Master notification switch
         *      1：开启所有通知
         *      1: turn on all notifications
         *      0：关闭所有通知
         *      0: turn off all notifications
         * allSendNum:
         *      总发送包数
         *      Total number of packets to send
         *      分批发送超过100个包
         *      Sent in batches if more than 100 packets
         *      all_send_num = now_send_index表示发送完成
         *      all_send_num = now_send_index means sending is complete
         * nowSendIndex:当前发送顺序
         * nowSendIndex:current send index
         * items:	IDONoticeMessageStateItem 集合
         * items:	IDONoticeMessageStateItem collection
         *          evtType：事件号
         *          evtType: event number
         *          notifyState：通知状态  1：允许通知 2：静默通知 3：关闭通知
         *          notifyState: notification status  1: allow notifications 2: silent notifications 3: turn off notifications
         *          picFlag：回复时适用，将此参数设置为0  0：无效  1：下载对应图片  2：无对应图片
         *          picFlag: applies when replying, set this parameter to 0  0: invalid  1: download the corresponding image  2: no corresponding image
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
                //Query the app list once after each status change to refresh the list status
                if (operat != 3) {
                    setNotificationState(3, false)
                } else {
                    //通过状态列表刷新当前应用通知状态
                    //Refresh the current app notification status from the status list
                    for (item1 in apps) {
                        val matchingItem = it.res?.items?.find { it.evtType == item1.evtType }
                        if (matchingItem != null) {
                            item1.status = matchingItem.notifyState
                        }
                    }
                    notificationIconAdapter.notifyDataSetChanged()
                    app_notification_pop_ll.visibility = View.GONE
                    toast("状态修改成功～ / Status change succeeded")

                }
            } else {
                toast("状态修改失败～ / Status change failed")
                app_notification_pop_ll.visibility = View.GONE
            }
        }


    }
}