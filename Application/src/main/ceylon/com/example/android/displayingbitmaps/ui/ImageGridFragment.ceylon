import android {
    AndroidR=R
}
import android.app {
    ActivityOptions
}
import android.content {
    Context,
    Intent
}
import android.os {
    Bundle
}
import android.support.v4.app {
    Fragment
}
import android.util {
    TypedValue
}
import android.view {
    LayoutInflater,
    Menu,
    MenuInflater,
    MenuItem,
    View,
    ViewGroup {
        LayoutParams
    },
    ViewTreeObserver
}
import android.widget {
    AbsListView,
    AdapterView,
    BaseAdapter,
    GridView,
    ImageView,
    Toast
}

import com.example.android.common.logger {
    Log
}
import com.example.android.displayingbitmaps {
    BuildConfig,
    R
}
import com.example.android.displayingbitmaps.provider {
    Images {
        ...
    }
}
import com.example.android.displayingbitmaps.util {
    ImageCache,
    ImageFetcher,
    Utils
}

shared class ImageGridFragment()
        extends Fragment()
        satisfies OnItemClickBase {

    value tag = "ImageGridFragment";
    value imageCacheDir = "thumbs";

    late Integer imageThumbSize;
    late Integer imageThumbSpacing;

    late ImageAdapter adapter;
    late ImageFetcher imageFetcher;

    shared actual void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setHasOptionsMenu(true);
        imageThumbSize = resources.getDimensionPixelSize(R.Dimen.image_thumbnail_size);
        imageThumbSpacing = resources.getDimensionPixelSize(R.Dimen.image_thumbnail_spacing);
        adapter = ImageAdapter(activity);
        value cacheParams = ImageCache.ImageCacheParams(activity, imageCacheDir);
        cacheParams.setMemCacheSizePercent(0.25);
        imageFetcher = ImageFetcher(activity, imageThumbSize);
        imageFetcher.setLoadingImage(R.Drawable.empty_photo);
        imageFetcher.addImageCache(activity.supportFragmentManager, cacheParams);
    }

    shared actual function onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        value v = inflater.inflate(R.Layout.image_grid_fragment, container, false);
        assert (is GridView gridView = v.findViewById(R.Id.gridView));
        gridView.setAdapter(adapter);
        gridView.setOnItemClickListener(this);
        gridView.setOnScrollListener(object satisfies AbsListView.OnScrollListener {
            shared actual void onScrollStateChanged(AbsListView absListView, Integer scrollState) {
                if (scrollState == AbsListView.OnScrollListener.scrollStateFling) {
                    if (!Utils.hasHoneycomb()) {
                        imageFetcher.setPauseWork(true);
                    }
                } else {
                    imageFetcher.setPauseWork(false);
                }
            }
            shared actual void onScroll(AbsListView absListView, Integer firstVisibleItem, Integer visibleItemCount, Integer totalItemCount) {}
        });
        gridView.viewTreeObserver.addOnGlobalLayoutListener(object satisfies ViewTreeObserver.OnGlobalLayoutListener {
            shared actual void onGlobalLayout() {
                if (adapter.numColumns == 0) {
                    value numColumns = gridView.width / (imageThumbSize + imageThumbSpacing);
                    if (numColumns>0) {
                        adapter.numColumns = numColumns;
                        adapter.itemHeight = (gridView.width / numColumns) - imageThumbSpacing;
                    }
                    if (BuildConfig.debug) {
                        Log.d(tag, "onCreateView - numColumns set to ``numColumns``");
                    }
                    if (Utils.hasJellyBean()) {
                        gridView.viewTreeObserver.removeOnGlobalLayoutListener(this);
                    } else {
                        gridView.viewTreeObserver.removeGlobalOnLayoutListener(this);
                    }
                }
            }
        });
        return v;
    }

    shared actual void onResume() {
        super.onResume();
        imageFetcher.setExitTasksEarly(false);
        adapter.notifyDataSetChanged();
    }

    shared actual void onPause() {
        super.onPause();
        imageFetcher.setPauseWork(false);
        imageFetcher.setExitTasksEarly(true);
        imageFetcher.flushCache();
    }

    shared actual void onDestroy() {
        super.onDestroy();
        imageFetcher.closeCache();
    }

    shared actual void onItemClick(AdapterView<out Object> parent, View v, small Integer position, Integer id) {
        value intent = Intent(activity, `ImageDetailActivity`);
        intent.putExtra(ImageDetailActivity.extraImage, id);
        if (Utils.hasJellyBean()) {
            value options = ActivityOptions.makeScaleUpAnimation(v, 0, 0, v.width, v.height);
            activity.startActivity(intent, options.toBundle());
        } else {
            startActivity(intent);
        }
    }

    onCreateOptionsMenu(Menu menu, MenuInflater inflater)
            => inflater.inflate(R.Menu.main_menu, menu);

    shared actual function onOptionsItemSelected(MenuItem item) {
        if (item.itemId == R.Id.clear_cache) {
            imageFetcher.clearCache();
            Toast.makeText(activity, R.String.clear_cache_complete_toast, Toast.lengthShort)
                 .show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    class ImageAdapter(Context context) extends BaseAdapter() {

        variable value _itemHeight = 0;
        variable value _numColumns = 0;
        variable value actionBarHeight = 0;

        variable LayoutParams imageViewLayoutParams
                = GridView.LayoutParams(LayoutParams.matchParent,
                                        LayoutParams.matchParent);

        value tv = TypedValue();
        if (context.theme.resolveAttribute(AndroidR.Attr.actionBarSize, tv, true)) {
            actionBarHeight = TypedValue.complexToDimensionPixelSize(tv.data, context.resources.displayMetrics);
        }

        shared Integer itemHeight => _itemHeight;
        assign itemHeight {
            if (itemHeight != _itemHeight) {
                _itemHeight = itemHeight;
                imageViewLayoutParams = GridView.LayoutParams(LayoutParams.matchParent, itemHeight);
                imageFetcher.setImageSize(itemHeight);
                notifyDataSetChanged();
            }
        }

        shared Integer numColumns => _numColumns;
        assign numColumns => _numColumns = numColumns;

        count => _numColumns == 0 then 0 else imageThumbUrls.size + _numColumns;

        getItem(Integer position)
                => imageThumbUrls[position - _numColumns];

        getItemId(Integer position)
                => position < _numColumns then 0 else position - _numColumns;

        viewTypeCount => 2;

        getItemViewType(Integer position)
                => position < _numColumns then 1 else 0;

        hasStableIds() => true;

        function imageView(View? convertView) {
            ImageView imageView;
            if (is ImageView convertView) {
                imageView = convertView;
            }
            else {
                imageView = RecyclingImageView(context);
                imageView.scaleType = ImageView.ScaleType.centerCrop;
                imageView.layoutParams = imageViewLayoutParams;
            }
            if (imageView.layoutParams.height != _itemHeight) {
                imageView.layoutParams = imageViewLayoutParams;
            }
            return imageView;
        }

        shared actual function getView(Integer position, View? convertView, ViewGroup container) {
            if (position < _numColumns) {
                value view = convertView else View(context);
                view.layoutParams = AbsListView.LayoutParams(LayoutParams.matchParent, actionBarHeight);
                return view;
            }
            else {
                value view = imageView(convertView);
                imageFetcher.loadImage(imageThumbUrls[position - _numColumns], view);
                return view;
            }
        }

    }
}
