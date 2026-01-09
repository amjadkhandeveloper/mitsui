# Login Screen

## Overview
The Login Screen is the authentication entry point for the Fleet Management System. It features a clean design with Mitsui branding and secure login functionality.

## Screen Details

### Purpose
- Authenticate users with username and password
- Display Mitsui & Co. branding
- Provide secure access to the Fleet Management System

### User Flow
1. User enters username and password
2. User taps "Sign In" button
3. System validates credentials
4. On success: Navigate to Home Screen
5. On failure: Display error message

### Design Layout
- **Upper Half**: Blue background with white logo container, "MITSUI & CO." text, and "Fleet Management System" subtitle
- **Lower Half**: White card with rounded top corners containing login form

## Design Specifications

### Colors
- **Background**: Mitsui Blue (#0066CC)
- **Card Background**: White
- **Button**: Dark Blue (#004499)
- **Input Fields**: Light Grey (#F5F5F5)
- **Text**: Black87 for titles, Grey for hints

### Typography
- **Company Name**: 20px, Bold, Black87
- **App Title**: 16px, Medium, White
- **Sign In Title**: 24px, Bold, Black87
- **Input Text**: 16px, Regular
- **Button Text**: 16px, SemiBold, White

### Components
1. **Logo Container**: 100x100 white square with rounded corners (12px radius)
2. **Input Fields**: Rounded (12px), light grey background, no border
3. **Sign In Button**: Full width, rounded (12px), dark blue background
4. **Card**: White with 32px top corner radius

## Technical Implementation

### State Management
- Uses Cubit for state management
- States: Loading, Success, Error

### Features
- Username validation
- Password validation (minimum 6 characters)
- Password visibility toggle
- Error message display
- Loading state during authentication

## API Specifications

See [api_specs.md](./api_specs.md) for detailed API documentation.

## Navigation

### Next Screen
- **On Success**: Home Screen (`/home`)
- **On Error**: Stay on Login Screen with error message

