package com.example.example_android.adapter

import android.annotation.SuppressLint
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.clj.fastble.data.BleDevice
import com.example.example_android.R
import com.example.example_android.util.BoundDeviceInfo


class ScanDeviceAdapter(
    var mDeviceList: MutableList<BleDevice?> = mutableListOf(),
    private val boundStyle: Boolean = false
) : RecyclerView.Adapter<ScanDeviceAdapter.DeviceViewHodler>() {

    private var mOnSelectDeviceListenter :onSelectDeviceListenter?=null
    private var selectedDevice :BleDevice ?=null
    private var boundItems = mutableListOf<BoundDeviceInfo>()

    override fun onBindViewHolder(holder: DeviceViewHodler, @SuppressLint("RecyclerView") position: Int) {
        if (boundStyle) {
            val item = boundItems.getOrNull(position) ?: return
            holder.tvName?.setText(item.name)
            holder.tvMac?.setText(item.mac)
            holder.tvRssi?.setText("Bound")
            holder.itemView.setBackgroundColor(android.graphics.Color.parseColor("#E8F4FF"))
            holder.view.visibility = View.GONE
            holder.itemView.setOnClickListener {
                mOnSelectDeviceListenter?.select(position)
            }
            return
        }

        val course: BleDevice? = mDeviceList[position]

        holder.tvName?.setText(course?.name)
        holder.tvMac?.setText(course?.mac)
        holder.tvRssi?.setText(course?.rssi.toString())
        holder.itemView.setBackgroundColor(android.graphics.Color.WHITE)
        if (selectedDevice?.mac.equals(course?.mac)){
            holder.view.visibility = View.VISIBLE
        }else{
            holder.view.visibility = View.GONE
        }
        holder.itemView.setOnClickListener(object :View.OnClickListener{
            override fun onClick(view: View?) {
                Log.d("ScanAdapter","dddddddddddddd")
                mOnSelectDeviceListenter?.select(position)
            }
        })
    }
    fun  setOnSelectDeviceListenter(listenter: onSelectDeviceListenter){
        this.mOnSelectDeviceListenter =listenter
    }

    override fun getItemCount(): Int {
        return if (boundStyle) boundItems.size else mDeviceList.size
    }

    fun updateData( list  :MutableList<BleDevice?>){
        this.mDeviceList = list
        this.notifyDataSetChanged()
    }

    fun setBoundData(list: List<BoundDeviceInfo>) {
        boundItems = list.toMutableList()
        notifyDataSetChanged()
    }

    fun getBoundItem(position: Int): BoundDeviceInfo? {
        return boundItems.getOrNull(position)
    }

    fun  setSelectDevice(bleDevice: BleDevice){
        this.selectedDevice =bleDevice
        notifyDataSetChanged()
    }
    interface  onSelectDeviceListenter{
        fun  select(position :Int)
    }

    fun clear() {
        this.selectedDevice = null
        this.mDeviceList.clear()
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): DeviceViewHodler {
        val view: View = LayoutInflater.from(parent.getContext())
            .inflate(R.layout.item_device, parent, false)
        val holder = DeviceViewHodler(view)
        return holder;
    /*    return DeviceViewHodler(
            LayoutInflater.from(parent.context).inflate(R.layout.item_device, null, false)
        )*/
    }
     class DeviceViewHodler(itemView: View) : RecyclerView.ViewHolder(itemView) {
         val  tvName =  itemView.findViewById<TextView>(R.id.tv_basic_name)
         val  tvMac =  itemView.findViewById<TextView>(R.id.tv_basic_mac)
         val  view =  itemView.findViewById<View>(R.id.view_select)
         val  tvRssi =  itemView.findViewById<TextView>(R.id.tvRssi)

    }
}
