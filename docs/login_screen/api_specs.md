# Login Screen - API Specifications

## Authentication Endpoint

### Login
**Endpoint**: `POST /auth/login`

**Request Headers**:
```
Content-Type: application/json
```

**Request Body**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Success Response** (200 OK):
```json
{
  "id": "string",
  "username": "string",
  "email": "string",
  "token": "string",
  "refresh_token": "string",
  "role": "driver" | "expat",
  "name": "string"
}
```

**Error Responses**:

**400 Bad Request** - Validation Error:
```json
{
  "message": "Username and password are required"
}
```

**401 Unauthorized** - Invalid Credentials:
```json
{
  "message": "Invalid username or password"
}
```

**500 Internal Server Error**:
```json
{
  "message": "An error occurred while processing your request"
}
```

## Data Models

### User
```json
{
  "id": "string",                    // Unique user ID
  "username": "string",              // Username for login
  "email": "string",                 // User email address
  "token": "string",                 // JWT authentication token
  "refresh_token": "string",        // Refresh token for token renewal
  "role": "driver" | "expat",       // User role
  "name": "string"                   // User full name
}
```

## Token Storage

After successful login:
- **auth_token**: Stored in SharedPreferences
- **refresh_token**: Stored in SharedPreferences (if provided)
- **user_data**: Complete user object stored as JSON (including role and name)

## Error Handling

### Network Errors
- Connection timeout: "Connection timeout. Please check your internet."
- Network error: "Network error occurred"

### Server Errors
- 400-499: Display server error message
- 500+: Display generic error message

### Validation Errors
- Empty username: "Please enter your username"
- Empty password: "Please enter your password"
- Short password: "Password must be at least 6 characters"

## Role Values
- **"driver"**: Regular driver user
- **"expat"**: Admin/expat user with elevated permissions

## Security Considerations

1. **Password**: Never logged or stored in plain text
2. **Token**: Stored securely in SharedPreferences
3. **HTTPS**: All API calls should use HTTPS
4. **Token Expiry**: Handle token expiration gracefully
5. **Role-based Access**: Backend should validate user role for protected endpoints

