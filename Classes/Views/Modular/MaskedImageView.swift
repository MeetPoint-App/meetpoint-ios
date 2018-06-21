//
//  MaskedImageView.swift
//  MeetPoint
//
//  Created by yusuf_kildan on 15/09/2017.
//  Copyright © 2017 yusuf_kildan. All rights reserved.
//

import UIKit
import PureLayout

class MaskedImageView: UIView {

    var imageView: UIImageView!
    
    fileprivate var gradientView = UIView()
    fileprivate var gradientLayer = MaskedImageView.generateGradientLayer()
    
    fileprivate static func generateGradientLayer() -> CAGradientLayer {
        let layer = CAGradientLayer()
        layer.locations = [0, 1]
        layer.colors = [
            UIColor.black.withAlphaComponent(0.7).cgColor,
            UIColor.black.withAlphaComponent(0.3).cgColor,
        ]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0.43)
        return layer
    }
    
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }

    override var contentMode: UIViewContentMode {
        didSet {
            imageView.contentMode = contentMode
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
        imageView = UIImageView.newAutoLayout()
        
        self.addSubview(imageView)
        
        imageView.autoPinEdgesToSuperviewEdges()

    
        gradientView = UIView.newAutoLayout()
        gradientView.layer.addSublayer(gradientLayer)
        
        imageView.addSubview(gradientView)
        
        gradientView.autoPinEdgesToSuperviewEdges()
    }
    
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
        // prevents animating the gradient view (it was "growing out" from the corner because it
        // starts with a frame of .zero)
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        gradientLayer.frame = CGRect(origin: .zero, size: gradientView.frame.size)
        CATransaction.commit()
    }
}
