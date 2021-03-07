<p align="center">

<img src="https://raw.github.com/d4rkd3v1l/timeARC/develop/timeARC/iOS/Assets.xcassets/AppIcon.appiconset/icon_dark_green_1024.png" width="250" height="250" />

<br />
<br />

<a href="https://app.bitrise.io/app/005a877ee34f42d3">
<img src="https://app.bitrise.io/app/005a877ee34f42d3/status.svg?token=6Ff82GaWAW8Fo_GPbgimDQ&branch=develop" />
</a>

<a href="https://sonarcloud.io/dashboard?id=timeARC&branch=develop">
<img src="https://sonarcloud.io/api/project_badges/measure?branch=develop&project=timeARC&metric=alert_status" />
</a>

</p>

# timeARC - A SwiftUI time tracking app

This is basically my "I'm learning SwiftUI project". :rocket:

## Roadmap

- [x] iOS App
- [x] watchOS Extension
- [ ] macOS App
- [ ] watchOS standalone App (?)

## About

The app is (and should stay) just a very minimalistic time tracker that I use to track my working times.
I also added some basic statistics (average working time, overtime etc.), but thats really the most advanced feature this project may ever see^^.

As I want to play with and learn the hotest and newest shit currently available, the App will only support the latest OS versions (that of now is iOS 14, watchOS 7, macOS 11.0).

### Redux

After working for more than 3 years professionally with a redux like approach using [ReSwift](https://github.com/ReSwift/ReSwift), I decided to use this approach here as well. Now using a very lightweight SwiftUI library named [SwiftUIFlux](https://github.com/Dimillian/SwiftUIFlux).

### Persistence

In the beginning I chose to just serialize data down into UserDefaults for persistence, but now I will move on to use Core Data with CloudKit to ensure proper sync between platforms.

### Dependency Injection

As this also seemed to be a good start to get deeper into DI, I decided to use [Resolver](https://github.com/hmlongco/Resolver) as DI framework.

### Tests

Currently still quite low, my goal is to get a high test coverage for this project as well. Basically I did not think about "view" testing yet, but all critical core componentes should have some tests at least.
