# Dashboard Screen

## Overview
The Dashboard Screen is the main landing page after user login. It displays user profile information, quick actions, and a grid of additional features for the Fleet Management System.

## Screen Details

### Purpose
- Display user welcome information
- Provide quick access to common actions (Check In, Apply Leave)
- Show available features in an organized grid layout
- Enable navigation to various system modules

### User Flow
1. User logs in successfully
2. Dashboard screen loads with user information
3. User can:
   - Check in/Apply leave via quick actions
   - Navigate to features via feature cards
   - Logout via header icon

### Design Layout

#### Header
- Dark blue background (`mitsuiDarkBlue`)
- "Dashboard" title in white
- Logout icon on the right

#### User Profile Card
- Blue gradient background (primary → secondary)
- White circular profile icon
- User name in uppercase (large, white, bold)
- "Welcome" subtitle (smaller, white)

#### Quick Actions Section
- Section heading: "Quick Actions"
- Two horizontal buttons:
  - **Check In**: Green background, white text, login icon
  - **Apply Leave**: White background, blue border, calendar icon

#### Additional Features Section
- Section heading: "Additional Features"
- 2-column grid layout
- Feature cards with:
  - Blue circular icon background
  - Feature icon (white)
  - Feature title (dark grey)
  - Feature subtitle (lighter grey)

### Features List
1. **Vehicle Schedule** - View calendar
2. **Driver Attendance** - View details
3. **Trips** - Create or manage trip
4. **Add Free Slot** - Schedule time
5. **Trip History** - View history
6. **Reports** - View reports

## Technical Implementation

### State Management
- Uses Cubit for state management
- States: Loading, Loaded with user data and features

### Components
- `UserProfileCard`: Displays user information
- `QuickActionButton`: Reusable button for quick actions
- `FeatureCard`: Grid item for features
- `StyledCard`: Base card widget with consistent styling

### Animations
- User profile card: Fade + Slide animation
- Quick action buttons: Staggered fade + slide
- Feature cards: Staggered fade + slide (500ms + index * 100ms delay)

## API Specifications

### Get User Profile
```
GET /api/user/profile
```

**Response**:
```json
{
  "id": "string",
  "username": "string",
  "name": "string",
  "email": "string",
  "avatar": "string | null"
}
```

### Get Dashboard Features
```
GET /api/dashboard/features
```

**Response**:
```json
{
  "features": [
    {
      "id": "string",
      "title": "string",
      "subtitle": "string",
      "icon": "string",
      "route": "string",
      "enabled": true
    }
  ]
}
```

## Navigation

### From Dashboard
- **Check In**: Navigate to check-in screen
- **Apply Leave**: Navigate to leave application screen
- **Feature Cards**: Navigate to respective feature screens
- **Logout**: Navigate to login screen

### To Dashboard
- **From Login**: After successful authentication
- **From Splash**: If user is already authenticated

