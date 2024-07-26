//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation

//
// MARK: - Usage
//

public extension NetworkAgentSampleNamespace {
    static func sampleUsage() {
        let cancelBag = CancelBag()

        var disabled: Bool { 1 == 2 }

        if disabled {
            //
            // JSON
            //
            let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
            let requestDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
            defaultForNetworkAgent.sampleRequestJSON(requestDto).sink { _ in } receiveValue: { response in
                Common.LogsManager.debug(response.data.prefix(3))
            }.store(in: cancelBag)
        }

        if disabled {
            //
            // Task + wait with CSV result
            //

            Task(priority: .background) {
                do {
                    let defaultForNetworkAgent: NetworkAgentSampleAPIProtocol = SimpleNetworkAgentSampleAPI(session: .defaultForNetworkAgent)
                    let requestAsyncDto = NetworkAgentSampleNamespace.RequestDto.Employee(someParam: "aaa")
                    let response = try await defaultForNetworkAgent.sampleRequestCVSAsync(requestAsyncDto)
                    Common.LogsManager.debug("\(response)")
                } catch {
                    Common.LogsManager.error(error)
                }
            }
        }

        if disabled {
            //
            // SSL Pinning
            //

            /// https://www.ssllabs.com/ssltest/analyze.html?d=www.google.co.uk&s=2607%3af8b0%3a4007%3a815%3a0%3a0%3a0%3a2003
            let serverPublicHashKey1 = "jr9L2wQM+Sxb3eq5qlk85ZtmrdNwW5qAbGFweZfG6Zw="
            let serverPublicHashKey2 = "2PC8qER2ONKfBHNYFULYdQPSRSjkgxY/eoB5nes/qS4="
            let serverPublicHashKeys = [serverPublicHashKey1, serverPublicHashKey2]
            let apiPinningV1 = SimpleNetworkAgentSampleAPI(
                session: .defaultForNetworkAgent,
                serverPublicHashKeys: serverPublicHashKeys
            )

            let pathToCertificates = [Bundle.main.path(forResource: "google", ofType: "cer")!]
            let apiPinningV2 = SimpleNetworkAgentSampleAPI(
                session: .defaultForNetworkAgent,
                pathToCertificates: pathToCertificates
            )

            let requestAsyncDto = NetworkAgentSampleNamespace.RequestDto.Pinning(someParam: "aaa")

            apiPinningV1.sampleRequestPinningGoogle(requestAsyncDto)
                .sink { _ in } receiveValue: { response in
                    Common.LogsManager.debug(response)
                }.store(in: cancelBag)

            apiPinningV2.sampleRequestPinningGoogle(requestAsyncDto)
                .sink { _ in } receiveValue: { response in
                    Common.LogsManager.debug(response)
                }.store(in: cancelBag)
        }
    }
}
