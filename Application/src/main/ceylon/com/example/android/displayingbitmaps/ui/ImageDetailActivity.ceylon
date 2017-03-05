import android {
    AndroidR=R
}
import android.os {
    Bundle
}
import android.support.v4.app {
    FragmentActivity,
    FragmentManager,
    FragmentStatePagerAdapter,
    NavUtils
}
import android.support.v4.view {
    ViewPager
}
import android.util {
    DisplayMetrics
}
import android.view {
    Menu,
    MenuItem,
    View {
        OnClickListener
    },
    WindowManager {
        LayoutParams
    }
}
import android.widget {
    Toast
}

import com.example.android.displayingbitmaps {
    BuildConfig,
    R
}
import com.example.android.displayingbitmaps.provider {
    Images
}
import com.example.android.displayingbitmaps.util {
    ImageCache,
    ImageFetcher,
    Utils
}

shared class ImageDetailActivity
        extends FragmentActivity
        satisfies OnClickListener {

    static String imageCacheDir = "images";
    shared static String extraImage = "extra_image";

    shared new () extends FragmentActivity() {}

    shared late ImageFetcher imageFetcher;
    late ImagePagerAdapter adapter;
    late ViewPager viewPager;

    shared actual void onCreate(Bundle savedInstanceState) {
        if (BuildConfig.debug) {
            Utils.enableStrictMode();
        }
        super.onCreate(savedInstanceState);
        setContentView(R.Layout.image_detail_pager);
        value displayMetrics = DisplayMetrics();
        windowManager.defaultDisplay.getMetrics(displayMetrics);
        value height = displayMetrics.heightPixels;
        value width = displayMetrics.widthPixels;
        value longest = (height > width then height else width) / 2;
        value cacheParams = ImageCache.ImageCacheParams(this, imageCacheDir);
        cacheParams.setMemCacheSizePercent(0.25);
        imageFetcher = ImageFetcher(this, longest);
        imageFetcher.addImageCache(supportFragmentManager, cacheParams);
        imageFetcher.setImageFadeIn(false);
        adapter = ImagePagerAdapter(supportFragmentManager, Images.imageUrls.size);
        assert (is ViewPager pager = findViewById(R.Id.pager));
        viewPager = pager;
        viewPager.adapter = adapter;
        viewPager.pageMargin = resources.getDimension(R.Dimen.horizontal_page_margin).integer;
        viewPager.offscreenPageLimit = 2;
        window.addFlags(LayoutParams.flagFullscreen);
        if (Utils.hasHoneycomb()) {
            value actionBar = this.actionBar;
            actionBar.setDisplayShowTitleEnabled(false);
            actionBar.setDisplayHomeAsUpEnabled(true);
            viewPager.setOnSystemUiVisibilityChangeListener(object satisfies View.OnSystemUiVisibilityChangeListener {
                shared actual void onSystemUiVisibilityChange(Integer vis) {
                    if (vis.and(View.systemUiFlagLowProfile) != 0) {
                        actionBar.hide();
                    }
                    else {
                        actionBar.show();
                    }
                }
            });
            viewPager.systemUiVisibility = View.systemUiFlagLowProfile;
            actionBar.hide();
        }

        value extraCurrentItem = intent.getLongExtra(extraImage, -1);
        if (extraCurrentItem != -1) {
            viewPager.currentItem = extraCurrentItem;
        }
    }

    shared actual void onResume() {
        super.onResume();
        imageFetcher.setExitTasksEarly(false);
    }

    shared actual void onPause() {
        super.onPause();
        imageFetcher.setExitTasksEarly(true);
        imageFetcher.flushCache();
    }

    shared actual void onDestroy() {
        super.onDestroy();
        imageFetcher.closeCache();
    }

    shared actual Boolean onOptionsItemSelected(MenuItem item) {
        if (item.itemId == AndroidR.Id.home) {
            NavUtils.navigateUpFromSameTask(this);
            return true;
        }
        else if (item.itemId == R.Id.clear_cache) {
            imageFetcher.clearCache();
            Toast.makeText(this, R.String.clear_cache_complete_toast, Toast.lengthShort)
                 .show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    shared actual Boolean onCreateOptionsMenu(Menu menu) {
        menuInflater.inflate(R.Menu.main_menu, menu);
        return true;
    }

    class ImagePagerAdapter(FragmentManager fm, Integer size)
            extends FragmentStatePagerAdapter(fm) {

        count => size;

        getItem(Integer position)
                => ImageDetailFragment.newInstance(Images.imageUrls.get(position).string);

    }

    onClick(View v)
            => viewPager.systemUiVisibility
                = if (viewPager.systemUiVisibility.and(View.systemUiFlagLowProfile) != 0)
                then View.systemUiFlagVisible
                else View.systemUiFlagLowProfile;

}
