# Attendance Report Feature

## Overview
The Attendance Report feature provides a comprehensive monthly view of attendance statistics and daily records. Users can filter by driver and month to view detailed attendance reports.

## Features
- **Monthly Filter**: Select month and year for report
- **Driver Filter**: Filter reports by specific driver or view all drivers
- **Summary Statistics**: 6 key metrics displayed in cards:
  - Total Days
  - Present Days
  - Absent Days
  - Leave Days
  - Attendance Rate (%)
  - Total Hours
- **Daily Records**: Detailed list of daily attendance with:
  - Date
  - Status (Present/Absent)
  - Check In time
  - Check Out time
  - Total Hours
  - Overtime hours

## Screen Layout

### Header Section
- Blue gradient card with "Monthly Attendance Report" title
- Driver dropdown filter (All Drivers or specific driver)
- Month picker filter (shows current month by default)

### Summary Statistics Section
- Grid layout (3 columns, 2 rows)
- 6 statistic cards with icons and values
- Color-coded icons:
  - Blue: Total Days, Attendance Rate
  - Green: Present, Total Hours
  - Red: Absent
  - Orange: Leave

### Daily Attendance Records Section
- Section header with calendar icon and record count
- List of daily records with:
  - Date display
  - Status badge (Present/Absent)
  - 4 detail cards for present days:
    - Check In (green)
    - Check Out (orange)
    - Total Hours (blue)
    - Overtime (orange)

## Navigation
- **From Dashboard**: "Reports" feature card → Attendance Report Screen

## Data Display
- **Date Format**: DD-MMM-YYYY (e.g., "01-Aug-2025")
- **Time Format**: hh:mm AM/PM (e.g., "09:00 AM")
- **Duration Format**: Xh Ym (e.g., "9h 0m", "62h 15m")
- **Percentage Format**: X.X% (e.g., "70.0%")

