//
//  ForgotPasswordViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import FirebaseAuth
import YKPopupDialogView
import AudioToolbox

class ForgotPasswordViewController: BaseViewController {
    
    fileprivate let DefaultInset: CGFloat = 20.0
    
    fileprivate var titleLabel: UILabel!
    fileprivate var subtitleLabel: UILabel!
    
    fileprivate var emailTextField: CustomTextField!
    
    fileprivate var resetButton: OverlayButton!
    
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
        title = "Forgot Password"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        
        let containerView = UIView.newAutoLayout()
        
        view.addSubview(containerView)
        
        containerView.autoCenterInSuperview()
        containerView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        containerView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        
        
        titleLabel = UILabel.newAutoLayout()
        titleLabel.textColor = UIColor.primaryDarkTextColor()
        titleLabel.font = UIFont.montserratSemiboldFont(withSize: 16.0)
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.text = "Trouble with logging in?"
        
        containerView.addSubview(titleLabel)
        
        titleLabel.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        
        
        subtitleLabel = UILabel.newAutoLayout()
        subtitleLabel.textColor = UIColor.primaryLightTextColor()
        subtitleLabel.font = UIFont.montserratRegularFont(withSize: 16.0)
        subtitleLabel.numberOfLines = 0
        subtitleLabel.textAlignment = NSTextAlignment.center
        subtitleLabel.text = "Enter your e-mail and we'll send you a link to reset your password."
        
        containerView.addSubview(subtitleLabel)
        
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        subtitleLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        subtitleLabel.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: titleLabel, withOffset: 8.0)
        
        
        emailTextField = CustomTextField.newAutoLayout()
        emailTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.customTextFieldDelegate = self
        emailTextField.returnKeyType = UIReturnKeyType.done
        emailTextField.placeholder = "Email".requiredSuffix()
        
        containerView.addSubview(emailTextField)
        
        emailTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        emailTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: subtitleLabel, withOffset: 40.0)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        resetButton = OverlayButton(type: UIButtonType.system)
        resetButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        resetButton.setTitle("RESET", for: UIControlState.normal)
        resetButton.addTarget(self, action: #selector(resetButtonTapped(_:))  , for: UIControlEvents.touchUpInside)
        
        containerView.addSubview(resetButton)
        
        resetButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        resetButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: emailTextField, withOffset: 40.0)
        resetButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        resetButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: containerView)
    }
    
    // MARK: - Interface
    
    override func shouldShowNavigationBar() -> Bool {
        return true
    }
    
    // MARK: - Actions
    
    func resetButtonTapped(_ button: OverlayButton) {
        reset()
    }
    
    func reset() {
        view.endEditing(true)
        
        var shouldReset = true
        
        if !validate(Field: emailTextField) {
            shouldReset = false
        }
        
        if !shouldReset {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        let email = emailTextField.text
        
        Auth.auth().sendPasswordReset(withEmail: email!) { (error) in
            
            if let error = error {
                self.showPopupWith(Title: "Error!", andMessage: error.localizedDescription)
            } else {
                self.showPopupWith(Title: "Success!", andMessage: "Please check your email to reset password.")
            }
            
            self.emailTextField.text = ""
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
        }
        
        return true
    }
    
    fileprivate func shakeTheTextField(_ textField: CustomTextField) {
        textField.shake()
    }
}

// MARK: - CustomTextFieldDelegate

extension ForgotPasswordViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        view.endEditing(true)
        return true
    }
}

