//
//  PickerView.swift
//  SmartApp
//
//  Created by Ricardo Santos on 15/04/2024.
//

import SwiftUI
//
import Domain
import Core
import DesignSystem
import Common

struct DigitTransitionView: View {
    @State private var imageName: String
    @State private var timer: Timer?
    @Binding private var digit: Int
    private let animated: Bool = Common_Utils.false
    private let onTapGesture: () -> Void
    private var images: [String] {
        let number = $digit.wrappedValue
        return [
            "\(number)00",
            "\(number)25",
            "\(number)50",
            "\(number)75",
            "\(number + 1)00"
        ]
    }

    public init(digit: Binding<Int>, onTapGesture: @escaping () -> Void) {
        self.onTapGesture = onTapGesture
        if animated {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        } else {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        }
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(
                minWidth: CounterView.minWidth,
                maxWidth: CounterView.maxWidth,
                minHeight: CounterView.minHeight,
                maxHeight: CounterView.maxHeight
            )
            .onChange(of: digit) { _ in
                if animated {
                    imageName = "\(digit - 1)00"
                    startAnimation()
                } else {
                    imageName = "\($digit.wrappedValue)00"
                }
            }.onTapGesture {
                onTapGesture()
            }
    }

    func startAnimation() {
        var animationDuration: Double {
            (Common.Constants.defaultAnimationsTime * 2) / Double(images.count)
        }
        var currentIndex = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: animationDuration,
            repeats: true
        ) { _ in
            if currentIndex < images.count {
                imageName = images[currentIndex]
                currentIndex += 1
            } else {
                timer?.invalidate() // Stop the timer when animation is done
            }
        }
    }
}

struct NumberTransitionView: View {
    @Binding private var digitIndex0: Int
    @Binding private var digitIndex1: Int
    @Binding private var digitIndex2: Int
    private let onTapGesture: () -> Void
    public init(
        digitIndex0: Binding<Int>,
        digitIndex1: Binding<Int>,
        digitIndex2: Binding<Int>,
        onTapGesture: @escaping () -> Void
    ) {
        self.onTapGesture = onTapGesture
        self._digitIndex0 = digitIndex0
        self._digitIndex1 = digitIndex1
        self._digitIndex2 = digitIndex2
    }

    var body: some View {
        HStack(spacing: 0) {
            DigitTransitionView(digit: $digitIndex0, onTapGesture: onTapGesture)
            DigitTransitionView(digit: $digitIndex1, onTapGesture: onTapGesture)
            DigitTransitionView(digit: $digitIndex2, onTapGesture: onTapGesture)
        }.onTapGesture {
            onTapGesture()
        }
    }
}

extension CounterView {
    static let maxWidth = screenWidth * 0.2
    static let maxHeight = screenWidth * 0.2
    static let minWidth = screenWidth * 0.15
    static let minHeight = screenWidth * 0.15
}

struct CounterView: View {
    @State private var number: Int
    @State private var digitIndex0: Int
    @State private var digitIndex1: Int
    @State private var digitIndex2: Int
    private let onChange: (Int) -> Void
    private let onTapGesture: () -> Void
    private let model: Model.TrackedEntity
    init(
        model: Model.TrackedEntity,
        onChange: @escaping (Int) -> Void,
        onTapGesture: @escaping () -> Void
    ) {
        let counterValue = model.cascadeEvents?.count ?? 0
        self.model = model
        self._number = State(initialValue: counterValue)
        self.digitIndex0 = Self.digitsArray(number: counterValue)[0]
        self.digitIndex1 = Self.digitsArray(number: counterValue)[1]
        self.digitIndex2 = Self.digitsArray(number: counterValue)[2]
        self.onChange = onChange
        self.onTapGesture = onTapGesture
    }

    public var body: some View {
        bodyV2
            .onTapGesture {
                onTapGesture()
            }
    }

    public var bodyV2: some View {
        VStack(spacing: 0) {
            SwiftUIUtils.RenderedView("\(Self.self).\(#function)", id: model.id)
            NumberTransitionView(
                digitIndex0: $digitIndex0,
                digitIndex1: $digitIndex1,
                digitIndex2: $digitIndex2,
                onTapGesture: onTapGesture
            )
            .onChange(of: number) { _ in
                digitIndex0 = Self.digitsArray(number: number)[0]
                digitIndex1 = Self.digitsArray(number: number)[1]
                digitIndex2 = Self.digitsArray(number: number)[2]
                onChange(number)
            }
            Text(model.name)
                .fontSemantic(.title2)
                .textColor(ColorSemantic.labelPrimary.color)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Group {
                if !model.info.isEmpty {
                    Text("(" + model.info + ")")
                        .fontSemantic(.footnote)
                        .textColor(ColorSemantic.labelSecondary.color)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                } else {
                    EmptyView()
                }
            }
        }
    }

    public var bodyV1: some View {
        VStack(spacing: 0) {
            SwiftUIUtils.RenderedView("\(Self.self).\(#function)", id: model.id)
            HStack(spacing: 0) {
                Text(model.name)
                    .fontSemantic(.largeTitle)
                    .textColor(ColorSemantic.labelPrimary.color)
                    .lineLimit(2)
                Spacer()
                NumberTransitionView(
                    digitIndex0: $digitIndex0,
                    digitIndex1: $digitIndex1,
                    digitIndex2: $digitIndex2,
                    onTapGesture: onTapGesture
                )
                .onChange(of: number) { _ in
                    digitIndex0 = Self.digitsArray(number: number)[0]
                    digitIndex1 = Self.digitsArray(number: number)[1]
                    digitIndex2 = Self.digitsArray(number: number)[2]
                    onChange(number)
                }
            }
        }
    }

    static func digitsArray(number: Int) -> [Int] {
        String(format: "%03d", number).compactMap(\.wholeNumberValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CounterView(
                model: .random(cascadeEvents: [.random]),
                onChange: { number in
                    Common_Logs.debug(number)
                },
                onTapGesture: {}
            )
            CounterView(
                model: .random(cascadeEvents: [.random, .random, .random]),
                onChange: { number in
                    Common_Logs.debug(number)
                },
                onTapGesture: {}
            )
        }
    }
}
