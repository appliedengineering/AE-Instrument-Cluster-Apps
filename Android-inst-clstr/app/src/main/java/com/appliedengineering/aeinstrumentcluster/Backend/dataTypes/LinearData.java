package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;

import java.util.ArrayList;
import java.util.List;

public class LinearData {

    private List<Entry> data = new ArrayList<>();

    private LineDataSet lineDataSet;

    private int count = 0;

    private String label = "DEFAULT_NAME";

    public LinearData(List<Entry> data) {
        this.data = data;
    }

    public LinearData() {
    }

    public void addDataPoint(double point) {
        data.add((new Entry(count, (float) point)));
        count++;
    }

    public List<Entry> getData() {
        return data;
    }

    public ILineDataSet getLineDataSet() {
        if(lineDataSet == null) {
            lineDataSet = new LineDataSet(data, label);
        }
        return lineDataSet;
    }
}
