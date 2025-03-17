package com.example.example_android.sport;

import android.app.AlertDialog;
import android.content.DialogInterface;
import android.graphics.Color;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.example.example_android.R;
import com.example.example_android.base.BaseActivity;
import com.example.example_android.widget.DataItemSelectPop;
import com.example.example_android.widget.SportScreenView;
import com.google.gson.Gson;
import com.idosmart.model.IDODataSubType;
import com.idosmart.model.IDODataType;
import com.idosmart.model.IDOSportScreenDataItemModel;
import com.idosmart.model.IDOSportScreenDataType;
import com.idosmart.model.IDOSportScreenInfoReplyModel;
import com.idosmart.model.IDOSportScreenItemModel;
import com.idosmart.model.IDOSportScreenItemReply;
import com.idosmart.model.IDOSportScreenLayoutType;
import com.idosmart.model.IDOSportScreenSportItemModel;
import com.idosmart.pigeon_implement.Cmds;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class EditSportActivity extends BaseActivity {
    private Button btStyle,btSave;
    private final String TAG = "EditSportActivity";

    IDOSportScreenInfoReplyModel sportScreenSettingReply;
    IDOSportScreenItemReply sportScreenItemReply;
    List<IDOSportScreenLayoutType> allSupportScreenLayoutList;
    List<IDOSportScreenDataType> allSupportDataItem;
    private RecyclerView recyclerview;
    private Adapter screenAdapter;
    boolean isAddMode = false;

    private SportScreenView ssv;
    private int curScreen = 0;
    private int sportType;
    private int maxScreenNum;
    private int defaultStyle = 0;
    @Override
    public int getLayoutId() {
        return R.layout.activity_edit_sport;
    }

    @Override
    public void initView() {
        super.initView();
        sportType = getIntent().getIntExtra("type", 1);
        maxScreenNum = getIntent().getIntExtra("MaxScreenNum",6);
        allSupportScreenLayoutList = (List<IDOSportScreenLayoutType>) getIntent().getSerializableExtra("list");
        Log.d(TAG,"allScreenList : " + new Gson().toJson(allSupportScreenLayoutList));
        Log.d(TAG,"sportType : " + sportType + " , maxScreenNum = " + maxScreenNum);
        recyclerview = findViewById(R.id.recyclerview);
        ssv = findViewById(R.id.ssv);
        btSave = findViewById(R.id.bt_save);
        btStyle = findViewById(R.id.bt_style);
        btStyle.setOnClickListener(v -> {
            showStyleList();
        });

        btSave.setOnClickListener(v -> {
            List<IDOSportScreenSportItemModel> idoSportScreenSportItemModels = new ArrayList<>();
            if(sportScreenItemReply != null){
                List<com.idosmart.model.IDOSportScreenItemModel> screenItems= sportScreenItemReply.getScreenItems();
                IDOSportScreenSportItemModel sendScreenModeItem = new IDOSportScreenSportItemModel(sportType,screenItems);
                idoSportScreenSportItemModels.add(sendScreenModeItem);
                Log.i(TAG, "send data :" + new Gson().toJson(idoSportScreenSportItemModels));
                if(!checkNoneDataItem(screenItems)){
                    Toast.makeText(EditSportActivity.this,"has none data ",Toast.LENGTH_SHORT).show();
                    return;
                }
                Cmds.setSportScreen  setSportScreen = new Cmds.setSportScreen(idoSportScreenSportItemModels);
                showProgressCanCancelDialog("sending data");
                setSportScreen.send(idoCmdSetResponseModelCmdResponse -> {
                    closeProgressDialog();
                    Log.i(TAG, "send data reply : " + new Gson().toJson(idoSportScreenSportItemModels));
                    return null;
                });
            }

        });
        getScreenDetailData();
    }
    private void initMockData(){

    }

    private boolean checkNoneDataItem(List<com.idosmart.model.IDOSportScreenItemModel> screenItemModels){
        for (IDOSportScreenItemModel screenItemModel : screenItemModels) {
            for (IDOSportScreenDataItemModel dataItemModel : screenItemModel.getDataItem()) {
                if(dataItemModel.getDataType() == IDODataType.NONE || dataItemModel.getSubType() == IDODataSubType.NONE){
                    return false;
                }
            }
        }
        return true;
    }

    private void getScreenDetailData(){
        showProgressCanCancelDialog("getting data");
        List<IDOSportScreenSportItemModel> curSport = new ArrayList<>();
        IDOSportScreenSportItemModel sportItemModel = new IDOSportScreenSportItemModel(sportType,new ArrayList<>());
        curSport.add(sportItemModel);
        Cmds.getSportScreenDetailInfo getSportScreenDetailInfo = new Cmds.getSportScreenDetailInfo(curSport);

        getSportScreenDetailInfo.send(idoSportScreenInfoReplyModelCmdResponse -> {
            closeProgressDialog();
            //{"error":{"code":0,"message":"success"},"res":{"err_code":0,"max_data_num":4,"max_screen_num":4,"min_data_num":1,"min_screen_num":1,"operate":0,"screen_conf":[{"layout_type":1,"style":1},{"layout_type":2,"style":1}],"screen_conf_num":2,"sport_item":[{"screen_item":[{"data_item":[{"data_sub_type":1,"data_type":1},{"data_sub_type":1,"data_type":2}],"data_item_count":2},{"data_item":[{"data_sub_type":1,"data_type":3},{"data_sub_type":2,"data_type":4}],"data_item_count":2}],"screen_num":2,"sport_type":1,"support_data_type_num":2,"support_data_type":[{"data_type":1,"data_value":1},{"data_type":2,"data_value":1}]},{"screen_item":[{"data_item":[{"data_sub_type":1,"data_type":1},{"data_sub_type":1,"data_type":2}],"data_item_count":2},{"data_item":[{"data_sub_type":1,"data_type":3},{"data_sub_type":2,"data_type":4}],"data_item_count":2}],"screen_num":2,"sport_type":1,"support_data_type_num":2,"support_data_type":[{"data_type":1,"data_value":1},{"data_type":2,"data_value":1}]}],"sport_num":2,"version":0}}
            Log.i(TAG,"idoSportScreenInfoReplyModelCmdResponse : " + idoSportScreenInfoReplyModelCmdResponse.getRes());
            IDOSportScreenInfoReplyModel replyData = idoSportScreenInfoReplyModelCmdResponse.getRes();
            if(replyData != null){
                loadData(replyData);
            }
            return null;
        });
    }

    private void loadData(IDOSportScreenInfoReplyModel detailData) {
        Log.i(TAG,"loadData : " + new Gson().toJson(detailData));
        if (detailData != null && detailData.getSportItems() != null) {
            sportScreenSettingReply = detailData;
            for (IDOSportScreenItemReply sportItem : detailData.getSportItems()) {
                if(sportItem.getSportType() == sportType){
                    sportScreenItemReply = sportItem;
                    break;
                }
            }
        }
        Log.i(TAG,"sportScreenItemReply : " + sportScreenItemReply);
        if(sportScreenItemReply == null){
            return;
        }
        allSupportDataItem = sportScreenItemReply.getSupportDataTypes();
        Log.i(TAG,"allSupportScreenLayoutList : " + new Gson().toJson(allSupportScreenLayoutList));
        Log.i(TAG,"allSupportDataItem : " + new Gson().toJson(allSupportDataItem));

        screenAdapter = new Adapter();
        recyclerview.setLayoutManager(new LinearLayoutManager(this,LinearLayoutManager.VERTICAL,false));
        recyclerview.setAdapter(screenAdapter);

        IDOSportScreenItemModel screenItem = sportScreenItemReply.getScreenItems().get(curScreen);
        IDOSportScreenLayoutType screenItemConf = getStyle(screenItem.getDataItemCount(),allSupportScreenLayoutList);
        if (screenItemConf != null) {
            ssv.setData(screenItemConf.getLayoutType(),screenItemConf.getStyle(),screenItem.getDataItem());
            ssv.setListener(dataItemIndex -> {
                Log.i(TAG,"onSelect = " + dataItemIndex);
                DataItemSelectPop typeSelectPop = new DataItemSelectPop(EditSportActivity.this);
                typeSelectPop.setListData(allSupportDataItem,
                        sportScreenItemReply.getScreenItems().get(curScreen).getDataItem().size() != 0 ?
                                sportScreenItemReply.getScreenItems().get(curScreen).getDataItem().get(dataItemIndex):
                                null);
                typeSelectPop.show(ssv);
                typeSelectPop.setListener((index, dataItem) -> {
                    Log.i(TAG,"onSelect index = " + index + " dataItem = " + new Gson().toJson(dataItem) + " , curScreen" + curScreen);
                    IDOSportScreenItemModel screenItem1 = sportScreenItemReply.getScreenItems().get(curScreen);
                    IDOSportScreenLayoutType screenItemConf1 = getStyle(screenItem1.getDataItemCount(),allSupportScreenLayoutList);
                    if(screenItem1.getDataItem().size() > dataItemIndex){
                        screenItem1.getDataItem().set(dataItemIndex,dataItem);
                    }

                    if(screenItemConf1 != null){
                        ssv.setData(screenItemConf1.getLayoutType(), screenItemConf1.getStyle(), screenItem1.getDataItem());
                        screenAdapter.notifyItemChanged(curScreen);
                    }
                });
            });
        }
    }

    private IDOSportScreenLayoutType getStyle(int dataNum,List<IDOSportScreenLayoutType> allScreenList){
        for (int i = 0; i < allScreenList.size(); i++) {
            IDOSportScreenLayoutType screenItemConf = allScreenList.get(i);
            if(screenItemConf.getLayoutType() == dataNum){
                return screenItemConf;
            }
        }
        return null;
    }

//    List<IDOSportScreenLayoutType> typeList = new ArrayList<>();
    public void showStyleList(){
        if(allSupportScreenLayoutList == null){
            Toast.makeText(EditSportActivity.this,"allSupportScreenLayoutList is null",Toast.LENGTH_SHORT).show();
            return;
        }
        String[] items = {"布局1", "布局2", "布局3","布局4", "布局5", "布局6"};
        if(allSupportScreenLayoutList != null){
            AlertDialog.Builder builder = new AlertDialog.Builder(this);
            builder.setTitle("选择一项");
            builder.setItems(items, new DialogInterface.OnClickListener() {
                @Override
                public void onClick(DialogInterface dialog, int which) {
                    List<IDOSportScreenDataItemModel> dataItemList = new ArrayList<>();
                    for (int i = 0; i < allSupportScreenLayoutList.get(which).getLayoutType(); i++) {
                        IDOSportScreenDataItemModel dataItem = new IDOSportScreenDataItemModel(IDODataType.NONE, IDODataSubType.NONE);
                        dataItemList.add(dataItem);
                    }
                    if(isAddMode){
                        IDOSportScreenItemModel screenItem = new IDOSportScreenItemModel(dataItemList);
                        screenItem.setDataItemCount(allSupportScreenLayoutList.get(which).getLayoutType());
                        screenItem.setDataItem(dataItemList);
                        sportScreenItemReply.getScreenItems().add(screenItem);
                        curScreen = sportScreenItemReply.getScreenItems().size() - 1;
                        screenAdapter.notifyDataSetChanged();
                        IDOSportScreenItemModel screen = sportScreenItemReply.getScreenItems().get(curScreen);
                        ssv.setData(screen.getDataItemCount(),defaultStyle, sportScreenItemReply.getScreenItems().get(curScreen).getDataItem());
                        isAddMode = false;
                    }else{
                        sportScreenItemReply.getScreenItems().get(curScreen).setDataItemCount(allSupportScreenLayoutList.get(which).getLayoutType());
                        if(sportScreenItemReply.getScreenItems().get(curScreen).getDataItem() != null){
                            for (int i = 0; i < sportScreenItemReply.getScreenItems().get(curScreen).getDataItem().size(); i++) {
                                if(i < dataItemList.size()){
                                    dataItemList.set(i,sportScreenItemReply.getScreenItems().get(curScreen).getDataItem().get(i));
                                }
                            }
                        }

                        sportScreenItemReply.getScreenItems().get(curScreen).setDataItem(dataItemList);
                        ssv.setData(allSupportScreenLayoutList.get(which).getLayoutType(),0, dataItemList);
                    }
                    screenAdapter.notifyItemChanged(curScreen);
                }
            });
            builder.show();
        }


    }

    public void moveUp(View view) {
        if(sportScreenItemReply != null){
            if(curScreen - 1 >= 0){
                Collections.swap(sportScreenItemReply.getScreenItems(), curScreen, curScreen - 1);
                curScreen--;
                screenAdapter.notifyDataSetChanged();
            }
        }else{
            Toast.makeText(this,"no data ",Toast.LENGTH_SHORT).show();
        }

    }

    public void moveDown(View view) {
        if(sportScreenItemReply != null){
            if(curScreen + 1 < sportScreenItemReply.getScreenItems().size()){
                Collections.swap(sportScreenItemReply.getScreenItems(), curScreen, curScreen + 1);
                curScreen++;
                screenAdapter.notifyDataSetChanged();
            }
        }else{
            Toast.makeText(this,"no data ",Toast.LENGTH_SHORT).show();
        }
    }

    public void add(View view) {
        if(sportScreenItemReply != null){
            if(sportScreenItemReply.getScreenItems().size() < maxScreenNum){
                isAddMode = true;
                showStyleList();
            }else{
                Toast.makeText(this,"maxScreenNum is " + maxScreenNum,Toast.LENGTH_SHORT).show();
            }
        }else{
            Toast.makeText(this,"no data ",Toast.LENGTH_SHORT).show();
        }

    }

    public void delete(View view) {
        if(sportScreenItemReply != null){
            if(sportScreenItemReply.getScreenItems().size() > 1){
                sportScreenItemReply.getScreenItems().remove(curScreen);
                screenAdapter.notifyItemRemoved(curScreen);
                screenAdapter.notifyItemRangeChanged(curScreen, sportScreenItemReply.getScreenItems().size() - curScreen);
                curScreen = 0;
                screenAdapter.notifyItemChanged(0);

                IDOSportScreenItemModel screen = sportScreenItemReply.getScreenItems().get(curScreen);
                ssv.setData(screen.getDataItemCount(),0, sportScreenItemReply.getScreenItems().get(curScreen).getDataItem());
            }
        }else{
            Toast.makeText(this,"no data ",Toast.LENGTH_SHORT).show();
        }

    }

    class Adapter extends RecyclerView.Adapter<EditSportActivity.Adapter.VH> {

        @NonNull
        @Override
        public EditSportActivity.Adapter.VH onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            return new VH(LayoutInflater.from(parent.getContext()).inflate(R.layout.item_edit_screen_list, parent, false));
        }

        @Override
        public void onBindViewHolder(@NonNull EditSportActivity.Adapter.VH holder, int position) {
            IDOSportScreenItemModel screenItem = sportScreenItemReply.getScreenItems().get(position);
            holder.tvName.setText(position + "");
            holder.sportScreenView.setTextSize(10);
            holder.sportScreenView.setIntercept(true);
            Log.i(TAG,position + " , screenList " + sportScreenItemReply.getScreenItems().size() + " , curScreen = " + curScreen);
            Log.i(TAG,position + " , item " + new Gson().toJson(screenItem));
            holder.sportScreenView.setData(screenItem.getDataItemCount(),0,screenItem.getDataItem());
            if(curScreen == position){
                holder.tvName.setTextColor(Color.BLUE);
            }else{
                holder.tvName.setTextColor(Color.WHITE);
            }
        }

        @Override
        public int getItemCount() {
            return sportScreenItemReply.getScreenItems().size();
        }

        class VH extends RecyclerView.ViewHolder {
            TextView tvName;
            SportScreenView sportScreenView;

            public VH(@NonNull View itemView) {
                super(itemView);
                tvName = itemView.findViewById(R.id.tvName);
                sportScreenView = itemView.findViewById(R.id.ssv);
                itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        IDOSportScreenItemModel screen = sportScreenItemReply.getScreenItems().get(getAdapterPosition());
                        curScreen = getAdapterPosition();
                        ssv.setData(screen.getDataItemCount(),0, sportScreenItemReply.getScreenItems().get(curScreen).getDataItem());
                        screenAdapter.notifyDataSetChanged();
                    }
                });
            }
        }
    }

}