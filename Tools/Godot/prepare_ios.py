#!/usr/bin/env python3
"""Compatibility entrypoint: validate the vendored iOS integration."""
from pathlib import Path
import sys

from vendor_source import verify_ios

verify_ios(Path(sys.argv[1]))
print("Vendored Godot iOS integration: PASS")
