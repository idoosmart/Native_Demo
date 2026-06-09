package com.example.example_android.adapter

import android.annotation.SuppressLint
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

    override fun onBindViewHolder(holder: GetFuntionViewHodler, @SuppressLint("RecyclerView") position: Int) {
        val function = getFuntionList[position]
        holder.title.text = function.title
        holder.tv_sub_title.text = function.sub_title
        holder.tv_sub_title.visibility = if (function.sub_title.isNullOrEmpty()) View.GONE else View.VISIBLE
        
        if (function.isSupported) {
            holder.title.alpha = 1.0f
            holder.tv_sub_title.alpha = 1.0f
        } else {
            holder.title.alpha = 0.4f
            holder.tv_sub_title.alpha = 0.4f
        }

        holder.itemView.setOnClickListener {
            itemClickListener?.onItemClick(position)
        }
    }

    interface  onItemClickListener{
        fun onItemClick( position: Int)
    }
}


class GetFuntionViewHodler(itemView:View) :RecyclerView.ViewHolder(itemView) {
    var title = itemView.findViewById<TextView>(R.id.tv_title)
    var tv_sub_title = itemView.findViewById<TextView>(R.id.tv_sub_title)
}
