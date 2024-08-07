//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

public extension NotificationCenter {
    static let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    static let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    static let keyboardDidHide = NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)
}

public extension Common {
    class KeyboardManagerV1: ObservableObject {
        @Published public var keyboardHeight: CGFloat = 0
        private var cancellable: AnyCancellable?

        private let keyboardWillShow = NotificationCenter.keyboardWillShow
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }

        private let keyboardWillHide = NotificationCenter.keyboardWillHide
            .map { _ in CGFloat.zero }

        // Debounce because on appear it publishes 370 and next 336
        public init() {
            self.cancellable = Publishers.Merge(keyboardWillShow, keyboardWillHide)
                .debounce(for: .milliseconds(250), scheduler: RunLoop.main).eraseToAnyPublisher()
                .subscribe(on: DispatchQueue.main)
                .assign(to: \.keyboardHeight, on: self)
        }
    }

    // Bug: Emits 336 and 370 when keyboard appears.
    class KeyboardManagerV2: ObservableObject {
        static let shared = KeyboardManagerV2()

        @Published public var keyboardHeight: CGFloat = 0

        init() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillHide),
                name: UIResponder.keyboardWillHideNotification,
                object: nil
            )
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(keyboardWillChangeFrame),
                name: UIResponder.keyboardWillChangeFrameNotification,
                object: nil
            )
        }

        @objc func keyboardWillHide() {
            keyboardHeight = 0
        }

        @objc func keyboardWillChangeFrame(notification: Notification) {
            guard let keyboardValue = notification
                .userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else { return }
            keyboardHeight = keyboardValue.cgRectValue.size.height
        }
    }
}

#if canImport(SwiftUI) && DEBUG
private extension Common_Preview {
    struct KeyboardManager: View {
        @StateObject var keyboardManagerV1 = Common.KeyboardManagerV1()
        @StateObject var keyboardManagerV2 = Common.KeyboardManagerV2()
        @State var message: String = ""
        @Namespace var topID
        @Namespace var bottomID
        @State var keyboardHeight: CGFloat = 0
        var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                ScrollViewReader { scrollView in
                    VStack {
                        Spacer()
                        SwiftUIUtils.FixedVerticalSpacer(height: 1).id(topID)
                        Button("Scroll to Bottom") {
                            withAnimation {
                                scrollView.scrollTo(bottomID)
                            }
                        }
                        TextField("Message_A", text: $message)
                            .background(Color.random.opacity(0.1))
                            .padding()
                            .customBorder()
                        Rectangle()
                            .fill(Color.clear)
                            .background(Color.red)
                            .frame(height: screenSize.height * 1.25)
                        TextField("Message_B", text: $message)
                            .background(Color.random.opacity(0.1))
                            .padding()
                            .customBorder()
                        Button("Scroll to Top") {
                            withAnimation {
                                scrollView.scrollTo(topID)
                            }
                        }
                        SwiftUIUtils.FixedVerticalSpacer(height: 1).id(bottomID)
                    }
                    .padding(.bottom, keyboardHeight)
                    .animation(.easeInOut(duration: Common.Constants.defaultAnimationsTime))
                    .onDragDismissKeyboardV1()
                    .onTapDismissKeyboard()
                    .onChange(of: keyboardManagerV1.keyboardHeight, perform: { newValue in
                        Common.LogsManager.debug("keyboardHeightV1: \(newValue)")
                        withAnimation {
                            keyboardHeight = newValue
                        }
                    })
                    .onChange(of: keyboardManagerV2.keyboardHeight, perform: { newValue in
                        Common.LogsManager.debug("keyboardHeightV2: \(newValue)")
                    })
                }
            }
        }
    }
}

#Preview {
    Common_Preview.KeyboardManager()
}

#endif

struct CustomBorderViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .strokeBorder(Color.blue, style: StrokeStyle(lineWidth: 1.0))
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.green, style: StrokeStyle(lineWidth: 3.0))
                    )
            )
    }
}

extension View {
    func customBorder() -> some View {
        modifier(CustomBorderViewModifier())
    }
}

//
// MARK: - View
//

public extension View {
    @inlinable func onDragDismissKeyboardV2() -> some View {
        gesture(DragGesture().onChanged { _ in
            UIApplication.shared.dismissKeyboard()
        })
    }

    @inlinable func onTapDismissKeyboard() -> some View {
        onTapGesture {
            UIApplication.shared.dismissKeyboard()
        }
    }
}

//
// MARK: - ResignKeyboardOnDragGesture
//

public struct ResignKeyboardOnDragGesture: ViewModifier {
    var gesture = DragGesture().onChanged { _ in
        UIApplication.shared.dismissKeyboard()
    }

    public func body(content: Content) -> some View {
        content.gesture(gesture)
    }
}

public extension View {
    func onDragDismissKeyboardV1() -> some View {
        modifier(ResignKeyboardOnDragGesture())
    }
}
