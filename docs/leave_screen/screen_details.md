# Leave Application - Screen Details

## Apply Leave Screen

### App Bar
- **Title**: "Apply Leave"
- **Background**: Mitsui Dark Blue (`AppTheme.mitsuiDarkBlue`)
- **Back Button**: Standard Material back button

### Main Content

#### 1. Leave Application Header Card
- **Position**: Top of screen, below app bar
- **Design**: Blue gradient card with rounded corners
- **Icon**: Calendar outline icon (white, 64x64 circle background)
- **Title**: "Leave Application" (white, bold, 24px)
- **Subtitle**: "Submit your leave request" (white, 14px)
- **Animation**: Fade slide animation (100ms delay)

#### 2. Leave Period Section
- **Heading**: "Leave Period" (bold, dark grey, 18px)
- **Start Date Field**:
  - Calendar icon on left
  - Placeholder: "Start Date*"
  - Opens date picker on tap
  - Displays selected date in DD-MMM-YYYY format
- **End Date Field**:
  - Calendar icon on left
  - Placeholder: "End Date*"
  - Opens date picker on tap
  - Validates that end date is after start date
- **Animation**: Fade slide animation (200ms delay)

#### 3. Leave Time Section
- **Heading**: "Leave Time" (bold, dark grey, 18px)
- **Start Time Field**:
  - Clock icon on left
  - Placeholder: "Start Time*"
  - Opens time picker on tap
  - Displays selected time in hh:mm AM/PM format
- **End Time Field**:
  - Clock icon on left
  - Placeholder: "End Time*"
  - Opens time picker on tap
  - Validates that end time is after start time
- **Animation**: Fade slide animation (300ms delay)

#### 4. Action Buttons
- **Cancel Button**:
  - Left side, outlined style
  - White background with grey border
  - Grey text
  - Closes screen without saving
- **Save Button**:
  - Right side, elevated style
  - Green background (`Colors.green.shade600`)
  - White text
  - Disabled if form is invalid or submitting
  - Shows loading indicator when submitting
- **Animation**: Fade slide animation (400ms delay)

### Validation
- All fields are required (marked with *)
- End date must be after start date
- End time must be after start time
- Shows error toast if validation fails

---

## Leave List Screen

### App Bar
- **Title**: "Leave Requests"
- **Background**: Mitsui Dark Blue (`AppTheme.mitsuiDarkBlue`)
- **Actions**: 
  - "+" icon button (top right) → Navigate to Apply Leave Screen
- **Back Button**: Standard Material back button

### Floating Action Button
- **Icon**: Plus icon
- **Label**: "Apply Leave"
- **Color**: Mitsui Blue (`AppTheme.mitsuiBlue`)
- **Action**: Navigate to Apply Leave Screen

### Main Content

#### Leave Request List Items
Each item displays:
- **User Name**: Driver name (bold, 16px)
- **Date Range**: Start date - End date (grey, 14px)
- **Time Range**: Start time - End time (light grey, 12px)
- **Status Badge**: 
  - Pending: Orange badge with pending icon
  - Approved: Green badge with check icon
  - Rejected: Red badge with cancel icon
- **Reason** (if provided): Grey background box with note icon
- **Admin Note** (if provided): Blue background box with admin icon
- **Admin Actions** (for pending requests):
  - Approve button (green outline)
  - Reject button (red outline)
  - Opens dialog for status update

#### Empty State
- **Icon**: Event busy icon (64px, grey)
- **Message**: "No leave requests found"
- **Subtitle**: "Tap the + button to apply for leave"

### Admin Actions

#### Approve Dialog
- **Title**: "Approve Leave Request"
- **Content**: 
  - User name
  - Date range
  - Approve button (green)
- **Action**: Updates status to Approved

#### Reject Dialog
- **Title**: "Reject Leave Request"
- **Content**: 
  - User name
  - Date range
  - Reason text field (optional)
  - Reject button (red)
- **Action**: Updates status to Rejected with optional note

### Pull-to-Refresh
- Swipe down to refresh leave requests list
- Reloads data from API

## Color Scheme
- **Pending Status**: Orange (`Colors.orange`)
- **Approved Status**: Green (`Colors.green`)
- **Rejected Status**: Red (`Colors.red`)
- **Background**: Light grey (`Colors.grey.shade50`)
- **Card Background**: White with shadow
- **Primary Button**: Green (`Colors.green.shade600`)
- **Cancel Button**: White with grey border

## Animations
- **Header Card**: Fade slide animation (100ms delay)
- **Form Sections**: Fade slide animation with staggered delays
- **List Items**: Fade slide animation with staggered delays (200ms + index * 50ms)

