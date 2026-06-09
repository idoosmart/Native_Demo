# String Localization Scripts

This directory contains scripts for managing the Xcode String Catalog (.xcstrings) localization.

## sync_strings.py

Automatically synchronizes `Localizable.xcstrings` with `L10n.swift`.

### Usage

```bash
# From the project root directory
python3 scripts/sync_strings.py
```

### What it does

1. Reads all keys from `IDODemo/Resources/Localizable.xcstrings`
2. Generates corresponding Swift code in `IDODemo/Common/L10n.swift`
3. Automatically categorizes keys into logical groups:
   - Common
   - EPO
   - Bluetooth
   - System
   - Notification
   - Get Operations
   - Set Operations
   - Sports Types
   - Metrics Categories
   - Metric Names
   - Other

4. Handles duplicate keys by appending "Full" suffix (e.g., `cadence` and `cadenceFull`)
5. Preserves camelCase for keys that are already in that format
6. Adds English translations as documentation comments

### Workflow

1. **Add new strings in Xcode**: Open `Localizable.xcstrings` in Xcode and add your new keys with translations
2. **Run the sync script**: `python3 scripts/sync_strings.py`
3. **Use in code**: Access via `L10n.yourKeyName` or `"your_key".i18n`

### Example

```swift
// In Localizable.xcstrings, you have:
// Key: "welcome_message"
// English: "Welcome to the app!"
// Chinese: "欢迎使用！"

// Generated code:
/// Welcome to the app!
static var welcomeMessage: String { String(localized: "welcome_message") }

// Usage in your code:
label.text = L10n.welcomeMessage
// or
label.text = "welcome_message".i18n
```

### Notes

- Do not manually edit `L10n.swift` - it will be overwritten when you run the script
- The script preserves existing key categorization patterns
- Keys starting with numbers get an underscore prefix (e.g., `_3sAveragePower`)
- The script automatically detects and handles duplicate variable names
