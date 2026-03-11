# Flutter Web Walkthrough

A Flutter web application demonstrating automatic version checking and cache clearing functionality with a simple counter demo page.

## Features

- 🔄 **Automatic Version Detection**: Periodically checks for new versions deployed on the server
- 🔔 **Update Notifications**: Alerts users when a new version is available
- 🧹 **Cache Clearing**: Automatically clears old caches when updating
- ⏰ **Postpone Option**: Users can choose to update now or postpone
- 📊 **Counter Demo**: Simple increment/decrement counter functionality
- 📱 **Responsive Design**: Works on desktop and mobile browsers

## How It Works

1. **Version Tracking**: The app uses a `version.json` file to track version information:
   ```json
   {
     "version": "1.0.0",
     "hash": "1.0.0-1741651200000",
     "timestamp": 1741651200000
   }
   ```

2. **Build Process**: When building the app, the build script automatically:
   - Generates a new hash and timestamp
   - Updates `version.json` with the new values
   - Builds the Flutter web app
   - Copies the version file to the build output

3. **Version Checking**: The app periodically (every 5 minutes):
   - Fetches `version.json` from the server
   - Compares the hash with the cached version
   - Notifies the user if a new version is detected

4. **Update Flow**:
   - **User accepts update**: The app reloads and clears all caches
   - **User postpones**: A notification is shown, and the check will happen again in the next interval

## Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (included with Flutter)
- Git

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd flutter-web-walkthrough
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run in Development Mode

```bash
flutter run -d chrome
```

## Building for Production

### Windows

Use the PowerShell build script:

```powershell
.\build.ps1 -Version "1.0.0"
```

### Linux/Mac

Use the bash build script:

```bash
chmod +x build.sh
./build.sh 1.0.0
```

The build script will:
1. Generate a new version hash and timestamp
2. Update `web/version.json`
3. Clean previous builds
4. Get dependencies
5. Build the Flutter web app
6. Copy version.json to the build output

The final build will be in the `build/web/` directory.

## Deployment

1. Build the app using the build script:
   ```powershell
   .\build.ps1 -Version "1.1.0"
   ```

2. Deploy the contents of `build/web/` to your web server

3. The `version.json` file should be accessible at the root of your deployment (e.g., `https://yourdomain.com/version.json`)

4. Users with the old version will be notified of the update automatically

## Project Structure

```
flutter-web-walkthrough/
├── lib/
│   ├── main.dart                    # Main app and counter page
│   └── services/
│       └── version_service.dart     # Version checking service
├── web/
│   ├── index.html                   # HTML entry point
│   ├── manifest.json                # Web app manifest
│   └── version.json                 # Version tracking file
├── docs/
│   └── logics.md                    # Project documentation
├── build.ps1                        # Windows build script
├── build.sh                         # Linux/Mac build script
├── pubspec.yaml                     # Flutter dependencies
├── .gitignore                       # Git ignore rules
└── .gitattributes                   # Git attributes
```

## Configuration

### Adjust Version Check Interval

Edit `lib/services/version_service.dart`:

```dart
static const Duration _checkInterval = Duration(minutes: 5);  // Change this value
```

### Customize Update Dialog

Modify the `_showUpdateDialog()` method in `lib/main.dart` to customize the appearance and behavior of the update notification.

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **http**: HTTP client for fetching version info
- **shared_preferences**: Local storage for caching version data
- **Git**: Version control

## Development Notes

### Version Number Format

We recommend using semantic versioning (e.g., `1.0.0`, `1.1.0`, `2.0.0`).

### Testing Version Updates Locally

1. Build the app with version 1.0.0:
   ```powershell
   .\build.ps1 -Version "1.0.0"
   ```

2. Serve the build locally (e.g., using Python HTTP server):
   ```bash
   cd build/web
   python -m http.server 8000
   ```

3. Open the app in a browser

4. Build a new version:
   ```powershell
   .\build.ps1 -Version "1.1.0"
   ```

5. Replace the files on the server

6. Wait 5 minutes or trigger a manual check - you should see the update notification

## Troubleshooting

### Update notification not showing

- Check that `version.json` is accessible at the root URL
- Verify the version check interval hasn't been increased too much
- Check browser console for any errors

### Cache not clearing

- Ensure the browser supports the Service Worker API
- Check that the reload function is being called correctly

## License

This project is open source and available under the MIT License.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
