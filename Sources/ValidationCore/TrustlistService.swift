//
//  File.swift
//  
//
//  Created by Dominik Mocher on 26.04.21.
//

import Foundation
import SwiftCBOR
import Security

public protocol TrustlistService {
    func key(for keyId: Data, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func key(for keyId: Data, cwt: CWT, keyType: CertType, completionHandler: @escaping (Result<SecKey, ValidationError>)->())
    func updateTrustlistIfNecessary(completionHandler: @escaping (ValidationError?)->())
}
