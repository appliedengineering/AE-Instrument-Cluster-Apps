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
        return settingsPref;
    }

    public static boolean saveSettingsPreferences(Activity activity, SettingsPref settingsPref) {
        SharedPreferences settings = activity.getSharedPreferences(SharedPrefsConstants.SETTINGS_PREF, 0);
        SharedPreferences.Editor editor = settings.edit();
        editor.putString(SharedPrefsConstants.SETTINGS_PREF_IP_ADDRESS, settingsPref.ipAddress);
        editor.putString(SharedPrefsConstants.SETTINGS_PREF_PORT, settingsPref.port);
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
