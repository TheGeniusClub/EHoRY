# EHoRY

##### 一个用于隐藏Android设备Root状态和绕过检测的综合脚本工具。

[简体中文](readme.md) | [English](readme_en.md)

![](https://img.shields.io/badge/Platform-Android-green?logo=Android&style=for-the-badge)  
[![](https://img.shields.io/badge/Update_Log-v5.0-orange?style=for-the-badge)](update_log.md)  

> [!IMPORTANT]
> 当前分支为使用Rust构建的分支  
> 旧版本使用纯Shell构建  
> 详情请见：[old branch](https://github.com/yu13140/EHoRY/tree/oldv)  

## 功能特性
- **多环境支持**: 兼容Magisk、KernelSU、APatch等Root方案。
- **自动化修复**: 一键解决Momo、Native Test、Holmes等应用的检测问题。
- **网络优化**: 自动选择最佳CDN节点加速下载。
- **便捷安装模块**：可以一键安装本地文件夹中的的所有模块。
- **安装所需模块**：支持安装隐藏环境所需的模块。

## 支持环境
- Android 7.0及以上
- Root工具：Magisk (v23+)、KernelSU、APatch
- 终端：MT管理器等 (Termux❌)

## 使用方法
1. **下载脚本**  
   [DownLoad](https://github.com/yu13140/EHoRY/releases/tag/v5.0)
   ```
2. **以Root权限运行**
   ```bash
   su
   sh EHoRY.sh
   ```
> [!WARNING]
> 操作前建议备份重要数据。  
> 部分功能涉及分区修改，需确保设备可进入Recovery模式。  
> 模块下载依赖GitHub，若连接失败请使用代理。  
> 如果脚本不能成功执行，请寻找设备内下载好的脚本手动执行它。   

---

## 许可证
本项目采用**CC BY-NC-SA 4.0**许可证  
想知道更多细节？

[![](https://img.shields.io/badge/License-CC_BY--NC--NA_4.0-blue?style=for-the-badge&logo=Github)](LICENSE)

## 联系
- 作者: [酷安@yu13140](https://www.coolapk.com/u/24898135)
- 反馈: [GitHub Issues](https://github.com/yu13140/EHoRY/issues)

## 鸣谢
>服务[VerifiedBootHash](https://github.com/yu13140/VerifiedBootHash)的代码来源：  
>[vvb2060/KeyAttestation](https://github.com/vvb2060/KeyAttestation)  
>[Xtrlumen/GetVBHash](https://github.com/XtrLumen/GetVBHash)  

- [5ec1cff/cmd-wrapper](https://gist.github.com/5ec1cff/4b3a3ef329094e1427e2397cfa2435ff) - 扫平执行环境障碍
- [JonForShort/android-tools](https://github.com/JonForShort/android-tools) - 提供安卓平台的aapt工具