//
//  ActivityCreationViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import DropDown
import YKPopupDialogView
import FirebaseAuth
import MapKit
import Kingfisher
import AudioToolbox

fileprivate enum ActivityVisibility {
    case `public`
    case followers
    
    var title: String {
        switch self {
        case .public:
            return "Public"
        case .followers:
            return "Followers"
        }
    }
    
    static let allValues = [`public`, followers]
}

class ActivityCreationViewController: BaseScrollViewController {
    
    fileprivate let DefaultInset: CGFloat = 16.0
    
    fileprivate var descriptionTextField: CustomTextField!
    
    fileprivate var dateDropDownButton: DropDownButton!
    
    fileprivate var locationDropDownButton: DropDownButton!
    
    fileprivate var privacyDropDownButton: DropDownButton!
    fileprivate var privacyDropDown = DropDown()
    
    fileprivate var inviteDropDownButton: DropDownButton!
    fileprivate var inviteDropDownButtonHeightConstraint: NSLayoutConstraint!
    
    fileprivate var createOverlayButton: OverlayButton!
    
    fileprivate var accessoryView: DescriptionInputAccessoryView!
    
    fileprivate var selectedUserListCollectionView: UICollectionView!
    fileprivate var selectedUserListCollectionViewHeightConstraint: NSLayoutConstraint!
    
    lazy var dropDowns: [DropDown] = {
        return [self.privacyDropDown]
    }()
    
