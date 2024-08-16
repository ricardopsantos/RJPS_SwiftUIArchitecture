//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public protocol SampleWebAPIProtocol {
    func sampleRequestJSON(_ requestDto: RequestDto.Employee) ->
        AnyPublisher<ResponseDto.EmployeeServiceAvailability, CommonNetworking.APIError>

    func sampleRequestPinningGoogle(_ requestDto: RequestDto.Pinning) ->
        AnyPublisher<ResponseDto.Pinning, CommonNetworking.APIError>

    func sampleRequestCVSAsync(_ requestDto: RequestDto.Employee) async throws -> ResponseDto.EmployeeServiceAvailability
}
