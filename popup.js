// Popup script - 智能引導系統

console.log('[LINE Extension Pro] Popup loaded');

// 視圖元素
const views = {
    loading: document.getElementById('loadingView'),
    install: document.getElementById('installView'),
    running: document.getElementById('runningView'),
    error: document.getElementById('errorView')
};

// 顯示指定視圖
function showView(viewName) {
    Object.keys(views).forEach(key => {
        views[key].classList.add('hidden');
    });
    if (views[viewName]) {
        views[viewName].classList.remove('hidden');
    }
}

// 檢測 Native Host 是否已安裝
function checkNativeHost() {
    return new Promise((resolve) => {
        console.log('[LINE Extension Pro] Checking Native Host...');
        
        // 設定超時，避免無限等待
        const timeout = setTimeout(() => {
            console.log('[LINE Extension Pro] Native Host check timeout');
            resolve(false);
        }, 3000);
        
        chrome.runtime.sendNativeMessage(
            'com.line.opener',
            { action: 'ping' },
            function(response) {
                clearTimeout(timeout);
                if (chrome.runtime.lastError) {
                    console.log('[LINE Extension Pro] Native Host not found:', chrome.runtime.lastError.message);
                    resolve(false);
                } else {
                    console.log('[LINE Extension Pro] Native Host found:', response);
                    resolve(true);
                }
            }
        );
    });
}

// 觸發 LINE 開啟
function openLINE() {
    console.log('[LINE Extension Pro] Opening LINE...');
    
    chrome.runtime.sendNativeMessage(
        'com.line.opener',
        { action: 'openLINE' },
        function(response) {
            if (chrome.runtime.lastError) {
                console.error('[LINE Extension Pro] Error:', chrome.runtime.lastError.message);
                showError('無法連接 Native Host：' + chrome.runtime.lastError.message);
            } else {
                console.log('[LINE Extension Pro] Response:', response);
                if (response && response.success) {
                    // 成功，等待一下後關閉 popup
                    setTimeout(() => window.close(), 1000);
                } else {
                    showError('執行失敗：' + (response.error || '未知錯誤'));
                }
            }
        }
    );
}

// 顯示錯誤
function showError(message) {
    showView('error');
    document.getElementById('errorMessage').textContent = message;
}

// 顯示安裝引導
function showInstallGuide() {
    showView('install');
    
    // 安裝按鈕 - 開啟一鍵安裝頁面
    const downloadBtn = document.getElementById('downloadBtn');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', (e) => {
            e.preventDefault();
            const installUrl = 'https://jwu0330.github.io/line-pro/install.html';
            chrome.tabs.create({ url: installUrl });
        });
    }
    
    // 重新檢測按鈕
    document.getElementById('recheckBtn').addEventListener('click', async () => {
        const btn = document.getElementById('recheckBtn');
        const originalText = btn.textContent;
        
        // 顯示檢測中
        btn.textContent = '🔄 檢測中...';
        btn.disabled = true;
        
        // 等待一下讓使用者感受到在檢測
        await new Promise(resolve => setTimeout(resolve, 800));
        
        // 重新初始化
        await init();
        
        // 恢復按鈕（如果還在安裝頁面）
        setTimeout(() => {
            btn.textContent = originalText;
            btn.disabled = false;
        }, 100);
    });
}

// 初始化
async function init() {
    console.log('[LINE Extension Pro] Initializing...');
    showView('loading');
    
    // 等待一下讓 UI 顯示
    await new Promise(resolve => setTimeout(resolve, 500));
    
    // 檢測 Native Host
    const isInstalled = await checkNativeHost();
    
    if (isInstalled) {
        // 已安裝，直接執行
        console.log('[LINE Extension Pro] Native Host installed, opening LINE...');
        showView('running');
        openLINE();
    } else {
        // 未安裝，顯示安裝引導
        console.log('[LINE Extension Pro] Native Host not installed, showing install guide...');
        showInstallGuide();
    }
}

// 錯誤重試
document.getElementById('retryBtn')?.addEventListener('click', () => {
    init();
});

// 啟動（避免雙重初始化）
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
} else {
    init();
}
