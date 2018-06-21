//
//  ChangePasswordViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 5.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import FirebaseAuth
import AudioToolbox

class ChangePasswordViewController: BaseScrollViewController {
    
    fileprivate let DefaultInset: CGFloat = 20.0
    
    fileprivate var currentPasswordTextField: CustomTextField!
    fileprivate var newPasswordTextField: CustomTextField!
    fileprivate var newPasswordConfirmationTextField: CustomTextField!
    
    fileprivate var updateButton: OverlayButton!
    
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
        title = "Change Password"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customCrossButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        currentPasswordTextField = CustomTextField.newAutoLayout()
        currentPasswordTextField.returnKeyType = UIReturnKeyType.next
        currentPasswordTextField.customTextFieldDelegate = self
        currentPasswordTextField.isSecureTextEntry = true
        currentPasswordTextField.placeholder = "Current Password".requiredSuffix()
        
        contentView.addSubview(currentPasswordTextField)
        
        currentPasswordTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        currentPasswordTextField.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        currentPasswordTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        currentPasswordTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        newPasswordTextField = CustomTextField.newAutoLayout()
        newPasswordTextField.returnKeyType = UIReturnKeyType.next
        newPasswordTextField.customTextFieldDelegate = self
        newPasswordTextField.isSecureTextEntry = true
        newPasswordTextField.placeholder = "New Password".requiredSuffix()
        
        contentView.addSubview(newPasswordTextField)
        
        newPasswordTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        newPasswordTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: currentPasswordTextField)
        newPasswordTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        newPasswordTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        newPasswordConfirmationTextField = CustomTextField.newAutoLayout()
        newPasswordConfirmationTextField.returnKeyType = UIReturnKeyType.done
        newPasswordConfirmationTextField.autocapitalizationType = UITextAutocapitalizationType.none
        newPasswordConfirmationTextField.customTextFieldDelegate = self
        newPasswordConfirmationTextField.isSecureTextEntry = true
        newPasswordConfirmationTextField.placeholder = "New Password Confirmation".requiredSuffix()
        
        contentView.addSubview(newPasswordConfirmationTextField)
        
        newPasswordConfirmationTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        newPasswordConfirmationTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: newPasswordTextField)
        newPasswordConfirmationTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        newPasswordConfirmationTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        updateButton = OverlayButton(type: UIButtonType.system)
        updateButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        updateButton.setTitle("UPDATE", for: UIControlState.normal)
        updateButton.addTarget(self, action: #selector(updateUpButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(updateButton)
        
        updateButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        updateButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: newPasswordConfirmationTextField, withOffset: DefaultInset)
        updateButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        updateButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: contentView, withOffset: -DefaultInset)
    }
    
    // MARK: - Actions
    
    override func crossButtonTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateUpButtonTapped(_ button: OverlayButton) {
        update()
    }
    
    // MARK: - Update
    
    fileprivate func update() {
        view.endEditing(true)
        
        var shouldUpdate = true
        
        if !validate(Field: currentPasswordTextField) {
            shouldUpdate = false
        }
        
        if !validate(Field: newPasswordTextField) {
            shouldUpdate = false
        }
        
        if !validate(Field: newPasswordConfirmationTextField) {
            shouldUpdate = false
        }
        
        if !shouldUpdate {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        updateProfile()
    }
    
    // MARK: - Validation
    
    fileprivate func validate(Field field: CustomTextField) -> Bool {
        if field == currentPasswordTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        } else if field == newPasswordTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        } else if field == newPasswordConfirmationTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        }
        
        if newPasswordConfirmationTextField.text != newPasswordTextField.text {
            shakeTheTextField(newPasswordConfirmationTextField)
            return false
        }
        
        return true
    }
    
    fileprivate func shakeTheTextField(_ textField: CustomTextField) {
        textField.shake()
    }
    
    fileprivate func updateProfile() {
        guard let user = AuthManager().getAuthenticatedUser() else {
            return
        }
        
        let currentPassword = currentPasswordTextField.text!
        let newPassword = newPasswordTextField.text!
        let email = user.email!
        
        let credential: AuthCredential = EmailAuthProvider.credential(withEmail: email, password: currentPassword)
        
        LoadingView.startAnimating()
        Auth.auth().currentUser?.reauthenticate(with: credential, completion: { (error) in
            if let error = error {
                LoadingView.stopAnimating {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                }
                
                return
            }
            
            Auth.auth().currentUser?.updatePassword(to: newPassword, completion: { (error) in
                if let error = error {
                    LoadingView.stopAnimating {
                        self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    }
                    
                    return
                }
                
                self.dismiss(animated: true, completion: {
                    LoadingView.stopAnimating {
                        self.showPopupWith(Title: "Success", andMessage: "Your password successfully updated!")
                        self.currentPasswordTextField.text = ""
                        self.newPasswordTextField.text = ""
                        self.newPasswordConfirmationTextField.text = ""
                    }
                })
            })
        })
    }
}

// MARK: - CustomTextFieldDelegate

extension ChangePasswordViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        if textField == currentPasswordTextField {
            newPasswordTextField.becomeFirstResponder()
        } else if textField == newPasswordTextField {
            newPasswordConfirmationTextField.becomeFirstResponder()
        } else if textField == newPasswordConfirmationTextField {
            view.endEditing(true)
        }
        
        return true
    }
}
