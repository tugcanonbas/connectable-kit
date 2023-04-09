//
//  Responsable.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Vapor

public protocol Responsable: ResponseEncodable {
    associatedtype ResponseType
    var httpStatus: Vapor.HTTPStatus { get }
    var status: ResponserStatus { get }
    var message: String? { get }
    var data: ResponseType? { get }
    func encodeResponse(for request: Vapor.Request) async throws -> Vapor.Response
}
