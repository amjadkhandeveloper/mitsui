# Leave Application Feature

## Overview
The Leave Application feature allows users to apply for leave requests and manage their leave status. Admin/Expat users can approve or reject leave requests based on availability.

## Features
- **Apply Leave**: Submit leave requests with start/end dates and times
- **Leave List**: View all leave requests with status indicators
- **Status Management**: Admin/Expat users can approve or reject leave requests
- **Role-based Access**: 
  - **Driver**: Can view and apply for their own leave requests
  - **Expat/Admin**: Can view all leave requests and approve/reject them

## Screens

### 1. Apply Leave Screen
- Form to submit new leave requests
- Leave Period section (Start Date, End Date)
- Leave Time section (Start Time, End Time)
- Cancel and Save buttons
- Validation for date/time ranges

### 2. Leave List Screen
- List of all leave requests
- Status indicators (Pending, Approved, Rejected)
- Add button to create new leave request
- Admin actions (Approve/Reject) for pending requests
- Pull-to-refresh functionality

## Navigation
- **From Dashboard**: Quick Action "Apply Leave" button → Leave List Screen
- **From Leave List**: Floating Action Button or "+" icon → Apply Leave Screen

## Status Types
- **Pending**: Leave request submitted, awaiting approval
- **Approved**: Leave request approved by admin/expat
- **Rejected**: Leave request rejected by admin/expat

## User Roles
- **Driver**: 
  - Can apply for leave
  - Can view only their own leave requests
- **Expat/Admin**: 
  - Can view all leave requests
  - Can approve or reject leave requests
  - Can add rejection notes

