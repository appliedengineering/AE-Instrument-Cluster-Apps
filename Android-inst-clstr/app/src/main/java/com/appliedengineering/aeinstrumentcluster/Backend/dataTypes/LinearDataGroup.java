package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.interfaces.datasets.ILineDataSet;

import java.util.ArrayList;

public class LinearDataGroup {
    private LineData lineData;
    private ArrayList<ILineDataSet> dataSets = new ArrayList<>();

    public void addNewDataSetToGroup(LinearData linearData) {
        dataSets.add(linearData.getLineDataSet());
    }

    public ArrayList<ILineDataSet> getDataSets() {
        return dataSets;
    }

    public LineData getLineData() {
        if(lineData == null) {
            lineData = new LineData(dataSets);
        }
        return lineData;
    }
}
