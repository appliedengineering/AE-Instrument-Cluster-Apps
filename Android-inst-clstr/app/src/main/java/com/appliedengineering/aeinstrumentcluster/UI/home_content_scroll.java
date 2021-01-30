package com.appliedengineering.aeinstrumentcluster.UI;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;

import android.graphics.Color;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.LinearLayout;

import com.appliedengineering.aeinstrumentcluster.R;

import com.github.mikephil.charting.*;

public class home_content_scroll extends Fragment{
    public home_content_scroll(){
        super(R.layout.home_content_scroll_layout);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState){
        View view = super.onCreateView(inflater, container, savedInstanceState);

        LinearLayout layout = (LinearLayout) view.findViewById(R.id.content_linear_layout);
        //layout.setLayoutParams(new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.MATCH_PARENT));
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT);
        lp.setMargins(10, 10, 10, 10);

        for (int i = 0; i < 20; i++){
            Button graphView = new Button(getActivity());


            graphView.setBackgroundColor(Color.parseColor("#32a852"));
            graphView.setMinimumHeight(500);
            graphView.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View view){
                    System.out.println("Graph is clicked");
                }
            });

            layout.addView(graphView, lp);
        }

        //layout.setBackgroundColor(Color.parseColor("#32a852"));


        //view.setBackgroundColor(Color.parseColor("#32a852"));

        return view;
    }

}
