# Koharu 0.83.4 气泡内边距修复版

修复过窄或过矮的气泡因固定内边距而触发 `text inset leaves no layout area` 的问题。空间不足时按比例缩小边距，给文字排版保留空间；正常气泡的边距保持原样。矩形排版区域和气泡轮廓使用同一组调整后的边距。

本仓库从上游 `0.83.4` 标签构建 Windows x64 版本。它只包含构建流程和补丁，不包含用户的漫画项目、模型或账号设置。

## 下载和使用

1. 打开本仓库的 **Actions**，选择最近成功的 **Build fixed Koharu 0.83.4**。
2. 下载 `koharu-0.83.4-fixed-windows` artifact，完整解压到一个新文件夹。
3. 保留 `koharu.exe`、所有 DLL、资源文件和 `locales` 文件夹，再运行 `koharu.exe`。
4. 先打开项目的 TEST 副本，验证此前失败的页面及导出结果。程序仍使用 Koharu 自己的数据目录和设置。

完整运行包的生成从打包流程修订后生效。更早构建的 artifact 只包含主程序，缺少 Chromium 运行库，不能单独作为完整安装包使用。

## 构建与验证

在 **Actions → Build fixed Koharu 0.83.4 → Run workflow** 中手动构建。推送到 `main` 也会触发构建。

构建流程会运行四项回归测试：窄气泡、矮气泡、正常气泡和异常边距。测试通过后构建正式版本，并收集运行所需的 Chromium 文件及许可证。`SHA256SUMS.txt` 包含包内文件的校验值。

Tauri CLI 使用官方 `3.0.0-alpha.1` Windows 预编译版本，并验证固定的 SHA-256，避免每次从源码重新编译构建工具。

上游源码及许可证：[koharu-rs/koharu](https://github.com/koharu-rs/koharu/tree/0.83.4)。

