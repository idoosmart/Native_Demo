package com.example.example_android.widget;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.widget.PopupWindow;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;


import com.example.example_android.R;
import com.example.example_android.util.SportScreenSetUtil;
import com.example.example_android.util.SportScreenUtil;
import com.idosmart.model.IDODataSubType;
import com.idosmart.model.IDODataType;
import com.idosmart.model.IDOSportScreenDataItemModel;
import com.idosmart.model.IDOSportScreenDataType;

import java.util.ArrayList;
import java.util.List;


public class DataItemSelectPop {
    private PopupWindow popupWindow;
    private Dialog dialog;
    private Context mContext;
    private RecyclerView recyclerView1, recyclerView2;
    private MyAdapter adapter1;
    private MyAdapter2 adapter2;
    private List<TypeItem> typeItems = new ArrayList<>();
    private List<SubTypeItem> subTypeItems = new ArrayList<>();
    private List<IDOSportScreenDataType> allSupportList = new ArrayList<>();
    private IDOSportScreenDataItemModel curData ;

    public DataItemSelectPop(Context context) {
        mContext = context;
        init();
    }
    public void init() {
        dialog = new Dialog(mContext);
        dialog.requestWindowFeature(Window.FEATURE_NO_TITLE); // 隐藏标题栏
        // 加载自定义布局
        LayoutInflater inflater = LayoutInflater.from(mContext);
        View view = inflater.inflate(R.layout.dialog_bottom_sheet, null);
        dialog.setContentView(view);

        recyclerView1 = view.findViewById(R.id.rv1);
        recyclerView2 = view.findViewById(R.id.rv2);
        recyclerView1.setLayoutManager(new LinearLayoutManager(mContext));
        recyclerView2.setLayoutManager(new LinearLayoutManager(mContext));
        adapter1 = new MyAdapter(typeItems);
        adapter2 = new MyAdapter2(subTypeItems);
        recyclerView1.setAdapter(adapter1);
        recyclerView2.setAdapter(adapter2);
        Window window = dialog.getWindow();
        if (window != null) {
            window.setGravity(Gravity.BOTTOM); // 设置显示在底部
            window.setLayout(WindowManager.LayoutParams.MATCH_PARENT, /*WindowManager.LayoutParams.WRAP_CONTENT*/1000);
            window.setBackgroundDrawableResource(android.R.color.transparent); // 设置背景透明
            window.setWindowAnimations(R.style.DialogAnimationsFade); // 设置动画
        }
    }

    // 显示 PopupWindow
    public void show(View anchorView) {
        if (dialog != null && !dialog.isShowing()) {
            dialog.show();
        }
    }

    // 关闭 PopupWindow
    public void dismiss() {
        if (dialog != null && dialog.isShowing()) {
            dialog.dismiss();
        }
    }


    public void setListData(List<IDOSportScreenDataType> allSupportList, IDOSportScreenDataItemModel curData){
        this.allSupportList = allSupportList;
        this.curData = curData;
        typeItems.clear();
        subTypeItems.clear();
        for (int i = 0; i < allSupportList.size(); i++) {
            TypeItem typeItem = new TypeItem();
            IDOSportScreenDataType item = allSupportList.get(i);
            typeItem.content = getDataType(item.getDataType());
            if(curData != null){
                typeItem.isSelect = curData.getDataType() == item.getDataType();

                if(curData.getDataType() == item.getDataType()){
                    List<com.idosmart.model.IDODataSubType> subTypeList = item.getDataValue();
                    for (int k = 0; k < subTypeList.size(); k++) {
                        IDODataSubType idoDataSubType = subTypeList.get(k);
                        SubTypeItem subTypeItem = new SubTypeItem();
                        subTypeItem.content = getSubDataType(idoDataSubType);
                        subTypeItem.isSelect = curData.getSubType() == idoDataSubType;
                        subTypeItem.subType = idoDataSubType;
                        subTypeItems.add(subTypeItem);
                    }
                }
            }
            typeItems.add(typeItem);
        }
        adapter1 = new MyAdapter(typeItems);
        adapter2 = new MyAdapter2(subTypeItems);
        recyclerView1.setAdapter(adapter1);
        recyclerView2.setAdapter(adapter2);
    }


    private class MyAdapter extends RecyclerView.Adapter<MyAdapter.ViewHolder> {
        private List<TypeItem> items;

        MyAdapter(List<TypeItem> items) {
            this.items = items;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_data_type_item, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            holder.textView.setText(items.get(position).content);
            holder.textView.setTextColor(items.get(position).isSelect? Color.BLUE:Color.WHITE);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    TypeItem typeItem = typeItems.get(holder.getAdapterPosition());
                    for (int i = 0; i < typeItems.size(); i++) {
                        typeItems.get(i).isSelect = false;
                    }
                    typeItem.isSelect = true;
                    curData = new IDOSportScreenDataItemModel(allSupportList.get(holder.getAdapterPosition()).getDataType(),IDODataSubType.NONE);
                    curData.setDataType(allSupportList.get(holder.getAdapterPosition()).getDataType());
//                    curData.setSubType(IDODataSubType);
                    setListData(allSupportList,curData);
                    adapter2.notifyDataSetChanged();
                }
            });
        }

        @Override
        public int getItemCount() {
            return items.size();
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            TextView textView;

            ViewHolder(View itemView) {
                super(itemView);
                textView = itemView.findViewById(R.id.tv_content);
            }
        }
    }
    private class MyAdapter2 extends RecyclerView.Adapter<MyAdapter2.ViewHolder> {
        private List<SubTypeItem> items;

        MyAdapter2(List<SubTypeItem> items) {
            this.items = items;
        }

        @NonNull
        @Override
        public ViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.item_data_type_item, parent, false);
            return new ViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ViewHolder holder, int position) {
            holder.textView.setText(items.get(position).content);
            holder.textView.setTextColor(items.get(position).isSelect? Color.BLUE:Color.WHITE);
            holder.itemView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    if(listener != null){
                        curData.setSubType(items.get(holder.getAdapterPosition()).subType);
                        listener.onSelect(holder.getAdapterPosition(),curData);
                        dismiss();
                    }
                }
            });
        }

        @Override
        public int getItemCount() {
            return items.size();
        }

        class ViewHolder extends RecyclerView.ViewHolder {
            TextView textView;

            ViewHolder(View itemView) {
                super(itemView);
                textView = itemView.findViewById(R.id.tv_content);
            }
        }
    }

    public static class TypeItem{
        public int type;
        public String content = "";
        public boolean isSelect = false;
    }
    public class SubTypeItem{
        public int type;
        public String content = "";
        public IDODataSubType subType;
        public boolean isSelect = false;
    }


    OnSelectTypeListener listener;

    public interface OnSelectTypeListener {
        void onSelect(int index,IDOSportScreenDataItemModel dataItem);
    }

    public void setListener(OnSelectTypeListener listener) {
        this.listener = listener;
    }

    public String getDataType(IDODataType type){
        if(type == null){
            return "--";
        }
        int strId = SportScreenSetUtil.SPORT_DATA_S.get(type);
        return mContext.getString(strId);
    }

    public String getSubDataType(IDODataSubType type){
        if(type == null){
            return "--";
        }
        int strId = SportScreenSetUtil.SPORT_DATA_S_SUB.get(type);
        return mContext.getString(strId);
    }
}
