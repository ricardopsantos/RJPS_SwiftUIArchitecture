//
//  PopulationStateModel.swift
//  SmartApp
//
//  Created by Ricardo Santos on 02/08/2024.
//

import Foundation
import SwiftUI
//
import Domain
import Common
import Core

//
// MARK: - Model
//

public struct PopulationStateModel: Equatable, Hashable, Sendable {
    let title: String
    let subTitle: String
    init(title: String = "", subTitle: String = "") {
        self.title = title
        self.subTitle = subTitle
    }

    init(populationStateDataResponse modelDto: ModelDto.PopulationStateDataResponse.Datum) {
        self.init(
            title: "\(modelDto.state): \(modelDto.population.localeString)",
            subTitle: ""
        )
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension PopulationStateViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case getPopulationData
    }

    struct Dependencies {
        let model: [PopulationStateModel]
        let year: String
        let onRouteBack: () -> Void
        let dataUSAService: DataUSAServiceProtocol
    }
}

class PopulationStateViewModel: BaseViewModel {
    // MARK: - View Usage Attributes
    @Published var model: [PopulationStateModel] = []
    @Published var title = "PopulationStateView".localized
    // MARK: - Auxiliar Attributes
    private let year: String
    private let dataUSAService: DataUSAServiceProtocol
    public init(dependencies: Dependencies) {
        self.model = dependencies.model
        self.year = dependencies.year
        self.dataUSAService = dependencies.dataUSAService
        super.init()
        send(action: .getPopulationData)
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            ()
        case .didDisappear:
            ()
        case .getPopulationData:
            Task { 
                loadingModel = .loading(message: "Loading".localized)
                model = []
                do {
                    let cachePolicy: ServiceCachePolicy = .cacheElseLoad
                    let modelDto = try await dataUSAService.requestPopulationStateData(
                        .init(year: year),
                        cachePolicy: cachePolicy
                    )
                    model = modelDto.data.map { .init(populationStateDataResponse: $0) }
                    if model.isEmpty {
                        alertModel = .init(type: .warning, message: "No data. Please try again latter".localizedMissing)
                    }
                    if year == ModelDto.PopulationStateDataRequest.Constants.lastYear {
                        title = String(format: "PopulationStateViewWithRecords".localized, "LastYear".localized)
                    } else {
                        title = String(format: "PopulationStateViewWithRecords".localized, year)
                    }
                    loadingModel = .notLoading
                } catch {
                    handle(error: error, sender: "\(Self.self).\(action)")
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
    PopulationStateViewCoordinator(
        year: ModelDto.PopulationStateDataRequest.Constants.lastYear,
        model: []
    )
    .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
