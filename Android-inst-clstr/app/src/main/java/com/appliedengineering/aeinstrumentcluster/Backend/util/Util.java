package com.appliedengineering.aeinstrumentcluster.Backend.util;

import com.appliedengineering.aeinstrumentcluster.Backend.LogUtil;

public class Util {
    public static String formatTitle(String keyValue) {
        String[] tokens = keyValue.split("(?=\\p{Upper})");
        String returnString = "";
        for(String token : tokens) {
            returnString += token.substring(0, 1).toUpperCase() + token.substring(1) + " ";
        }
        return returnString;
    }

    public static float parseFloat(String string) {
        try {
            return Float.parseFloat(string);
        } catch (NumberFormatException e) {
            LogUtil.addc("Could not parse number! Corrupted data?");
            return 0;
        }
    }

    public static long parseLong(String string) {
        try {
            return Long.parseLong(string);
        } catch (NumberFormatException e) {
            LogUtil.addc("Could not parse number! Corrupted data?");
            return 0L;
        }
    }

    public static double parseDouble(String string) {
        try {
            return Double.parseDouble(string);
        } catch (NumberFormatException e) {
            LogUtil.addc("Could not parse number! Corrupted data?");
            return 0;
        }
    }
}
