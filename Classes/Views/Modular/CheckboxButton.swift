//
//  CheckboxButton.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 22.02.2018.
//  Copyright © 2018 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

let CheckboxButtonDefaultDimension: CGFloat = 44.0

enum CheckboxState: Int {
    case `default` = 0
    case selected = 1
}

class CheckboxButton: UIView {
    weak var delegate: CheckboxButtonDelegate!
    
    fileprivate var checkboxButton: UIButton!
    
    var state: CheckboxState = CheckboxState.default
    
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
        checkboxButton = UIButton(type: UIButtonType.custom)
        checkboxButton.addTarget(self,
                                action: #selector(checkboxButtonTapped(_:)),
                                for: UIControlEvents.touchUpInside)
        
        addSubview(checkboxButton)
        
        checkboxButton.autoPinEdgesToSuperviewEdges()
        
        
        updateInterfaceWith(State: state)
    }
    
    // MARK: - Update
    
    func updateInterfaceWith(State state: CheckboxState) {
        switch state {
        case .default:
            checkboxButton.setImage(UIImage(named: "checkBoxOff"), for: UIControlState())
        case .selected:
            checkboxButton.setImage(UIImage(named: "checkBoxOn"), for: UIControlState())
        }
    }
    
    // MARK: - Button Actions
    
    @objc fileprivate func checkboxButtonTapped(_ button: UIButton) {
        state = CheckboxState(rawValue: (((state.rawValue) + 1) % 2))!
        
        updateInterfaceWith(State: state)
        
        delegate.checkboxButtonTapped(self)
    }
}

// MARK: - CheckboxButtonDelegate

protocol CheckboxButtonDelegate: NSObjectProtocol {
    func checkboxButtonTapped(_ button: CheckboxButton)
}

