#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; 1. 菜单配置中心（后续新增功能，在此处加一行即可）
; ==============================================================================

global ToolsMenu := Menu()

; 菜单绑定列表
ToolsMenu.Add("📋 复制纯文件名`tCtrl+Alt+Z", (*) => Action_CopyFileName())
ToolsMenu.Add("📦 运行 Repomix`tCtrl+Alt+R",  (*) => Action_RunRepomix())

; ------------------------------------------------------------------------------
; 【后续扩展占位】未来若要增加新工具，直接取消注释并绑定新函数：
; ToolsMenu.Add() ; 分割线
; ToolsMenu.Add("🚀 你的新功能名称", (*) => Action_YourNewFeature())
; ------------------------------------------------------------------------------


; ==============================================================================
; 2. 窗口范围与触发绑定
; ==============================================================================

; 仅在资源管理器及桌面环境中生效
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass") or WinActive("ahk_class Progman") or WinActive("ahk_class WorkerW")

; --- 呼出菜单：Alt + 鼠标右键 ---
!RButton::ShowToolsMenu()

; --- 独立直达快捷键 ---
^!z::Action_CopyFileName() ; Ctrl + Alt + Z
^!r::Action_RunRepomix()    ; Ctrl + Alt + R

#HotIf


; ==============================================================================
; 3. 菜单与窗口调度（解决多窗口/焦点错位问题）
; ==============================================================================

/**
 * 弹出菜单前强制激活鼠标所在的窗口，确保获取到正确的窗口路径
 */
ShowToolsMenu() {
    MouseGetPos ,, &hoverHwnd
    if hoverHwnd && (WinGetClass(hoverHwnd) ~= "CabinetWClass|ExploreWClass|Progman|WorkerW") {
        WinActivate("ahk_id " hoverHwnd)
    }
    ToolsMenu.Show()
}


; ==============================================================================
; 4. 功能动作层（每个功能一个独立函数）
; ==============================================================================

/**
 * 功能 1：复制当前选中文件的纯文件名
 */
Action_CopyFileName() {
    A_Clipboard := ""
    Send "^+c" ; 模拟 Win11 路径复制
    
    if !ClipWait(0.6) {
        ShowTip("⚠️ 未检测到选中的文件，请先鼠标单击选中")
        return
    }
    
    result := ""
    Loop Parse A_Clipboard, "`n", "`r" {
        cleanPath := StrReplace(A_LoopField, '"', '')
        if (cleanPath != "") {
            SplitPath cleanPath, &fileName
            result .= fileName "`n"
        }
    }
    result := RTrim(result, "`n")
    
    if (result != "") {
        A_Clipboard := result
        ShowTip("✅ 已复制文件名：`n" result)
    }
}

/**
 * 功能 2：在目标窗口真实路径下运行 Repomix
 */
Action_RunRepomix() {
    targetDir := GetActiveExplorerPath()
    if (targetDir == "") {
        ShowTip("⚠️ 无法识别当前资源管理器目录路径")
        return
    }

    ShowTip("🚀 正在启动 Repomix...`n" targetDir)
    
    ; 显式 cd 并执行命令
    cmd := 'powershell.exe -NoExit -Command "Set-Location \`"' targetDir '\`"; npx repomix --style markdown"'
    Run(cmd, targetDir)
}

/**
 * 【扩展模板】新增功能直接复制本函数修改
 */
Action_YourNewFeature() {
    targetDir := GetActiveExplorerPath()
    ShowTip("执行了新功能，目录：" targetDir)
}


; ==============================================================================
; 5. 底层工具库（Utils）
; ==============================================================================

/**
 * 精准获取当前激活资源管理器窗口/活动标签页的真实路径
 */
GetActiveExplorerPath() {
    ; 1. 桌面环境判断
    if WinActive("ahk_class Progman") or WinActive("ahk_class WorkerW") {
        return A_Desktop
    }

    ; 2. 获取当前获得焦点的窗口句柄
    activeHwnd := WinActive("A")
    if !activeHwnd
        return ""

    winTitle := WinGetTitle(activeHwnd)
    shell := ComObject("Shell.Application")
    matchedWindows := []

    ; 收集属于当前活动窗口的所有 Shell 视图对象
    for window in shell.Windows {
        try {
            if (window.hwnd == activeHwnd) {
                matchedWindows.Push(window)
            }
        }
    }

    ; 单窗口直接返回
    if (matchedWindows.Length == 1) {
        return matchedWindows[1].Document.Folder.Self.Path
    }

    ; 兼容 Win11 多标签页：遍历窗口，匹配标题与文件夹名称相符的活动标签
    if (matchedWindows.Length > 1) {
        for tabItem in matchedWindows {
            try {
                folderName := tabItem.Document.Folder.Self.Name
                if (folderName != "" && InStr(winTitle, folderName)) {
                    return tabItem.Document.Folder.Self.Path
                }
            }
        }
        return matchedWindows[1].Document.Folder.Self.Path
    }

    return ""
}

/**
 * 统一气泡提示
 */
ShowTip(text, duration := -1500) {
    ToolTip text
    SetTimer () => ToolTip(), duration
}