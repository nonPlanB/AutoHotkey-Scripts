# AutoHotkey Scripts (Windows 资源管理器效能工具箱)

基于 **AutoHotkey v2** 开发的 Windows 资源管理器（File Explorer）增强工具集合。提供独立的编译版 `.exe` 可执行文件（开箱即用，无需安装 AHK 环境）以及规范解耦的 `.ahk` 源码，方便日常使用与持续扩展。

---

## ✨ 核心特性

* **🖱️ 独创专属快捷菜单 (`Alt + 鼠标右键`)**
* 在资源管理器或桌面任意空白/文件处按下 `Alt + 右键`，直接唤出轻量级功能面板。
* **避开 Win11 痛点**：无需修改注册表，永不被系统折叠进“显示更多选项”（二级菜单）。


* **🎯 多窗口与 Win11 标签页精准定位**
* 解决多开资源管理器时焦点漂移的问题；
* 内置光标悬停窗口自动激活机制与 Shell COM 接口解析，精准抓取当前鼠标所在窗口（包含 Windows 11 多标签页）的真实物理路径。


* **📋 复制纯文件名 (`Ctrl + Alt + Z`)**
* 一键提取选中单/多文件的纯文件名（自动去除完整路径与 Win11 复制带有的双引号）。


* **📦 运行 Repomix 代码打包 (`Ctrl + Alt + R`)**
* 在当前文件夹路径下直接拉起 PowerShell 执行 `npx repomix --style markdown`，且执行后保留控制台便于排查输出日志。


* **🧩 模块化可维护架构**
* 菜单配置层、热键捕获层、动作执行层（Action）、底层工具库（Utils）彻底分离，方便随时追加自定义脚本。



---

## ⌨️ 快捷键速查

| 触发方式 | 作用场景 | 功能说明 |
| --- | --- | --- |
| **`Alt + 鼠标右键`** | 资源管理器 / 电脑桌面 | 呼出专属功能工具箱菜单 |
| **`Ctrl + Alt + Z`** | 资源管理器 / 电脑桌面 | 提取并复制选中文件的**纯文件名** |
| **`Ctrl + Alt + R`** | 资源管理器 / 电脑桌面 | 在当前目录执行 **`npx repomix --style markdown`** |

---

## 🚀 快速上手

### 方式一：直接运行 EXE（推荐）

1. 下载仓库中的 `ExplorerTools.exe`（由 AHK v2 官方编译器打包）。
2. 双击运行即可，无需安装 AutoHotkey 运行环境。

### 方式二：源码运行

1. 确保电脑已安装 [AutoHotkey v2.0+](https://www.autohotkey.com/)。
2. 双击运行 `ExplorerTools.ahk`。

---

## ⚙️ 开机自启设置（手动配置）

建议将脚本设置为开机自启，保证每次打开文件资源管理器随时可用：

1. 按下键盘快捷键 **`Win + R`** 打开运行窗口。
2. 输入 **`shell:startup`** 并按回车，系统将打开 Windows 启动文件夹。
3. 对你的 `ExplorerTools.exe`（或 `ExplorerTools.ahk`）点击右键，选择 **“创建快捷方式”**。
4. 将生成的快捷方式复制或剪切到刚打开的 `startup` 文件夹中即可。

---

## 🛠️ 二次开发与功能扩展

本项目代码严格分层，若需在此脚本中添加新脚本/工具，只需两步：

### 第一步：在动作层编写功能逻辑

在 `ExplorerTools.ahk` 的 `3. 功能动作层` 添加独立函数：

```autohotkey
Action_MyCustomTool() {
    targetDir := GetActiveExplorerPath() ; 获取当前窗口真实路径
    if (targetDir == "") {
        ShowTip("⚠️ 无法识别当前路径")
        return
    }
    
    ; 编写具体操作，例如启动自定义程序或命令行
    Run('powershell.exe -NoExit -Command "your-command-here"', targetDir)
    ShowTip("✅ 已启动自定义命令")
}

```

### 第二步：注册到菜单中心

在 `1. 菜单配置中心` 追加一行：

```autohotkey
ToolsMenu.Add("🚀 启动我的工具", (*) => Action_MyCustomTool())

```

*(若需要分配独立快捷键，在 `#HotIf` 区块内额外绑定即可)*

---

## 📄 License

MIT License © [nonPlanB](https://github.com/nonPlanB/nonPlanB)
