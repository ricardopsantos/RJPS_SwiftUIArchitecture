<p align="center">
   <img src="https://img.shields.io/badge/status-active-brightgreen">
<img src="https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat">

<img src="https://img.shields.io/badge/Xcode-15.4-blue.svg">
   <a href="https://twitter.com/ricardo_psantos/">
      <img src="https://img.shields.io/badge/Twitter-@ricardo_psantos-blue.svg?style=flat" alt="Twitter">
   </a>
</p>

# Abstract

SmartApp is a __template iOS__ application built with __SwiftUI__ using __MVVM__ and inspired by [iOSKickstart: Create iOS App Boilerplate in Just 20 Seconds](https://medium.com/shuru-tech/ioskickstart-create-ios-app-boilerplate-in-just-20-seconds-b793ed911705) and the navigation was inspired by [Modular Navigation in SwiftUI: A Comprehensive Guide](https://medium.com/gitconnected/modular-navigation-in-swiftui-a-comprehensive-guide-5eeb8a511583).

# Index

* __About__: _Into_ | _Architecture Overview_ | _Additional Modules_ | _Dependencies Manager_ 
* __Architecture__: _Application_ | _Domain_ | _Core_ | _Common_ | _DesignSystem_ | _DevTools_
* __Tests__: _UI Tests_ | _Unit Tests_
* __Misc__: _Design Language_ | _XcodeGen_ | _SwiftLint and SwiftFormat_  | _Profiling_ | _Install_
	
# About 

## Intro 

SmartApp is a __template iOS__ application built with __SwiftUI__ using __MVVM__, and was mainly designed to serve as a template while integrating various frameworks and features in a well-organized structure with support for __Unit Testing__, __UI Testing__. Also makes use of other tools like __[XcodeGen](https://github.com/yonaskolb/XcodeGen)__, __[SwiftLint](https://github.com/realm/SwiftLint)__ and __[SwiftFormat](https://github.com/nicklockwood/SwiftFormat)__

__SwiftUI__ because is Apple's current standart and offers several advantages like including a declarative syntax that simplifies UI design, real-time previews for faster iteration, and seamless integration with Swift for a unified coding experience while also enabling cross-platform development with a single codebase, significantly reducing development time and effort.

__MVVM__ (Model-View-ViewModel) because separates concerns by dividing code into _Model_, _View_, and _ViewModel_, making maintenance easier. Also improves testability by isolating the _ViewModel_ for _unit tests_, enhancing code reliability. It also boosts reusability, allowing _ViewModels_ and _Views_ to be used across different contexts. Additionally, _MVVM_ simplifies data binding, integrating smoothly with _SwiftUI_ and _Combine_ for reactive and responsive user interfaces.


<center>
<img src=SmartApp/_Documents/graphviz_prety.png width=800/>
</center>


## Architecture Overview

The app is built using _Clean Architecture_ principles and separation of concerns, ensuring a maintainable and scalable codebase. It leverages dependency injection and interfaces for easy testing and seamless implementation changes.

* __SmartApp:__ The main application containing _Views_, _ViewModels_, _Managers_ (e.g., Analytics), _Assets_, and handling the app's life cycle.

* __Domain:__ Defines the app's _Models_ and _Interfaces_.

* __Core:__ Implements the business logic, such as caching and API requests, defined in the _Domain_.

* __DesignSystem:__ Houses definitions for the app's Fonts, Colors, and Designables (reusable UI components).


## Additional Modules

There are 2 other modules not displayed for simplicity. 

* __Common:__ A utility toolbox containing helper extensions, property wrappers, and other utilities. It has its own unit tests and can be used in any project as it has no dependencies.
 
* __DevTools:__ Manages app logs, with dependencies across all other modules to facilitate logging.

This modular structure ensures each component is focused on a specific responsibility, promoting clean, efficient, and easily testable code.

## Dependencies Manager 

[__Swift Package Manager__](https://www.swift.org/documentation/package-manager/) simplifies dependency management and project organization for Swift developers. It enables you to easily add, update, and manage third-party libraries and frameworks. Integrated seamlessly with Xcode, Swift Package Manager promotes modularity, improves build performance, and ensures that your dependencies are up-to-date, making it an essential tool for modern Swift development.

<center>
<img src=SmartApp/_Documents/images/features/spm.png width=800/>
</center>

Our philosophy emphasizes avoiding the addition of large dependencies for simple tasks (e.g., using Alamofire for a basic REST GET method). Instead, we carefully selected only three essential dependencies to handle complex or time-consuming (to implement) tasks:

* __Firebase__: Integrated for various backend services, including authentication, real-time database, messaging, and analytics.
* __Nimble__: A matcher framework that enables writing expressive and readable tests.
* __Reachability__: A library used to monitor network reachability and handle network state changes effectively.


# Architecture

<center>
<img src=SmartApp/_Documents/images/Xcode.png width=500/>
</center>

The project is organized into several key directories/targets, each serving a specific purpose: __SmartApp__, __Domain__, __Core__, __Common__, __DesignSystem__, __DevTools__, __SmartAppUnitTests__, __SmartAppUITests__ 

<center>
<table>
<tr>
<td>
<img src=SmartApp/_Documents/images/project_struct/Application.png width=200/>
</td>
<td>
<center>
<img src=SmartApp/_Documents/images/project_struct/Core.png width=200/>
</center>
</td>
<td>
<img src=SmartApp/_Documents/images/project_struct/Domain.png width=200/>
</td>
</tr>
<tr>
<td>
<img src=SmartApp/_Documents/images/project_struct/DevTools.png width=200/>
</td>
<td>
<center>
<img src=SmartApp/_Documents/images/project_struct/SmartAppUnitTests.png width=200/>
<img src=SmartApp/_Documents/images/project_struct/SmartAppUITests.png width=200/>
</center>
</td>
<td>
<img src=SmartApp/_Documents/images/project_struct/DesignSystem.png width=200/>
</td>
</tr>
</table>
</center>

## Application

It's the main application target. Contains the `Views` (scenes), `ViewModels` (glue betweeen _Views_ and Logic), `Coordinators` (routing logic). 

## Domain

This target encapsulates the interface functionality of the application. Providing the _Models_ and _Protocols_ it define what the app can do and the data structures to do it.

- __Repositories__: Local data storage protocols.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

## Core

This target implements the _Domain_ functionalities, providing essential components such as:

- __Network__: Remote communication implementations.
- __Repositories__: Local data storage implementations.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

Notably, `Services`, `Repositories` and `Network` are defined and implemented via _protocols_. The actual implementation is determined in the main app target, which is crucial for testing and ensuring scalable, maintainable code.

## Common

A shared framework that includes extensions and utility functions used across multiple targets, promoting code reuse and modularity. Should not depend on any target, and should seamless work on any project. 

## DesignSystem

This target houses design-related components, ensuring a consistent and reusable visual style throughout the application. Also houses the applications _Colors_ and _Fonts_

## DevTools

Includes various development tools and utilities such as logging, facilitating smoother development and debugging processes.

# Tests 

The app includes both UI Tests and Unit Tests

<img src=SmartApp/_Documents/images/tests/tests2.png width=800/>

### UITesting

The app includes UI Tests for views and routing logic

<img src=SmartApp/_Documents/images/features/uiTesting1.png width=800/>
    
### Unit Testing (ViewModels & Services)

The app _ViewModels_ are built on a way that can be tested.

<img src=SmartApp/_Documents/images/features/unitTesting1.png width=800/>

The app _Services_ are built on a way that can be tested.

<img src=SmartApp/_Documents/images/features/unitTesting2.png width=800/>

# Misc

## Design Language 

Design language in mobile apps refers to a set of guidelines and principles that define the visual and interactive style of an application. It includes elements like color schemes, typography, iconography, and spacing to ensure a cohesive and intuitive user experience. A well-defined design language helps maintain consistency, improve usability, and strengthen brand identity across different platforms and devices.

More about at [Adding a Design Language to your Xcode project.](https://medium.com/@ricardojpsantos/adding-a-design-language-to-your-xcode-project-fef5be39bef7)

### Custom Colors (for Ligth/Dark mode)

<img src=SmartApp/_Documents/images/features/colors.png width=800/>

### Custom Fonts 

<img src=SmartApp/_Documents/images/features/fonts.png width=800/>

### Custom Designables 

<img src=SmartApp/_Documents/images/features/designables.png width=800/>

##  XcodeGen

__XcodeGen__ treamlines project management by allowing you to generate Xcode project files from a simple YAML or JSON specification. This approach reduces merge conflicts, ensures consistency across teams, and makes it easier to version control project settings. By automating project setup, XcodeGen enhances productivity and maintains a cleaner, more organized codebase.

<center>
<img src=SmartApp/_Documents/images/features/xcodegen.png width=400/>
</center>

## SwiftLint and SwiftFormat

[SwiftLint](https://github.com/realm/SwiftLint) and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) are essential tools for maintaining code quality in Swift projects. SwiftLint enforces coding style and conventions by analyzing your code for potential issues and inconsistencies, ensuring adherence to best practices. SwiftFormat, on the other hand, automatically formats your Swift code to conform to a consistent style, making it more readable and maintainable. Together, they help streamline development workflows and uphold code standards across teams.

<center>
<img src=SmartApp/_Documents/images/features/lint.png width=400/>
</center>

## Profiling

At the present day the project is [leaks](https://developer.apple.com/documentation/xcode/diagnosing-memory-thread-and-crash-issues-early) free.

<center>
<img src=SmartApp/_Documents/images/tests/leaks.png width=800/>

## Install 

No need to install anything, as all app dependencies are managed via [Swift Package Manager](https://www.swift.org/documentation/package-manager/).

However, the project can be fully rebuilt with `./makefile.sh` (for a total cleanup and conflict fixing) using [XcodeGen](https://github.com/yonaskolb/XcodeGen). If you are not familiar with XcodeGen, please check [Avoiding merge conflicts with XcodeGen](https://medium.com/@ricardojpsantos/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb).

The scripts can be found at [`SmartApp/XcodeGen`](https://github.com/ricardopsantos/RJPS_SwiftUIArchitecture/tree/main/SmartApp/Xcodegen).


<center>
<img src=SmartApp/_Documents/install.png width=500/>
</center>