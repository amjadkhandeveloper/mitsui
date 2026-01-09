# Splash Screen

## Overview
The Splash Screen is the first screen users see when launching the app. It displays the app logo/branding with smooth animations and handles initial app initialization.

## Screen Details

### Purpose
- Display app branding/logo
- Initialize app dependencies
- Check user authentication status
- Navigate to appropriate screen based on app state

### User Flow
1. App launches → Splash Screen appears
2. Logo animates in (fade + scale)
3. App initializes (check auth, load config, etc.)
4. Navigate to:
   - Home Screen (if authenticated)
   - Login/Onboarding Screen (if not authenticated)

### Duration
- Minimum display time: 2 seconds
- Maximum wait time: 5 seconds (with loading indicator)

## Design Specifications

### Layout
- Full screen background (gradient or solid color)
- Centered logo/icon
- App name/tagline (optional)
- Loading indicator (if initialization takes time)

### Animations
- Logo fade in + scale animation (0.8 → 1.0 scale, 0 → 1 opacity)
- Duration: 800ms
- Curve: Curves.easeOutCubic
- Background gradient animation (optional)

### Colors
- Background: [To be updated with design]
- Logo: [To be updated with design]
- Text: [To be updated with design]

## Technical Implementation

### State Management
- Uses Cubit for state management
- States: Initial, Loading, Authenticated, Unauthenticated, Error

### Dependencies
- Checks authentication status
- Loads app configuration
- Initializes required services

## API Specifications

### No API calls required
The splash screen doesn't make direct API calls. It checks local storage/cache for:
- Authentication token
- User preferences
- App configuration

## Navigation

### Next Screens
- **Authenticated**: Home Screen (`/home`)
- **Unauthenticated**: Login Screen (`/login`) or Onboarding (`/onboarding`)

