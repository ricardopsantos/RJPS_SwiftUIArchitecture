//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

//
// https://medium.com/@anuj.rai2489/ssl-pinning-254fa8ca2109
// https://medium.com/@gizemturker/lock-down-your-app-with-https-and-certificate-pinning-a-swift-security-masterclass-d709494649bd
// https://www.ssllabs.com/ssltest/analyze.html?d=www.google.co.uk&s=2607%3af8b0%3a4007%3a815%3a0%3a0%3a0%3a2003
// https://www.ssldragon.com/blog/certificate-pinning/
//

/**
 __Static SSL Pinning:__ The SSL certificate is hard-coded into the application itself. This method, while robust,
 doesn’t allow for certificate updates, presenting potential security issues. If the hard-coded pinned certificate expires
 or is compromised, you must update the entire application to implement a new SSL certificate. Thus, static SSL pinning requires meticulous planning.

 __Dynamic SSL Pinning:__ This method offers a more flexible approach to certificate pinning, allowing for updates
 without requiring a complete application overhaul. Dynamic SSL Pinning retrieves the SSL certificate or public key
 during runtime and enables software applications to update the pinned certificates dynamically. It provides extra security
 by maintaining communication integrity between the client and the server.
 */

/**
 # 1. Generate a private key: This command generates a 2048-bit RSA private key and
 saves it to a file named google.key. The private key is essential for creating the certificate and is used to encrypt data securely.
 `openssl genrsa -out google.key 2048`

 # 2. Create a Certificate Signing Request (CSR). This command creates a Certificate
 Signing Request (CSR) using the private key generated in the first step.
 `openssl req -new -key google.key -out google.csr`

 # 3. Generate a self-signed certificate and save it as google.cer. This command generates
 a self-signed SSL certificate using the CSR and private key from the previous steps
 `openssl x509 -req -days 365 -in google.csr -signkey google.key -out google.cert`

 Summary of Files Generated
 `google.key`: The private key.
 `google.csr`: The Certificate Signing Request.
 `google.cer`: The self-signed SSL certificate.
 */

public extension CommonNetworking.AuthenticationHandler {
    struct Server {
        public let url: String
        public let publicHashKeys: [String]
        public let pathToCertificates: [String]?
        public let credentials: (user: String, password: String)?
        public init(
            url: String,
            publicHashKeys: [String],
            credentials: (user: String, password: String)? = nil,
            pathToCertificates: [String]? = nil
        ) {
            self.url = url
            self.publicHashKeys = publicHashKeys
            self.credentials = credentials
            self.pathToCertificates = pathToCertificates
        }
    }
}

public extension CommonNetworking.AuthenticationHandler.Server {
    static var gitHub: Self {
        Self(
            url: "https://gist.github.com/",
            publicHashKeys: ["XZVlvxBvEFhGF+9gt9WOwIJdvQBYT3Cqnu0mu6S884I="],
            pathToCertificates: []
        )
    }

    static var googleUkWithHashKeys: Self {
        Self(
            url: "https://www.google.co.uk/",
            publicHashKeys: ["caMXMXM6GkN65HHqWbN8rm32m0Td+FXeMwVaraqJies="],
            pathToCertificates: nil
        )
    }

    static var googleUkWithCertPath: Self {
        var pathToCertificates: [String]?
        #if IN_PACKAGE_CODE
        if let cert = Bundle.module.path(forResource: "google.co.uk", ofType: "cer") {
            pathToCertificates = [cert]
        } else {
            fatalError("Not found")
        }
        #else
        if let cert = Bundle.main.path(forResource: "google.co.uk", ofType: "cer") {
            pathToCertificates = [cert]
        } else {
            fatalError("Not found")
        }
        #endif
        return Self(
            url: "https://www.google.co.uk/",
            publicHashKeys: [],
            pathToCertificates: pathToCertificates
        )
    }
}

public extension CommonNetworking {
    class AuthenticationHandler: NSObject, URLSessionDelegate {
        // Holds user credentials for HTTP Basic Authentication.
        private let credential: URLCredential?
        // Array of server public key hashes for SSL pinning.
        private let serverPublicHashKeys: [String]?
        // Array of file paths to local certificates for SSL pinning.
        private let pathToCertificates: [String]?

        public init(server: Server) {
            if let credentials = server.credentials {
                self.credential = .init(user: credentials.user, password: credentials.password, persistence: .forSession)
            } else {
                self.credential = nil
            }
            self.serverPublicHashKeys = server.publicHashKeys
            self.pathToCertificates = server.pathToCertificates
            super.init()
        }

        public init(credential: URLCredential) {
            self.credential = credential
            self.serverPublicHashKeys = nil
            self.pathToCertificates = nil
            super.init()
        }

        public init(serverPublicHashKeys: [String]) {
            self.credential = nil
            self.serverPublicHashKeys = serverPublicHashKeys
            self.pathToCertificates = nil
            super.init()
        }

        public init(pathToCertificates: [String]) {
            self.credential = nil
            self.serverPublicHashKeys = nil
            self.pathToCertificates = pathToCertificates
            super.init()
        }

        // Delegate method for handling authentication challenges.
        public func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            Common_Logs.debug("\(CommonNetworking.NetworkAgentClient.self): Received URLAuthenticationChallenge for \(session)")
            // Handle HTTP Basic Authentication challenges.
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                guard let credential = credential else {
                    Common_Logs.error("\(CommonNetworking.NetworkAgentClient.self): No credentials provided for challenge \(challenge)")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                Common_Logs.debug("\(CommonNetworking.NetworkAgentClient.self): Authenticated with Credentials")
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
                Common_Logs.error("\(CommonNetworking.NetworkAgentClient.self): Invalid serverCertificate")
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            // Helper function to log and cancel the authentication challenge.
            func cancelAuthenticationChallengeWithLog(key: String, value: String) {
                Common_Logs.debug("\(CommonNetworking.NetworkAgentClient.self): ServerPublicKey: \(serverPublicKey)\nServerPublicKeyData: \(serverPublicKeyData)")
                Common_Logs.error("\(CommonNetworking.NetworkAgentClient.self): Unexpected \(key): [\(value)]")
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
                    Common_Logs.debug("\(CommonNetworking.NetworkAgentClient.self): Authenticated with Server Public Key")
                    return
                } else {
                    cancelAuthenticationChallengeWithLog(key: "serverPublicKey",
                                                         value: "\(serverPublicKeyDataHash)")
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
                    Common_Logs.debug("\(CommonNetworking.NetworkAgentClient.self): Authenticated with Local Certificate")
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
