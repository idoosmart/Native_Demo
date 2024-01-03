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
import com.idosmart.model.IDOBleDeviceModel


class ScanDeviceAdapter(var mDeviceList  :MutableList<BleDevice?> ): RecyclerView.Adapter<ScanDeviceAdapter.DeviceViewHodler>() {

    private var mOnSelectDeviceListenter :onSelectDeviceListenter?=null
    private var selectedDevice :BleDevice ?=null
    override fun onBindViewHolder(holder: DeviceViewHodler, @SuppressLint("RecyclerView") position: Int) {
        val course: BleDevice? = mDeviceList[position]

        holder.tvName?.setText(course?.name)
        holder.tvMac?.setText(course?.mac)
        holder.tvRssi?.setText(course?.rssi.toString())
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
        return mDeviceList.size
    }

    fun updateData( list  :MutableList<BleDevice?>){
        this.mDeviceList = list
        this.notifyDataSetChanged()
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