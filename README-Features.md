
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

