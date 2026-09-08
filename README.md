# WorkFlow Hub

For Atei DevOps, the system should be designed around three access levels: Employee, Admin/Manager, and Super Admin. The Super Admin should control the entire platform, while managers handle employees and work assignments.

Recommended System Structure

1. Employee Dashboard

The employee dashboard should be simple and mobile-friendly because staff may use it while working in the field.

Dashboard Overview

Show:

Current date and time

Clock-in or clock-out status

Total hours worked today

Current weekly workload

Completed, ongoing, overdue, and pending tasks

Missing daily-log notification

Upcoming deadlines

Recent feedback from managers

Attendance

Employees should be able to:

Clock in once per day

Capture GPS coordinates during clock-in

Record the device and IP address

Clock out at the end of the day

View their attendance history

Submit a reason for a late or missed clock-in

Request correction of an incorrect attendance record

The system should prevent employees from manually changing timestamps or GPS information.

My Weekly Tasks

Each task should display:

Task title

Assigned brand or project

Description

Priority

Start date

Deadline

Estimated hours

Current progress

Manager who assigned it

Required deliverables

Approval status

Recommended statuses:

Not Started

In Progress

Submitted

Revision Requested

Approved

Completed

Overdue

Blocked

Daily Work Log

Employees should be able to add multiple work-log items in one submission.

Each item should include:

Brand or project

Assigned task

Activity performed

Time spent

Progress before and after work

Work description

Challenges encountered

Next action

Completion percentage

Multiple progress photos

File or link attachment

Save as draft

Submit for review

Photo and File Evidence

Support:

Multiple images per task

Image previews

Captions

Automatic compression

Upload date and time

GPS metadata where appropriate

PDFs, documents, videos, and external links

Secure private storage

Offline upload queue

Notifications

Employees should receive alerts for:

Newly assigned tasks

Approaching deadlines

Overdue tasks

Missing daily reports

Manager comments

Revision requests

Approved submissions

Schedule changes

2. Admin or Manager Dashboard

Managers should only access employees, teams, brands, and tasks assigned to their area.

Dashboard Summary

Show:

Employees currently clocked in

Employees who have not clocked in

Missing daily logs

Tasks due today

Overdue tasks

Weekly completion rate

Total hours logged

Pending report approvals

Progress by employee

Progress by brand or project

Task Assignment

Managers should be able to:

Create individual tasks

Assign tasks to one employee

Assign tasks to a team

Create recurring weekly tasks

Select a brand or client project

Add descriptions and checklists

Set priority and deadline

Add expected working hours

Attach reference files

Define required proof

Duplicate previous weekly plans

Reassign or extend a task

Add task dependencies

Progress Monitoring

Useful views include:

Kanban board

Task table

Employee progress view

Brand progress view

Weekly calendar

Deadline timeline

Photo-proof gallery

Approval and Feedback

Managers should be able to:

Approve submitted work

Request revisions

Add comments

Mention employees

Rate the quality of work

Confirm final completion

Reopen completed tasks

Maintain an activity and feedback history

Reports

Allow managers to filter and export by:

Employee

Team

Brand

Task

Status

Date range

Attendance

Completion percentage

Approved or rejected submissions

Export formats:

CSV

Excel

PDF

Reports should include total hours, attendance, completed tasks, overdue work, progress rates, evidence links and manager feedback.

Super Admin Dashboard

The Super Admin dashboard should provide complete visibility and control over the Atei DevOps system.

1. Executive Overview

The top section should contain summary cards for:

Total employees

Active employees

Employees clocked in today

Total brands and projects

Tasks assigned this week

Completed tasks

Overdue tasks

Pending approvals

Missing daily logs

Total hours worked

Storage used

Active system alerts

Recommended charts:

Weekly task-completion trend

Hours worked by employee

Productivity by team

Task status distribution

Performance by brand

Attendance trend

Overdue-task trend

2. Organisation Management

The Super Admin should manage:

Company information

Departments

Teams

Job roles

Reporting hierarchy

Work locations

Working days

Public holidays

Standard working hours

Time zone

Company logo and system branding

3. User and Access Management

Functions should include:

Create, edit, suspend or archive users

Invite users by email

Reset passwords

Assign employees to teams

Assign managers

Create custom roles

Configure permissions

View last login

Force account logout

Activate or deactivate accounts

Suggested roles:

RoleAccessSuper AdminComplete system accessAdminOperational administrationManagerAssigned teams, tasks and reportsSupervisorReview work and attendanceEmployeePersonal tasks and work logsAuditorRead-only reports and activity history

Use granular permissions such as users.create, tasks.assign, logs.approve, reports.export and settings.manage.

4. Brand and Project Management

The Super Admin should be able to:

Create brands and client projects

Upload brand logos

Assign account managers

Add project descriptions

Set start and end dates

Set project status

Add client information

Archive inactive brands

Restrict brand access by team

Monitor hours and tasks per brand

Recommended brand statuses:

Active

On Hold

Completed

Archived

5. Global Task Management

Provide a complete task register where the Super Admin can:

View tasks across every team

Bulk assign tasks

Transfer workloads

Change deadlines

Set priorities

Create task templates

Create recurring tasks

Monitor unassigned work

Identify overloaded employees

Lock approved tasks

Archive old tasks

6. Attendance and Location Controls

Include:

Real-time clock-in monitor

Attendance calendar

Late arrival records

Early clock-out records

Missing clock-outs

Employee working-hours summaries

