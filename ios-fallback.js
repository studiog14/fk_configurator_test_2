// Mobile fallback system: activate mobile mode within index.html for better responsiveness
(function () {
  'use strict';
  try {
    var w = (typeof window !== 'undefined') ? window : null;
    if (!w) return;

    // Helpers once
    const defineOnce = (name, fn) => {
      if (typeof w[name] !== 'function') {
        Object.defineProperty(w, name, { value: fn, configurable: true, enumerable: false, writable: true });
      }
    };
    defineOnce('tryAlternativeLoad', function () {});
    defineOnce('openWebVersion', function () {});
    defineOnce('installPWA', function () {});
    defineOnce('showInstallInstructions', function () {});
    defineOnce('continueToApp', function () {});
    defineOnce('tryAutoInstall', function () {});

    // Detection: mobile device - FIXED iOS DETECTION
    var isMobileDevice = false;
    var isIOS = false;
    try {
      var ua = navigator.userAgent || '';
      var platform = navigator.platform || '';

      // FIXED: Better iOS detection including iPhone XR and simulators
      var isIOS_OnMacIntel = platform === 'MacIntel' && navigator.maxTouchPoints > 1 && (/iPhone|iPad|iPod/i.test(ua) || /Mobile/i.test(ua));
      var isIOS_UA = /iPhone|iPad|iPod/i.test(ua) && /Mobile/i.test(ua);

      isIOS = isIOS_UA || (/iPhone|iPad|iPod|M iPad|M iPhone/.test(ua)) || (platform === 'MacIntel' && navigator.maxTouchPoints > 1);

      var isAndroid = /Android/i.test(ua);
      var isMobileUA = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ua) ||
                      (platform==='MacIntel' && navigator.maxTouchPoints>1);
      var hasTouch = 'ontouchstart' in window || navigator.maxTouchPoints > 0;
      var isNarrow = window.innerWidth <= 820;

      // 🔥 FORCE FALLBACK FOR TESTING: Check URL parameters
      var forceFallback = /[?&]fallback=1/.test(window.location.search) || /[?&]iosfallback=1/.test(window.location.search);
      var forceIOS = /[?&]ios=1/.test(window.location.search) || /[?&]iphone=1/.test(window.location.search);

      isMobileDevice = isMobileUA || hasTouch || isNarrow || forceFallback || isIOS;

      console.log('📱 Mobile detection results:', {
        userAgent: ua.substring(0, 100),
        isIOS,
        isAndroid,
        isMobileUA,
        hasTouch,
        isNarrow,
        forceFallback,
        forceIOS,
        finalIsMobileDevice: isMobileDevice,
        screenWidth: window.innerWidth,
        screenHeight: window.innerHeight
      });
    } catch (_) { isMobileDevice = false; }

    // Detection: native import map support
    var importMapSupported = false;
    try {
      importMapSupported = (typeof HTMLScriptElement !== 'undefined') &&
        (typeof HTMLScriptElement.supports === 'function') &&
        HTMLScriptElement.supports('importmap');

      // 🔥 FORCE NO IMPORT MAPS FOR TESTING
      var forceNoImportMaps = /[?&]noimportmaps=1/.test(window.location.search);
      if (forceNoImportMaps) {
        importMapSupported = false;
        console.log('🔧 Forcing no import map support for testing');
      }
    } catch (_) { importMapSupported = false; }

    // If mobile device detected, force mobile mode
    if (isMobileDevice) {
      try {
        document.body.classList.add('mobile-mode');
        console.log('📱 iOS Fallback: Mobile device detected, activated mobile mode');
      } catch (_) {
        console.log('📱 iOS Fallback: Could not add mobile-mode class');
      }
    }

    // If import maps not supported on mobile, show warning but don't redirect
    if (!importMapSupported && isMobileDevice && (isIOS || window.innerWidth <= 820)) {
      console.log('📱 iOS Fallback: Import maps not supported on mobile device');
      console.log('📱 iOS Fallback: Using fallback rendering mode');

      // Add fallback class for additional mobile adaptations
      try {
        document.body.classList.add('mobile-fallback');
      } catch (_) {}

      // 🔥 CREATE COMPLETE FALLBACK UI FOR iOS - ONLY ON ACTUAL MOBILE DEVICES
      if (isIOS && !importMapSupported && window.innerWidth <= 820) {
        console.log('📱 iOS Fallback: Creating complete fallback UI for iOS');

        // Create fallback UI container - ONLY for mobile testing
        const fallbackContainer = document.createElement('div');
        fallbackContainer.id = 'ios-fallback-ui';
        fallbackContainer.style.cssText = `
          position: fixed;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          background: linear-gradient(135deg, #f8f9fa 0%, #e3f2fd 100%);
          z-index: 9999;
          display: flex;
          flex-direction: column;
          font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
          overflow-y: auto;
        `;

        // HIDE NORMAL SIDEBAR when fallback is active to prevent conflicts
        const normalSidebar = document.getElementById('sidebar');
        if (normalSidebar) {
          normalSidebar.style.display = 'none';
          console.log('📱 Hid normal sidebar to prevent layout conflicts');
        }

        // Create header with logo and title
        const header = document.createElement('div');
        header.style.cssText = `
          padding: 20px;
          text-align: center;
          background: rgba(255, 255, 255, 0.95);
          backdrop-filter: blur(10px);
          border-bottom: 1px solid rgba(0, 0, 0, 0.1);
        `;

        const logo = document.createElement('img');
        logo.src = 'icons/FK_logo.png';
        logo.alt = 'Fajne Krzesła';
        logo.style.cssText = 'width: 80px; height: auto; margin-bottom: 15px; border-radius: 8px;';

        const title = document.createElement('h1');
        title.textContent = 'Konfigurator Krzeseł';
        title.style.cssText = 'margin: 0; font-size: 24px; font-weight: 600; color: #333;';

        const subtitle = document.createElement('p');
        subtitle.textContent = 'Wybierz swoje idealne krzesło';
        subtitle.style.cssText = 'margin: 8px 0 0 0; font-size: 16px; color: #666;';

        header.appendChild(logo);
        header.appendChild(title);
        header.appendChild(subtitle);

        // Create main content area
        const mainContent = document.createElement('div');
        mainContent.style.cssText = `
          flex: 1;
          padding: 20px;
          display: flex;
          flex-direction: column;
          gap: 20px;
        `;

        // Categories section
        const categoriesSection = document.createElement('div');
        categoriesSection.innerHTML = `
          <h3 style="margin: 0 0 15px 0; font-size: 18px; color: #333; text-align: center;">Kategorie:</h3>
          <div id="fallback-categories" style="display: flex; flex-wrap: wrap; gap: 12px; justify-content: center;">
            <button class="fallback-category-btn active" data-category="Wszystkie" style="
              background: linear-gradient(135deg, #F5C842, #E5B432);
              color: white;
              border: none;
              border-radius: 12px;
              padding: 12px 20px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 4px 15px rgba(245, 200, 66, 0.4);
            ">Wszystkie</button>
            <button class="fallback-category-btn" data-category="Krzesła" style="
              background: white;
              color: #333;
              border: 2px solid #F5C842;
              border-radius: 12px;
              padding: 12px 20px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
            ">Krzesła</button>
            <button class="fallback-category-btn" data-category="Fotele" style="
              background: white;
              color: #333;
              border: 2px solid #F5C842;
              border-radius: 12px;
              padding: 12px 20px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
            ">Fotele</button>
            <button class="fallback-category-btn" data-category="Hokery" style="
              background: white;
              color: #333;
              border: 2px solid #F5C842;
              border-radius: 12px;
              padding: 12px 20px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
            ">Hokery</button>
          </div>
        `;

        // Models grid
        const modelsSection = document.createElement('div');
        modelsSection.innerHTML = `
          <h3 style="margin: 0 0 15px 0; font-size: 18px; color: #333; text-align: center;">Wybierz model:</h3>
          <div id="fallback-models" style="
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(140px, 1fr));
            gap: 15px;
            max-height: 60vh;
            overflow-y: auto;
            padding: 10px;
          "></div>
        `;

        // Add responsive CSS for mobile vs desktop
        const responsiveCSS = document.createElement('style');
        responsiveCSS.id = 'fallback-responsive-styles';
        responsiveCSS.textContent = `
          /* Desktop styles (default) */
          #ios-fallback-ui #fallback-models {
            grid-template-columns: repeat(3, 1fr) !important;
            gap: 20px !important;
          }

          #ios-fallback-ui .model-element {
            padding: 20px !important;
          }

          #ios-fallback-ui .model-element img {
            width: 120px !important;
            height: 120px !important;
          }

          #ios-fallback-ui .fallback-category-btn {
            padding: 12px 24px !important;
            font-size: 16px !important;
            min-width: 120px !important;
          }

          /* Mobile styles */
          @media (max-width: 820px) {
            #ios-fallback-ui #fallback-models {
              grid-template-columns: repeat(2, 1fr) !important;
              gap: 15px !important;
            }

            #ios-fallback-ui .model-element {
              padding: 15px !important;
            }

            #ios-fallback-ui .model-element img {
              width: 80px !important;
              height: 80px !important;
            }

            #ios-fallback-ui .fallback-category-btn {
              padding: 10px 16px !important;
              font-size: 14px !important;
              min-width: 100px !important;
            }

            #ios-fallback-ui h1 {
              font-size: 20px !important;
            }

            #ios-fallback-ui h3 {
              font-size: 16px !important;
            }
          }
        `;

        // Remove existing responsive styles if present
        const existingResponsiveCSS = document.getElementById('fallback-responsive-styles');
        if (existingResponsiveCSS) {
          existingResponsiveCSS.remove();
        }

        document.head.appendChild(responsiveCSS);

        // PWA Install section
        const pwaSection = document.createElement('div');
        pwaSection.innerHTML = `
          <div style="text-align: center; margin-top: 20px; padding: 20px; background: rgba(245, 200, 66, 0.1); border-radius: 12px; border: 1px solid #F5C842;">
            <h4 style="margin: 0 0 15px 0; color: #333;">📱 Zainstaluj aplikację</h4>
            <p style="margin: 0 0 15px 0; font-size: 14px; color: #666;">
              Dla najlepszego doświadczenia zainstaluj aplikację na swoim urządzeniu
            </p>
            <button id="fallback-install-pwa" style="
              background: linear-gradient(135deg, #4CAF50, #45a049);
              color: white;
              border: none;
              border-radius: 12px;
              padding: 12px 24px;
              font-size: 14px;
              font-weight: 600;
              cursor: pointer;
              transition: all 0.3s ease;
              box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
            ">Zainstaluj aplikację</button>
          </div>
        `;

        mainContent.appendChild(categoriesSection);
        mainContent.appendChild(modelsSection);
        mainContent.appendChild(pwaSection);

        fallbackContainer.appendChild(header);
        fallbackContainer.appendChild(mainContent);

        // Add to DOM
        document.body.appendChild(fallbackContainer);

        // Add event listeners for category buttons
        const categoryButtons = fallbackContainer.querySelectorAll('.fallback-category-btn');
        categoryButtons.forEach(button => {
          button.addEventListener('click', () => {
            // Update active state
            categoryButtons.forEach(btn => {
              btn.classList.remove('active');
              btn.style.background = 'white';
              btn.style.color = '#333';
            });
            button.classList.add('active');
            button.style.background = 'linear-gradient(135deg, #F5C842, #E5B432)';
            button.style.color = 'white';

            // Load models for category
            loadFallbackModels(button.dataset.category);
          });
        });

        // PWA Install button
        const installButton = fallbackContainer.querySelector('#fallback-install-pwa');
        installButton.addEventListener('click', () => {
          if (typeof showInstallInstructions === 'function') {
            showInstallInstructions();
          } else {
            alert('Aby zainstalować aplikację, użyj przycisku "Udostępnij" w Safari i wybierz "Dodaj do ekranu początkowego"');
          }
        });

        // Load initial models
        loadFallbackModels('Wszystkie');

        console.log('📱 iOS Fallback: Complete fallback UI created successfully');
      }
    }

    // Log detection results for debugging
    if (typeof console !== 'undefined') {
      console.log('📱 iOS Fallback: Detection results:', {
        isMobileDevice,
        importMapSupported,
        userAgent: navigator.userAgent.substring(0, 50),
        screenWidth: window.innerWidth,
        hasTouch: 'ontouchstart' in window || navigator.maxTouchPoints > 0
      });
    }
  } catch (_) {
    // swallow errors
  }
})();

