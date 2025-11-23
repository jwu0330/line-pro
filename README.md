# 🚀 Open LINE in Edge (Pro)

一鍵從 Chrome 開啟 Edge 的 LINE，無確認對話框，完全自動化。

[![Version](https://img.shields.io/badge/version-2.2.0-green.svg)](https://github.com/jwu0330/line-pro/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

---

## ✨ 特色

- ⚡ **無確認對話框** - 使用 Chrome Native Messaging API
- 🎯 **完全自動化** - 自動點擊 LINE 圖示
- 🔒 **安全可靠** - Chrome 官方 API，開源可審查
- 🎨 **智能引導** - 首次使用自動引導安裝
- 💻 **一鍵安裝** - 複製貼上 PowerShell 指令即可

---

## 📥 快速開始

### 方法 1：一鍵安裝（推薦）

1. **載入 Chrome 擴充程式**
   - 下載此專案：[Download ZIP](https://github.com/jwu0330/line-pro/archive/refs/heads/master.zip)
   - 解壓縮
   - 在 Chrome 前往 `chrome://extensions/`
   - 開啟「開發人員模式」
   - 點擊「載入未封裝項目」，選擇解壓後的資料夾

2. **點擊擴充圖示**
   - 點擊 Chrome 工具列上的 LINE 圖示
   - 會看到「未安裝」提示

3. **點擊「開始安裝」**
   - 點擊綠色的「🚀 開始安裝」按鈕
   - 會開啟安裝指南頁面

4. **複製並執行指令**
   - 點擊「📋 複製」按鈕
   - 開啟 PowerShell（按 `Win + X`）
   - 貼上並按 Enter

5. **完成！**
   - 回到 Chrome，點擊「🔄 重新檢測」
   - LINE 會自動在 Edge 中開啟！

### 方法 2：手動安裝

查看 [完整安裝指南](https://jwu0330.github.io/line-pro/)

---

## 🎯 使用方式

### 第一次使用
```
點擊圖示 → 看到引導 → 點擊「開始安裝」→ 複製指令 → 執行 → 重新檢測 → 完成
```

### 之後使用
```
點擊圖示 → LINE 自動開啟（約 3-5 秒）
```

---

## 🔧 系統需求

- ✅ Windows 10/11
- ✅ Chrome 瀏覽器
- ✅ Microsoft Edge（已安裝 LINE 擴充功能）
- ✅ PowerShell 5.0+（Windows 內建）

---

## 📖 工作原理

```
Chrome Extension
    ↓ (檢測 Native Host)
未安裝 → 顯示安裝引導
已安裝 → 發送訊息
    ↓ (Native Messaging)
Native Host (批次檔 + PowerShell)
    ↓
PowerShell UI Automation
    ↓
自動點擊 Edge 中的 LINE 圖示
    ↓
LINE 開啟！
```

---

## ❓ 常見問題

### Q: 點擊圖示沒反應？

**A:** 請確認：
1. 已執行安裝指令
2. Extension ID 正確
3. 已重新載入擴充程式
4. 點擊「重新檢測」按鈕

### Q: 如何更新 Extension ID？

**A:** 執行以下 PowerShell 指令：

```powershell
$extId = "你的新Extension ID"
$installDir = "$env:LOCALAPPDATA\LineOpenerPro\native-host"
$hostPath = "$installDir\line_opener_host.bat" -replace '\\', '\\'
$manifest = @"
{
  "name": "com.line.opener",
  "description": "LINE Opener Native Host",
  "path": "$hostPath",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$extId/"
  ]
}
"@
Set-Content "$installDir\com.line.opener.json" -Value $manifest -Encoding UTF8
Write-Host "已更新 Extension ID: $extId" -ForegroundColor Green
```

### Q: 如何解除安裝？

**A:** 執行：

```powershell
Remove-Item "$env:LOCALAPPDATA\LineOpenerPro" -Recurse -Force
reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /f
```

然後在 Chrome 移除擴充程式。

### Q: 安裝在哪裡？

**A:** 
- 檔案位置：`%LOCALAPPDATA%\LineOpenerPro\`
- 註冊表：`HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener`
- 不需要管理員權限
- 可以完全移除

---

## 🛠️ 開發者資訊

### 專案結構

```
line-pro/
├── manifest.json              # Chrome 擴充程式配置
├── popup.html                 # 擴充程式 UI
├── popup.js                   # 擴充程式邏輯（智能檢測）
├── background.js              # 背景服務
├── icons/                     # 圖示
├── native-host/               # Native Host 檔案
│   ├── line_opener_host.bat   # Native Host 入口
│   ├── line_opener_host.ps1   # Native Messaging 處理
│   └── auto_click_line.ps1    # UI Automation 腳本
├── docs/                      # GitHub Pages
│   ├── index.html            # 安裝指南首頁
│   └── install.html          # 一鍵安裝頁面
└── quick-test.ps1            # 快速測試腳本
```

### 本地測試

```powershell
# 快速測試
.\quick-test.ps1

# 完整流程測試
.\test-complete-flow.ps1

# 驗證安裝
.\verify-installation.ps1
```

### 建立發佈版本

```powershell
.\build-release.bat
```

---

## 🆚 版本比較

| 功能 | 基本版 | Pro 版 |
|------|--------|--------|
| 自動點擊 LINE | ✅ | ✅ |
| 確認對話框 | ❌ 每次詢問 | ✅ 無需確認 |
| 背景執行 | ⚠️ 可能閃現 | ✅ 完全隱藏 |
| 智能引導 | ❌ | ✅ |
| 一鍵安裝 | ❌ | ✅ |
| 可上架 Web Store | ❌ | ✅ |

---

## 📝 更新日誌

### v2.2.0 (2025-11-24)
- ✨ 新增一鍵 PowerShell 安裝
- ✨ 智能安裝引導系統
- ✨ 自動檢測 Native Host 狀態
- 🐛 修正路徑格式問題
- 📝 完整的測試套件

### v2.1.0 (2025-11-23)
- ✨ 智能引導系統
- ✨ 自動顯示 Extension ID
- ✨ 安裝狀態檢測

### v2.0.0 (2025-11-23)
- 🎉 初始 Native Messaging 版本
- ✨ 無確認對話框
- ✨ 完全背景執行

---

## 🤝 貢獻

歡迎提交 Issue 和 Pull Request！

---

## 📄 授權

MIT License - 詳見 [LICENSE](LICENSE)

---

## 🙏 致謝

感謝所有測試和回饋的使用者！

---

## 📞 支援

- 🐛 [回報問題](https://github.com/jwu0330/line-pro/issues)
- 💬 [討論區](https://github.com/jwu0330/line-pro/discussions)
- 📧 聯絡作者

---

**⭐ 如果這個專案對你有幫助，請給個星星！**
