package org.dora.godotrc1;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import org.json.JSONObject;

/** Separate controller APK; the target stays an ordinary nondebuggable release.
 * Uses only Android framework APIs and the public Lua fixture's result file.
 * The controller must share the local QA signing certificate with the target.
 */
public final class ReleaseLifecycle extends Instrumentation {
    @Override public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        start();
    }
    @Override public void onStart() {
        Bundle result = new Bundle();
        try {
            Intent intent = getTargetContext().getPackageManager()
                .getLaunchIntentForPackage("org.ippclub.dorassr");
            if (intent == null) throw new IllegalStateException("Missing target activity");
            Activity activity = startActivitySync(intent);
            File complete = new File(getTargetContext().getFilesDir(), "godot-release/result.json");
            long deadline = System.nanoTime() + 90_000_000_000L;
            while (!complete.isFile()) {
                if (System.nanoTime() > deadline) throw new IllegalStateException("No Lua completion");
                Thread.sleep(50);
            }
            JSONObject json = new JSONObject(new String(Files.readAllBytes(complete.toPath()), StandardCharsets.UTF_8));
            if (!json.getBoolean("complete")) throw new IllegalStateException("Incomplete Lua result");
            Log.i("DoraReleaseLifecycle", "QA_ACTIVITY_FINISH_REQUESTED");
            runOnMainSync(activity::finish);
            while (!activity.isDestroyed()) {
                if (System.nanoTime() > deadline) throw new IllegalStateException("Activity destruction timed out");
                Thread.sleep(50);
            }
            // Queue behind onDestroy: SDL joins the native thread before its
            // callback returns. isDestroyed alone becomes true too early.
            runOnMainSync(() -> Log.i("DoraReleaseLifecycle", "QA_ACTIVITY_DESTROYED"));
            result.putString("result", "Activity finished after public Lua completion");
            finish(Activity.RESULT_OK, result);
        } catch (Exception error) {
            Log.e("DoraReleaseLifecycle", "QA_ACTIVITY_FAILURE", error);
            result.putString("error", error.toString());
            finish(Activity.RESULT_CANCELED, result);
        }
    }
}
