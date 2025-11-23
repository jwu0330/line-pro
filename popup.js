// Popup script - Native Messaging 版本
// 不使用協定，直接透過 Native Host 執行

console.log('[LINE Extension Pro] Popup loaded');

function triggerNativeHost() {
  console.log('[LINE Extension Pro] Sending message to native host...');
  
  // 發送訊息給 Native Host
  chrome.runtime.sendNativeMessage(
    'com.line.opener',
    { action: 'openLINE' },
    function(response) {
      if (chrome.runtime.lastError) {
        console.error('[LINE Extension Pro] Error:', chrome.runtime.lastError.message);
        // 顯示錯誤訊息
        document.querySelector('.title').textContent = '❌ 錯誤';
        document.querySelector('.message').innerHTML = 
          '<strong>Native Host 未安裝</strong><br>' +
          '請執行 install.bat 安裝';
        return;
      }
      
      console.log('[LINE Extension Pro] Response:', response);
      
      if (response && response.success) {
        // 成功，關閉 popup
        setTimeout(() => window.close(), 500);
      } else {
        console.error('[LINE Extension Pro] Failed:', response);
      }
    }
  );
}

// 自動觸發
document.addEventListener('DOMContentLoaded', () => {
  console.log('[LINE Extension Pro] DOM loaded, triggering...');
  triggerNativeHost();
});

// 備用
if (document.readyState === 'complete' || document.readyState === 'interactive') {
  console.log('[LINE Extension Pro] Document ready, triggering immediately...');
  setTimeout(triggerNativeHost, 10);
}
