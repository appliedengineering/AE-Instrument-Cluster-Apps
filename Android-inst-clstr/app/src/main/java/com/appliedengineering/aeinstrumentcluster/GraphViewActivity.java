package com.appliedengineering.aeinstrumentcluster;

import android.os.Bundle;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.dataTypes.GraphDataHolder;
import com.appliedengineering.aeinstrumentcluster.Backend.util.Util;
import com.github.mikephil.charting.charts.LineChart;

public class GraphViewActivity extends AppCompatActivity {

    private DataManager dataManager;
    public static final String DATA_INDEX = "DATA_INDEX";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_graph_view);

        // get the proper id
        String chartId = getIntent().getStringExtra(DATA_INDEX);

        // set the title
        TextView title = findViewById(R.id.graph_title_view);
        title.setText(Util.formatTitle(chartId));

        // retrieve the data
        dataManager = DataManager.dataManager;
        GraphDataHolder graphDataHolder = dataManager.getGraphDataHolderRef(chartId);
        if (graphDataHolder != null) {
            LineChart chart = findViewById(R.id.lineChartId);
            graphDataHolder.register(chart);
            graphDataHolder.updateGraphView(this);
            graphDataHolder.updateGraphView(this);
            // need to update two times, for reasons explained in another class
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}