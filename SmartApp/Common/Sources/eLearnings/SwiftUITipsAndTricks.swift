//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

public struct SwiftUITipsAndTricks {
    private init() {}
    public enum VM {}
}

public extension SwiftUITipsAndTricks {
    //
    // MARK: -  How to declare variables inside GeometryReader
    // https://paigeshin1991.medium.com/swiftui-how-to-declare-variables-inside-geometryreader-aa5ebade46a8
    //

    struct DeclareVariablesInsideGeometryReader: View {
        public var body: some View {
            VStack {
                bodyV1
                bodyV2WithProxy
            }
        }

        var bodyV1: some View {
            VStack {
                GeometryReader { geometry in
                    let size = geometry.size
                    Text("Hello world")
                        .frame(width: size.width, height: size.height, alignment: .top)
                }
            }
        }

        var bodyV2WithProxy: some View {
            func viewWithProxy(_ proxy: GeometryProxy) -> some View {
                let size = proxy.size
                return Text("Hello world")
                    .frame(width: size.width, height: size.height, alignment: .top)
            }
            return VStack {
                GeometryReader { geometry in
                    viewWithProxy(geometry)
                }
            }
        }

        var bodyV2AsAnyView: some View {
            VStack {
                GeometryReader { proxy -> AnyView in
                    let size = proxy.size
                    return AnyView(
                        Text("Hello world")
                            .frame(width: size.width, height: size.height, alignment: .top)
                    )
                }
            }
        }
    }
}

public extension SwiftUITipsAndTricks {
    //
    // MARK: - Use a Drawing Group to Speed Up Views 🎨
    // https://benlmyers.medium.com/9-swiftui-hacks-for-beautiful-views-cd9682fbe2ec
    //

    struct UseDrawingGroupToSpeedUpView: View {
        let useCompositingGroup: Bool
        let useDrawingGroup: Bool

        public var body: some View {
            content1
                .doIf(useDrawingGroup, transform: {
                    $0.drawingGroup()
                })
        }

        var content1: some View {
            VStack {
                ZStack {
                    Text("DrawingGroup")
                        .foregroundColor(.black)
                        .padding(20)
                        .background(Color.red)
                    Text("DrawingGroup")
                        .blur(radius: 2)
                }
                .font(.title)
                .doIf(useCompositingGroup, transform: {
                    $0.compositingGroup()
                })
                .opacity(1.0)
            }
            .background(Color.white)
        }
    }
}

public extension SwiftUITipsAndTricks {
    //
    // MARK: -  Solving redraw issues in SwiftUI
    // https://www.avanderlee.com/swiftui/debugging-swiftui-views/
    //

    struct SolvingRedraw_TimerCountFixedView: View {
        @State var count = 0
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        public var body: some View {
            VStack {
                Text("Count is now: \(count)!")
                    .onReceive(timer) { _ in
                        count += 1
                    }
                SwiftUITipsAndTricks.SolvingRedraw_AnimatedButton()
            }
        }
    }

    struct SolvingRedraw_AnimatedButton: View {
        @State var animateButton = true
        public var body: some View {
            Button {} label: {
                Text("SAVE")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 80)
                    .background(Color.red)
                    .cornerRadius(50)
                    .shadow(color: .secondary, radius: 1, x: 0, y: 5)
            }.rotationEffect(Angle(degrees: animateButton ? Double.random(in: -8.0...1.5) : Double.random(in: 0.5...16))).onAppear {
                withAnimation(.easeInOut(duration: 1).delay(0.5).repeatForever(autoreverses: true)) {
                    animateButton.toggle()
                }
            }
        }
    }
}

//
// MARK: - NeumorphicButton
// https://medium.com/devtechie/neumorphic-button-in-ios-16-and-swiftui-75360b41866e
//

public extension SwiftUITipsAndTricks {
    struct NeumorphicButton: View {
        let offWhiteColor = Color(red: 236 / 255, green: 234 / 255, blue: 235 / 255)
        let shadowColor = Color(red: 197 / 255, green: 197 / 255, blue: 197 / 255)
        public var body: some View {
            let shape1 = Circle()
            // let shape2 = RoundedRectangle(cornerRadius: 20, style: .continuous)
            if #available(iOS 16.0, *) {
                return ZStack {
                    VStack {
                        Text("NeumorphicButton")
                            .font(.caption)
                        Button(action: {}) {
                            Image.globe
                                .resizable()
                                .frame(width: 40, height: 40)
                                .padding(25)
                                .foregroundColor(Color.orange)
                                .background(
                                    shape1
                                        .fill(
                                            // .shadow(.inner(color: shadowColor,radius: 3, x: 3, y: 3))
                                            // .shadow(.inner(color: .white, radius: 3, x: -3, y: -3))
                                            .shadow(.drop(color: shadowColor, radius: 3, x: 3, y: 3))
                                                .shadow(.drop(color: .white, radius: 3, x: -3, y: -3))
                                        )
                                        .foregroundColor(offWhiteColor)
                                )
                        }
                    }
                }
            } else {
                return Text("Not iOS16")
            }
        }
    }
}

//
// MARK: - CategoryPickerView
//

public extension SwiftUITipsAndTricks {
    struct CategoryPickerView: View {
        @State private var id: Int?
        let onSelect: (Int) -> Void
        public var body: some View {
            Picker("Select Category", selection: $id) {
                ForEach(1...10, id: \.self) { index in
                    Text("Category \(index)").tag(Optional(index))
                }
            }.pickerStyle(.wheel)
                .onChange(of: id) { value in
                    if let value {
                        onSelect(value)
                    }
                }
        }
    }
}

//
// MARK: - KeyboardPinToTextField
//

public extension SwiftUITipsAndTricks {
    struct KeyboardPinToTextField: View {
        //
        // https://twitter.com/natpanferova/status/1590676836488732678?s=46&t=H-9UOSADwiL21W9-VZj76A
        // If we need to permanently pin a view to the bottom of the screen in SwiftUI,
        // we can place it inside safeAreaInset(edge: .bottom) modifier.
        // If we use this method with a text field, it will also automatically
        // move to the top of the keyboard when focused.
        @State private var messages: [(id: Int, text: String)] = [(1, "Message 1"), (2, "Message 2")]
        @State private var newMessageText: String = ""
        public var body: some View {
            List(messages, id: \.0) { item in
                Text(item.1).safeAreaInset(edge: .bottom) { TextField("New message", text: $newMessageText)
                    padding()
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
private extension Common_Preview {
    struct SwiftUITipsAndTricksPreview: View {
        @State private var categoryId = 0
        public init() {}
        public var body: some View {
            ScrollView {
                VStack {
                    SwiftUIUtils.RenderedView("RenderedView")
                    SwiftUITipsAndTricks.UseDrawingGroupToSpeedUpView(
                        useCompositingGroup: false,
                        useDrawingGroup: false
                    )
                    SwiftUITipsAndTricks.UseDrawingGroupToSpeedUpView(
                        useCompositingGroup: true,
                        useDrawingGroup: true
                    )
                    SwiftUITipsAndTricks.NeumorphicButton()
                    SwiftUITipsAndTricks.KeyboardPinToTextField()
                    SwiftUITipsAndTricks.SolvingRedraw_TimerCountFixedView()
                    SwiftUITipsAndTricks.CategoryPickerView { id in
                        categoryId = id
                    }
                    Text("\(categoryId)")
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    Common_Preview.SwiftUITipsAndTricksPreview()
}

#endif
