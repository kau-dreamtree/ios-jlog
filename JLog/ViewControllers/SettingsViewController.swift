//
//  SettingsViewController.swift
//  JLog
//
//  Created by 이지수 on 7/7/24.
//

import UIKit

#if DEBUG

final class SettingsViewController: JLogBaseCollectionViewController {
    
    enum DebugMenu: Int, CaseIterable {
        case clearLogs = 0, clearBalance
        
        var title: String {
            switch self {
            case .clearLogs : "로그 데이터 초기화하기"
            case .clearBalance : "총 잔액 데이터 초기화하기"
            }
        }
    }
    
    init() {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        super.init(collectionViewLayout: layout)
        
        self.collectionView.register(SettingCell.self, forCellWithReuseIdentifier: SettingCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    func action(with menu: DebugMenu) -> (() -> Void) {
        return {
            Task {
                self.isLoading.activate()
                switch menu {
                case .clearLogs :
                    let _: [LogDTO] = await LocalStorageManager.shared.deleteAll()
                case .clearBalance :
                    let _: [BalanceDTO] = await LocalStorageManager.shared.deleteAll()
                }
                self.isLoading.deactivate()
                self.alert(with: "\(menu.title) 완료")
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return DebugMenu.allCases.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell,
                  let menu = DebugMenu(rawValue: indexPath.row) else { return UICollectionViewCell() }
            cell.update(title: menu.title)
            return cell
        default :
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 0,
              let menu = DebugMenu(rawValue: indexPath.row) else { return }
        self.action(with: menu)()
    }
}

#endif
