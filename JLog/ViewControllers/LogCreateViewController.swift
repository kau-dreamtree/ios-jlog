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
    
    func enter(with: Int, memo: String?) async -> Bool
}

final class LogCreateViewController: JLogBaseViewController {
    
    private weak var delegate: RefreshRoomViewDelegate?
    
    private let viewModel: LogCreateViewModelProtocol
    
    private let amount: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("amount")
        label.font = .largeFont
        label.textColor = .secondaryLabel
        return label
    }()
    private let amountInput = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.font = .regularFont
        field.textColor = .secondaryLabel
        field.leftViewMode = .always
        return field
    }()
    private let amountInputBorder = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        return view
    }()
    private let memo: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("memo")
        label.font = .largeFont
        label.textColor = .secondaryLabel
        return label
    }()
    private let optional: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("braced_optional")
        label.font = .smallFont
        label.textColor = .secondaryLabel
        return label
    }()
    private let memoInput = {
        let field = UITextField()
        field.font = .regularFont
        field.textColor = .secondaryLabel
        field.leftViewMode = .always
        return field
    }()
    private let memoInputBorder = {
        let view = UIView()
        view.backgroundColor = .secondaryLabel
        return view
    }()
    private let enter: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .regularFont
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .buttonOff
        button.isEnabled = false
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
            self.amountInput.text = "\(amount)"
        }
        self.memoInput.text = self.viewModel.log?.memo
        self.enter.setTitle(self.viewModel.enterTitle, for: .normal)
        
        self.setupLayout()
        self.setButton()
        self.setField()
    }
    
    private func setupLayout() {
        self.view.addSubviews([self.amount, self.amountInput, self.amountInputBorder, self.memo, self.optional, self.memoInput, self.memoInputBorder, self.enter])
        
        NSLayoutConstraint.activate([
            self.amount.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.amount.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        NSLayoutConstraint.activate([
            self.amountInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.amountInput.topAnchor.constraint(equalTo: self.amount.bottomAnchor, constant: 10),
            self.amountInput.heightAnchor.constraint(equalToConstant: 50),
            self.amountInput.leadingAnchor.constraint(equalTo: self.amount.leadingAnchor),
            self.amountInput.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        NSLayoutConstraint.activate([
            self.amountInputBorder.leadingAnchor.constraint(equalTo: self.amountInput.leadingAnchor),
            self.amountInputBorder.trailingAnchor.constraint(equalTo: self.amountInput.trailingAnchor),
            self.amountInputBorder.bottomAnchor.constraint(equalTo: self.amountInput.bottomAnchor),
            self.amountInputBorder.heightAnchor.constraint(equalToConstant: 2)
        ])
        NSLayoutConstraint.activate([
            self.memo.leadingAnchor.constraint(equalTo: self.amount.leadingAnchor),
            self.memo.topAnchor.constraint(equalTo: self.amountInput.bottomAnchor, constant: 20)
        ])
        NSLayoutConstraint.activate([
            self.optional.leadingAnchor.constraint(equalTo: self.amount.trailingAnchor),
            self.optional.centerYAnchor.constraint(equalTo: self.memo.centerYAnchor)
        ])
        NSLayoutConstraint.activate([
            self.memoInput.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.memoInput.topAnchor.constraint(equalTo: self.memo.bottomAnchor, constant: 10),
            self.memoInput.heightAnchor.constraint(equalToConstant: 50),
            self.memoInput.leadingAnchor.constraint(equalTo: self.amount.leadingAnchor),
            self.memoInput.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        NSLayoutConstraint.activate([
            self.memoInputBorder.leadingAnchor.constraint(equalTo: self.memoInput.leadingAnchor),
            self.memoInputBorder.trailingAnchor.constraint(equalTo: self.memoInput.trailingAnchor),
            self.memoInputBorder.bottomAnchor.constraint(equalTo: self.memoInput.bottomAnchor),
            self.memoInputBorder.heightAnchor.constraint(equalToConstant: 2)
        ])
        NSLayoutConstraint.activate([
            self.enter.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.enter.topAnchor.constraint(equalTo: self.memoInput.bottomAnchor, constant: 15),
            self.enter.leadingAnchor.constraint(equalTo: self.memoInput.leadingAnchor),
            self.enter.trailingAnchor.constraint(equalTo: self.memoInput.trailingAnchor),
            self.enter.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setButton() {
        self.enter.addAction(UIAction { [weak self] _ in
            guard let self,
                  let amountString = self.amountInput.text,
                  let amount = Int(amountString)
            else { return }
            let memo = self.memoInput.text
            self.enter(with: amount, memo: memo?.isEmpty == true ? nil : memo)
        }, for: .touchUpInside)
    }
    
    private func setField() {
        self.amountInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let amount = self.amountInput.text ?? ""
            self.enter.isEnabled = amount.isEmpty == false
            self.enter.backgroundColor = amount.isEmpty == false ? .buttonOn : .buttonOff
        }, for: .editingChanged)
        
        self.amountInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.amount.textColor = .label
            self.amountInput.textColor = .label
            self.amountInputBorder.backgroundColor = .label
        }, for: .editingDidBegin)
        
        self.amountInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.amount.textColor = .secondaryLabel
            self.amountInput.textColor = .secondaryLabel
            self.amountInputBorder.backgroundColor = .secondaryLabel
        }, for: .editingDidEnd)
        
        self.memoInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let amount = self.amountInput.text ?? ""
            self.enter.isEnabled = amount.isEmpty == false
            self.enter.backgroundColor = amount.isEmpty == false ? .buttonOn : .buttonOff
        }, for: .editingChanged)
        
        self.memoInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.memo.textColor = .label
            self.memoInput.textColor = .label
            self.optional.textColor = .label
            self.memoInputBorder.backgroundColor = .label
        }, for: .editingDidBegin)
        
        self.memoInput.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            self.memo.textColor = .secondaryLabel
            self.memoInput.textColor = .secondaryLabel
            self.optional.textColor = .secondaryLabel
            self.memoInputBorder.backgroundColor = .secondaryLabel
        }, for: .editingDidEnd)
    }
    
    private func enter(with amount: Int, memo: String?) {
        Task {
            self.isLoading.activate()
            let result = await self.viewModel.enter(with: amount, memo: memo)
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
    
    func enter(with amount: Int, memo: String?) async -> Bool {
        do {
            let (_, response) = try await JLogNetwork.shared.request(with: LogAPI.create(roomCode: self.code, username: self.name, amount: amount, memo: memo))
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
    
    func enter(with amount: Int, memo: String?) async -> Bool {
        do {
            guard let log else { return false }
            let (_, response) = try await JLogNetwork.shared.request(with: LogAPI.modify(roomCode: self.code, username: self.name, logId: log.id, amount: amount, memo: memo))
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return false }
            return true
        } catch {
            return false
        }
    }
}
