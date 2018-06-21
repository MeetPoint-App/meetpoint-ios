//
//  OnboardingViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 12/10/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

fileprivate let FacebookPermissions = ["public_profile", "email"]
fileprivate let FacebookParameters  = ["fields": "id, name, first_name, last_name, picture.type(large), email"]

class OnboardingViewController: BaseViewController {
    
    fileprivate var scrollView: UIScrollView!
    fileprivate var pageControl: UIPageControl!
    
    fileprivate let DefaultInset: CGFloat = 16.0
    fileprivate let BottomComponentsHolderViewDefaultHeight: CGFloat = 100.0

    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init() {
        super.init()
        
        commonInit()
    }
    
    fileprivate func commonInit() {}
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView = UIScrollView.newAutoLayout()
        scrollView.backgroundColor = UIColor.clear
        scrollView.isScrollEnabled = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        
        view.addSubview(scrollView)
        
        scrollView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.bottom)
        scrollView.autoPinEdge(toSuperviewEdge: ALEdge.bottom, withInset: 100.0)
        
        
        let logoImageView = UIImageView.newAutoLayout()
        logoImageView.image = UIImage(named: "logo")
        
        view.addSubview(logoImageView)
        
        logoImageView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        logoImageView.autoPinEdge(toSuperviewEdge: ALEdge.top, withInset: DefaultInset)
        
        
        let bottomComponentsHolderView = UIView.newAutoLayout()
        bottomComponentsHolderView.backgroundColor = UIColor.white
        
        view.addSubview(bottomComponentsHolderView)
        
        bottomComponentsHolderView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.top)
        bottomComponentsHolderView.autoSetDimension(ALDimension.height, toSize: BottomComponentsHolderViewDefaultHeight)
        
        let screenWidth = view.frame.width
        
        
        let loginButton = UIButton(type: UIButtonType.custom)
        loginButton.backgroundColor = UIColor.primaryButtonBackgroundColor()
        loginButton.setTitle("Login", for: UIControlState())
        loginButton.setTitleColor(UIColor.primaryButtonTitleColor(), for: UIControlState())
        loginButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 14.0)
        loginButton.addTarget(self, action: #selector(loginButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        
        bottomComponentsHolderView.addSubview(loginButton)
        
        loginButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        loginButton.autoPinEdge(toSuperviewEdge: ALEdge.left)
        loginButton.autoSetDimensions(to: CGSize(width: screenWidth / 2, height: 50.0))
        
        
        let signUpButton = UIButton(type: UIButtonType.system)
        signUpButton.backgroundColor = UIColor.secondaryButtonBackgroundColor()
        signUpButton.setTitleColor(UIColor.secondaryButtonTitleColor(), for: UIControlState())
        signUpButton.setTitle("Sign Up", for: UIControlState())
        signUpButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 14.0)
        signUpButton.addTarget(self,
                               action: #selector(signUpButtonTapped(_:)),
                               for: UIControlEvents.touchUpInside)
        
        bottomComponentsHolderView.addSubview(signUpButton)
        
        signUpButton.autoPinEdge(toSuperviewEdge: ALEdge.right)
        signUpButton.autoPinEdge(toSuperviewEdge: ALEdge.bottom)
        signUpButton.autoSetDimensions(to: CGSize(width: screenWidth / 2, height: 50.0))
        
        
        let connectWithFacebookButton = UIButton(type: UIButtonType.system)
        connectWithFacebookButton.backgroundColor = UIColor.facebookButtonBackgroundColor()
        connectWithFacebookButton.setTitleColor(UIColor.secondaryButtonTitleColor(), for: UIControlState())
        connectWithFacebookButton.setTitle("Connect with Facebook", for: UIControlState())
        connectWithFacebookButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 14.0)
        connectWithFacebookButton.addTarget(self,
                                            action: #selector(connectWithFacebookButtonTapped(_:)),
                                            for: UIControlEvents.touchUpInside)
        
        bottomComponentsHolderView.addSubview(connectWithFacebookButton)
        
        connectWithFacebookButton.autoPinEdge(toSuperviewEdge: ALEdge.right)
        connectWithFacebookButton.autoPinEdge(toSuperviewEdge: ALEdge.left)
        connectWithFacebookButton.autoSetDimension(ALDimension.height, toSize: 50.0)
        connectWithFacebookButton.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: signUpButton)
        connectWithFacebookButton.autoPinEdge(ALEdge.top, to: ALEdge.top, of: bottomComponentsHolderView)
        
        
        pageControl = UIPageControl.newAutoLayout()
        pageControl.currentPage = 0
        pageControl.isEnabled = false
        pageControl.numberOfPages = OnboardPage.allPages.count
        
        bottomComponentsHolderView.addSubview(pageControl)
        
        pageControl.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        pageControl.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: bottomComponentsHolderView, withOffset: -DefaultInset)
        
        view.layoutIfNeeded()
        
        
        var prevOnboardPageView: UIView!
        
        for onboardPage in OnboardPage.allPages {
            let onboardPageView = OnboardingPageView.newAutoLayout()
            onboardPageView.titleLabel.text = onboardPage.title
            onboardPageView.imageView.image = onboardPage.image
            
            scrollView.addSubview(onboardPageView)
            
            if prevOnboardPageView == nil {
                onboardPageView.autoPinEdge(ALEdge.left, to: ALEdge.left, of: scrollView)
            }else {
                onboardPageView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: prevOnboardPageView)
            }
            
            onboardPageView.autoPinEdge(toSuperviewEdge: ALEdge.top)
            onboardPageView.autoSetDimensions(to: CGSize(width: screenWidth, height: scrollView.frame.size.height))
            
            prevOnboardPageView = onboardPageView
        }
        
        prevOnboardPageView!.autoPinEdge(ALEdge.right, to: ALEdge.right, of: scrollView)
        
        let width = screenWidth * CGFloat(OnboardPage.allPages.count)
        
        scrollView.contentSize = CGSize(width: width, height: scrollView.frame.size.height)
        
        
        _ = Timer.scheduledTimer(timeInterval: 3.0,
                                 target: self,
                                 selector: #selector(showNextOnboardingPage),
                                 userInfo: nil,
                                 repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
    }
    
    // MARK: - Interface
    
    override func shouldShowNavigationBar() -> Bool {
        return false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Actions
    
    func loginButtonTapped(_ button: UIButton) {
        showSignInPage()
    }
    
    func signUpButtonTapped(_ button: UIButton) {
        showSignUpPage()
    }
    
    func connectWithFacebookButtonTapped(_ button: UIButton) {
        authenticateWithFacebook()
    }
    
    func showSignInPage() {
        let signInViewController = SignInViewController()
        navigationController?.pushViewController(signInViewController, animated: true)
    }
    
    func showSignUpPage() {
        let signUpViewController = SignUpViewController()
        navigationController?.pushViewController(signUpViewController, animated: true)
    }
    
    @objc func showNextOnboardingPage() {
        var currentPage = pageControl.currentPage
        
        if currentPage == (OnboardPage.allPages.count - 1) {
            currentPage = -1
        }
        
        let offsetX = CGFloat(currentPage + 1) * view.frame.size.width
        
        UIView.animate(withDuration: 0.33, animations: {
            self.scrollView.contentOffset = CGPoint(x: offsetX, y: 0.0)
        })
    }
    
    // MARK: - Facebook Authentication
    
    func authenticateWithFacebook() {
        LoadingView.startAnimating()
        
        if let _ = FBSDKAccessToken.current() {
            getFacebookProfileInformation()
            
            return
        }
        
        let loginManager = FBSDKLoginManager()
        
        loginManager.logIn(withReadPermissions: FacebookPermissions,
                           from: self) { (result, error) in
                                                if error != nil {
                                                    LoadingView.stopAnimating({
                                                        self.showPopupWith(Title: "Error", andMessage: "Unable to retrieve Facebook account information.")
                                                    })
                                                } else if (result?.isCancelled)! {
                                                    LoadingView.stopAnimating({
                                                        self.showPopupWith(Title: "Error", andMessage: "Facebook authentication cancelled.")
                                                    })
                                                } else {
                                                    if let _ = FBSDKAccessToken.current() {
                                                        self.getFacebookProfileInformation()
                                                    } else {
                                                        LoadingView.stopAnimating({
                                                            self.showPopupWith(Title: "Error", andMessage: "Unable to retrieve Facebook account information.")
                                                        })
                                                    }
                                                }
        }
    }
    
    func getFacebookProfileInformation() {
        let graphRequest = FBSDKGraphRequest.init(graphPath: "me",
                                                  parameters: FacebookParameters)!
        
        graphRequest.start { (connection, result, error) in
            if error == nil {
                guard let result = result else {
                    LoadingView.stopAnimating({
                        self.showPopupWith(Title: "Error", andMessage: "Unable to retrieve Facebook account information.")
                    })
                    
                    return
                }
                
                self.handleFacebookAuthenticationWith(Result: result as AnyObject)
            } else {
                LoadingView.stopAnimating({
                    self.showPopupWith(Title: "Error", andMessage: "Unable to retrieve Facebook account information.")
                })
            }
        }
    }
    
    func handleFacebookAuthenticationWith(Result result: AnyObject) {
        guard let accessToken = FBSDKAccessToken.current(), let accessTokenString = accessToken.tokenString else {
            return
        }
        
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        AuthManager.sharedManager.connectWithFacebook(result, credentials: credentials) { (error) in
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
}

// MARK: - UIScrollViewDelegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = view.frame.size.width
        
        if width == 0 {
            return
        }
        
        let page = Int(floor((scrollView.contentOffset.x - width / 2) / width)) + 1;
        
        pageControl.currentPage = page
    }
}
