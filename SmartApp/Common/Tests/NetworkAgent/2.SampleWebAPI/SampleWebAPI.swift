//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Combine
@testable import Common

public class SampleWebAPI: CommonNetworking.NetworkAgentClient, NetworkAgentProtocol {
    public var client: CommonNetworking.NetworkAgentClient {
        CommonNetworking.NetworkAgentClient(session: urlSession)
    }
    #if targetEnvironment(simulator)
    public var logger: CommonNetworking.NetworkLogger { .requestAndResponses }
    #else
    public var logger: CommonNetworking.NetworkLogger { .allOff }
    #endif
}
