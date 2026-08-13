# Dreaming — Product Build Specification

Build a production-quality Flutter application called **Dreaming**.

The application is a private dream-memory journal. Its purpose is simple: allow a user to record dreams over time and visually see their dream-recording history through a GitHub-style yearly heatmap.

The application must target **Flutter Web and Flutter Mobile** from the same codebase.

## 1. Product concept

The core experience is:

1. User opens Dreaming.
2. User sees a GitHub-style yearly calendar heatmap.
3. Each day is represented by a square.
4. An empty square means the user recorded no dreams that day.
5. A filled square means at least one dream exists for that day.
6. Clicking/tapping a day shows a quick preview of that day's dreams.
7. The user can then open the day and see all dreams recorded on that date.
8. The user can create multiple dreams for the same day.
9. Each dream contains:
   - Title
   - Dream text
   - Emoji-based mood
   - Tags
   - Exact date and time
10. The user can edit, duplicate, or delete dreams.
11. The user can search and filter their entire dream collection.
12. The user can export their data as JSON or CSV.

The application does **not** require an account, authentication, backend, cloud synchronization, or AI.

All data must remain on the user's device.

## 2. Important privacy requirement

This is a local-first application.

Do NOT introduce:

- Firebase
- Supabase
- A custom backend
- User accounts
- Authentication
- Cloud databases
- Analytics that transmit dream content
- External APIs for storing dreams

Dream content is private personal data and should remain local.

The architecture should make it obvious that the application works completely offline.

## 3. Target platforms

Use one Flutter codebase supporting:

- Android
- iOS
- Web

Do not create separate implementations unless platform-specific behavior genuinely requires them.

The UI must adapt properly to:

- Mobile portrait
- Mobile landscape
- Desktop web
- Smaller browser windows
- Large desktop screens

Do not simply stretch the mobile UI across desktop.

## 4. Main screen

The primary screen should make the yearly heatmap the visual centerpiece.

Suggested structure:

- App title / branding
- Current year
- Year navigation
- GitHub-style yearly heatmap
- Basic statistics
- Primary "Add Dream" action

The agent has freedom to decide the exact visual design.

The design should feel:

- Minimal
- Calm
- Personal
- Modern
- Slightly dreamy
- Not childish
- Not overloaded with gradients or decorative elements

The GitHub contribution graph should remain the main visual metaphor.

## 5. Yearly heatmap

Implement a GitHub-style yearly contribution heatmap.

The heatmap must represent an entire year.

Each cell represents one calendar day.

Behavior:

- No dreams = empty/inactive cell.
- One or more dreams = active cell.
- Intensity does NOT represent the number of dreams.
- There should be no distinction between 1 dream and 10 dreams in cell intensity.
- The heatmap is therefore a binary presence visualization.

Use an appropriate calendar layout where weekdays form rows and weeks form columns, similar to GitHub's contribution graph.

Account for:

- Leap years
- Different month lengths
- First/last partial weeks
- Correct weekday alignment
- Current date
- Historical years
- Future dates

Future dates should not incorrectly appear as recorded activity.

Allow the user to navigate between years.

## 6. Day interaction

When the user taps/clicks a heatmap cell:

Do not immediately throw them into a large editor.

First show a **quick preview**.

The preview should communicate:

- Date
- Number of dreams
- Dream titles
- Mood indicators
- Relevant short information

Example:

```text
August 12, 2026

3 dreams

🌙 Flying over the ocean
😨 The endless hallway
😊 A strange reunion

[View all]
[Add dream]
```

The user can then open the complete day view.

On desktop, this could be implemented as a popover, dialog, side panel, or similar interaction.

On mobile, a bottom sheet or modal is appropriate.

The implementation should use responsive UX rather than forcing one interaction pattern on every platform.

## 7. Day view

The day view displays every dream recorded on the selected date.

Multiple dreams per day are explicitly supported.

Each dream should show at minimum:

- Time
- Title
- Mood
- Tags
- Dream text preview

The user should be able to open a dream for the complete content.

Provide obvious actions:

- Edit
- Duplicate
- Delete

Provide an "Add Dream" action directly from the day view.

## 8. Dream data model

Create a clean domain model.

Conceptually:

```text
Dream
├── id
├── title
├── content
├── mood
├── tags[]
├── createdAt
└── dreamDateTime
```

Use a stable unique identifier for each dream.

