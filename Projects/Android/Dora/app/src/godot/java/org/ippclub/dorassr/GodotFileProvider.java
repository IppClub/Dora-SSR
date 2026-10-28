package org.ippclub.dorassr;

import androidx.annotation.Keep;
import androidx.core.content.FileProvider;

/** Keep Godot's authority/path rules separate from Dora's existing provider. */
@Keep
public final class GodotFileProvider extends FileProvider { }
