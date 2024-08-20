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

    public init(digit: Binding<Int>) {
        if animated {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        } else {
            self._digit = digit
            self.imageName = "\(digit.wrappedValue)00"
        }
    }

    var body: some View {
        VStack {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(
                    width: screenWidth * 0.25,
                    height: screenWidth * 0.25
                )
        }
        .onChange(of: digit) { _ in
            if animated {
                imageName = "\(digit - 1)00"
                startAnimation()
            } else {
                imageName = "\($digit.wrappedValue)00"
            }
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
    public init(
        digitIndex0: Binding<Int>,
        digitIndex1: Binding<Int>,
        digitIndex2: Binding<Int>
    ) {
        self._digitIndex0 = digitIndex0
        self._digitIndex1 = digitIndex1
        self._digitIndex2 = digitIndex2
    }

    var body: some View {
        VStack {
            Text("\(digitIndex0), \(digitIndex1), \(digitIndex2)")
            HStack {
                DigitTransitionView(digit: $digitIndex0)
                DigitTransitionView(digit: $digitIndex1)
                DigitTransitionView(digit: $digitIndex2)
            }
        }
    }
}

struct CounterView: View {
    @State private var number: Int
    @State private var digitIndex0: Int
    @State private var digitIndex1: Int
    @State private var digitIndex2: Int
    private let onChange: (Int) -> Void
    init(number: Int, onChange: @escaping (Int) -> Void) {
        self._number = State(initialValue: number)
        self.digitIndex0 = Self.digitsArray(number: number)[0]
        self.digitIndex1 = Self.digitsArray(number: number)[1]
        self.digitIndex2 = Self.digitsArray(number: number)[2]
        self.onChange = onChange
    }

    public var body: some View {
        VStack {
            Text("\(Self.digitsArray(number: number))")
            NumberTransitionView(
                digitIndex0: $digitIndex0,
                digitIndex1: $digitIndex1,
                digitIndex2: $digitIndex2
            )
            Button("Inc") {
                number += 1
            }
            .onChange(of: number) { _ in
                digitIndex0 = Self.digitsArray(number: number)[0]
                digitIndex1 = Self.digitsArray(number: number)[1]
                digitIndex2 = Self.digitsArray(number: number)[2]
                onChange(number)
            }
        }
    }

    static func digitsArray(number: Int) -> [Int] {
        String(format: "%03d", number).compactMap(\.wholeNumberValue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CounterView(number: 0, onChange: { number in
            Common_Logs.debug(number)
        })
    }
}
