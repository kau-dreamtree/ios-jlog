//
//  LoadingView.swift
//  JLog
//
//  Created by 이지수 on 2/23/24.
//

import UIKit

final class LoadingView: UIActivityIndicatorView {
    
    init(view: UIView, activityIndicatorStyle style: UIActivityIndicatorView.Style) {
        super.init(style: style)
        view.addSubview(self)
        self.isHidden = true
        self.updateLayout()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func updateLayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview else { return }
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
        ])
    }
    
    func activate() {
        self.isHidden = false
        self.startAnimating()
    }
    
    func deactivate() {
        self.isHidden = true
        self.stopAnimating()
    }
}
