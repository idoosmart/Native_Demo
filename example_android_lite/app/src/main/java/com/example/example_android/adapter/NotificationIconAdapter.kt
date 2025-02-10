package com.example.example_android.adapter

import android.content.Context
import android.graphics.drawable.Drawable
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.example.example_android.R
import com.example.example_android.data.TranIconBean
import com.idosmart.model.IDOAppIconItemModel
import java.io.File


class NotificationIconAdapter(
    private val context: Context,
    private val data: List<TranIconBean>
) : RecyclerView.Adapter<NotificationIconAdapter.ViewHolder>() {

    private var listener: OnItemClickListener? = null

    interface OnItemClickListener {
        fun onItemClick(position: Int)
    }

    fun setOnItemClickListener(listener: OnItemClickListener) {
        this.listener = listener
    }


    override fun onCreateViewHolder(
        parent: ViewGroup,
        viewType: Int
    ): NotificationIconAdapter.ViewHolder {
        val view =
            LayoutInflater.from(context).inflate(R.layout.item_notification_icon, parent, false)
        return ViewHolder(view)
    }

    override fun onBindViewHolder(holder: NotificationIconAdapter.ViewHolder, position: Int) {
        val item = data[position]
        holder.appName.text = item.appName

        holder.appIcon.setImageDrawable(item.icon)

        when (item.status) {
            1 ->
                holder.status.text = "允许"

            2 ->
                holder.status.text = "静默"

            3 ->
                holder.status.text = "关闭"
        }

    }

    override fun getItemCount(): Int = data.size


    inner class ViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        val appName: TextView = itemView.findViewById(R.id.app_name)
        val status: TextView = itemView.findViewById(R.id.app_status)
        val appIcon: ImageView = itemView.findViewById(R.id.app_icon)

        init {
            itemView.setOnClickListener {
                listener?.let {
                    val position = adapterPosition
                    if (position != RecyclerView.NO_POSITION) {
                        it.onItemClick(position)
                    }
                }
            }
        }
    }
}