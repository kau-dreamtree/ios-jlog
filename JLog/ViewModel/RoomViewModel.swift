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
    private(set) var logs: [LogDTO] = []
    
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
    
    private var liveBackupInOn: Bool {
        return UserDefaults.standard.bool(forKey: Constant.isBackUpOnKey)
    }
    
    func searchLogs() async -> Bool {
        if self.liveBackupInOn {
            return await self.searchLogsWithLocalStorage()
        } else {
            return await self.searchLogsWithoutLocalStorage()
        }
    }
    
    private func searchLogsWithLocalStorage() async -> Bool {
        let (localLogs, localBalance) = await self.fetchDataWithLocalStorage()
        if let (serverLogs, serverBalance) = await self.fetchDataWithServer() {
            self.logs = serverLogs
            self.rawBalance = serverBalance
            self.saveLogs(localLogs, serverLogs)
            self.saveBalance(localBalance, serverBalance)
            return true
        } else {
            self.logs = localLogs
            self.rawBalance = localBalance
            return false
        }
    }
    
    private func searchLogsWithoutLocalStorage() async -> Bool {
        guard let (serverLogs, serverBalance) = await self.fetchDataWithServer() else { return false }
        self.logs = serverLogs
        self.rawBalance = serverBalance
        return true
    }
    
    private func fetchDataWithLocalStorage() async -> ([LogDTO], BalanceDTO?) {
        let logs: [LogDTO] = await LocalStorageManager.shared.fetch().sorted(by: >)
        let balance: BalanceDTO? = await LocalStorageManager.shared.fetch()
        return (logs, balance)
    }
    
    private func fetchDataWithServer() async -> ([LogDTO], BalanceDTO)? {
        do {
            let (data, _) = try await JLogNetwork.shared.request(with: LogAPI.find(roomCode: self.code, username: self.name))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(Response.self, from: data)
            return (response.logs, response.balance)
        } catch {
            return nil
        }
    }
    
    private func saveLogs(_ oldValue: [LogDTO], _ newValue: [LogDTO]) {
        let oldIDs = oldValue.map({ $0.id })
        let newLogs = newValue.filter({ oldIDs.contains($0.id) == false })
        Task {
            for log in newLogs {
                await LocalStorageManager.shared.insert(log)
            }
        }
    }
    
    private func saveBalance(_ oldValue: BalanceDTO?, _ newValue: BalanceDTO) {
        guard oldValue != newValue else { return }
        Task {
            if oldValue != nil {
                await LocalStorageManager.shared.modify(to: newValue)
            } else {
                await LocalStorageManager.shared.insert(newValue)
            }
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
            if self.liveBackupInOn {
                await LocalStorageManager.shared.delete(log)
            }
            return true
        } catch {
            return false
        }
    }
}
