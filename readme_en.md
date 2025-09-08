# EHoRY

###### A comprehensive tool to hide root status and bypass detection on Android devices.

[简体中文](readme.md) | [English](readme_en.md)

![](https://img.shields.io/badge/Platform-Android-green?logo=Android&style=for-the-badge)  
[![](https://img.shields.io/badge/Update_Log-v5.0-orange?style=for-the-badge)](update_log.md)  

> [!IMPORTANT]
> The current branch is built using Rust  
> The old version is built using pure Shell  
> For details, please refer to [old branch](https://github.com/yu13140/EHoRY/tree/old)  

## Features
- **Multi-Environment Support**: Compatible with Magisk, KernelSU, APatch.
- **Auto-Fix Issues**: Bypass detection from Momo, Native Test, Holmes.
- **Convenient installation modules**: Install all modules in the local folder.
- **Install required modules**: Support the installation of modules required for the hidden environment.

## Requirements
- Android 7.0+
- Root: Magisk (v23+), KernelSU, APatch
- Terminal: MT Manager, etc. (Termux❌)

## Usage
1. **Download Script**     
   [DownLoad](https://github.com/yu13140/EHoRY/releases/tag/v5.0)

2. **Run as Root**  
   ```bash
   su
   bash EHoRY.sh
   ```
> [!WARNING]
> Always backup before operation.  
> Ensure device can enter Recovery mode.  
> If the script does not execute successfully, look for a downloaded script to execute it manually.  
> At present, the output of the script is only Chinese. I welcome you to add your own language to the script.  

---

## License
This project is licensed under the **CC BY-NC-SA 4.0 License**.  
For details, see

[![](https://img.shields.io/badge/License-CC_BY--NC--NA_4.0-blue?style=for-the-badge&logo=Github)](LICENSE)

## Contact
- Author: [Coolapk@yu13140](https://www.coolapk.com/u/24898135)
- Issues: [GitHub Issues](https://github.com/yu13140/EHoRY/issues)

## Thanks
> Service [VerifiedBootHash](https://github.com/yu13140/VerifiedBootHash) Source of code:  
> [vvb2060/KeyAttestation](https://github.com/vvb2060/KeyAttestation)  
> [Xtrlumen/GetVBHash](https://github.com/XtrLumen/GetVBHash)  

- [5ec1cff/cmd-wrapper](https://gist.github.com/5ec1cff/4b3a3ef329094e1427e2397cfa2435ff) - Eliminate obstacles in the execution environment  
- [JonForShort/Android tools](https://github.com/JonForShort/android-tools) - Provide aapt tool for Android platform