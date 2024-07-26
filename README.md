# SmartApp

<p align="center">
   <img src="https://img.shields.io/badge/status-active-brightgreen">
<img src="https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat">

<img src="https://img.shields.io/badge/Xcode-15.4-blue.svg">
   <a href="https://twitter.com/ricardo_psantos/">
      <img src="https://img.shields.io/badge/Twitter-@ricardo_psantos-blue.svg?style=flat" alt="Twitter">
   </a>
</p>

## About 

__SmartApp__ is a modern iOS application built with _SwiftUI_. __The project is designed to demonstrate the integration of various frameworks and tools for robust app development using SwiftUI__. It features a well-organized structure with support for _Unit testing_, _UI testing_, and various configurations.


<img src=SmartApp/_Documents/images/Xcode.png width=800/>


The project was inspired by [iOSKickstart: Create iOS App Boilerplate in Just 20 Seconds](https://medium.com/shuru-tech/ioskickstart-create-ios-app-boilerplate-in-just-20-seconds-b793ed911705) and the navigation inspired by [Modular Navigation in SwiftUI: A Comprehensive Guide
](https://medium.com/gitconnected/modular-navigation-in-swiftui-a-comprehensive-guide-5eeb8a511583)

## Project Overview

### Xcodegen
SmartApp is structured using [XcodeGen](https://github.com/yonaskolb/XcodeGen), which simplifies the management of Xcode projects by using YAML configuration files. This approach ensures consistency and ease of maintenance across different environments.

The scripts can but found at [`SmartApp/XcodeGen`](https://github.com/ricardopsantos/RJPS_SwiftUIArchitecture/tree/main/SmartApp/Xcodegen). If you are not familliar with XcodeGen, please check [Avoiding merge conflicts with XcodeGen
](https://medium.com/@ricardojpsantos/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb)

<img src=SmartApp/_Documents/graphviz.png width=500/>

### Dependencies

Our philosophy emphasizes avoiding the addition of large dependencies for simple tasks (e.g., using Alamofire for a basic REST GET method). Instead, we carefully selected only three essential dependencies to handle complex or time-consuming (to implement) tasks:

* __Firebase__: Integrated for various backend services, including authentication, real-time database, messaging, and analytics.
* __Nimble__: A matcher framework that enables writing expressive and readable tests.
* __Reachability__: A library used to monitor network reachability and handle network state changes effectively.

## Project Structure (Targets)

The project is organized into several key directories/ targets, each serving a specific purpose:

* __SmartApp__
* __Core__
* __Common__
* __DesignSystem__
* __DevTools__
* __SmartAppUnitTests__
* __SmartAppUITests__ 


### Application

The main application target. Contains the `Views` (Scenes), `ViewModels`, `Coordinators`.

<img src=SmartApp/_Documents/images/project_struct/Application.png width=250/>

### Core

This target encapsulates the core functionality of the application, providing essential components such as:

- __Models__: Business structures and enums that represent the data entities.
- __Network__: Remote communication interfaces and implementations.
- __Repositories__: Local data storage interfaces and implementations.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

Notably, `Services`, `Repositories` and `Network` are defined and implemented via _protocols_. The actual implementation is determined in the main app target, which is crucial for testing and ensuring scalable, maintainable code.

<img src=SmartApp/_Documents/images/project_struct/Core.png width=250/>

### Common

A shared framework that includes extensions and utility functions used across multiple targets, promoting code reuse and modularity. Should not depend on any target, and should seamless work on any project. 

<img src=SmartApp/_Documents/images/project_struct/Common.png width=250/>

### DesignSystem

This target houses design-related components, ensuring a consistent and reusable visual style throughout the application. Also houses the applications _Colors_ and _Fonts_

<img src=SmartApp/_Documents/images/project_struct/DesignSystem.png width=250/>

### DevTools

Includes various development tools and utilities such as logging, facilitating smoother development and debugging processes.

<img src=SmartApp/_Documents/images/project_struct/DevTools.png width=250/>

### SmartAppUnitTests

Contains unit tests for the SmartApp, ensuring that individual components function correctly.

<img src=SmartApp/_Documents/images/project_struct/SmartAppUnitTests.png width=250/>

### SmartAppUITests

Contains UI tests for the SmartApp, validating the user interface and user interactions to ensure a seamless user experience.

<img src=SmartApp/_Documents/images/project_struct/SmartAppUITests.png width=250/>

## Project Structure (File Groups)

### File Groups
  - **Documents**: Includes document-related files.
  - **Configuration**: Contains configuration files for different environments.
  - **XcodeGen**: YAML files for configuring the Xcode project.

### Configuration

The project supports multiple configurations including `Production`, `QA`, and `Dev`, with specific settings for `Debug` and `Release` builds. Configuration files are located in the `Configuration` directory and are referenced in the Xcode project settings.

### Build Scripts

- __SwiftLint__: Enforces Swift style and conventions.
- __SwiftFormat__: Automatically formats Swift code according to style guidelines.

### Project Setup

Run `./makeProject.sh` and project and all dependencies will be installed

<img src=SmartApp/_Documents/install.png width=500/>


