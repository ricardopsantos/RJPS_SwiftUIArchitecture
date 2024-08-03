# Index

* __Arquitecture Features__
	* Clean Arquitecture Principles 
	* Swift Package Manager
	* SwiftLint and SwiftFormat
* __UI/UX Features__
	* Ligth / Dark mode suport 
	* Localizables
	* Pull down to refresh
	* Loading Screens
	* Alerts (for Success, Warnings and Errors)
* __Design Language Features__
	* Custom Colors (for Ligth/Dark mode) 
	* Custom Fonts 
	* Custom Designables 
* __Performance Features__
	* Services Caching  
* __Debug Features__
	* Logs	 
	* Analitics
	* Errors handling
* __Testing Features__
	* UITesting 	
	* Unit Testing (ViewModels & Services)

## Arquitecture Features 

<center>
<img src=SmartApp/_Documents/images/features/clean.png width=300/>
</center>

### Clean Arquitecture Principles

Our app is built using _Clean Architecture_ principles and separation of concerns, ensuring a maintainable and scalable codebase. It leverages dependency injection and interfaces for easy testing and seamless implementation changes.

#### Architecture Overview

* __Domain:__ Defines the app's _Models_ and _Interfaces_.

* __Core:__ Implements the business logic, such as caching and API requests, defined in the _Domain_.

* __SmartApp:__ The main application containing _Views_, _ViewModels_, _Managers_ (e.g., Analytics), _Assets_, and handling the app's life cycle.

* __DesignSystem:__ Houses definitions for the app's Fonts, Colors, and Designables (reusable UI components).

#### Additional Modules

There are 2 other modules not displayed for simplicity. 

* __Common:__ A utility toolbox containing helper extensions, property wrappers, and other utilities. It has its own unit tests and can be used in any project as it has no dependencies.
 
* __DevTools:__ Manages app logs, with dependencies across all other modules to facilitate logging.

This modular structure ensures each component is focused on a specific responsibility, promoting clean, efficient, and easily testable code.

### Swift Package Manager

As dependencies manager, the app uses SPM allready integrated with _Xcode_ for a seamless experience.

<center>
<img src=SmartApp/_Documents/images/features/spm.png width=800/>
</center>

### SwiftLint and SwiftFormat

<center>
<img src=SmartApp/_Documents/images/features/lint.png width=400/>
</center>

## UI/UX Features 

### Ligth / Dark mode suport

<center>
<table>
<tr>
<td>
<img src=SmartApp/_Documents/images/features/ligthMode.png width=200/>
</td>
<td>
<img src=SmartApp/_Documents/images/features/darkMode.png width=200/>
</table>
</center>

### Localizables 
 
Portuguese and English are for now the available app languages. 
 
<img src=SmartApp/_Documents/images/features/localizables.png width=800/>

### Pull down to refresh

The user can force a screen to refresh by "Pull donw to refresh"

<center>
<img src=SmartApp/_Documents/images/features/pullDonwRefresh.png width=200/>
</center>

### Loading Screens

While the user is waiting for data to be loaded, theres a loader for UX reasons.

<table>
<tr>
<td>
<center>
<img src=SmartApp/_Documents/images/features/loading2.png width=200/>
<center>
</td>
<tr>
<td>
<img src=SmartApp/_Documents/images/features/loading1.png width=800/>
</td>
</tr>
</table>

### Alerts (for Success, Warnings and Errors)

<table>
<tr>
<td>
<center>
<img src=SmartApp/_Documents/images/features/error2.png width=200/>
</center>
</td>
<tr>
<td>
<img src=SmartApp/_Documents/images/features/error1.png width=800/>
</td>
</tr>
</table>

## Design Language Features 

### Custom Colors (for Ligth/Dark mode)

<img src=SmartApp/_Documents/images/features/colors.png width=800/>

### Custom Fonts 

<img src=SmartApp/_Documents/images/features/fonts.png width=800/>

### Custom Designables 

<img src=SmartApp/_Documents/images/features/designables.png width=800/>

## Performance Features

### Services Caching 

By defaults, the _ViewModels_ will prefer to use the cached value (for performance), unless the user chooses to "Pull down to refresh"

<img src=SmartApp/_Documents/images/features/caching.png width=800/>

__IMPORTANT__: This is a very simple cache approach. Ussually I do it this way [Enhancing mobile app user experience through efficient caching in Swift](https://ricardojpsantos.medium.com/enhancing-mobile-app-user-experience-through-efficient-caching-in-swift-c970554eab84) or 

or on the `URLSession`

```
public extension URLSession {
    static var defaultForNetworkAgent: URLSession {
        defaultWithConfig(
            waitsForConnectivity: false,
            timeoutIntervalForResource: defaultTimeoutIntervalForResource,
            cacheEnabled: false
        )
    }

    static var defaultTimeoutIntervalForResource: TimeInterval { 60 }

    static func defaultWithConfig(
        waitsForConnectivity: Bool,
        timeoutIntervalForResource: TimeInterval = defaultTimeoutIntervalForResource,
        cacheEnabled: Bool = true
    ) -> URLSession {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = waitsForConnectivity
        if cacheEnabled {
            config.timeoutIntervalForResource = timeoutIntervalForResource
            let cache = URLCache(
                memoryCapacity: 20 * 1024 * 1024,
                diskCapacity: 100 * 1024 * 1024,
                diskPath: "URLSession.defaultWithConfig"
            )
            config.urlCache = cache
            config.requestCachePolicy = .returnCacheDataElseLoad
        } else {
            config.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        }

        return URLSession(configuration: config)
    }
}
```

## Debug Features

### Logs

The app have logs by _type_ (_debug_, _warning_ and _error_) and by _tag_ (_view_, _bussiness_ and app _life cicle_)

<img src=SmartApp/_Documents/images/features/logs.png width=800/>

### Analitics

Analitics to know the user flow while using the app (screens visited and touchs)

<img src=SmartApp/_Documents/images/features/analitics.png width=800/>

### Errors handling

<img src=SmartApp/_Documents/images/features/errorsManager.png width=800/>

## Testing Features 

The app includes both UI Tests and Unit Tests

<img src=SmartApp/_Documents/images/features/testing.png width=800/>

### UITesting

The app includes UI Tests for views and routing logic

<img src=SmartApp/_Documents/images/features/uiTesting1.png width=800/>
    
### Unit Testing (ViewModels & Services)

The app _ViewModels_ are built on a way that can be tested.

<img src=SmartApp/_Documents/images/features/unitTesting1.png width=800/>

The app _Services_ are built on a way that can be tested.

<img src=SmartApp/_Documents/images/features/unitTesting2.png width=800/>