    fileprivate var selectedDate: Date?
    fileprivate var selectedLocation: Location?
    fileprivate var activityVisibility: ActivityVisibility?
    fileprivate var selectedImage: UIImage?
    fileprivate var selectedUsers: [User]?
    
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
        title = "Create Activity"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customCrossButton)
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        let activityDetailLabel = UILabel.newAutoLayout()
        activityDetailLabel.text = "Activity Details"
        activityDetailLabel.font = UIFont.montserratSemiboldFont(withSize: 16.0)
        activityDetailLabel.textColor = UIColor.primaryDarkTextColor()
        
        contentView.addSubview(activityDetailLabel)
        
        activityDetailLabel.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        activityDetailLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        activityDetailLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        descriptionTextField = CustomTextField.newAutoLayout()
        descriptionTextField.maximumLength = 50
        descriptionTextField.customTextFieldDelegate = self
        descriptionTextField.placeholder = "Type what you want to do".requiredSuffix()
        
        contentView.addSubview(descriptionTextField)
        
        descriptionTextField.autoPinEdge(ALEdge.top,
                                         to: ALEdge.bottom,
                                         of: activityDetailLabel,
                                         withOffset: DefaultInset / 2.0)
        descriptionTextField.autoSetDimension(ALDimension.height, toSize: CustomTextFieldDefaultHeight)
        descriptionTextField.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        descriptionTextField.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        accessoryView = DescriptionInputAccessoryView(frame: CGRect(x: 0.0, y: 0.0, width: view.frame.width, height: 50.0))
        accessoryView.delegate = self
        descriptionTextField.inputAccessoryView = accessoryView
        
        
        dateDropDownButton = DropDownButton.newAutoLayout()
        dateDropDownButton.setTitle("When?".requiredSuffix(), for: UIControlState.normal)
        dateDropDownButton.addTarget(self, action: #selector(didTapDateDropDownButton(_:)),
                                     for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(dateDropDownButton)
        
        dateDropDownButton.autoPinEdge(ALEdge.top,
                                       to: ALEdge.bottom,
                                       of: descriptionTextField,
                                       withOffset: DefaultInset)
        dateDropDownButton.autoSetDimension(ALDimension.height, toSize: DropDownButtonDefaultHeight)
        dateDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        dateDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        locationDropDownButton = DropDownButton.newAutoLayout()
        locationDropDownButton.setTitle("Where?".requiredSuffix(), for: UIControlState.normal)
        locationDropDownButton.addTarget(self, action: #selector(didTapLocationDropDownButton(_:)),
                                         for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(locationDropDownButton)
        
        locationDropDownButton.autoPinEdge(ALEdge.top,
                                           to: ALEdge.bottom,
                                           of: dateDropDownButton,
                                           withOffset: DefaultInset)
        locationDropDownButton.autoSetDimension(ALDimension.height,
                                                toSize: DropDownButtonDefaultHeight)
        locationDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        locationDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        let activityPrivacyLabel = UILabel.newAutoLayout()
        activityPrivacyLabel.text = "Activity Privacy"
        activityPrivacyLabel.font = UIFont.montserratSemiboldFont(withSize: 16.0)
        activityPrivacyLabel.textColor = UIColor.primaryDarkTextColor()
        
        contentView.addSubview(activityPrivacyLabel)
        
        activityPrivacyLabel.autoPinEdge(ALEdge.top,
                                         to: ALEdge.bottom,
                                         of: locationDropDownButton,
                                         withOffset: DefaultInset)
        activityPrivacyLabel.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        activityPrivacyLabel.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        privacyDropDownButton = DropDownButton.newAutoLayout()
        privacyDropDownButton.setTitle("With who?".requiredSuffix(), for: UIControlState.normal)
        privacyDropDownButton.addTarget(self, action: #selector(didTapPrivacyDropDownButton(_:)),
                                        for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(privacyDropDownButton)
        
        privacyDropDownButton.autoPinEdge(ALEdge.top,
                                          to: ALEdge.bottom,
                                          of: activityPrivacyLabel,
                                          withOffset: DefaultInset)
        privacyDropDownButton.autoSetDimension(ALDimension.height, toSize: DropDownButtonDefaultHeight)
        privacyDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        privacyDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        privacyDropDown.anchorView = privacyDropDownButton
        
        privacyDropDown.dataSource = ActivityVisibility.allValues.map { $0.title }
        privacyDropDown.selectionAction = { [unowned self] (index, item) in
            self.privacyDropDownButton.setTitle(item, for: UIControlState.normal)
            
            if index == ActivityVisibility.followers.hashValue {
                self.inviteDropDownButtonHeightConstraint.constant = DropDownButtonDefaultHeight
                self.selectedUserListCollectionViewHeightConstraint.constant = 44.0
                self.inviteDropDownButton.isHidden = false
                self.selectedUserListCollectionView.isHidden = false
                self.contentView.layoutIfNeeded()
                self.activityVisibility = ActivityVisibility.followers
            } else {
                self.inviteDropDownButtonHeightConstraint.constant = 0.0
                self.selectedUserListCollectionViewHeightConstraint.constant = 0.0
                self.inviteDropDownButton.isHidden = true
                self.selectedUserListCollectionView.isHidden = true
                self.contentView.layoutIfNeeded()
                self.activityVisibility = ActivityVisibility.public
            }
        }
        
        customizeDropDown()
        
        inviteDropDownButton = DropDownButton.newAutoLayout()
        inviteDropDownButton.setTitle("Select Followers to Invite".requiredSuffix(), for: UIControlState.normal)
        inviteDropDownButton.isHidden = true
        inviteDropDownButton.addTarget(self, action: #selector(didInviteDropDownButton(_:)),
                                       for: UIControlEvents.touchUpInside)
        
        contentView.addSubview(inviteDropDownButton)
        
        inviteDropDownButton.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: privacyDropDownButton, withOffset: DefaultInset)
        inviteDropDownButtonHeightConstraint = inviteDropDownButton.autoSetDimension(ALDimension.height, toSize: 0.0)
        inviteDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        inviteDropDownButton.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = UICollectionViewScrollDirection.horizontal
        
        selectedUserListCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        selectedUserListCollectionView.register(HorizontalUserListCollectionViewCell.classForCoder(),
                                                forCellWithReuseIdentifier: HorizontalUserListCollectionViewCellReuseIdentifier)
        selectedUserListCollectionView.backgroundColor = UIColor.clear
        selectedUserListCollectionView.delegate = self
        selectedUserListCollectionView.dataSource = self
        
        contentView.addSubview(selectedUserListCollectionView)
        
        selectedUserListCollectionView.autoPinEdge(ALEdge.top,
                                                   to: ALEdge.bottom,
                                                   of: inviteDropDownButton,
                                                   withOffset: DefaultInset)
        selectedUserListCollectionView.autoPinEdge(toSuperviewEdge: ALEdge.left,
                                                   withInset: DefaultInset)
        selectedUserListCollectionView.autoPinEdge(toSuperviewEdge: ALEdge.right,
                                                   withInset: DefaultInset)
        selectedUserListCollectionViewHeightConstraint = selectedUserListCollectionView.autoSetDimension(ALDimension.height,
                                                                                                         toSize: 0.0)
        selectedUserListCollectionView.autoPinEdge(ALEdge.bottom,
                                                   to: ALEdge.bottom,
                                                   of: contentView,
                                                   withOffset: -(DefaultInset))
        
        
        createOverlayButton = OverlayButton(type: UIButtonType.system)
        createOverlayButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 17.0)
        createOverlayButton.setTitle("CREATE", for: UIControlState.normal)
        createOverlayButton.addTarget(self, action: #selector(didTapCreateButton(_:)),
                                      for: UIControlEvents.touchUpInside)
        
        view.addSubview(createOverlayButton)
        
        createOverlayButton.autoSetDimensions(to: OverlayButtonDefaultSize)
        createOverlayButton.autoAlignAxis(toSuperviewAxis: ALAxis.vertical)
        createOverlayButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 16.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if descriptionTextField.text!.isEmpty {
            descriptionTextField.becomeFirstResponder()
        }
    }
    
    // MARK: - Actions
    
    override func crossButtonTapped(_ button: UIButton) {
        view.endEditing(true)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapCreateButton(_ button: OverlayButton) {
        create()
    }
    
    func didTapDateDropDownButton(_ button: DropDownButton) {
        view.endEditing(true)
        
        let picker = DateTimePicker.show()
        
        picker.highlightColor = UIColor.secondaryBackgroundColor()
        picker.backgroundViewColor = UIColor.black.withAlphaComponent(0.5)
        picker.isDatePickerOnly = false
        picker.selectedDate = Date()
        picker.darkColor = UIColor.primaryDarkTextColor()
        picker.dateFormat = "EEEE, HH:mm"
        picker.completionHandler = { date in
            
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en")
            dateFormatter.dateFormat = "EEEE, HH:mm"
            
            self.selectedDate = date
            
            self.dateDropDownButton.setTitle("\(dateFormatter.string(from: date))", for: UIControlState.normal)
        }
    }
    
    func didTapPrivacyDropDownButton(_ button: DropDownButton) {
        view.endEditing(true)
        
        self.privacyDropDown.show()
    }
    
    func didTapLocationDropDownButton(_ button: DropDownButton) {
        view.endEditing(true)
        
        let viewController = SearchLocationViewController()
        viewController.delegate = self
        
        let navigationController = BaseNavigationController(rootViewController: viewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func didInviteDropDownButton(_ button: DropDownButton) {
        view.endEditing(true)
        
        let viewController = InviteUserViewController(withUsers: selectedUsers)
        viewController.delegate = self
        let navigationController = BaseNavigationController(rootViewController: viewController)
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
    // MARK: - Create
    
    fileprivate func create() {
        view.endEditing(true)
        
        var shouldCreate = true
        
        if descriptionTextField.text?.count == 0 || descriptionTextField.text == "" {
            descriptionTextField.shake()
            shouldCreate = false
        }
        
        if selectedDate == nil {
            dateDropDownButton.shake()
            shouldCreate = false
        }
        
        if selectedLocation == nil {
            locationDropDownButton.shake()
            shouldCreate = false
        }
        
        if activityVisibility == nil {
            privacyDropDownButton.shake()
            shouldCreate = false
        }
        
        if activityVisibility == ActivityVisibility.followers && selectedUsers == nil {
            inviteDropDownButton.shake()
            shouldCreate = false
        }
        
        if !shouldCreate {
            
            AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            return
        }
        
        createActivity()
    }
    
    fileprivate func createActivity() {
        guard let uuid = Auth.auth().currentUser?.uid else {
            return
        }
        
        LoadingView.startAnimating()
        
        func create() {
            StorageManager.sharedManager.uploadCoverPhoto(self.selectedImage!) { (urlString, error) in
                if let error = error {
                    
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    
                    return
                }
                
                let activity = Activity()
                activity.uuid = uuid
                activity.description = self.descriptionTextField.text!
                activity.latitude = self.selectedLocation?.latitude
                activity.longitude = self.selectedLocation?.longitude
                activity.primaryAddress = self.selectedLocation?.primaryAddress
                activity.secondaryAddress = self.selectedLocation?.secondaryAddress
                activity.createdTimestamp = Date().timeIntervalSince1970
                activity.activityTimestamp = self.selectedDate!.timeIntervalSince1970
                activity.commentCount = 0
                activity.participantCount = 0
                activity.coverImageUrl = urlString!
                activity.isPrivate = self.activityVisibility == ActivityVisibility.followers
                
                if self.activityVisibility == ActivityVisibility.public {
                    DatabaseManager.sharedManager.createPublicActivity(activity.dictionaryRepresentation(), { (error) in
                        if let error = error {
                            
                            LoadingView.stopAnimating {
                                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                            }
                            
                            return
                        }
                        
                        self.dismiss(animated: true, completion: {
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: FeedUpdateNotification), object: nil)
                            self.showPopupWith(Title: "Success", andMessage: "Your public activity successfully shared!")
                        })
                    })
                } else {
                    DatabaseManager.sharedManager.createPrivateActivity(self.selectedUsers!, dictionary: activity.dictionaryRepresentation(), { (error) in
                        if let error = error {
                            
                            LoadingView.stopAnimating {
                                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                            }
                            
                            return
                        }
                        
                        self.dismiss(animated: true, completion: {
                            self.showPopupWith(Title: "Success", andMessage: "Your private activity successfully created and invitations sended to selected users!")
                        })
                    })
                }
            }
        }
        
        if selectedLocation?.photo == nil {
            let mapSnapshotOptions = MKMapSnapshotOptions()
            
            let center = CLLocationCoordinate2D(latitude: self.selectedLocation!.latitude!, longitude: self.selectedLocation!.longitude!)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            mapSnapshotOptions.region = region
            
            mapSnapshotOptions.scale = UIScreen.main.scale
            
            mapSnapshotOptions.size = CGSize(width: 500.0, height: 500.0)
            
            mapSnapshotOptions.showsBuildings = true
            mapSnapshotOptions.showsPointsOfInterest = true
            
            let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
            
            let queue = DispatchQueue(label: "mapSnapshot")
            snapShotter.start(with: queue , completionHandler: { (snapshot, error) in
                if error == nil {
                    self.selectedImage = snapshot?.image
                    create()
                }
            })
        } else {
            create()
        }
    }
    
    // MARK: - Customize
    
    func customizeDropDown() {
        let appearance = DropDown.appearance()
        
        appearance.cellHeight = 44.0
        appearance.backgroundColor = UIColor.white
        appearance.selectionBackgroundColor = UIColor.dropDownButtonBackgroundColor()
        appearance.separatorColor = UIColor.listSeparatorColor()
        appearance.cornerRadius = 4.0
        appearance.shadowColor = UIColor(white: 0.6, alpha: 1.0)
        appearance.shadowOpacity = 0.9
        appearance.shadowRadius = 25.0
        appearance.animationduration = 0.25
        appearance.textColor = UIColor.primaryDarkTextColor()
        appearance.textFont = UIFont.montserratRegularFont(withSize: 14.0)
    }
    
    // MARK: - Configure
    
    fileprivate func configure(HorizontalUserListCollectionViewCellDefaultHeight cell: HorizontalUserListCollectionViewCell,
                               withIndexPath indexPath: IndexPath) {
        
        guard let selectedUsers = self.selectedUsers else {
            return
        }
        
        if indexPath.item >= selectedUsers.count {
            return
        }
        
        let user = selectedUsers[indexPath.item]
        
        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
            cell.avatarImageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        } else {
            cell.avatarImageView.image = UIImage(named: "placeholderAvatarSmall")
        }
    }
}

