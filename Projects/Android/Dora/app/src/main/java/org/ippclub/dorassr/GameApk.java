/* Copyright (c) 2016-2026 Li Jin <dragon-fly@qq.com>

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. */

package org.ippclub.dorassr;

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Paint;
import android.graphics.RectF;
import android.util.TypedValue;

import com.android.apksig.ApkSigner;
import com.android.apksig.ApkVerifier;

import org.bouncycastle.asn1.x500.X500Name;
import org.bouncycastle.cert.jcajce.JcaX509CertificateConverter;
import org.bouncycastle.cert.jcajce.JcaX509v3CertificateBuilder;
import org.bouncycastle.operator.jcajce.JcaContentSignerBuilder;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.math.BigInteger;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.security.KeyPairGenerator;
import java.security.MessageDigest;
import java.security.KeyStore;
import java.security.PrivateKey;
import java.security.SecureRandom;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.TreeSet;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;
import java.util.zip.ZipOutputStream;

/** Exports an independent Android game using the currently installed Dora APK. */
final class GameApk {
	private static final String KEY_ALIAS = "game";
	private static final String MANIFEST = "AndroidManifest.xml";
	private static final int ICON_SIZE = 512;
	private static final long DAY = 24L * 60 * 60 * 1000;

	private GameApk() {}

	static KeyStore createKeyStore(char[] password) throws Exception {
		SecureRandom random = new SecureRandom();
		KeyPairGenerator generator = KeyPairGenerator.getInstance("RSA");
		generator.initialize(3072, random);
		java.security.KeyPair keyPair = generator.generateKeyPair();
		X500Name name = new X500Name("CN=Dora Game");
		long now = System.currentTimeMillis();
		BigInteger serial = new BigInteger(128, random).setBit(127);
		X509Certificate certificate = new JcaX509CertificateConverter().getCertificate(
				new JcaX509v3CertificateBuilder(name, serial, new Date(now - DAY),
						new Date(now + 365L * 50 * DAY), name, keyPair.getPublic())
						.build(new JcaContentSignerBuilder("SHA256withRSA").build(keyPair.getPrivate())));
		KeyStore store = KeyStore.getInstance("PKCS12");
		store.load(null, password);
		store.setKeyEntry(KEY_ALIAS, keyPair.getPrivate(), password, new Certificate[]{certificate});
		return store;
	}

	static KeyStore loadKeyStore(InputStream input, char[] password) throws Exception {
		KeyStore store = KeyStore.getInstance("PKCS12");
		store.load(input, password);
		getSigner(store, password);
		return store;
	}

	static boolean validPackageName(String gameId, String originalId) {
		return gameId.length() <= 200 && !gameId.equals(originalId)
				&& gameId.matches("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+");
	}

	static String fingerprint(KeyStore store, char[] password) throws Exception {
		byte[] digest = MessageDigest.getInstance("SHA-256").digest(
				getSigner(store, password).getCertificates().get(0).getEncoded());
		StringBuilder hex = new StringBuilder();
		for (byte value : digest) hex.append(String.format(Locale.ROOT, "%02x", value & 255));
		return hex.toString();
	}

	private static ApkSigner.SignerConfig getSigner(KeyStore store, char[] password) throws Exception {
		String alias = null;
		for (Enumeration<String> keys = store.aliases(); keys.hasMoreElements();) {
			String candidate = keys.nextElement();
			if (!store.isKeyEntry(candidate)) continue;
			if (alias != null) throw new IOException("The signing file contains multiple keys");
			alias = candidate;
		}
		if (alias == null || !(store.getKey(alias, password) instanceof PrivateKey)) {
			throw new IOException("The signing file has no private key");
		}
		PrivateKey key = (PrivateKey) store.getKey(alias, password);
		Certificate[] chain = store.getCertificateChain(alias);
		if (chain == null || chain.length == 0) throw new IOException("The signing key has no certificate");
		List<X509Certificate> certificates = new ArrayList<>();
		for (Certificate certificate : chain) certificates.add((X509Certificate) certificate);
		return new ApkSigner.SignerConfig.Builder("GAME", key, certificates).build();
	}

	static Set<String> availableAbis(File source) throws IOException {
		try (ZipFile template = new ZipFile(source)) {
			return availableAbis(template);
		}
	}

	static boolean isTemplateAvailable(File source, boolean needsGodot) throws IOException {
		try (ZipFile template = new ZipFile(source)) {
			Set<String> abis = availableAbis(template);
			return !abis.isEmpty() && template.getEntry(MANIFEST) != null && template.getEntry("classes.dex") != null
					&& (!needsGodot || abis.stream().allMatch(abi -> template.getEntry("lib/" + abi + "/libgodot_android.so") != null));
		}
	}

