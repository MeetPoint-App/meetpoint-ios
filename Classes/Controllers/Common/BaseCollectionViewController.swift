//
//  BaseCollectionViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 14/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class BaseCollectionViewController: BaseViewController {
    var collectionViewLayout: UICollectionViewLayout!
    var collectionView: UICollectionView!
    
    var canLoadMore: Bool! = false
    
    fileprivate var subComponentsHolderView: UIView!
    fileprivate var subComponentsHolderViewTopConstraint: NSLayoutConstraint!
    fileprivate var subComponentsHolderViewBottomConstraint: NSLayoutConstraint!
    
    fileprivate var loadingIndicator: UIActivityIndicatorView!
    
    fileprivate var statusLabel: UILabel!
    
    fileprivate var state: ControllerState! = ControllerState.none
    
    fileprivate lazy var refreshControl: UIRefreshControl! = {
        [unowned self] in
        
        return UIRefreshControl()
        }()
    
    var contentInset: UIEdgeInsets! {
        get {
            return collectionView.contentInset
        }
        
        set (newValue) {
            collectionView.contentInset = newValue
        }
    }
    
    var scrollIndicatorInsets: UIEdgeInsets! {
        didSet {
            collectionView.scrollIndicatorInsets = scrollIndicatorInsets
        }
    }
    
    var strictBackgroundColor: UIColor? {
        didSet {
            view.backgroundColor = strictBackgroundColor
            
            if let collectionView = collectionView {
                collectionView.backgroundColor = strictBackgroundColor
            }
            
            if let holderView = subComponentsHolderView {
                holderView.backgroundColor = strictBackgroundColor
            }
        }
    }
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    init(withLayout layout: UICollectionViewLayout) {
        super.init()
        
        collectionViewLayout = layout
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView = UICollectionView(frame: view.bounds,
                                          collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.interactive
        collectionView.alwaysBounceVertical = true
        
        view.addSubview(collectionView)
        
        
        subComponentsHolderView = UIView.newAutoLayout()
        subComponentsHolderView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                            action: #selector(didTapSubComponentsHolderBackground(_:))))
        
        view.addSubview(subComponentsHolderView)

        subComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.left)
        subComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right)
        subComponentsHolderViewTopConstraint = subComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.top,
                                                                                   withInset: 0.0)
        subComponentsHolderViewBottomConstraint = subComponentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.bottom,
                                                                                      withInset: 0.0)
        
        setSubComponents(Visible: false, animated: false, completion: nil)
        
        if canPullToRefresh() {
            refreshControl.addTarget(self,
                                     action: #selector(refresh(_:)),
                                     for: UIControlEvents.valueChanged)
            
            collectionView.addSubview(refreshControl)
        }
        
        
        strictBackgroundColor = UIColor.primaryBackgroundColor()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Refresh
    
    func canPullToRefresh() -> Bool {
        return false
    }
    
    @objc fileprivate func refresh(_ refreshControl: UIRefreshControl) {
        loadData(withRefresh: true)
    }
    
    func endRefreshing() {
        guard let refreshControl = refreshControl else {
            return
        }
        
        refreshControl.endRefreshing()
    }
    
    // MARK: - Interface
    
    fileprivate func setSubComponents(Visible visible: Bool, animated: Bool, completion: (() -> Void)?) {
        func set(Visible visible: Bool) {
            subComponentsHolderView.alpha = visible ? 1.0 : 0.0
        }
        
        if visible {
            updateSubComponentsHolderViewConstraints()
            
            subComponentsHolderView.isHidden = false
        }
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                set(Visible: visible)
            }, completion: { (completed) in
                self.subComponentsHolderView.isHidden = !visible
                
                if let completion = completion {
                    completion()
                }
            })
        } else {
            set(Visible: visible)
            
            if let completion = completion {
                completion()
            }
        }
    }
    
    fileprivate func updateSubComponentsHolderViewConstraints() {
        subComponentsHolderViewTopConstraint.constant = defaultTopInset()
        subComponentsHolderViewBottomConstraint.constant = -defaultBottomInset()
        
        view.layoutIfNeeded()
    }
    
    // MARK: - Loading
    
    @discardableResult func loadData(withRefresh refresh: Bool) -> Bool {
        if (state == ControllerState.loading) {
            return false
        }
        
        state = ControllerState.loading
        
        startLoading()
        
        return true
    }
    
    func finishLoading(withState state: ControllerState, andMessage message: String?) {
        switch state {
        case .none:
            collectionView.isScrollEnabled = true
            
            if let label = statusLabel {
                label.isHidden = true
                
                label.text = ""
            }
            
            setSubComponents(Visible: false, animated: true, completion: {
                self.stopLoading()
            })
        case .error:
            collectionView.isScrollEnabled = false
            
            if statusLabel == nil {
                statusLabel = UILabel.newAutoLayout()
                statusLabel.textAlignment = NSTextAlignment.center
                statusLabel.textColor = UIColor.primaryDarkTextColor()
                statusLabel.font = UIFont.montserratRegularFont(withSize: 14.0)
                statusLabel.numberOfLines = 0
                
                subComponentsHolderView.addSubview(statusLabel)
                
                let insets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
                statusLabel.autoPinEdgesToSuperviewEdges(with: insets)
            }
            
            setSubComponents(Visible: true, animated: true, completion: {
                self.statusLabel.isHidden = false
                
                self.statusLabel.text = message
                
                self.stopLoading()
            })
        default:
            break
        }
        
        self.state = state
    }
    
    fileprivate func startLoading() {
        if loadingIndicator == nil {
            loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
            loadingIndicator.hidesWhenStopped = true
            
            subComponentsHolderView.addSubview(loadingIndicator)
            
            loadingIndicator.autoCenterInSuperview()
        }
        
        if let label = statusLabel {
            label.isHidden = true
            
            label.text = ""
        }
        
        loadingIndicator.isHidden = false
        
        loadingIndicator.startAnimating()
        
        setSubComponents(Visible: true, animated: true, completion: nil)
    }
    
    fileprivate func stopLoading() {
        guard let _ = loadingIndicator else {
            return
        }
        
        loadingIndicator.stopAnimating()
        
        loadingIndicator.isHidden = true
    }
    
    // MARK: - Gestures
    
    @objc fileprivate func didTapSubComponentsHolderBackground(_ recognizer: UITapGestureRecognizer) {
        if state == ControllerState.error {
            backgroundTapHandlerOnError()
        }
    }
    
    func backgroundTapHandlerOnError() {
        loadData(withRefresh: true)
    }
    
    // MARK: - Keyboard Notifications
    
    override func didReceiveKeyboardWillShowNotification(_ notification: Notification) {
        handleInsetsOf(ScrollView: collectionView, forAction: KeyboardAction.show, withNotification: notification)
    }
    
    override func didReceiveKeyboardWillHideNotification(_ notification: Notification) {
        handleInsetsOf(ScrollView: collectionView, forAction: KeyboardAction.hide, withNotification: notification)
    }
}

// MARK: - UICollectionViewDelegate

extension BaseCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}

// MARK: - UICollectionViewDataSource

extension BaseCollectionViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}

// MARK: - UIScrollViewDelegate

extension BaseCollectionViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView != collectionView {
            return
        }
        
        if scrollView.contentSize.height < scrollView.frame.size.height {
            return
        }
        
        if (state == ControllerState.loading) || !canLoadMore {
            return
        }
        
        if (((scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y) < 10.0) {
            loadData(withRefresh: false)
        }
    }
}

