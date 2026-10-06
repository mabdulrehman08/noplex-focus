# Find Your Now

**Why this exists:** an iOS role at a startup like NoPlex calls for understanding why a person cannot start a task, not simply making a prettier list. This small SwiftUI slice explores three ADHD-related friction points: time feeling abstract, too many choices blocking action, and an intrusive thought pulling someone away from what they were doing. It demonstrates product judgment through the interaction model, backed by separated models, view models, views, and persistence.

Inspired by NoPlex’s “The Chaos Management App” framing. This is an independent demo, with no NoPlex integration or affiliation. The behavior is a product hypothesis, not a clinically validated intervention.

## One screen, three decisions

| Friction | Design choice | Intended benefit |
| --- | --- | --- |
| Time blindness | A real-world anchor says **“In 45 min”**, alongside clock time and five-minute marks. | Make distance to the next commitment visible. |
| Task paralysis | **Now / Next** exposes only two tasks. “Now” includes a concrete first action and a small starting window. | Reduce the decisions required to begin. |
| Overwhelm and interruption | An always-visible capture field saves a typed thought with one tap, without changing focus. Sorting stays in a separate sheet. | Let someone park a thought without planning it immediately. |
| Pressure from a timer | Pause, extend by two minutes, or finish early. Expiry asks a gentle question and never auto-completes a task. | Support agency instead of turning a time box into a deadline. |

The starting task is “Send the project update”; its first step is “Open the draft. Write just the first sentence.” The sample appointment is 45 minutes from first launch. The anchor can be edited to fit a real day.

## Run on a Mac

1. Open `NoPlexFocus.xcodeproj` in Xcode 15 or newer.
2. Select the shared **NoPlexFocus** scheme and an iOS 17+ simulator.
3. Run with **⌘R**. There are no packages, credentials, or setup steps.
4. Run the included XCTest target with **⌘U**. For a physical device, choose your own signing team in the app target.

**Build limitation:** this project was written in a Linux environment with no Xcode, Apple SDKs, or Swift compiler. It has **not been compiled, run in a simulator, or tested with XCTest here**. The Xcode project, shared scheme, app source, assets, and test source are included; macOS build and device validation are still required. Linux validation checks project references, source inclusion, asset JSON, scheme XML, and whitespace only. It does not establish that the Swift code compiles.

```sh
python3 scripts/check_project.py
git diff --check
```

On macOS, a command-line build can use a destination available on your machine:

```sh
xcodebuild -list -project NoPlexFocus.xcodeproj
xcodebuild test -project NoPlexFocus.xcodeproj -scheme NoPlexFocus \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

## A 90-second product walkthrough

- Start the ten-minute window. Only the first step, remaining time, and next task are visible.
- Type “Buy groceries” in the capture bar and tap **+**. The timer and current task stay in place.
- Pause, leave the app, and return: paused time stays frozen. Resume and the clock continues from the remaining time.
- Open **Parked thoughts** and choose **Make this Next**. It becomes the next five-minute starting point, preserving Now. Swipe to remove a thought you no longer need.
- Tap **Done for now** to reveal Next, or **Try another** to move Now to the back of the queue without losing it.
- Edit the time anchor to one minute ago and start a fresh task: the anchor says it is here. For timer expiry, let a session finish; it stays on the task and offers **+2 min**.

## Architecture and boundaries

`FocusState` contains the queue, parked thoughts, anchor, and session timestamps. `FocusViewModel` owns all transitions on the main actor. An injected `FocusStore` keeps persistence separate; the app stores a small Codable snapshot in local UserDefaults, and tests use an in-memory store. SwiftUI views render that state and forward user actions.

`TimelineView` refreshes the display; the timer derives remaining time from an absolute end date rather than decrementing a counter. Backgrounding or relaunching therefore does not lose elapsed time. Pausing persists a duration instead. A clock adjustment on the device can affect an active session; this demo uses wall time rather than a monotonic clock.

The six XCTest cases cover relaunch timing, pause/resume, extending an expired window, capture without focus interruption, completion, and deferral. They are supplied but unexecuted here. On a Mac, also check VoiceOver, accessibility text sizes, keyboard capture, and background/foreground behavior on a device. The UI uses semantic fonts, scrolling cards, labeled controls, and a text equivalent for the anchor visualization. The demo deliberately uses a light palette; dark mode has not been designed.

There are no accounts, network calls, notification permissions, analytics, recurring tasks, or app-store packaging. Nudges appear in the foreground only; a session expiring while the app is closed does not send a notification. Local data persists across launches; delete the app to restore the seed scenario. The sample anchor also persists, so an old commitment remains visible until edited.

Before widening the feature set, I would test one question with users: **does a concrete first step plus a small time window help them begin with less effort?** Useful signals would be time to first start, whether capture preserves focus, and how much pressure the timer feels like. More completed tasks alone would not answer that question.
