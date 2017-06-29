package FoxitPdf;

import android.content.Context;
import android.graphics.Color;
import android.view.View;
import android.widget.RelativeLayout;
import android.app.Activity;

import com.foxit.sdk.PDFViewCtrl;
import com.foxit.sdk.common.Library;
import com.foxit.sdk.common.PDFException;
import com.foxit.uiextensions.UIExtensionsManager;
import com.foxit.uiextensions.pdfreader.impl.PDFReader;

import java.io.InputStream;
import java.io.ByteArrayInputStream;
import java.nio.charset.Charset;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.json.JSONArray;
import org.json.JSONException;

/**
 * This class echoes a string called from JavaScript.
 */
public class FoxitPdf extends CordovaPlugin {
    private static int errCode = PDFException.e_errSuccess;
    static {
        System.loadLibrary("rdk");
    }

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("init")) {
            final String sn = args.getString(0);
            final String key = args.getString(1);
            this.init(sn, key, callbackContext);
            return true;
        } else if (action.equals("openPdf")){
            final String filePath = args.getString(0).replace("file://", "");
            this.openDoc(filePath, callbackContext);
            return true;
        }

        return false;
    }

    private void init(final String sn, final String key, final CallbackContext callbackContext) {
        try {
            Library.init(sn, key);
        } catch (PDFException e) {
            errCode = e.getLastError();
            callbackContext.error("Failed to initialize Foxit library.");
        }

        errCode = PDFException.e_errSuccess;
        callbackContext.error("Succeed to initialize Foxit library.");
    }

    private void openDoc(final String path, final CallbackContext callbackContext) {
        if (path == null || path.trim().length() < 1) {
            callbackContext.error("Please input validate path.");
            return;
        }

        if (errCode != PDFException.e_errSuccess) {
            callbackContext.error("Please initialize Foxit library Firstly.");
        }

        final Context context = this.cordova.getActivity();
        final Activity activity =  this.cordova.getActivity();
        this.cordova.getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
              final RelativeLayout relativeLayout = new RelativeLayout(context);
              RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                      RelativeLayout.LayoutParams.MATCH_PARENT, RelativeLayout.LayoutParams.MATCH_PARENT);

              final PDFViewCtrl pdfViewCtrl = new PDFViewCtrl(context);

              relativeLayout.addView(pdfViewCtrl, params);
              relativeLayout.setWillNotDraw(false);
              relativeLayout.setBackgroundColor(Color.argb(0xff, 0xe1, 0xe1, 0xe1));
              relativeLayout.setDrawingCacheEnabled(true);
              setContentView(relativeLayout);

              final String UIExtensionsConfig = "{\n" +
                  "    \"defaultReader\": true,\n" +
                  "    \"modules\": {\n" +
                  "        \"readingbookmark\": true,\n" +
                  "        \"outline\": true,\n" +
                  "        \"annotations\": true,\n" +
                  "        \"thumbnail\" : false,\n" +
                  "        \"attachment\": true,\n" +
                  "        \"signature\": false,\n" +
                  "        \"search\": true,\n" +
                  "        \"pageNavigation\": true,\n" +
                  "        \"form\": true,\n" +
                  "        \"selection\": true,\n" +
                  "        \"encryption\" : false\n" +
                  "    }\n" +
                  "}\n";

              InputStream stream = new ByteArrayInputStream(UIExtensionsConfig.getBytes(Charset.forName("UTF-8")));
              UIExtensionsManager.Config config = new UIExtensionsManager.Config(stream);

              UIExtensionsManager uiextensionsManager = new UIExtensionsManager(context, relativeLayout, pdfViewCtrl,config);
              uiextensionsManager.setAttachedActivity(activity);

              pdfViewCtrl.setUIExtensionsManager(uiextensionsManager);

              PDFReader mPDFReader= (PDFReader) uiextensionsManager.getPDFReader();
              mPDFReader.onCreate(activity, pdfViewCtrl, null);
              mPDFReader.openDocument(path, null);
              setContentView(mPDFReader.getContentView());
              mPDFReader.onStart(activity);
            }
        });

//        callbackContext.success("Open document success.");
    }

    private void setContentView(View view) {
        this.cordova.getActivity().setContentView(view);
    }
}
