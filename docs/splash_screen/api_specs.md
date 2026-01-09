# Splash Screen - API Specifications

## Overview

The Splash Screen does not make direct API calls. Instead, it performs local checks and initialization.

## Local Storage Checks

### 1. Authentication Token Check
- **Source**: Local storage (SharedPreferences/Hive)
- **Key**: `auth_token` or `access_token`
- **Purpose**: Determine if user is authenticated

**Response Format**:
```json
{
  "token": "string | null",
  "expiresAt": "timestamp | null",
  "refreshToken": "string | null"
}
```

### 2. User Preferences
- **Source**: Local storage
- **Key**: `user_preferences`
- **Purpose**: Load user settings

**Response Format**:
```json
{
  "theme": "light | dark | system",
  "language": "en | ja | ...",
  "notifications": true | false
}
```

### 3. App Configuration
- **Source**: Local storage or remote config
- **Key**: `app_config`
- **Purpose**: Load app settings

**Response Format**:
```json
{
  "version": "1.0.0",
  "minSupportedVersion": "1.0.0",
  "features": {
    "feature1": true,
    "feature2": false
  }
}
```

## Future API Endpoints (If Needed)

### Check App Version
```
GET /api/app/version-check
```

**Request**: None (uses device info)

**Response**:
```json
{
  "currentVersion": "1.0.0",
  "latestVersion": "1.0.1",
  "forceUpdate": false,
  "updateMessage": "New features available"
}
```

### Initialize Session
```
POST /api/auth/init-session
```

**Request**:
```json
{
  "deviceId": "string",
  "deviceType": "ios | android",
  "appVersion": "1.0.0"
}
```

**Response**:
```json
{
  "sessionId": "string",
  "config": {
    "apiUrl": "string",
    "features": {}
  }
}
```

## Error Handling

- **No Internet**: Show cached data, proceed with offline mode
- **Token Expired**: Navigate to login screen
- **Config Error**: Use default configuration
- **Timeout**: Navigate after 5 seconds maximum

