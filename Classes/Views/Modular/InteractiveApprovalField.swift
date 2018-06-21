//
//  InteractiveApprovalField.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 28.12.2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

enum ApprovalState: Int {
    case disapproved = 0
    case approved    = 1
}

enum InteractiveTextScheme: String {
    case termsOfUse     = "meetpoint://terms_of_use"
    case privacyPolicy  = "meetpoint://privacy_policy"
}

class InteractiveApprovalField: UIView {
    weak var delegate: InteractiveApprovalFieldDelegate!
    
    fileprivate var approveButton: UIButton!
    fileprivate var textView: UITextView!
    
    var state: ApprovalState! = ApprovalState.disapproved
    
    // MARK: - Constructors
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        approveButton = UIButton(type: UIButtonType.custom)
        approveButton.addTarget(self,
                                action: #selector(approveButtonTapped(_:)),
                                for: UIControlEvents.touchUpInside)
        
        addSubview(approveButton)
        
        let approveButtonInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 0.0)
        approveButton.autoPinEdgesToSuperviewEdges(with: approveButtonInsets, excludingEdge: ALEdge.right)
        approveButton.autoSetDimension(ALDimension.width, toSize: 44.0)
        
        
        textView = UITextView.newAutoLayout()
        textView.backgroundColor = UIColor.clear
        textView.tintColor = UIColor.primaryDarkTextColor()
        textView.isEditable = false
        textView.isSelectable = true
        textView.isScrollEnabled = false
        textView.delegate = self
        
        addSubview(textView)
        
        textView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: 10.0)
        textView.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        textView.autoPinEdge(ALEdge.left, to: ALEdge.right, of: approveButton)
        
        updateInterfaceWith(State: state)
    }
    
    // MARK: - Update
    
    func updateInterfaceWith(State state: ApprovalState) {
        switch state {
        case .disapproved:
            approveButton.setImage(UIImage(named: "checkBoxOff"), for: UIControlState())
        case .approved:
            approveButton.setImage(UIImage(named: "checkBoxOn"), for: UIControlState())
        }
    }
    
    // MARK: - Atributed Text
    
    func addInteractiveAttributedText(_ attributedText: NSMutableAttributedString, forScheme scheme: InteractiveTextScheme) {
        let currentAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        attributedText.addAttribute(NSLinkAttributeName,
                                    value: scheme.rawValue,
                                    range: NSRange(location: 0, length: attributedText.length))
        
        currentAttributedText.append(attributedText)
        
        textView.attributedText = currentAttributedText
    }
    
    func addNonInteractiveAttributedText(_ attributedText: NSMutableAttributedString) {
        let currentAttributedText = NSMutableAttributedString(attributedString: textView.attributedText)
        
        currentAttributedText.append(attributedText)
        
        textView.attributedText = currentAttributedText
    }
    
    // MARK: - Button Actions
    
    @objc fileprivate func approveButtonTapped(_ button: UIButton) {
        state = ApprovalState(rawValue: (((state?.rawValue)! + 1) % 2))
        
        updateInterfaceWith(State: state)
    }
}

// MARK: - InteractiveApprovalFieldDelegate

protocol InteractiveApprovalFieldDelegate: NSObjectProtocol {
    func interactiveApprovalField(_ field: InteractiveApprovalField, didTriggerScheme scheme: InteractiveTextScheme)
}

// MARK: - Button Actions

extension InteractiveApprovalField: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        guard let scheme = InteractiveTextScheme(rawValue: URL.absoluteString) else {
            return false
        }
        
        delegate.interactiveApprovalField(self, didTriggerScheme: scheme)
        
        return false
    }
}
