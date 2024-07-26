//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

@testable import Smart_Dev

import XCTest
import Combine
import Nimble
//
import Common

let cancelBag = CancelBag()
var timeout: Int = 5
var loadedAny: Any?
