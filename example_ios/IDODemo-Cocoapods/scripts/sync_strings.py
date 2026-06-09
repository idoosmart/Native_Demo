#!/usr/bin/env python3
"""
Sync Localizable.xcstrings with L10n.swift

This script reads all keys from Localizable.xcstrings and generates
corresponding L10n.swift code with proper categorization.

Usage:
    python3 scripts/sync_strings.py
"""

import json
import re
import sys
from pathlib import Path
from typing import Dict, List, Tuple, Set

# Configuration
XCSTRINGS_PATH = Path("IDODemo/Resources/Localizable.xcstrings")
L10N_SWIFT_PATH = Path("IDODemo/Common/L10n.swift")

# Key patterns for categorization
CATEGORY_PATTERNS = [
    # (pattern, category_name, priority)
    (r"^refresh$|^exit_app$|^cancel$|^supported$|^unsupported$", "Common", 0),
    (r"^epo_", "EPO", 10),
    (r"^nonsupport$|^fastconfig_|^on_fastconfig$|^need_ignore_pair$|^ble_off$|^gps_tips$", "Bluetooth", 20),
    (r"^system_notify|^main_switch$|^call_remind$|^fetch_fail$", "System", 30),
    (r"^notify_", "Notification", 40),
    (r"^get[A-Z]", "Get Operations", 50),
    (r"^set[A-Z]|^photo|^findDevice|^factoryReset$|^reboot$|^musicControl$|^noticeMessageV3$", "Set Operations", 60),
    (r"^(walk|run|ride|hike|swim|fitness|yoga|basketball|football|tennis|golf|skiing|boxing|treadmill|outdoor|indoor|pool|open water|high-intensity|cricket|free training|functional|core|traditional|pull ups|jumping|squats|high knees|barbell|martial|tai chi|taekwondo|karate|kickboxing|fencing|archery|gymnastics|horizontal|parallel|walking|climbing|bowling|billiards|hockey|rugby|squash|softball|handball|shuttlecock|beach|sepak|dodgeball|hip-hop|ballet|social|frisbee|darts|horseback|stair|kite|fishing|sled|snow|alpine|cross-country|curling|ice|biathlon|surfing|sailing|windsurfing|kayak|motorboat|rowing|dragon|water|rafting|skateboarding|rock|bungee|parkour|bmx|outdoor Fun|other activity|Track|Cross country|mountain|badminton|spinning|elliptical|sit-ups|push-ups|dumbbells|weight|calisthenics|rope|table|volleyball|baseball|roller|dancing|indoor|pilates|cross|aerobics|zumba|square|plank|gym)$", "Sports Types", 70),
    (r"^(overallResponseTime|distance|elevation|pace|speed|heartRate|power|cadence|runningEconomy|runningFitness|time|other)$", "Metrics Categories", 80),
    (r"^(Overall|Total|Current|Last|Lap|Average|Maximum|Vertical|Heart Rate|Power|Cadence|Stride|Training|Aerobic|Anaerobic|Calorie|Activity|Vo2max|Battery|Grade|Effort)", "Metric Names", 90),
]

# Keys that need special Swift variable names (to avoid conflicts with reserved words or duplicates)
SPECIAL_VARIABLE_NAMES = {
    "3s Average Power": "_3sAveragePower",
    "10s Average Power": "_10sAveragePower",
    "other": "otherSport",  # Duplicate key handling
}

# Keys that start with numbers need underscore prefix
NUMBER_PREFIX_KEYS = ["3s Average Power", "10s Average Power"]

# Swift reserved words that cannot be used as identifiers
SWIFT_RESERVED_WORDS = {
    'associatedtype', 'class', 'deinit', 'enum', 'extension', 'fileprivate', 'func', 'import', 'init',
    'inout', 'internal', 'let', 'open', 'operator', 'private', 'protocol', 'public', 'rethrows',
    'static', 'struct', 'subscript', 'typealias', 'var', 'break', 'case', 'continue', 'default',
    'defer', 'do', 'else', 'fallthrough', 'for', 'guard', 'if', 'in', 'repeat', 'return', 'switch',
    'where', 'while', 'as', 'Any', 'catch', 'false', 'is', 'nil', 'super', 'self', 'Self', 'throw',
    'throws', 'true', 'try', '_', '#available', '#colorLiteral', '#column', '#else', '#elseif',
    '#endif', '#file', '#fileLiteral', '#function', '#if', '#imageLiteral', '#line', '#selector',
    '#sourceLocation', '#warning', '#error'
}


