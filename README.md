
DisplayingBitmaps sample for Ceylon on Android
==============================================

Sample demonstrating how to load large bitmaps efficiently off the main UI thread,
caching bitmaps (both in memory and on disk), managing bitmap memory and displaying
bitmaps in UI elements such as `ViewPager` and `ListView`/`GridView`.

Introduction
------------

This is a sample application for the Android Training class [Displaying Bitmaps Efficiently][1],
partially ported to [Ceylon](https://ceylon-lang.org).

It demonstrates how to load large bitmaps efficiently off the main UI thread, caching
bitmaps (both in memory and on disk), managing bitmap memory and displaying bitmaps
in UI elements such as `ViewPager` and `ListView`/`GridView`.

It also demonstrates how to have an Android project containing a mix of Ceylon code 
alongside Java code, using the [Ceylon Gradle plugin for Android][2]. (We've 
deliberately left some of the original Java code alone, in order to demonstrate this.)

[1]: http://developer.android.com/training/displaying-bitmaps/
[2]: https://github.com/ceylon/ceylon-gradle-android

Pre-requisites
--------------

- Ceylon 1.3.2
- Android SDK 25
- Android Build Tools v25.0.2
- Android Support Repository

Make sure you have [Ceylon IDE for IntelliJ][3] installed as a plugin in [Android Studio][4].

[3]: https://ceylon-lang.org/documentation/1.3/ide/intellij/install/
[4]: https://developer.android.com/studio/install.html

Screenshots
-------------

<img src="screenshots/1-gridview.png" height="400" alt="Screenshot"/> <img src="screenshots/2-detail.png" height="400" alt="Screenshot"/> 

Getting Started
---------------

This sample uses the Gradle build system. To build this project, use the `gradlew build`
command or use 'Import Project' in Android Studio.