	private static Set<String> availableAbis(ZipFile template) {
		Set<String> abis = new TreeSet<>();
		for (Enumeration<? extends ZipEntry> entries = template.entries(); entries.hasMoreElements();) {
			String name = entries.nextElement().getName();
			if (name.startsWith("lib/") && name.endsWith("/libmain.so")) {
				int end = name.indexOf('/', 4);
				if (end > 4 && end == name.lastIndexOf('/')) abis.add(name.substring(4, end));
			}
		}
		return abis;
	}

	static void export(File source, Resources resources, File assets, File unsigned, File output, String originalId, String gameId,
			String title, int versionCode, String versionName, Set<String> abis, KeyStore store, char[] password,
			boolean keepGodot, InputStream exportPolicy) throws Exception {
		if (!validPackageName(gameId, originalId) || versionCode < 1
				|| title.trim().isEmpty() || versionName.trim().isEmpty()) {
			throw new IOException("Invalid Android package name, title, or version");
		}
		File project = new File(assets, "Game");
		if (!new File(assets, "Script/init.lua").isFile() || !project.isDirectory()) {
			throw new IOException("The game snapshot has no startup script or project files");
		}
		ApkSigner.SignerConfig signer = getSigner(store, password);
		TemplatePolicy policy = new TemplatePolicy(exportPolicy);
		byte[] icon = readGameIcon(new File(project, "icon.png"));
		int iconId = icon == null ? android.R.mipmap.sym_def_app_icon
				: resources.getIdentifier("game_export_icon", "drawable", originalId);
		String iconEntry = null;
		if (icon != null) {
			// Resolve the compiled path so it matches the installed APK's resource table.
			TypedValue resource = new TypedValue();
			resources.getValue(iconId, resource, true);
			if (resource.string == null) throw new IOException("The Dora APK game icon resource is not a file");
			iconEntry = resource.string.toString();
		}
		try (ZipFile template = new ZipFile(source);
				ZipOutputStream zip = new ZipOutputStream(Files.newOutputStream(unsigned.toPath()))) {
			if (template.getEntry(MANIFEST) == null || template.getEntry("classes.dex") == null) {
				throw new IOException("A complete Dora APK is required");
			}
			if (abis.isEmpty() || !availableAbis(template).containsAll(abis)) {
				throw new IOException(Locale.getDefault().getLanguage().equals("zh")
						? "请选择 Dora APK 支持的 Android 架构"
						: "Select at least one Android ABI supported by this Dora APK.");
			}
			if (keepGodot && abis.stream().anyMatch(abi -> template.getEntry("lib/" + abi + "/libgodot_android.so") == null)) {
				throw new IOException(Locale.getDefault().getLanguage().equals("zh")
						? "此项目需要 Godot 运行库，请使用包含 Godot 的 Dora APK 导出"
						: "Use a Dora APK with Godot to export this project.");
			}
			if (iconEntry != null && template.getEntry(iconEntry) == null) {
				throw new IOException("The Dora APK is missing the game icon resource");
			}
			for (Enumeration<? extends ZipEntry> entries = template.entries(); entries.hasMoreElements();) {
				ZipEntry item = entries.nextElement();
				String name = item.getName();
				if (item.isDirectory() || policy.excludes(name)) continue;
				if (name.startsWith("lib/")) {
					int end = name.indexOf('/', 4);
					if (end <= 4 || !abis.contains(name.substring(4, end))) continue;
					// Android resolves this optional runtime on demand via dlopen.
					if (!keepGodot && name.endsWith("/libgodot_android.so")) continue;
				}
				if (MANIFEST.equals(name)) {
					try (InputStream input = template.getInputStream(item)) {
						byte[] manifest = readManifest(input, item.getSize());
						zip.putNextEntry(new ZipEntry(name));
						zip.write(GameManifest.rewrite(manifest, originalId, gameId, title, versionCode, versionName, iconId));
					}
				} else if (name.equals(iconEntry)) {
					zip.putNextEntry(new ZipEntry(name));
					zip.write(icon);
				} else {
					ZipEntry entry = new ZipEntry(name);
					if (item.getMethod() == ZipEntry.STORED || "resources.arsc".equals(name)) {
						entry.setMethod(ZipEntry.STORED);
						entry.setSize(item.getSize());
						entry.setCrc(item.getCrc());
					}
					zip.putNextEntry(entry);
					try (InputStream input = template.getInputStream(item)) {
						transfer(input, zip);
					}
				}
				zip.closeEntry();
			}
			appendAssets(zip, assets, "assets/");
		}
		new ApkSigner.Builder(Collections.singletonList(signer))
				.setInputApk(unsigned)
				.setOutputApk(output)
				.setAlignmentPreserved(false)
				.setLibraryPageAlignmentBytes(16384)
				// Dora targets Android 9 and newer, which support APK signing blocks.
				.setV1SigningEnabled(false)
				.setV4SigningEnabled(false)
				.build().sign();
		if (!new ApkVerifier.Builder(output).build().verify().isVerified()) {
			throw new IOException("The exported APK failed signature verification");
		}
	}

