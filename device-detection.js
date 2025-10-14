// Device detection and mobile redirection system
(function() {
    'use strict';

    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initDeviceDetection);
    } else {
        initDeviceDetection();
    }

    function initDeviceDetection() {
        console.log('🔄 Device detection starting...');

        detectDeviceAndRedirect();

        // Re-check on resize/orientation change
        window.addEventListener('resize', () => {
            setTimeout(detectDeviceAndRedirect, 500);
        });
        window.addEventListener('orientationchange', () => {
            setTimeout(detectDeviceAndRedirect, 500);
        });
    }

    function detectDeviceAndRedirect() {
        try {
            // Skip detection if explicitly requested via URL parameter
            const urlParams = new URLSearchParams(window.location.search);
            if (urlParams.get('skip_detection') === '1') {
                console.log('🔄 Device detection skipped per URL parameter');
                return;
            }

            // Get current page filename
            const currentPath = window.location.pathname;
            const currentFile = currentPath.substring(currentPath.lastIndexOf('/') + 1);

            console.log('🔄 Current page:', currentFile);

            // Enhanced device detection
            const detection = detectDevice();
            console.log('🔄 Device detection result:', detection);

            // Redirect logic
            if (detection.isMobile) {
                // Mobile device detected
                if (currentFile === 'index.html') {
                    console.log('🔄 Mobile device detected, redirecting from index.html');

                    // Try to redirect to mobile version
                    // First try iOS test page, fall back to simple mobile
                    redirectToMobile();
                }
                // No action needed if already on mobile page
            } else if (detection.isDesktop) {
                // Desktop device
                if (currentFile.includes('mobile')) {
                    console.log('🔄 Desktop device detected on mobile page, offering return');
                    // Show a message but don't force redirect (user may want to stay)
                    showDesktopOnMobileMessage();
                }
            }

        } catch (error) {
            console.error('🔄 Device detection failed:', error);
        }
    }

    function detectDevice() {
        const ua = navigator.userAgent || '';
        const platform = navigator.platform || '';
        const maxTouchPoints = navigator.maxTouchPoints || 0;

        // Mobile detection logic
        const isMobileUA = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua);
        const isMobilePlatform = platform === 'MacIntel' && maxTouchPoints > 1; // iPad OS
        const hasTouch = maxTouchPoints > 0 || 'ontouchstart' in window;
        const isNarrowScreen = window.innerWidth <= 820;

        // Additional checks
        const isiOS = /iPhone|iPad|iPod|M iPad|M iPhone/.test(ua) || (platform === 'MacIntel' && maxTouchPoints > 1);
        const isiPhoneXR = isiOS && ((/XR/i.test(ua) || /iPhone\s+9,3/i.test(ua)) ||
                                    (window.screen.width === 828 || window.innerWidth === 896));
        const isAndroid = /Android/i.test(ua);

        return {
            isMobile: isMobileUA || isMobilePlatform || hasTouch || isNarrowScreen,
            isDesktop: !isMobileUA && !isMobilePlatform && !hasTouch && !isNarrowScreen,
            isiOS,
            isiPhoneXR,
            isAndroid,
            userAgent: ua.substring(0, 50),
            platform,
            maxTouchPoints,
            screenWidth: window.innerWidth,
            screenHeight: window.innerHeight
        };
    }

    function redirectToMobile() {
        // No more redirections - all devices use the same index.html file
        // Mobile adaptations are handled by CSS media queries and mobile-specific logic
        console.log('🔄 No redirection - all devices use unified index.html with mobile adaptations');
        return;
    }

    function showDesktopOnMobileMessage() {
        // Create a message for desktop users on mobile-page
        try {
            let messageDiv = document.getElementById('desktop-message');
            if (!messageDiv) {
                messageDiv = document.createElement('div');
                messageDiv.id = 'desktop-message';
                messageDiv.style.cssText = `
                    position: fixed;
                    top: 20px;
                    left: 20px;
                    right: 20px;
                    background: #2196F3;
                    color: white;
                    padding: 15px;
                    border-radius: 8px;
                    font-family: Arial, sans-serif;
                    z-index: 1000;
                    box-shadow: 0 4px 15px rgba(0,0,0,0.3);
                    text-align: center;
                `;

                messageDiv.innerHTML = `
                    <strong>Komputer wykryty</strong><br>
                    Wydajesz się korzystać z komputera. <a href="index.html" style="color: white; text-decoration: underline;">Przejdź do wersji desktopowej</a> dla pełnego doświadczenia z 3D.
                    <button onclick="this.parentElement.remove()" style="margin-left: 10px; background: transparent; border: 1px solid white; color: white; padding: 5px; border-radius: 3px; cursor: pointer;">×</button>
                `;

                document.body.appendChild(messageDiv);

                // Auto-hide after 10 seconds
                setTimeout(() => {
                    if (messageDiv && messageDiv.parentElement) {
                        messageDiv.remove();
                    }
                }, 10000);
            }
        } catch (error) {
            console.error('Failed to show desktop message:', error);
        }
    }

    // Expose detection function globally for debug/testing
    window.detectDevice = detectDevice;
})();
