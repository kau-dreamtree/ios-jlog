//
//  SettingsViewController.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//

import UIKit
import Combine

protocol SettingsViewModelProtocol {
    var liveBackUpIsOnPublisher: AnyPublisher<Bool, Never> { get }
    
    var liveBackUpIsOn: Bool { get }
    
    func update(on: SettingsViewModel.Data)
    func backUp(on: Bool) async -> Bool
    func syncAll() async -> Bool
    func clearLogs() async -> Bool
    func clearBalance() async -> Bool
}

enum SettingsMenuType {
    case normal
    case toggle
}

protocol SettingsMenu: CaseIterable {
    associatedtype RawValue = Int
    
    var title: String { get }
    var type: SettingsMenuType { get }
}

final class SettingsViewController: JLogBaseCollectionViewController {
    
    enum DataManageMenu: Int, SettingsMenu {
        case liveBackUp = 0, syncAll = 1
        
        var title: String {
            switch self {
            case .liveBackUp : "실시간 백업"
            case .syncAll : "동기화하기"
            }
        }
        
        var type: SettingsMenuType {
            switch self {
            case .liveBackUp : return .toggle
            default : return .normal
            }
        }
    }
    
    #if DEBUG
    enum DebugMenu: Int, SettingsMenu {
        case clearLogs = 0, clearBalance
        
        var title: String {
            switch self {
            case .clearLogs : "로그 데이터 초기화하기"
            case .clearBalance : "총 잔액 데이터 초기화하기"
            }
        }
        
        var type: SettingsMenuType {
            switch self {
            default : return .normal
            }
        }
    }
    #endif
    
    private let viewModel: SettingsViewModelProtocol
    private var cancellables: Set<AnyCancellable> = Set()
    
    init(viewModel: SettingsViewModelProtocol) {
        self.viewModel = viewModel
        
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        super.init(collectionViewLayout: layout)
        
        self.collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.identifier)
        self.collectionView.register(ToggleSettingCell.self, forCellWithReuseIdentifier: ToggleSettingCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.updateNavigationController()
        self.syncAction()
    }
    
    private func syncAction() {
        self.viewModel.liveBackUpIsOnPublisher
            .dropFirst()
            .sink { [weak self] isOn in
                self?.action(with: DataManageMenu.liveBackUp)(isOn)
            }
            .store(in: &cancellables)
    }
    
    private func updateNavigationController() {
        self.navigationItem.title = "설정"
    }
    
    private func action(with menu: any SettingsMenu) -> ((Bool?) -> Void) {
        return { isOn in
            Task {
                self.isLoading.activate()
                let isSuccess: Bool
                switch menu {
                case DataManageMenu.liveBackUp :
                    isSuccess = await self.viewModel.backUp(on: isOn ?? false)
                case DataManageMenu.syncAll :
                    isSuccess = await self.viewModel.syncAll()
                #if DEBUG
                case DebugMenu.clearLogs :
                    isSuccess = await self.viewModel.clearLogs()
                case DebugMenu.clearBalance :
                    isSuccess = await self.viewModel.clearBalance()
                #endif
                default :
                    return
                }
                self.isLoading.deactivate()
                if menu.type == .toggle {
                    let successMessage = (isOn ?? false) ? "시작" : "종료"
                    self.alert(with: "\(menu.title) \(successMessage) \(isSuccess ? "완료" : "실패")")
                }
                self.alert(with: "\(menu.title) \(isSuccess ? "완료" : "실패")")
            }
        }
    }
    
    // MARK: UICollectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        #if DEBUG
        return 2
        #else
        return 1
        #endif
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0 : return DataManageMenu.allCases.count
        #if DEBUG
        case 1 : return DebugMenu.allCases.count
        #endif
        default : return 0
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let menu: (any SettingsMenu)?
        switch indexPath.section {
        case 0 : menu = DataManageMenu(rawValue: indexPath.row)
        #if DEBUG
        case 1 : menu = DebugMenu(rawValue: indexPath.row)
        #endif
        default : return UICollectionViewCell()
        }
        
        guard let menu else { return UICollectionViewCell() }
        
        if menu.type == .toggle {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ToggleSettingCell.identifier, for: indexPath) as? ToggleSettingCell
            cell?.update(title: menu.title, isOn: viewModel.liveBackUpIsOn) { isOn in
                self.viewModel.update(on: .init(liveBackUpIsOn: isOn))
            }
            return cell ?? UICollectionViewCell()
        }
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
        cell.update(title: menu.title)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let menu: (any SettingsMenu)?
        switch indexPath.section {
        case 0 : menu = DataManageMenu(rawValue: indexPath.row)
        #if DEBUG
        case 1 : menu = DebugMenu(rawValue: indexPath.row)
        #endif
        default : return
        }
        guard let menu else { return }
        
        if menu.type == .toggle {
            self.viewModel.update(on: .init(liveBackUpIsOn: !self.viewModel.liveBackUpIsOn))
        } else {
            self.action(with: menu)(nil)
        }
    }
}
