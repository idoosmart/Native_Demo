package com.example.example_android.adapter

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.R
import com.example.example_android.data.GetFuntionData
import com.example.example_android.data.IDoDataBean

class GetFuntionAdapter(var getFuntionList: MutableList<IDoDataBean>) : RecyclerView.Adapter<GetFuntionViewHodler>() {
    private var itemClickListener :onItemClickListener ?= null
    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): GetFuntionViewHodler {
         return GetFuntionViewHodler(LayoutInflater.from(parent.context).inflate(R.layout.layout_item_get_function,parent,false))
    }

    override fun getItemCount(): Int {
      return  getFuntionList.size
    }

    fun setonItemClickListener(itemClickListener: onItemClickListener){
        this.itemClickListener = itemClickListener
    }

    override fun onBindViewHolder(holder: GetFuntionViewHodler, position: Int) {
        var  function  = getFuntionList[position]
         holder.title.text = function.title
        holder.tv_sub_title.text = function.sub_title
        holder.itemView.setOnClickListener(object : View.OnClickListener {
            override fun onClick(view: View) {
                itemClickListener?.onItemClick(position)
            }
        })
    }

    interface  onItemClickListener{
        fun onItemClick( position: Int)
    }
}


class GetFuntionViewHodler(itemView:View) :RecyclerView.ViewHolder(itemView) {
    var title = itemView.findViewById<TextView>(R.id.tv_title)
    var tv_sub_title = itemView.findViewById<TextView>(R.id.tv_sub_title)
}
