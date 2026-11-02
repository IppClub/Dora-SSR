#!/usr/bin/env python3
"""Compatibility entrypoint: validate the vendored Android integration."""
from pathlib import Path
import sys

from vendor_source import verify_android

verify_android(Path(sys.argv[1]))
print("Vendored Godot Android integration: PASS")
