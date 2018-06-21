//
//  SignUpViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 16/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import SafariServices
import Firebase
import Whisper
import AudioToolbox

class SignUpViewController: BaseScrollViewController {
    
    fileprivate let DefaultInset: CGFloat = 20.0
    fileprivate let AvatarDimension: CGFloat = 90.0
    
    fileprivate var avatarImageView: UIImageView!
    
    fileprivate var firstNameTextField: CustomTextField!
    fileprivate var lastNameTextField: CustomTextField!
    
    fileprivate var emailTextField: CustomTextField!
    
    fileprivate var usernameTextField: CustomTextField!
    
    fileprivate var passwordTextField: CustomTextField!
    fileprivate var passwordConfirmationTextField: CustomTextField!
    
    fileprivate var approveField: InteractiveApprovalField!
    
    fileprivate var signUpButton: OverlayButton!
    
    fileprivate var selectedImage: UIImage?
    
    fileprivate var isUsernameAvailable: Bool?
    
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
        let customBackButton = UIButton(type: UIButtonType.custom)
        customBackButton.setImage(UIImage(named: "iconBackButton"), for: UIControlState())
        customBackButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        customBackButton.addTarget(self,
                                   action: #selector(backButtonTapped(_:)),
                                   for: UIControlEvents.touchUpInside)
        
        view.addSubview(customBackButton)
        
