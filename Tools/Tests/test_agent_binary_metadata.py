#!/usr/bin/env python3
"""Build/run authored TS metadata tests in Dora. Requires a running matching engine, Pillow and ffmpeg."""
import argparse
import json
import os
from pathlib import Path
import shutil
import struct
import subprocess
import tempfile
import wave
import zipfile
from PIL import Image

ROOT = Path(__file__).resolve().parents[2]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("executable", type=Path)
    args = parser.parse_args()
    executable = str(args.executable.resolve())
    env = {k: v for k, v in os.environ.items() if k.lower() not in {"http_proxy", "https_proxy", "all_proxy", "no_proxy"}}
    source = Path(__file__).with_name("AgentBinaryMetadataTests.ts")
    agent_root = ROOT / "Assets/Script/Lib/Agent"
    with tempfile.TemporaryDirectory(prefix="MetadataTests", dir=agent_root) as build_directory:
        staged = Path(build_directory) / source.name
        shutil.copyfile(source, staged)
        subprocess.run([executable, "cli", "build", "--lang", "ts", "-f", str(staged), "-p",
                        str(agent_root), "--timeout", "180"], check=True, env=env)
        compiled = staged.with_suffix(".lua").read_bytes()
    with tempfile.TemporaryDirectory(prefix="dora-binary-metadata-") as directory:
        root = Path(directory) / "project"
        root.mkdir()
        (root / "AgentBinaryMetadataTests.lua").write_bytes(compiled)
        image = Image.new("RGB", (17, 11), (20, 80, 160))
        cases = []
        def case(path, expected=None, absent=None):
            cases.append({"path": path, **({"expected": expected} if expected is not None else {}), **({"absent": absent} if absent else {})})
        for extension, fmt in [("png", "png"), ("jpg", "jpeg"), ("gif", "gif"), ("bmp", "bmp"), ("webp", "webp")]:
            name = f"image.{extension}"
            image.save(root / name)
            case(name, {"kind": "image", "format": fmt, "width": 17, "height": 11})
        image.save(root / "lossless.webp", lossless=True)
        case("lossless.webp", {"format": "webp", "width": 17, "height": 11})
        image.save(root / "progressive.jpg", progressive=True)
        case("progressive.jpg", {"format": "jpeg", "width": 17, "height": 11})
        with wave.open(str(root / "tone.wav"), "wb") as stream:
            stream.setparams((2, 2, 44100, 44100, "NONE", "not compressed"))
            stream.writeframes(b"\0" * 44100 * 4)
        case("tone.wav", {"kind": "audio", "format": "wav", "codec": "pcm", "channels": 2, "sampleRate": 44100, "bitsPerSample": 16, "durationSeconds": 1})
        for extension, codec in [("flac", "flac"), ("ogg", "vorbis"), ("opus", "libopus")]:
            subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-i", str(root / "tone.wav"), "-c:a", codec, "-strict", "-2", str(root / f"tone.{extension}")], check=True)
            # Encoders may pad the input; compare with the actual container duration.
            probe = json.loads(subprocess.check_output(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "json", str(root / f"tone.{extension}")], text=True))
            duration = float(probe["format"]["duration"])
            if extension == "opus":
                # ffprobe container duration includes Opus pre-skip. Compare the
                # presentation duration with decoded PCM instead.
                pcm = subprocess.check_output(["ffmpeg", "-nostdin", "-v", "error", "-i", str(root / "tone.opus"), "-f", "s16le", "-ac", "2", "-ar", "48000", "-"])
                duration = len(pcm) / (2 * 2 * 48000)
            case(f"tone.{extension}", {"kind": "audio", "format": "flac" if extension == "flac" else "ogg", "codec": {"flac": "flac", "ogg": "vorbis", "opus": "opus"}[extension], "channels": 2, "sampleRate": 48000 if extension == "opus" else 44100, "durationSeconds": duration})
        wav = (root / "tone.wav").read_bytes()
        junk = b"JUNK" + struct.pack("<I", 5) + b"a\0b\0c\0"
        (root / "junk.wav").write_bytes(b"RIFF" + struct.pack("<I", len(wav) - 8 + len(junk)) + wav[8:12] + junk + wav[12:])
        case("junk.wav", {"format": "wav", "durationSeconds": 1})
        doc = json.dumps({"asset": {"version": "2.0"}, "meshes": [{"primitives": []}, {"primitives": []}], "materials": [{}], "animations": [], "extras": {"secret": "DO_NOT_RETURN_BINARY_PAYLOAD"}}).encode()
        doc += b" " * (-len(doc) % 4)
        (root / "model.glb").write_bytes(b"glTF" + struct.pack("<IIII", 2, 20 + len(doc), len(doc), 0x4E4F534A) + doc)
        case("model.glb", {"kind": "model", "format": "glb", "version": 2, "meshCount": 2, "materialCount": 1, "animationCount": 0})
        shutil.copyfile(root / "image.png", root / "wrong-extension.bin")
        case("wrong-extension.bin", {"format": "png", "width": 17, "height": 11})
        (root / "unknown.bin").write_bytes(b"\0DO_NOT_RETURN_BINARY_PAYLOAD\xff" * 100)
        case("unknown.bin")
        (root / "truncated.png").write_bytes((root / "image.png").read_bytes()[:20])
        case("truncated.png")
        broken = bytearray(wav)
        broken[40:44] = struct.pack("<I", 0x7FFFFFFF)
        (root / "broken.wav").write_bytes(broken)
        case("broken.wav")
        # Valid-looking headers beyond the probe budget must not trigger unbounded reads.
        jpeg = (root / "image.jpg").read_bytes()
        (root / "late-header.jpg").write_bytes(jpeg[:2] + b"\xff\xe1\xff\xff" + b"\0" * 65533 + jpeg[2:])
        case("late-header.jpg")
        with (root / "large.png").open("wb") as stream:
            stream.write((root / "image.png").read_bytes())
            stream.truncate(8 * 1024**3)
        case("large.png", {"format": "png", "width": 17, "height": 11})
        with (root / "large.ogg").open("wb") as stream:
            stream.write((root / "tone.ogg").read_bytes())
            stream.truncate(17 * 1024**2)
        case("large.ogg", {"format": "ogg", "codec": "vorbis", "sampleRate": 44100}, ["durationSeconds"])
        ogg = bytearray((root / "tone.ogg").read_bytes())
        last = ogg.rfind(b"OggS")
        ogg[last + 14:last + 18] = struct.pack("<I", (struct.unpack_from("<I", ogg, 14)[0] + 1) % 2**32)
        (root / "other-stream.ogg").write_bytes(ogg)
        case("other-stream.ogg", {"format": "ogg", "codec": "vorbis"}, ["durationSeconds"])
        with zipfile.ZipFile(root / "packed.zip", "w", compression=zipfile.ZIP_DEFLATED) as archive:
            for name in ["image.png", "tone.ogg", "tone.wav"]:
                archive.write(root / name, name)
        case("packed.zip/image.png", {"format": "png", "width": 17, "height": 11})
        case("packed.zip/tone.ogg", {"format": "ogg", "codec": "vorbis", "durationSeconds": next(c["expected"]["durationSeconds"] for c in cases if c["path"] == "tone.ogg")})
        case("packed.zip/tone.wav", {"format": "wav", "durationSeconds": 1})
        (root / "plain.txt").write_text("first line\nsecond line\nthird line\n")
        (root.parent / "outside.png").write_bytes((root / "image.png").read_bytes())
        (root / "cases.json").write_text(json.dumps(cases))
        request = root / "request.json"
        request.write_text(json.dumps({"mode": "lua", "code": '''local result, failure
requireProjectModule("AgentBinaryMetadataTests").runTests(projectDir):addCallbacks(function(_, value) result = value end, function(_, err) failure = tostring(err) end)
wait(function() return result ~= nil or failure ~= nil end)
assert(not failure, failure)
assert(result:match("^passed"), result)
print(result)''', "timeoutSeconds": 60}))
        completed = subprocess.run([executable, "cli", "agent", "command", "-p", str(root), "--input", str(request)], capture_output=True, text=True, env=env)
        assert completed.returncode == 0, completed.stdout + completed.stderr
        result = json.loads(completed.stdout)
        assert result["success"] and result["output"].startswith("passed"), result
        print(result["output"])


if __name__ == "__main__":
    main()
