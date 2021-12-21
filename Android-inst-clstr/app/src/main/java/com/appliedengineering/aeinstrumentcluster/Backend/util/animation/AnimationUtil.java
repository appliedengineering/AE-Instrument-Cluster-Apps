package com.appliedengineering.aeinstrumentcluster.Backend.util.animation;

import android.widget.Button;

public class AnimationUtil {
    public static void setDepressedButtonAnimation(String normalText, String depressedText, Button button) {
        button.setText(depressedText);
        button.animate().alpha(0.5f).setDuration(1000).withEndAction(new Runnable() {
            @Override
            public void run() {
                // restore the text
                button.animate().alpha(1f).setDuration(1000);
                button.setText(normalText);
            }
        });
    }
}