def is_valid_swift_identifier(key: str) -> bool:
    """Check if the key can be converted to a valid Swift identifier.

    Accepts patterns that can be converted to valid Swift variable names:
    - camelCase: getDeviceInfo, exitApp
    - snake_case: get_device_info, exit_app
    - PascalCase: GetDeviceInfo, ExitApp
    - lowercase: refresh, cancel
    - With spaces (will be converted): "Heart Rate" -> heartRate
    - With hyphens (will be converted): "push-ups" -> pushUps

    Rejected patterns:
    - Starts with number: 3s Average Power
    - Empty string
    - Swift reserved words
    - Contains only special characters
    """
    if not key or not key.strip():
        return False

    # Get the variable name that would be generated
    var_name = to_camel_case(key)

    # Check if it's empty after conversion
    if not var_name:
        return False

    # Check if it starts with a number (invalid Swift identifier)
    if var_name[0].isdigit():
        return False

    # Check if it's a Swift reserved word
    if var_name in SWIFT_RESERVED_WORDS:
        return False

    # Check if the variable name is valid Swift identifier format
    # Must start with letter or underscore
    if not (var_name[0].isalpha() or var_name[0] == '_'):
        return False

    # Rest must be alphanumeric or underscore
    if not all(c.isalnum() or c == '_' for c in var_name):
        return False

    return True


def to_camel_case(key: str) -> str:
    """Convert a key to camelCase Swift variable name.

    Examples:
        "getDeviceInfo" -> "getDeviceInfo" (already camelCase)
        "exit_app" -> "exitApp"
        "3s Average Power" -> "_3sAveragePower"
        "Heart Rate" -> "heartRate"
    """
    # Check for special names first
    if key in SPECIAL_VARIABLE_NAMES:
        return SPECIAL_VARIABLE_NAMES[key]

    # Handle keys starting with numbers
    prefix = ""
    clean_key = key
    if key and key[0].isdigit():
        prefix = "_"
        clean_key = key

    # If key is already camelCase (contains uppercase after first char), preserve it
    if len(clean_key) > 1 and any(c.isupper() for c in clean_key[1:]):
        # Check if it follows camelCase pattern (no spaces, no underscores)
        if ' ' not in clean_key and '_' not in clean_key:
            return prefix + clean_key[0].lower() + clean_key[1:]

    # Convert snake_case or other formats to camelCase
    # Handle keys with spaces, underscores, hyphens, etc.
    words = re.split(r'[\s\-_]+', clean_key)

    # First word lowercase, rest capitalized
    if not words:
        return prefix

    result = words[0].lower()
    for word in words[1:]:
        if word:
            result += word.capitalize()

    return prefix + result


def categorize_key(key: str) -> Tuple[str, int]:
    """Categorize a key and return (category_name, priority)."""
    for pattern, category, priority in CATEGORY_PATTERNS:
        if re.search(pattern, key, re.IGNORECASE):
            return category, priority
    return "Other", 100


def parse_xcstrings(path: Path) -> Tuple[Dict[str, str], List[Tuple[str, str]]]:
    """Parse xcstrings file and return (valid_keys_dict, ignored_keys_list).

    Returns:
        Tuple of (valid keys dict, list of ignored (key, reason) tuples)
    """
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    valid_keys = {}
    ignored_keys = []

    for key, entry in data.get("strings", {}).items():
        # Get English value as comment
        en_value = ""
        localizations = entry.get("localizations", {})
        if "en" in localizations:
            en_value = localizations["en"].get("stringUnit", {}).get("value", "")

        # Check if key follows Swift naming conventions
        if is_valid_swift_identifier(key):
            valid_keys[key] = en_value
        else:
            reason = ""
            var_name = to_camel_case(key)
            if not key or not key.strip():
                reason = "empty key"
            elif key and key[0].isdigit():
                reason = "starts with number"
            elif var_name in SWIFT_RESERVED_WORDS:
                reason = f"Swift reserved word '{var_name}'"
            elif var_name and not (var_name[0].isalpha() or var_name[0] == '_'):
                reason = "starts with invalid character"
            elif var_name and not all(c.isalnum() or c == '_' for c in var_name):
                reason = "contains invalid characters"
            else:
                reason = "invalid format"
            ignored_keys.append((key, reason, en_value))

    return valid_keys, ignored_keys


