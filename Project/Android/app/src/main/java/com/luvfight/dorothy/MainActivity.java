package com.luvfight.dorothy;

import org.libsdl.app.SDLActivity;
import android.os.Bundle;

public class MainActivity extends SDLActivity {
	private static native void nativeSetPath(String path);
	private static native void nativeSetScreenDensity(float density);

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		MainActivity.nativeSetPath(this.getApplicationInfo().sourceDir);
		MainActivity.nativeSetScreenDensity(this.getResources().getDisplayMetrics().density);
	}
}
