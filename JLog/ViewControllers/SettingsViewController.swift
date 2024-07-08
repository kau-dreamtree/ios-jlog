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
        case clearLogs = 0
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
                switch menu {
                case .clearLogs :
                    self.isLoading.activate()
                    let _: [LogDTO] = await LocalStorageManager.shared.deleteAll()
                    self.isLoading.deactivate()
                    self.alert(with: "로그 초기화 완료")
                }
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SettingCell.identifier, for: indexPath) as? SettingCell else { return UICollectionViewCell() }
            cell.update(title: "로그 초기화하기")
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
