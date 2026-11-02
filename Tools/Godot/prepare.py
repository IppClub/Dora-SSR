#!/usr/bin/env python3
"""Compatibility entrypoint: validate the vendored common Dora bridge."""
from pathlib import Path
import sys

from vendor_source import verify_common

verify_common(Path(sys.argv[1]))
print("Vendored Godot common bridge: PASS")
