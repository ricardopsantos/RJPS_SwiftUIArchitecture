//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import MapKit

public extension MKMapView {
    func deselectAllAnnotations(animated: Bool = true) {
        for annotation in selectedAnnotations {
            deselectAnnotation(annotation, animated: animated)
        }
    }
}
