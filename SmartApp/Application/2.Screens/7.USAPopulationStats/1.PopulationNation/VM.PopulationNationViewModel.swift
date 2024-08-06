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
import DevTools

//
// MARK: - Model
//

struct PopulationNationModel: Equatable, Hashable {
    let title: String
    let subTitle: String
    let year: String
    init(title: String = "", subTitle: String, year: String) {
        self.title = title
        self.subTitle = subTitle
        self.year = year
    }

    init(populationNationDataResponse modelDto: ModelDto.PopulationNationDataResponse.Datum) {
        self.init(
            title: "Year: \(modelDto.year)",
            subTitle: "Population: \(modelDto.population.localeString)",
            year: modelDto.year
        )
    }
}

//
// MARK: - ViewModel (Extensions)
//

extension PopulationNationViewModel {
    enum Actions {
        case didAppear
        case didDisappear
        case getPopulationData(cachePolicy: ServiceCachePolicy)
    }

    struct Dependencies {
        let model: [PopulationNationModel]
        let dataUSAService: DataUSAServiceProtocol
        let onSelected: (PopulationNationModel) -> Void
    }
}

class PopulationNationViewModel: BaseViewModel {
    @Published var model: [PopulationNationModel] = []
    @Published var title: String = "PopulationNationViewTitle".localized
    // MARK: - Auxiliar Attributes
    private let dataUSAService: DataUSAServiceProtocol
    public init(dependencies: Dependencies) {
        self.model = dependencies.model
        self.dataUSAService = dependencies.dataUSAService
        super.init()
        send(action: .getPopulationData(cachePolicy: .cacheElseLoad))
    }

    func send(action: Actions) {
        switch action {
        case .didAppear:
            ()
        case .didDisappear:
            ()
        case .getPopulationData(cachePolicy: let cachePolicy):
            Task { @MainActor in
                loadingModel = .loading(message: "Loading".localized)
                model = []
                do {
                    let modelDto = try await dataUSAService.requestPopulationNationData(
                        .init(),
                        cachePolicy: cachePolicy
                    )
                    model = modelDto.data.map { .init(populationNationDataResponse: $0) }
                    title = String(format: "PopulationNationViewTitleWithRecords".localized, model.count)
                    loadingModel = .notLoading
                    if model.isEmpty {
                        alertModel = .init(type: .warning, message: "NoDataTryAgainLatter".localized)
                    }
                } catch {
                    handle(error: error, sender: "\(Self.self).\(action)")
                }
            }
        }
    }
}

#Preview {
    PopulationNationViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