def generate_l10n_swift(keys: Dict[str, str]) -> str:
    """Generate L10n.swift content."""

    # Track used variable names to avoid duplicates
    used_var_names: Dict[str, str] = {}  # var_name -> original_key

    # Group keys by category
    categories: Dict[str, List[Tuple[str, str, int, str]]] = {}
    for key, value in keys.items():
        category, priority = categorize_key(key)
        if category not in categories:
            categories[category] = []

        var_name = to_camel_case(key)

        # Handle duplicate variable names
        if var_name in used_var_names:
            # Add suffix to make it unique
            original_key = used_var_names[var_name]
            # Determine which one should get the suffix based on key patterns
            # Prefer the one with more specific/clearer key
            if len(key) > len(original_key):
                # Current key is more specific, keep var_name for it
                # Rename the previous one
                categories[category] = [
                    (k, v, p, f"{to_camel_case(k)}Full" if to_camel_case(k) == var_name else to_camel_case(k))
                    for k, v, p, _ in categories[category]
                ]
                used_var_names[var_name] = key
            else:
                # Use suffix for current key
                var_name = f"{var_name}Full"
        else:
            used_var_names[var_name] = key

        categories[category].append((key, value, priority, var_name))

    # Sort categories by priority
    sorted_categories = sorted(categories.items(), key=lambda x: min(item[2] for item in x[1]))

    # Generate code
    lines = [
        "import Foundation",
        "",
        "// MARK: - Strings",
        "",
        "// This file is auto-generated by scripts/sync_strings.py",
        "// Do not edit manually. Run `python3 scripts/sync_strings.py` to regenerate.",
        "",
        "enum L10n {",
    ]

    for category, items in sorted_categories:
        # Sort items by key
        sorted_items = sorted(items, key=lambda x: x[0])

        lines.append("")
        lines.append(f"    // MARK: - {category}")

        for key, value, _, var_name in sorted_items:

            # Escape special characters in the key for Swift string
            swift_key = key.replace('\\', '\\\\').replace('"', '\\"')

            # Add comment with English value if available
            if value:
                # Escape comment for Swift
                comment = value.replace('*/', '* /')
                lines.append(f'    /// {comment}')

            lines.append(f'    static var {var_name}: String {{ String(localized: "{swift_key}") }}')

    lines.append("}")
    lines.append("")
    lines.append("// MARK: - String Extension")
    lines.append("")
    lines.append("extension String {")
    lines.append("    /// Localizes the string using the current locale.")
    lines.append("    /// The string itself is used as the localization key.")
    lines.append("    /// Compatible with iOS 15+")
    lines.append("    var i18n: String {")
    lines.append("        Bundle.main.localizedString(forKey: self, value: nil, table: nil)")
    lines.append("    }")
    lines.append("}")
    lines.append("")

    return "\n".join(lines)


def main():
    """Main entry point."""
    print("🔄 Syncing Localizable.xcstrings with L10n.swift...")

    # Check if files exist
    if not XCSTRINGS_PATH.exists():
        print(f"❌ Error: {XCSTRINGS_PATH} not found!")
        sys.exit(1)

    # Ensure output directory exists
    L10N_SWIFT_PATH.parent.mkdir(parents=True, exist_ok=True)

    # Parse xcstrings
    print(f"📖 Reading {XCSTRINGS_PATH}...")
    keys, ignored_keys = parse_xcstrings(XCSTRINGS_PATH)
    print(f"   Found {len(keys)} valid strings")
    if ignored_keys:
        print(f"   Ignored {len(ignored_keys)} strings (naming convention)")

    # Generate L10n.swift
    print(f"✍️  Generating {L10N_SWIFT_PATH}...")
    content = generate_l10n_swift(keys)

    # Write file
    with open(L10N_SWIFT_PATH, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"✅ Successfully generated {L10N_SWIFT_PATH}")
    print(f"   Total valid strings: {len(keys)}")

    # Show categories
    categories: Dict[str, int] = {}
    for key in keys:
        category, _ = categorize_key(key)
        categories[category] = categories.get(category, 0) + 1

    print("\n📊 Categories:")
    for category, count in sorted(categories.items(), key=lambda x: x[1], reverse=True):
        print(f"   {category}: {count}")

    # Show ignored keys
    if ignored_keys:
        print("\n⚠️  Ignored Keys (naming convention violations):")
        print("   These keys don't follow Swift naming conventions and were skipped.")
        print("   Format: key -> reason (English value)")
        print("")

        # Group by reason
        by_reason: Dict[str, List[Tuple[str, str]]] = {}
        for key, reason, value in ignored_keys:
            if reason not in by_reason:
                by_reason[reason] = []
            by_reason[reason].append((key, value))

        for reason, items in sorted(by_reason.items()):
            print(f"   [{reason}] ({len(items)} keys):")
            for key, value in sorted(items):
                display_value = value[:50] + "..." if len(value) > 50 else value
                print(f"      - \"{key}\" -> \"{display_value}\"")
            print("")


if __name__ == "__main__":
    main()
