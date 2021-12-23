package com.appliedengineering.aeinstrumentcluster.Backend.util.sharedPrefs;

import android.app.Activity;
import android.content.SharedPreferences;

import com.appliedengineering.aeinstrumentcluster.UI.HomeActivity;

import java.util.HashSet;

public class SharedPrefUtil {

    public static SettingsPref loadSettingsPreferences(Activity activity) {
        SettingsPref settingsPref = new SettingsPref();
        SharedPreferences settings = activity.getSharedPreferences(SharedPrefsConstants.SETTINGS_PREF, 0);

        settingsPref.ipAddress = settings.getString(SharedPrefsConstants.SETTINGS_PREF_IP_ADDRESS, SharedPrefsConstants.SETTINGS_PREF_IP_ADDRESS_DEFAULT);
        settingsPref.port = settings.getString(SharedPrefsConstants.SETTINGS_PREF_PORT, SharedPrefsConstants.SETTINGS_PREF_PORT_DEFAULT);

        settingsPref.timestampIp = settings.getString(SharedPrefsConstants.SETTINGS_PREF_TIME_IP_ADDRESS, SharedPrefsConstants.SETTINGS_PREF_TIME_IP_ADDRESS_DEFAULT);
        settingsPref.timestampPort = settings.getString(SharedPrefsConstants.SETTINGS_PREF_TIME_PORT, SharedPrefsConstants.SETTINGS_PREF_TIME_PORT_DEFAULT);

        settingsPref.drawBackground = settings.getBoolean(SharedPrefsConstants.SETTINGS_PREF_DRAW_BG, SharedPrefsConstants.SETTINGS_PREF_DRAW_BG_DEFAULT);
        settingsPref.cubicLineFitting = settings.getBoolean(SharedPrefsConstants.SETTINGS_PREF_CUBIC_LINE, SharedPrefsConstants.SETTINGS_PREF_CUBIC_LINE_DEFAULT);

        settingsPref.refreshInterval = settings.getInt(SharedPrefsConstants.SETTINGS_PREF_REFRESH_INTERVAL, SharedPrefsConstants.SETTINGS_PREF_REFRESH_INTERVAL_DEFAULT);
        settingsPref.viewportWidth = settings.getInt(SharedPrefsConstants.SETTINGS_PREF_VIEW_WIDTH, SharedPrefsConstants.SETTINGS_PREF_VIEW_WIDTH_DEFAULT);

        return settingsPref;
    }

    public static boolean saveSettingsPreferences(Activity activity, SettingsPref settingsPref) {
        SharedPreferences settings = activity.getSharedPreferences(SharedPrefsConstants.SETTINGS_PREF, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(SharedPrefsConstants.SETTINGS_PREF_IP_ADDRESS, settingsPref.ipAddress);
        editor.putString(SharedPrefsConstants.SETTINGS_PREF_PORT, settingsPref.port);

        editor.putString(SharedPrefsConstants.SETTINGS_PREF_TIME_IP_ADDRESS, settingsPref.timestampIp);
        editor.putString(SharedPrefsConstants.SETTINGS_PREF_TIME_PORT, settingsPref.timestampPort);

        editor.putBoolean(SharedPrefsConstants.SETTINGS_PREF_DRAW_BG, settingsPref.drawBackground);
        editor.putBoolean(SharedPrefsConstants.SETTINGS_PREF_CUBIC_LINE, settingsPref.cubicLineFitting);

        editor.putInt(SharedPrefsConstants.SETTINGS_PREF_REFRESH_INTERVAL, settingsPref.refreshInterval);
        editor.putInt(SharedPrefsConstants.SETTINGS_PREF_VIEW_WIDTH, settingsPref.viewportWidth);

        return editor.commit();
    }

    public static SnapshotsPref loadSnapshotsPreferences(Activity activity) {
        SnapshotsPref snapshotsPref = new SnapshotsPref();
        SharedPreferences settings = activity.getSharedPreferences(SharedPrefsConstants.SNAPSHOTS_PREF, 0);
        snapshotsPref.snapshots = new HashSet<>(settings.getStringSet(SharedPrefsConstants.SNAPSHOTS_PREF_SNAPSHOTS, new HashSet<>()));
        return snapshotsPref;
    }

    public static boolean saveSnapshotsPreferences(HomeActivity activity, SnapshotsPref snapshotsPref) {
        SharedPreferences settings = activity.getSharedPreferences(SharedPrefsConstants.SNAPSHOTS_PREF, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putStringSet(SharedPrefsConstants.SNAPSHOTS_PREF_SNAPSHOTS, snapshotsPref.snapshots);
        return editor.commit();
    }
}
