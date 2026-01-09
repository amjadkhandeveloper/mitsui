# Animations and Gradients Guide

## Overview
This document describes the standard animations and gradient utilities implemented across all screens in the Mitsui Fleet Management System app.

## Gradient Utilities

### Location
`lib/core/utils/gradients.dart`

### Available Gradients

#### 1. Primary Blue Gradient
```dart
AppGradients.primaryBlueGradient
```
- **Usage**: Main background gradient for screens
- **Colors**: Mitsui Blue → Dark Blue
- **Direction**: Top-left to bottom-right
- **Used in**: Splash Screen, Login Screen background

#### 2. Button Gradient
```dart
AppGradients.buttonGradient
```
- **Usage**: Primary action buttons
- **Colors**: Dark Blue → Mitsui Blue
- **Direction**: Top-left to bottom-right
- **Used in**: Sign In button, primary CTAs

#### 3. Subtle Blue Gradient
```dart
AppGradients.subtleBlueGradient
```
- **Usage**: Subtle background variations
- **Colors**: 90% opacity Blue → Full Blue
- **Direction**: Top to bottom

#### 4. Light Blue Gradient
```dart
AppGradients.lightBlueGradient
```
- **Usage**: Light backgrounds
- **Colors**: Light Blue → White
- **Direction**: Top-left to bottom-right

## Animation Utilities

### Location
`lib/core/utils/animations.dart`

### Standard Durations
- **Fast**: 200ms
- **Normal**: 300ms
- **Slow**: 500ms
- **Very Slow**: 800ms

### Standard Curves
- **Standard**: `Curves.easeOutCubic`
- **Smooth**: `Curves.easeInOut`
- **Bounce**: `Curves.elasticOut`
- **Sharp**: `Curves.easeIn`

### Available Animation Widgets

#### 1. FadeInAnimation
Fades in a widget from transparent to opaque.

```dart
FadeInAnimation(
  duration: AnimationDurations.normal,
  delay: Duration(milliseconds: 200),
  child: YourWidget(),
)
```

**Usage**: Text, icons, simple elements

#### 2. SlideInAnimation
Slides in a widget from a specified direction with fade.

```dart
SlideInAnimation(
  duration: AnimationDurations.slow,
  delay: Duration(milliseconds: 300),
  direction: AxisDirection.down, // up, down, left, right
  beginOffset: Offset(0, 0.3),
  child: YourWidget(),
)
```

**Usage**: Cards, containers, complex widgets

#### 3. ScaleInAnimation
Scales a widget from smaller to full size with fade.

```dart
ScaleInAnimation(
  duration: AnimationDurations.slow,
  delay: Duration(milliseconds: 200),
  beginScale: 0.8,
  child: YourWidget(),
)
```

**Usage**: Logos, icons, important visual elements

#### 4. FadeSlideAnimation
Combines fade and slide for smooth entry.

```dart
FadeSlideAnimation(
  duration: AnimationDurations.slow,
  delay: Duration(milliseconds: 300),
  beginOffset: Offset(0, 0.2),
  child: YourWidget(),
)
```

**Usage**: Form cards, content sections

## Implementation Examples

### Splash Screen
- **Background**: Primary Blue Gradient
- **Logo**: ScaleInAnimation (0.8 → 1.0 scale)
- **Text**: FadeInAnimation with staggered delays

### Login Screen
- **Background**: Primary Blue Gradient
- **Logo**: ScaleInAnimation with shadow
- **Company Name**: FadeInAnimation (400ms delay)
- **App Title**: FadeInAnimation (600ms delay)
- **Login Card**: FadeSlideAnimation (slides up from bottom)
- **Input Fields**: FadeSlideAnimation (slides from left)
- **Button**: FadeSlideAnimation with gradient background

## Best Practices

1. **Stagger Animations**: Use delays to create a cascading effect
2. **Keep It Subtle**: Animations should enhance, not distract
3. **Performance**: Use GPU-accelerated widgets (Transform, Opacity)
4. **Consistency**: Use standard durations and curves across screens
5. **Accessibility**: Respect reduced motion preferences

## Animation Timeline Example (Login Screen)

```
0ms     → Logo starts scaling in
200ms   → Logo animation completes
400ms   → Company name fades in
600ms   → App title fades in
300ms   → Login card starts sliding up
500ms   → "Sign In" title fades in
600ms   → Username field slides in
700ms   → Password field slides in
800ms   → Sign In button slides in
```

## Performance Considerations

- All animations use `RepaintBoundary` where appropriate
- Controllers are properly disposed
- Animations are GPU-accelerated (Transform, Opacity)
- No unnecessary rebuilds during animations

## Future Enhancements

- Page transition animations
- Micro-interactions (button press, hover)
- Loading state animations
- Success/error state animations

