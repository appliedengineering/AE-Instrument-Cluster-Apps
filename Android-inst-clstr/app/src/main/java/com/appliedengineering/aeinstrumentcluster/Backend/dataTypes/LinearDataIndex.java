package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

import java.util.HashMap;

public class LinearDataIndex {
    private HashMap<String, LinearDataGroup> linearDataIndex; // Maps the id or string of the data to a certain LinearDataGroup
    // This allows the LinearDataGroups to be search and makes it easy to add incoming data

    public void registerLinearDataGroup(String key, LinearDataGroup linearDataGroup) {
        linearDataIndex.put(key, linearDataGroup);
    }

    public LinearDataGroup getLinearDataGroupByKey(String key) {
        return linearDataIndex.get(key);
    }
}
