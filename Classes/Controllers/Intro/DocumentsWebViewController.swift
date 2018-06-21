//
//  DocumentsWebViewController.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 6.01.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit

let TermsOfUseURL: String = "http://meetpointapp.co/terms_of_use.html"
let PrivacyPolicyURL: String = "http://meetpointapp.co/privacy_policy.html"

enum DocumentType {
    case termsOfUse
    case privacyPolicy
    
    var url: String {
        switch self {
        case .termsOfUse:
            return TermsOfUseURL
        case .privacyPolicy:
            return PrivacyPolicyURL
        }
    }
    
    var title: String {
        switch self {
        case .termsOfUse:
            return "Terms of Use"
        case .privacyPolicy:
            return "Privacy Policy"
        }
    }
    
    static let allValues = [termsOfUse, privacyPolicy]
}

class DocumentsWebViewController: BaseWebViewController {
    fileprivate var urlString: String?
    
    // MARK: - Init / Deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }

    init(withDocumentType type: DocumentType) {
        super.init()
        
        self.title = type.title
        self.urlString = type.url
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.customCrossButton)
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let urlString = urlString else {
            return
        }
        
        if let url = URL(string: urlString) {
            webView.loadRequest(URLRequest(url: url))
        }
    }
    
    // MARK: - Button Actions
    
    override func crossButtonTapped(_ button: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UIWebViewDelegate
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        print(error?.localizedDescription)
    }
}

