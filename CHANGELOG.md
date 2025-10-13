# Changelog

All notable changes to the Windsurf IDE Reset Utility will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2025-10-13

### Added
- Enhanced JSON handling for PowerShell 5.1+ compatibility
- Automatic timestamped backup creation before modifications
- Comprehensive error handling and validation
- Detailed console output with color-coded messages
- Administrator privilege verification
- File existence validation before processing

### Changed
- Improved script structure and code organization
- Better user feedback with clear success/error messages
- Updated JSON manipulation to use PSCustomObject for compatibility

### Fixed
- PowerShell 5.1 compatibility issues
- JSON parsing errors in certain scenarios
- Backup file naming to prevent conflicts

### Security
- Added backup mechanism to prevent data loss
- Implemented safe JSON modification with rollback capability
- Added file validation before any modifications

## [1.0.0] - 2025-10-01

### Added
- Initial release
- Basic telemetry ID reset functionality
- Support for three telemetry identifiers:
  - `machineId`
  - `macMachineId`
  - `devDeviceId`
- Simple PowerShell script implementation

### Features
- Reset Windsurf IDE telemetry identifiers
- Generate new GUIDs for device identification
- Basic error handling

---

## [Unreleased]

### Planned Features
- GUI interface option
- Batch processing for multiple IDE instances
- Configuration restore from backup
- Scheduled reset capability
- Cross-platform support (Linux/macOS)

---

## Version History

- **1.1.0** - Current stable version with enhanced features
- **1.0.0** - Initial release

## How to Update

To update to the latest version:

1. Download the latest release from [GitHub Releases](https://github.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset/releases)
2. Replace your existing script file
3. Review the changelog for any breaking changes
4. Run the new version as usual

## Support

For issues or questions about specific versions:
- Check [GitHub Issues](https://github.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset/issues)
- Contact via YouTube: [@bforbca](https://youtube.com/@bforbca)

---

**Note:** This changelog is maintained manually. For detailed commit history, see the [GitHub repository](https://github.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset).
