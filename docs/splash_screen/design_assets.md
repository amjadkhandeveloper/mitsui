# Splash Screen - Design Assets

## Logo/Icon
- **Location**: `assets/images/logo.png` (to be added)
- **Size**: 120x120 (recommended)
- **Format**: PNG with transparency
- **Variants**: 
  - Light mode version
  - Dark mode version (optional)

## Colors

### Light Theme
- **Background Gradient Start**: Primary Container Color
- **Background Gradient End**: Surface Color
- **Logo Background**: Primary Color
- **Logo Icon**: On Primary Color
- **Text Color**: On Surface Color

### Dark Theme
- **Background Gradient Start**: Primary Container Color (dark)
- **Background Gradient End**: Surface Color (dark)
- **Logo Background**: Primary Color
- **Logo Icon**: On Primary Color
- **Text Color**: On Surface Color (dark)

## Typography
- **App Name**: Headline Small, Bold
- **Font Family**: [To be updated with design]

## Spacing
- **Logo Size**: 120x120
- **Logo to App Name**: 24px
- **Loading Indicator Position**: 80px from bottom

## Animation Specifications

### Logo Animation
- **Type**: Fade + Scale
- **Initial Scale**: 0.8
- **Final Scale**: 1.0
- **Initial Opacity**: 0.0
- **Final Opacity**: 1.0
- **Duration**: 800ms
- **Curve**: easeOutCubic

### App Name Animation
- **Type**: Fade
- **Delay**: 400ms after logo starts
- **Duration**: 600ms
- **Curve**: easeOut

## Image Assets Checklist
- [ ] Logo (light mode)
- [ ] Logo (dark mode) - optional
- [ ] App icon (for app launcher)
- [ ] Splash screen background (if custom design)

## Notes
- All images should be optimized for performance
- Use vector graphics (SVG) when possible, convert to PNG for Flutter
- Provide @2x and @3x versions for high-density displays

