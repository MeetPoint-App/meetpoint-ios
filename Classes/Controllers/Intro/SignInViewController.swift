//
//  SignInViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import YKPopupDialogView
import AudioToolbox

class SignInViewController: BaseViewController {
    
    fileprivate let DefaultInset: CGFloat = 20.0
    
    fileprivate var logoImageView: UIImageView!
    
    fileprivate var emailTextField: CustomTextField!
    fileprivate var passwordTextField: CustomTextField!
    
    fileprivate var loginButton: OverlayButton!
    fileprivate var forgotPasswordButton: UIButton!
    fileprivate var signUpButton: UIButton!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        let containerView = UIView.newAutoLayout()
        containerView.backgroundColor = UIColor.clear
        
        view.addSubview(containerView)
        
        containerView.autoCenterInSuperview()
        containerView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        containerView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        
        
        logoImageView = UIImageView.newAutoLayout()
        logoImageView.contentMode = UIViewContentMode.scaleAspectFill
        logoImageView.image = UIImage(named: "introLogo")
        
        containerView.addSubview(logoImageView)
        
        logoImageView.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        logoImageView.autoPinEdge(toSuperviewEdge: ALEdge.top)
        
        
        emailTextField = CustomTextField.newAutoLayout()
        emailTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.customTextFieldDelegate = self
        emailTextField.placeholder = "Email".requiredSuffix()
        
        containerView.addSubview(emailTextField)
        
        emailTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        emailTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: logoImageView, withOffset: 50.0)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        passwordTextField = CustomTextField.newAutoLayout()
        passwordTextField.returnKeyType = UIReturnKeyType.done
        passwordTextField.isSecureTextEntry = true
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordTextField.customTextFieldDelegate = self
        passwordTextField.placeholder = "Password".requiredSuffix()
        
        containerView.addSubview(passwordTextField)
        
        passwordTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        passwordTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: emailTextField)
        passwordTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        passwordTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        loginButton = OverlayButton(type: UIButtonType.system)
        loginButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        loginButton.setTitle("LOGIN", for: UIControlState.normal)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        containerView.addSubview(loginButton)
        
        loginButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        loginButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: passwordTextField, withOffset: DefaultInset)
        loginButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        
        forgotPasswordButton = UIButton(type: UIButtonType.system)
        forgotPasswordButton.setTitle("Forgot Password?", for: UIControlState.normal)
        forgotPasswordButton.titleLabel?.font = UIFont.montserratMediumFont(withSize: 15.0)
        forgotPasswordButton.setTitleColor(UIColor.primaryLightTextColor(), for: UIControlState.normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped(_:))  , for: UIControlEvents.touchUpInside)
        
        containerView.addSubview(forgotPasswordButton)
        
        forgotPasswordButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        forgotPasswordButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: loginButton, withOffset: DefaultInset)
        forgotPasswordButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: containerView)
        
        
        signUpButton = UIButton(type: UIButtonType.system)
        signUpButton.setTitle("SIGN UP NOW", for: UIControlState.normal)
        signUpButton.titleLabel?.font = UIFont.montserratBoldFont(withSize: 17.0)
        signUpButton.setTitleColor(UIColor.primaryDarkTextColor(), for: UIControlState.normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(_:))  , for: UIControlEvents.touchUpInside)
        
        view.addSubview(signUpButton)
        
        signUpButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        signUpButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: DefaultInset)
        
        
        let informationLabel = UILabel.newAutoLayout()
        informationLabel.text = "You don’t have an account?"
        informationLabel.textColor = UIColor.primaryDarkTextColor()
        informationLabel.font = UIFont.montserratMediumFont(withSize: 16.0)
        
        view.addSubview(informationLabel)
        
        informationLabel.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        informationLabel.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: signUpButton, withOffset: -4.0)
    }
    
    // MARK: - Interface
    
    override func shouldShowNavigationBar() -> Bool {
        return false
    }
    
    override func shouldHideKeyboardWhenTappedArround() -> Bool {
        return true
    }
    
    // MARK: - Helpers
    
    func animateViewMoving (up: Bool, moveValue: CGFloat){
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    // MARK: - Actions
    
    func loginButtonTapped(_ button: OverlayButton) {
        login()
    }
    
    func forgotPasswordButtonTapped(_ button: UIButton) {
        self.navigationController?.pushViewController(ForgotPasswordViewController(), animated: true)
    }
    
    func signUpButtonTapped(_ button: UIButton) {
        self.navigationController?.pushViewController(SignUpViewController(), animated: true)
    }
    
    // MARK: - Login
    
    fileprivate func login() {
        
        view.endEditing(true)
        
        var shouldLogin = true
        
        if !validate(Field: emailTextField) {
            shouldLogin = false
        }
        
        if !validate(Field: passwordTextField) {
            shouldLogin =  false
        }
        
        if !shouldLogin {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        let email = emailTextField.text
        let password = passwordTextField.text
        
        LoadingView.startAnimating()
        
        AuthManager.sharedManager.login(email!, password: password!) { (error) in
            if let error = error {
                
                LoadingView.stopAnimating{
                    self.showPopupWith(Title: "Error!", andMessage: error.localizedDescription)
                }
                
                return
            }
            
            LoadingView.stopAnimating {
                DispatchQueue.main.async(execute: { () -> Void in
                    NotificationCenter.default
                        .post(name: Notification.Name(rawValue: UserAuthenticationNotification),
                              object: nil)
                })
            }
        }
    }
    
    // MARK: - Validation
    
    fileprivate func validate(Field field: CustomTextField) -> Bool {
        if field == emailTextField {
            let email = field.text
            
            if email == nil || email!.count == 0 {
                shakeTheTextField(field)
                return false
            } else if email?.isValidEmail() == false {
                shakeTheTextField(field)
                return false
            }
        }  else if field == passwordTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        }
        
        return true
    }
    
    fileprivate func shakeTheTextField(_ textField: CustomTextField) {
        textField.shake()
    }
}

// MARK: - CustomTextFieldDelegate

extension SignInViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            view.endEditing(true)
        }
        
        return true
    }
    
    func customTextFieldDidBeginEditing(_ textField: CustomTextField) {
        animateViewMoving(up: true, moveValue: 50.0)
    }
    
    func customTextFieldDidEndEditing(_ textField: CustomTextField) {
        animateViewMoving(up: false, moveValue: 50.0)
    }
}
