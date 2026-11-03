# Fixed Godot source and Dora delta

`Source/3rdParty/Godot/UPSTREAM.json` describes the original upstream import.
[SOURCE_DELTA.json](SOURCE_DELTA.json) records the current registered Dora delta,
not a new upstream version or an approval of runtime behavior.

The [read-only auditor](https://github.com/IppClub/Dora-Example/blob/master/Test/Godot/audit_vendor_provenance.py) verifies the fixed archive
against the fixed upstream Git tree and Dora's initial import commit, then checks
all current registered/non-ignored source against the declared delta. It also
emits and reconstructs the entire Dora patch in a temporary directory with zero
fuzz and zero offset. No upstream code, generator, or build is executed.

```sh
python3 $DORA_TEST_REPO/Test/Godot/audit_vendor_provenance.py \
  --archive /path/to/godot-4.6-stable.tar.gz \
  --upstream-git /path/to/cached-upstream.git \
  --output /path/to/fresh-audit
python3 $DORA_TEST_REPO/Test/Godot/test_vendor_provenance.py \
  --archive /path/to/godot-4.6-stable.tar.gz \
  --upstream-git /path/to/cached-upstream.git \
  --output /path/to/fresh-controls
```

The repository must contain the initial import commit, and the cached upstream
Git repository must contain the fixed upstream tree. Git must support
`check-attr --source`. Lazy fetching is disabled; the auditor does not download
objects, change refs, or write the index. This optional audit is separate from
the fast marker/header checks in `vendor_source.py`; normal builds do not acquire
a new archive or Git-history dependency.

Canonicalization only follows text/EOL attributes from the fixed import. The
25 Windows/Mono files archived with CRLF map to the fixed Git LF blobs. Binary
and explicitly non-text files are not normalized. Paths, content and executable
bits remain checked. Unknown edits/additions, missing source or notices,
symlinks, unsafe paths and undeclared executable changes are rejected. Ignored
SCons caches and generated/build artifacts are outside this source inventory;
the audit does not establish that the raw directory is artifact-free.

After an authorized Dora source change, generate a proposal with the same
command plus `--propose` into a fresh directory. Inspect `proposal.json` and
`delta.patch`, update `SOURCE_DELTA.json` to the reviewed proposal, and rerun the
normal audit. Proposal mode produces no passed verification report. The current
registry keeps 47 modified and 44 added files (including import metadata), with
no removed upstream files. Source/patch correctness, licenses of external SDKs,
ABI, actual builds and runtime acceptance remain separate checks.

The zlib suffix `1.3.1.2-audit` is present in the [fixed upstream source](https://raw.githubusercontent.com/godotengine/godot/89cea143987d564363e15d207438530651d943ac/thirdparty/zlib/zlib.h).
It is not an unregistered Dora edit. All current vendored `thirdparty/` source
has the same canonical content and modes as that fixed Godot tree.