// Function to load fallback models
function loadFallbackModels(category) {
  console.log('📱 Loading fallback models for category:', category);

  const modelsContainer = document.getElementById('fallback-models');
  if (!modelsContainer) {
    console.error('📱 Fallback models container not found');
    return;
  }

  modelsContainer.innerHTML = '<div style="text-align: center; padding: 40px; color: #666;">Ładowanie modeli...</div>';

  // Simulate loading models (replace with actual data loading)
  setTimeout(() => {
    // This would normally load from your data source
    // For now, show a sample of available models
    const sampleModels = [
      { Nazwa: 'Tulla', Kategoria: 'Krzesła', Obrazek: 'icons/chair_icon.png', Cena: '450' },
      { Nazwa: 'Soul', Kategoria: 'Krzesła', Obrazek: 'icons/chair_icon.png', Cena: '520' },
      { Nazwa: 'Fargo', Kategoria: 'Krzesła', Obrazek: 'icons/chair_icon.png', Cena: '380' }
    ];

    const filteredModels = category === 'Wszystkie'
      ? sampleModels
      : sampleModels.filter(model => model.Kategoria === category);

    modelsContainer.innerHTML = '';

    filteredModels.forEach(model => {
      const modelElement = document.createElement('div');
      modelElement.className = 'model-element';
      modelElement.style.cssText = `
        background: white;
        border-radius: 12px;
        padding: 20px;
        text-align: center;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
        cursor: pointer;
        transition: all 0.3s ease;
      `;

      modelElement.innerHTML = `
        <img src="${model.Obrazek}" alt="${model.Nazwa}" style="width: 120px; height: 120px; object-fit: cover; border-radius: 8px; margin-bottom: 10px;">
        <div style="font-size: 16px; font-weight: 600; color: #333; margin-bottom: 5px;">${model.Nazwa}</div>
        <div style="font-size: 14px; color: #F5C842; font-weight: bold;">${model.Cena} zł</div>
      `;

      modelElement.addEventListener('click', () => {
        console.log('📱 Fallback model selected:', model.Nazwa);
        // Here you would normally load the model
        alert(`Wybrano model: ${model.Nazwa}\nCena: ${model.Cena} zł\n\nFunkcjonalność konfiguratora zostanie uruchomiona po pełnej implementacji.`);
      });

      modelElement.addEventListener('mouseenter', () => {
        modelElement.style.transform = 'translateY(-2px)';
        modelElement.style.boxShadow = '0 6px 20px rgba(0, 0, 0, 0.15)';
      });

      modelElement.addEventListener('mouseleave', () => {
        modelElement.style.transform = 'translateY(0)';
        modelElement.style.boxShadow = '0 4px 15px rgba(0, 0, 0, 0.1)';
      });

      modelsContainer.appendChild(modelElement);
    });

    console.log('📱 Fallback models loaded:', filteredModels.length);
  }, 1000);
}
