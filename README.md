# Fixtura

Fixtura is a Flutter app for organizing local tournaments, leagues, brackets, and roulette-based draft flows. It is built for mobile first, with a polished dark UI, persistent local storage, and a focused set of tournament management tools.

## What It Does

The app supports:

- Creating round-robin leagues and knockout tournaments
- Entering teams and generating fixtures automatically
- Tracking match results and standings for leagues
- Viewing knockout brackets visually
- Running a roulette draft for tournaments and for the standalone quick roulette tool
- Persisting tournaments, teams, matches, and roulette assignments locally with SQLite

## Main Features

### Tournament Dashboard

- Overview of all tournaments
- Counts for active and finished tournaments
- Quick entry to create a tournament or open the standalone roulette tool

### Tournament Creation

- Tournament name and type selection
- Round-robin league support with single or double legs
- Custom points system for wins, draws, and losses
- Knockout bracket generation with automatic BYE handling
- Optional Team Roulette setup with a configurable roulette pool
- Option to keep roulette assignments unique across rounds

### Tournament Details

- Fixture list with round selection
- League standings table
- Knockout bracket board
- Winner banner when a tournament is completed
- Roulette drafting tab when Team Roulette is enabled

### Roulette Drafting

The roulette flow now works by round:

- Round cards are shown under the tournament tabs
- Selecting a round changes the active player and the available roulette teams
- Auto Draft This Round fills the selected round only
- Auto Draft All Rounds fills every round in the tournament
- Reset This Round clears only the selected round
- Reset All Rounds clears the full roulette history
- Team selection is aligned with the top pointer on the wheel

### Standalone Roulette

There is also a separate roulette screen for quick use outside a tournament. It lets you:

- Add custom options manually
- Use quick-add sample options
- Spin the wheel and show a dedicated result dialog

## Tech Stack

- Flutter
- Provider for state management
- SQLite via sqflite for local persistence
- intl for date formatting
- google_fonts for app typography

## Project Structure

- `lib/screens/` - dashboard, tournament creation, tournament details, standalone roulette
- `lib/providers/` - app state and tournament logic
- `lib/models/` - tournament, team, match, and standing models
- `lib/widgets/` - reusable UI components such as the roulette wheel, match cards, and bracket board
- `lib/database/` - SQLite helper and schema management
- `lib/theme/` - shared color and style definitions

## Getting Started

### Prerequisites

- Flutter SDK 3.11 or newer
- Android Studio, VS Code, or Xcode depending on your target platform

### Install Dependencies

```bash
flutter pub get
```

### Run the App

```bash
flutter run
```

To run on a specific device:

```bash
flutter devices
flutter run -d <device_id>
```

## Typical Workflow

1. Open the dashboard.
2. Create a new tournament.
3. Add teams and configure the format.
4. Open the tournament details screen.
5. Use fixtures, standings, bracket, or roulette drafting as needed.
6. Enter match scores and complete the tournament when all matches are finished.

## Notes

- Tournament data is stored locally on the device.
- Roulette assignments are tracked per round when Team Roulette is enabled.
- The standalone roulette tool is separate from tournament drafting and can be used for quick random selection.

## Platform Support

The project includes Android, iOS, web, Windows, macOS, and Linux platform folders. Actual runtime support depends on your Flutter setup and the platform you build for.

## License

No license has been defined yet.
