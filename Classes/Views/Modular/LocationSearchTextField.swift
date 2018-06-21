//
//  LocationSearchTextField.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 26/11/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let LocationSearchTextFieldDefaultHeight: CGFloat = 44.0

class LocationSearchTextField: UIView {
    weak var delegate: LocationSearchTextFieldDelegate!
    
    fileprivate var textField: UITextField!
    fileprivate var bottomShadow: UIImageView!
    
    fileprivate let DefaultInset: CGFloat = 8.0
    
    var text: String! {
        get {
            return textField.text
        } set (newValue) {
            textField.text = newValue
        }
    }
    
    var shouldShowShadowOnBottom: Bool! = false {
        didSet {
            if shouldShowShadowOnBottom == true {
                if let shadow = bottomShadow {
                    shadow.isHidden = false
                    
                    return
                }
                
                bottomShadow = UIImageView.newAutoLayout()
                bottomShadow.image = UIImage(named: "gradientBackgroundBlackTopToBottomSmall")
                
                addSubview(bottomShadow)
                
                bottomShadow.autoPinEdge(ALEdge.top, to: ALEdge.bottom, of: self)
                bottomShadow.autoPinEdge(toSuperviewEdge: ALEdge.left)
                bottomShadow.autoPinEdge(toSuperviewEdge: ALEdge.right)
                bottomShadow.autoSetDimension(ALDimension.height, toSize: 5.0)
            } else {
                if let shadow = bottomShadow {
                    shadow.isHidden = false
                }
            }
        }
    }
    
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
        self.backgroundColor = UIColor.primaryBackgroundColor()
        
        let componentsHolderView = UIView.newAutoLayout()
        componentsHolderView.backgroundColor = UIColor.dropDownButtonBackgroundColor()
        componentsHolderView.layer.cornerRadius = 4.0
        componentsHolderView.layer.masksToBounds = true
        
        self.addSubview(componentsHolderView)
        
        componentsHolderView.autoSetDimension(ALDimension.height, toSize: 30.0)
        componentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.left, withInset: DefaultInset)
        componentsHolderView.autoPinEdge(toSuperviewEdge: ALEdge.right, withInset: DefaultInset)
        componentsHolderView.autoAlignAxis(toSuperviewAxis: ALAxis.horizontal)
        
        
        let searchIcon = UIImageView.newAutoLayout()
        searchIcon.image = UIImage(named: "iconLocationSearch")
        searchIcon.contentMode = UIViewContentMode.scaleAspectFit
        
        componentsHolderView.addSubview(searchIcon)
        
        searchIcon.autoPinEdges(toSuperviewMarginsExcludingEdge: ALEdge.right)
        searchIcon.autoSetDimension(ALDimension.width, toSize: 30.0)
        
        
        textField = UITextField.newAutoLayout()
        textField.delegate = self
        textField.font = UIFont.montserratRegularFont(withSize: 14.0)
        textField.textColor = UIColor.primaryDarkTextColor()
        textField.clearsOnBeginEditing = true
        textField.placeholder = "Search..."
        textField.tintColor = UIColor.segmentedControlTintColor()
        textField.returnKeyType = UIReturnKeyType.search
        textField.clearButtonMode = UITextFieldViewMode.always
        textField.addTarget(self, action: #selector(LocationSearchTextField.textFieldEditingChanged), for: UIControlEvents.editingChanged)
        
        componentsHolderView.addSubview(textField)
        
        textField.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: ALEdge.left)
        textField.autoPinEdge(ALEdge.left, to: ALEdge.right, of: searchIcon)
    }
    
    // MARK: - Actions
    
    func textFieldEditingChanged() {
        delegate.locationSearchTextFieldEditingChanged(self)
    }
}

// MARK: - UITextFieldDelegate

extension LocationSearchTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return delegate.locationSearchTextFieldShouldReturn(self)
    }
}

// MARK: - LocationSearchTextFieldDelegate

protocol LocationSearchTextFieldDelegate: NSObjectProtocol {
    func locationSearchTextFieldEditingChanged(_ textField: LocationSearchTextField)
    func locationSearchTextFieldShouldReturn(_ textField: LocationSearchTextField) -> Bool
}