`dreamDateTime` represents when the dream occurred/was recorded according to the application's chosen UX.

The exact time must be preserved.

Do not use the title as an identifier.

Do not rely on list position as an identifier.

Use proper serialization/deserialization.

## 9. Dream creation

Create a dedicated dream editor.

Required fields:

### Title

Short text input.

### Dream

Large multiline text editor.

The dream text is the primary content and should receive most of the editor's visual space.

### Mood

Use an emoji-based mood selector.

The agent should choose a sensible predefined collection of moods.

For example:

```text
😊 Happy
😌 Peaceful
😨 Scary
😢 Sad
🤩 Exciting
😕 Strange
😐 Neutral
❤️ Emotional
```

The exact final set can be chosen by the agent.

The selection must be visually obvious and easy to change.

### Tags

Allow users to add multiple tags.

Examples:

```text
lucid
school
family
flying
nightmare
ocean
```

Tags should be reusable rather than requiring users to recreate identical tags manually every time.

### Date and time

Allow the user to specify the exact date and time.

Default to a sensible current date/time but allow complete editing.

## 10. Multiple dreams on the same day

A day may contain any number of dreams.

Do not overwrite an existing dream when another dream is created on the same date.

For example:

```text
August 12

06:40 — Flying
08:15 — Strange House
09:02 — Ocean
```

All three must remain independent records.

The user must be able to sort the dreams.

Supported sorting behavior should allow the user to switch between sensible chronological orders, such as:

- Newest first
- Oldest first

Structure the implementation so additional sorting options could be added later without rewriting the day-view logic.

## 11. Search

Implement global dream search.

Search must be capable of matching:

- Title
- Dream text
- Tags
- Mood
- All searchable fields

Partial text matching should work.

Search should update results without requiring a backend.

Searching `ocean` should find dreams containing "ocean" in:

- Title
- Content
- Tags

The UI should make it clear why a result matched when practical.

## 12. Filtering

Provide useful filters alongside search.

At minimum support filtering by:

- Mood
- Tags
- Date/date range

Filters should be composable where reasonable.

For example:

```text
Search: ocean
Mood: 😌
Tag: lucid
Date: 2026
```

should return only matching dreams.

Avoid creating an unnecessarily complicated filtering system.

The goal is fast retrieval of old dream memories.

## 13. Duplicate dream

Implement a duplicate action.

Duplicating a dream should create a new independent dream with a new ID.

Do not accidentally overwrite the original.

Decide on sensible default behavior for the duplicated timestamp, but make the behavior obvious to the user.

## 14. Delete dream

Deletion must require appropriate confirmation because dream entries are personal memories.

Example:

```text
Delete dream?

This dream will be permanently removed from this device.

[Cancel] [Delete]
```

Do not provide a fake "delete" that only hides the item from the UI.

The underlying local record must actually be removed.

## 15. Local persistence

Choose an appropriate Flutter local-storage solution.

Requirements:

- Works on mobile.
- Works on web.
- Supports structured records.
- Supports serialization.
- Supports reliable reads/writes.
- Does not require a server.

Keep persistence behind a repository/storage abstraction.

For example:

```text
UI
 ↓
Application / Services
 ↓
DreamRepository
 ↓
LocalStorage
```

Do not allow widgets to directly manipulate the database/storage layer.

This will make future migration to another persistence mechanism easier.

## 16. State management

Choose a modern, maintainable Flutter state-management approach.

The agent may choose the framework/library, but the choice should be justified in the project documentation.

Avoid unnecessary global mutable state.

Separate:

- UI state
- Domain state
- Persistence
- Business logic

The heatmap should derive its state from the dream repository rather than maintaining a second independent copy of the dream data.

## 17. Heatmap architecture

Do not hard-code heatmap cells.

Create a reusable calendar/heatmap model that converts dream records into daily activity.

Conceptually:

```text
Dream records
      ↓
Group by calendar date
      ↓
Map date → hasDream
      ↓
Generate year calendar
      ↓
Render cells
```

For every date:

```text
hasDream = dreamsForDate.isNotEmpty
```

The heatmap should update automatically after:

- Creating a dream
- Editing a dream
- Deleting a dream
- Duplicating a dream

If a dream is moved to another date by editing its date/time, both affected heatmap cells must update correctly.

## 18. Statistics

Add lightweight statistics that make the journal more interesting without turning the application into a data-analysis dashboard.

