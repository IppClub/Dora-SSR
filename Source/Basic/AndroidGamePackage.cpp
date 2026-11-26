/* Copyright (c) 2026 Li Jin <dragon-fly@qq.com>
 * SPDX-License-Identifier: MIT */
#include "Const/Header.h"
#include "Basic/GamePackage.h"

#if DORA_APK_EXPORT
#include "Other/utf8.h"
#include "miniz.h"
#include <openssl/evp.h>
#include <openssl/pkcs12.h>
#include <openssl/rand.h>
#include <openssl/rsa.h>
#include <openssl/x509.h>
#include <regex>
#include <unordered_set>

namespace Dora::GamePackage {
namespace {
using Bytes = std::string;
using View = std::string_view;
constexpr uint32_t MaxApk = 0x7fffffff;
constexpr uint16_t Stored = 0;
constexpr uint16_t Deflated = 8;

uint32_t number(View data, size_t offset, size_t count) {
	require(offset <= data.size() && count <= data.size() - offset, "Truncated Android package metadata");
	uint32_t value = 0;
	for (size_t i = 0; i < count; i++) value |= static_cast<uint32_t>(static_cast<uint8_t>(data[offset + i])) << (8 * i);
	return value;
}

void put(Bytes& data, size_t offset, uint64_t value, size_t count) {
	require(offset <= data.size() && count <= data.size() - offset, "Invalid Android package metadata offset");
	for (size_t i = 0; i < count; i++) data[offset + i] = static_cast<char>(value >> (8 * i));
}

Bytes word(uint64_t value, size_t count = 4) {
	Bytes result(count, '\0');
	put(result, 0, value, count);
	return result;
}

Bytes field(View value) { return word(value.size()) + Bytes(value); }

class Manifest {
public:
	explicit Manifest(Bytes content)
		: _input(std::move(content)) {
		require(number(_input, 0, 2) == 3 && number(_input, 2, 2) == 8 && number(_input, 4, 4) == _input.size(), "Invalid Android manifest");
		_header = number(_input, 10, 2);
		_size = number(_input, 12, 4);
		_count = number(_input, 16, 4);
		_flags = number(_input, 24, 4);
		_strings = number(_input, 28, 4);
		require(number(_input, 8, 2) == 1 && _header >= 28 && number(_input, 20, 4) == 0
			&& _header + _count * 4ull <= _strings && _strings <= _size && 8ull + _size <= _input.size(), "Invalid Android string pool");
	}

