//
//  EnteranceViewController.swift
//  JLog
//
//  Created by 이지수 on 2/16/24.
//

import UIKit

final class EnteranceViewController: JLogBaseViewController {
    
    private let viewModel: EnteranceViewModel
    
    private let guide: UILabel = {
        let label = UILabel()
        label.text = LocalizableStrings.localize("enter_code_guide")
        label.font = .largeFont
        label.textColor = .label
        return label
    }()
    private let roomCode: UITextField = {
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
        button.setTitle(LocalizableStrings.localize("enter"), for: .normal)
        button.titleLabel?.font = .regularFont
        button.titleLabel?.textColor = .tertiaryLabel
        button.backgroundColor = .buttonOff
        button.layer.cornerRadius = 10
        return button
    }()
    private let hold: UIButton = {
        let button = UIButton()
        button.setTitle(LocalizableStrings.localize("create_room"), for: .normal)
        button.titleLabel?.font = .regularFont
        button.titleLabel?.textColor = .tertiaryLabel
        button.backgroundColor = .buttonOn
        button.layer.cornerRadius = 10
        return button
    }()
    
    init(viewModel: EnteranceViewModel) {
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
        self.setButton()
        self.setField()
    }

    private func setupLayout() {
        self.view.addSubviews([self.guide, self.roomCode, self.enter, self.hold])
        NSLayoutConstraint.activate([
            self.guide.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.guide.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
        ])
        NSLayoutConstraint.activate([
            self.roomCode.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.roomCode.topAnchor.constraint(equalTo: self.guide.bottomAnchor, constant: 40),
            self.roomCode.heightAnchor.constraint(equalToConstant: 50),
            self.roomCode.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            self.roomCode.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
        NSLayoutConstraint.activate([
            self.enter.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.enter.topAnchor.constraint(equalTo: self.roomCode.bottomAnchor, constant: 20),
            self.enter.leadingAnchor.constraint(equalTo: self.roomCode.leadingAnchor),
            self.enter.trailingAnchor.constraint(equalTo: self.roomCode.trailingAnchor),
            self.enter.heightAnchor.constraint(equalToConstant: 50)
        ])
        NSLayoutConstraint.activate([
            self.hold.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            self.hold.topAnchor.constraint(equalTo: self.enter.bottomAnchor, constant: 5),
            self.hold.leadingAnchor.constraint(equalTo: self.enter.leadingAnchor),
            self.hold.trailingAnchor.constraint(equalTo: self.enter.trailingAnchor),
            self.hold.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setButton() {
        self.enter.addAction(UIAction { [weak self] _ in
            guard let code = self?.roomCode.text else { return }
            self?.isLoading.activate()
            self?.enter.isEnabled = false
            self?.hold.isEnabled = false
            Task { [weak self] in
                let result = await self?.viewModel.enter(withCode: code) ?? false
                switch result {
                case true: self?.enterRoom(withCode: code)
                case false: self?.alert(with: LocalizableStrings.localize("retry_enter"))
                }
                self?.enter.isEnabled = true
                self?.hold.isEnabled = true
                self?.isLoading.deactivate()
            }
        }, for: .touchUpInside)
        
        self.hold.addAction(UIAction { [weak self] _ in
            self?.isLoading.activate()
            self?.enter.isEnabled = false
            self?.hold.isEnabled = false
            Task { [weak self] in
                let code = await self?.viewModel.hold()
                if let code {
                    self?.enterRoom(withCode: code)
                } else {
                    self?.alert(with: LocalizableStrings.localize("retry_create"))
                }
                self?.enter.isEnabled = true
                self?.hold.isEnabled = true
                self?.isLoading.activate()
            }
        }, for: .touchUpInside)
    }
    
    private func setField() {
        self.roomCode.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            let roomCode = self.roomCode.text ?? ""
            self.enter.isEnabled = roomCode.isEmpty == false
            self.enter.backgroundColor = roomCode.isEmpty == false ? .buttonOn : .buttonOff
        }, for: .editingChanged)
    }
    
    private func enterRoom(withCode code: String) {
        let vc = RoomViewController(viewModel: RoomViewModel(name: self.viewModel.name, code: code))
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true)
    }
}

struct EnteranceViewModel {
    let name: String
    
    struct Response: Codable {
        let room_code: String
    }
    
    init(name: String) {
        self.name = name
    }
    
    func enter(withCode code: String) async -> Bool {
        do {
            let (_, response) = try await JLogNetwork.shared.request(with: RoomAPI.join(roomCode: code, username: self.name))
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  (200..<300).contains(statusCode) else { return false }
            self.willEnterRoom(with: code)
            return true
        } catch {
            return false
        }
    }
    
    func hold() async -> String? {
        do {
            let (data, _) = try await JLogNetwork.shared.request(with: RoomAPI.create(username: self.name))
            let roomCode = try JSONDecoder().decode(Response.self, from: data).room_code
            self.willEnterRoom(with: roomCode)
            return roomCode
        } catch {
            return nil
        }
    }
    
    private func willEnterRoom(with code: String) {
        UserDefaults.standard.setValue(code, forKey: Constant.roomKey)
    }
}

extension UIViewController {
    func alert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: LocalizableStrings.localize("confirm"), style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true)
    }
}
