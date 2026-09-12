//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftOpenAPIGenerator open source project
//
// Copyright (c) 2023 Apple Inc. and the SwiftOpenAPIGenerator project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftOpenAPIGenerator project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
//
// https://github.com/apple/swift-openapi-generator/blob/main/Examples/logging-middleware-swift-log-example/Sources/LoggingMiddleware/LoggingMiddleware.swift
// を元に、クライアント側だけ残した。

import Foundation
import HTTPTypes
import Logging
import OpenAPIRuntime

/// リクエストとレスポンスをログに出す。
actor LoggingMiddleware {
    private let logger: Logger
    private let bodyLoggingPolicy: BodyLoggingPolicy

    init(logger: Logger = LoggingMiddleware.defaultLogger, bodyLoggingPolicy: BodyLoggingPolicy = .never) {
        self.logger = logger
        self.bodyLoggingPolicy = bodyLoggingPolicy
    }

    /// 既定のハンドラは info 以上しか出さないので debug まで下げる。
    private static var defaultLogger: Logger {
        var logger = Logger(label: "AozoraReader.API")
        logger.logLevel = .debug
        return logger
    }
}

extension LoggingMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (requestBodyToLog, requestBodyForNext) = try await bodyLoggingPolicy.process(body)
        log(request, requestBodyToLog)

        do {
            let (response, responseBody) = try await next(request, requestBodyForNext, baseURL)
            let (responseBodyToLog, responseBodyForNext) = try await bodyLoggingPolicy.process(responseBody)
            log(request, response, responseBodyToLog)
            return (response, responseBodyForNext)
        } catch {
            log(request, failedWith: error)
            throw error
        }
    }
}

private extension LoggingMiddleware {
    func log(_ request: HTTPRequest, _ body: BodyLoggingPolicy.BodyLog) {
        logger.debug(
            "Request",
            metadata: [
                "method": .stringConvertible(request.method),
                "path": .string(request.path ?? "<nil>"),
                "body": .stringConvertible(body),
            ]
        )
    }

    func log(_ request: HTTPRequest, _ response: HTTPResponse, _ body: BodyLoggingPolicy.BodyLog) {
        logger.debug(
            "Response",
            metadata: [
                "method": .stringConvertible(request.method),
                "path": .string(request.path ?? "<nil>"),
                "status": .stringConvertible(response.status.code),
                "body": .stringConvertible(body),
            ]
        )
    }

    func log(_ request: HTTPRequest, failedWith error: any Error) {
        logger.warning(
            "Request error",
            metadata: [
                "method": .stringConvertible(request.method),
                "path": .string(request.path ?? "<nil>"),
                "error": .string(error.localizedDescription),
            ]
        )
    }
}

/// body をどこまでログに出すか。
enum BodyLoggingPolicy {
    /// body を出さない。
    case never
    /// 長さが分かっていて `maxBytes` 以下なら出す。
    case upTo(maxBytes: Int)

    enum BodyLog: Equatable, CustomStringConvertible {
        case none
        case redacted
        case unknownLength
        case tooManyBytesToLog(Int64)
        case complete(Data)

        var description: String {
            switch self {
            case .none: "<none>"
            case .redacted: "<redacted>"
            case .unknownLength: "<unknown length>"
            case .tooManyBytesToLog(let byteCount): "<\(byteCount) bytes>"
            case .complete(let data): String(data: data, encoding: .utf8) ?? String(describing: data)
            }
        }
    }

    func process(_ body: HTTPBody?) async throws -> (bodyToLog: BodyLog, bodyForNext: HTTPBody?) {
        switch (body?.length, self) {
        case (.none, _): (.none, body)
        case (_, .never): (.redacted, body)
        case (.unknown, _): (.unknownLength, body)
        case (.known(let length), .upTo(let maxBytesToLog)) where length > maxBytesToLog:
            (.tooManyBytesToLog(length), body)
        case (.known, .upTo(let maxBytesToLog)):
            try await {
                let data = try await Data(collecting: body!, upTo: maxBytesToLog)
                return (.complete(data), HTTPBody(data))
            }()
        }
    }
}
