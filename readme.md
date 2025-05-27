# EHoRY

![GitHub](https://img.shields.io/badge/License-开源协议-blue)![Platform](https://img.shields.io/badge/Platform-Android-green)
[English](https://github.com/yu13140/EHoRY/blob/main/readme_en.md) | [更新日志](https://github.com/yu13140/EHoRY/blob/main/update_log.md)

一个用于隐藏Android设备Root状态和绕过检测的综合脚本工具，支持Magisk、KernelSU、APatch等多种环境。
A comprehensive tool to hide root status and bypass detection on Android devices, supporting Magisk, KernelSU, APatch, etc.

## 功能特性
- **多环境支持**: 兼容Magisk、KernelSU、APatch等Root方案。
- **自动化修复**: 一键解决Momo、Native Test、Holmes等应用的检测问题。
- **日志清理**: 清除Magisk/LSPosed等残留日志。
- **开发者模式控制**: 快速开关ADB调试和开发者选项。
- **网络优化**: 自动选择最佳CDN节点加速下载。
- **便捷安装模块**：一键安装本地文件夹中的的所有模块。
- **安装所需模块**：支持安装隐藏环境所需的模块。

## 支持环境
- Android 7.0及以上
- Root工具：Magisk (v23+)、KernelSU、APatch
- 终端：MT管理器等 (Termux❌)

## 使用方法
1. **下载脚本**  
   ```bash
   curl -LJO https://raw.githubusercontent.com/yu13140/EHoRY/main/EHoRY.sh
   ```
2. **赋予权限**  
   ```bash
   chmod +x EHoRY.sh
   ```
3. **以Root权限运行**  
   ```bash
   su -c ./EHoRY.sh
   ```

## 注意事项
1. **备份数据**: 操作前建议备份重要数据。
2. **救砖准备**: 部分功能涉及分区修改，需确保设备可进入Recovery模式。
3. **网络要求**: 模块下载依赖GitHub，若连接失败请使用代理。

---

## 许可证
本项目采用**GPL-3.0**许可证
想知道更多细节？[LICENSE](https://github.com/yu13140/EHoRY/blob/main/LICENSE).

## 联系
- 作者: [酷安@yu13140](https://www.coolapk.com/u/24898135)
- 问题: [GitHub Issues](https://github.com/yu13140/EHoRY/issues)