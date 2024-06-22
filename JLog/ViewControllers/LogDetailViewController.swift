//
//  LogDetailViewController.swift
//  JLog
//
//  Created by 이지수 on 6/22/24.
//

import UIKit

protocol LogDetailViewModelProtocol {
    var sectionCount: Int { get }
    
    var topInfo: TopLogDetailCell.ViewData { get }
    var narrowInfo: [NarrowLogDetailCell.ViewData] { get }
    var wideInfo: [WideLogDetailCell.ViewData] { get }
}

final class LogDetailViewController: JLogBaseViewController {
    private let viewModel: LogDetailViewModelProtocol
    
    private lazy var details = {
        var layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = .init(top: 5, left: 0, bottom: 5, right: 0)
        
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.dataSource = self
        view.delegate = self
        view.contentInset = .init(top: 40, left: 0, bottom: 40, right: 0)
        
        view.register(TopLogDetailCell.self, forCellWithReuseIdentifier: TopLogDetailCell.identifier)
        view.register(NarrowLogDetailCell.self, forCellWithReuseIdentifier: NarrowLogDetailCell.identifier)
        view.register(WideLogDetailCell.self, forCellWithReuseIdentifier: WideLogDetailCell.identifier)
        return view
    }()
    
    init(viewModel: LogDetailViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] _ in
            (self?.details.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
        }
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.details])
        
        NSLayoutConstraint.activate([
            self.details.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.details.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.details.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            self.details.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}

extension LogDetailViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.viewModel.sectionCount
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0 : return 1
        case 1 : return self.viewModel.narrowInfo.count
        default : return self.viewModel.wideInfo.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TopLogDetailCell.identifier, for: indexPath) as? TopLogDetailCell else { return UICollectionViewCell() }
            cell.update(with: self.viewModel.topInfo)
            return cell
        case 1 :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NarrowLogDetailCell.identifier, for: indexPath) as? NarrowLogDetailCell else { return UICollectionViewCell() }
            let data = self.viewModel.narrowInfo[indexPath.row]
            cell.update(with: data)
            return cell
        default :
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WideLogDetailCell.identifier, for: indexPath) as? WideLogDetailCell
            else { return UICollectionViewCell() }
            let data = self.viewModel.wideInfo[indexPath.row]
            cell.update(with: .init(title: data.title, content: data.content))
            return cell
        }
    }
}

extension LogDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding = 40.0
        let width = collectionView.frame.width - padding
        switch indexPath.section {
        case 0 : return CGSize(width: width, height: 100)
        case 1 : return CGSize(width: width, height: 50)
        default : 
            let text = self.viewModel.wideInfo[indexPath.row].content
            let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
            let boundingBox = text.boundingRect(with: constraintRect,
                                                options: .usesLineFragmentOrigin,
                                                attributes: [.font: UIFont.smallFont],
                                                context: nil)
            return CGSize(width: width, height: boundingBox.height + 60)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