	Bytes rewrite(View package, View title, View version, uint32_t code) {
		enum Field { Package = 1, Code = 2, Version = 4, Label = 8, Icon = 16 };
		unsigned found = 0;
		std::string original;
		Bytes content;
		size_t keepFrom = 8 + _size;
		size_t filter = std::string::npos;
		size_t omit = std::string::npos;
		bool launcher = false;
		for (size_t at = keepFrom; at < _input.size();) {
			auto kind = number(_input, at, 2);
			auto header = number(_input, at + 2, 2);
			auto size = number(_input, at + 4, 4);
			require(header >= 8 && header <= size && size <= _input.size() - at, "Invalid Android XML chunk");
			if (kind == 0x102 || kind == 0x103) {
				auto element = at + header;
				require(element + (kind == 0x102 ? 20 : 8) <= at + size, "Invalid Android XML element");
				auto tag = stringAt(number(_input, element + 4, 4));
				if (kind == 0x102 && tag == "intent-filter") {
					filter = at;
					launcher = false;
				} else if (kind == 0x103 && tag == "intent-filter" && filter != std::string::npos) {
					if (!launcher) {
						content.append(_input, keepFrom, filter - keepFrom);
						keepFrom = at + size;
					}
					filter = std::string::npos;
				} else if (kind == 0x103 && omit != std::string::npos) {
					content.append(_input, keepFrom, omit - keepFrom);
					keepFrom = at + size;
					omit = std::string::npos;
				}
				if (kind == 0x102) {
					auto start = element + number(_input, element + 8, 2);
					auto stride = number(_input, element + 10, 2);
					auto count = number(_input, element + 12, 2);
					require(start >= element + 20 && stride >= 20 && start + stride * uint64_t(count) <= at + size, "Invalid Android XML attributes");
					for (uint32_t i = 0; i < count; ++i) {
						auto attribute = start + i * stride;
						auto name = stringAt(number(_input, attribute + 4, 4));
						auto value = _input[attribute + 15] == 3 ? stringAt(number(_input, attribute + 16, 4)) : "";
						if (tag == "manifest" && name == "package") {
							original = value;
							require(!original.empty() && original != package, "Choose a package name different from Dora");
							setText(attribute, package);
							found |= Package;
						} else if (tag == "manifest" && name == "versionCode") {
							setValue(attribute, 0x10, code);
							found |= Code;
						} else if (tag == "manifest" && name == "versionName") {
							setText(attribute, version);
							found |= Version;
						} else if (tag == "application" && name == "label") {
							setText(attribute, title);
							found |= Label;
						} else if (tag == "application" && (name == "icon" || name == "roundIcon")) {
							setValue(attribute, 1, 0x0108002c);
							if (name == "icon") found |= Icon;
						} else if (filter != std::string::npos && tag == "action" && name == "name" && value == "android.intent.action.MAIN") {
							launcher = true;
						} else if (tag == "uses-permission" && name == "name" && value == "android.permission.REQUEST_INSTALL_PACKAGES") {
							omit = at;
						} else if (!original.empty() && value.starts_with(original + ".") && (name == "authorities" || name == "permission"
							|| (name == "name" && (tag == "permission" || tag == "uses-permission")))) {
							setText(attribute, Bytes(package) + value.substr(original.size()));
						} else if (tag == "activity" && name == "name" && value.starts_with('.')) {
							setText(attribute, "org.ippclub.dorassr" + value);
						}
					}
				}
			}
			at += size;
		}
		require(found == (Package | Code | Version | Label | Icon), "The Dora APK is missing game export metadata");
		content.append(_input, keepFrom);
		return encode(content);
	}
private:
	bool isUtf8() const { return (_flags & 0x100) != 0; }
	std::string stringAt(uint32_t index) const {
		require(index < _count, "Invalid Android string index");
		View pool = View(_input).substr(8 + _strings, _size - _strings);
		size_t at = number(_input, 8 + _header + index * 4, 4);
		if (isUtf8()) {
			at += number(pool, at, 1) & 128 ? 2 : 1; // UTF-16 length
			auto first = number(pool, at++, 1);
			auto bytes = first & 128 ? ((first & 127) << 8) | number(pool, at++, 1) : first;
			require(at <= pool.size() && bytes < pool.size() - at && pool[at + bytes] == '\0', "Invalid Android UTF-8 string");
			return Bytes(pool.substr(at, bytes));
		}
		auto first = number(pool, at, 2);
		at += 2;
		auto length = first & 0x8000 ? ((first & 0x7fff) << 16) | number(pool, at, 2) : first;
		if (first & 0x8000) at += 2;
		require(at <= pool.size() && length * 2ull + 2 <= pool.size() - at, "Invalid Android UTF-16 string");
		std::u16string chars(length, u'\0');
		for (size_t i = 0; i < length; ++i) chars[i] = static_cast<char16_t>(number(pool, at + i * 2, 2));
		return CodeCvt::utf16to8(chars);
	}
	void setText(size_t at, View value) {
		auto it = std::find(_extra.begin(), _extra.end(), value);
		auto index = _count + std::distance(_extra.begin(), it);
		if (it == _extra.end()) _extra.emplace_back(value);
		put(_input, at + 8, index, 4);
		put(_input, at + 15, 3, 1);
		put(_input, at + 16, index, 4);
	}
	void setValue(size_t at, uint8_t type, uint32_t value) {
		put(_input, at + 8, 0xffffffff, 4);
		put(_input, at + 15, type, 1);
		put(_input, at + 16, value, 4);
	}
	Bytes encode(View body) {
		Bytes offsets;
		Bytes strings = _input.substr(8 + _strings, _size - _strings);
		for (const auto& value : _extra) {
			auto chars = CodeCvt::utf8to16(value);
			require(value.size() <= 0x7fff && chars.size() <= 0x7fff, "Game metadata is too long");
			offsets += word(strings.size());
			if (isUtf8()) {
				for (auto count : {chars.size(), value.size()}) {
					if (count >= 128) strings += static_cast<char>(128 | (count >> 8));
					strings += static_cast<char>(count >= 128 ? count & 255 : count);
				}
				strings += value;
				strings += '\0';
			} else {
				strings += word(chars.size(), 2);
				for (auto c : chars) strings += word(c, 2);
				strings += word(0, 2);
			}
		}
		strings.append((4 - strings.size() % 4) % 4, '\0');
		auto result = _input.substr(0, 8 + _header + _count * 4);
		put(result, 12, _strings + offsets.size() + strings.size(), 4);
		put(result, 16, _count + _extra.size(), 4);
		put(result, 24, _flags & ~1u, 4);
		put(result, 28, _strings + offsets.size(), 4);
		result += offsets;
		result.append(_strings - _header - _count * 4, '\0');
		result += strings;
		result += body;
		put(result, 4, result.size(), 4);
		return result;
	}
	Bytes _input;
	uint32_t _header{}, _size{}, _count{}, _flags{}, _strings{};
	std::vector<std::string> _extra;
};

template <typename T, auto Free> using SSL = std::unique_ptr<T, decltype(Free)>;

struct SigningIdentity {
	SSL<EVP_PKEY, EVP_PKEY_free> key{nullptr, EVP_PKEY_free};
	SSL<X509, X509_free> cert{nullptr, X509_free};
	Bytes store;
};

template <typename T> Bytes der(T* value, int (*encode)(const T*, unsigned char**)) {
	auto size = encode(value, nullptr);
	require(size > 0, "Cannot encode APK signing identity");
	Bytes data(size, '\0');
	auto buffer = reinterpret_cast<unsigned char*>(data.data());
	require(encode(value, &buffer) == size, "Cannot encode APK signing identity");
	return data;
}

SigningIdentity identity(const rapidjson::Value& options) {
	SigningIdentity identity;
	auto secret = Bytes(text(options, "password"));
	require(!secret.empty() && secret.size() <= 1024 && secret.find('\0') == std::string::npos, "Invalid APK signing password");
	auto stored = options.FindMember("key");
	if (stored != options.MemberEnd() && !stored->value.IsNull()) {
		auto encoded = text(stored->value);
		require(encoded.size() <= 1400000, "PKCS#12 file is too large");
		auto bytes = unbase64(encoded);
		auto data = reinterpret_cast<const unsigned char*>(bytes.data());
		SSL<PKCS12, PKCS12_free> store(d2i_PKCS12(nullptr, &data, static_cast<long>(bytes.size())), PKCS12_free);
		EVP_PKEY* key = nullptr;
		X509* cert = nullptr;
		bool valid = store && data == reinterpret_cast<const unsigned char*>(bytes.data() + bytes.size())
			&& PKCS12_parse(store.get(), secret.c_str(), &key, &cert, nullptr);
		identity.key.reset(key);
		identity.cert.reset(cert);
		require(valid && key && cert && EVP_PKEY_is_a(key, "RSA") && X509_check_private_key(cert, key) == 1,
			"Could not read the RSA signing key. Check the PKCS#12 file and password.");
		return identity;
	}

	identity.key.reset(EVP_PKEY_Q_keygen(nullptr, nullptr, "RSA", size_t(3072)));
	identity.cert.reset(X509_new());
	auto cert = identity.cert.get();
	require(identity.key && cert, "Cannot create APK signing identity");
	unsigned char serial[16];
	require(RAND_bytes(serial, sizeof(serial)) == 1, "Cannot generate certificate serial");
	serial[0] = (serial[0] & 0x7f) | 1;
	SSL<BIGNUM, BN_free> serialNumber(BN_bin2bn(serial, sizeof(serial), nullptr), BN_free);
	auto name = X509_get_subject_name(cert);
	require(serialNumber && name && X509_set_version(cert, 2) == 1
		&& BN_to_ASN1_INTEGER(serialNumber.get(), X509_get_serialNumber(cert))
		&& X509_gmtime_adj(X509_getm_notBefore(cert), -86400)
		&& X509_gmtime_adj(X509_getm_notAfter(cert), 50L * 365 * 86400)
		&& X509_NAME_add_entry_by_txt(name, "CN", MBSTRING_ASC, reinterpret_cast<const unsigned char*>("Dora Game"), -1, -1, 0) == 1
		&& X509_set_issuer_name(cert, name) == 1 && X509_set_pubkey(cert, identity.key.get()) == 1
		&& X509_sign(cert, identity.key.get(), EVP_sha256()) > 0, "Cannot generate APK signing certificate");
	SSL<PKCS12, PKCS12_free> store(PKCS12_create(secret.c_str(), "game", identity.key.get(), cert, nullptr, 0, 0, 0, 0, 0), PKCS12_free);
	require(store != nullptr, "Cannot create PKCS#12 signing key");
	identity.store = base64(der(store.get(), i2d_PKCS12));
	return identity;
}

Bytes sha256(View data) {
	Bytes result(32, '\0');
	size_t size = 0;
	require(EVP_Q_digest(nullptr, "SHA256", nullptr, data.data(), data.size(), reinterpret_cast<unsigned char*>(result.data()), &size) == 1
		&& size == result.size(), "Cannot hash APK signing data");
	return result;
}

Bytes signBlock(const SigningIdentity& identity, View digest) {
	auto algorithm = word(0x0103); // RSASSA-PKCS1-v1_5 with SHA-256.
	auto signedData = field(field(algorithm + field(digest))) + field(field(der(identity.cert.get(), i2d_X509))) + field("");
	SSL<EVP_MD_CTX, EVP_MD_CTX_free> ctx(EVP_MD_CTX_new(), EVP_MD_CTX_free);
	EVP_PKEY_CTX* keyContext = nullptr;
	size_t size = 0;
	require(ctx && EVP_DigestSignInit(ctx.get(), &keyContext, EVP_sha256(), nullptr, identity.key.get()) == 1
		&& EVP_PKEY_CTX_set_rsa_padding(keyContext, RSA_PKCS1_PADDING) > 0
		&& EVP_DigestSign(ctx.get(), nullptr, &size, reinterpret_cast<const unsigned char*>(signedData.data()), signedData.size()) == 1, "Cannot sign APK");
	Bytes signature(size, '\0');
	require(EVP_DigestSign(ctx.get(), reinterpret_cast<unsigned char*>(signature.data()), &size,
		reinterpret_cast<const unsigned char*>(signedData.data()), signedData.size()) == 1, "Cannot sign APK");
	signature.resize(size);
	auto signers = field(field(field(signedData) + field(field(algorithm + field(signature))) + field(der(identity.key.get(), i2d_PUBKEY))));
	auto pair = word(signers.size() + 4, 8) + word(0x7109871a) + signers;
	auto blockSize = word(pair.size() + 24, 8);
	return blockSize + pair + blockSize + "APK Sig Block 42";
}

struct Member {
	uint16_t method;
	uint32_t crc;
	uint32_t size;
	Bytes data;
};

class ApkArchive {
public:
	explicit ApkArchive(const fs::path& output)
		: _file(open(output, "w+b")) {
		require(_file != nullptr, "Cannot create APK file");
	}
	void add(View name, const Member& member) {
		require(_names.insert(Bytes(name)).second, "Duplicate APK entry");
		require(name.size() <= 65535 && _names.size() <= 65535 && member.data.size() < MaxApk, "APK is too large");
		size_t align = member.method == Stored ? (name.ends_with(".so") ? 16384 : 4) : 1;
		auto base = _offset + 30 + name.size();
		auto extra = base % align ? 4 + (align - (base + 4) % align) % align : 0;
		require(base + extra + member.data.size() < MaxApk, "APK is too large");
		auto fields = word(20, 2) + word(0x800, 2) + word(member.method, 2) + word(0, 2) + word(33, 2)
			+ word(member.crc) + word(member.data.size()) + word(member.size) + word(name.size(), 2);
		_directory += word(0x02014b50) + word(20, 2) + fields + Bytes(12, '\0') + word(_offset) + Bytes(name);
		auto local = word(0x04034b50) + fields + word(extra, 2) + Bytes(name);
		if (extra) local += word(0xa11e, 2) + word(extra - 4, 2) + Bytes(extra - 4, '\0');
		write(local);
		write(member.data);
		_offset += local.size() + member.data.size();
	}
	void addStored(View name, Bytes bytes) {
		auto size = bytes.size();
		require(size < MaxApk, "APK entry is too large");
		auto crc = static_cast<uint32_t>(mz_crc32(0, reinterpret_cast<const unsigned char*>(bytes.data()), size));
		add(name, {Stored, crc, static_cast<uint32_t>(size), std::move(bytes)});
	}
	void finish(const SigningIdentity& identity) {
		Bytes end = word(0x06054b50) + word(0) + word(_names.size(), 2) + word(_names.size(), 2)
			+ word(_directory.size()) + word(_offset) + word(0, 2);
		require(std::fseek(_file.get(), 0, SEEK_SET) == 0, "Cannot read APK for signing");
		constexpr size_t chunkLimit = 1024 * 1024;
		Bytes chunk(5 + chunkLimit, '\0');
		chunk[0] = char(0xa5);
		Bytes summaries;
		for (size_t remaining = _offset; remaining;) {
			auto length = std::min(chunkLimit, remaining);
			require(std::fread(chunk.data() + 5, 1, length, _file.get()) == length, "Cannot read APK for signing");
			put(chunk, 1, length, 4);
			summaries += sha256(View(chunk).substr(0, 5 + length));
			remaining -= length;
		}
		for (View section : {View(_directory), View(end)}) {
			for (size_t at = 0; at < section.size(); at += chunkLimit) {
				auto part = section.substr(at, chunkLimit);
				summaries += sha256(Bytes(1, char(0xa5)) + word(part.size()) + Bytes(part));
			}
		}
		auto digest = sha256(Bytes(1, char(0x5a)) + word(summaries.size() / 32) + summaries);
		auto block = signBlock(identity, digest);
		require(_offset + block.size() + _directory.size() + end.size() < MaxApk, "APK is too large");
		put(end, 16, _offset + block.size(), 4);
		require(std::fseek(_file.get(), static_cast<long>(_offset), SEEK_SET) == 0, "Cannot append APK signature");
		write(block);
		write(_directory);
		write(end);
		require(std::fclose(_file.release()) == 0, "Cannot finish APK");
	}
private:
	void write(View data) { require(std::fwrite(data.data(), 1, data.size(), _file.get()) == data.size(), "Cannot write APK"); }
	File _file;
	size_t _offset = 0;
	Bytes _directory;
	std::unordered_set<std::string> _names;
};

class Template {
public:
	explicit Template(const fs::path& path)
		: _file(open(path, "rb")) {
		require(_file && mz_zip_reader_init_cfile(&_zip, _file.get(), 0, 0), "Invalid Dora APK template");
	}
	~Template() { mz_zip_reader_end(&_zip); }
	uint32_t count() { return mz_zip_reader_get_num_files(&_zip); }
	bool has(View name) { return mz_zip_reader_locate_file(&_zip, Bytes(name).c_str(), nullptr, MZ_ZIP_FLAG_CASE_SENSITIVE) >= 0; }
	mz_zip_archive_file_stat entry(uint32_t index) {
		mz_zip_archive_file_stat stat{};
		require(mz_zip_reader_file_stat(&_zip, index, &stat), "Invalid APK template entry");
		return stat;
	}
	Bytes read(const mz_zip_archive_file_stat& entry, size_t limit, bool compressed = false) {
		auto size = compressed ? entry.m_comp_size : entry.m_uncomp_size;
		require(size <= limit && entry.m_is_supported && !entry.m_is_encrypted, "Invalid APK template entry");
		Bytes data(size, '\0');
		require(mz_zip_reader_extract_to_mem(&_zip, entry.m_file_index, data.data(), data.size(), compressed ? MZ_ZIP_FLAG_COMPRESSED_DATA : 0),
			"Cannot read APK template entry");
		return data;
	}
private:
	File _file;
	mz_zip_archive _zip{};
};

bool safeEntry(View name) {
	if (name.empty() || name.starts_with('/') || name.find_first_of("\\:") != View::npos) return false;
	for (size_t at = 0; at <= name.size();) {
		auto end = name.find('/', at);
		auto part = name.substr(at, end == View::npos ? end : end - at);
		if (part.empty() || part == "." || part == "..") return false;
		if (end == View::npos) break;
		at = end + 1;
	}
	return true;
}

bool excluded(const rapidjson::Value& policy, View name) {
	auto matches = [&](const char* key, auto check) {
		const auto& list = member(policy, key);
		require(list.IsArray(), "Invalid Android export policy");
		for (const auto& entry : list.GetArray()) if (check(text(entry))) return true;
		return false;
	};
	if (matches("excludedPaths", [&](View entry) { return name == entry; })
		|| matches("excludedDirectories", [&](View entry) { return name.starts_with(entry); })) return true;
	if (name.starts_with("lib/") && matches("excludedLibraries", [&](View entry) { return name.ends_with("/" + Bytes(entry)); })) return true;
	if (!name.starts_with("META-INF/")) return false;
	auto file = Bytes(name.substr(9));
	if (file.find('/') != Bytes::npos) return false;
	for (auto& ch : file) if (ch >= 'A' && ch <= 'Z') ch += 'a' - 'A';
	return matches("signatureNames", [&](View entry) { return file == entry; })
		|| matches("signaturePrefixes", [&](View entry) { return file.starts_with(entry); })
		|| matches("signatureSuffixes", [&](View entry) { return file.ends_with(entry); });
}
}

std::string buildAndroid(const rapidjson::Value& options) {
	const auto& game = member(options, "game");
	auto package = text(game, "packageName");
	auto title = text(game, "title");
	auto version = text(game, "versionName");
	const auto& code = member(game, "versionCode");
	static const std::regex packageSyntax("[A-Za-z][A-Za-z0-9_]*(\\.[A-Za-z][A-Za-z0-9_]*)+");
	require(package.size() <= 200 && std::regex_match(package.begin(), package.end(), packageSyntax)
		&& title.find_first_not_of(" \t\r\n") != View::npos && version.find_first_not_of(" \t\r\n") != View::npos
		&& title.size() <= 0x7fff && version.size() <= 0x7fff
		&& code.IsInt() && code.GetInt() > 0, "Invalid Android game metadata");
	auto contents = path(options, "assets");
	require(fs::is_regular_file(contents / "Script" / "init.lua") && fs::is_directory(contents / "Game"), "Missing Android game startup script");
	rapidjson::Document rules;
	auto policyJson = text(options, "policy");
	rules.Parse(policyJson.data(), policyJson.size());
	auto& policy = member(rules, "androidTemplate");
	auto godot = member(options, "needsGodot").IsTrue();
	Template input(path(options, "template"));
	require(input.has("AndroidManifest.xml") && input.has("classes.dex") && input.has("resources.arsc"), "Invalid Dora APK template");
	auto signer = identity(options);
	ApkArchive output(path(options, "output"));
	bool foundRuntime = false;
	for (uint32_t index = 0; index < input.count(); ++index) {
		auto entry = input.entry(index);
		if (entry.m_is_directory) continue;
		View name(entry.m_filename);
		require(safeEntry(name) && (entry.m_method == Stored || entry.m_method == Deflated)
			&& entry.m_uncomp_size < MaxApk, "Unsupported APK template entry");
		if (name.starts_with("lib/") && name.ends_with("/libmain.so")) {
			foundRuntime = true;
			require(!godot || input.has(Bytes(name.substr(0, name.size() - 10)) + "libgodot_android.so"), "The Dora APK template is missing Godot");
		}
		if (excluded(policy, name) || (!godot && name.starts_with("lib/") && name.ends_with("/libgodot_android.so"))) continue;
		if (name == "AndroidManifest.xml") {
			output.addStored(name, Manifest(input.read(entry, 2 * 1024 * 1024)).rewrite(package, title, version, code.GetInt()));
		} else {
			output.add(name, {entry.m_method, entry.m_crc32, static_cast<uint32_t>(entry.m_uncomp_size), input.read(entry, MaxApk - 1, true)});
		}
	}
	require(foundRuntime, "The Dora APK is missing native libraries");
	for (const auto& item : fs::recursive_directory_iterator(contents)) {
		require(!item.is_symlink(), "Symbolic links are not supported in game exports");
		if (!item.is_regular_file()) continue;
		auto name = utf8(item.path().lexically_relative(contents));
		require(safeEntry(name), "Invalid game file path");
		// Reuse miniz's raw deflate when it saves space; keep PNG and other
		// precompressed assets unchanged.
		auto bytes = read(item.path(), MaxApk - 1);
		auto crc = static_cast<uint32_t>(mz_crc32(0, reinterpret_cast<const unsigned char*>(bytes.data()), bytes.size()));
		size_t compressedSize = 0;
		auto compressed = std::unique_ptr<void, decltype(&mz_free)>(tdefl_compress_mem_to_heap(bytes.data(), bytes.size(), &compressedSize, 128), mz_free);
		if (compressed && compressedSize < bytes.size()) {
			output.add("assets/" + name, {Deflated, crc, static_cast<uint32_t>(bytes.size()), Bytes(static_cast<const char*>(compressed.get()), compressedSize)});
		} else {
			output.add("assets/" + name, {Stored, crc, static_cast<uint32_t>(bytes.size()), std::move(bytes)});
		}
	}
	output.finish(signer);
	return signer.store;
}
}
#endif