Potential statistics:

- Dreams recorded this year
- Days with dreams
- Current recording streak
- Longest recording streak

The agent may choose the final set and presentation.

Do not make statistics more prominent than the heatmap.

## 19. Export

Implement two export formats.

### JSON

Export all dream data in a structured format that can later be imported by a future version.

Include:

- ID
- Title
- Content
- Mood
- Tags
- Date/time
- Any other required metadata

The exported JSON should be human-readable.

### CSV

Export dreams as tabular data.

Suggested columns:

```text
id
title
content
mood
tags
date
time
createdAt
```

Handle commas, quotes, newlines, Unicode, and other CSV edge cases correctly.

Do not manually concatenate CSV strings without escaping fields correctly.

On mobile and web, use appropriate platform-specific file/share/download behavior.

## 20. Import architecture

Import is not required for V1.

However, structure the JSON format and persistence layer so that importing a previous export could be added later without redesigning the entire application.

Document this as a future feature rather than implementing it unnecessarily.

## 21. Empty states

Design proper empty states.

First launch should not look broken.

Example:

```text
No dreams recorded yet.

Your dream history will appear here.

[Record your first dream]
```

If a year has no dreams:

```text
No dreams recorded in 2024.
```

Search with no results:

```text
No dreams found.
Try another search or remove a filter.
```

## 22. Responsive design

Desktop web should use available horizontal space intelligently.

Mobile should prioritize the heatmap and primary actions.

Do not allow the heatmap to become unusably tiny.

For narrow screens, horizontal scrolling of the heatmap is acceptable if necessary.

## 23. Navigation

Keep navigation simple.

Potential primary destinations:

- Home / Heatmap
- Search
- Settings

Do not create unnecessary screens.

The main journey should remain:

```text
Heatmap
   ↓
Day preview
   ↓
Day details
   ↓
Dream
   ↓
Edit
```

Adding a dream should always be easy from multiple appropriate locations.

## 24. Settings

Keep settings minimal.

Possible settings:

- Theme
- Year/start-of-week preference if useful
- Export data
- Storage information
- About

Do not add accounts, synchronization, or unnecessary configuration.

The agent may choose the exact settings based on UX quality.

## 25. Visual design

The user gives the agent freedom to choose the final visual direction.

The design should satisfy:

- Minimal
- Calm
- Modern
- Personal
- Slightly dreamy
- Strong readability
- Excellent typography
- Good spacing
- Clear hierarchy
- Accessible contrast
- Tasteful animation

Avoid:

- Excessive gradients
- Generic AI-dashboard aesthetics
- Excessive glassmorphism
- Huge decorative illustrations
- Overly colorful interfaces
- Gamification that distracts from remembering dreams

The heatmap should visually communicate history and consistency.

## 26. Animation

Use subtle animation where it improves feedback.

Good examples:

- Heatmap cell interaction
- Opening day preview
- Opening dream details
- Adding/removing a dream
- Page transitions

Do not animate everything.

Animations must not interfere with accessibility or performance.

## 27. Accessibility

Support:

- Keyboard navigation on web
- Semantic labels
- Sufficient contrast
- Screen-reader-friendly interactive controls
- Visible focus states
- Reasonable touch targets on mobile

Heatmap cells must have accessible labels.

For example:

```text
August 12, 2026 — 3 dreams recorded
```

rather than exposing an unlabeled colored square.

## 28. Performance

The app should remain responsive with a large dream history.

Assume a user could eventually have:

- Thousands of dreams
- Many tags
- Multiple dreams every day
- Several years of history

Avoid rebuilding the entire application unnecessarily when one dream changes.

Search/filter operations should be efficient enough for normal personal-journal-scale data.

## 29. Error handling

Handle:

- Storage failure
- Export failure
- Invalid data
- Corrupted records
- Missing fields from older data versions

Do not crash the application because one local record is malformed.

Use user-friendly error messages.

Do not expose raw stack traces to users.

## 30. Data migration

Add a persistence/data schema version.

For example:

```text
schemaVersion: 1
```

This is important because the application is local-only. If the data model changes in future releases, existing users must not lose their dreams.

Document how future migrations should be implemented.

## 31. Testing

Write meaningful tests.

### Unit tests

Test:

- Dream serialization
- Dream deserialization
- Date grouping
- Heatmap generation
- Leap years
- Year boundaries
- Search
- Tag filtering
- Mood filtering
- Combined filtering
- Sorting
- Duplicate behavior
- Delete behavior
- Statistics
- JSON export
- CSV escaping

