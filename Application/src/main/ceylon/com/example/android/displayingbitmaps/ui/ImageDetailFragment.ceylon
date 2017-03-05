import android.os {
    Bundle
}
import android.support.v4.app {
    Fragment
}
import android.view {
    LayoutInflater,
    View{
        OnClickListener
    },
    ViewGroup
}
import android.widget {
    ImageView,
    ProgressBar
}
import com.example.android.displayingbitmaps {
    R
}
import com.example.android.displayingbitmaps.util {
    ImageFetcher,
    ImageWorker,
    Utils
}

shared class ImageDetailFragment
        extends Fragment
        satisfies ImageWorker.OnImageLoadedListener {

    static value imageDataExtra = "extra_image_data";

    shared static ImageDetailFragment newInstance(String imageUrl) {
        value fragment = ImageDetailFragment();
        value args = Bundle();
        args.putString(imageDataExtra, imageUrl);
        fragment.arguments = args;
        return fragment;
    }

    late String? imageUrl;
    late ImageView imageView;
    late ProgressBar progressBar;
    late ImageFetcher imageFetcher;

    shared new() extends Fragment() {}

    shared actual void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        imageUrl = if (exists arguments = this.arguments)
            then arguments.getString(imageDataExtra)
            else null;
    }

    shared actual View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
        value view = inflater.inflate(R.Layout.image_detail_fragment, container, false);
        assert (is ImageView imageView = view.findViewById(R.Id.imageView),
                is ProgressBar progressBar = view.findViewById(R.Id.progressbar));
        this.imageView = imageView;
        this.progressBar = progressBar;
        return view;
    }

    shared actual void onActivityCreated(Bundle savedInstanceState) {
        super.onActivityCreated(savedInstanceState);
        if (is ImageDetailActivity activity = this.activity) {
            imageFetcher = activity.imageFetcher;
            imageFetcher.loadImage(imageUrl, imageView, this);
        }
        if (is OnClickListener activity = this.activity, Utils.hasHoneycomb()) {
            imageView.setOnClickListener(activity);
        }
    }

    shared actual void onDestroy() {
        super.onDestroy();
        try {
            ImageWorker.cancelWork(imageView);
            imageView.setImageDrawable(null);
        }
        catch (e) {}
    }

    onImageLoaded(Boolean success) => progressBar.visibility = View.gone;

}
