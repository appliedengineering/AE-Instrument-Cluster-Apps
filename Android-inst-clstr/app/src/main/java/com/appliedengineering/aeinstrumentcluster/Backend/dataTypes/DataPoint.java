package com.appliedengineering.aeinstrumentcluster.Backend.dataTypes;

public class DataPoint {
    private long x;
    private float y;

    public DataPoint(long x, float y) {
        this.x = x;
        this.y = y;
    }

    public long getX() {
        return x;
    }

    public void setX(long x) {
        this.x = x;
    }

    public float getY() {
        return y;
    }

    public void setY(float y) {
        this.y = y;
    }
}
