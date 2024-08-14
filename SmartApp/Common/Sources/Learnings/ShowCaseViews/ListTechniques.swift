//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

// https://medium.com/@wesleymatlock/advanced-techniques-for-using-list-in-swiftui-a03ee8e28f0e

public extension CommonLearnings {
    enum ListTechniques {
        public static let items1 = ["item 1.1", "item 1.2"]
        public static let items2 = ["item 2.1", "item 2.2"]
    }
}

//
// MARK: - ListAdvancedTechniques
//

public extension CommonLearnings.ListTechniques {
    struct SimpleListView: View {
        public init() {}
        public var body: some View {
            List(CommonLearnings.ListTechniques.items1, id: \.self) { item in
                Text(item)
            }
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct CustomRowListView: View {
        public init() {}
        public var body: some View {
            List(CommonLearnings.ListTechniques.items1, id: \.self) { item in
                HStack {
                    Image(systemName: "leaf")
                        .foregroundColor(.green)
                    Text(item)
                        .font(.headline)
                    Spacer()
                    Button(action: {
                        //("\(item) selected")
                    }) {
                        Image(systemName: "info.circle")
                    }
                }
            }
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct SectionedListView: View {
        public init() {}
        public var body: some View {
            List {
                Section(header: Text("Section 1")) {
                    ForEach(CommonLearnings.ListTechniques.items1, id: \.self) { item in
                        Text(item)
                    }
                }
                Section(header: Text("Section 2")) {
                    ForEach(CommonLearnings.ListTechniques.items2, id: \.self) { item in
                        Text(item)
                    }
                }
            }
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct SwipeActionListView: View {
        public init() {}
        @State public var items = CommonLearnings.ListTechniques.items1
        public var body: some View {
            List {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .swipeActions {
                            Button(role: .destructive) {
                                if let index = items.firstIndex(of: item) {
                                    items.remove(at: index)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct ReorderableListView: View {
        public init() {}
        @State public var items = CommonLearnings.ListTechniques.items1
        public var body: some View {
            NavigationView {
                List {
                    ForEach(items, id: \.self) { item in
                        HStack {
                            Text(item)
                        }
                    }
                    .onMove(perform: move)
                }
                .toolbar {
                    EditButton()
                }
                .navigationTitle("Reorderable List")
            }
        }

        public func move(from source: IndexSet, to destination: Int) {
            items.move(fromOffsets: source, toOffset: destination)
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct SearchableListView: View {
        @State private var searchText = ""
        @State private var items = CommonLearnings.ListTechniques.items1

        var filteredItems: [String] {
            if searchText.isEmpty {
                return items
            } else {
                return items.filter { $0.contains(searchText) }
            }
        }

        public var body: some View {
            List(filteredItems, id: \.self) { item in
                Text(item)
            }
            .searchable(text: $searchText)
        }
    }
}

public extension CommonLearnings.ListTechniques {
    struct DisplayView: View {
        let content: () -> (any View)
        let title: String
        public init(content: @escaping () -> any View, title: String) {
            self.content = content
            self.title = title
        }

        public var body: some View {
            VStack(spacing: 0) {
                Text(title)
                    .font(.headline)
                content().erasedToAnyView
                Divider()
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    VStack {
        if Common_Utils.true {
            CommonLearnings.ListTechniques.DisplayView(content: {
                CommonLearnings.ListTechniques.SimpleListView()
            }, title: "SimpleListView")
        }
        if Common_Utils.false {
            CommonLearnings.ListTechniques.DisplayView(content: {
                CommonLearnings.ListTechniques.CustomRowListView()
            }, title: "CustomRowListView")
        }
        if Common_Utils.false {
            CommonLearnings.ListTechniques.DisplayView(content: {
                CommonLearnings.ListTechniques.SectionedListView()
            }, title: "SectionedListView")
        }
        if Common_Utils.false {
            CommonLearnings.ListTechniques.DisplayView(content: {
                CommonLearnings.ListTechniques.SwipeActionListView()
            }, title: "SwipeActionListView")
        }
        if Common_Utils.false {
            CommonLearnings.ListTechniques.DisplayView(content: {
                CommonLearnings.ListTechniques.ReorderableListView()
            }, title: "ReorderableListView")
        }
        CommonLearnings.ListTechniques.DisplayView(content: {
            CommonLearnings.ListTechniques.SearchableListView()
        }, title: "SearchableListView")
    }
}
#endif
