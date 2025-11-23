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

// 取得 Extension ID
function getExtensionId() {
    return chrome.runtime.id;
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
    
    // 顯示 Extension ID
    const extId = getExtensionId();
    document.getElementById('extensionId').textContent = extId;
    
    // 安裝按鈕 - 開啟一鍵安裝頁面並傳遞 Extension ID
    const downloadBtn = document.getElementById('downloadBtn');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', (e) => {
            e.preventDefault();
            const installUrl = `https://jwu0330.github.io/line-pro/install.html?id=${extId}`;
            chrome.tabs.create({ url: installUrl });
            
            // 記住使用者已經看過安裝頁面
            chrome.storage.local.set({ 'hasSeenInstallPage': true });
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
        // 檢查是否已經看過安裝頁面
        const result = await chrome.storage.local.get(['hasSeenInstallPage']);
        
        if (result.hasSeenInstallPage) {
            // 已經看過安裝頁面但還沒安裝，顯示錯誤
            console.log('[LINE Extension Pro] Native Host not installed after seeing install page');
            showError('請先完成 Native Host 安裝，然後點擊「重新檢測」');
        } else {
            // 第一次使用，顯示安裝引導
            console.log('[LINE Extension Pro] First time, showing install guide...');
            showInstallGuide();
        }
    }
}

// 錯誤重試
document.getElementById('retryBtn')?.addEventListener('click', () => {
    init();
});

// 啟動
document.addEventListener('DOMContentLoaded', () => {
    init();
});

// 備用啟動
if (document.readyState === 'complete' || document.readyState === 'interactive') {
    setTimeout(init, 10);
}
