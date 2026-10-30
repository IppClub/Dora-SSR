package org.dora.godotrc1;

import android.app.Activity;
import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import java.io.File;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import org.json.JSONObject;

/** Separate controller APK; the target stays an ordinary nondebuggable release.
 * Uses only Android framework APIs and the public Lua fixture's result file.
 * The controller must share the local QA signing certificate with the target.
 */
public final class ReleaseLifecycle extends Instrumentation {
    private Bundle arguments;
    @Override public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        this.arguments = arguments == null ? new Bundle() : arguments;
        start();
    }
    private static void deleteTree(File file) throws Exception {
        if (!file.exists()) return;
        if (file.isDirectory()) {
            File[] children = file.listFiles();
            if (children != null) for (File child : children) deleteTree(child);
        }
        if (!file.delete()) throw new IllegalStateException("Cannot delete " + file);
    }
    private static void write(File file, String value) throws Exception {
        Files.write(file.toPath(), value.getBytes(StandardCharsets.UTF_8));
    }
    private static void exportEvidence(File source, File destination) throws Exception {
        deleteTree(destination);
        if (!destination.mkdirs()) throw new IllegalStateException("Cannot create " + destination);
        File[] files = source.listFiles();
        if (files == null) throw new IllegalStateException("Cannot list " + source);
        for (File file : files) {
            String name = file.getName();
            if (file.isFile() && (name.endsWith(".png") || name.equals("result.json")))
                Files.copy(file.toPath(), new File(destination, name).toPath(), StandardCopyOption.REPLACE_EXISTING);
        }
    }
    @Override public void onStart() {
        Bundle result = new Bundle();
        try {
            int buffers = Integer.parseInt(arguments.getString("buffers", "3"));
            if (buffers < 2 || buffers > 4) throw new IllegalArgumentException("Invalid buffers");
            boolean direct = "1".equals(arguments.getString("direct", "0"));
            boolean missing = "1".equals(arguments.getString("missing", "0"));
            File fixture = new File(getTargetContext().getFilesDir(), "godot-release");
            deleteTree(fixture);
            if (!fixture.mkdirs()) throw new IllegalStateException("Cannot create " + fixture);
            File[] mediaRoots = getTargetContext().getExternalMediaDirs();
            if (mediaRoots.length == 0 || mediaRoots[0] == null)
                throw new IllegalStateException("Target external media directory unavailable");
            File external = new File(mediaRoots[0], "dora-godot-evidence");
            deleteTree(external);
            write(new File(fixture, "buffers.txt"), Integer.toString(buffers));
            if (missing) write(new File(fixture, "expect-missing"), "1");
            Intent intent = getTargetContext().getPackageManager()
                .getLaunchIntentForPackage("org.ippclub.dorassr");
            if (intent == null) throw new IllegalStateException("Missing target activity");
            if (direct) intent.putExtra("DORA_GODOT_GL_DIRECT", "1");
            Activity activity = startActivitySync(intent);
            File complete = new File(fixture, "result.json");
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
            exportEvidence(fixture, external);
            write(new File(external, "controller.json"), new JSONObject()
                .put("buffers", buffers).put("direct", direct).put("missing", missing).toString());
            Log.i("DoraReleaseLifecycle", "QA_EVIDENCE_EXPORTED " + external);
            result.putString("result", "Activity finished after public Lua completion");
            finish(Activity.RESULT_OK, result);
        } catch (Exception error) {
            Log.e("DoraReleaseLifecycle", "QA_ACTIVITY_FAILURE", error);
            result.putString("error", error.toString());
            finish(Activity.RESULT_CANCELED, result);
        }
    }
}
