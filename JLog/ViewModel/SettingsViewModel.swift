//
//  SettingsViewModel.swift
//  JLog
//
//  Created by 이지수 on 7/20/24.
//

import Foundation

final class SettingsViewModel: SettingsViewModelProtocol {
    let name: String
    let code: String
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
    
    func syncAll() async -> Bool {
        do {
            let (data, _) = try await JLogNetwork.shared.request(with: LogAPI.find(roomCode: self.code, username: self.name))
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let response = try decoder.decode(RoomViewModel.Response.self, from: data)
            
            guard let serverSavedLastLog = response.logs.last else { return true }
            let predicate = NSPredicate(format: "createdAt >= %@", serverSavedLastLog.createdAt as NSDate)
            let localLogs:[LogDTO] = await LocalStorageManager.shared.fetch(with: predicate).sorted(by: >)
            let localBalance: BalanceDTO? = await LocalStorageManager.shared.fetch()
            
            await self.syncLogs(oldValue: localLogs, newValue: response.logs)
            await self.syncBalance(oldValue: localBalance, newValue: response.balance)
            
            return true
        } catch {
            return false
        }
    }
    
    private func syncLogs(oldValue: [LogDTO], newValue: [LogDTO]) async -> Bool {
        var oldSet = Set(oldValue)
        let newSet = Set(newValue)
        var isSuccess: Bool = true
        
        // 중복 저장되거나 서버에서만 삭제된 로그를 찾아 삭제
        let oldCountedSet = NSCountedSet(array: oldValue)
        let duplicatedIDs = Array(oldCountedSet.filter({ oldCountedSet.count(for: $0) > 1 })).compactMap({ ($0 as? LogDTO)?.id })
        let deletedIDs = Array(oldSet.subtracting(newValue)).map({ $0.id })
        let needToDeleteIDs = Set(duplicatedIDs + deletedIDs)
        if needToDeleteIDs.isEmpty == false {
            let predicate = NSPredicate(format: "id IN %@", Array(needToDeleteIDs))
            let _: [LogDTO] = await LocalStorageManager.shared.deleteAll(with: predicate)
            oldSet = oldSet.filter({ needToDeleteIDs.contains($0.id) == false })
        }
        
        // 추가해야할 로그 찾기
        let newLogs = Array(newSet.subtracting(oldSet))
        if newLogs.isEmpty == false {
            let insertSuccess = await LocalStorageManager.shared.insert(newLogs)
            isSuccess = isSuccess && insertSuccess
        }
        
        // 수정된 로그 찾기
        var interSectionDict: [Int64: [LogDTO]] = [:]
        (newLogs + Array(oldSet)).forEach({
            interSectionDict[$0.id] = (interSectionDict[$0.id] ?? []) + [$0]
        })
        let needToModifyLogs: [LogDTO] = interSectionDict.compactMap { (key, value) -> (LogDTO, LogDTO)? in
            guard value.count == 2,
                  let oldValue = value[safe: 0],
                  let newValue = value[safe: 1]
            else { return nil }
            return (oldValue, newValue)
        }.filter { (oldValue, newValue) in
            return (oldValue.memo == newValue.memo && oldValue.amount == newValue.amount) == false
        }.map { (oldValue, newValue) in
            return newValue
        }
        if needToModifyLogs.isEmpty == false {
            let modifySuccess = await LocalStorageManager.shared.modify(to: needToModifyLogs)
            isSuccess = isSuccess && modifySuccess
        }
        
        return isSuccess
    }
    
    private func syncBalance(oldValue: BalanceDTO?, newValue: BalanceDTO) async {
        if let oldValue, oldValue != newValue {
            await LocalStorageManager.shared.modify(to: newValue)
        } else {
            await LocalStorageManager.shared.insert(newValue)
        }
    }
    
    func clearLogs() async -> Bool {
        let _: [LogDTO] = await LocalStorageManager.shared.deleteAll()
        return true
    }
    
    func clearBalance() async -> Bool {
        let _: [BalanceDTO] = await LocalStorageManager.shared.deleteAll()
        return true
    }
}
