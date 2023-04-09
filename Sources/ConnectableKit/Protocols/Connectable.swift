//
//  Connectable.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Vapor

public protocol Connectable: Content {
    associatedtype DTO = Responser<Self>
    func toDTO(_ httpStatus: Vapor.HTTPStatus, status: ResponserStatus, message: String?) -> Responser<Self>
}

public extension Connectable {
    func toDTO(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil) -> Responser<Self> {
        let response = Responser(httpStatus, status: status, message: message, data: self)
        return response
    }
}
