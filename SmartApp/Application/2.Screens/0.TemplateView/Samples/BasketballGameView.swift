//
//  SampleViews.swift
//  SmartApp
//
//  Created by Ricardo Santos on 17/07/2024.
//

import Foundation
import SwiftUI
//
import Common

class ScoreViewModel: ObservableObject {
    enum Actions {
        case increment
    }

    @Published private(set) var points = 0
    @MainActor
    func send(_ action: Actions) {
        switch action {
        case .increment: points += 1
        }
    }
}

struct ScoreView: View {
    @StateObject private var vm = ScoreViewModel()
    let teamName: String
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView("ScoreView")
            Button("\(teamName): \(vm.points)") { vm.send(.increment) }
        }
    }
}

struct BasketballGameView: View {
    @State private var quarter = 1
    var body: some View {
        VStack {
            SwiftUIUtils.RenderedView("ScoreView")
            if quarter <= 4 {
                Button(quarter < 4 ? "Next Quarter" : "End Game") { quarter += 1 }
                HStack {
                    ScoreView(teamName: "Team A")
                    ScoreView(teamName: "Team B")
                }
                Text("Quarter: \(quarter)")
            } else {
                Text("Game Ended")
            }
        }
    }
}

#Preview {
    BasketballGameView()
}
