//
//  ResponserStatus.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Foundation

public enum ResponserStatus: String {
    case information
    case success
    case redirection
    case failure
    case error
}

extension ResponserStatus: Codable {}
