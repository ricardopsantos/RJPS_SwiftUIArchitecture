//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import SwiftUI

// https://quickbirdstudios.com/blog/coordinator-pattern-in-swiftui/

public extension View {
    func buildNavigationLinkAndPerformOnTap(_ action: @escaping () -> Void) -> some View {
        let isActive = Binding(
            get: { false },
            set: { newValue in if newValue {
                action()
            } }
        )
        return NavigationLink(
            destination: EmptyView(),
            isActive: isActive
        ) { self }
    }

    func buildNavigationDestination<Item>(viewModel: Binding<Item?>, @ViewBuilder destination: (Item) -> some View) -> some View {
        let isActive = Binding(
            get: {
                if let bool = viewModel.wrappedValue as? Bool {
                    return bool
                }
                return viewModel.wrappedValue != nil
            },
            set: { value in if !value {
                viewModel.wrappedValue = nil
            } }
        )
        return overlay(
            NavigationLink(
                destination: isActive.wrappedValue ? viewModel.wrappedValue.map(destination) : nil,
                isActive: isActive,
                label: { EmptyView() }
            )
        )
    }

    // https://developer.apple.com/documentation/swiftui/view/fullscreencover(ispresented:ondismiss:content:)
    func buildFullScreenCoverDestination<Item>(viewModel: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> some View) -> some View {
        let isActive = Binding(
            get: {
                if let bool = viewModel.wrappedValue as? Bool {
                    return bool
                }
                return viewModel.wrappedValue != nil
            },
            set: { value in if !value {
                viewModel.wrappedValue = nil
            } }
        )
        return fullScreenCover(isPresented: isActive) {
            destination(viewModel.wrappedValue!)
        }
    }

    func buildSheetDestination<Item>(viewModel: Binding<Item?>, @ViewBuilder destination: @escaping (Item) -> some View) -> some View {
        let isActive = Binding(
            get: {
                if let bool = viewModel.wrappedValue as? Bool {
                    return bool
                }
                return viewModel.wrappedValue != nil
            },
            set: { value in if !value {
                viewModel.wrappedValue = nil
            } }
        )
        return sheet(isPresented: isActive) {
            destination(viewModel.wrappedValue!)
        }
    }
}

public struct SheetModifierWithItem<Item: Identifiable, Destination: View>: ViewModifier {
    private let item: Binding<Item?>
    private let destination: (Item) -> Destination
    init(item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Destination) {
        self.item = item
        self.destination = content
    }

