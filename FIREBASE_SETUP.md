# Firebase Setup Guide for SCOM Voting System

## Overview
This voting system now uses Firebase Real-time Database for real-time data synchronization across all devices.

## Setup Instructions

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Name your project: `scom-voting-system`
4. Follow the setup steps

### 2. Add Firebase to Android App
1. In Firebase Console, click "Add app" → Android
2. Package name: `com.example.scom_ec`
3. Download `google-services.json`
4. Replace the placeholder `google-services.json` in `android/app/` with your downloaded file

### 3. Update Android Build Files

#### android/build.gradle (Project level)
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

#### android/app/build.gradle (App level)
```gradle
plugins {
    // Add this line
    id 'com.google.gms.google-services'
}

dependencies {
    // Add these lines
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-analytics'
    implementation 'com.google.firebase:firebase-database'
}
```

### 4. Add Firebase to Web App
1. In Firebase Console, add a Web app
2. Copy the Firebase config object
3. Replace the placeholder values in `web/index.html`

### 5. Configure Firebase Real-time Database Rules
In Firebase Console → Real-time Database → Rules, set:
```json
{
  "rules": {
    "votingData": {
      ".read": "true",
      ".write": "true"
    }
  }
}
```

## Features Enabled

### Real-time Synchronization
- All voting data syncs instantly across devices
- When a user votes, all other users see the update immediately
- Admin changes appear instantly on all connected devices

### Offline Support
- App works offline with local caching
- Changes are queued and synced when connection is restored
- 10MB cache size for offline data

### Data Structure
```
votingData/
├── validVoterNumbers: [array of voter IDs]
├── votersWhoVoted: {voterId: true, ...}
├── votersWhoNominated: {voterId: true, ...}
├── nominations: {position: {candidate: votes, ...}, ...}
├── voteResults: {position: {candidate: votes, ...}, ...}
└── adminSubmittedCandidates: {position: [candidates], ...}
```

## Testing Real-time Features
1. Open the app on two different devices/browsers
2. Sign in with different voter numbers
3. Make a vote on one device
4. Watch the results update instantly on the other device

## Security Notes
- Current rules allow read/write access for testing
- For production, implement proper authentication rules
- Consider using Firebase Authentication for user management

## Troubleshooting
- If Firebase doesn't initialize, check your configuration files
- Ensure your Firebase project has Real-time Database enabled
- Check internet connectivity for real-time features
- Monitor Firebase Console for database usage and errors
