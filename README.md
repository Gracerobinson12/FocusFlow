# FocusFlow

## App Concept
FocusFlow is a study session tracker that helps students stay focused and accountable. It combines a Pomodoro-style countdown timer with a session log and statistics dashboard so you can see exactly how long you study, on what subjects, and how consistently.

## Platform
iOS — built with SwiftUI. No external dependencies or API keys required.

## Main Features
- **Focus Timer** — pick a subject, describe your task, choose a duration (15/25/30/45/60 min), and start an animated countdown ring
- **Pause & Resume** — pause mid-session and pick back up anytime
- **Post-session notes** — add a reflection note when a session completes
- **Session History** — searchable, filterable list of all past sessions with swipe-to-delete
- **Session Detail & Edit** — view, edit, or delete any saved session
- **Stats Dashboard** — total focus time, day streak, session count, average session length, top subject, bar chart by subject, and completion rate
- **JSON Persistence** — all data saves to the device and survives app restarts

## Platform
iOS — SwiftUI. No external dependencies or API keys required.

## Setup Instructions
1. Open Xcode → File ▸ New ▸ Project → iOS → App
2. Name it FocusFlow, Interface: SwiftUI, Language: Swift
3. Add all source files from this repo into matching groups (Models, Services, Views, Views/Components)
4. Check Target Membership for each file in the File Inspector
5. No external packages or Firebase setup needed

## How to Run
1. Select any iPhone simulator in Xcode
2. Press Cmd+R to build and run
3. Pick a subject chip, enter a task, choose a duration, tap Start Focusing
4. After a session, check the History and Stats tabs

## File Structure
FocusFlow/
├── FocusFlowApp.swift
├── ContentView.swift
├── Models/
│ └── Models.swift
├── Services/
│ ├── SessionStore.swift
│ └── TimerService.swift
└── Views/
├── TimerView.swift
├── HistoryView.swift
├── StatsView.swift
├── SessionDetailView.swift
└── Components/
├── TimerRing.swift
├── StatCard.swift
├── SessionRow.swift
└── EmptyStateView.swift


## Requirements Coverage
- Original SwiftUI app solving a practical problem
- Multiple screens: Timer, History, Stats tabs + Detail + Edit screens
- User input: subject picker, task text, duration buttons, post-session notes, edit form
- State management: @StateObject, @EnvironmentObject, @Published
- JSON persistence to Documents directory — survives app restarts
- Filterable, searchable history list with detail screens
- Edit and delete sessions
- Stats dashboard with totals, streak, bar chart, completion rate
- Empty states on all three tabs, form validation, error handling
- Reusable components: TimerRing, StatCard, SessionRow, EmptyStateView