	private static byte[] readGameIcon(File file) throws IOException {
		if (!file.isFile()) return null;

		BitmapFactory.Options options = new BitmapFactory.Options();
		options.inJustDecodeBounds = true;
		BitmapFactory.decodeFile(file.getPath(), options);
		if (!"image/png".equals(options.outMimeType) || options.outWidth <= 0 || options.outHeight <= 0) {
			throw new IOException("Project icon.png must be a readable PNG image");
		}
		// Keep the decoding bitmap small even for high-resolution artwork.
		int longest = Math.max(options.outWidth, options.outHeight);
		options.inSampleSize = 1;
		while (longest / options.inSampleSize >= 2 * ICON_SIZE) options.inSampleSize *= 2;
		options.inJustDecodeBounds = false;
		options.inPreferredConfig = Bitmap.Config.ARGB_8888;
		Bitmap source = BitmapFactory.decodeFile(file.getPath(), options);
		if (source == null) throw new IOException("Could not decode project icon.png");
		try {
			Bitmap icon = Bitmap.createBitmap(ICON_SIZE, ICON_SIZE, Bitmap.Config.ARGB_8888);
			try {
				float scale = (float) ICON_SIZE / Math.max(source.getWidth(), source.getHeight());
				float width = source.getWidth() * scale;
				float height = source.getHeight() * scale;
				float left = (ICON_SIZE - width) / 2;
				float top = (ICON_SIZE - height) / 2;
				new Canvas(icon).drawBitmap(source, null, new RectF(left, top, left + width, top + height),
						new Paint(Paint.FILTER_BITMAP_FLAG));
				ByteArrayOutputStream encoded = new ByteArrayOutputStream();
				if (!icon.compress(Bitmap.CompressFormat.PNG, 100, encoded)) {
					throw new IOException("Could not encode project icon.png");
				}
				return encoded.toByteArray();
			} finally {
				icon.recycle();
			}
		} finally {
			source.recycle();
		}
	}

	private static final class TemplatePolicy {
		private final List<String> paths, directories, libraries, names, prefixes, suffixes;

		TemplatePolicy(InputStream source) throws IOException, JSONException {
			ByteArrayOutputStream bytes = new ByteArrayOutputStream();
			transfer(source, bytes);
			JSONObject rules = new JSONObject(new String(bytes.toByteArray(), StandardCharsets.UTF_8)).getJSONObject("androidTemplate");
			paths = strings(rules, "excludedPaths");
			directories = strings(rules, "excludedDirectories");
			libraries = strings(rules, "excludedLibraries");
			names = strings(rules, "signatureNames");
			prefixes = strings(rules, "signaturePrefixes");
			suffixes = strings(rules, "signatureSuffixes");
		}

		private static List<String> strings(JSONObject rules, String key) throws JSONException {
			JSONArray values = rules.getJSONArray(key);
			List<String> result = new ArrayList<>(values.length());
			for (int i = 0; i < values.length(); ++i) result.add(values.getString(i));
			return result;
		}

		boolean excludes(String path) {
			if (paths.contains(path) || directories.stream().anyMatch(path::startsWith)) return true;
			if (path.startsWith("lib/") && libraries.stream().anyMatch(name -> path.endsWith("/" + name))) return true;
			if (!path.startsWith("META-INF/")) return false;
			String name = path.substring("META-INF/".length()).toLowerCase(Locale.ROOT);
			return !name.contains("/") && (names.contains(name)
					|| prefixes.stream().anyMatch(name::startsWith) || suffixes.stream().anyMatch(name::endsWith));
		}
	}

	private static byte[] readManifest(InputStream input, long size) throws IOException {
		if (size <= 0 || size > 2 * 1024 * 1024) throw new IOException("Unexpected Android manifest size");
		byte[] bytes = new byte[(int) size];
		new java.io.DataInputStream(input).readFully(bytes);
		return bytes;
	}

	private static void appendAssets(ZipOutputStream zip, File directory, String prefix) throws IOException {
		File[] children = directory.listFiles();
		if (children == null) throw new IOException("Could not read " + directory);
		for (File child : children) {
			if (child.isDirectory()) {
				appendAssets(zip, child, prefix + child.getName() + "/");
			} else {
				zip.putNextEntry(new ZipEntry(prefix + child.getName()));
				try (InputStream input = Files.newInputStream(child.toPath())) {
					transfer(input, zip);
				}
				zip.closeEntry();
			}
		}
	}

	private static void transfer(InputStream input, OutputStream output) throws IOException {
		byte[] buffer = new byte[65536];
		for (int read; (read = input.read(buffer)) != -1;) output.write(buffer, 0, read);
	}
}
