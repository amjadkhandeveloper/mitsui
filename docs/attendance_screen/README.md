# Attendance Screen

## Overview
The Attendance Screen displays daily check-in/check-out records for drivers. The screen behavior differs based on user role:
- **Expat Users**: Can select a driver from a dropdown to view their attendance records
- **Driver Users**: Directly view their own attendance records

## Features
- View attendance records with date, driver name, and present/absent status
- Driver selection dropdown for expat users
- "Today's Attendance" card for quick access
- Statistics icon in app bar (for future statistics view)
- Animated list items with fade and slide effects
- Color-coded status indicators (green for present, red for absent)

## Navigation
- Accessed from Dashboard → "Driver Attendance" feature card
- Requires current user to be passed as route argument

## User Roles
- **Expat**: Can view attendance for all drivers or filter by specific driver
- **Driver**: Can only view their own attendance records

