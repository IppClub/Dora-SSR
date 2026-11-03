"""Name native xmake object targets for upstream same-source compile variants."""
from pathlib import PurePosixPath


def variant_target(source: str, flags: tuple[str, ...]) -> str:
    definitions = {}
    for flag in flags:
        if flag.startswith('-D'):
            name, _, value = flag[2:].partition('=')
            definitions[name] = value
    if source.startswith('thirdparty/pcre2/'):
        width = definitions.get('PCRE2_CODE_UNIT_WIDTH')
        if width in ('16', '32'):
            return 'godot-pcre2-' + width
    if source.startswith('thirdparty/libjpeg-turbo/'):
        width = definitions.get('BITS_IN_JSAMPLE')
        if width in ('8', '12'):
            return 'godot-jpeg-' + width
    raise ValueError('Unregistered same-source variant: ' + str(PurePosixPath(source)))


def manifest_actions(text: str):
    """Read the generated manifest's target/source/flags records for auditing."""
    import re
    for block in re.finditer(r'target\("([^\"]+)"\)\n    add_files\(\n(.*?)    \)\ntarget_end\(\)', text, re.S):
        target, body = block.groups()
        flags = tuple(re.findall(r'flag\("([^\"]+)"\)', body))
        for source in re.findall(r'source\("([^\"]+)"\)', body):
            yield target, source, flags


def validate_native_variants(text: str) -> int:
    from collections import Counter
    actions = list(manifest_actions(text))
    identities = [(target, source) for target, source, _ in actions]
    if len(identities) != len(set(identities)):
        raise ValueError('Duplicate source/configuration within one xmake target')
    counts = Counter()
    for target, source, flags in actions:
        if target.startswith(('godot-pcre2-', 'godot-jpeg-')):
            if target != variant_target(source, flags):
                raise ValueError('Native variant target and compile macros differ')
            counts[target] += 1
    expected = {'godot-pcre2-16': 31, 'godot-pcre2-32': 31,
                'godot-jpeg-8': 24, 'godot-jpeg-12': 24}
    if dict(counts) != expected:
        raise ValueError('Incomplete codec variant compilation inventory: ' + str(counts))
    return sum(counts.values())
