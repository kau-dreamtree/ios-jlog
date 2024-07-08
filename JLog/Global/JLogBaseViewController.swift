//
//  JLogBaseViewController.swift
//  JLog
//
//  Created by 이지수 on 2/23/24.
//

import UIKit

class JLogBaseViewController: UIViewController {
    private(set) lazy var isLoading: LoadingView = LoadingView(view: self.view, activityIndicatorStyle: .large)
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
}

class JLogBaseCollectionViewController: UICollectionViewController {
    private(set) lazy var isLoading: LoadingView = LoadingView(view: self.collectionView, activityIndicatorStyle: .large)
}
