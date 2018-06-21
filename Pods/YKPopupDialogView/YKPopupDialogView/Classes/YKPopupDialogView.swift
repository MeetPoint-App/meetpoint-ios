//
//  YKPopupDialogView.swift
//  YKPopupDialogView
//
//  Created by yusuf_kildan on 20/08/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit

// MARK: - Enums

public enum YKPopupDialogAnimationPattern {
    case fadeInOut
    case zoomInOut
    case slideBottomBottom
    case slideBottomTop
    case slideLeftLeft
    case slideLeftRight
    case slideTopTop
    case slideTopBottom
    case slideRightRight
    case slideRightLeft
}

public enum YKPopupDialogButtonAlignment {
    case horizontal
    case vertical
}

public enum YKPopupDialogButtonType {
    case `default`
    case cancel
    
    var textColor: UIColor {
        switch self {
        case .default:
            return UIColor.white
        case .cancel:
            return UIColor(red:0.47, green:0.50, blue:0.56, alpha:1.0)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .default:
            return  UIColor(red:0.31, green:0.57, blue:0.87, alpha:1.0)
        case .cancel:
            return UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.0)
        }
    }
    
    var font: UIFont {
        return UIFont.boldSystemFont(ofSize: 15.0)
    }
}

// MARK: - YKPopupDialogButton

public class YKPopupDialogButton: UIButton {
    
    public var popupDialogView: YKPopupDialogView!
    
    // MARK: - Constructors
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {}
}

// MARK: - YKPopupDialogOverlayView

public class YKPopupDialogOverlayView: UIView {
    
    // MARK: - Constructors
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    fileprivate func commonInit() {}
}

// MARK: - YKPopupDialogView

public class YKPopupDialogView: UIView {
    
    // MARK: - Configuration
    
    public var closeOnTap: Bool = true
    
    public var popupViewInnerPadding: CGFloat = 12.0
    public var popupViewWidth: CGFloat = 260.0
    
    public var popupViewCornerRadius: CGFloat = 4.0 {
        didSet {
            self.popupView.layer.cornerRadius = popupViewCornerRadius
        }
    }
    
    public var popupViewBackgroundColor: UIColor = UIColor.white {
        didSet {
            self.popupView.backgroundColor = popupViewBackgroundColor
        }
    }
    
    public var overlayViewBackgroundColor: UIColor = UIColor.black.withAlphaComponent(0.4) {
        didSet {
            self.overlayView.backgroundColor = overlayViewBackgroundColor
        }
    }
    
    public var buttonHeight: CGFloat = 40.0
    public var buttonPadding: CGFloat = 8.0
    
    public var imageSize: CGSize = CGSize(width: 120.0, height: 120.0)
    
    public var animationDuration: TimeInterval = 0.33
    
    public var buttonAlignment: YKPopupDialogButtonAlignment = YKPopupDialogButtonAlignment.vertical
    
    // MARK: - Private Variables
    
    fileprivate var popupView: UIView = UIView()
    fileprivate var overlayView: YKPopupDialogOverlayView = YKPopupDialogOverlayView()
    
    fileprivate var imageView: UIImageView?
    
    fileprivate var title: String?
    fileprivate var titleAttributes: [String: AnyObject]?
    fileprivate var titleLabel: UILabel?
    
    fileprivate var message: String?
    fileprivate var messageAttributes: [String: AnyObject]?
    fileprivate var messageLabel: UILabel?
    
    fileprivate var buttons: [YKPopupDialogButton] = [YKPopupDialogButton]()
    
    fileprivate var animationPattern: YKPopupDialogAnimationPattern!
    
    // MARK: - Public Variables
    
    public private(set) var isShown: Bool!
    
    // MARK: - Constructors
    
