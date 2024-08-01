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

_SmartApp_ is a modern _iOS_ application built with _SwiftUI_ using _MVVM_ and _Domain-Driven Design_. This design approach ensures that the structure and language of the software code (class names, methods, variables) match the business domain. More info at [DDD](https://en.wikipedia.org/wiki/Domain-driven_design).

<center>
<img src=SmartApp/_Documents/graphviz.png width=250/>
</center>

__The project was mainly designed to demonstrate the integration of various frameworks and tools for robust app development using SwiftUI__ and features a well-organized structure with support for _Unit Testing_, _UI Testing_, and multiple configurations.

<center>
<img src=SmartApp/_Documents/images/Xcode.png width=800/>
</center>

Also, was inspired by [iOSKickstart: Create iOS App Boilerplate in Just 20 Seconds](https://medium.com/shuru-tech/ioskickstart-create-ios-app-boilerplate-in-just-20-seconds-b793ed911705) and the navigation was inspired by [Modular Navigation in SwiftUI: A Comprehensive Guide](https://medium.com/gitconnected/modular-navigation-in-swiftui-a-comprehensive-guide-5eeb8a511583).


## Install 

No need to install anything, as all app dependencies are managed via [Swift Package Manager](https://www.swift.org/documentation/package-manager/).

However, the project can be fully rebuilt with `./makefile.sh` (for a total cleanup and conflict fixing) using [XcodeGen](https://github.com/yonaskolb/XcodeGen). If you are not familiar with XcodeGen, please check [Avoiding merge conflicts with XcodeGen](https://medium.com/@ricardojpsantos/avoiding-merge-conflicts-with-xcodegen-a0e2a1647bcb).

The scripts can be found at [`SmartApp/XcodeGen`](https://github.com/ricardopsantos/RJPS_SwiftUIArchitecture/tree/main/SmartApp/Xcodegen).

<center>
<img src=SmartApp/_Documents/install.png width=500/>
</center>



## Project Structure (Targets)

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

### Application Target

It's the main application target. Contains the `Views` (scenes), `ViewModels` (glue betweeen _Views_ and Logic), `Coordinators` (routing logic). 

### Domain Target

This target encapsulates the interface functionality of the application. Providing the _Models_ and _Protocols_ it define what the app can do and the data structures to do it.

- __Repositories__: Local data storage protocols.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

### Core Target

This target implements the _Domain_ functionalities, providing essential components such as:

- __Network__: Remote communication implementations.
- __Repositories__: Local data storage implementations.
- __Services__: Bigde betweens _ViewModels_ and _Network_ and where we can have more logic associated (eg. caching)

Notably, `Services`, `Repositories` and `Network` are defined and implemented via _protocols_. The actual implementation is determined in the main app target, which is crucial for testing and ensuring scalable, maintainable code.

### Common Target

A shared framework that includes extensions and utility functions used across multiple targets, promoting code reuse and modularity. Should not depend on any target, and should seamless work on any project. 

### DesignSystem Target

This target houses design-related components, ensuring a consistent and reusable visual style throughout the application. Also houses the applications _Colors_ and _Fonts_

### DevTools Target

Includes various development tools and utilities such as logging, facilitating smoother development and debugging processes.

### SmartAppUnitTests Target

Contains unit tests for the SmartApp, ensuring that individual components function correctly.

### SmartAppUITests Target

Contains UI tests for the SmartApp, validating the user interface and user interactions to ensure a seamless user experience.

## Tests 

The app include Unit Tests and UITests. 

<img src=SmartApp/_Documents/images/tests/tests.png width=800/>

### Testing Target: SmartApp

<img src=SmartApp/_Documents/images/tests/test_viewmodels.png width=800/>

### Testing Target: Core - Repositories

<img src=SmartApp/_Documents/images/tests/test_reps.png width=800/>

### Testing Target: Core - Services

<img src=SmartApp/_Documents/images/tests/test_services.png width=800/>

### Testing Target: Common

`Common` is a package by it self, and also includes tests. 

<img src=SmartApp/_Documents/images/tests/common.png width=800/>

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


## Project (external) Dependencies

Our philosophy emphasizes avoiding the addition of large dependencies for simple tasks (e.g., using Alamofire for a basic REST GET method). Instead, we carefully selected only three essential dependencies to handle complex or time-consuming (to implement) tasks:

* __Firebase__: Integrated for various backend services, including authentication, real-time database, messaging, and analytics.
* __Nimble__: A matcher framework that enables writing expressive and readable tests.
* __Reachability__: A library used to monitor network reachability and handle network state changes effectively.

