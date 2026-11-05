"""Validate the completed per-input NIR distribution notice review."""
import hashlib
import json

def verify_review(review, provenance, require_hash=True):
    if not isinstance(review, dict) or review.get('schema') != 1 or review.get('inheritance_review_complete') is not True:
        raise ValueError('NIR license review is incomplete')
    if review.get('godot_nir_tag') != provenance.get('godot_nir_tag') or review.get('mesa_commit') != provenance.get('mesa_commit'):
        raise ValueError('NIR license review version mismatch')
    expected_hash=provenance.get('license_review_sha256')
    if require_hash and (not isinstance(expected_hash,str) or len(expected_hash)!=64):
        raise ValueError('NIR license review digest missing')
    if expected_hash and hashlib.sha256((json.dumps(review,ensure_ascii=False,indent=2)+'\n').encode()).hexdigest()!=expected_hash:
        raise ValueError('NIR license review integrity mismatch')
    expected=set(provenance.get('files_without_notice_blocks', []))
    inventory={r['path']:r['sha256'] for r in provenance['files']}
    rows=review.get('files', [])
    if len(rows)!=len(expected) or {r['path'] for r in rows}!=expected:
        raise ValueError('NIR license review coverage mismatch')
    for row in rows:
        if row.get('reviewed') is not True or row.get('sha256')!=inventory[row['path']] or not row.get('basis') or not row.get('evidence') or row.get('license') not in ['MIT','Apache-2.0','metadata','build-input-only']:
            raise ValueError('NIR license review entry is invalid: '+row['path'])
    return True
