


[https://developer.apple.com/documentation/swiftui/](https://developer.apple.com/documentation/swiftui/preferencekey)

[https://augmentedcode.io/2020/05/10/setting-an-equal-width-to-text-views-in-swiftui/](https://augmentedcode.io/2020/05/10/setting-an-equal-width-to-text-views-in-swiftui/)

[https://medium.com/@wesleymatlock/enhancing-swiftui-views-with-preferencekey-a-comprehensive-guide-0dfa7be2044f](https://medium.com/@wesleymatlock/enhancing-swiftui-views-with-preferencekey-a-comprehensive-guide-0dfa7be2044f)

`PreferenceKey` is a protocol in SwiftUI that allows views to communicate data up the view hierarchy. It’s especially useful for situations where you need to pass data from a child view to a parent view.

To use a `PreferenceKey`, you need to define a custom type that conforms to the protocol. You then use this type to define a preference value in a view hierarchy. 

Any views that are descendants of this view can then access the preference value using the @Environment property wrapper.

__Example 1__

```
struct ChildView: View {
    var body: some View {
        Text("Hello, SwiftUI!")
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: MyPreferenceKey.self, value: "\(geometry.size.width)")
                }
            )
    }
}

struct ParentView: View {
    @State private var width: String = ""
    
    var body: some View {
        VStack {
            ChildView()
            Text("Width: \(width)")
        }
        .onPreferenceChange(MyPreferenceKey.self) { value in
            self.width = value
        }
    }
}
```