// MARK: - CustomTextFieldDelegate

extension ActivityCreationViewController: CustomTextFieldDelegate {
    func customTextFieldShouldBeginEditing(_ textField: CustomTextField) -> Bool {
        return true
    }
    
    func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool {
        view.endEditing(true)
        
        return true
    }
}

// MARK: - InviteUserViewControllerDelegate

extension ActivityCreationViewController: InviteUserViewControllerDelegate {
    func inviteUserViewController(_ controller: InviteUserViewController, withSelectedUsers users: [User]) {
        self.selectedUsers = users
        
        if users.count > 1 {
            inviteDropDownButton.setTitle("\(users.count) Followers Selected", for: UIControlState.normal)
        } else {
            inviteDropDownButton.setTitle("\(users.count) Follower Selected", for: UIControlState.normal)
        }
        
        self.selectedUserListCollectionView.reloadData()
    }
}

// MARK: - DescriptionInputAccessoryViewDelegate

extension ActivityCreationViewController: DescriptionInputAccessoryViewDelegate {
    func descriptionInputAccessoryView(_ view: DescriptionInputAccessoryView,
                                       selectedActivityType type: ActivityType) {
        let description = type.description
        descriptionTextField.text = description
        descriptionTextField.counterText = "\(description.utf16.count)"
    }
}

// MARK: - SearchLocationViewControllerDelegate

extension ActivityCreationViewController: SearchLocationViewControllerDelegate {
    func searchLocationViewController(_ viewController: SearchLocationViewController,
                                      withSelectedLocation location: Location) {
        guard let address = location.primaryAddress else {
            return
        }
        
        self.selectedLocation = location
        self.selectedImage = location.photo
        
        locationDropDownButton.setTitle(address, for: UIControlState.normal)
    }
}

// MARK: - UICollectionViewDelegate

extension ActivityCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDataSource

extension ActivityCreationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let selectedUsers = self.selectedUsers {
            return selectedUsers.count
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HorizontalUserListCollectionViewCellReuseIdentifier,
                                                      for: indexPath) as! HorizontalUserListCollectionViewCell
        
        configure(HorizontalUserListCollectionViewCellDefaultHeight: cell,
                  withIndexPath: indexPath)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ActivityCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: HorizontalUserListCollectionViewCellDefaultHeight,
                      height: HorizontalUserListCollectionViewCellDefaultHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return DefaultInset / 2.0
    }
}
