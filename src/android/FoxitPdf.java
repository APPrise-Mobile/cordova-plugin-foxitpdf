package FoxitPdf;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.RelativeLayout;

import com.foxit.sdk.PDFViewCtrl;
import com.foxit.sdk.common.Library;
import com.foxit.sdk.common.PDFException;
import com.foxit.uiextensions.UIExtensionsManager;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class FoxitPdf extends CordovaPlugin {
    private static int errCode = PDFException.e_errSuccess;
    private PDFViewCtrl pdfViewCtrl = null;
    static {
        System.loadLibrary("rdk");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
            final String sn = args.getString(0);
            final String key = args.getString(0);
            this.init(callbackContext);
            return true;
        } else if (action.equals("Preview")){
            final String filePath = args.getString(0);
            this.openDoc(filePath, callbackContext);
            return true;
        }

        return false;
    }

    private void init(CallbackContext callbackContext) {
        try {
            Library.init(sn, key);
        } catch (PDFException e) {
            errCode = e.getLastError();
            callbackContext.error("Failed to initialize Foxit library.");
        }

        errCode = PDFException.e_errSuccess;
        callbackContext.error("Succeed to initialize Foxit library.");
    }

    private void openDoc(final String path, CallbackContext callbackContext) {
        if (path == null || path.trim().length() < 1) {
            callbackContext.error("Please input validate path.");
            return;
        }

        if (errCode != PDFException.e_errSuccess) {
            callbackContext.error("Please initialize Foxit library Firstly.");
        }

        final Context context = this.cordova.getActivity();
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                final RelativeLayout relativeLayout = new RelativeLayout(context);
                RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                        RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);

                pdfViewCtrl = new PDFViewCtrl(context);

                relativeLayout.addView(pdfViewCtrl, params);
                relativeLayout.setWillNotDraw(false);
                relativeLayout.setBackgroundColor(Color.argb(0xff, 0xe1, 0xe1, 0xe1));
                relativeLayout.setDrawingCacheEnabled(true);
                setContentView(relativeLayout);

                UIExtensionsManager uiExtensionsManager = new UIExtensionsManager(context,
                        relativeLayout, pdfViewCtrl);

                pdfViewCtrl.setUIExtensionsManager(uiExtensionsManager);

                pdfViewCtrl.openDoc(path, null);
            }
        });

//        callbackContext.success("Open document success.");
    }

    private void setContentView(View view) {
        this.cordova.getActivity().setContentView(view);
    }
}