### Widget tests

Test:

- Empty state
- Heatmap rendering
- Day preview
- Dream creation
- Dream editing
- Delete confirmation
- Search results
- Filters

### Integration tests

Test the core workflow:

```text
Create dream
→ Persist
→ Restart/load
→ Dream exists
→ Heatmap contains that date
→ Open day
→ View dream
→ Edit
→ Delete
```

## 32. Project structure

Use a clean architecture appropriate for a medium-sized Flutter application.

A reasonable structure could resemble:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router/
│   └── theme/
│
├── core/
│   ├── errors/
│   ├── utils/
│   └── constants/
│
├── features/
│   ├── dreams/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── heatmap/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── search/
│   │   └── presentation/
│   │
│   ├── export/
│   │   └── data/
│   │
│   └── settings/
│
└── main.dart
```

Adjust this structure if another organization is clearly better.

The important requirement is separation of responsibilities.

## 33. Development workflow

Do not attempt to implement the entire product blindly in one giant change.

Work in phases.

### Phase 1 — Foundation

- Initialize Flutter project.
- Configure platforms.
- Set up architecture.
- Add dependencies.
- Set up theme.
- Set up local persistence abstraction.
- Create Dream model.
- Add tests.

### Phase 2 — Dream CRUD

Implement:

- Create
- Read
- Edit
- Delete
- Duplicate
- Multiple dreams per day
- Date/time

Make persistence reliable before proceeding.

### Phase 3 — Heatmap

Implement:

- Year calendar generation
- Day cells
- Presence state
- Year navigation
- Correct date handling
- Responsive layout

### Phase 4 — Day preview and day view

Implement:

- Cell interaction
- Quick preview
- Complete day view
- Multiple dreams
- Sorting

### Phase 5 — Search and filters

Implement:

- Search
- Tags
- Mood
- Date filters
- Combined filters

### Phase 6 — Export

Implement:

- JSON export
- CSV export
- Platform-specific download/share behavior

### Phase 7 — Polish

Improve:

- Responsive design
- Accessibility
- Empty states
- Animations
- Error states
- Performance
- Visual consistency

### Phase 8 — Testing and release readiness

Run:

```text
flutter analyze
flutter test
```

Also test the web and mobile builds manually.

Fix all analyzer errors and test failures before considering the project complete.

## 34. Definition of done

The product is complete only when a user can perform this entire workflow successfully:

```text
Open Dreaming
      ↓
See yearly heatmap
      ↓
Tap a day
      ↓
See quick preview
      ↓
Open day
      ↓
Create multiple dreams
      ↓
Assign title
      ↓
Write dream
      ↓
Select emoji mood
      ↓
Add tags
      ↓
Set exact date/time
      ↓
Save
      ↓
Heatmap updates
      ↓
Search for the dream
      ↓
Filter it
      ↓
Edit it
      ↓
Duplicate it
      ↓
Delete the duplicate
      ↓
Export all dreams as JSON
      ↓
Export all dreams as CSV
```

All data must survive application restarts.

No backend or account should be required.

## 35. Agent behavior

Act as a senior Flutter engineer and product designer.

Before implementing:

1. Inspect the repository.
2. Determine whether an existing Flutter project already exists.
3. Inspect the current architecture.
4. Reuse existing infrastructure where appropriate.
5. Do not overwrite unrelated user work.
6. Produce a concise implementation plan.
7. Identify architectural risks.
8. Then implement incrementally.

During implementation:

- Keep changes small enough to review.
- Run tests frequently.
- Run static analysis frequently.
- Do not leave TODO placeholders for core functionality.
- Do not implement fake functionality.
- Do not use mock data as a substitute for persistence.
- Do not create a backend.
- Do not add authentication.
- Do not add AI.
- Do not add unnecessary dependencies.
- Prefer simple, maintainable solutions.

When a design decision is unspecified, choose the option that best supports:

**privacy → simplicity → maintainability → UX quality → performance.**

When implementation is complete, provide:

1. What was built.
2. Architecture summary.
3. Important dependencies.
4. Storage implementation.
5. Tests written.
6. Commands used to verify the project.
7. Known limitations.
8. Suggested future improvements.

The final implementation should feel like a real small product, not a tutorial project or a collection of screens.
