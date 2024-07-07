//
//  RoomViewModel.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import Foundation

final class RoomViewModel {
    let name: String
    let code: String
    
    private var rawBalance: BalanceDTO? = nil
    private(set) lazy var logs: [LogDTO] = {
        return []
    }()
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}

extension RoomViewModel: RoomViewModelProtocol {
    struct Response: Codable {
        let balance: BalanceDTO
        let logs: [LogDTO]
    }
    
    var balance: String {
        guard let username = self.rawBalance?.username,
              let amount = self.rawBalance?.amount.currency else { return "?" }
        return "\(username) \(amount)"
    }
    
    func searchLogs() async -> Bool {
        do {
            let (data, _) = try await JLogNetwork.shared.request(with: LogAPI.find(roomCode: self.code, username: self.name))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(Response.self, from: data)
            self.rawBalance = response.balance
            self.logs = response.logs
            return true
        } catch {
            return false
        }
    }
    
    func findLog(at index: Int) -> LogCell.ViewData? {
        guard let log = self.logs[safe: index] else { return nil }
        return LogCell.ViewData(log: log, isMine: log.username == self.name)
    }
    
    func deleteLog(at index: Int) async -> Bool {
        guard let log = self.logs[safe: index] else { return false }
        do {
            let (_, response) = try await JLogNetwork.shared.request(with: LogAPI.delete(roomCode: self.code, username: self.name, logId: log.id))
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return false }
            return true
        } catch {
            return false
        }
    }
}
