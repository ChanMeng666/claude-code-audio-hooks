# Changelog

All notable changes to Claude Code Audio Hooks will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.4.0] - 2025-11-06

### Added
- **Dual Audio System**: Complete flexibility to choose between voice and non-voice notifications
  - 9 new modern UI chime sound effects in `audio/custom/` directory
  - 9 refreshed voice notifications in `audio/default/` directory (Jessica voice from ElevenLabs)
- **Pre-configured Examples**:
  - `config/example_preferences_chimes.json` - All chimes configuration
  - `config/example_preferences_mixed.json` - Mixed voice and chimes with scenario templates
- **Audio Customization Documentation**: New comprehensive section in README explaining:
  - Three audio options (voice-only, chimes-only, mixed)
  - Quick-start guide for switching to chimes
  - Available audio files comparison table
  - Configuration scenarios for different use cases
- **User Choice Philosophy**: System now supports complete user customization
  - Default configuration uses voice (existing behavior preserved)
  - Users can easily switch to chimes or create mixed configurations
  - Simple one-file configuration change to switch audio sets

### Changed
- README.md updated with new "Audio Customization Options" section
- Version badges updated to v2.4.0
- Table of Contents updated with new audio customization section

### Enhanced
- User flexibility: Users can now choose audio style based on personal preference
- Music-friendly option: Chimes don't interfere with background music
- Mixed configurations: Different audio types for different notification priorities

### Background
This release addresses user feedback requesting non-voice notification options, particularly for users who:
- Play music while coding
- Prefer instrumental sounds over AI voices
- Want different audio styles for different notification types

The dual audio system maintains backward compatibility (default voice notifications) while providing complete flexibility for users who want alternatives.

## [2.3.1] - 2025-11-06

### Fixed
- Critical bug in configure.sh save_configuration() function that prevented saving on macOS
- Python heredoc in configure.sh now correctly passes CONFIG_FILE path using shell variable substitution
- Resolved IndexError when accessing sys.argv[1] in Python heredoc

## [2.3.0] - 2025-11-06

### Added
- Full compatibility with macOS default bash 3.2
- Bash version detection in install.sh with helpful warnings
- Compatibility notes in scripts for macOS users

### Fixed
- Replaced bash 4+ associative arrays with indexed arrays in configure.sh and test-audio.sh
- Replaced bash 4+ case conversion operators (${var^^} and ${var,,}) with tr commands in path_utils.sh
- All scripts now work with bash 3.2+ without requiring Homebrew bash on macOS

### Changed
- Refactored configure.sh to use parallel indexed arrays instead of associative arrays
- Refactored test-audio.sh to use parallel indexed arrays for configuration data
- Updated path_utils.sh to use portable tr command for case conversion
- Enhanced README with macOS compatibility information

## [2.2.0] - Previous Release

### Added
- Automatic format compatibility for Claude Code v2.0.32+
- Git Bash path conversion fixes
- Enhanced Windows compatibility

### Fixed
- Path conversion issues on Git Bash
- Audio playback on various Windows environments

## [2.1.0] - Previous Release

### Added
- Hook trigger logging system
- Diagnostic tools for troubleshooting
- View-hook-log.sh script for monitoring hook triggers

## [2.0.0] - Major Release

### Added
- 9 different hook types (up from 1 in v1.0)
- Professional ElevenLabs audio files
- Interactive configuration tool
- JSON-based user preferences
- Audio queue system
- Debounce system
- Automatic v1.0 upgrade support

### Changed
- Complete project restructure
- Modular hook system with shared library
- Cross-platform support improvements

## [1.0.0] - Initial Release

### Added
- Basic stop hook with audio notification
- Simple installation script
- Custom audio support