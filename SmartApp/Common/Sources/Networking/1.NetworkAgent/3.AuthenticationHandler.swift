//
//  Created by Ricardo Santos on 01/01/2023.
//  Copyright © 2024 - 2019 Ricardo Santos. All rights reserved.
//

import Foundation
import Security
import CommonCrypto

public extension CommonNetworking {
    class AuthenticationHandler: NSObject, URLSessionDelegate {
        var credential: URLCredential?
        var serverPublicHashKeys: [String]? // https://www.ssllabs.com/ssltest/analyze.html
        var pathToCertificates: [String]?

        public func urlSession(
            _ session: URLSession,
            didReceive challenge: URLAuthenticationChallenge,
            completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
        ) {
            //
            // Challenge Type : User and Password
            //
            if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
                guard let credential else {
                    Common_Logs.error("No credentials provided for challenge \(challenge)")
                    completionHandler(.cancelAuthenticationChallenge, nil)
                    return
                }
                completionHandler(.useCredential, credential)
            }

            guard let serverTrust = challenge.protectionSpace.serverTrust else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            guard let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
                  let serverPublicKey = SecCertificateCopyKey(serverCertificate),
                  let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
            }

            func cancelAuthenticationChallengeWithLog(key: String, value: String) {
                Common_Logs.debug("ServerPublicKey: \(serverPublicKey)\nServerPublicKeyData: \(serverPublicKeyData)")
                Common_Logs.error("Unexpected \(key): [\(value)]")
                completionHandler(.cancelAuthenticationChallenge, nil)
            }

            //
            // Challenge Type : SSL Pinning - Public Key Provided
            //
            if let serverPublicHashKeys, !serverPublicHashKeys.isEmpty {
                func sha256(data: Data) -> String {
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
                // Server public key
                let serverPublicKeyDataHash = sha256(data: serverPublicKeyData as Data)
                if serverPublicHashKeys.contains(serverPublicKeyDataHash) {
                    // Success!
                    completionHandler(.useCredential, URLCredential(trust: serverTrust))
                    return
                } else {
                    cancelAuthenticationChallengeWithLog(key: "serverHashKey", value: "\(serverPublicKeyDataHash)")
                    return
                }
            }

            //
            // Challenge Type : SSL Pinning - Certificate Provided
            //
            if let pathToCertificates,
               !pathToCertificates.isEmpty {
                let localCertificatesData: [Data] = pathToCertificates.compactMap { NSData(contentsOfFile: $0) } as [Data]
                let policy = NSMutableArray()
                policy.add(SecPolicyCreateSSL(true, challenge.protectionSpace.host as CFString))
                let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
                let remoteCertificateData: NSData = SecCertificateCopyData(serverCertificate)
                let existsMatchingLocalCer = localCertificatesData.filter { remoteCertificateData.isEqual(to: $0) }.first != nil
                if isServerTrusted, existsMatchingLocalCer {
                    let credential: URLCredential = URLCredential(trust: serverTrust)
                    // Success!
                    completionHandler(.useCredential, credential)
                    return
                } else {
                    cancelAuthenticationChallengeWithLog(key: "remoteCertificateData", value: "\(Data(remoteCertificateData).base64EncodedString())")
                    //  Common_Logs.error("Unexpected remoteCertificateData: [\(Data(remoteCertificateData).base64EncodedString())]")
                }
            }

            // Pinning failed
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}
