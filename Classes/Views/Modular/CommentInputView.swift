//
//  CommentInputView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 24/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//


import UIKit
import PureLayout

let CommentInputViewDefaultHeight: CGFloat = 50.0

fileprivate let DefaultInset: CGFloat = 8.0

class CommentInputView: UIView {
    weak var delegate: CommentInputViewDelegate!
    
    var textField: UITextField!
    fileprivate var actionButton: UIButton!
    
    fileprivate var topShadow: UIImageView!
    
    var text: String! {
        get {
            return textField.text!.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        }
        
        set(newValue) {
            if newValue == "" {
                self.isEnabled = false
            }
            
            textField.text = newValue
        }
    }
    
    var shouldShowShadow: Bool! = false {
        didSet {
            if shouldShowShadow == true {
                if let view = topShadow {
                    view.isHidden = false
                    
                    return
                }
                
                topShadow = UIImageView.newAutoLayout()
                topShadow.image = UIImage(named: "gradientBackgroundBlackBottomToTopSmall")
                
                addSubview(topShadow)
                
                topShadow.autoPinEdge(ALEdge.bottom, to: ALEdge.top, of: self)
                topShadow.autoPinEdge(toSuperviewEdge: ALEdge.left)
                topShadow.autoPinEdge(toSuperviewEdge: ALEdge.right)
                topShadow.autoSetDimension(ALDimension.height, toSize: 5.0)
            }else {
                if let view = topShadow {
                    view.isHidden = true
                }
            }
        }
    }
    
    var placeholder: String! {
        didSet {
            textField.placeholder = placeholder
        }
    }
    
    var isEnabled: Bool! {
        didSet {
            actionButton.isEnabled = isEnabled
            actionButton.alpha = isEnabled == true ? 1 : 0.5
        }
    }
    
    var textColor: UIColor! {
        didSet {
            if let textField = textField {
                textField.textColor = textColor!
            }
        }
    }
    
    var font: UIFont! {
        didSet {
            if let textField = textField {
                textField.font = font
            }
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        actionButton = UIButton(type: UIButtonType.system)
        actionButton.setTitle("Send", for: UIControlState.normal)
        actionButton.contentHorizontalAlignment = UIControlContentHorizontalAlignment.center
        actionButton.backgroundColor = UIColor.secondaryBackgroundColor()
        actionButton.layer.cornerRadius = 17.0
        actionButton.layer.masksToBounds = false
        actionButton.titleLabel?.font = UIFont.montserratSemiboldFont(withSize: 14.0)
        actionButton.setTitleColor(UIColor.secondaryLightTextColor(), for: UIControlState.normal)
        actionButton.addTarget(self, action: #selector(CommentInputView.didTapActionButton(_:)), for: UIControlEvents.touchUpInside)
        
        addSubview(actionButton)
        
        let inset = UIEdgeInsetsMake(DefaultInset, 0.0, DefaultInset, DefaultInset)
        actionButton.autoPinEdgesToSuperviewEdges(with: inset, excludingEdge: ALEdge.left)
        actionButton.autoSetDimension(ALDimension.width, toSize: 70.0)
        
        
        textField = UITextField.newAutoLayout()
        textField.returnKeyType = UIReturnKeyType.done
        textField.delegate = self
        textField.addTarget(self, action: #selector(CommentInputView.textFieldEditingChanged), for: UIControlEvents.editingChanged)
        
        addSubview(textField)
        
        textField.autoPinEdge(ALEdge.left, to: ALEdge.left, of: self, withOffset: DefaultInset)
        textField.autoPinEdge(ALEdge.right, to: ALEdge.left, of: actionButton, withOffset: -DefaultInset)
        textField.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapBackground(_:))))
    }
    
    // MARK: - Actions
    
    func didTapActionButton(_ button: UIButton) {
        delegate.commentInputViewDidTapActionButton(self)
    }
    
    func textFieldEditingChanged() {
        delegate.commentInputViewEditingChanged(self)
    }
    
    func didTapBackground(_ recognizer: UIGestureRecognizer) {
        delegate.commentInputViewDidTapBackground(self)
    }
}

// MARK: - UITextFieldDelegate

extension CommentInputView: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate.responds(to: #selector(CommentInputViewDelegate.commentInputViewDidEndEditing(_:))) {
            delegate.commentInputViewDidEndEditing!(self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate.commentInputViewShouldReturn(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if delegate.responds(to: #selector(CommentInputViewDelegate.commentInputViewDidBeginEditing(_:))) {
            delegate.commentInputViewDidBeginEditing!(self)
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return  delegate.commentInputView(self, shouldChangeCharactersIn: range, replacementString: string)
    }
}

// MARK: - CommentInputViewDelegate

@objc protocol CommentInputViewDelegate: NSObjectProtocol {
    @objc optional func commentInputViewDidEndEditing(_ view: CommentInputView)
    func commentInputViewShouldReturn(_ view: CommentInputView) -> Bool
    func commentInputViewDidTapActionButton(_ view: CommentInputView)
    @objc optional func commentInputViewDidBeginEditing(_ view: CommentInputView)
    func commentInputView(_ view: CommentInputView, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func commentInputViewEditingChanged(_ view: CommentInputView)
    func commentInputViewDidTapBackground(_ view: CommentInputView)
}

