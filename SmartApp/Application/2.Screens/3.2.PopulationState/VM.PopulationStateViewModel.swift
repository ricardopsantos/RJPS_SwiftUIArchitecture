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

struct PopulationStateModel: Equatable, Hashable {
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

@MainActor
class PopulationStateViewModel: ObservableObject {
    // MARK: - View Usage Attributes
    @Published var alertModel: Model.AlertModel?
    @Published var loadingModel: Model.LoadingModel?
    @Published var model: [PopulationStateModel] = []
    @Published var title = "PopulationStateView".localized
    // MARK: - Auxiliar Attributes
    private let year: String
    private let dataUSAService: DataUSAServiceProtocol
    public init(dependencies: Dependencies) {
        self.model = dependencies.model
        self.year = dependencies.year
        self.dataUSAService = dependencies.dataUSAService
        send(action: .getPopulationData)
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            ()
        case .didDisappear:
            ()
        case .getPopulationData:
            Task { @MainActor in
                loadingModel = .loading(message: "Loading".localizedMissing)
                model = []
                do {
                    let modelDto = try await dataUSAService.requestPopulationStateData(.init(year: year))
                    model = modelDto.data.map { .init(populationStateDataResponse: $0) }
                    if year == ModelDto.PopulationStateDataRequest.Constants.lastYear {
                        title = String(format: "PopulationStateViewWithRecords".localized, "LastYear".localized)
                    } else {
                        title = String(format: "PopulationStateViewWithRecords".localized, year)
                    }
                    loadingModel = .notLoading
                } catch {
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                    alertModel = .tryAgainLatter
                }
            }
        }
    }
}

#Preview {
    PopulationStateViewCoordinator(year: ModelDto.PopulationStateDataRequest.Constants.lastYear)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
