package com.example.example_android.sport;

import android.content.Intent;
import android.os.Bundle;
import android.os.Parcelable;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.example.example_android.R;
import com.example.example_android.base.BaseActivity;
import com.google.gson.Gson;
import com.idosmart.model.IDOSportScreenInfoReplyModel;
import com.idosmart.model.IDOSportScreenItemReply;
import com.idosmart.pigeon_implement.CmdResponse;
import com.idosmart.pigeon_implement.Cmds;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

import kotlin.Unit;
import kotlin.jvm.functions.Function1;


public class EditSportListActivity extends BaseActivity {
    private String TAG = getClass().getSimpleName();
    private RecyclerView recyclerView;
    private ArrayList<IDOSportScreenItemReply> list = new ArrayList<>();
    private Adapter adapter;
    IDOSportScreenInfoReplyModel replyModel;
    @Override
    public void initView() {
        super.initView();
        recyclerView = findViewById(R.id.recyclerview);
        adapter = new Adapter();
        recyclerView.setAdapter(adapter);
        loadData();
    }

    private void getBaseData() {
        showProgressCanCancelDialog("getting data");
        Cmds.getSportScreenBaseInfo getSportScreenBaseInfo = new Cmds.getSportScreenBaseInfo();
        getSportScreenBaseInfo.send(idoSportScreenInfoReplyModelCmdResponse -> {
            closeProgressDialog();
            //{"error":{"code":0,"message":"success"},"res":{"err_code":0,"max_data_num":4,"max_screen_num":4,"min_data_num":1,"min_screen_num":1,"operate":0,"screen_conf":[{"layout_type":1,"style":1},{"layout_type":2,"style":1}],"screen_conf_num":2,"sport_item":[{"screen_item":[{"data_item":[{"data_sub_type":1,"data_type":1},{"data_sub_type":1,"data_type":2}],"data_item_count":2},{"data_item":[{"data_sub_type":1,"data_type":3},{"data_sub_type":2,"data_type":4}],"data_item_count":2}],"screen_num":2,"sport_type":1,"support_data_type_num":2,"support_data_type":[{"data_type":1,"data_value":1},{"data_type":2,"data_value":1}]},{"screen_item":[{"data_item":[{"data_sub_type":1,"data_type":1},{"data_sub_type":1,"data_type":2}],"data_item_count":2},{"data_item":[{"data_sub_type":1,"data_type":3},{"data_sub_type":2,"data_type":4}],"data_item_count":2}],"screen_num":2,"sport_type":1,"support_data_type_num":2,"support_data_type":[{"data_type":1,"data_value":1},{"data_type":2,"data_value":1}]}],"sport_num":2,"version":0}}
            Log.i(TAG,"idoSportScreenInfoReplyModelCmdResponse : " + new Gson().toJson(idoSportScreenInfoReplyModelCmdResponse));
            if(idoSportScreenInfoReplyModelCmdResponse.getRes() != null && idoSportScreenInfoReplyModelCmdResponse.getRes().getSportItems().size() > 0){
                replyModel = idoSportScreenInfoReplyModelCmdResponse.getRes();
                list.clear();
                list.addAll(idoSportScreenInfoReplyModelCmdResponse.getRes().getSportItems());
                adapter.notifyDataSetChanged();
            };
            return null;
        });
    }

    private void loadData() {
        getBaseData();
    }

    @Override
    public int getLayoutId() {
        return R.layout.activity_edit_sport_list;
    }


    class Adapter extends RecyclerView.Adapter<Adapter.VH> {

        @NonNull
        @Override
        public VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new VH(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_edit_sport_list, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull VH holder, int position) {
            IDOSportScreenItemReply item = list.get(position);
            int strId = getResources().getIdentifier("motion_"+ item.getSportType(), "string",
                    getPackageName());
            holder.tvName.setText(EditSportListActivity.this.getString(strId));
//            holder.tvName.setText(item.getSportType() + "");
        }

        @Override
        public int getItemCount() {
            return list.size();
        }

        class VH extends RecyclerView.ViewHolder {
            TextView tvName;

            public VH(@NonNull View itemView) {
                super(itemView);
                tvName = itemView.findViewById(R.id.tvName);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        Intent intent = new Intent(EditSportListActivity.this, EditSportActivity.class).putExtra("type",
                                list.get(getAdapterPosition()).getSportType());
                        if(replyModel != null){
                            intent.putExtra("MaxScreenNum",replyModel.getMaxScreenNum());
                            intent.putExtra("list",(Serializable) replyModel.getScreenConfItems());
//                            intent.putExtra("replyModel", replyModel);
                        }
                        startActivity(intent);
                    }
                });
            }
        }
    }
}
