# Vehicle Schedule Feature

## Overview
The Vehicle Schedule feature allows users to view and manage vehicle trip schedules. Users can select dates from a calendar, view upcoming trips for selected dates, and accept or reject trip requests. Additionally, users can add free slots for vehicle availability.

## Features
- **Calendar View**: Interactive calendar for date selection
- **Trip List**: Display trips for selected date with Accept/Reject actions
- **Trip Management**: Accept or reject pending trip requests
- **Free Slot Management**: Add free slots for vehicle availability
- **Status Indicators**: Visual indicators for trip status (Pending, Accepted, Rejected)

## Screens

### 1. Vehicle Schedule Screen
- Calendar component for date selection
- "Upcoming Trips" list for selected date
- Trip cards with Accept/Reject buttons for pending trips
- Floating Action Button to add free slots

### 2. Add Free Slot Screen
- Date picker for selecting slot date
- Time pickers for start and end time
- Optional notes field
- Create button to submit free slot

## Navigation
- **From Dashboard**: "Vehicle Schedule" feature card → Vehicle Schedule Screen
- **From Vehicle Schedule**: Floating Action Button or "+" icon → Add Free Slot Screen

## Trip Status Types
- **Pending**: Trip request awaiting acceptance/rejection
- **Accepted**: Trip request accepted
- **Rejected**: Trip request rejected

## Calendar Features
- Month navigation (previous/next buttons)
- Date selection highlighting
- Today's date highlighting (green circle)
- Selected date highlighting (blue circle)
- Weekend dates in red
- Marked dates for trips (dark blue circles)

