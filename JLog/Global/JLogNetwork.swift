//
//  JLogNetwork.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation
import OSLog

enum JLogNetworkError: Error {
    case unknown
}

final class JLogNetwork {
    
    static let shared = JLogNetwork()
    
    private let host: String = Constant.jlogHost
    private let port: Int = Constant.jlogPort
    
    func request(with api: JLogAPI) async throws -> (Data, URLResponse) {
        do {
            let request = try self.makeURLRequest(with: api)
            let logger = Logger(subsystem: OSLog.subsystem, category: "[NETWORK]")
            logger.debug("""
                Request: \(request)
                Body: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "nil")
            """)
            let (data, response) = try await URLSession.shared.data(for: request)
            logger.debug("""
                StatusCode: \((response as? HTTPURLResponse)?.statusCode ?? 0)
                Data : \(String(data: data, encoding: .utf8) ?? "nil")
            """)
            return (data, response)
        } catch {
            let logger = Logger(subsystem: OSLog.subsystem, category: "[ERROR]")
            logger.debug("""
                Error: \(error)
            """)
            throw error
        }
        
    }
    
    private func makeURLRequest(with api: JLogAPI) throws -> URLRequest {
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = self.host
        urlComponents.port = self.port
        #if DEBUG
        urlComponents.path = "/test\(api.path)"
        #else
        urlComponents.path = api.path
        #endif
        
        switch api.method {
        case .get(let queryItems) :
            urlComponents.queryItems = queryItems
        default :
            break
        }
        
        guard let url = urlComponents.url else { throw JLogNetworkError.unknown }
        
        var request = URLRequest(url: url)
        switch api.method {
        case let .post(data), let .put(data), let .delete(data):
            request.httpBody = try? JSONSerialization.data(withJSONObject: data)
        default :
            break
        }
        request.httpMethod = api.method.string
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}

protocol JLogAPI {
    var path: String { get }
    var method: Method { get }
}

enum Method {
    case get(queryItems: [URLQueryItem]), post(data: [String: Any]), put(data: [String: Any]), delete(data: [String: Any])
    
    var string: String {
        switch self {
        case .get: return "GET"
        case .post : return "POST"
        case .put : return "PUT"
        case .delete: return "DELETE"
        }
    }
}

enum RoomAPI: JLogAPI {
    case create(username: String), join(roomCode: String, username: String)

    var path: String {
        switch self {
        case .create, .join: return "/api/room"
        }
    }
    
    var method: Method {
        switch self {
        case .create(let username) : return .post(data: ["username": username])
        case .join(let roomCode, let username) : return .put(data: ["username": username, "room_code": roomCode])
        }
    }
}

enum LogAPI: JLogAPI {
    case create(roomCode: String, username: String, amount: Int, memo: String?)
    case find(roomCode: String, username: String)
    case modify(roomCode: String, username: String, logId: Int, amount: Int, memo: String?)
    case delete(roomCode: String, username: String, logId: Int)

    var path: String {
        switch self {
        case .create, .find, .modify, .delete: return "/api/log"
        }
    }
    
    var method: Method {
        switch self {
        case let .create(roomCode, username, amount, memo) :
            return .post(data: ["room_code": roomCode, "username": username, "amount": amount, "memo": memo])
        case let .find(roomCode, username) :
            return .get(queryItems: [URLQueryItem(name: "room_code", value: roomCode), URLQueryItem(name: "username", value: username)])
        case let .modify(roomCode, username, logId, amount, memo) :
            return .put(data: ["room_code": roomCode, "username": username, "log_id": logId, "amount": amount, "memo": memo])
        case let .delete(roomCode, username, logId) :
            return .delete(data: ["room_code": roomCode, "username": username, "log_id": logId])
        }
    }
}

extension OSLog {
    static let subsystem = Bundle.main.bundleIdentifier!
    static let network = OSLog(subsystem: subsystem, category: "Network")
    static let debug = OSLog(subsystem: subsystem, category: "Debug")
    static let info = OSLog(subsystem: subsystem, category: "Info")
    static let error = OSLog(subsystem: subsystem, category: "Error")
}
