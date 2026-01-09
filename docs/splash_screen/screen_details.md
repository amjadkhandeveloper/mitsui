# Splash Screen - Detailed Specifications

## Screen Information

**Screen Name**: Splash Screen  
**Screen ID**: `splash_screen`  
**Route**: `/` (initial route)  
**Feature Module**: `splash`

## UI Components

### 1. Background
- **Type**: Gradient or Solid Color
- **Color**: [To be updated with design assets]
- **Animation**: Subtle gradient shift (optional)

### 2. Logo/Icon
- **Position**: Center of screen
- **Size**: Responsive (max 200x200)
- **Animation**: 
  - Fade in: 0 → 1 opacity
  - Scale: 0.8 → 1.0
  - Duration: 800ms
  - Curve: Curves.easeOutCubic

### 3. App Name (Optional)
- **Position**: Below logo
- **Animation**: Fade in after logo (delay: 400ms)
- **Typography**: [To be updated]

### 4. Loading Indicator (Conditional)
- **Display**: Only if initialization > 2 seconds
- **Type**: Circular progress indicator or custom loader
- **Position**: Bottom of screen
- **Color**: [To be updated]

## Animations Timeline

```
0ms     → Logo starts fading in and scaling
800ms   → Logo animation completes
1200ms  → App name fades in (if present)
2000ms  → Minimum display time completed
2000ms+ → Navigate based on auth state
```

## Performance Considerations

1. **Image Optimization**: Use optimized logo assets
2. **Animation Performance**: Use Transform and Opacity (GPU accelerated)
3. **Lazy Loading**: Initialize heavy services after navigation
4. **Memory Management**: Dispose animations properly

## Accessibility

- Screen reader: "Loading application"
- High contrast mode support
- Reduced motion support (skip animations)

