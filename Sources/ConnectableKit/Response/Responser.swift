//
//  Responser.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Vapor

public struct Responser<ResponseData: Connectable>: Vapor.Content, Responsable {
    public var httpStatus: Vapor.HTTPStatus
    public var status: ResponserStatus
    public var message: String?
    public var data: ResponseData?

    public init(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil, data: ResponseData? = nil) {
        self.httpStatus = httpStatus
        self.status = status
        self.message = message
        self.data = data
    }

    public init(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil) where ResponseData == Connector {
        self.httpStatus = httpStatus
        self.status = status
        self.message = message
    }

    struct ResponseDTO: Vapor.Content {
        var status: ResponserStatus
        var message: String?
        var data: ResponseData?

        init(status: ResponserStatus, message: String? = nil, data: ResponseData? = nil) {
            self.status = status
            self.message = message
            self.data = data
        }
    }

    public func encodeResponse(for _: Vapor.Request) async throws -> Vapor.Response {
        let responseDTO = ResponseDTO(status: status, message: message, data: data)
        let encoded = try JSONEncoder().encode(responseDTO)

        let response = Vapor.Response()
        response.status = httpStatus
        response.headers.contentType = .json
        response.body = .init(data: encoded)

        return response
    }
}

public struct Connector: Connectable {
    private init() {}

    public static func toDTO(_ httpStatus: Vapor.HTTPStatus = .ok, status: ResponserStatus = .success, message: String? = nil) -> Responser<Connector> {
        let response = Responser(httpStatus, status: status, message: message)
        return response
    }
}
