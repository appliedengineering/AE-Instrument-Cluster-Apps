package com.appliedengineering.aeinstrumentcluster.Backend;

import android.util.Log;

import com.appliedengineering.aeinstrumentcluster.Backend.dataTypes.GraphDataHolder;
import com.appliedengineering.aeinstrumentcluster.UI.HomeContentScroll;
import com.github.mikephil.charting.charts.LineChart;
import com.github.mikephil.charting.data.Entry;

import org.msgpack.value.Value;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DataManager {

    private int dataIndex = 0;

    private HashMap<String, GraphDataHolder> graphsMap = new HashMap<>();


    public static final String[] GRAPH_KEY_VALUES = new String[] {
            "psuMode",
            "throttlePercent",
            "dutyPercent",
            "pwmFrequency",
            "rpm",
            "torque",
            "tempC",
            "sourceVoltage",
            "pwmCurrent",
            "powerChange",
            "voltageChange"
    };

    public GraphDataHolder registerForDataManager(String keyValue, LineChart chart) {
        GraphDataHolder dataHolder = new GraphDataHolder(keyValue, chart);
        graphsMap.put(keyValue, dataHolder);
        return dataHolder;
    }

    public void addData(Map<Value, Value> map) {
        dataIndex++;
        try {
            // First convert the format of the map, make it more friendly
            List<String> keyValues = Arrays.asList(DataManager.GRAPH_KEY_VALUES);
            float timeStamp = dataIndex;
            LogUtil.add("Timestamp: " + timeStamp/1000f);
            for (Map.Entry<Value, Value> entry : map.entrySet()) {
                Value key = entry.getKey();
                Value value = entry.getValue();

                String keyValue = key.toString();
                if(keyValues.contains(keyValue)) {
                    float entryValue = 0;
                    try {
                        entryValue = Float.parseFloat(value.toString());
                    } catch (NumberFormatException e) {
                        LogUtil.addc("Could not parse number! Corrupted data?");
                    }

                    graphsMap.get(keyValue).addEntry(new Entry(timeStamp, entryValue));
                    graphsMap.get(keyValue).updateGraphView();
                }


            }
        } catch (Exception e) {
            Log.e("DataManager", e.toString());
            LogUtil.addc("Serious error when parsing data! Corrupted data?");
        }
    }

    private float getTimestamp(Map<Value, Value> map) {
        float entryValue = 0;
        for (Map.Entry<Value, Value> entry : map.entrySet()) {
            if(entry.getKey().toString().equals("timeStamp")){
                try {
                    entryValue = Float.parseFloat(entry.getValue().toString());
                } catch (NumberFormatException e) {
                    LogUtil.addc("Could not parse number! Corrupted data?");
                }
            }
        }
        return entryValue;
    }

    public GraphDataHolder getGraphDataHolderRef(String keyValue) {
        return graphsMap.get(keyValue);
    }


    // These following properties need to be handled differently
//            "mddStatus" : True,
//            "ocpStatus" : True,
//            "ovpStatus" : True,
//            "timeStamp" // Determines the x coordinate


}
