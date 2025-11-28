# 🌊 Windsurf IDE Reset Utility

<div align="center">

![Version](https://img.shields.io/badge/version-2.0-blue.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)

**A safe and reliable PowerShell utility to reset Windsurf IDE telemetry identifiers**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [How It Works](#-how-it-works) • [FAQ](#-faq)

</div>

---

## ⚠️ DISCLAIMER

> **IMPORTANT:** This tool is provided for **educational and testing purposes only**. 
> 
> - Use this script at your own risk and responsibility
> - The author is not responsible for any misuse or damage caused by this tool
> - Ensure you understand what this script does before running it
> - Always maintain backups of your important data
> - This tool is intended for legitimate testing and development scenarios only
> 
> By using this script, you acknowledge that you have read and understood this disclaimer.

---

## 📋 Overview

This PowerShell script safely resets Windsurf IDE's telemetry identifiers (app-level only) without affecting your Windows Machine ID or system information. Perfect for developers who need to refresh their IDE instance or troubleshoot telemetry-related issues.

## ✨ Features

- 🔒 **Safe & Non-Destructive** - Automatically creates timestamped backups before making changes
- 🎯 **Targeted Reset** - Only modifies app-level telemetry IDs, not system identifiers
- 🛡️ **Administrator Check** - Ensures proper permissions before execution
- 📝 **Detailed Logging** - Clear console output showing all changes made
- 🔄 **PowerShell 5.1+ Compatible** - Works on all modern Windows systems
- ✅ **Error Handling** - Robust error checking and user-friendly messages

## 🚀 Installation

### Prerequisites

- Windows operating system
- PowerShell 5.1 or higher
- Windsurf IDE installed
- Administrator privileges

### Method 1: Run Directly from GitHub (Easiest)

**One-line command** - No download needed:

```powershell
powershell -ExecutionPolicy Bypass -Command "iwr https://raw.githubusercontent.com/abhishek-maurya576/reset_cursor/main/windsurf_reset_v2r.ps1 | iex"
```

> ⚠️ **Note:** Make sure to run PowerShell as Administrator for this command to work properly.


### Download

1. Clone this repository or download the script directly:
   ```powershell
   git clone https://github.com/abhishek-maurya576/windsurf-ide-reset.git
   ```

2. Or download the script file directly:
   - [Download `reset_windsurf_IDE-v1.0.ps1`](https://github.com/abhishek-maurya576/Windsurf-IDE-Configuration-Reset/releases/download/v1.0/reset_windsurf_IDE-v1.0.ps1)

## 💻 Usage

### Step 1: Run as Administrator

Right-click on **PowerShell** and select **"Run as Administrator"**

### Step 2: Navigate to Script Directory

```powershell
cd path\to\script\directory
```

### Step 3: Execute the Script

```powershell
powershell -ExecutionPolicy Bypass -File .\reset_windsurf_IDE-v1.0.ps1
```

### Step 4: Restart Windsurf IDE

After successful execution, restart Windsurf IDE to apply the changes.

## 🔧 How It Works

The script performs the following operations:

1. **Permission Check** - Verifies the script is running with Administrator privileges
2. **File Validation** - Checks if Windsurf's `storage.json` exists at:
   ```
   %APPDATA%\Windsurf\User\globalStorage\storage.json
   ```
3. **Backup Creation** - Creates a timestamped backup of the original file
4. **ID Generation** - Generates three new GUIDs for:
   - `telemetry.machineId`
   - `telemetry.macMachineId`
   - `telemetry.devDeviceId`
5. **Safe Update** - Updates the JSON configuration while preserving all other settings
6. **Verification** - Displays the new identifiers and backup location

### What Gets Modified

The script **ONLY** modifies these fields in `storage.json`:

```json
{
  "telemetry": {
    "machineId": "new-guid-here",
    "macMachineId": "new-guid-here",
    "devDeviceId": "new-guid-here"
  }
}
```

### What Stays Unchanged

- ✅ Windows Machine ID
- ✅ System hardware information
- ✅ All other Windsurf settings and preferences
- ✅ Installed extensions and configurations

## 📸 Example Output

```
Backup created at: C:\Users\YourName\AppData\Roaming\Windsurf\User\globalStorage\storage.json.backup_20241013_191530

Windsurf device identifiers have been reset successfully!

New Identifiers:
   telemetry.machineId    : a1b2c3d4-e5f6-7890-abcd-ef1234567890
   telemetry.macMachineId : b2c3d4e5-f6a7-8901-bcde-f12345678901
   telemetry.devDeviceId  : c3d4e5f6-a7b8-9012-cdef-123456789012

Backup file location: C:\Users\YourName\AppData\Roaming\Windsurf\User\globalStorage\storage.json.backup_20241013_191530

Done! You can now restart Windsurf IDE.
```

## ❓ FAQ

### Is this safe to use?

Yes! The script creates automatic backups before making any changes. You can always restore from the backup if needed.

### Will this affect my Windows installation?

No. This script only modifies Windsurf IDE's application-level telemetry identifiers, not system-level IDs.

### What if something goes wrong?

The script creates timestamped backups. Simply copy the backup file back to `storage.json` to restore your previous configuration.

### Do I need to uninstall Windsurf?

No. This script works with your existing Windsurf installation without requiring reinstallation.

### Can I run this multiple times?

Yes. Each execution creates a new backup and generates fresh identifiers.

## 🛠️ Troubleshooting

### "Please run this script as Administrator"

**Solution:** Right-click PowerShell and select "Run as Administrator"

### "Windsurf storage.json not found"

**Solution:** Ensure Windsurf IDE is installed and has been run at least once

### "Execution Policy" Error

**Solution:** Run this command in Administrator PowerShell:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## 📦 File Structure

```
Windsurf-IDE-Configuration-Reset/
├── reset_windsurf_IDE-v1.0.ps1    # Main PowerShell script
├── README.md                       # Project documentation
├── LICENSE                         # MIT License
├── CONTRIBUTING.md                 # Contribution guidelines
├── SECURITY.md                     # Security policy
├── CHANGELOG.md                    # Version history
└── .gitignore                      # Git ignore rules
```

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - feel free to use, modify, and distribute as needed.

## 👨‍💻 Author

**Abhishek Maurya**

- 🎥 YouTube: [@bforbca](https://youtube.com/@bforbca)
- 💻 GitHub: [@abhishek-maurya576](https://github.com/abhishek-maurya576)

## ⭐ Show Your Support

If this project helped you, please consider giving it a ⭐ on GitHub!

## 📝 Changelog

### Version 1.1
- Enhanced JSON handling for PowerShell 5.1+ compatibility
- Improved error handling and user feedback
- Added automatic backup with timestamps
- Better validation and safety checks

### Version 1.0
- Initial release
- Basic telemetry ID reset functionality

---

<div align="center">

**Made with ❤️ by Abhishek Maurya**

[⬆ Back to Top](#-windsurf-ide-reset-utility)

</div>
