//
//  EditProfileViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 21.12.2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Whisper
import AudioToolbox

class EditProfileViewController: BaseScrollViewController {
    weak var delegate: EditProfileViewControllerDelegate!
    
    fileprivate let DefaultInset: CGFloat = 20.0
    fileprivate var AvatarImageViewDimension: CGFloat = 100.0
    
    fileprivate var avatarImageView: UIImageView!
    
    fileprivate var firstNameTextField: CustomTextField!
    fileprivate var lastNameTextField: CustomTextField!
    fileprivate var usernameTextField: CustomTextField!
    fileprivate var emailTextField: CustomTextField!
    
    fileprivate var saveButton: OverlayButton!
    
    fileprivate var user: User?
    
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
    
    init(withUser user: User) {
        super.init()
        self.user = user
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        title = "Edit Profile"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customCrossButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        avatarImageView = UIImageView.newAutoLayout()
        avatarImageView.contentMode = UIViewContentMode.scaleAspectFill
        avatarImageView.layer.cornerRadius = AvatarImageViewDimension / 2.0
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapAvatarImageView(_:))))
        
        contentView.addSubview(avatarImageView)
        
        avatarImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        avatarImageView.autoSetDimensions(to: CGSize(width: AvatarImageViewDimension, height: AvatarImageViewDimension))
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
        
        
        usernameTextField = CustomTextField.newAutoLayout()
        usernameTextField.returnKeyType = UIReturnKeyType.next
        usernameTextField.autocapitalizationType = UITextAutocapitalizationType.none
        usernameTextField.customTextFieldDelegate = self
        usernameTextField.placeholder = "Username".requiredSuffix()
        
        contentView.addSubview(usernameTextField)
        
        usernameTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        usernameTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: lastNameTextField)
        usernameTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        usernameTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        emailTextField = CustomTextField.newAutoLayout()
        emailTextField.returnKeyType = UIReturnKeyType.done
        emailTextField.autocapitalizationType = UITextAutocapitalizationType.none
        emailTextField.customTextFieldDelegate = self
        emailTextField.keyboardType = UIKeyboardType.emailAddress
        emailTextField.placeholder = "Email".requiredSuffix()
        
        contentView.addSubview(emailTextField)
        
        emailTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        emailTextField.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: usernameTextField)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        emailTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        saveButton = OverlayButton(type: UIButtonType.system)
        saveButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        saveButton.setTitle("SAVE", for: UIControlState.normal)
        saveButton.addTarget(self, action: #selector(saveUpButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(saveButton)
        
        saveButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        saveButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: emailTextField, withOffset: DefaultInset)
        saveButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        saveButton.autoPinEdge(ALEdge.bottom, to: ALEdge.bottom, of: contentView, withOffset: -DefaultInset)
        
        if let user = user {
            firstNameTextField.text = user.fullName?.components(separatedBy: " ")[0]
            lastNameTextField.text = user.fullName?.components(separatedBy: " ")[1]
            usernameTextField.text = user.username
            emailTextField.text = user.email
            
            if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
                avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
            } else {
                avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        Whisper.hide()
    }
    
    // MARK: - Actions
    
    override func crossButtonTapped(_ button: UIButton) {
        delegate.editProfileViewControllerDidClose(self)
    }
    
    func saveUpButtonTapped(_ button: OverlayButton) {
        save()
    }
    
    // MARK: - Save
    
    fileprivate func save() {
        view.endEditing(true)
        
        var shouldSave = true
        
        if !validate(Field: firstNameTextField) {
            shouldSave = false
        }
        
        if !validate(Field: lastNameTextField) {
            shouldSave = false
        }
        
        if !validate(Field: usernameTextField) {
            shouldSave = false
        }
        
        if !validate(Field: emailTextField) {
            shouldSave = false
        }
        
        if !shouldSave {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        updateProfile()
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
        } else if field == usernameTextField {
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
        } else if field == emailTextField {
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
    
    fileprivate func checkAvailabilityOf(Username username: String) {
        if username != user?.username {
            AuthManager.sharedManager.isUsernameAvailable(username) { (isAvailable) in
                self.isUsernameAvailable = isAvailable
                
                if isAvailable == false {
                    self.usernameTextField.shake()
                    self.showNotifyView("This username already taken. Please enter different username!")
                } else {
                    Whisper.hide()
                }
            }
        } else {
            self.isUsernameAvailable = true
        }
    }
    
    // MARK: - Update
    
    fileprivate func updateProfile() {
        let firstName   = firstNameTextField.text!
        let lastName    = lastNameTextField.text!
        let username    = usernameTextField.text!
        let email       = emailTextField.text!
        
        guard let user = user else {
            return
        }
        
        user.fullName = firstName + " " + lastName
        user.email = email
        user.username = username
        
        LoadingView.startAnimating()
        
        if let selectedImage = selectedImage {
            
            StorageManager.sharedManager.uploadProfileImage(selectedImage, uid: user.uuid!, completion: { (urlString, error) in
                if let error = error {
                    
                    print(error.localizedDescription)
                    
                    return
                }
                
                user.profileImageUrl = urlString!
                
                DatabaseManager.sharedManager.updateProfile([user.uuid!: user.dictionaryRepresentation()], completion: { (error) in
                    
                    if let error = error {
                        LoadingView.stopAnimating {
                            self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                        }
                        
                        return
                    }
                    
                    LoadingView.stopAnimating {
                        self.selectedImage = nil
                        self.dismiss(animated: true, completion: {
                            self.showPopupWith(Title: "Success", andMessage: "Your profile updated.")
                        })
                    }
                })
            })
        } else {
            DatabaseManager.sharedManager.updateProfile([user.uuid!: user.dictionaryRepresentation()], completion: { (error) in
                
                if let error = error {
                    LoadingView.stopAnimating {
                        self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    }
                    
                    return
                }
                
                LoadingView.stopAnimating {
                    self.selectedImage = nil
                    self.dismiss(animated: true, completion: {
                        self.showPopupWith(Title: "Success", andMessage: "Your profile updated.")
                    })
                }
            })
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
                                                style: UIAlertActionStyle.destructive) { (action) in
                                                    
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

extension EditProfileViewController: CustomTextFieldDelegate {
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        if textField == firstNameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            usernameTextField.becomeFirstResponder()
        } else if textField == usernameTextField {
            emailTextField.becomeFirstResponder()
        } else {
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

// MARK: - UINavigationControllerDelegate & UIImagePickerControllerDelegate

extension EditProfileViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
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

// MARK: - EditProfileViewControllerDelegate

protocol EditProfileViewControllerDelegate: NSObjectProtocol {
    func editProfileViewControllerDidClose(_ controller: EditProfileViewController)
}

