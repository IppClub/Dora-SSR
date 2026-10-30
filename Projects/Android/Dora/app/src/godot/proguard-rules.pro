# Godot's native Android wrappers resolve Java classes, methods and fields by
# fixed JNI names, including private Godot.restart(). The upstream Java-only
# AAR has no consumer rules covering every such entry. Keep the optional Godot
# package intact while continuing to shrink/optimize the rest of the Dora app.
-keep class org.godotengine.godot.** { *; }
-keep class org.ippclub.dorassr.GodotEmbed { *; }
-keep class org.ippclub.dorassr.GodotFileProvider { *; }
