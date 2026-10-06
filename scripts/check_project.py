#!/usr/bin/env python3
"""Check project wiring on Linux. This does not compile or type-check Swift."""
import hashlib
import json
import re
from pathlib import Path
from xml.etree import ElementTree

root = Path(__file__).resolve().parents[1]
project = (root / "NoPlexFocus.xcodeproj/project.pbxproj").read_text()
ids = re.findall(r"^([A-F0-9]{24}) =", project, re.MULTILINE)
assert len(ids) == len(set(ids)), "Duplicate project object IDs"
references = set(re.findall(r"\b[A-F0-9]{24}\b", project))
assert references == set(ids), "Unresolved project object references"
paths = re.findall(r'path = "([^"\n]+\.swift)";', project)
expected = {str(p.relative_to(root)) for directory in ("NoPlexFocus", "NoPlexFocusTests")
            for p in (root / directory).rglob("*.swift")}
assert set(paths) == expected, "Swift source file references differ from disk"
for path in paths:
    file_match = re.search(r'^([A-F0-9]{24}) = \{ isa = PBXFileReference;[^\n]*path = "' + re.escape(path) + r'";', project, re.MULTILINE)
    assert file_match, f"Missing file reference: {path}"
    build_match = re.search(r'^([A-F0-9]{24}) = \{ isa = PBXBuildFile; fileRef = ' + file_match[1] + ';', project, re.MULTILINE)
    assert build_match, f"Missing build reference: {path}"
    phase = "test-sources" if path.startswith("NoPlexFocusTests/") else "app-sources"
    # Verify the correct target sources phase, not just the object table.
    phase_id = hashlib.sha1(phase.encode()).hexdigest()[:24].upper()
    assert re.search(r'^' + phase_id + r' = \{ isa = PBXSourcesBuildPhase;[^\n]*files = \([^\n]*' + build_match[1], project, re.MULTILINE), f"Missing source phase entry: {path} ({phase})"
for asset in (root / "NoPlexFocus/Assets.xcassets").rglob("*.json"):
    json.loads(asset.read_text())
scheme = ElementTree.parse(root / "NoPlexFocus.xcodeproj/xcshareddata/xcschemes/NoPlexFocus.xcscheme")
for reference in scheme.iter("BuildableReference"):
    assert reference.attrib["BlueprintIdentifier"] in ids, "Unknown scheme target"
assert len(list(scheme.iter("TestableReference"))) == 1, "Test target missing from scheme"
assert 'IPHONEOS_DEPLOYMENT_TARGET = 17.0' in project
print(f"Project wiring OK: {len(paths)} Swift files, asset JSON, shared build/test scheme.")
print("Swift compilation and XCTest execution require Xcode on macOS; neither ran here.")
