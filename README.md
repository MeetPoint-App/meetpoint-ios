# MeetPoint

[![Build Status](https://www.bitrise.io/app/7a26c93ad5a8995a.svg?token=UiTe2gkL-Nq1vXmW6Opxiw&branch=master)](https://www.bitrise.io/app/) ![Platform](https://camo.githubusercontent.com/783873a5a5968925c13e4b7748d284c56e3e676d/68747470733a2f2f636f636f61706f642d6261646765732e6865726f6b756170702e636f6d2f702f4e53537472696e674d61736b2f62616467652e737667) [![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://github.com/MeetPoint-App/meetpoint-ios/blob/master/LICENSE)


Together is better! We believe that meeting with people and socializing should be easy. We designed MeetPoint to help you meet with people in real life.
With only couple taps you let people know what activity you want to do and get together spontaneously.

## Screenshots
![Screenshots](https://i.imgur.com/k5XA4DK.jpg)
## Some Features
- [x] Facebook and Email login
- [x] Geofence feature
- [x] Create public / private activities
- [x] Participate other activities
- [x] Follow / Unfollow the users
- [x] Push notification for user based actions
- [x] Search 
- [x] Write comment
- [ ] Offline mode
## Communication
* If you **found a bug** or have a **feature request** - open an issue.
* If you want to **contribute** - submit a pull request.

## Requirements
* iOS 10.3+
* Xcode 8.0+
* Swift 3.1+

## Installation guide
#### Download repo
```
$ git clone https://github.com/yusufkildan/MeetPoint.git
$ cd MeetPoint
```
#### Install pods
``` 
$ pod install
```
#### Setup tokens
- Open the Info.plist file and setup your `FacebookAppID`
- Open the AppDelegate.swift and enter your Google Places api key( `GMSPlacesClient.provideAPIKey("ENTER YOUR API KEY HERE")` )
#### Setup Firebase 
To create your own database please follow this steps:

- Go to the [Firebase console](https://console.firebase.google.com/)
- Press `Create new project` and follow the instructions
- Download `GoogleService-Info.plist` file and make sure the file name is `GoogleService-Info-Development.plist`.Then add to the plist file to project(add to Support folder).
- Set the `Database Rules` as follows:
```
{
  "rules": {
    ".read": true,
    ".write": "auth != null",
    "NearMe": {
      // Allow anyone to read the GeoFire index
      ".read": true,

      // Index each location's geohash for faster querying
      ".indexOn": ["g"],

      // Schema validation
      "$key": {
        // Allow anyone to add, update, or remove keys in the GeoFire index
        ".write": true,

        // Key validation
        ".validate": "newData.hasChildren(['g', 'l'])",

        // Geohash validation
        "g": {
          ".validate": "newData.isString() && newData.val().length <= 22 && newData.val().length > 0"
        },

        // Location coordinates validation
        "l": {
          "0" : {
            ".validate": "newData.isNumber() && newData.val() >= -90 && newData.val() <= 90"
          },
          "1" : {
            ".validate": "newData.isNumber() && newData.val() >= -180 && newData.val() <= 180"
          },
          "$other": {
            ".validate": false
          }
        },

        // Don't allow any other keys to be written
        "$other": {
          ".validate": false
        }
      }
    }
  }
}
```
- Choose `Authentication` from left menu and enable Facebook and Email Sign-In providers

*Note: To send and receive push notification upload your APNs Certificates to Firebase and Deploy Firebase Cloud Functions to your project.*

And finally open *MeetPoint.xcworkspace* and **run the app**

## License
MeetPoint is licensed under Apache License 2.0. [See LICENSE](https://github.com/MeetPoint-App/meetpoint-ios/blob/master/LICENSE) for details.

##
<a target="_blank" href="http://itunes.apple.com/us/app/meetpoint-app/id1363547170"><img src="https://perfectradiousa.files.wordpress.com/2016/09/itunes-app-store-logo.png"  width="250" alt="App Store" /></a>

