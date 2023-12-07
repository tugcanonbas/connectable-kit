//
//  ErrorMiddleware.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Vapor

public final class ConnectableErrorMiddleware: Vapor.AsyncMiddleware {
    public typealias ErrorClosure = (Error) -> (Vapor.HTTPResponseStatus, String, Vapor.HTTPHeaders)

    public static func `default`(environment: Vapor.Environment) -> Vapor.ErrorMiddleware {
        return .init { req, error in
            let status: Vapor.HTTPResponseStatus
            let reason: String
            let headers: Vapor.HTTPHeaders

            switch error {
            case let abort as Vapor.AbortError:
                reason = abort.reason
                status = abort.status
                headers = abort.headers
            default:
                reason = environment.isRelease
                    ? "Something went wrong."
                    : String(describing: error)
                status = .internalServerError
                headers = [:]
            }

            req.logger.report(error: error)

            let response = Vapor.Response(status: status, headers: headers)

            do {
                let serverStatus: ResponserStatus = {
                    switch status.code {
                    case 100 ... 199:
                        return .information
                    case 200 ... 299:
                        return .success
                    case 300 ... 399:
                        return .redirection
                    case 400 ... 499:
                        return .failure
                    case 500 ... 599:
                        return .error
                    default:
                        return .error
                    }
                }()
                let serverResponse = Responser<Connector>.ResponseDTO(status: serverStatus, message: reason)
                let errorResponse = serverResponse
                response.body = try .init(data: JSONEncoder().encode(errorResponse), byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)", byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }

    public static func custom(closure: @escaping (Vapor.Request, Error) -> Vapor.Response) -> Vapor.ErrorMiddleware {
        return .init { req, error in
            let response = closure(req, error)
            req.logger.report(error: error)
            return response
        }
    }

    public static func custom(errorClosure: @escaping ErrorClosure) -> Vapor.ErrorMiddleware {
        return .init { req, error in

            let (status, reason, headers) = errorClosure(error)

            req.logger.report(error: error)

            let response = Vapor.Response(status: status, headers: headers)

            do {
                let serverStatus: ResponserStatus = {
                    switch status.code {
                    case 100 ... 199:
                        return .information
                    case 200 ... 299:
                        return .success
                    case 300 ... 399:
                        return .redirection
                    case 400 ... 499:
                        return .failure
                    case 500 ... 599:
                        return .error
                    default:
                        return .error
                    }
                }()
                let serverResponse = Responser<Connector>.ResponseDTO(status: serverStatus, message: reason)
                let errorResponse = serverResponse
                response.body = try .init(data: JSONEncoder().encode(errorResponse), byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "application/json; charset=utf-8")
            } catch {
                response.body = .init(string: "Oops: \(error)", byteBufferAllocator: req.byteBufferAllocator)
                response.headers.replaceOrAdd(name: .contentType, value: "text/plain; charset=utf-8")
            }
            return response
        }
    }

    public func respond(to request: Vapor.Request, chainingTo next: Vapor.AsyncResponder) async throws -> Vapor.Response {
        try await next.respond(to: request)
    }
}
