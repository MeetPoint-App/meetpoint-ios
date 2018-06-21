//
//  ActivityDetailViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 21/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import Kingfisher
import Firebase

class ActivityDetailViewController: BaseCollectionViewController {
    
    fileprivate var activity: Activity?
    
    fileprivate var comments: [Comment] = []
    
    fileprivate var commentView: CommentInputView!
    fileprivate var commentViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate var activeCommentIndex: Int!
    
    fileprivate var reference: DatabaseReference!
    fileprivate var databaseHandle: DatabaseHandle!
    
    fileprivate var moreButton: UIButton!
    fileprivate var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    init(withActivity activity: Activity) {
        super.init()
        
        self.activity = activity
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        if let user = activity?.user, let username = user.username {
            self.title = "\(username)'s Activity"
        }
        
        moreButton = UIButton(type: UIButtonType.system)
        moreButton.tintColor = UIColor.defaultTintColor()
        moreButton.frame = CGRect(x: 0.0, y: 0.0, width: 44.0, height: 44.0)
        moreButton.setImage(UIImage(named: "iconMore"), for: UIControlState.normal)
        moreButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.right
        moreButton.addTarget(self, action: #selector(didTapMoreButton(_:)), for: UIControlEvents.touchUpInside)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBackButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
        
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.startAnimating()
    }
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        let layout = UICollectionViewFlowLayout()
        self.collectionViewLayout = layout
        
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.primaryBackgroundColor()
        
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.none
        collectionView.register(ActivityCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: ActivityCollectionViewCellReuseIdentifier)
        collectionView.register(ActivityFooterView.classForCoder(),
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: ActivityFooterViewReuseIdentifier)
        collectionView.register(CommentCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: CommentCollectionViewCellReuseIdentifier)
        collectionView.register(EmptyStateCollectionViewCell.classForCoder(),
                                forCellWithReuseIdentifier: EmptyStateCollectionViewCellReuseIdentifier)
        
        
        commentView = CommentInputView.newAutoLayout()
        commentView.font = UIFont.montserratMediumFont(withSize: 14.0)
        commentView.textColor = UIColor.primaryDarkTextColor()
        commentView.textField.tintColor = UIColor.secondaryBackgroundColor()
        commentView.shouldShowShadow = true
        commentView.placeholder = "Leave a comment..."
        commentView.isEnabled = false
        commentView.backgroundColor = UIColor.primaryBackgroundColor()
        commentView.delegate = self
        
        view.addSubview(commentView)

        commentView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        commentView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        commentViewBottomConstraint = commentView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                                              withInset: MainTabBarDefaultHeight)
        commentView.autoSetDimension(ALDimension.height, toSize: CommentInputViewDefaultHeight)

        
        var insets = contentInset
        insets?.bottom = defaultBottomInset()
        
        scrollIndicatorInsets = insets
        
        contentInset = insets
        
        
        loadData(withRefresh: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // To ensure observer removed only when the viewController is popped.
        if self.isMovingFromParentViewController {
            if databaseHandle != nil {
                self.reference.removeObserver(withHandle: databaseHandle)
            }
        }
    }
    
    // MARK: - Interface
    
    override func defaultBottomInset() -> CGFloat {
        return MainTabBarDefaultHeight + CommentInputViewDefaultHeight
    }
    
    override func canPullToRefresh() -> Bool {
        return true
    }
    
    // MARK: - Load Data
    
    @discardableResult override func loadData(withRefresh refresh: Bool) -> Bool {
        if !super.loadData(withRefresh: refresh) {
            return false
        }
        
        if refresh {
            self.comments = []
        }
        
        guard let activityIdentifier = activity?.identifier else {
            return true
        }
        
        guard let uid = activity?.user?.uuid else {
            return true
        }
        
        DatabaseManager.sharedManager.getActivityOfUser(uid, activityIdentifier: activityIdentifier) { (error, activity) in
            if let error = error {
                self.finishLoading(withState: ControllerState.none, andMessage: nil)
                
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                
                self.moreButton.isEnabled = false
                
                return
            }
            
            self.activity = activity
            
            self.reference = Router.comment(identifier: activityIdentifier).reference
            
            self.reference.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
                if snapshot.childrenCount == 0 {
                    self.collectionView.reloadData()
                    self.endRefreshing()
                    self.finishLoading(withState: ControllerState.none, andMessage: nil)

                    return
                }
            })
            
