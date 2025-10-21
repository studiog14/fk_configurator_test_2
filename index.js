// JavaScript-based device detection fallback
// This file can be used as index.js if PHP is not available

(function() {
    'use strict';

    // Mobile device detection
    function detectMobileDevice() {
        const userAgent = navigator.userAgent || '';
        const mobileKeywords = [
            'Mobile', 'Android', 'iPhone', 'iPad', 'iPod', 'BlackBerry',
            'Windows Phone', 'Opera Mini', 'IEMobile', 'webOS'
        ];

        // Check user agent
        for (const keyword of mobileKeywords) {
            if (userAgent.includes(keyword)) {
                return true;
            }
        }

        // Check for touch capability
        if ('ontouchstart' in window || navigator.maxTouchPoints > 0) {
            return true;
        }

        // Check screen size
        if (window.innerWidth <= 1024 && window.innerHeight <= 1366) {
            return true;
        }

        return false;
    }

    // Check URL parameters for forced version
    function getForcedVersion() {
        const urlParams = new URLSearchParams(window.location.search);
        const mobile = urlParams.get('mobile');
        const desktop = urlParams.get('desktop');

        if (mobile === '1') return 'mobile';
        if (desktop === '1') return 'desktop';
        return null;
    }

    // Main detection and redirection logic
    function initializeApp() {
        const forcedVersion = getForcedVersion();
        const isMobile = detectMobileDevice();

        console.log('🔍 Device detection:', {
            userAgent: navigator.userAgent.substring(0, 50),
            screenSize: `${window.innerWidth}x${window.innerHeight}`,
            hasTouch: 'ontouchstart' in window,
            maxTouchPoints: navigator.maxTouchPoints,
            forcedVersion,
            detectedMobile: isMobile
        });

        if (forcedVersion === 'mobile' || (isMobile && !forcedVersion)) {
            // Load mobile version
            loadMobileVersion();
        } else {
            // Load desktop version
            loadDesktopVersion();
        }
    }

    function loadMobileVersion() {
        console.log('📱 Loading mobile version...');

        // Check if mobile file exists
        fetch('index.mobile.html', { method: 'HEAD' })
            .then(response => {
                if (response.ok) {
                    window.location.href = 'index.mobile.html';
                } else {
                    console.warn('Mobile version not found, falling back to desktop');
                    loadDesktopVersion();
                }
            })
            .catch(error => {
                console.error('Error checking mobile version:', error);
                loadDesktopVersion();
            });
    }

    function loadDesktopVersion() {
        console.log('🖥️ Loading desktop version...');

        // Check if desktop file exists
        fetch('index.html', { method: 'HEAD' })
            .then(response => {
                if (response.ok) {
                    window.location.href = 'index.html';
                } else {
                    console.error('Desktop version not found');
                    showErrorMessage();
                }
            })
            .catch(error => {
                console.error('Error checking desktop version:', error);
                showErrorMessage();
            });
    }

    function showErrorMessage() {
        document.body.innerHTML = `
            <div style="display: flex; align-items: center; justify-content: center; height: 100vh; font-family: Arial, sans-serif; text-align: center; padding: 20px;">
                <div>
                    <h1>🚫 Version Not Found</h1>
                    <p>Neither mobile nor desktop version could be loaded.</p>
                    <p>Please check that the following files exist:</p>
                    <ul style="text-align: left; display: inline-block;">
                        <li>index.html (Desktop Version)</li>
                        <li>index.mobile.html (Mobile Version)</li>
                    </ul>
                    <br>
                    <button onclick="window.location.reload()" style="padding: 10px 20px; margin-top: 20px; cursor: pointer;">
                        Retry
                    </button>
                </div>
            </div>
        `;
    }

    // Initialize when DOM is ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeApp);
    } else {
        initializeApp();
    }
})();
