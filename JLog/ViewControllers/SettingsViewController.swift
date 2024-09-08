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
    var numberOfSections: Int { get }
    
    func cellCount(section: Int) -> Int
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
                guard let self, let cell = self.collectionView(self.collectionView, cellForItemAt: IndexPath(row: 0, section: 0)) as? ToggleSettingCell else { return }
                let menu = DataManageMenu.liveBackUp
                self.action(with: menu)(isOn)
                cell.update(title: menu.title, isOn: isOn) { [weak self] isOn in
                    self?.viewModel.update(on: .init(liveBackUpIsOn: isOn))
                }
            }
            .store(in: &cancellables)
    }
    
    private func updateNavigationController() {
        self.navigationItem.title = "설정"
    }
    
    private func action(with menu: any SettingsMenu) -> ((Bool?) -> Void) {
        return { isOn in
            let isOn = isOn ?? false
            Task {
                self.isLoading.activate()
                let isSuccess: Bool
                switch menu {
                case DataManageMenu.liveBackUp :
                    isSuccess = await self.viewModel.backUp(on: isOn)
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
                    let successMessage = isOn ? "시작" : "종료"
                    self.alert(with: "\(menu.title) \(successMessage) \(isSuccess ? "완료" : "실패")")
                    if isSuccess == false {
                        self.viewModel.update(on: .init(liveBackUpIsOn: !isOn))
                    } else {
                        self.collectionView.reloadData()
                    }
                }
                self.alert(with: "\(menu.title) \(isSuccess ? "완료" : "실패")")
            }
        }
    }
    
    // MARK: UICollectionView
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.numberOfSections
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.cellCount(section: section)
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
