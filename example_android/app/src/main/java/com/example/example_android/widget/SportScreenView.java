package com.example.example_android.widget;


import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Rect;
import android.graphics.RectF;
import android.text.TextUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;

import androidx.annotation.Nullable;

import com.example.example_android.R;
import com.example.example_android.sport.SportScreenSetting;
import com.example.example_android.util.SportScreenSetUtil;
import com.example.example_android.util.SportScreenUtil;
import com.google.gson.Gson;
import com.idosmart.model.IDODataSubType;
import com.idosmart.model.IDOSportScreenDataItemModel;

import java.util.ArrayList;
import java.util.List;

public class SportScreenView extends View {
    private static final String TAG = "SportScreenView";
    private Context mContext;
    private int layout_type = 1;//屏幕布局类型
    private int style = 0;//风格
    private List<IDOSportScreenDataItemModel> dataItemList = new ArrayList<>();
    private Paint paint, paintLine, paintText,highlightPaint;
    private List<RectF> dataRectList = new ArrayList<>();
    private int padding = 30;
    private boolean isIntercept = false;
    private int touchX;
    private int touchY;
    private RectF highlightRect; // 高亮区域
    public SportScreenView(Context context) {
        super(context);
        mContext = context;
        init();
    }

    public SportScreenView(Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
        mContext = context;
        init();
    }

    public SportScreenView(Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
        mContext = context;
        init();
    }

