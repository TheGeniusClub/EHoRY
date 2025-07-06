# EHoRY

![GitHub](https://img.shields.io/badge/License-Open_Source-blue)![Platform](https://img.shields.io/badge/Platform-Android-green)
[ChangeLog](https://github.com/yu13140/EHoRY/blob/main/update_log.md)

A comprehensive tool to hide root status and bypass detection on Android devices, supporting Magisk, KernelSU, APatch, etc.

## Features
- **Multi-Environment Support**: Compatible with Magisk, KernelSU, APatch.
- **Auto-Fix Issues**: Bypass detection from Momo, Native Test, Holmes.
- **Log Cleanup**: Clear residual logs from Magisk/LSPosed.
- **Developer Mode Control**: Toggle ADB debugging quickly.
- **Convenient installation modules**: Install all modules in the local folder.
- **Install required modules**: Support the installation of modules required for the hidden environment.

## Requirements
- Android 7.0+
- Root: Magisk (v23+), KernelSU, APatch
- Terminal: MT Manager, etc. (Termux❌)

## Usage
1. **Download Script**  
   ```bash
   curl -LJO https://raw.githubusercontent.com/yu13140/EHoRY/main/EHoRY.sh
   ```

2. **Run as Root**  
   ```bash
   su
   bash EHoRY.sh
   ```

Note: If the script does not execute successfully, look for a downloaded script to execute it manually.

## Warnings
1. **Backup Data**: Always backup before operation.
2. **Recovery Ready**: Ensure device can enter Recovery mode.
3. **Chinese Only**：At present, the output of the script is only Chinese. I welcome you to add your own language to the script.

---

## License
This project is licensed under the **CC BY-NC-SA 4.0 License**.  
For details, see [LICENSE](https://github.com/yu13140/EHoRY/blob/main/LICENSE).

## Contact
- Author: [酷安@yu13140](https://www.coolapk.com/u/24898135)
- Issues: [GitHub Issues](https://github.com/yu13140/EHoRY/issues)