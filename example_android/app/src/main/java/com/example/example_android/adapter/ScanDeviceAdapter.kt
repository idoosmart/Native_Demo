package com.example.example_android.adapter

import android.annotation.SuppressLint
import android.graphics.Color
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.R
import com.idosmart.model.IDOBleDeviceModel

class ScanDeviceAdapter(
    var mDeviceList: MutableList<IDOBleDeviceModel?>,
    private val boundStyle: Boolean = false
) : RecyclerView.Adapter<ScanDeviceAdapter.DeviceViewHodler>() {

    private var mOnSelectDeviceListenter: onSelectDeviceListenter? = null
    private var selectedDevice: IDOBleDeviceModel? = null

    override fun onBindViewHolder(holder: DeviceViewHodler, @SuppressLint("RecyclerView") position: Int) {
        val course: IDOBleDeviceModel? = mDeviceList[position]
        holder.tvName?.text = course?.name
        holder.tvMac?.text = course?.macAddress
        if (boundStyle) {
            holder.itemView.setBackgroundColor(Color.parseColor("#E8F4FF"))
            holder.tvRssi?.text = "Bound"
        } else {
            holder.itemView.setBackgroundColor(Color.WHITE)
            holder.tvRssi?.text = course?.rssi.toString()
        }
        holder.view.visibility =
            if (selectedDevice?.macAddress.equals(course?.macAddress)) View.VISIBLE else View.GONE
        holder.itemView.setOnClickListener {
            Log.d("ScanAdapter", "select")
            mOnSelectDeviceListenter?.select(position)
        }
    }

    fun setOnSelectDeviceListenter(listenter: onSelectDeviceListenter) {
        this.mOnSelectDeviceListenter = listenter
    }

    override fun getItemCount(): Int = mDeviceList.size

    fun updateData(list: MutableList<IDOBleDeviceModel?>) {
        this.mDeviceList = list
        notifyDataSetChanged()
    }

    fun setSelectDevice(bleDevice: IDOBleDeviceModel) {
        this.selectedDevice = bleDevice
        notifyDataSetChanged()
    }

    interface onSelectDeviceListenter {
        fun select(position: Int)
    }

    fun clear() {
        this.selectedDevice = null
        this.mDeviceList.clear()
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DeviceViewHodler {
        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_device, parent, false)
        return DeviceViewHodler(view)
    }

    class DeviceViewHodler(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val tvName = itemView.findViewById<TextView>(R.id.tv_basic_name)
        val tvMac = itemView.findViewById<TextView>(R.id.tv_basic_mac)
        val view = itemView.findViewById<View>(R.id.view_select)
        val tvRssi = itemView.findViewById<TextView>(R.id.tvRssi)
    }
}
