//
//  LoginViewController.swift
//  JLog
//
//  Created by 이지수 on 2/16/24.
//

import UIKit

final class LoginViewController: UIViewController {
    
    private let guide: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("enter_name_guide")
        label.font = .largeFont
        label.textColor = .label
        return label
    }()
    private let name: UITextField = {
        let field = UITextField()
        field.font = .regularFont
        field.textColor = .label
        field.layer.borderWidth = 0.5
        field.layer.borderColor = UIColor.gray.cgColor
        field.layer.cornerRadius = 10
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        field.leftViewMode = .always
        return field
    }()
    private let enter: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizableStrings.localize("confirm"), for: .normal)
        button.setTitleColor(.buttonTitle, for: .normal)
        button.titleLabel?.font = .regularFont
        button.backgroundColor = .buttonOff
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        self.setupLayout()
        self.setButton()
        self.setField()
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.guide, self.name, self.enter])
        NSLayoutConstraint.activate([
            self.guide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.guide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        NSLayoutConstraint.activate([
            self.name.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.name.topAnchor.constraint(equalTo: self.guide.bottomAnchor, constant: 40),
            self.name.heightAnchor.constraint(equalToConstant: 50),
            self.name.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.name.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        NSLayoutConstraint.activate([
            self.enter.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.enter.topAnchor.constraint(equalTo: self.name.bottomAnchor, constant: 15),
            self.enter.leadingAnchor.constraint(equalTo: self.name.leadingAnchor),
            self.enter.trailingAnchor.constraint(equalTo: self.name.trailingAnchor),
            self.enter.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setButton() {
        self.enter.addAction(UIAction { [weak self] _ in
            guard let name = self?.name.text else { return }
            UserDefaults.standard.setValue(name, forKey: Constant.usernameKey)
            let vc = EnteranceViewController(viewModel: EnteranceViewModel(name: name))
            vc.modalPresentationStyle = .fullScreen
            self?.present(vc, animated: true)
        }, for: .touchUpInside)
    }
    
    private func setField() {
        self.name.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let username = self.name.text ?? ""
            self.enter.isEnabled = username.isEmpty == false
            self.enter.backgroundColor = username.isEmpty == false ? .buttonOn : .buttonOff
            
            if username.count > Constant.usernameLimit {
                self.name.text = String(username.prefix(Constant.usernameLimit))
            }
        }, for: .editingChanged)
    }
}
