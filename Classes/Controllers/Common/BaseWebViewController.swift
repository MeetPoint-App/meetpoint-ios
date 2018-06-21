//
//  BaseWebViewController.swift
//  Meeting
//
//  Created by yusuf_kildan on 6.01.2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class BaseWebViewController: BaseViewController {
    
    var webView: UIWebView!
    
    // MARK: - View's Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = UIWebView.newAutoLayout()
        webView.delegate = self
        
        view.addSubview(webView)
        
        webView.autoPinEdgesToSuperviewEdges()
    }
}

// MARK: - UIWebViewDelegate

extension BaseWebViewController : UIWebViewDelegate {
    
}

