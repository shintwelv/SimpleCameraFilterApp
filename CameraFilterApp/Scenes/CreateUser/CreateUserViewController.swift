//
//  CreateUserViewController.swift
//  CameraFilterApp
//
//  Created by siheo on 12/18/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import GoogleSignIn
import AuthenticationServices

protocol CreateUserDisplayLogic: AnyObject
{
    func displayLoginStatus(viewModel: CreateUser.LoginStatus.ViewModel)
    func displayUserSignedInWithGoogle(viewModel: CreateUser.GoogleSignIn.ViewModel)
    func displaySignedInUser(viewModel: CreateUser.SignIn.ViewModel)
    func displaySignedOutUser(viewModel: CreateUser.SignOut.ViewModel)
    func displaySignedUpUser(viewModel: CreateUser.SignUp.ViewModel)
}

class CreateUserViewController: UIViewController, CreateUserDisplayLogic
{
    var interactor: CreateUserBusinessLogic?
    var router: (NSObjectProtocol & CreateUserRoutingLogic & CreateUserDataPassing)?
    
    // MARK: Object lifecycle
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup()
    {
        let viewController = self
        let interactor = CreateUserInteractor()
        let presenter = CreateUserPresenter()
        let router = CreateUserRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: Routing
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let scene = segue.identifier {
            let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
            if let router = router, router.responds(to: selector) {
                router.perform(selector, with: segue)
            }
        }
    }
    