    @Override
    protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
        super.onMeasure(widthMeasureSpec, heightMeasureSpec);
    }

    private void init() {
        paint = new Paint();
        paint.setColor(Color.BLACK); // 设置画笔颜色
        paint.setStyle(Paint.Style.FILL); // 设置填充样式
        paint.setAntiAlias(true); // 抗锯齿

        paintText = new Paint();
        paintText.setColor(Color.WHITE); // 设置画笔颜色
        paintText.setStyle(Paint.Style.FILL); // 设置填充样式
        paintText.setTextSize(50);

        paintLine = new Paint();
        paintLine.setColor(Color.GRAY); // 设置画笔颜色
        paintLine.setStyle(Paint.Style.FILL); // 设置填充样式
        paintLine.setAntiAlias(true); // 抗锯齿

        highlightPaint = new Paint();
        highlightPaint.setColor(0x800000FF);
        highlightPaint.setStyle(Paint.Style.FILL);
    }

    public void setData(int layout_type, int style, List<IDOSportScreenDataItemModel> data) {
        highlightRect = null;
        this.layout_type = layout_type;
        this.style = style;
        dataItemList = data;
        Log.i(TAG, "setData " + layout_type + " , style =" + style + " , dataItemList= " + dataItemList);
        invalidate();
    }

    public void setIntercept(boolean isIntercept){
        this.isIntercept = isIntercept;
        getParent().requestDisallowInterceptTouchEvent(isIntercept);
    }

    public void setTextSize(int size) {
        paintText.setTextSize(size);
    }

    @SuppressLint("DrawAllocation")
    @Override
    protected void onDraw(Canvas canvas) {
//        super.onDraw(canvas);
        int width = getWidth();
        int height = getHeight();
        Log.i(TAG, "width" + width + " , height =" + height);
        dataRectList = new ArrayList<>();
        int radius = Math.min(width, height) / 2; // 计算圆的半径
        int centerX = width / 2;
        int centerY = height / 2;
        canvas.drawCircle(centerX, centerY, radius, paint); // 绘制圆形
        if (dataItemList != null) {
            switch (layout_type) {
                case 1:
                    if (style == 0) {//一项 居中
                        String contetent = "--";
                        if(dataItemList.size() >= 1){
                            contetent = getContent(dataItemList.get(0));
                        }
                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, centerY + getTextHeight(paintText, contetent), paintText);
                        RectF r1 = new RectF(0, 0, width, height);
                        dataRectList.add(r1);
                    }
                    break;
                case 2:
                    if (style == 0) {
                        int clipNum = 2;//2项内容 上下平分
                        int centerClipNum = clipNum * 2;
                        String contetent = "--";
                        String contetent2 = "--";
                        if(dataItemList.size() >= 2){
                            contetent = getContent(dataItemList.get(0));
                            contetent2 = getContent(dataItemList.get(1));
                        }
                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, height / centerClipNum + getTextHeight(paintText, contetent) / 2, paintText);
                        canvas.drawLine(0, centerY, width, centerY, paintLine);
                        RectF r1 = new RectF(0, 0, width, height / clipNum);
                        dataRectList.add(r1);

                        canvas.drawText(contetent2, centerX - getTextWidth(paintText, contetent2) / 2, height / centerClipNum * 3 - getTextHeight(paintText, contetent2) / 2, paintText);
                        RectF r2 = new RectF(0, height / clipNum, width, height);
                        dataRectList.add(r2);
                    }

                    break;
                case 3:
                    if (style == 0) {
                        int clipNum = 3;//3项内容 上下平分
                        int centerClipNum = clipNum * 2;
                        String contetent = "--";
                        String contetent2 = "--";
                        String contetent3 = "--";
                        if(dataItemList.size() >= 3){
                            contetent = getContent(dataItemList.get(0));
                            contetent2 = getContent(dataItemList.get(1));
                            contetent3 = getContent(dataItemList.get(2));
                        }
                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, height / centerClipNum + getTextHeight(paintText, contetent) / 2, paintText);
                        canvas.drawLine(30, width / clipNum, width-30, width / 3, paintLine);
                        RectF r1 = new RectF(0, 0, width, height / clipNum);
                        dataRectList.add(r1);

                        canvas.drawText(contetent2, centerX - getTextWidth(paintText, contetent2) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent2) / 2, paintText);
                        canvas.drawLine(30, width / clipNum * 2, width-30, width / 3 * 2, paintLine);
                        RectF r2 = new RectF(0, height / clipNum, width, height / clipNum * 2);
                        dataRectList.add(r2);

                        canvas.drawText(contetent3, centerX - getTextWidth(paintText, contetent3) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent3) / 2, paintText);
                        RectF r3 = new RectF(0, height / clipNum * 2, width, height / clipNum * 3);
                        dataRectList.add(r3);
                    }

                    break;
                case 4:
                    if (style == 0) {
                        int clipNum = 3;//4项内容 上下3平分 2中间2平分
                        int centerClipNum = clipNum * 2;
                        String contetent = "--";
                        String contetent2 = "--";
                        String contetent3 = "--";
                        String contetent4 = "--";
                        if(dataItemList.size() >= 4){
                            contetent = getContent(dataItemList.get(0));
                            contetent2 = getContent(dataItemList.get(1));
                            contetent3 = getContent(dataItemList.get(2));
                            contetent4 = getContent(dataItemList.get(3));
                        }

                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, height / centerClipNum + getTextHeight(paintText, contetent) / 2, paintText);
                        canvas.drawLine(30, height / clipNum, width-30, height / clipNum, paintLine);
                        RectF r1 = new RectF(0, 0, width, height / clipNum);
                        dataRectList.add(r1);

                        canvas.drawText(contetent2, width / 4 - getTextWidth(paintText, contetent2) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent2) / 2, paintText);
                        canvas.drawLine(centerX, height / clipNum, centerX, height / clipNum * 2, paintLine);
                        RectF r2 = new RectF(0, height / clipNum, width / 2, height / clipNum * 2);
                        dataRectList.add(r2);

                        canvas.drawText(contetent3, width / 4 * 3 - getTextWidth(paintText, contetent3) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent3) / 2, paintText);
                        canvas.drawLine(30, height / clipNum * 2, width-30, height / clipNum * 2, paintLine);
                        RectF r3 = new RectF(width / 2, height / clipNum, width, height / clipNum * 2);
                        dataRectList.add(r3);

                        canvas.drawText(contetent4, centerX - getTextWidth(paintText, contetent4) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent4) / 2, paintText);
                        RectF r4 = new RectF(0, height / clipNum * 2, width, height / clipNum * 3);
                        dataRectList.add(r4);
                    }

                    break;
                case 5:
                    if (style == 0) {
                        int clipNum = 4;//5项内容 上下4平分 3中间2平分
                        int centerClipNum = clipNum * 2;
                        String contetent = "--";
                        String contetent2 = "--";
                        String contetent3 = "--";
                        String contetent4 = "--";
                        String contetent5 = "--";
                        if(dataItemList.size() >= 5){
                            contetent = getContent(dataItemList.get(0));
                            contetent2 = getContent(dataItemList.get(1));
                            contetent3 = getContent(dataItemList.get(2));
                            contetent4 = getContent(dataItemList.get(3));
                            contetent5 = getContent(dataItemList.get(4));
                        }
                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, height / centerClipNum + getTextHeight(paintText, contetent) / 2, paintText);
                        canvas.drawLine(50, height / clipNum, width-50, height / clipNum, paintLine);
                        RectF r1 = new RectF(0, 0, width, height / clipNum);
                        dataRectList.add(r1);

                        canvas.drawText(contetent2, centerX - getTextWidth(paintText, contetent2) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent2) / 2, paintText);
                        canvas.drawLine(0, height / clipNum * 2, width, height / clipNum * 2, paintLine);
                        RectF r2 = new RectF(0, height / clipNum, width, height / clipNum * 2);
                        dataRectList.add(r2);

                        canvas.drawText(contetent3, width / 4 - getTextWidth(paintText, contetent3) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent3) / 2, paintText);
                        canvas.drawLine(centerX, height / clipNum * 2, centerX, height / clipNum * 3, paintLine);
                        RectF r3 = new RectF(0, height / clipNum * 2, width / 2, height / clipNum * 3);
                        dataRectList.add(r3);

                        canvas.drawText(contetent4, width / 4 * 3 - getTextWidth(paintText, contetent4) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent4) / 2, paintText);
                        canvas.drawLine(50, height / clipNum * 3, width-50, height / clipNum * 3, paintLine);
                        RectF r4 = new RectF(width / 2, height / clipNum * 2, width, height / clipNum * 3);
                        dataRectList.add(r4);

                        canvas.drawText(contetent5, centerX - getTextWidth(paintText, contetent5) / 2, height / centerClipNum * 7 + getTextHeight(paintText, contetent5) / 2, paintText);
                        RectF r5 = new RectF(0, height / clipNum * 3, width, height / clipNum * 4);
                        dataRectList.add(r5);
                    }

                    break;
                case 6:
                    if (style == 0) {
                        int clipNum = 4;//6项内容 上下4平分 23中间2平分
                        int centerClipNum = clipNum * 2;
                        String contetent = "--";
                        String contetent2 = "--";
                        String contetent3 = "--";
                        String contetent4 = "--";
                        String contetent5 = "--";
                        String contetent6 = "--";
                        if(dataItemList.size() >= 5){
                            contetent = getContent(dataItemList.get(0));
                            contetent2 = getContent(dataItemList.get(1));
                            contetent3 = getContent(dataItemList.get(2));
                            contetent4 = getContent(dataItemList.get(3));
                            contetent5 = getContent(dataItemList.get(4));
                            contetent6 = getContent(dataItemList.get(5));
                        }
                        canvas.drawText(contetent, centerX - getTextWidth(paintText, contetent) / 2, height / centerClipNum + getTextHeight(paintText, contetent) / 2, paintText);
                        canvas.drawLine(50, height / clipNum, width-50, height / clipNum, paintLine);
                        RectF r1 = new RectF(0, 0, width, height / clipNum);
                        dataRectList.add(r1);

                        canvas.drawText(contetent2, width / 4 - getTextWidth(paintText, contetent2) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent2) / 2, paintText);
                        canvas.drawLine(centerX, height / clipNum * 1, centerX, height / clipNum * 2, paintLine);
                        canvas.drawText(contetent3, width / 4 * 3 - getTextWidth(paintText, contetent3) / 2, height / centerClipNum * 3 + getTextHeight(paintText, contetent3) / 2, paintText);
                        canvas.drawLine(0, height / clipNum * 2, width, height / clipNum * 2, paintLine);
                        RectF r2 = new RectF(0, height / clipNum, width/2, height / clipNum * 2);
                        dataRectList.add(r2);
                        RectF r3 = new RectF(width / 2, height / clipNum, width, height / clipNum * 2);
                        dataRectList.add(r3);

                        canvas.drawText(contetent4, width / 4 - getTextWidth(paintText, contetent4) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent4) / 2, paintText);
                        canvas.drawLine(centerX, height / clipNum * 2, centerX, height / clipNum * 3, paintLine);
                        canvas.drawText(contetent5, width / 4 * 3 - getTextWidth(paintText, contetent5) / 2, height / centerClipNum * 5 + getTextHeight(paintText, contetent5) / 2, paintText);
                        canvas.drawLine(50, height / clipNum * 3, width-50, height / clipNum * 3, paintLine);
                        RectF r4 = new RectF(0, height / clipNum * 2, width/2, height / clipNum * 3);
                        dataRectList.add(r4);
                        RectF r5 = new RectF(width / 2, height / clipNum * 2, width, height / clipNum * 3);
                        dataRectList.add(r5);

                        canvas.drawText(contetent6, centerX - getTextWidth(paintText, contetent6) / 2, height / centerClipNum * 7 + getTextHeight(paintText, contetent6) / 2, paintText);
                        RectF r6 = new RectF(0, height / clipNum * 3, width, height / clipNum * 4);
                        dataRectList.add(r6);
                    }
                    break;
            }
        }
        if(highlightRect != null){
            canvas.drawRect(highlightRect,highlightPaint);
        }

    }

    public void clearHighlight(){
        highlightRect = null;
        invalidate();
    }

    private String getContent(IDOSportScreenDataItemModel dataItem) {
        Log.d("getContent",dataItem.getSubType() + " ---" + (dataItem.getSubType() == null));
        Log.d("getContent",new Gson().toJson(dataItem));
        if(dataItem.getSubType() == null){
            return "--";
        }
        if(dataItem.getSubType() == IDODataSubType.NONE){
            return "--";
        }
        int strId = SportScreenSetUtil.SPORT_DATA_S_SUB.get(dataItem.getSubType());
        return mContext.getString(strId);
    }

    public float getTextWidth(Paint paint, String str) { //calculate text width
        float iRet = 0;
        if (str != null && str.length() > 0) {
            int len = str.length();
            float[] widths = new float[len];
            paint.getTextWidths(str, widths);
            for (int j = 0; j < len; j++) {
                iRet += (int) Math.ceil(widths[j]);
            }
        }
        return iRet;
    }

    public static int getTextHeight(Paint paint, String text) {
        if (paint == null || TextUtils.isEmpty(text)) {
            return 0;
        }
        Rect rect = new Rect();
        paint.getTextBounds(text, 0, text.length(), rect);
        return rect.height();
    }

    @Override
    public boolean onTouchEvent(MotionEvent event) {
        switch (event.getAction()) {
            case MotionEvent.ACTION_DOWN:
                if(isIntercept){
                    return false;
                }
                touchX = (int) event.getX();
                touchY = (int) event.getY();
                if (!dataRectList.isEmpty()) {
                    for (int i = 0; i < dataRectList.size(); i++) {
                        RectF rectf = dataRectList.get(i);
                        if (rectf.contains(touchX, touchY)) {
                            highlightRect = rectf;
                            invalidate();
                            if (listener != null) {
                                listener.onSelect(i);
                                return true;
                            }
                        }
                    }
                }
                return true;
            case MotionEvent.ACTION_MOVE:
                return true;
            case MotionEvent.ACTION_UP:
                return true;
        }
        return false;
    }

    OnSelectItemListener listener;

    public interface OnSelectItemListener {
        void onSelect(int index);
    }

    public void setListener(OnSelectItemListener listener) {
        this.listener = listener;
    }
}
