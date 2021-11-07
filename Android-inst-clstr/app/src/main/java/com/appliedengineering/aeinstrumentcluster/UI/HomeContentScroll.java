package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.graphics.Color;
import android.os.Bundle;
import android.speech.tts.TextToSpeech;
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
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;

import java.util.ArrayList;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

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
            List<Entry> entries = new ArrayList<>();
            LineDataSet lineDataSet = new LineDataSet(entries, "DEFAULT_LABEL");
            ArrayList<ILineDataSet> dataSets = new ArrayList<>();
            dataSets.add(lineDataSet);
            graphView.setData(new LineData(dataSets));
            // Generate some random data
            Timer timer = new Timer();
            timer.scheduleAtFixedRate(new TimerTask() {
                float x = 0;

                @Override
                public void run() {
                    graphView.getData().addEntry(new Entry(x, (float) (30*Math.random())), 0);
                    graphView.notifyDataSetChanged();
                    x++;
                    graphView.invalidate();

                }
            }, 1000, 1000);

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