            self.databaseHandle = self.reference.observe(DataEventType.childAdded, with: { (snapshot) in
                guard let dict = snapshot.value as? [String: Any] else {
                    return
                }
                
                guard let uid = dict["uuid"] as? String else {
                    return
                }
                
                DatabaseManager.sharedManager.getUserWith(uid, completion: { (user, error) in
                    if let error = error {
                        self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
                        
                        return
                    }
                    
                    let comment = Comment(snapshot: snapshot)
                    comment.user = user
                    comment.isOwnComment = uid == Auth.auth().currentUser?.uid
                    
                    self.comments.append(comment)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                        self.comments = self.comments.sorted {
                            $0.createdTimestamp! < $1.createdTimestamp!
                        }
                        
                        self.collectionView.reloadData()
                        self.endRefreshing()
                        self.finishLoading(withState: ControllerState.none, andMessage: nil)
                    })
                })
            }, withCancel: { (error) in
                self.finishLoading(withState: ControllerState.error, andMessage: error.localizedDescription)
            })
        }
        
        return true
    }
    
    // MARK: - Configure
    
    fileprivate func configure(ActivityCollectionViewCell cell: ActivityCollectionViewCell, withIndexPath indexPath: IndexPath) {
        
        guard let activity = activity else {
            return
        }
        
        if let urlString = activity.coverImageUrl, let url = URL(string: urlString) {
            cell.imageView.imageView.kf.setImage(with: url, options: [.transition(.fade(0.2))])
        }
        
        if let description = activity.description {
            cell.descriptionLabel.text = description
        }
        
        if let primaryAddress = activity.primaryAddress {
            cell.locationLabel.title = primaryAddress
        }
        
        if let activityTimestamp = activity.activityTimestamp {
            cell.timeLabel.title = NSDate.dayDifference(activityTimestamp)
        }
        
        if let commentCount = activity.commentCount {
            cell.commentCountLabel.title = "\(commentCount)"
        }
        
        if let participantCount = activity.participantCount, let isPrivate = activity.isPrivate {
            
            let text: String
            
            if isPrivate {
                guard let invitedUsers = activity.invitedUsers else {
                    return
                }
                
                text = "\(participantCount)/\(invitedUsers.count)"
            } else {
                text = "\(participantCount)"
            }
            
            cell.participantCountLabel.title = text
        }
        
        cell.distanceLabel.isHidden = true
    }
    
    fileprivate func configure(ActivityFooterView footerView: ActivityFooterView, withIndexPath indexPath: IndexPath) {
        footerView.backgroundColor = UIColor.primaryBackgroundColor()
        footerView.delegate = self
        
        guard let activity = self.activity else {
            return
        }
        
        if activity.isParticipated == 0 {
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.selected
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        } else if activity.isParticipated == 1 {
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.selected
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
        } else {
            footerView.goingButton.actionButtonState = InteractiveActionButtonState.default
            footerView.interestedButton.actionButtonState = InteractiveActionButtonState.default
        }
    }
    
    fileprivate func configure(CommentCollectionViewCell cell: CommentCollectionViewCell, withIndexPath indexPath: IndexPath) {
        
        if indexPath.item  >= comments.count {
            return
        }
        
        cell.delegate = self
        
        let comment = comments[indexPath.item]
        
        if let commentText = comment.commentText {
            cell.subtitle = commentText
        }
        
        guard let user = comment.user else {
            return
        }
        
        if let fullName = user.fullName {
            cell.title = fullName
        }
        
        if let timestamp = comment.createdTimestamp {
            let date = NSDate(timeIntervalSince1970: timestamp)
            cell.time = NSDate.timePassedSinceDate(date)
        }
        
        if let urlString = user.profileImageUrl, let url = URL(string: urlString) {
            cell.avatarImageView.kf.setImage(with: url, options: [])
        } else {
            cell.avatarImageView.image = UIImage(named: "placeholderAvatarLarge")
        }
    }
    
    fileprivate func configure(EmptyStateCollectionViewCell cell: EmptyStateCollectionViewCell, withIndexPath indexPath: IndexPath) {
        
        cell.emptyStateView.update(withImage: UIImage(named: "emptyStateCommentIcon"), andMessageTitle: "Nothing is here!", andMessageSubtitle: "Start conversation and learn the details.", andButtonTitle: nil)
    }
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            self.presentActionSheetForActivityDetail()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            if comments.count == 0 {
                return 1
            }
            
            return comments.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ActivityCollectionViewCellReuseIdentifier, for: indexPath) as! ActivityCollectionViewCell
            
            configure(ActivityCollectionViewCell: cell, withIndexPath: indexPath)
            
            return cell
        } else {
            
            if comments.count == 0 {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyStateCollectionViewCellReuseIdentifier, for: indexPath) as! EmptyStateCollectionViewCell
                
                configure(EmptyStateCollectionViewCell: cell, withIndexPath: indexPath)
                
                return cell
            }
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCellReuseIdentifier, for: indexPath) as! CommentCollectionViewCell
            
            configure(CommentCollectionViewCell: cell, withIndexPath: indexPath)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ActivityFooterViewReuseIdentifier, for: indexPath) as! ActivityFooterView
            
            configure(ActivityFooterView: footerView, withIndexPath: indexPath)
            
            return footerView
        }
        
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        guard let activity = activity else {
            return CGSize.zero
        }
        
        if section == 0 {
            if let activityTimestamp = activity.activityTimestamp {
                if (activityTimestamp > NSDate().timeIntervalSince1970) && (activity.isOwnActivity == false)  {
                    return CGSize(width: self.view.frame.size.width, height: ActivityFooterViewDefaultHeight)
                } else {
                    return CGSize.zero
                }
            } else {
                return CGSize.zero
            }
        } else {
            return CGSize.zero
        }
    }
    
    // MARK: - Handle Inset
    
    override func handleInsetsOf(ScrollView scrollView: UIScrollView,
                                 forAction action: KeyboardAction,
                                 withNotification notification: Notification) {
        if ((self.isViewLoaded == true && self.view.window != nil) == false) {
            return
        }
        
        let application = UIApplication.shared
        
        if application.applicationState != UIApplicationState.active {
            return
        }
        
        var insets = scrollView.contentInset
        
        guard let keyboardFrame = (notification as NSNotification).userInfo![UIKeyboardFrameEndUserInfoKey] else {
            return
        }
        
        guard let keyboardAnimationDuration = (notification as NSNotification).userInfo![UIKeyboardAnimationDurationUserInfoKey] else {
            return
        }
        
        switch action {
        case KeyboardAction.show:
            let keyboardHeight = (keyboardFrame as AnyObject).cgRectValue.size.height
            
            insets.bottom = keyboardHeight + CommentInputViewDefaultHeight
            
            scrollView.scrollIndicatorInsets = insets
            
            commentViewBottomConstraint.constant = -keyboardHeight
            
            UIView.animate(withDuration: (keyboardAnimationDuration as AnyObject).doubleValue, animations: {
                self.view.layoutIfNeeded()
            })
        case KeyboardAction.hide:
            insets.bottom = defaultBottomInset()
            
            scrollView.scrollIndicatorInsets = insets
            
            commentViewBottomConstraint.constant = -MainTabBarDefaultHeight
            
            UIView.animate(withDuration: (keyboardAnimationDuration as AnyObject).doubleValue, animations: {
                self.view.layoutIfNeeded()
            })
        }
        
        scrollView.contentInset = insets
    }
    
    // MARK: - Actions
    
    func didTapMoreButton(_ button: UIButton) {
        guard let activity = activity else {
            return
        }
        
        presentActionSheetForActivity(activity)
    }
    
    // MARK: - Action Sheet
    
    fileprivate func presentActionSheetForActivity(_ activity: Activity) {
        let alertController = UIAlertController()
        
        if activity.isOwnActivity == true {
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
                self.delete(activity: activity)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }else {
            alertController.addAction(UIAlertAction(title: "Report Abuse", style: UIAlertActionStyle.default, handler: { (_) in
                self.report(activity: activity)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func presentActionSheetForComment(_ comment: Comment) {
        guard let index = comments.index(where: {$0.identifier == comment.identifier}) else {
            return
        }
        
        activeCommentIndex = Int(index)
        
        let alertController = UIAlertController()
        
        if comment.isOwnComment == true {
            alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
                self.delete(comment: comment)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }else {
            alertController.addAction(UIAlertAction(title: "Report Abuse", style: UIAlertActionStyle.default, handler: { (_) in
                self.report(comment: comment)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) in
                
            }))
        }
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func presentActionSheetForActivityDetail() {
        guard let activity = activity else {
            return
        }
        
        let alertController = UIAlertController()
        
        alertController.addAction(UIAlertAction(title: "Show on the map", style: UIAlertActionStyle.default, handler: { (_) in
            let viewController = MapViewController(WithActivity: activity)
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: " Show the participants", style: UIAlertActionStyle.default, handler: { (_) in
            let viewController = ParticipantViewController(withActivity: activity)
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - Activity Actions
    
    fileprivate func delete(activity: Activity) {
        let alertController = UIAlertController(title: "Are you sure to delete this activity?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
            
            guard let activity = self.activity else {
                return
            }
            
            guard let identifier = activity.identifier else {
                return
            }
            
            DatabaseManager.sharedManager.deleteActivity(identifier, completion: { (error) in
                if let error = error {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    
                    return
                }
                
                self.navigationController?.popViewController(animated: true)
                self.showPopupWith(Title: "Success", andMessage: "Your activity successfully deleted.")
            })
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func delete(comment: Comment) {
        let alertController = UIAlertController(title: "Are you sure to delete this comment?", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: { (_) in
            
            let index: Int! = self.activeCommentIndex
            
            let comment = self.comments[index]
            
            guard let activity = self.activity else {
                return
            }
            
            guard let commentIdentifier = comment.identifier else {
                return
            }
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
            
            DatabaseManager.sharedManager.deleteComment(activity, commentIdentifier: commentIdentifier, completion: { (error) in
                if let error = error {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    return
                }
                
                self.comments.remove(at: index)
                self.collectionView.reloadData()
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.moreButton)
                
                self.showPopupWith(Title: "Succes", andMessage: "Your comment successfully deleted.")
            })
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    fileprivate func report(activity: Activity) {
        DatabaseManager.sharedManager.reportActivity(activity) { (error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
            }
            
            self.showPopupWith(Title: "Success",
                               andMessage: "Thanks for reporting this activity. We will examine it.")
        }
    }
    
    fileprivate func report(comment: Comment) {
        DatabaseManager.sharedManager.reportComment(comment) { (error) in
            if let error = error {
                self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
            }
            
            self.showPopupWith(Title: "Success",
                               andMessage: "Thanks for reporting this comment. We will examine it.")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ActivityDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: view.frame.size.width, height: ActivityCollectionViewCell.cellHeight())
        } else {
            
            if comments.count == 0 {
                let height = view.frame.size.height - (ActivityCollectionViewCell.cellHeight() + defaultTopInset() + defaultBottomInset())
                
                return CGSize(width: view.frame.size.width, height: height)
            }
            
            let comment = comments[indexPath.item]
            return CGSize(width: view.frame.size.width, height: CommentCollectionViewCell.cellHeight(withComment: comment))
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}

// MARK: - CommentInputViewDelegate

extension ActivityDetailViewController: CommentInputViewDelegate {
    func commentInputViewShouldReturn(_ view: CommentInputView) -> Bool {
        if view.textField.isFirstResponder {
            view.textField.resignFirstResponder()
        }
        
        return true
    }
    
    func commentInputViewDidTapActionButton(_ view: CommentInputView) {
        if !commentView.text.isEmpty {
            
            guard let uuid = Auth.auth().currentUser?.uid else {
                return
            }
            
            guard let activity = activity else {
                return
            }
            
            let comment = Comment()
            comment.commentText = commentView.text
            comment.uuid = uuid
            comment.createdTimestamp = Date().timeIntervalSince1970
            
            view.text = ""
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityIndicator)
            
            DatabaseManager.sharedManager.createComment(comment.dictionaryRepresentation(), activity: activity, completion: { (error) in
                if let error = error {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.moreButton)
                    
                    return
                }
                
                self.collectionView.reloadData()
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.moreButton)
                
                self.scrollToBottom()
            })
        }
    }
    
    func commentInputView(_ view: CommentInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    func commentInputViewEditingChanged(_ view: CommentInputView) {
        if commentView.text.isEmpty == true || commentView.text == "" {
            commentView.isEnabled = false
        }else {
            commentView.isEnabled = true
        }
    }
    
    func commentInputViewDidTapBackground(_ view: CommentInputView) {
        if !view.textField.isFirstResponder {
            view.textField.becomeFirstResponder()
            scrollToBottom()
        }
    }
    
    func commentInputViewDidBeginEditing(_ view: CommentInputView) {
        //scrollToBottom()
    }
    
    func scrollToBottom() {
        if comments.count != 0 {
            let indexPath = IndexPath(item: self.comments.count - 1, section: 1)
            self.collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.bottom, animated: true)
        }
    }
}

// MARK: - CommentCollectionViewCellDelegate

extension ActivityDetailViewController: CommentCollectionViewCellDelegate {
    func commentCollectionViewCellDidTapTitleLabel(_ cell: CommentCollectionViewCell) {
        
        guard let index = commentIndex(cell) else {
            return
        }
        
        if index >= comments.count {
            return
        }
        
        let comment = comments[index]
        
        if let user = comment.user {
            showProfileViewController(withUser: user)
        }
    }
    
    func commentCollectionViewCellDidActionButtonTapped(_ cell: CommentCollectionViewCell) {
        guard let index = commentIndex(cell) else {
            return
        }
        
        if index >= comments.count {
            return
        }
        
        let comment = comments[index]
        
        presentActionSheetForComment(comment)
    }
    
    func commentCollectionViewCellDidTapAvatarImageView(_ cell: CommentCollectionViewCell) {
        guard let index = commentIndex(cell) else {
            return
        }
        
        if index >= comments.count {
            return
        }
        
        let comment = comments[index]
        
        if let user = comment.user {
            showProfileViewController(withUser: user)
        }
    }
    
    func showProfileViewController(withUser user: User) {
        view.endEditing(true)
        
        let viewController = ProfileViewController(withUser: user)
        
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    fileprivate func commentIndex(_ cell: CommentCollectionViewCell) -> Int? {
        
        guard let indexPath = collectionView.indexPath(for: cell) else {
            return nil
        }
        
        return indexPath.item
    }
}

// MARK: - ActivityFooterViewDelegate

extension ActivityDetailViewController: ActivityFooterViewDelegate {
    func activityFooterViewDidTapGoingButton(_ footerView: ActivityFooterView,
                                             withInteractiveActionButton button: InteractiveActionButton) {
        
        
        guard  let activity = self.activity, let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            
            if let error = error {
                LoadingView.stopAnimating {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    footerView.toggleActionButton(button)
                }
                return
            }
            
            let value: Int?
            if footerView.goingButton.actionButtonState == InteractiveActionButtonState.default {
                value = nil
            } else {
                value = footerView.goingButton.actionButtonType.hashValue
            }
            
            activity.isParticipated = value
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func activityFooterViewDidTapInterestedButton(_ footerView: ActivityFooterView,
                                                  withInteractiveActionButton button: InteractiveActionButton) {
        
        guard let activity = self.activity, let activityTimestamp = activity.activityTimestamp else {
            return
        }
        
        let currentTimestamp = Date().timeIntervalSince1970 as Double
        
        if activityTimestamp < currentTimestamp {
            self.showPopupWith(Title: "Error",
                               andMessage: "Activity time already passed. You can't join right now!")
            
            return
        }
        
        footerView.toggleActionButton(button)
        
        LoadingView.startAnimating()
        DatabaseManager.sharedManager.participate(activity, state: button.actionButtonState, type: button.actionButtonType) { (count, error) in
            if let error = error {
                LoadingView.stopAnimating {
                    self.showPopupWith(Title: "Error", andMessage: error.localizedDescription)
                    footerView.toggleActionButton(button)
                }
                
                return
            }
            
            let value: Int?
            if footerView.interestedButton.actionButtonState == InteractiveActionButtonState.default {
                value = nil
            } else {
                value = footerView.interestedButton.actionButtonType.hashValue
            }
            
            activity.isParticipated = value
            
            if let count = count {
                LoadingView.stopAnimating {
                    activity.participantCount = Int(count)
                    self.collectionView.reloadData()
                }
            }
        }
    }
}
