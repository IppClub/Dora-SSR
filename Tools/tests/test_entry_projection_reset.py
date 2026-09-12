"""Regression test for entry transitions; requires Dora at localhost:8866."""

import json
from pathlib import Path
import tempfile
import urllib.request


def post(route, body):
    request = urllib.request.Request(
        "http://127.0.0.1:8866/" + route,
        json.dumps(body).encode(),
        {"Content-Type": "application/json"},
    )
    # The local engine must not be routed through an environment proxy.
    opener = urllib.request.build_opener(urllib.request.ProxyHandler({}))
    with opener.open(request, timeout=20) as response:
        result = json.load(response)
    assert result.get("success"), result
    return result


def run(project):
    post("run", {"file": str(project / "init.lua"), "asProj": True,
                 "projectRoot": str(project)})


def main():
    with tempfile.TemporaryDirectory(prefix="dora-projection-test-") as folder:
        root = Path(folder)
        changed = root / "changed"
        probe = root / "probe"
        changed.mkdir()
        probe.mkdir()
        (changed / "init.lua").write_text(
            'local View = require("Dora").View\n'
            'View.nearPlaneDistance = 5\n'
            'View.farPlaneDistance = 150\n'
            'View.fieldOfView = 48\n'
        )
        (probe / "init.lua").write_text(
            'local View = require("Dora").View\n'
            'assert(math.abs(View.nearPlaneDistance - 0.1) < 0.00001)\n'
            'assert(View.farPlaneDistance == 10000)\n'
            'assert(View.fieldOfView == 45)\n'
            'local distance = View.size.height / 2 / math.tan(math.rad(45) / 2)\n'
            'assert(distance < View.farPlaneDistance)\n'
        )
        try:
            for stop_first in (True, False, True):
                run(changed)
                if stop_first:
                    post("stop", {})
                run(probe)
        finally:
            post("stop", {})
    print("PASS: stop/run and direct entry switches restore the 2D projection")


if __name__ == "__main__":
    main()
