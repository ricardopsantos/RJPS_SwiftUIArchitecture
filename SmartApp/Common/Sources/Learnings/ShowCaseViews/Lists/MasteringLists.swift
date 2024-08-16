//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://blog.stackademic.com/swiftui-mastering-list-programmatically-scroll-set-initial-visible-item-check-if-an-item-is-e9a8b86dd9a8

public extension CommonLearnings {
    enum MasteringLists {}
}

public extension CommonLearnings.MasteringLists {
    struct ListDemoV1: View {
        @State var list: Array<String> = (0...30).map { "Index\($0)" }
        public var body: some View {
            List {
                ForEach(0..<list.count, id: \.self) { i in
                    let item = list[i]
                    Text(item)
                        .frame(height: 100, alignment: .leading)
                        .frame(maxWidth: .infinity)
                        .listRowSeparator(.hidden, edges: .all)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .listStyle(PlainListStyle())
        }
    }
}

public extension CommonLearnings.MasteringLists {
    struct ListDemoV2: View {
        let setInitialIndex: Int?
        public init(setInitialIndex: Int?) {
            self.setInitialIndex = setInitialIndex
        }

        @State var list: Array<String> = (0...30).map { "Index\($0)" }
        public var body: some View {
            ScrollViewReader { proxy in
                VStack {
                    Button("Jump to item id=5") {
                        withAnimation(.default) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }
                    List {
                        ForEach(0..<list.count, id: \.self) { i in
                            let item = list[i]
                            Text(item)
                                .frame(height: 100, alignment: .leading)
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden, edges: .all)
                                .id(i)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .listStyle(PlainListStyle())
                }
                .onAppear { proxy.scrollTo(setInitialIndex ?? 0, anchor: .top) }
            }
        }
    }
}

public extension CommonLearnings.MasteringLists {
    struct ListDemoV3: View {
        @State var list: Array<String> = (0...30).map { "Index\($0)" }
        let setInitialIndex: Int?
        let canPrependItems: Bool
        public init(setInitialIndex: Int?, canPrependItems: Bool) {
            self.setInitialIndex = setInitialIndex
            self.canPrependItems = canPrependItems
        }

        public var body: some View {
            ScrollViewReader { proxy in
                VStack {
                    Button("Jump to top") {
                        withAnimation(.default) {
                            proxy.scrollTo(0, anchor: .top)
                        }
                    }

                    List {
                        ForEach(0..<list.count, id: \.self) { i in
                            let item = list[i]
                            Text(item)
                                .frame(height: 100, alignment: .leading)
                                .frame(maxWidth: .infinity)
                                .listRowSeparator(.hidden, edges: .all)
                                .id(i)
                                .onAppear {
                                    if i == list.count - 1 {
                                        print("last visible row")
                                        Task {
                                            let newItemsList = (list.count...list.count + 30).map { "New Item: Index\($0)" }
                                            list.append(contentsOf: newItemsList)
                                        }
                                    } else if i == 0 {
                                        print("first visible row")
                                        if canPrependItems {
                                            Task {
                                                let newItemsList = (0...10).map { "Previous Item: Index\($0)" }
                                                list.insert(contentsOf: newItemsList, at: 0)
                                                proxy.scrollTo(10, anchor: .top)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .listStyle(PlainListStyle())
                    .onAppear { proxy.scrollTo(setInitialIndex ?? 1, anchor: .top) }
                }
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    // CommonLearnings.MasteringLists.ListDemoV1()
    // CommonLearnings.MasteringLists.ListDemoV2(setInitialIndex: 10)
    CommonLearnings.MasteringLists.ListDemoV3(setInitialIndex: 10, canPrependItems: true)
}
#endif
