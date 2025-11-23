# Open LINE in Edge (Pro)

一鍵從 Chrome 開啟 Edge 的 LINE，使用 Native Messaging 技術，無確認對話框，完全背景執行。

## ✨ 特色

- ✅ **無確認對話框** - 使用 Chrome Native Messaging API
- ✅ **完全背景執行** - 不會有任何視窗閃現
- ✅ **自動點擊 LINE** - 使用 Windows UI Automation
- ✅ **可上架 Chrome Web Store** - 符合官方規範
- ✅ **無需 Python** - 只使用 Windows 內建工具

---

## 📦 安裝步驟

### 1. 載入 Chrome 擴充程式

1. 開啟 Chrome 瀏覽器
2. 前往 `chrome://extensions/`
3. 右上角開啟「**開發人員模式**」
4. 點擊「**載入未封裝項目**」
5. 選擇此資料夾（`line-pro`）
6. **複製擴充程式 ID**（在擴充程式名稱下方）

### 2. 安裝 Native Host

1. 雙擊執行 `install-pro.bat`
2. 當提示輸入 Extension ID 時，貼上剛才複製的 ID
3. 等待安裝完成

### 3. 重新載入擴充程式

1. 回到 `chrome://extensions/`
2. 找到「Open LINE in Edge (Pro)」
3. 點擊「🔄 重新載入」按鈕

### 4. 測試

點擊 Chrome 工具列上的擴充圖示，LINE 應該會自動開啟！

---

## 🎯 使用方式

### 日常使用

1. 點擊 Chrome 工具列上的 LINE 圖示
2. Edge 自動開啟
3. LINE 自動點擊
4. 完成！

**整個過程約 3-5 秒，完全自動化。**

### 固定到工具列（可選）

1. 點擊 Chrome 右上角的拼圖圖示
2. 找到「Open LINE in Edge (Pro)」
3. 點擊📌圖釘圖示固定到工具列

---

## 🔧 技術架構

```
Chrome Extension
    ↓ (Native Messaging API)
Native Host (批次檔 + PowerShell)
    ↓
PowerShell 腳本
    ↓
Windows UI Automation
    ↓
自動點擊 Edge 中的 LINE 圖示
    ↓
LINE 開啟
```

### 檔案說明

```
line-pro/
├── manifest.json              # Chrome 擴充程式配置
├── popup.html                 # 擴充程式 UI
├── popup.js                   # 擴充程式邏輯
├── icons/                     # 圖示
├── native-host/               # Native Host 檔案
│   ├── line_opener_host.bat   # Native Host 入口
│   ├── line_opener_host.ps1   # Native Messaging 處理
│   ├── auto_click_line.ps1    # UI Automation 腳本
│   └── com.line.opener.json   # Native Host manifest
├── install-pro.bat            # 安裝程式
├── uninstall-pro.bat          # 解除安裝
└── check-install.bat          # 檢查安裝狀態
```

---

## ❓ 常見問題

### Q: 點擊圖示沒反應？

**A:** 檢查以下項目：

1. **Extension ID 是否正確**
   ```cmd
   check-install.bat
   ```
   查看 manifest 中的 Extension ID 是否與實際相符

2. **重新安裝**
   ```cmd
   uninstall-pro.bat
   install-pro.bat
   ```

3. **檢查 LINE 擴充功能**
   - 確認 Edge 已安裝 LINE 擴充功能
   - 確認 LINE 圖示在 Edge 工具列可見

### Q: 如何更新 Extension ID？

**A:** 開啟 PowerShell 執行：

```powershell
$extId = "你的新Extension ID"
$manifestPath = "$env:LOCALAPPDATA\LineOpenerPro\native-host\com.line.opener.json"
$hostPath = "$env:LOCALAPPDATA\LineOpenerPro\native-host\line_opener_host.bat"
$hostPathJson = $hostPath -replace '\\', '\\'

$manifest = @"
{
  "name": "com.line.opener",
  "description": "LINE Opener Native Host",
  "path": "$hostPathJson",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://$extId/"
  ]
}
"@

Set-Content $manifestPath -Value $manifest -Encoding UTF8
Write-Host "已更新 Extension ID: $extId"
```

然後重新載入擴充程式。

### Q: 如何解除安裝？

**A:** 

1. 執行 `uninstall-pro.bat`
2. 在 Chrome 移除擴充程式

---

## 🆚 與基本版比較

| 功能 | 基本版 (line) | Pro 版 (line-pro) |
|------|---------------|-------------------|
| 自動點擊 LINE | ✅ | ✅ |
| 確認對話框 | ❌ 每次詢問 | ✅ 無需確認 |
| 背景執行 | ⚠️ 可能閃現 | ✅ 完全隱藏 |
| 安裝複雜度 | 簡單 | 中等 |
| 需要 Python | ❌ | ❌ |
| 可上架 Web Store | ❌ | ✅ |

---

## 🔒 安全性

- ✅ 只安裝到使用者目錄（`%LOCALAPPDATA%`）
- ✅ 不需要管理員權限
- ✅ 可以完全移除
- ✅ 使用 Chrome 官方 Native Messaging API
- ✅ 開源程式碼，可審查

---

## 📝 系統需求

- Windows 10/11
- Chrome 瀏覽器
- Microsoft Edge（已安裝 LINE 擴充功能）
- PowerShell 5.0+（Windows 內建）

---

## 🐛 問題回報

如果遇到問題，請提供：

1. Windows 版本
2. Chrome 版本
3. Edge 版本
4. 錯誤訊息截圖
5. `check-install.bat` 的輸出

---

## 📄 授權

MIT License

---

## 🙏 致謝

感謝所有測試和回饋的使用者！
