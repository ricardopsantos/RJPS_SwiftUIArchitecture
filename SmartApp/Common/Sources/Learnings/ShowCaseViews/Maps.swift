//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import UIKit
import Foundation
import SwiftUI
import Combine
import MapKit
import CoreLocation

// https://medium.com/@davidhu-sg/mapkit-in-swiftui-79bcea6b76fc

public extension CommonLearnings {
    enum Maps {
        public struct KopiTiam: Identifiable {
            public let id = UUID()
            public var name: String
            public var coordinate: CLLocationCoordinate2D
        }
    }
}

public extension CommonLearnings.Maps {
    struct MapSample: View {
        @State private var searchResults: [CommonLearnings.Maps.KopiTiam] = []
        @State private var region: MKCoordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 1.280716, longitude: 103.850442),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
        var searchQuery: String = "KopiTiam"
        let locations = [
            KopiTiam(name: "Lau Pa Sat", coordinate: CLLocationCoordinate2D(latitude: 1.280716, longitude: 103.850442)),
            KopiTiam(name: "Test location", coordinate: CLLocationCoordinate2D(latitude: 1.284983, longitude: 103.851615))
        ]
        public var body: some View {
            Map(coordinateRegion: $region, annotationItems: searchResults) { foodCourt in
                // Add Annotation
                MapAnnotation(coordinate: foodCourt.coordinate) {
                    // In this demo, I just put a button here, you can choose whichever you like
                    Button(action: {
                        // action
                    }) {
                        // UI Components for Annotation
                        Image(systemName: "cup.and.saucer.fill")
                            .resizable()
                            .frame(width: 30, height: 22, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .accentColor(.white)
                    }
                    .frame(width: 44, height: 44)
                    .background(.green)
                    .cornerRadius(22)
                }
            }
            .ignoresSafeArea() // Usually we need to ignore safe area for map
            .onAppear { // Load data when onAppear()
                loadAnnotationsByCurrentLocation()
            }
        }
    }
}

public extension CommonLearnings.Maps.MapSample {
    func loadAnnotationsByCurrentLocation() {
        startSearchLocations(searchQuery, region) { results in
            searchResults = mapItemsToKT(mapItems: results)
        }
    }

    func startSearchLocations(_ searchKeyword: String, _ region: MKCoordinateRegion, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchKeyword
        request.region = region
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                print("test log Error: \(error?.localizedDescription ?? "Unknown error").")
                return
            }
            completion(response.mapItems)
        }
    }

    // Convertion code
    func convertMapItemToKopiTiam(mapItem: MKMapItem) -> CommonLearnings.Maps.KopiTiam {
        // covert code here, add more to info
        CommonLearnings.Maps.KopiTiam(
            name: mapItem.name ?? "Unknown Location",
            coordinate: mapItem.placemark.coordinate
        )
    }

    // Convert map items to a custom struct
    func mapItemsToKT(mapItems: [MKMapItem]) -> [CommonLearnings.Maps.KopiTiam] {
        var result: [CommonLearnings.Maps.KopiTiam] = []
        _ = mapItems.compactMap { item in
            result.append(convertMapItemToKopiTiam(mapItem: item))
        }
        return result
    }
}

//
// MARK: - Preview
//

#if canImport(SwiftUI) && DEBUG
#Preview {
    CommonLearnings.Maps.MapSample()
}
#endif
