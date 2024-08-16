//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

//
// https://medium.com/@gizemturker/lock-down-your-app-with-https-and-certificate-pinning-a-swift-security-masterclass-d709494649bd
//

public extension CommonNetworking {
    class AuthenticationHandler: NSObject, URLSessionDelegate {
        // Holds user credentials for HTTP Basic Authentication.
        var credential: URLCredential?

        // Array of server public key hashes for SSL pinning.
        var serverPublicHashKeys: [String]?

        // Array of file paths to local certificates for SSL pinning.
        var pathToCertificates: [String]?

        // Delegate method for handling authentication challenges.
        public func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            // Handle HTTP Basic Authentication challenges.
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                guard let credential = credential else {
                    Common_Logs.error("No credentials provided for challenge \(challenge)")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                completionHandler(.useCredential, credential)
                return
            }

            // Check if we have server trust (SSL certificate) information.
            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            // Extract the server's certificate from the server trust.
            guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
                  let serverPublicKey = SecCertificateCopyKey(serverCertificate),
                  let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            // Helper function to log and cancel the authentication challenge.
            func cancelAuthenticationChallengeWithLog(key: String, value: String) {
                Common_Logs.debug("ServerPublicKey: \(serverPublicKey)\nServerPublicKeyData: \(serverPublicKeyData)")
                Common_Logs.error("Unexpected \(key): [\(value)]")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }

            // Handle SSL Pinning with public key hashes.
            if let serverPublicHashKeys = serverPublicHashKeys, !serverPublicHashKeys.isEmpty {
                func sha256(data: Data) -> String {
                    // Add ASN.1 header for RSA 2048 public key.
                    let rsa2048Asn1Header: [UInt8] = [
                        0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00
                    ]
                    var keyWithHeader = Data(rsa2048Asn1Header)
                    keyWithHeader.append(data)
                    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
                    keyWithHeader.withUnsafeBytes {
                        _ = CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
                    }
                    return Data(hash).base64EncodedString()
                }

                // Compute the hash of the server's public key.
                let serverPublicKeyDataHash = sha256(data: serverPublicKeyData as Data)
                if serverPublicHashKeys.contains(serverPublicKeyDataHash) {
                    // Public key hash matches, authentication successful.
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                    return
                } else {
                    cancelAuthenticationChallengeWithLog(key: "serverHashKey", value: "\(serverPublicKeyDataHash)")
                    return
                }
            }

            // Handle SSL Pinning with local certificates.
            if let pathToCertificates = pathToCertificates, !pathToCertificates.isEmpty {
                // Load local certificates from file paths.
                let localCertificatesData: [Data] = pathToCertificates.compactMap { NSData(contentsOfFile: $0) } as [Data]

                // Create SSL policy for the remote server.
                let policy = NSMutableArray()
                policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))

                // Evaluate if the server trust is valid.
                let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)

                // Get the server's certificate data.
                let remoteCertificateData: NSData = SecCertificateCopyData(serverCertificate)

                // Check if the server's certificate matches any of the local certificates.
                let existsMatchingLocalCer = localCertificatesData.contains { remoteCertificateData.isEqual(to: $0) }

                if isServerTrusted, existsMatchingLocalCer {
                    // Certificate matches, authentication successful.
                    let credential: URLCredential = URLCredential(trust: serverTrust)
                    completionHandler(.useCredential, credential)
                    return
                } else {
                    cancelAuthenticationChallengeWithLog(key: "remoteCertificateData", value: "\(Data(remoteCertificateData).base64EncodedString())")
                }
            }

            // Pinning failed, cancel the authentication challenge.
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

//
// MARK: - Usage
//

extension CommonNetworking.AuthenticationHandler {
    static var sampleAuthenticationHandler: CommonNetworking.AuthenticationHandler {
        let authenticationHandler = CommonNetworking.AuthenticationHandler()

        // Configure the AuthenticationHandler
        authenticationHandler.credential = URLCredential(user: "username", password: "password", persistence: .forSession)

        // Example server public key hashes (you would replace these with actual values)
        authenticationHandler.serverPublicHashKeys = [
            "jr9L2wQM+Sxb3eq5qlk85ZtmrdNwW5qAbGFweZfG6Zw=",
            "2PC8qER2ONKfBHNYFULYdQPSRSjkgxY/eoB5nes/qS4="
        ]

        // Example paths to local certificates (ensure these paths are valid)
        authenticationHandler.pathToCertificates = [
            "/path/to/certificate1.pem",
            "/path/to/certificate2.pem"
        ]
        authenticationHandler.pathToCertificates = [Bundle.main.path(forResource: "google", ofType: "cer")!]
        return authenticationHandler
    }

    static func sample2() {
        // Create an instance of AuthenticationHandler
        let authenticationHandler = CommonNetworking.AuthenticationHandler.sampleAuthenticationHandler

        // Create a URLSession with the authentication handler as its delegate
        let urlSession = URLSession(
            configuration: .defaultForNetworkAgent(),
            delegate: authenticationHandler,
            delegateQueue: nil
        )

        // Create a URL request
        guard let url = URL(string: "https://example.com/api/resource") else {
            fatalError("Invalid URL")
        }

        let request = URLRequest(url: url)

        // Create a data task
        let dataTask = urlSession.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                print("Data received: \(data)")
            }
        }

        // Start the data task
        dataTask.resume()
    }
}