    convenience init(buttonAlignment: YKPopupDialogButtonAlignment) {
        self.init(frame:CGRect.zero)
        
        self.buttonAlignment = buttonAlignment
        
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    fileprivate func commonInit() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.overlayView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayView.backgroundColor = overlayViewBackgroundColor
        
        self.addSubview(overlayView)
        
        overlayView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                action: #selector(didTapOverlayView(_:))))
        
        self.popupView.layer.cornerRadius = popupViewCornerRadius
        self.popupView.backgroundColor = popupViewBackgroundColor
        self.popupView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.popupView)
        
        self.layoutSubviews()
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        overlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        overlayView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    // MARK: - Show
    
    public func show(_ animationPattern: YKPopupDialogAnimationPattern = YKPopupDialogAnimationPattern.fadeInOut) {
        overlayView.alpha = 0
        popupView.alpha = 0
        
        overlayView.isHidden = true
        popupView.isHidden = true
        
        self.removeFromSuperview()
        
        isShown = true
        
        self.animationPattern = animationPattern
        
        let appDelegate = UIApplication.shared.delegate
        
        var parentViewController = appDelegate?.window??.rootViewController
        
        var modalViewController = parentViewController?.presentedViewController
        
        while modalViewController != nil {
            parentViewController = modalViewController
            
            modalViewController = parentViewController?.presentedViewController
        }
        
        parentViewController?.view.addSubview(self)
        
        self.leadingAnchor.constraint(equalTo: self.superview!.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: self.superview!.trailingAnchor).isActive = true
        self.topAnchor.constraint(equalTo: self.superview!.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: self.superview!.bottomAnchor).isActive = true
        
        var lastItem: UIView?
        
        self.createLabelsAndImageView(&lastItem)
        self.createButtons(&lastItem)
        
        popupView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        popupView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        popupView.widthAnchor.constraint(equalToConstant: self.popupViewWidth).isActive = true
        
        if lastItem != nil {
            popupView.bottomAnchor.constraint(equalTo: lastItem!.bottomAnchor, constant: popupViewInnerPadding).isActive = true
        } else {
            popupView.heightAnchor.constraint(equalToConstant: 240.0).isActive = true
        }
        
        self.popupView.isHidden = false
        self.overlayView.isHidden = false
        
        self.layoutIfNeeded()
        
        switch animationPattern {
        case .slideBottomBottom, .slideBottomTop,
             .slideLeftLeft, .slideLeftRight, .slideTopTop, .slideTopBottom, .slideRightRight, .slideRightLeft:
            
            slideInAnimation(animationPattern)
        case .zoomInOut:
            zoomInAnimation()
        default:
            fadeInAnimation()
        }
    }
    
