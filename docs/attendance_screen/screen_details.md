# Attendance Screen - Screen Details

## Screen Layout

### App Bar
- **Title**: "Attendance Sheet"
- **Background**: Mitsui Blue (`AppTheme.mitsuiBlue`)
- **Actions**: Statistics icon (bar chart) - for future statistics view
- **Back Button**: Standard Material back button

### Main Content

#### 1. Today's Attendance Card (Expat View Only)
- **Position**: Top of screen, below app bar
- **Design**: Blue gradient card with white icon and text
- **Icon**: Receipt/document icon
- **Text**: "Today's Attendance"
- **Action**: Tappable (future: navigate to today's detail view)

#### 2. Driver Dropdown (Expat View Only)
- **Position**: Below "Today's Attendance" card
- **Design**: Styled card with dropdown
- **Options**: 
  - "All Drivers" (shows all attendance records)
  - Individual driver names (filters by selected driver)
- **Behavior**: Selecting a driver loads their attendance records

#### 3. Attendance List Header
- **Columns**: 
  - Date (100px width)
  - Name (flexible width)
  - Present (60px width, centered)
- **Style**: Grey background with border bottom

#### 4. Attendance List Items
- **Date Format**: DD-MMM-YYYY (e.g., "01-Aug-2025")
- **Name Display**: 
  - Colored dot indicator (green for present, red for absent)
  - Driver name
- **Status Icon**: 
  - Green circle with white checkmark for "Present"
  - Red circle with white X for "Absent"
- **Animation**: Fade and slide animation with staggered delays

### Empty State
- **Icon**: Event busy icon (64px, grey)
- **Message**: "No attendance records found"

## States

### Loading State
- Shows circular progress indicator centered on screen

### Error State
- Shows toast error message
- User can retry by selecting a different driver (expat) or refreshing

### Loaded State
- Shows attendance list with all records
- For expat: Shows selected driver or all drivers based on dropdown selection
- For driver: Shows only their own records

## Animations
- **Today's Attendance Card**: Fade slide animation (200ms delay)
- **Driver Dropdown**: Fade slide animation (300ms delay)
- **List Items**: Fade slide animation with staggered delays (400ms + index * 50ms)

## Color Scheme
- **Present Status**: Green (`Colors.green`)
- **Absent Status**: Red (`Colors.red`)
- **Background**: White
- **Text**: Dark grey/black (`onSurface`)
- **Card Background**: White with shadow
- **Gradient**: Primary blue gradient for "Today's Attendance" card

