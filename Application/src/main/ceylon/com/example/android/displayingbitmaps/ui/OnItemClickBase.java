package com.example.android.displayingbitmaps.ui;

import android.view.View;
import android.widget.Adapter;
import android.widget.AdapterView;

/**
 * Created by gavin on 3/4/17.
 */

public interface OnItemClickBase extends AdapterView.OnItemClickListener {
    @Override
    public void onItemClick(AdapterView adapterView, View view, int i, long l);
}
