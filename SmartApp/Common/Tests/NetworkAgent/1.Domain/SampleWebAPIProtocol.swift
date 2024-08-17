//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public protocol SampleWebAPIProtocol {
    typealias EmployeesAvailabilityResponse = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    func fetchEmployeesAvailability(_ requestDto: RequestDto.Employee) -> EmployeesAvailabilityResponse
}