        customBackButton.autoPinEdge(toSuperviewEdge: ALEdge.left)
        customBackButton.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                     withInset: 20.0)
        customBackButton.autoSetDimensions(to: CGSize(width: 44.0, height: 44.0))
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.primaryBackgroundColor()
        
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.image = UIImage(named: "iconAddAvatar")
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = AvatarDimension / 2
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarDimension, height: AvatarDimension))
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        
        
        firstNameTextField = CustomTextField.newAutoLayout()
        firstNameTextField.returnKeyType = UIReturnKeyType.next
        firstNameTextField.customTextFieldDelegate = self
        firstNameTextField.placeholder = "First Name".requiredSuffix()
        
        contentView.addSubview(firstNameTextField)
        
        firstNameTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        firstNameTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: avatarImageView, withOffset: DefaultInset)
        firstNameTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        firstNameTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        lastNameTextField = CustomTextField.newAutoLayout()
        lastNameTextField.returnKeyType = UIReturnKeyType.next
        lastNameTextField.customTextFieldDelegate = self
        lastNameTextField.placeholder = "Last Name".requiredSuffix()
        
        contentView.addSubview(lastNameTextField)
        
        lastNameTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        lastNameTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: firstNameTextField)
        lastNameTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        lastNameTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        emailTextField = CustomTextField.newAutoLayout()
        emailTextField.returnKeyType = UIReturnKeyType.next
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.customTextFieldDelegate = self
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.placeholder = "Email".requiredSuffix()
        
        contentView.addSubview(emailTextField)
        
        emailTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        emailTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: lastNameTextField)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        usernameTextField = CustomTextField.newAutoLayout()
        usernameTextField.returnKeyType = UIReturnKeyType.next
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        usernameTextField.customTextFieldDelegate = self
        usernameTextField.placeholder = "Username".requiredSuffix()
        
        contentView.addSubview(usernameTextField)
        
        usernameTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        usernameTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: emailTextField)
        usernameTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        usernameTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        passwordTextField = CustomTextField.newAutoLayout()
        passwordTextField.returnKeyType = UIReturnKeyType.next
        passwordTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordTextField.customTextFieldDelegate = self
        passwordTextField.isSecureTextEntry = true
        passwordTextField.placeholder = "Password".requiredSuffix()
        
        contentView.addSubview(passwordTextField)
        
        passwordTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        passwordTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: usernameTextField)
        passwordTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        passwordTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        passwordConfirmationTextField = CustomTextField.newAutoLayout()
        passwordConfirmationTextField.returnKeyType = UIReturnKeyType.done
        passwordConfirmationTextField.autocapitalizationType = UITextAutocapitalizationType.none
        passwordConfirmationTextField.customTextFieldDelegate = self
        passwordConfirmationTextField.isSecureTextEntry = true
        passwordConfirmationTextField.placeholder = "Password Confirmation".requiredSuffix()
        
        contentView.addSubview(passwordConfirmationTextField)
        
        passwordConfirmationTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        passwordConfirmationTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: passwordTextField)
        passwordConfirmationTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        passwordConfirmationTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        approveField = InteractiveApprovalField.newAutoLayout()
        approveField.delegate = self
        
        let termsOfUseText = NSMutableAttributedString()
        termsOfUseText.append(NSAttributedString(string: "Terms of use",
                                                 attributes: [NSFontAttributeName: UIFont.montserratMediumFont(withSize: 15.0),
                                                              NSForegroundColorAttributeName: UIColor.white,
                                                              NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]))
        approveField.addInteractiveAttributedText(termsOfUseText, forScheme: InteractiveTextScheme.termsOfUse)
        
        
        let andText = NSMutableAttributedString()
        andText.append(NSAttributedString(string: " and ",
                                          attributes: [NSFontAttributeName: UIFont.montserratMediumFont(withSize: 15.0),
                                                       NSForegroundColorAttributeName: UIColor.primaryDarkTextColor()]))
        approveField.addNonInteractiveAttributedText(andText)
        
        
        let privacyPolicyText = NSMutableAttributedString()
        privacyPolicyText.append(NSAttributedString(string: "Privacy policy",
                                                    attributes: [NSFontAttributeName: UIFont.montserratMediumFont(withSize: 15.0),
                                                                 NSForegroundColorAttributeName: UIColor.white,
                                                                 NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]))
        approveField.addInteractiveAttributedText(privacyPolicyText, forScheme: InteractiveTextScheme.privacyPolicy)
        
        
        contentView.addSubview(approveField)
        
        approveField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: passwordConfirmationTextField, withOffset: 8.0)
        approveField.autoPinEdge(toSuperviewEdge: ALEdge.left)
        approveField.autoPinEdge(toSuperviewEdge: ALEdge.right)
        approveField.autoSetDimension(ALDimension.height, toSize: 44.0)
        
        
        signUpButton = OverlayButton(type: UIButtonType.system)
        signUpButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        signUpButton.setTitle("SIGN UP", for: UIControlState.normal)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(signUpButton)
        
        signUpButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        signUpButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: approveField, withOffset: 8.0)
        signUpButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        signUpButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: contentView, withOffset: -DefaultInset)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Whisper.hide()
    }
    
    // MARK: - Interface
    
    override func shouldShowNavigationBar() -> Bool {
        return false
    }
    
    // MARK: - Actions
    
    func signUpButtonTapped(_ button: OverlayButton) {
        signUp()
    }
    
    // MARK: - Sign Up
    
    fileprivate func signUp() {
        
        view.endEditing(true)
        
        var shouldSignUp = true
        
        if !validate(Field: firstNameTextField) {
            shouldSignUp = false
        }
        
        if !validate(Field: lastNameTextField) {
            shouldSignUp = false
        }
        
        if !validate(Field: emailTextField) {
            shouldSignUp = false
        }
        
        if !validate(Field: usernameTextField) {
            shouldSignUp = false
        }
        
        if !validate(Field: passwordTextField) {
            shouldSignUp =  false
        }
        
        if !validate(Field: passwordConfirmationTextField) {
            shouldSignUp = false
        }
        
        if !shouldSignUp {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        if approveField.state == ApprovalState.disapproved {
            self.showPopupWith(Title: "Error",
                               andMessage: "You should approve Terms of Use & Privacy Policy.")
            
            return
        }
        
        createUser()
    }
    
    // MARK: - Validation
    
    fileprivate func validate(Field field: CustomTextField) -> Bool {
        if field == firstNameTextField {
            let firstName = field.text
            
            if ((firstName == nil) || (firstName!.count == 0)) {
                shakeTheTextField(field)
                return false
            } else if firstName?.isValidFirstName() == false {
                shakeTheTextField(field)
                return false
            }
        } else if field == lastNameTextField {
            let lastName = field.text
            
            if ((lastName == nil) || (lastName!.count == 0)) {
                shakeTheTextField(field)
                return false
            } else if lastName?.isValidLastName() == false {
                shakeTheTextField(field)
                return false
            }
        } else if field == emailTextField {
            let email = field.text
            
            if email == nil || email!.count == 0 {
                shakeTheTextField(field)
                return false
            } else if email?.isValidEmail() == false {
                shakeTheTextField(field)
                return false
            }
        }  else if field == usernameTextField {
            let username = field.text
            if ((username == nil) || (username!.count == 0)) {
                shakeTheTextField(field)
                return false
            } else if username?.isValidUsername() == false {
                shakeTheTextField(field)
                return false
            } else if isUsernameAvailable == false {
                self.usernameTextField.shake()
                self.showNotifyView("This username already taken. Please enter different username!")
                return false
            }
        } else if field == passwordTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        } else if field == passwordConfirmationTextField {
            let password = field.text
            
            if password?.count == 0 {
                shakeTheTextField(field)
                return false
            } else if password?.isValidPassword() == false {
                shakeTheTextField(field)
                return false
            }
        }
        
        if passwordConfirmationTextField.text != passwordTextField.text {
            shakeTheTextField(passwordConfirmationTextField)
            return false
        }
        
        return true
    }
    
    fileprivate func shakeTheTextField(_ textField: CustomTextField) {
        textField.shake()
    }
    
    fileprivate func checkAvailabilityOf(Username username: String) {
        AuthManager.sharedManager.isUsernameAvailable(username) { (isAvailable) in
            self.isUsernameAvailable = isAvailable
            
            if isAvailable == false {
                self.usernameTextField.shake()
                self.showNotifyView("This username already taken. Please enter different username!")
            } else {
                Whisper.hide()
            }
        }
    }
    
    // MARK: - Create User
    
    fileprivate func createUser() {
        let firstName   = firstNameTextField.text!
        let lastName    = lastNameTextField.text!
        let email       = emailTextField.text!
        let username    = usernameTextField.text!
        let password    = passwordTextField.text!
        
        let user = User()
        user.username = username
        user.fullName = firstName + " " + lastName
        user.email = email
        user.createdTimestamp = Date().timeIntervalSince1970 as NSNumber
        user.activityCount = 0
        user.followerCount = 0
        user.followingCount = 0
        user.profileImage = self.selectedImage
        user.fcmToken = Messaging.messaging().fcmToken
        
        LoadingView.startAnimating()
        
        AuthManager.sharedManager.signUp(email, password: password, user: user) { (error) in
            if let error = error {
                LoadingView.stopAnimating {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
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
    
    // MARK: - Gestures
    
    func didTapAvatarImageView(_ recognizer: UITapGestureRecognizer) {
        presentPhotoSourceSelection()
    }
    
    // MARK: - Photo Source
    
    func presentPhotoSourceSelection() {
        let alertController = UIAlertController(title: nil,
                                                message: nil,
                                                preferredStyle: UIAlertControllerStyle.actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Choose From Library",
                                                style: UIAlertActionStyle.default) { (action) in
                                                    self.presentImagePicker()
        })
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            alertController.addAction(UIAlertAction(title: "Capture Photo",
                                                    style: UIAlertActionStyle.default) { (action) in
                                                        self.presentCamera()
            })
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: UIAlertActionStyle.cancel) { (action) in
                                                    
        })
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func presentImagePicker() {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = UIImagePickerControllerSourceType.photoLibrary
        
        present(controller, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.allowsEditing = true
        controller.sourceType = UIImagePickerControllerSourceType.camera
        
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Helpers
    
    func showNotifyView(_ title: String) {
        var murmur = Murmur(title: title)
        murmur.font = UIFont.montserratLightFont(withSize: 13.0)
        murmur.backgroundColor = UIColor.red
        murmur.titleColor = UIColor.secondaryLightTextColor()
        
        Whisper.show(whistle: murmur, action: .present)
    }
}

// MARK: - CustomTextFieldDelegate

extension SignUpViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            passwordConfirmationTextField.becomeFirstResponder()
        } else if textField == passwordConfirmationTextField {
            view.endEditing(true)
        }
        
        return true
    }
    
    func customTextFieldDidEndEditing(_ textField: CustomTextField) {
        if textField == usernameTextField && textField.text != "" {
            checkAvailabilityOf(Username: textField.text!)
        }
    }
}

// MARK: - InteractiveApprovalFieldDelegate

extension SignUpViewController: InteractiveApprovalFieldDelegate {
    func interactiveApprovalField(_ field: InteractiveApprovalField, didTriggerScheme scheme: InteractiveTextScheme) {
        let type: DocumentType
        
        switch scheme {
        case .termsOfUse:
            type = DocumentType.termsOfUse
        case .privacyPolicy:
            type = DocumentType.privacyPolicy
        }
        
        let viewController = DocumentsWebViewController(withDocumentType: type)
        let navigationController = BaseNavigationController(rootViewController: viewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate

extension SignUpViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true) {
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.selectedImage = image
                self.avatarImageView.image = image
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
