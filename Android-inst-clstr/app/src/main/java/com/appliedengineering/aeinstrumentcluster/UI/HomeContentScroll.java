package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;
import com.appliedengineering.aeinstrumentcluster.Backend.dataTypes.LinearData;
import com.appliedengineering.aeinstrumentcluster.Backend.dataTypes.LinearDataGroup;
import com.appliedengineering.aeinstrumentcluster.R;

import com.github.mikephil.charting.*;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;

public class HomeContentScroll extends Fragment{
    public HomeContentScroll(){
        super(R.layout.home_content_scroll_layout);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState){
        View view = super.onCreateView(inflater, container, savedInstanceState);

        LinearLayout layout = (LinearLayout) view.findViewById(R.id.content_linear_layout);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMargins(10, 10, 10, 10);

        for (int i = 0; i < 20; i++){
            LineChart graphView = new LineChart(getActivity());

            // Generate some random data
            LinearDataGroup linearDataGroup = new LinearDataGroup();
            LinearData linearData = new LinearData();
            for (int x = 0; x < 30; x++) {
                linearData.addDataPoint(x*Math.random());
            }
            linearDataGroup.addNewDataSetToGroup(linearData);
            graphView.setData(linearDataGroup.getLineData());

            graphView.setBackgroundColor(Color.parseColor("#32a852"));
            graphView.setMinimumHeight(500);
            graphView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view){
                    LogUtil.add("Graph is clicked");
                }
            });

            layout.addView(graphView, lp);
        }

        //layout.setBackgroundColor(Color.parseColor("#32a852"));


        //view.setBackgroundColor(Color.parseColor("#32a852"));

        return view;
    }

}