    public func body(content: Content) -> some View {
        content.sheet(item: item, content: destination)
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
internal extension Common_Preview {
    typealias SampleNavAppA = Common_Preview.SampleNavigationAppA
    struct SampleNavigationAppA {
        struct DetailsModel: Hashable, Identifiable {
            public var id: String { color.description }
            let color: Color
            init(_ color: Color) {
                self.color = color
            }
        }

        class DetailsViewModel: ObservableObject, Identifiable {
            @Published var model: DetailsModel
            public var id: String { model.id }
            private unowned let mainCoordinator: MainCoordinator
            init(detailsModel: DetailsModel, mainCoordinator: MainCoordinator) {
                self.model = detailsModel
                self.mainCoordinator = mainCoordinator
            }

            func close() {
                mainCoordinator.closeDetailsModel()
            }
        }

        struct DetailsView: View {
            @ObservedObject var viewModel: DetailsViewModel
            let isPresented: Bool
            public var body: some View {
                VStack {
                    Group {
                        if isPresented {
                            ZStack {
                                detailsView
                                closeButtonView
                            }
                        } else {
                            detailsView
                        }
                    }
                    SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
                    Spacer()
                }
            }

            private var closeButtonView: some View {
                VStack {
                    SwiftUIUtils.FixedVerticalSpacer(height: 16)
                    HStack {
                        Spacer()
                        Button("Close", action: {
                            viewModel.close()
                        })
                        SwiftUIUtils.FixedHorizontalSpacer(width: 16)
                    }
                    Spacer()
                }
            }

            private var detailsView: some View {
                Text(viewModel.model.color.description)
                    .font(.title)
                    .foregroundColor(viewModel.model.color)
            }
        }

        class ListViewModel: ObservableObject {
            @Published var detailsViewModelList: [DetailsViewModel]
            private unowned let mainCoordinator: MainCoordinator
            init(detailsViewModelList: [DetailsViewModel], mainCoordinator: MainCoordinator) {
                self.detailsViewModelList = detailsViewModelList
                self.mainCoordinator = mainCoordinator
            }

            func open(_ detailsModel: SampleNavAppA.DetailsModel) {
                mainCoordinator.openAsNavigation(detailsModel: detailsModel)
            }
        }

        struct ListView: View {
            @ObservedObject var viewModel: ListViewModel
            public var body: some View {
                VStack {
                    List(viewModel.detailsViewModelList, id: \.model) { item in
                        Text(item.model.color.description).foregroundColor(item.model.color)
                            .buildNavigationLinkAndPerformOnTap {
                                viewModel.open(item.model)
                            }
                    }
                    .font(.headline)
                    .navigationTitle("\(viewModel.detailsViewModelList.count) colors")
                    .navigationBarTitleDisplayMode(.inline)
                    SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
                    Spacer()
                }
            }
        }

        class MainCoordinator: ObservableObject, Identifiable {
            @Published var listViewModel: ListViewModel!
            @Published var detailsViewModel: (navigation: DetailsViewModel?, sheet: DetailsViewModel?)
            init() {
                let red = DetailsViewModel(detailsModel: .init(.red), mainCoordinator: self)
                let blue = DetailsViewModel(detailsModel: .init(.blue), mainCoordinator: self)
                let green = DetailsViewModel(detailsModel: .init(.green), mainCoordinator: self)
                self.listViewModel = .init(detailsViewModelList: [red, blue, green], mainCoordinator: self)
            }

            func closeDetailsModel() {
                detailsViewModel.sheet = nil
                detailsViewModel.navigation = nil
            }

            func openAsSheet(detailsModel: SampleNavAppA.DetailsModel) {
                detailsViewModel.sheet = .init(detailsModel: detailsModel, mainCoordinator: self)
            }

            func openAsNavigation(detailsModel: SampleNavAppA.DetailsModel) {
                detailsViewModel.navigation = .init(detailsModel: detailsModel, mainCoordinator: self)
            }
        }

        struct MainCoordinatorView: View {
            @ObservedObject var listCoordinator: MainCoordinator = .init()
            var asNavigation: Bool
            init(asNavitagion value: Bool) {
                self.asNavigation = value
            }

            public var body: some View {
                VStack {
                    displayAsButtonsAndPresentAsSheet
                    displayAsList
                    SwiftUIUtils.RenderedView("\(Self.self).\(#function)")
                    Spacer()
                }
            }

            private var displayAsButtonsAndPresentAsSheet: some View {
                let sheetModifier = SheetModifierWithItem(item: $listCoordinator.detailsViewModel.sheet) { detailsViewModel in
                    SampleNavAppA.DetailsView(viewModel: detailsViewModel, isPresented: true)
                }
                return HStack {
                    ForEach(listCoordinator.listViewModel.detailsViewModelList, id: \.model) { detailsViewModelItem in
                        Button(action: {
                            listCoordinator.openAsSheet(detailsModel: detailsViewModelItem.model)
                        }) {
                            Image.systemHeart
                                .tint(color: detailsViewModelItem.model.color)
                        }
                    }
                }.modifier(sheetModifier)
            }

            private var displayAsList: some View {
                var displayAsListAndPresentAsNavigation: some View {
                    SampleNavAppA.ListView(viewModel: listCoordinator.listViewModel)
                        .buildNavigationDestination(viewModel: $listCoordinator.detailsViewModel.navigation) { detailsViewModel in
                            SampleNavAppA.DetailsView(viewModel: detailsViewModel, isPresented: false)
                        }
                }

                var displayAsListAndPresentAsSheet: some View {
                    SampleNavAppA.ListView(viewModel: listCoordinator.listViewModel)
                        .buildSheetDestination(viewModel: $listCoordinator.detailsViewModel.navigation) { detailsViewModel in
                            SampleNavAppA.DetailsView(viewModel: detailsViewModel, isPresented: true)
                        }
                }
                return Group {
                    if asNavigation {
                        displayAsListAndPresentAsNavigation
                    } else {
                        displayAsButtonsAndPresentAsSheet
                    }
                }
            }
        }
    }
}

#Preview {
    Common_Preview.SampleNavAppA.MainCoordinatorView(asNavitagion: true)
}
#endif
