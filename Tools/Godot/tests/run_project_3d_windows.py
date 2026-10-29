#!/usr/bin/env python3
"""Ordinary Windows WGL glTF/3D project runner; shares strict native acceptance."""
import sys
from run_project_3d_native import main
if __name__=="__main__":
    assert sys.platform=='win32'
    main()