GPS map view

Approved work locations

Configurable geofence radius

Manual attendance correction

Correction approval history

Location collection must require employee permission and should only occur during check-in, check-out or authorized site-visit reporting.

7. Reports and Analytics

The Super Admin should access:

Company productivity report

Employee performance report

Attendance report

Weekly task report

Brand or client report

Timesheet report

Overdue-task report

Proof-of-work report

Manager approval report

System usage report

Include scheduled reports that can automatically be generated daily, weekly or monthly.

8. Approval Centre

Create one central queue for:

Submitted work

Revision requests

Attendance corrections

Missed clock-in explanations

Overtime requests

Leave requests

Task deadline-extension requests

9. Notification and Reminder Settings

The Super Admin should configure:

Missing-log reminders

Deadline reminders

Overdue alerts

Clock-out reminders

Manager escalation rules

Email notifications

In-app notifications

Optional WhatsApp or SMS notifications

Reminder times and frequency

Avoid sending repeated alerts after a task has already been completed or approved.

10. Audit Logs

Every important action should be recorded:

Who performed the action

Action performed

Previous value

New value

Date and time

IP address

Device details

Audit records should not be editable by ordinary administrators.

11. System Configuration

Include settings for:

Company branding

Work week

Working hours

Time zone

File-size limits

Accepted file formats

Photo-compression quality

GPS requirements

Offline synchronization

Data-retention period

Report templates

Email templates

Task status options

Completion-percentage rules

12. System Health and Storage

The Super Admin should see:

Database status

Storage consumption

Failed uploads

Failed notifications

Offline synchronization errors

Recent application errors

Active user sessions

Backup status

Recommended Database Tables

Your proposed tables are correct, but the complete system will require more supporting tables.

Core tables

users

roles

permissions

role_permissions

teams

team_members

brands

projects

assigned_tasks

task_assignees

task_checklist_items

task_progress_updates

daily_logs

daily_log_items

photos

attachments

attendance_records

task_comments

approvals

notifications

recurring_task_rules

work_locations

audit_logs

system_settings

Important relationships

A brand can contain multiple projects.

A project can contain multiple tasks.

A task can be assigned to one or multiple employees.

An employee can create multiple daily logs.

A daily log can contain multiple log items.

Each log item can reference an assigned task.

Tasks and log items can have multiple photos.

Progress updates should be stored separately rather than overwriting previous progress.

Every approval and revision should retain its full history.

Recommended API Structure

/api/auth
  /login
  /logout
  /forgot-password
  /reset-password
  /session

/api/users
  GET, POST
  /[id]
  /[id]/status
  /[id]/role

/api/teams
  GET, POST
  /[id]
  /[id]/members

/api/brands
  GET, POST
  /[id]
  /[id]/projects

/api/projects
  GET, POST
  /[id]

/api/tasks
  GET, POST
  /[id]
  /[id]/assign
  /[id]/progress
  /[id]/comments
  /[id]/submit
  /[id]/approve
  /[id]/request-revision

/api/daily-logs
  GET, POST
  /[id]
  /[id]/submit
  /[id]/approve

/api/attendance
  /clock-in
  /clock-out
  /today
  /history
  /correction-request

/api/uploads
  /photo
  /attachment
  /signed-url

/api/reports
  /attendance
  /tasks
  /employees
  /brands
  /timesheets
  /export

/api/notifications
  GET
  /[id]/read
  /read-all

/api/admin
  /dashboard
  /audit-logs
  /settings
  /system-health

Recommended Technology Choice

For this project, I recommend:

Next.js with TypeScript

Tailwind CSS and shadcn/ui

Supabase Authentication

PostgreSQL through Supabase

Supabase Storage for photos and attachments

Supabase Realtime for dashboard updates

Row-Level Security for data protection

React Hook Form and Zod for forms

TanStack Query for server data

IndexedDB for offline drafts

Service Worker for offline access

ExcelJS for Excel exports

PDF generation on the server

Vercel for hosting

Supabase is particularly suitable because the system is relational, needs private photo storage, authentication, real-time updates and strict role-based database access.

Important Product Rules

Completion should not automatically mean approval.

Employees should not delete submitted logs.

Approved records should be locked.

Managers should not view teams outside their assigned scope.

Images should be stored privately using temporary signed URLs.

Progress changes should retain historical records.

Offline submissions must have unique IDs to prevent duplicates.

Clock-in records should use server time, not device time.

GPS should include accuracy information.

Account deletion should normally archive the user instead of removing historical reports.

A strong first version should focus on authentication, employee management, brands, weekly task assignment, attendance, daily logs, photo uploads, approvals, notifications and exports. Advanced performance analytics, WhatsApp reminders, geofencing and scheduled reports can follow in the second phase.

This project was built with [Lovable](https://lovable.dev).

## Build with Lovable

Continue developing this project in the [Lovable editor](https://lovable.dev/projects/fe4a0fa6-ac35-4790-a4e7-7a986a4ae73d).

- **Ship faster**: describe what you want to build and Lovable handles the code.
- **Stay in sync**: every change made in Lovable is committed straight to this repository.
- **Full ownership**: this code is yours. Push to `main` on GitHub and your changes sync back into Lovable, ready for your next prompt.

## Development

Prefer working locally? You need Node.js and npm — [install with nvm](https://github.com/nvm-sh/nvm#installing-and-updating).

```sh
git clone <this-repository-url>
cd <repository-name>
npm i
npm run dev
```
