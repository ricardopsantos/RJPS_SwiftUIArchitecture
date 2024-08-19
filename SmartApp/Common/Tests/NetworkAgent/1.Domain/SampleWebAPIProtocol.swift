//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public protocol SampleWebAPIProtocol {
    //
    // MARK: - Generic api calls
    //
    func requestAsync<T: Decodable>(_ api: SampleWebAPIMethods) async throws -> T
    func requestPublisher<T: Decodable>(_ api: SampleWebAPIMethods) -> AnyPublisher<T, CommonNetworking.APIError>
    
    //
    // MARK: - Verbose/Custom api calls
    //
    typealias EmployeesAvailabilityResponse = AnyPublisher<
        ResponseDto.EmployeeServiceAvailability,
        CommonNetworking.APIError
    >
    func fetchEmployeesAvailability(_ requestDto: RequestDto.Employee) -> EmployeesAvailabilityResponse
}
