package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.gesture.Gesture;
import android.graphics.Color;
import android.graphics.drawable.Drawable;
import android.os.Vibrator;
import android.util.Log;
import android.util.TypedValue;
import android.view.MotionEvent;

import androidx.core.content.ContextCompat;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SettingsPref;
import com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs.SharedPrefUtil;
import com.appliedengineering.aeinstrumentcluster.R;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.components.Description;
import com.github.mikephil.charting.data.Entry;
import com.github.mikephil.charting.data.LineData;
import com.github.mikephil.charting.data.LineDataSet;
import com.github.mikephil.charting.listener.ChartTouchListener;
import com.github.mikephil.charting.listener.OnChartGestureListener;
import com.github.mikephil.charting.utils.EntryXComparator;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

public class GraphDataHolder {

    private static final String TAG = "GraphDataHolder";

    private final String keyValue;
    private transient LineChart chart;
    private List<DataPoint> dataPoints;
    private transient List<LineChart> chartsToUpdate = new ArrayList<>();
    private transient static int POINTS_VISIBLE_MIN = 5;
    private transient static int POINTS_VISIBLE_MAX = 5;

    private transient final Drawable drawable, pausedDrawable;

    private transient final LineDataSet lineDataSet;
    private transient final LineData lineData;
    private transient final List<Entry> entriesList = new ArrayList<>();

    private transient final SettingsPref settingsPref;

    // chart states
    private transient volatile boolean isChartStopped = false;


    public GraphDataHolder(String keyValue, LineChart chart, Activity activity) {

        this.settingsPref = SharedPrefUtil.loadSettingsPreferences(activity);
        this.keyValue = keyValue;
        this.chart = chart;
        this.dataPoints = new ArrayList<>();
        this.drawable =  ContextCompat.getDrawable(chart.getContext(), R.drawable.fade_cool_blue);
        this.pausedDrawable =  ContextCompat.getDrawable(chart.getContext(), R.drawable.fade_cool_yello);


        // initial init
        lineDataSet = new LineDataSet(entriesList, keyValue);
        lineData = new LineData(lineDataSet);

        addChart(chart);

    }

    private void addChart(LineChart chart) {
        chartsToUpdate.add(chart);
        formatChart(chart);
    }

    private void formatChart(LineChart chart) {
        if (chartsToUpdate.indexOf(chart) == 0) {
            // Hide labels
            lineData.setDrawValues(false);
            lineData.setHighlightEnabled(false);

            chart.getAxisLeft().setDrawGridLines(false);
            chart.getAxisRight().setDrawGridLines(false);
            chart.getXAxis().setDrawGridLines(false);

            chart.getAxisLeft().setDrawLabels(false);
            chart.getXAxis().setDrawLabels(false);

            chart.getAxisLeft().setDrawAxisLine(false);
            chart.getAxisRight().setDrawAxisLine(false);
            chart.getXAxis().setDrawAxisLine(false);

        }

        // set the correct colors
        TypedValue typedValue = new TypedValue();
        Resources.Theme theme = chart.getContext().getTheme();
        theme.resolveAttribute(R.attr.inverse_backgroundColor, typedValue, true);
        int labelColor = typedValue.data;

        chart.getAxisRight().setTextColor(labelColor);
        chart.getDescription().setTextColor(labelColor);

        // make the chart smooth
        if(settingsPref.cubicLineFitting) {
            lineDataSet.setMode(LineDataSet.Mode.CUBIC_BEZIER);
            lineDataSet.setCubicIntensity(.1f);
        }
        lineDataSet.setDrawCircles(false);
        lineDataSet.setDrawFilled(true);
        lineDataSet.setLineWidth(3f);
        if(settingsPref.drawBackground) {
            lineDataSet.setFillDrawable(drawable);
        }
        chart.setData(lineData);
        chart.getLegend().setEnabled(false);

    }

    public void stopOrStartGraph(){
        isChartStopped = !isChartStopped;
        if(isChartStopped) {
            lineDataSet.setColor(Color.YELLOW);
            lineDataSet.setFillDrawable(pausedDrawable);
        } else {
            lineDataSet.setColor(Color.CYAN);
            lineDataSet.setFillDrawable(drawable);
        }
        updateGraphView();
    }

    public synchronized void updateGraphView() {
        for (LineChart chart : chartsToUpdate) {
            if (!entriesList.isEmpty()) {
                chart.getDescription().setText("Current value: " + entriesList.get(entriesList.size() - 1).getY());
            }


            // update graphview
            lineDataSet.notifyDataSetChanged();
            lineData.notifyDataChanged();
            chart.notifyDataSetChanged();

            // auto scroll the graph view
            // limit the number of visible entries
            chart.setVisibleXRange(POINTS_VISIBLE_MIN, POINTS_VISIBLE_MAX);
            chart.setScaleEnabled(true);
            chart.setScaleYEnabled(false);
            chart.setScaleXEnabled(true);

            if(!entriesList.isEmpty()) {
                float lastX = entriesList.get(entriesList.size() - 1).getX();
                // chart.setScaleMinima(lastX * .25f, 1f); // keep zooming out as more points are added
                // by using the lastX to calculate the scale the effects of adding points are counteracted
                // move to the latest entry
                if (entriesList.size() > POINTS_VISIBLE_MIN && !isChartStopped) {
                    chart.moveViewToX(lastX);
                } else {
                    chart.invalidate();
                }

            }

        }

    }

    private List<Entry> getEntriesFormatted(DataPoint... dataPoints) {
        // Format the data relative to the time elapsed
        List<Entry> newEntryList = new ArrayList<>();
        // make a copy of dataPoints just in case to avoid ConcurrentModificationException
        for (DataPoint e : dataPoints) {
            float x, y;
            x = (e.getX() - DataManager.START_TIME) / 1000f; // divide by 1000 to convert to seconds
            y = e.getY();
            Entry newEntry = new Entry(x, y);

            newEntryList.add(newEntry);
        }

        return newEntryList;

    }

    // GETTERS AND SETTERS

    public synchronized void addEntry(long x, float y) {
        if(!isChartStopped) {
            DataPoint newPoint = new DataPoint(x, y);
            dataPoints.add(newPoint);
            entriesList.addAll(getEntriesFormatted(newPoint));
            lineDataSet.notifyDataSetChanged();
        }
        updateGraphView();
    }

    public synchronized void clear() {
        dataPoints.clear();
        entriesList.clear();
        chart.resetZoom();
        updateGraphView();
    }

    public List<DataPoint> getDataPoints() {
        return dataPoints;
    }

    public synchronized void setDataPoints(List<DataPoint> dataPoints, Activity activity) {
        this.dataPoints = dataPoints;
        entriesList.clear();
        entriesList.addAll(getEntriesFormatted(dataPoints.toArray(new DataPoint[0])));
        activity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                updateGraphView();

            }
        });

    }

    public void deRegister(LineChart lineChart) {
        chartsToUpdate.remove(lineChart);
    }

    public void register(LineChart lineChart) {
        addChart(lineChart);
    }

}
