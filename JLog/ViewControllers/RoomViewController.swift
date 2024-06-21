//
//  RoomViewController.swift
//  JLog
//
//  Created by 이지수 on 2/16/24.
//

import UIKit

protocol RefreshRoomViewDelegate: NSObject {
    func refreshRoom()
}

protocol RoomViewModelProtocol {
    var name: String { get }
    var code: String { get }
    var balance: String { get }
    var logs: [Log] { get }
    
    func searchLogs() async -> Bool
    func findLog(at: Int) -> LogCell.ViewData?
    func deleteLog(at: Int) async -> Bool
}

final class RoomViewController: JLogBaseViewController {
    
    private let viewModel: RoomViewModelProtocol
    
    private lazy var logs = {
        var config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        config.trailingSwipeActionsConfigurationProvider = swipeActions
        
        let layout = UICollectionViewCompositionalLayout.list(using: config)

        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.backgroundColor = .systemBackground
        
        view.register(BalanceCell.self, forCellWithReuseIdentifier: BalanceCell.identifier)
        view.register(LogCell.self, forCellWithReuseIdentifier: LogCell.identifier)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction(handler: { [weak self] _ in
            self?.refreshRoom()
        }), for: .valueChanged)
        view.refreshControl = refreshControl
        
        return view
    }()
    
    private let navigationBar: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.opaqueSeparator.cgColor
        return view
    }()
    private let room: UILabel = {
        let label = UILabel()
        label.text = "jlog"
        label.font = .logo
        label.textColor = .label
        return label
    }()
    private let code: UILabel = {
        let label = UILabel()
        label.font = .smallFont
        label.textColor = .secondaryLabel
        return label
    }()
    private let add: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleToFill
        return button
    }()
    private let info: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "info.circle", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        button.imageView?.contentMode = .scaleToFill
        return button
    }()
    
    init(viewModel: RoomViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refreshRoom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupLayout()
        self.setupButton()
        self.refreshRoom()
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.navigationBar, self.logs])
        
        NSLayoutConstraint.activate([
            self.logs.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.logs.topAnchor.constraint(equalTo: self.navigationBar.bottomAnchor),
            self.logs.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.logs.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.logs.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        self.setupCustomNavigationBar()
    }
    
    private func setupCustomNavigationBar() {
        self.code.text = "#\(self.viewModel.code)"
        
        self.navigationBar.addSubviews([self.room, self.code, self.add, self.info])
        
        NSLayoutConstraint.activate([
            navigationBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: -1),
            navigationBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 1),
            navigationBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: -1),
            navigationBar.heightAnchor.constraint(equalToConstant: self.view.safeAreaInsets.top + 121)
        ])
        
        NSLayoutConstraint.activate([
            self.room.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            self.room.bottomAnchor.constraint(equalTo: self.code.topAnchor)
        ])
        NSLayoutConstraint.activate([
            self.code.centerXAnchor.constraint(equalTo: navigationBar.centerXAnchor),
            self.code.bottomAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: -10)
        ])
        NSLayoutConstraint.activate([
            self.add.centerYAnchor.constraint(equalTo: self.room.bottomAnchor, constant: -10),
            self.add.trailingAnchor.constraint(equalTo: self.navigationBar.trailingAnchor, constant: -20),
            self.add.heightAnchor.constraint(equalToConstant: 25),
            self.add.widthAnchor.constraint(equalToConstant: 25)
        ])
        NSLayoutConstraint.activate([
            self.info.centerYAnchor.constraint(equalTo: self.room.bottomAnchor, constant: -10),
            self.info.leadingAnchor.constraint(equalTo: self.navigationBar.leadingAnchor, constant: 20),
            self.info.heightAnchor.constraint(equalToConstant: 25),
            self.info.widthAnchor.constraint(equalToConstant: 25)
        ])
    }
    
    private func setupButton() {
        self.add.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let viewModel = LogCreateViewModel(name: self.viewModel.name, code: self.viewModel.code)
            let vc = LogCreateViewController(viewModel: viewModel, delegate: self)
            self.present(vc, animated: true)
        }, for: .touchUpInside)
        
        self.info.addAction(UIAction { [weak self] _ in
            // TODO: make info button action
        }, for: .valueChanged)
    }
    
    private func swipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath, indexPath.section == 1,
              let log = self.viewModel.findLog(at: indexPath.row)?.log,
              log.username == self.viewModel.name else { return nil }
        let modifyAction = UIContextualAction(style: .normal, title: LocalizableStrings.localize("modify")) { [weak self] _, _, completion in
            guard let self else { return }
            let viewModel = LogModifyViewModel(name: self.viewModel.name, code: self.viewModel.code, log: log)
            let vc = LogCreateViewController(viewModel: viewModel, delegate: self)
            self.present(vc, animated: true)
        }
        let deleteAction = UIContextualAction(style: .destructive, title: LocalizableStrings.localize("delete")) { [weak self] _, _, completion in
            Task { [weak self] in
                guard let self else { return }
                self.add.isEnabled = false
                
                let result = await self.viewModel.deleteLog(at: indexPath.row)
                switch result {
                case true : self.refreshRoom()
                case false : self.alert(with: LocalizableStrings.localize("retry_delete"))
                }
                
                self.add.isEnabled = true
            }
        }
        return UISwipeActionsConfiguration(actions: [deleteAction, modifyAction])
    }
    
    private func didEndRefreshRoom() {
        guard self.logs.refreshControl?.isRefreshing == true else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.logs.refreshControl?.endRefreshing()
        }
    }
}

extension RoomViewController: RefreshRoomViewDelegate {
    func refreshRoom() {
        Task {[weak self] in
            guard let self else { return }
            self.add.isEnabled = false
            
            let result = await self.viewModel.searchLogs()
            switch result {
            case true : self.logs.reloadData()
            case false : self.alert(with: LocalizableStrings.localize("retry_refresh"))
            }
            
            self.add.isEnabled = true
            self.didEndRefreshRoom()
        }
    }
}

extension RoomViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return self.viewModel.logs.count
        default : return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BalanceCell.identifier, for: indexPath) as? BalanceCell else { return UICollectionViewCell() }
            cell.update(balance: self.viewModel.balance)
            return cell
        default :
            guard let data = self.viewModel.findLog(at: indexPath.row),
                  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LogCell.identifier, for: indexPath) as? LogCell
            else { return UICollectionViewCell() }
            cell.update(with: data)
            return cell
        }
    }
}

extension RoomViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0: return CGSize(width: collectionView.frame.width, height: 150)
        default: return CGSize(width: collectionView.frame.width, height: 50)
        }
    }
}
