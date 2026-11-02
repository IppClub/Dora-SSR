#!/usr/bin/env python3
"""Compatibility entrypoint: validate the vendored Web integration."""
from pathlib import Path
import sys

from vendor_source import verify_web

verify_web(Path(sys.argv[1]))
print("Vendored Godot Web integration: PASS")
