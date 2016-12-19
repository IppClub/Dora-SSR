package com.luvfight.dorothy;

import org.libsdl.app.SDLActivity;
import android.os.Bundle;
import android.content.pm.ApplicationInfo;

public class MainActivity extends SDLActivity {
	private static native void nativeSetPath(String path);

	@Override
	protected void onCreate(final Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		ApplicationInfo applicationInfo = this.getApplicationInfo();
		MainActivity.nativeSetPath(applicationInfo.sourceDir);
	}
}
