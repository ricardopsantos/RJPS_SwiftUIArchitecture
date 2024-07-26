//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObject {
    class var entityName: String {
        String(describing: self).components(separatedBy: ".").last!
    }
}
