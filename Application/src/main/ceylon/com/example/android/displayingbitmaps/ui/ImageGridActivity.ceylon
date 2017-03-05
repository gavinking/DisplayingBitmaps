import android {
    AndroidR=R
}
import android.os {
    Bundle
}
import android.support.v4.app {
    FragmentActivity
}

import com.example.android.displayingbitmaps {
    BuildConfig
}
import com.example.android.displayingbitmaps.provider {
    Images {
        ...
    }
}
import com.example.android.displayingbitmaps.util {
    Utils
}

shared class ImageGridActivity() extends FragmentActivity() {
    value tag = "ImageGridActivity";

    shared actual void onCreate(Bundle savedInstanceState) {
        if (BuildConfig.debug) {
            Utils.enableStrictMode();
        }
        super.onCreate(savedInstanceState);
        if (!supportFragmentManager.findFragmentByTag(tag) exists) {
            value ft = supportFragmentManager.beginTransaction();
            ft.add(AndroidR.Id.content, ImageGridFragment(), tag);
            ft.commit();
        }
    }

}
