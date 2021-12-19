package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import android.graphics.drawable.Drawable;

import androidx.core.content.ContextCompat;

import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;
import com.appliedengineering.aeinstrumentcluster.R;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;
import com.github.mikephil.charting.utils.EntryXComparator;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;

public class GraphDataHolder {
    private final String keyValue;
    private final LineChart chart;
    private final List<Entry> entries;
    private final long startTime = System.currentTimeMillis()/1000L; // we want current time in seconds

    public GraphDataHolder(String keyValue, LineChart chart) {
        this.keyValue = keyValue;
        this.chart = chart;
        this.entries = new ArrayList<>();

        // initial init

//        // hide the grid
//        chart.getAxisLeft().setDrawGridLines(false);
//        chart.getXAxis().setDrawGridLines(false);
    }

    public void updateGraphView(){
        // reset data
        //LogUtil.add(startTime+"");
        LogUtil.add(getEntries().toString());
        //LogUtil.add(getEntriesFormatted().toString());
        LineDataSet lineDataSet = new LineDataSet(getEntries(), keyValue);
        LineData lineData = new LineData(lineDataSet);
        // Hide labels
        lineData.setDrawValues(false);
        lineData.setHighlightEnabled(false);

        // auto scroll the graph view
        // limit the number of visible entries
        chart.setVisibleXRange(10, 20);

        chart.getAxisLeft().setDrawGridLines(false);
        chart.getXAxis().setDrawGridLines(false);
        chart.getXAxis().setDrawLabels(false);

        // make the chart smooth
        lineDataSet.setMode(LineDataSet.Mode.CUBIC_BEZIER);
        lineDataSet.setCubicIntensity(.1f);
        lineDataSet.setDrawCircles(false);

        // move to the latest entry
        if(entries.size() > 11) {
            chart.moveViewToX(entries.size() - 11);
        }

        Drawable drawable = ContextCompat.getDrawable(chart.getContext(), R.drawable.fade_cool_blue);
        lineDataSet.setDrawFilled(true);
        lineDataSet.setFillDrawable(drawable);
        chart.setData(lineData);
        // update graphview
        chart.notifyDataSetChanged();
        chart.invalidate();
    }

    private List<Entry> getEntriesFormatted() {
        // Format the data relative to the time elapsed
        float nowTime = System.currentTimeMillis()/1f;
        List<Entry> newEntryList = new ArrayList<>();
        for(Entry e : entries) {
            float x, y;
            LogUtil.add(e.getX() +"  " +nowTime+" New");
            x = (e.getX()-nowTime);
            y = e.getY();
            Entry newEntry = new Entry(x, y);
            newEntryList.add(newEntry);
        }

        // The entries MUST be sorted
        Collections.sort(newEntryList, new EntryXComparator());

        return newEntryList;

    }

    // GETTERS AND SETTERS

    public void addEntry(Entry e) {
        entries.add(e);

        Collections.sort(entries, new EntryXComparator());
    }

    public List<Entry> getEntries() {
        return entries;
    }
}