    fileprivate func slideInAnimation(_ animationPattern: YKPopupDialogAnimationPattern) {
        let sourceSize: CGSize = self.bounds.size
        let popupViewSize: CGSize = popupView.bounds.size
        var popupViewStartRect: CGRect
        
        switch animationPattern {
        case .slideBottomTop, .slideBottomBottom:
            popupViewStartRect = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0, y: sourceSize.height , width: popupViewSize.width, height: popupViewSize.height)
        case .slideLeftLeft, .slideLeftRight:
            popupViewStartRect = CGRect(x: -sourceSize.width, y: (sourceSize.height - popupViewSize.height) / 2.0, width: popupViewSize.width, height: popupViewSize.height)
        case .slideTopTop, .slideTopBottom:
            popupViewStartRect = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0, y: -sourceSize.height, width: popupViewSize.width, height: popupViewSize.height)
        default:
            popupViewStartRect = CGRect(x: sourceSize.width, y: (sourceSize.height - popupViewSize.height) / 2.0, width: popupViewSize.width, height: popupViewSize.height)
        }
        
        let popupViewEndRect:CGRect = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0, y: (sourceSize.height - popupViewSize.height) / 2.0, width: popupViewSize.width, height: popupViewSize.height)
        
        popupView.frame = popupViewStartRect
        popupView.alpha = 1.0
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.overlayView.alpha = 1.0
            
            self.popupView.frame = popupViewEndRect
        }, completion: { (finished) -> Void in
            
        })
    }
    
    fileprivate func zoomInAnimation() {
        let sourceSize: CGSize = self.bounds.size
        let popupViewSize: CGSize = self.popupView.bounds.size
        popupView.frame = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0,
                                 y: (sourceSize.height - popupViewSize.height) / 2.0,
                                 width: popupViewSize.width,
                                 height: popupViewSize.height)
        popupView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        popupView.alpha = 0.0
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.overlayView.alpha = 1.0
            self.popupView.transform = CGAffineTransform.identity
            self.popupView.alpha = 1.0
        }) { (finished) -> Void in
            
        }
    }
    
    fileprivate func fadeInAnimation() {
        let sourceSize: CGSize = self.bounds.size
        let popupViewSize: CGSize = popupView.bounds.size
        
        self.popupView.frame = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0,
                                      y: (sourceSize.height - popupViewSize.height) / 2.0,
                                      width: popupViewSize.width,
                                      height: popupViewSize.height)
        popupView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        popupView.alpha = 0.0
        
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.overlayView.alpha = 1.0
            self.popupView.transform = CGAffineTransform.identity
            self.popupView.alpha = 1.0
        }, completion: { (finished) -> Void in
            
        })
    }
    
    // MARK: - Hide
    
    public func hide(_ animationPattern: YKPopupDialogAnimationPattern) {
        isShown = false
        
        switch animationPattern {
        case .slideBottomBottom, .slideBottomTop, .slideLeftLeft, .slideLeftRight, .slideTopTop, .slideTopBottom, .slideRightRight, .slideRightLeft:
            
            slideOutAnimation(animationPattern)
        case .zoomInOut:
            zoomOutAnimation()
        default:
            fadeOutAnimation()
        }
    }
    
    public func hide() {
        self.hide(self.animationPattern)
    }
    
    fileprivate func slideOutAnimation(_ animationPattern: YKPopupDialogAnimationPattern){
        let sourceSize: CGSize = self.bounds.size
        let popupViewSize: CGSize = self.popupView.bounds.size
        var popupViewEndRect: CGRect
        
        switch animationPattern {
        case .slideBottomTop, .slideTopTop:
            popupViewEndRect = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0, y: -popupViewSize.height, width: popupViewSize.width, height: popupViewSize.height)
        case .slideBottomBottom, .slideTopBottom:
            popupViewEndRect = CGRect(x: (sourceSize.width - popupViewSize.width) / 2.0, y: sourceSize.height, width: popupViewSize.width, height: popupViewSize.height)
        case .slideLeftRight, .slideRightRight:
            popupViewEndRect = CGRect(x: sourceSize.width, y: self.popupView.frame.origin.y, width: popupViewSize.width, height: popupViewSize.height)
        default:
            popupViewEndRect = CGRect(x: -popupViewSize.width, y: self.popupView.frame.origin.y, width: popupViewSize.width, height: popupViewSize.height)
        }
        
        UIView.animate(withDuration: self.animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            
            self.popupView.frame = popupViewEndRect
            
        }) { (finished) -> Void in
            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
                self.overlayView.alpha = 0.0
                self.popupView.alpha = 0.0
            }) { (finished) -> Void in
                self.overlayView.isHidden = true
                self.popupView.isHidden = true
                
                self.removeFromSuperview()
            }
        }
    }
    
    fileprivate func zoomOutAnimation() {
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions.curveEaseIn, animations: { () -> Void in
            self.overlayView.alpha = 0.0
            self.popupView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            self.popupView.alpha = 0.0
        }) { (finished) -> Void in
            self.overlayView.isHidden = true
            self.popupView.isHidden = true
            
            self.removeFromSuperview()
        }
    }
    
    fileprivate func fadeOutAnimation() {
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.overlayView.alpha = 0.0
            self.popupView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.popupView.alpha = 0.0
        }, completion: { (finished) -> Void in
            self.overlayView.isHidden = true
            self.popupView.isHidden = true
            
            self.removeFromSuperview()
        })
    }
    
    // MARK: - Create UI
    
    fileprivate func createLabelsAndImageView(_ lastItem: inout UIView?) {
        
        if titleLabel != nil {
            self.titleLabel = self.label(title!, textAttributes: titleAttributes, bold: true)
            titleLabel?.translatesAutoresizingMaskIntoConstraints = false
            
            self.popupView.addSubview(titleLabel!)
            
            titleLabel?.preferredMaxLayoutWidth = (self.popupViewWidth - (2 * self.popupViewInnerPadding))
            
            
            titleLabel?.topAnchor.constraint(equalTo: popupView.topAnchor, constant: popupViewInnerPadding).isActive = true
            titleLabel?.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: popupViewInnerPadding).isActive = true
            titleLabel?.rightAnchor.constraint(equalTo: popupView.rightAnchor, constant: -popupViewInnerPadding).isActive = true
            
            if let imageView = imageView {
                imageView.translatesAutoresizingMaskIntoConstraints = false
                
                popupView.addSubview(imageView)
                
                imageView.widthAnchor.constraint(equalToConstant: imageSize.width).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: imageSize.height).isActive = true
                imageView.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: popupViewInnerPadding).isActive = true
                imageView.centerXAnchor.constraint(equalTo: popupView.centerXAnchor).isActive = true
                
                lastItem = imageView
            }else {
                lastItem = titleLabel
            }
        }
        
        if self.messageLabel != nil {
            messageLabel?.translatesAutoresizingMaskIntoConstraints = false
            
            self.popupView.addSubview(messageLabel!)
            
            messageLabel?.preferredMaxLayoutWidth = (self.popupViewWidth - (2 * self.popupViewInnerPadding))
            
            if let imageView = imageView {
                messageLabel?.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: popupViewInnerPadding).isActive = true
            }else {
                messageLabel?.topAnchor.constraint(equalTo: titleLabel!.bottomAnchor, constant: popupViewInnerPadding).isActive = true
            }
            
            messageLabel?.leftAnchor.constraint(equalTo: popupView.leftAnchor, constant: popupViewInnerPadding).isActive = true
            messageLabel?.rightAnchor.constraint(equalTo: popupView.rightAnchor, constant: -popupViewInnerPadding).isActive = true
            
            lastItem = messageLabel
        }
    }
    
    fileprivate func createButtons(_ lastItem: inout UIView?) {
        if buttons.count > 0 {
            var previousButton: YKPopupDialogButton?
            
            for button in buttons {
                button.translatesAutoresizingMaskIntoConstraints = false
                
                self.popupView.addSubview(button)
                
                switch buttonAlignment {
                case.vertical:
                    if previousButton == nil {
                        if let messageLabel = messageLabel {
                            button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: popupViewInnerPadding).isActive = true
                        }else {
                            if let titleLabel = titleLabel {
                                button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: popupViewInnerPadding).isActive = true
                            }else {
                                button.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: popupViewInnerPadding).isActive = true
                            }
                        }
                    }else {
                        button.topAnchor.constraint(equalTo: previousButton!.bottomAnchor, constant: buttonPadding).isActive = true
                    }
                    
                    button.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: popupViewInnerPadding).isActive = true
                    button.rightAnchor.constraint(equalTo: self.popupView.rightAnchor, constant: -popupViewInnerPadding).isActive = true
                    button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                case .horizontal:
                    if let messageLabel = messageLabel {
                        button.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: popupViewInnerPadding).isActive = true
                    }else {
                        if let titleLabel = titleLabel {
                            button.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: popupViewInnerPadding).isActive = true
                        }else {
                            button.topAnchor.constraint(equalTo: self.popupView.topAnchor, constant: popupViewInnerPadding).isActive = true
                        }
                    }
                    
                    if previousButton == nil {
                        button.leftAnchor.constraint(equalTo: self.popupView.leftAnchor, constant: popupViewInnerPadding).isActive = true
                    }else {
                        button.leftAnchor.constraint(equalTo: previousButton!.rightAnchor, constant: buttonPadding).isActive = true
                    }
                    
                    button.widthAnchor.constraint(equalToConstant: (popupViewWidth - (2 * popupViewInnerPadding) - (CGFloat(buttons.count - 1) * buttonPadding)) / CGFloat(buttons.count)).isActive = true
                    button.heightAnchor.constraint(equalToConstant: buttonHeight).isActive = true
                }
                
                previousButton = button
                lastItem = button
            }
        }
    }
    
    fileprivate func label(_ text: String, textAttributes: [String: AnyObject]?, bold: Bool = false) -> UILabel {
        let label: UILabel = UILabel()
        
        var attributes: [String: AnyObject]? = textAttributes
        
        label.backgroundColor = UIColor.clear
        label.textAlignment = .center
        label.numberOfLines = 0
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: text)
        if attributes == nil {
            attributes = [String: AnyObject]()
        }
        if attributes![NSFontAttributeName] == nil {
            attributes![NSFontAttributeName] = (bold ? UIFont.boldSystemFont(ofSize: 18) : UIFont.systemFont(ofSize: 14))
        }
        if attributes![NSForegroundColorAttributeName] == nil {
            attributes![NSForegroundColorAttributeName] = UIColor.darkGray
        }
        if attributes![NSBackgroundColorAttributeName] == nil {
            attributes![NSBackgroundColorAttributeName] = UIColor.clear
        }
        attributedString.addAttributes(attributes!, range: NSRange.init(location: 0, length: text.count))
        
        label.attributedText = attributedString
        
        return label
    }
    
    // MARK: - Configure Views
    
    @discardableResult public func setImage(_ image: UIImage) -> UIImageView {
        imageView = UIImageView()
        imageView?.image = image
        imageView?.contentMode = UIViewContentMode.scaleAspectFit
        imageView?.clipsToBounds = true
        
        return imageView!
    }
    
    @discardableResult public func setTitle(_ title: String, attributes: [String: AnyObject] = [String: AnyObject]()) -> UILabel {
        self.title = title
        self.titleAttributes = attributes
        
        titleLabel = self.label(self.title!, textAttributes: self.titleAttributes, bold: true)
        
        return titleLabel!
    }
    
    @discardableResult public func setMessage(_ message: String, attributes: [String: AnyObject] = [String: AnyObject]()) -> UILabel {
        self.message = message
        self.messageAttributes = attributes
        
        messageLabel = self.label(self.message!, textAttributes: self.messageAttributes, bold: false)
        
        return messageLabel!
    }
    
    @discardableResult public func setMessage(_ attributedString: NSMutableAttributedString) -> UILabel {
        self.message = attributedString.string
        
        messageLabel = UILabel()
        messageLabel!.backgroundColor = UIColor.clear
        messageLabel!.textAlignment = .center
        messageLabel!.numberOfLines = 0
        messageLabel!.attributedText = attributedString
        
        return messageLabel!
    }
    
    public func addButton(_ button: YKPopupDialogButton) {
        self.buttons.append(button)
        self.popupView.addSubview(button)
    }
    
    public func addButton(_ title: String, textColor: UIColor = UIColor.white, backgroundColor: UIColor = UIColor.gray, font: UIFont = UIFont.boldSystemFont(ofSize: 14), cornerRadius: CGFloat = 4) -> YKPopupDialogButton {
        let button = YKPopupDialogButton(type: UIButtonType.system)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(textColor, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = cornerRadius
        button.clipsToBounds = true
        button.titleLabel?.font = font
        
        button.popupDialogView = self
        
        self.addButton(button)
        
        return button
    }
    
    public func addButton(_ title: String, type: YKPopupDialogButtonType) -> YKPopupDialogButton {
        
        return self.addButton(title, textColor: type.textColor, backgroundColor: type.backgroundColor, font: type.font)
    }
    
    // MARK: - Recognizers
    
    @objc fileprivate func didTapOverlayView(_ recognizer: UITapGestureRecognizer) {
        if closeOnTap == true {
            self.hide(self.animationPattern)
        }
    }
}
