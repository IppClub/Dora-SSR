/* Copyright (c) 2026 Dora SSR contributors. MIT license (see repository LICENSE). */

package org.ippclub.dorassr;

import java.io.DataInputStream;
import java.io.EOFException;
import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Stream;

/** Detects Godot assets and API references in the game files staged for export. */
final class GameGodotDependency {
	private static final Pattern GODOT_ASSET = Pattern.compile("\\.(?:pck|gd|gdc|tscn|scn|tres|gdshader|gdshaderinc|gdextension)$");
	private static final Pattern SCRIPT = Pattern.compile("\\.(?:lua|yue|tl|ts|tsx|js|jsx|xml|wasm|wa|rs|vs|bl|json)$");
	private static final Pattern API = Pattern.compile("\\b(?:GodotNode|GodotPlayer|godotnode_[a-z_]+)\\b");
	private static final Pattern LUA_TEXT = Pattern.compile(
			"(--(?:\\[(=*)\\[[\\s\\S]*?\\]\\2\\]|[^\\r\\n]*))|([\"'])(?:\\\\[\\s\\S]|(?!\\3)[^\\\\])*+\\3|\\[(=*)\\[[\\s\\S]*?\\]\\4\\]");
	private static final Pattern JS_TEXT = Pattern.compile(
			"(//[^\\r\\n]*|/\\*[\\s\\S]*?\\*/)|([\"'`])(?:\\\\[\\s\\S]|(?!\\2)[^\\\\])*+\\2");
	private static final Pattern XML_TEXT = Pattern.compile("(<!--[\\s\\S]*?-->)|<!\\[CDATA\\[[\\s\\S]*?\\]\\]>");
	private static final int MAX_COMMENT_SCAN_BYTES = 1024 * 1024;
	private static final int OVERLAP = 32;

	private GameGodotDependency() {}

	static boolean isNeeded(File project) {
		try (Stream<Path> files = Files.walk(project.toPath())) {
			return files.filter(Files::isRegularFile).anyMatch(GameGodotDependency::usesGodot);
		} catch (IOException | UncheckedIOException error) {
			// Keep the runtime when the project cannot be fully inspected.
			return true;
		}
	}

	private static boolean usesGodot(Path file) {
		String name = file.getFileName().toString().toLowerCase(Locale.ROOT);
		if ("project.godot".equals(name) || GODOT_ASSET.matcher(name).find()) return true;
		try {
			if (name.endsWith(".res")) return isGodotResource(file);
			if (!SCRIPT.matcher(name).find()) return false;
			Pattern text = commentPattern(name.substring(name.lastIndexOf('.') + 1));
			if (text == null || Files.size(file) > MAX_COMMENT_SCAN_BYTES) return containsApi(file);
			// As in Web export, keep quoted API names and ignore comment tokens.
			String source = new String(Files.readAllBytes(file), StandardCharsets.ISO_8859_1);
			Matcher token = text.matcher(source);
			StringBuilder code = new StringBuilder(source.length());
			int previous = 0;
			while (token.find()) {
				code.append(source, previous, token.start());
				if (token.group(1) == null) code.append(token.group());
				else code.append(' ');
				previous = token.end();
			}
			code.append(source, previous, source.length());
			return API.matcher(code).find();
		} catch (IOException error) {
			return true;
		}
	}

	private static Pattern commentPattern(String extension) {
		switch (extension) {
			case "lua": case "yue": case "tl": return LUA_TEXT;
			case "ts": case "tsx": case "js": case "jsx": return JS_TEXT;
			case "xml": return XML_TEXT;
			default: return null;
		}
	}

	private static boolean isGodotResource(Path file) throws IOException {
		try (DataInputStream input = new DataInputStream(Files.newInputStream(file))) {
			int magic = input.readInt();
			return magic == 0x52535243 || magic == 0x52534343; // RSRC or RSCC
		} catch (EOFException error) {
			return false;
		}
	}

	private static boolean containsApi(Path file) throws IOException {
		try (Reader reader = Files.newBufferedReader(file, StandardCharsets.ISO_8859_1)) {
			char[] chunk = new char[8192 + OVERLAP];
			int carried = 0;
			for (int read; (read = reader.read(chunk, carried, chunk.length - carried)) != -1;) {
				int size = carried + read;
				if (API.matcher(new String(chunk, 0, size)).find()) return true;
				carried = Math.min(OVERLAP, size);
				System.arraycopy(chunk, size - carried, chunk, 0, carried);
			}
			return false;
		}
	}
}
