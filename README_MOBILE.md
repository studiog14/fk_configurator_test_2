# Mobile Version Implementation

## Overview
This project now includes a complete mobile-optimized version of the chair configurator that automatically detects mobile devices and serves the appropriate interface while maintaining all desktop functionality.

## Files Structure

### Main Files
- `index.php` - PHP-based device detection and redirection
- `index.js` - JavaScript fallback for environments without PHP
- `index.html` - Desktop version (unchanged)
- `index.mobile.html` - Mobile-optimized version

### Mobile-Specific Features
- **Bottom-positioned UI** - Mobile apps style with bottom sidebar
- **Touch-optimized controls** - Larger touch targets
- **Horizontal scrolling** - For categories and models
- **Mobile-first CSS** - Optimized for mobile viewports
- **PWA-ready** - Same PWA functionality as desktop

## Device Detection Logic

### Automatic Detection
The system detects mobile devices using multiple methods:

1. **User Agent Detection** - Checks for mobile keywords
2. **Touch Capability** - Detects touch-enabled devices
3. **Screen Size** - Considers viewport dimensions
4. **Platform Detection** - Identifies iOS, Android, tablets

### Detection Criteria
```javascript
const isMobile = /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ||
                 (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1) ||
                 ('ontouchstart' in window) ||
                 (window.innerWidth <= 1024 && window.innerHeight <= 1366);
```

## How It Works

### 1. PHP Detection (Primary)
When a user visits the site:
1. `index.php` analyzes the User-Agent
2. Detects mobile devices automatically
3. Redirects to appropriate version:
   - Mobile → `index.mobile.html`
   - Desktop → `index.html`

### 2. JavaScript Fallback
If PHP is not available:
1. `index.js` runs device detection
2. Redirects to appropriate version
3. Provides error handling if files are missing

### 3. Manual Override
Users can force specific versions:
- `?mobile=1` - Force mobile version
- `?desktop=1` - Force desktop version

## Mobile UI Features

### Layout Changes
- **Vertical stacking** - App layout optimized for mobile
- **Bottom sidebar** - 140px height at screen bottom
- **Full-screen canvas** - Takes remaining space above sidebar
- **Touch-friendly buttons** - Larger tap targets

### Navigation
- **Horizontal scrolling** for categories and models
- **Bottom-positioned toolbar** for main controls
- **Slide-up config panel** from bottom
- **Centered popups** for better mobile UX

### Optimizations
- **Mobile-specific CSS** - Touch-optimized interactions
- **Viewport height fix** - Handles mobile browser bars
- **Safe area support** - iOS notch and home indicator
- **Reduced animations** - Better performance on mobile

## Same Functionality
The mobile version maintains **100% feature parity** with desktop:

- ✅ Same 3D model loading and rendering
- ✅ Same material system and texture loading
- ✅ Same configuration options
- ✅ Same pricing and order system
- ✅ Same PWA capabilities
- ✅ Same AR functionality (when available)
- ✅ Same data loading from Google Sheets

## Technical Implementation

### Mobile CSS Structure
```css
/* Mobile-first responsive design */
@media (max-width: 1024px) {
  #app {
    flex-direction: column; /* Stack vertically */
  }

  #sidebar {
    position: fixed;
    bottom: 0; /* Bottom positioning */
    height: 140px; /* Fixed height */
  }

  #canvas-container {
    height: calc(100vh - 140px); /* Leave space for sidebar */
  }
}
```

### JavaScript Integration
- Same Three.js and ThreePipe setup
- Mobile-optimized renderer settings
- Touch event handling
- Mobile-specific UI state management

## Usage

### Automatic Usage
1. Users visit the main URL
2. System automatically detects device type
3. Appropriate version loads seamlessly

### Manual Testing
- Desktop: `yoursite.com/index.html`
- Mobile: `yoursite.com/index.mobile.html`
- Force mobile: `yoursite.com/?mobile=1`
- Force desktop: `yoursite.com/?desktop=1`

## Benefits

### For Users
- **Optimal experience** on each device type
- **Same functionality** across all platforms
- **Touch-optimized** mobile interface
- **Fast loading** with device-specific optimizations

### For Development
- **Single codebase** with responsive design
- **Easy maintenance** - one set of business logic
- **Consistent behavior** across platforms
- **Future-proof** - easy to add new features

## Browser Support

### Mobile
- ✅ iOS Safari (iPhone, iPad)
- ✅ Chrome Mobile (Android)
- ✅ Samsung Internet
- ✅ Firefox Mobile
- ✅ Edge Mobile

### Desktop
- ✅ Chrome (Windows, macOS, Linux)
- ✅ Firefox (Windows, macOS, Linux)
- ✅ Safari (macOS)
- ✅ Edge (Windows)

## Performance Optimizations

### Mobile-Specific
- **Reduced render quality** for better performance
- **Optimized texture loading** for mobile bandwidth
- **Touch-specific event handling**
- **Mobile-friendly memory management**

### Shared Optimizations
- **Same data loading** from Google Sheets
- **Same 3D model optimization**
- **Same PWA caching strategies**

## Troubleshooting

### Common Issues

1. **Wrong version loading**
   - Clear browser cache
   - Check User-Agent detection
   - Use manual override parameters

2. **Mobile UI not appearing**
   - Ensure `index.mobile.html` exists
   - Check file permissions
   - Verify PHP/server configuration

3. **Touch interactions not working**
   - Check for JavaScript errors
   - Ensure touch events are properly bound
   - Verify CSS is loading correctly

### Debug Information
Add to URL for debugging:
- `?debug=1` - Enable debug logging
- `?mobile=1` - Force mobile version
- `?desktop=1` - Force desktop version

## Future Enhancements

### Planned Features
- **Gesture controls** for 3D model manipulation
- **Offline mode** improvements
- **Push notifications** for order updates
- **Advanced mobile AR** when WebXR matures

### Easy Extensions
- **Theme switching** (dark/light mode)
- **Language selection** interface
- **Advanced search** with filters
- **Favorites system** for saved configurations

---

## Summary
The mobile implementation provides the **same powerful configurator experience** on mobile devices with an interface optimized for touch interaction and mobile usage patterns, while maintaining complete feature parity with the desktop version.
