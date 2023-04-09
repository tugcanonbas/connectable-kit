//
//  ConnectableKit.swift
//  ConnectableKit
//
//  Created by Tuğcan ÖNBAŞ on 09.04.2023.
//

import Vapor

public struct ConnectableKit {
    private init() {}

    public static func configureErrorMiddleware(_ app: Vapor.Application) {
        app.middleware = .init()
        app.middleware.use(ConnectableErrorMiddleware.default(environment: app.environment))
    }

    public static func configureCors(_ app: Vapor.Application, configuration: Vapor.CORSMiddleware.Configuration? = nil) {
        let corsConfiguration = configuration ?? Vapor.CORSMiddleware.Configuration(
            allowedOrigin: .all,
            allowedMethods: [.GET, .POST, .PUT, .DELETE, .OPTIONS, .PATCH],
            allowedHeaders: [.accept, .authorization, .contentType, .origin, .xRequestedWith, .userAgent, .accessControlAllowOrigin]
        )

        let corsMiddleware = Vapor.CORSMiddleware(configuration: corsConfiguration)
        app.middleware.use(corsMiddleware)
    }
}
