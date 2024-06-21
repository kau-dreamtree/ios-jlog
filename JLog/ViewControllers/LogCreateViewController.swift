//
//  LogCreateViewController.swift
//  JLog
//
//  Created by 이지수 on 2/17/24.
//

import UIKit

protocol LogCreateViewModelProtocol {
    var log: Log? { get }
    var enterTitle: String { get }
    
    func enter(with: Int) async -> Bool
}

final class LogCreateViewController: JLogBaseViewController {
    
    private weak var delegate: RefreshRoomViewDelegate?
    
    private let viewModel: LogCreateViewModelProtocol
    
    private let guide: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("enter_amount")
        label.font = .largeFont
        label.textColor = .label
        return label
    }()
    private let amount = {
        let field = UITextField()
        field.keyboardType = .decimalPad
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
        button.titleLabel?.font = .regularFont
        button.backgroundColor = .buttonOff
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(viewModel: LogCreateViewModelProtocol, delegate: RefreshRoomViewDelegate) {
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        if let amount = self.viewModel.log?.amount {
            self.amount.text = "\(amount)"
        }
        self.enter.setTitle(self.viewModel.enterTitle, for: .normal)
        
        self.setupLayout()
        self.setButton()
        self.setField()
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.guide, self.amount, self.enter])
        NSLayoutConstraint.activate([
            self.guide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.guide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        NSLayoutConstraint.activate([
            self.amount.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.amount.topAnchor.constraint(equalTo: self.guide.bottomAnchor, constant: 40),
            self.amount.heightAnchor.constraint(equalToConstant: 50),
            self.amount.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.amount.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        NSLayoutConstraint.activate([
            self.enter.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.enter.topAnchor.constraint(equalTo: self.amount.bottomAnchor, constant: 15),
            self.enter.leadingAnchor.constraint(equalTo: self.amount.leadingAnchor),
            self.enter.trailingAnchor.constraint(equalTo: self.amount.trailingAnchor),
            self.enter.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setButton() {
        self.enter.addAction(UIAction { [weak self] _ in
            guard let self,
                  let amountString = self.amount.text,
                  let amount = Int(amountString) else { return }
            self.enter(with: amount)
        }, for: .touchUpInside)
    }
    
    private func setField() {
        self.amount.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let amount = self.amount.text ?? ""
            self.enter.isEnabled = amount.isEmpty == false
            self.enter.backgroundColor = amount.isEmpty == false ? .tertiaryLabel : .quaternarySystemFill
        }, for: .editingChanged)
    }
    
    private func enter(with amount: Int) {
        Task {
            self.isLoading.activate()
            let result = await self.viewModel.enter(with: amount)
            switch result {
            case true : 
                self.delegate?.refreshRoom()
                self.dismiss(animated: true)
            case false : 
                self.alert(with: LocalizableStrings.localize("retry_upload"))
            }
            self.isLoading.deactivate()
        }
    }
}

struct LogCreateViewModel {
    private let name: String
    private let code: String
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
    }
}

extension LogCreateViewModel: LogCreateViewModelProtocol {
    
    var enterTitle: String { return LocalizableStrings.localize("create") }
    var log: Log? { return nil }
    
    func enter(with amount: Int) async -> Bool {
        do {
            let (_, response) = try await JLogNetwork.shared.request(with: LogAPI.create(roomCode: self.code, username: self.name, amount: amount))
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return false }
            return true
        } catch {
            return false
        }
    }
}

struct LogModifyViewModel: LogCreateViewModelProtocol {
    private let rawLog: Log
    private let name: String
    private let code: String
    
    init(name: String, code: String, log: Log) {
        self.name = name
        self.code = code
        self.rawLog = log
    }
}

extension LogModifyViewModel {
    
    var enterTitle: String { return LocalizableStrings.localize("modify") }
    var log: Log? { return self.rawLog }
    
    func enter(with amount: Int) async -> Bool {
        do {
            guard let log else { return false }
            let (_, response) = try await JLogNetwork.shared.request(with: LogAPI.modify(roomCode: self.code, username: self.name, logId: log.id, amount: amount))
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return false }
            return true
        } catch {
            return false
        }
    }
}
