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

struct PopulationNationModel: Equatable, Hashable, Sendable {
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
            Task {
                await getPopulationData(cachePolicy: cachePolicy, action: action)
            }
        }
    }
}

extension PopulationNationViewModel {
    @MainActor
    func getPopulationData(cachePolicy: ServiceCachePolicy, action: Actions?) async -> Bool {
        loadingModel = .loading(message: "Loading".localized)
        var newValueForModel: [PopulationNationModel] = []
        do {
            let modelDto = try await dataUSAService.requestPopulationNationData(
                .init(),
                cachePolicy: cachePolicy
            )
            newValueForModel = modelDto.data.map { .init(populationNationDataResponse: $0) }
            title = String(format: "PopulationNationViewTitleWithRecords".localized, newValueForModel.count)
            loadingModel = .notLoading
            if newValueForModel.isEmpty {
                alertModel = .init(type: .warning, message: "NoDataTryAgainLatter".localized)
            }
            model = newValueForModel
            return true
        } catch {
            handle(error: error, sender: "\(Self.self).\(String(describing: action))")
            return false
        }
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    PopulationNationViewCoordinator()
        .environmentObject(ConfigurationViewModel.defaultForPreviews)
}
#endif
