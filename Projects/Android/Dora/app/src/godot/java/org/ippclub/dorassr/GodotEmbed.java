package org.ippclub.dorassr;

import android.app.Activity;
import android.util.Log;
import android.os.Looper;
import java.util.concurrent.FutureTask;
import java.util.concurrent.TimeUnit;
import androidx.annotation.Keep;
import java.lang.ref.WeakReference;
import java.util.Arrays;
import java.util.Collections;
import org.godotengine.godot.Godot;
import org.godotengine.godot.GodotHost;

/** Optional upstream Android services, with no Godot render view or event loop. */
@Keep
public final class GodotEmbed implements GodotHost {
    private final WeakReference<Activity> activity;
    private final Godot godot;
    private static GodotEmbed owner;
    private GodotEmbed(Activity activity) {
        this.activity = new WeakReference<>(activity);
        this.godot = Godot.getInstance(activity);
    }
    @Override public Activity getActivity() { return activity.get(); }
    @Override public Godot getGodot() { return godot; }
    // Godot project teardown must not terminate the containing Dora Activity.
    @Override public void onGodotForceQuit(Godot instance) { }
    @Override public boolean onGodotForceQuit(int instanceId) { return instanceId == 0; }
    @Keep public static synchronized boolean prepare(Activity activity, String[] arguments) {
        if (owner != null) return false;
        try {
            GodotEmbed next;
            if (Looper.myLooper() == Looper.getMainLooper()) {
                next = new GodotEmbed(activity);
            } else {
                // Upstream services install Handler-backed device listeners.
                // Construct them on UI, then initialize Main on Dora's owner.
                FutureTask<GodotEmbed> create = new FutureTask<>(() -> new GodotEmbed(activity));
                activity.runOnUiThread(create);
                next = create.get(30, TimeUnit.SECONDS);
            }
            if (!next.godot.initEngine(next, Arrays.asList(arguments), Collections.emptySet())) return false;
            owner = next;
            // Deliberately do not call onInitRenderView: Dora owns EGL/present.
            Log.i("DoraGodot", "Upstream Android services prepared; render view remains host-owned");
            return true;
        } catch (Exception error) {
            if (error instanceof InterruptedException) Thread.currentThread().interrupt();
            Log.e("DoraGodot", "Cannot prepare embedded Android services", error);
            return false;
        }
    }
}
