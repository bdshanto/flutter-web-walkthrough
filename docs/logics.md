## Goal

Test live version refresh mechanism for Flutter web application.

### Version Management

The project uses a `version.json` file to track application versions:

```json
{
  "version": "8.5.0",
  "hash": "8.5.0-1773046542684",
  "timestamp": 1773046542684
}
```

### Update Detection Flow

1. **Build & Publish**: When the Flutter web project is built, the `hash` and `timestamp` values in `version.json` are automatically updated
2. **Server Deployment**: The updated version is deployed to the server
3. **Client Detection**: Active users who are unaware of the new deployment will be notified automatically
4. **User Action**:
   - **Accept Update**: If the user clicks "OK", the system will:
     - Reload the application
     - Clear all old caches
     - Fetch new resources from the server
   - **Postpone Update**: If the user clicks "Not Now":
     - Display a notification message
     - Postpone the update reminder for later

## Technology Stack

- Flutter
- Dart
- Git
  - `.gitignore`
  - `.gitattributes`

## Demo Page

Simple counter page with increment and decrement functionality.
