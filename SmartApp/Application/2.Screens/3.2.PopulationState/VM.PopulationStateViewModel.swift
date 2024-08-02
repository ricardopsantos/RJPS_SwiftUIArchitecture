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
                loadingModel = .loading(message: "Loading".localized)
                model = []
                do {
                    let cachePolicy: DataUSAServiceCachePolicy = .cacheElseLoad
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
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                    ErrorsManager.handleError(message: "\(Self.self).\(action)", error: error)
                    if let appError = error as? AppErrors, !appError.localizedForUser.isEmpty {
                        alertModel = .init(type: .error, message: appError.localizedForUser)
                    } else {
                        alertModel = .init(type: .error, message: error.localizedDescription)
                    }
                }
            }
        }
    }
}

#Preview {
    PopulationStateViewCoordinator(year: ModelDto.PopulationStateDataRequest.Constants.lastYear)
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
