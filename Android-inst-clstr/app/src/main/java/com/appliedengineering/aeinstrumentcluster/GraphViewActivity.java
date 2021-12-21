package com.appliedengineering.aeinstrumentcluster;

import androidx.appcompat.app.AppCompatActivity;

import android.os.Bundle;
import android.widget.TextView;

import com.appliedengineering.aeinstrumentcluster.Backend.DataManager;
import com.appliedengineering.aeinstrumentcluster.Backend.dataTypes.GraphDataHolder;
import com.github.mikephil.charting.charts.LineChart;

import org.w3c.dom.Text;

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
        title.setText(chartId);

        // retrieve the data
        dataManager = DataManager.dataManager;
        GraphDataHolder graphDataHolder = dataManager.getGraphDataHolderRef(chartId);
        if(graphDataHolder != null) {
            LineChart chart = findViewById(R.id.lineChartId);
            graphDataHolder.register(chart);
            graphDataHolder.updateGraphView(); // just to display the chart faster so user does not have to wait
        }

    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }
}