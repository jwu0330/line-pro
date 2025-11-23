# 📖 安裝指南

## 🎯 給新使用者：超簡單 4 步驟

### 步驟 1：下載並載入擴充程式

1. 下載此專案：
   - 點擊 [Download ZIP](https://github.com/jwu0330/line-pro/archive/refs/heads/master.zip)
   - 解壓縮到任意位置

2. 載入到 Chrome：
   - 開啟 Chrome
   - 在網址列輸入：`chrome://extensions/`
   - 右上角開啟「**開發人員模式**」
   - 點擊「**載入未封裝項目**」
   - 選擇解壓後的資料夾

### 步驟 2：點擊擴充圖示

- 在 Chrome 工具列找到綠色的 LINE 圖示
- 點擊它
- 會看到「❌ Native Host 未安裝」的提示

### 步驟 3：一鍵安裝

1. 點擊綠色的「**🚀 開始安裝**」按鈕
2. 會開啟新分頁，顯示安裝指令
3. 點擊「**📋 複製**」按鈕
4. 按 `Win + X`，選擇「Windows PowerShell」
5. 在 PowerShell 中按 `Ctrl + V` 貼上
6. 按 `Enter` 執行
7. 等待顯示「✅ 安裝完成！」

### 步驟 4：完成

1. 回到 Chrome
2. 再次點擊 LINE 圖示
3. 點擊「**🔄 重新檢測**」按鈕
4. LINE 會自動在 Edge 中開啟！

---

## 🎉 之後使用

只需要：
1. 點擊 Chrome 工具列上的 LINE 圖示
2. 等待 3-5 秒
3. LINE 自動開啟！

---

## ❓ 常見問題

### Q: 為什麼需要執行 PowerShell 指令？

**A:** 因為 Chrome 的安全限制，擴充程式無法直接安裝檔案到電腦。使用 PowerShell 指令可以：
- 自動下載需要的檔案
- 自動設定 Extension ID
- 自動註冊到系統
- 完全透明，可以看到每一步在做什麼

### Q: 這安全嗎？

**A:** 完全安全！
- ✅ 開源程式碼，可以審查
- ✅ 只安裝到使用者目錄，不需要管理員權限
- ✅ 使用 Chrome 官方 Native Messaging API
- ✅ 可以隨時完全移除

### Q: 安裝到哪裡？

**A:** 
- 位置：`C:\Users\你的使用者名稱\AppData\Local\LineOpenerPro\`
- 只有 4 個小檔案，總共約 13 KB
- 不會修改系統檔案
- 不會常駐記憶體

### Q: 如何解除安裝？

**A:** 
1. 在 PowerShell 執行：
   ```powershell
   Remove-Item "$env:LOCALAPPDATA\LineOpenerPro" -Recurse -Force
   reg delete "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /f
   ```
2. 在 Chrome 移除擴充程式

### Q: 點擊圖示沒反應？

**A:** 請確認：
1. ✅ 已執行 PowerShell 安裝指令
2. ✅ 看到「安裝完成」訊息
3. ✅ 已重新載入 Chrome 擴充程式
4. ✅ 已點擊「重新檢測」按鈕

如果還是不行：
1. 完全關閉 Chrome（所有視窗）
2. 重新開啟 Chrome
3. 再次測試

### Q: Extension ID 是什麼？

**A:** Extension ID 是 Chrome 給每個擴充程式的唯一識別碼，類似：
```
phmpiijeidboekpokjaannamejbkjock
```

安裝指令會自動填入正確的 ID，你不需要手動輸入。

### Q: 可以在其他電腦使用嗎？

**A:** 可以！每台電腦都需要：
1. 載入擴充程式（Extension ID 會不同）
2. 執行安裝指令
3. 完成！

### Q: 會不會干擾其他程式？

**A:** 不會！
- ✅ 只在你點擊圖示時才執行
- ✅ 不會常駐背景
- ✅ 不會影響其他擴充程式
- ✅ 不會修改 Edge 或 LINE 的設定

---

## 🔧 進階：手動安裝

如果你不想使用 PowerShell 指令，可以手動安裝：

### 1. 下載檔案

從 [native-host 資料夾](https://github.com/jwu0330/line-pro/tree/master/native-host) 下載：
- `line_opener_host.bat`
- `line_opener_host.ps1`
- `auto_click_line.ps1`

### 2. 建立目錄

```powershell
mkdir "$env:LOCALAPPDATA\LineOpenerPro\native-host"
```

### 3. 複製檔案

將下載的 3 個檔案複製到上面建立的目錄

### 4. 建立 manifest

在同一目錄建立 `com.line.opener.json`，內容：

```json
{
  "name": "com.line.opener",
  "description": "LINE Opener Native Host",
  "path": "C:\\Users\\你的使用者名稱\\AppData\\Local\\LineOpenerPro\\native-host\\line_opener_host.bat",
  "type": "stdio",
  "allowed_origins": [
    "chrome-extension://你的Extension ID/"
  ]
}
```

**注意：**
- 替換「你的使用者名稱」
- 替換「你的Extension ID」
- 路徑使用雙反斜線 `\\`

### 5. 註冊到 Chrome

```powershell
reg add "HKCU\Software\Google\Chrome\NativeMessagingHosts\com.line.opener" /ve /t REG_SZ /d "$env:LOCALAPPDATA\LineOpenerPro\native-host\com.line.opener.json" /f
```

### 6. 完成

重新載入 Chrome 擴充程式，點擊「重新檢測」

---

## 📞 需要幫助？

- 🐛 [回報問題](https://github.com/jwu0330/line-pro/issues)
- 💬 [討論區](https://github.com/jwu0330/line-pro/discussions)

---

**祝你使用愉快！** 🎉