    // MARK: - UI
    private var closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("닫기", for: .normal)
        button.tintColor = .systemPurple
        return button
    }()
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.text = "로그인"
        return label
    }()
    
    private var emailTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이메일"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private var emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "abc@xyz.com"
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .black
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private var passwordTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "비밀번호"
        label.textColor = .black
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private var passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "비밀번호"
        tf.font = .systemFont(ofSize: 16)
        tf.textColor = .black
        tf.keyboardType = .default
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private var signUpModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("가입할래요", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .systemPurple
        return button
    }()
    
    private var signInModeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인할래요", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.tintColor = .systemPurple
        button.isHidden = true
        return button
    }()
    
    private var horizontalDivider: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray4
        return view
    }()
    
    private var socialLoginTitle: UILabel = {
        let label = UILabel()
        label.text = "소셜로그인"
        label.backgroundColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.textColor = .black
        return label
    }()
    
    private var googleLoginButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.style = .wide
        return button
    }()
    
    private var appleLoginButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
    private var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("회원가입", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.layer.cornerRadius = 10
        return button
    }()
    
    private var signInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인", for: .normal)
        button.titleLabel?.textAlignment = .center
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.isHidden = true
        return button
    }()

    // MARK: View lifecycle
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureUI()
        configureAutoLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkLoginStatus()
    }
    
    private func configureUI() {
        self.view.backgroundColor = .white
        
        [
            self.closeButton,
            self.titleLabel,
            self.emailTitleLabel,
            self.emailTextField,
            self.passwordTitleLabel,
            self.passwordTextField,
            self.signInModeButton,
            self.signUpModeButton,
            
            self.horizontalDivider,
            self.socialLoginTitle,
            
            self.googleLoginButton,
            self.appleLoginButton,
            
            self.signInButton,
            self.signUpButton,
        ].forEach { self.view.addSubview($0) }
        
        self.closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        self.signInModeButton.addTarget(self, action: #selector(signInModeButtonTapped), for: .touchUpInside)
        self.signUpModeButton.addTarget(self, action: #selector(signUpModeButtonTapped), for: .touchUpInside)
        
        self.googleLoginButton.addTarget(self, action: #selector(googleLoginButtonTapped), for: .touchUpInside)
        self.appleLoginButton.addTarget(self, action: #selector(appleLoginButtonTapped), for: .touchUpInside)
        
        self.signInButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        self.signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        self.emailTextField.delegate = self
        self.passwordTextField.delegate = self
    }
    
    private func configureAutoLayout() {
        [
            self.closeButton,
            self.titleLabel,
            self.emailTitleLabel,
            self.emailTextField,
            self.passwordTitleLabel,
            self.passwordTextField,
            self.signInModeButton,
            self.signUpModeButton,
            
            self.horizontalDivider,
            self.socialLoginTitle,
            
            self.googleLoginButton,
            self.appleLoginButton,
            
            self.signInButton,
            self.signUpButton,
        ].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        NSLayoutConstraint.activate([
            self.closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            self.closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.closeButton.heightAnchor.constraint(equalToConstant: 50),
            self.closeButton.widthAnchor.constraint(equalToConstant: 50),
            
            self.titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            self.titleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            
            self.emailTitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 30),
            self.emailTitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.emailTitleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            self.emailTextField.topAnchor.constraint(equalTo: self.emailTitleLabel.bottomAnchor, constant: 5),
            self.emailTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.emailTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.emailTextField.heightAnchor.constraint(equalToConstant: 30),
            
            self.passwordTitleLabel.topAnchor.constraint(equalTo: self.emailTextField.bottomAnchor, constant: 15),
            self.passwordTitleLabel.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.passwordTitleLabel.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            
            self.passwordTextField.topAnchor.constraint(equalTo: self.passwordTitleLabel.bottomAnchor, constant: 5),
            self.passwordTextField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.passwordTextField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.passwordTextField.heightAnchor.constraint(equalToConstant: 30),
            
            self.signInModeButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 10),
            self.signInModeButton.centerXAnchor.constraint(equalTo: self.passwordTextField.centerXAnchor),
            self.signInModeButton.heightAnchor.constraint(equalToConstant: 20),
            self.signInModeButton.widthAnchor.constraint(equalTo: self.passwordTextField.widthAnchor),
            
            self.signUpModeButton.topAnchor.constraint(equalTo: self.passwordTextField.bottomAnchor, constant: 10),
            self.signUpModeButton.centerXAnchor.constraint(equalTo: self.passwordTextField.centerXAnchor),
            self.signUpModeButton.heightAnchor.constraint(equalToConstant: 20),
            self.signUpModeButton.widthAnchor.constraint(equalTo: self.passwordTextField.widthAnchor),
            
            self.socialLoginTitle.topAnchor.constraint(equalTo: self.signUpModeButton.bottomAnchor, constant: 15),
            self.socialLoginTitle.widthAnchor.constraint(equalToConstant: 100),
            self.socialLoginTitle.heightAnchor.constraint(equalToConstant: 20),
            self.socialLoginTitle.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),

            self.horizontalDivider.centerYAnchor.constraint(equalTo: self.socialLoginTitle.centerYAnchor),
            self.horizontalDivider.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.horizontalDivider.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.horizontalDivider.heightAnchor.constraint(equalToConstant: 1),
            
            self.googleLoginButton.topAnchor.constraint(equalTo: self.socialLoginTitle.bottomAnchor, constant: 15),
            self.googleLoginButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.appleLoginButton.topAnchor.constraint(equalTo: self.googleLoginButton.bottomAnchor, constant: 10),
            self.appleLoginButton.widthAnchor.constraint(equalTo: self.googleLoginButton.widthAnchor),
            self.appleLoginButton.heightAnchor.constraint(equalTo: self.googleLoginButton.heightAnchor),
            self.appleLoginButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            
            self.signInButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            self.signInButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.signInButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.signInButton.heightAnchor.constraint(equalToConstant: 50),
            
            self.signUpButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            self.signUpButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
            self.signUpButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            self.signUpButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    @objc private func closeButtonTapped(_ button: UIButton) {
        moveToCameraPreview()
    }
    
    @objc private func signInModeButtonTapped(_ button: UIButton) {
        
        self.titleLabel.text = "로그인"
        
        [
            self.signUpModeButton,
            self.signInButton,
        ].forEach { $0.isHidden = false }
        
        [
            self.signInModeButton,
            self.signUpButton,
        ].forEach { $0.isHidden = true }
    }
    
    @objc private func signUpModeButtonTapped(_ button: UIButton) {
        self.titleLabel.text = "회원가입"
        
        [
            self.signUpModeButton,
            self.signInButton,
        ].forEach { $0.isHidden = true }
        
        [
            self.signInModeButton,
            self.signUpButton,
        ].forEach { $0.isHidden = false }
    }
    
    // MARK: - CreateUserBusinessLogic
    private func checkLoginStatus() {
        let request = CreateUser.LoginStatus.Request()
        self.interactor?.isSignedIn(request: request)
    }
    
    @objc private func googleLoginButtonTapped(_ button: GIDSignInButton) {
        let request = CreateUser.GoogleSignIn.Request(presentingViewController: self)
        self.interactor?.googleSignIn(request: request)
    }
    
    @objc private func appleLoginButtonTapped(_ button: ASAuthorizationAppleIDButton) {
        let request = CreateUser.AppleSignIn.Request(presentingViewController: self)
        self.interactor?.appleSignIn(request: request)
    }
    
    @objc private func signInButtonTapped(_ button: UIButton) {
        guard let typedEmail = self.emailTextField.text,
              let typedPassword = self.passwordTextField.text else { return }
        
        let request = CreateUser.SignIn.Request(userEmail: typedEmail, userPassword: typedPassword)
        self.interactor?.signIn(request: request)
    }
    
    @objc private func signUpButtonTapped(_ button: UIButton) {
        guard let typedEmail = self.emailTextField.text,
              let typedPassword = self.passwordTextField.text else { return }
        
        let request = CreateUser.SignUp.Request(newEmail: typedEmail, newPassword: typedPassword)
        self.interactor?.signUp(request: request)
    }
    
    // MARK: CreateUserDisplayLogic
    func displayLoginStatus(viewModel: CreateUser.LoginStatus.ViewModel) {
        let signedInUserEmail = viewModel.signedInUserEmail
        if let _ = signedInUserEmail {
            hideSigningForm()
        } else {
            showSigningForm()
        }
    }
    
    func displayUserSignedInWithGoogle(viewModel: CreateUser.GoogleSignIn.ViewModel) {
        let signedInUserEmail = viewModel.signedInUserEmail
        displaySignedInUser(userEmail: signedInUserEmail)
    }
    
    func displaySignedInUser(viewModel: CreateUser.SignIn.ViewModel) {
        let signedInUserEmail = viewModel.signedInUserEmail
        displaySignedInUser(userEmail: signedInUserEmail)
    }
    
    private func displaySignedInUser(userEmail: String?) {
        if let _ = userEmail {
            hideSigningForm()
            
            let alertController = okAlertController(title: "안내", message: "로그인 되었습니다") { [weak self] action in
                guard let self = self else { return }
                
                self.moveToCameraPreview()
            }
            
            self.present(alertController, animated: true)
        } else {
            let alertController = okAlertController(title: "에러", message: "로그인 할 수 없습니다")
            self.present(alertController, animated: true)
        }
    }
    
    func displaySignedOutUser(viewModel: CreateUser.SignOut.ViewModel) {
        let signedOutUserEmail = viewModel.signedOutUserEmail
        if let _ = signedOutUserEmail {
            showSigningForm()
            
            let alertController = okAlertController(title: "안내", message: "로그아웃 되었습니다")
            self.present(alertController, animated: true)
        } else {
            let alertController = okAlertController(title: "에러", message: "로그아웃에 실패했습니다")
            self.present(alertController, animated: true)
        }
    }
    
    func displaySignedUpUser(viewModel: CreateUser.SignUp.ViewModel) {
        let createdUserEmail = viewModel.createdUserEmail
        if let _ = createdUserEmail {
            hideSigningForm()
            
            let alertController = okAlertController(title: "안내", message: "회원가입이 완료되었습니다") { [weak self] action in
                guard let self = self else { return }
                
                self.moveToCameraPreview()
            }
            
            self.present(alertController, animated: true)
        } else {
            let alertController = okAlertController(title: "에러", message: "회원가입에 실패했습니다")
            self.present(alertController, animated: true)
        }
    }
    
    private func okAlertController(title: String, message: String, okButtonTappedHandler: ((UIAlertAction) -> Void)? = nil) -> UIAlertController {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: okButtonTappedHandler)
        alertController.addAction(okAction)
        
        return alertController
    }
    
    private func moveToCameraPreview() {
        let selector = NSSelectorFromString("routeToCameraPreviewWithSegue:")
        if let router = self.router, router.responds(to: selector) {
            router.perform(selector, with: nil)
        }
    }
    
    private func hideSigningForm() {
        [
            self.emailTitleLabel,
            self.emailTextField,
            self.passwordTitleLabel,
            self.passwordTextField,
            self.signInModeButton,
            self.signUpModeButton,
            self.signInButton,
            self.signUpButton,
        ].forEach { $0.isHidden = true }
        
        self.titleLabel.text = "로그인 되었습니다"
    }
    
    private func showSigningForm() {
        [
            self.signInModeButton,
            self.signUpButton,
        ].forEach { $0.isHidden = true }
        
        [
            self.emailTitleLabel,
            self.emailTextField,
            self.passwordTitleLabel,
            self.passwordTextField,
            self.signUpModeButton,
            self.signInButton,
        ].forEach { $0.isHidden = false }
        
        self.titleLabel.text = "로그인"
    }
}

extension CreateUserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
