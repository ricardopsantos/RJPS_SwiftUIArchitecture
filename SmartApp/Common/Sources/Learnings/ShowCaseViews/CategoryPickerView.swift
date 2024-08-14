//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine

//
// MARK: - CategoryPickerView
//

public extension CommonLearnings {
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

    struct CategoryPickerUsageView: View {
        @State var categoryId = 0
        public var body: some View {
            VStack {
                Text("\(categoryId)")
                CommonLearnings.CategoryPickerView { id in
                    categoryId = id
                }
                Spacer()
            }
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CommonLearnings.CategoryPickerUsageView()
}
#endif
