//
//  LoginViewController.swift
//  TJUBBS
//
//  Created by JinHongxu on 2017/4/30.
//  Copyright © 2017年 twtstudio. All rights reserved.
//

import UIKit
import SnapKit
import PKHUD

class LoginViewController: UIViewController {
    
    let screenFrame = UIScreen.main.bounds
    var portraitImageView: UIImageView?
    var usernameImageView: UIImageView?
    var usernameTextField: UITextField?
    var passwordImageView: UIImageView?
    var passwordTextField: UITextField?
    var loginButton: UIButton?
    var registerButton: UIButton?
    var authenticateButton: UIButton?
    var forgetButton: UIButton?
    var visitorButton: UIButton?
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    convenience init(para: Int) {
        self.init()
        view.backgroundColor = UIColor.white
        UIApplication.shared.statusBarStyle = .lightContent
        initUI()
        addTapGestures()
        addKVOSelectors()
        addTargetAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        portraitImageView = UIImageView(image: UIImage(named: "portrait"))
        view.addSubview(portraitImageView!)
        portraitImageView?.snp.makeConstraints {
            make in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(screenFrame.height*(650/1920))
        }
        
        usernameImageView = UIImageView(image: UIImage(named: "用户名"))
        view.addSubview(usernameImageView!)
        usernameImageView?.snp.makeConstraints {
            make in
            make.top.equalTo(portraitImageView!.snp.bottom).offset(screenFrame.height*(100/1920))
            make.left.equalTo(view).offset(screenFrame.width*(150/1080))
            make.width.equalTo(screenFrame.height*(96/1920))
            make.height.equalTo(screenFrame.height*(88/1920))
        }
        
        usernameTextField = UITextField()
        view.addSubview(usernameTextField!)
        usernameTextField?.snp.makeConstraints {
            make in
            make.centerY.equalTo(usernameImageView!)
            make.left.equalTo(usernameImageView!.snp.right).offset(8)
            make.height.equalTo(screenFrame.height*(64/1920))
            make.width.equalTo(screenFrame.width*(650/1080))
        }
        usernameTextField?.placeholder = "用户名"
        
        passwordImageView = UIImageView(image: UIImage(named: "密码"))
        view.addSubview(passwordImageView!)
        passwordImageView?.snp.makeConstraints {
            make in
            make.top.equalTo(usernameImageView!.snp.bottom).offset(screenFrame.height*(100/1920))
            make.left.equalTo(view).offset(screenFrame.width*(150/1080))
            make.width.equalTo(screenFrame.height*(96/1920))
            make.height.equalTo(screenFrame.height*(88/1920))
        }
        
        passwordTextField = UITextField()
        view.addSubview(passwordTextField!)
        passwordTextField?.snp.makeConstraints {
            make in
            make.centerY.equalTo(passwordImageView!)
            make.left.equalTo(passwordImageView!.snp.right).offset(8)
            make.height.equalTo(screenFrame.height*(64/1920))
            make.width.equalTo(screenFrame.width*(650/1080))
        }
        passwordTextField?.placeholder = "密 码"
        passwordTextField?.isSecureTextEntry = true
        
        forgetButton = UIButton(title: "忘记密码?")
        view.addSubview(forgetButton!)
        forgetButton?.snp.makeConstraints {
            make in
            make.top.equalTo(passwordImageView!.snp.bottom).offset(8)
            make.right.equalTo(passwordTextField!.snp.right)
        }

        loginButton = UIButton(type: .roundedRect)
        view.addSubview(loginButton!)
        loginButton?.snp.makeConstraints {
            make in
            make.top.equalTo(forgetButton!.snp.bottom).offset(8)
            make.centerX.equalTo(view)
            make.width.equalTo(screenFrame.width*(800/1080))
            make.height.equalTo(screenFrame.height*(100/1920))
        }
        loginButton?.setTitle("登 录", for: .normal)
        loginButton?.setTitleColor(UIColor.white, for: .normal)
        loginButton?.backgroundColor = UIColor.BBSBlue
        loginButton?.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        loginButton?.layer.cornerRadius = 5.0
        loginButton?.clipsToBounds = true
        
        registerButton = UIButton(title: "新用户注册")
        view.addSubview(registerButton!)
        registerButton?.snp.makeConstraints {
            make in
            make.top.equalTo(loginButton!.snp.bottom).offset(8)
            make.left.equalTo(loginButton!.snp.left)
        }
        
        authenticateButton = UIButton(title: "老用户认证")
        view.addSubview(authenticateButton!)
        authenticateButton?.snp.makeConstraints {
            make in
            make.top.equalTo(loginButton!.snp.bottom).offset(8)
            make.right.equalTo(loginButton!.snp.right)
        }
        
        visitorButton = UIButton(title: "游客登录 >", color: UIColor.BBSBlue, fontSize: 16)
        view.addSubview(visitorButton!)
        visitorButton?.snp.makeConstraints {
            make in
            make.bottom.equalTo(view.snp.bottom).offset(-8)
            make.centerX.equalTo(view)
        }
    }

    func addTapGestures() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func addKVOSelectors() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func addTargetAction() {
        authenticateButton?.addTarget(self, action: #selector(authenticateButtonTapped), for: .touchUpInside)
        loginButton?.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
    }
    
    func authenticateButtonTapped() {
        let authenticateVC = AuthenticateViewController(para: 1)
        self.navigationController?.pushViewController(authenticateVC, animated: true)
    }
    
    func loginButtonTapped() {
        print("loginButtonTapped")
        HUD.flash(.success, onView: portraitImageView, delay: 1.0, completion: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

