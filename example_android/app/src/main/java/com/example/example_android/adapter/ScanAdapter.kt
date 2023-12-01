package com.example.example_android.adapter
import android.annotation.SuppressLint
import android.content.Context
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.TextView
import com.example.example_android.R
import com.idosmart.model.IDOBleDeviceModel
import java.util.*

class ScanAdapter(context: Context?, refCourse: MutableList<IDOBleDeviceModel>?) :
    BaseAdapter() {
    private val inflater: LayoutInflater
    private var entities: MutableList<IDOBleDeviceModel>? = null
    private var selectDevice: IDOBleDeviceModel? = null
    fun setEntities(entities: MutableList<IDOBleDeviceModel>?) {
        if (entities != null) {
            this.entities = entities
        } else {
            this.entities = ArrayList<IDOBleDeviceModel>()
        }
    }

    fun upDada(device: IDOBleDeviceModel) {
        entities!!.add(device)
        notifyDataSetChanged()
    }

    fun clear() {
        selectDevice = null
        entities!!.clear()
        notifyDataSetChanged()
    }

    override fun getCount(): Int {
        return entities!!.size
    }

    fun setSelectDevice(device: IDOBleDeviceModel?) {
        selectDevice = device
        notifyDataSetChanged()
    }

    override fun getItem(index: Int): IDOBleDeviceModel {
        return entities!![index]
    }

    override fun getItemId(index: Int): Long {
        return index.toLong()
    }

    @SuppressLint("NewApi")
    override fun getView(position: Int, convertView: View, arg2: ViewGroup): View {
        var convertView = convertView
        var holder: ViewHolder? = null
        if (convertView == null) {
            convertView = inflater.inflate(R.layout.item_device, null)
            var holder = ViewHolder()
            holder.tvName = convertView.findViewById<View>(R.id.tv_basic_name) as TextView
            holder.tvMac = convertView.findViewById<View>(R.id.tv_basic_mac) as TextView
            holder.view = convertView.findViewById(R.id.view_select) as View
            holder.tvRssi = convertView.findViewById<View>(R.id.tvRssi) as TextView
            convertView.tag = holder
        } else {
            holder = convertView.tag as ViewHolder
        }
        val idoBleDeviceModel: IDOBleDeviceModel = entities!![position]
        Log.d("ScanAdapter",idoBleDeviceModel.toString())
        holder!!.tvName?.setText(idoBleDeviceModel?.name)
        holder!!.tvMac?.setText(idoBleDeviceModel?.macAddress)
        holder!!.tvRssi?.setText(idoBleDeviceModel?.rssi.toString() + "")
        if (selectDevice != null && selectDevice?.macAddress.equals(idoBleDeviceModel?.macAddress)) {
            holder.view!!.visibility = View.VISIBLE
        } else {
            holder.view!!.visibility = View.GONE
        }
        return convertView
    }

    internal inner class ViewHolder {
        var tvName: TextView? = null
        var tvMac: TextView? = null
        var view: View? = null
        var tvRssi: TextView? = null
    }

    init {
        setEntities(refCourse)
        inflater = LayoutInflater.from(context)
    }
}