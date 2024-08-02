//
//  PopulationNationModel.swift
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

struct PopulationNationModel: Equatable, Hashable {
    let title: String
    let subTitle: String
    
    init(title: String = "", subTitle: String) {
        self.title = title
        self.subTitle = subTitle
    }
    
    init(populationNationDataResponse modelDto: ModelDto.PopulationNationDataResponse.Datum) {
        self.init(title: "\(modelDto.nation.rawValue)  \(modelDto.year)",
                  subTitle: "Population: \(modelDto.population.localeString)")
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension PopulationNationViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case getPopulationData
    }

    struct Dependencies {
        let model: [PopulationNationModel]
        let didSelected: (ModelDto.PopulationStateDataResponse) -> Void
        let dataUSAService: DataUSAServiceProtocol
    }
}

@MainActor
class PopulationNationViewModel: ObservableObject {
    // MARK: - View Usage Attributes
    @Published var alertModel: Model.AlertModel?
    @Published var loadingModel: Model.LoadingModel?
    @Published var model: [PopulationNationModel] = []

    // MARK: - Auxiliar Attributes
    private let dataUSAService: DataUSAServiceProtocol
    public init(dependencies: Dependencies) {
        self.model = dependencies.model
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
                    let modelDto = try await dataUSAService.requestPopulationNationData(.init())
                    model = modelDto.data.map({ .init(populationNationDataResponse: $0) })
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
    PopulationNationViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
