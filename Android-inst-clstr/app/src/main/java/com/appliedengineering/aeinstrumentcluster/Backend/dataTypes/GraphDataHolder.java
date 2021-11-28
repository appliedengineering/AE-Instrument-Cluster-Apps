package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;
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

    public GraphDataHolder(String keyValue, LineChart chart) {
        this.keyValue = keyValue;
        this.chart = chart;
        this.entries = new ArrayList<>();
    }

    public void updateGraphView(){
        // reset data
        LogUtil.add(getEntries().toString());
        LineDataSet lineDataSet = new LineDataSet(getEntries(), keyValue);
        LineData lineData = new LineData(lineDataSet);
        chart.setData(lineData);
        // update graphview
        chart.notifyDataSetChanged();
        chart.invalidate();
    }

    // GETTERS AND SETTERS

    public void addEntry(Entry e) {
        entries.add(e);
        // The entries MUST be sorted
        Collections.sort(entries, new EntryXComparator());
    }

    public List<Entry> getEntries() {
        return entries;
    }
}
