//
//  CustomTextField.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let CustomTextFieldDefaultHeight: CGFloat = 48.0

class CustomTextField: UITextField {
    weak var customTextFieldDelegate: CustomTextFieldDelegate?
    
    fileprivate var bottomLineView: UIView!
    fileprivate var counterLabel: UILabel!
    
    fileprivate let CounterLaberDimensions = CGSize(width: 40.0, height: 25.0)
    
    var maximumLength: Int? {
        didSet {
            rightView = counterLabel
            rightViewMode = UITextFieldViewMode.whileEditing
            
            guard let maximumLength = maximumLength else {
                return
            }
            
            if let text = text {
                counterLabel.text = "\(text.utf16.count)/\(maximumLength)"
            } else {
                counterLabel.text = "0/\(maximumLength)"
            }
        }
    }
    
    var activeColor: UIColor! = UIColor.textFieldActiveColor(){
        didSet {
            bottomLineView.backgroundColor = activeColor
            self.tintColor = activeColor
        }
    }
    
    var inactiveColor: UIColor! = UIColor.textFieldInactiveColor() {
        didSet {
            bottomLineView.backgroundColor = inactiveColor
            self.tintColor = inactiveColor
        }
    }
    
    var counterText: String! {
        didSet {
            guard let maximumLength = self.maximumLength else {
                return
            }
            
            print(counterText)
            counterLabel.text = "\(counterText!)/\(maximumLength)"
        }
    }
    
    var counterLabelFont: UIFont! = UIFont.montserratMediumFont(withSize: 14.0) {
        didSet {
            counterLabel.font = counterLabelFont
        }
    }
    
    var counterLabelTextColor: UIColor! = UIColor.primaryLightTextColor() {
        didSet {
            counterLabel.textColor = counterLabelTextColor
        }
    }
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.font = UIFont.montserratRegularFont(withSize: 16.0)
        self.textColor = UIColor.primaryDarkTextColor()
        self.keyboardAppearance = UIKeyboardAppearance.dark
        
        self.delegate = self
        self.tintColor = inactiveColor
        
        bottomLineView = UIView.newAutoLayout()
        bottomLineView.backgroundColor = inactiveColor
        
        self.addSubview(bottomLineView)
        
        bottomLineView.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero,
                                                    excludingEdge: ALEdge.top)
        bottomLineView.autoSetDimension(ALDimension.height, toSize: 1.0)
        
        
        counterLabel = UILabel()
        counterLabel.textColor = counterLabelTextColor
        counterLabel.font = counterLabelFont
    }
    
    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        super.rightViewRect(forBounds: bounds)
        if maximumLength != nil {
            return CGRect(x: frame.width - CounterLaberDimensions.width - 5.0,
                          y: (CustomTextFieldDefaultHeight - CounterLaberDimensions.height) / 2.0,
                          width: CounterLaberDimensions.width,
                          height: CounterLaberDimensions.height)
        } else {
            return CGRect()
        }
    }
}

// MARK: - UITextFieldDelegate

extension CustomTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.bottomLineView.backgroundColor = activeColor
        self.tintColor = activeColor
        
        guard let inlineDelegate = customTextFieldDelegate else {
            return
        }
        
        if inlineDelegate.responds(to: #selector(CustomTextFieldDelegate.customTextFieldDidBeginEditing(_:))) {
            inlineDelegate.customTextFieldDidBeginEditing!(self)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.bottomLineView.backgroundColor = inactiveColor
        self.tintColor = inactiveColor
        
        guard let inlineDelegate = customTextFieldDelegate else {
            return
        }
        
        if inlineDelegate.responds(to: #selector(CustomTextFieldDelegate.customTextFieldDidEndEditing(_:))) {
            inlineDelegate.customTextFieldDidEndEditing!(self)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let inlineDelegate = customTextFieldDelegate else {
            return false
        }
        
        if inlineDelegate.responds(to: #selector(CustomTextFieldDelegate.customTextFieldShouldReturn(_:))) {
            return inlineDelegate.customTextFieldShouldReturn!(self)
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard let inlineDelegate = customTextFieldDelegate else {
            return false
        }
        
        if inlineDelegate.responds(to: #selector(CustomTextFieldDelegate.customTextFieldShouldBeginEditing(_:))) {
            return inlineDelegate.customTextFieldShouldBeginEditing!(self)
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let maximumLength = self.maximumLength else {
            return true
        }
        
        guard let text = textField.text , maximumLength != 0 else {
            return true
        }
        
        let currentCount = text.utf16.count + string.utf16.count - range.length
        
        if currentCount >= 40 {
            counterLabel.textColor = UIColor.customRedColor()
        } else {
            counterLabel.textColor = UIColor.primaryLightTextColor()
        }
        
        if currentCount <= maximumLength {
            counterLabel.text = "\(currentCount)/\(maximumLength)"
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.counterLabel.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                
            }, completion: { (finish) in
                UIView.animate(withDuration: 0.1, animations: {
                    self.counterLabel.transform = CGAffineTransform.identity
                })
            })
        }
        
        return currentCount <= maximumLength
    }
}

// MARK: - CustomTextFieldDelegate

@objc protocol CustomTextFieldDelegate: NSObjectProtocol {
    @objc optional func customTextFieldDidBeginEditing(_ textField: CustomTextField)
    @objc optional func customTextFieldDidEndEditing(_ textField: CustomTextField)
    @objc optional func customTextFieldShouldReturn(_ textField: CustomTextField) -> Bool
    @objc optional func customTextFieldShouldBeginEditing(_ textField: CustomTextField) -> Bool
}
