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
    var logs: [LogDTO] { get }
    
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
    
    private lazy var navigationTitle: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(codeButtonDidTouched)))
        return view
    }()
    private let room: UILabel = {
        let label = UILabel()
        label.text = "jlog"
        label.font = .logo
        label.textColor = .label
        return label
    }()
    private let code: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 10)
        let image = UIImage(systemName: "doc.on.doc", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleToFill
        button.tintColor = .secondaryLabel
        button.setTitleColor(.secondaryLabel, for: .normal)
        button.titleLabel?.font = .smallFont
        button.isEnabled = false
        return button
    }()
    private lazy var add: UIButton = {
        let button = UIButton()
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 30)
        let image = UIImage(systemName: "plus", withConfiguration: imageConfig)
        button.setImage(image, for: .normal)
        button.tintColor = .systemBackground
        button.imageView?.contentMode = .scaleToFill
        button.layer.cornerRadius = 25
        button.backgroundColor = .systemGray2
        button.addTarget(self, action: #selector(addButtonDidTouched), for: .touchUpInside)
        return button
    }()
    #if !REAL
    private lazy var setting: UIBarButtonItem = {
        let imageConfig = UIImage.SymbolConfiguration(pointSize: 20)
        let image = UIImage(systemName: "gearshape", withConfiguration: imageConfig)
        let button = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(settingButtonDidTouched))
        button.tintColor = .label
        return button
    }()
    #endif
    
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
        self.refreshRoom()
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.logs, self.add])
        
        NSLayoutConstraint.activate([
            self.logs.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.logs.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.logs.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            self.logs.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.logs.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            self.add.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.add.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            self.add.widthAnchor.constraint(equalToConstant: 50),
            self.add.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        self.setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        self.code.setTitle(self.viewModel.code, for: .normal)
        
        #if !REAL
        self.navigationItem.rightBarButtonItem = self.setting
        #endif
        self.navigationItem.titleView = self.navigationTitle
        self.navigationController?.isNavigationBarHidden = false
        
        let backBarButton = UIBarButtonItem(title: "", style: .plain, target: self, action: nil)
        backBarButton.tintColor = .label
        self.navigationItem.backBarButtonItem = backBarButton
        
        self.navigationTitle.addSubviews([self.room, self.code])
        
        NSLayoutConstraint.activate([
            self.navigationTitle.widthAnchor.constraint(equalToConstant: 100),
            self.navigationTitle.heightAnchor.constraint(equalToConstant: 44)
        ])
        NSLayoutConstraint.activate([
            self.room.centerXAnchor.constraint(equalTo: self.navigationTitle.centerXAnchor),
            self.room.bottomAnchor.constraint(equalTo: self.code.topAnchor)
        ])
        NSLayoutConstraint.activate([
            self.code.centerXAnchor.constraint(equalTo: self.navigationTitle.centerXAnchor),
            self.code.bottomAnchor.constraint(equalTo: self.navigationTitle.bottomAnchor)
        ])
    }

    @objc
    private func codeButtonDidTouched() {
        let activityViewController = UIActivityViewController(activityItems: [self.viewModel.code], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @objc
    private func addButtonDidTouched() {
        let viewModel = LogCreateViewModel(name: self.viewModel.name, code: self.viewModel.code)
        let vc = LogCreateViewController(viewModel: viewModel, delegate: self)
        self.present(vc, animated: true)
    }
    
    #if !REAL
    @objc
    private func settingButtonDidTouched() {
        let vc = SettingsViewController(viewModel: SettingsViewModel(name: self.viewModel.name, code: self.viewModel.code))
        self.navigationController?.pushViewController(vc, animated: true)
    }
    #endif
    
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
            self.logs.reloadData()
            switch result {
            case true : self.add.isEnabled = true
            case false : break
            }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.section == 1 else { return }
        let viewModel = LogDetailViewModel(log: self.viewModel.logs[indexPath.row])
        let vc = LogDetailViewController(viewModel: viewModel)
        self.present(vc, animated: true)
    }
}
