YKPopupDialogView
========================
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/language-swift3-f48041.svg?style=flat"></a>
<a href="https://developer.apple.com/ios"><img src="https://img.shields.io/badge/platform-iOS%2010%2B-blue.svg?style=flat"></a>
[![Pod License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/yusufkildan/YKPopupDialogView/master/LICENSE)

## Preview

<img src="Screenshots/examples.gif" width="300">


## Installation

YKPopupDialogView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "YKPopupDialogView"
```

## Usage
1. Import the pod

```swift
import YKPopupDialogView
```

2. Create a YKPopupDialogView instance

```swift
let popupDialogView = YKPopupDialogView()
```

3. Set content

```swift
popupDialogView.setTitle("Title")
popupDialogView.setMessage("Message")        
popupDialogView.setImage(UIImage(named: "imageName"))
```

4. Add Buttons

```swift
let defaultButton = popupDialogView.addButton("Default", type: YKPopupDialogButtonType.default)        
defaultButton.addTarget(self, action: #selector(popupDialogButtonTapped(_:)), for: UIControlEvents.touchUpInside)

let cancelButton = popupDialogView.addButton("Cancel", type: YKPopupDialogButtonType.cancel)
cancelButton.addTarget(self, action: #selector(popupDialogButtonTapped(_:)), for: UIControlEvents.touchUpInside)
```

5. Display

```swift
popupDialogView.show()
```

### Animation options

- Fade-In
- Fade-Out
- Zoom-In
- Zoom-Out
- Slide-Bottom
- Slide-Top
- Slide-Left
- Slide-Right

## Customizing

You can access the properties below from YKPopupDialogView's instance before you call the ```show``` function
as you can see in the example and customize it any way you like and need.

#### Example
```swift
let popupDialogView: YKPopupDialogView = YKPopupDialogView()

popupDialogView.closeOnTap = false
popupDialogView.popupViewCornerRadius = 30
popupDialogView.buttonAlignment = .horizontal
popupDialogView.animationDuration = 0.2
popupDialogView.overlayViewBackgroundColor = UIColor(red: 117.0 / 255.0, green: 117.0 / 255.0, blue: 117.0 / 255.0, alpha: 0.8)
popupDialogView.imageSize = CGSize(width: 120.24, height: 104.04)
popupDialogView.setImage(UIImage(named: "geofencePermissionIcon")!)

popupDialogView.setTitle("Enable Geofencing", attributes: [NSFontAttributeName: UIFont(name: "Kanit-SemiBold", size: 17.0)!, NSForegroundColorAttributeName: UIColor(red: 33.0 / 255.0, green: 33.0 / 255.0, blue: 33.0 / 255.0, alpha: 1.0)])

popupDialogView.setMessage("Enable geofencing to get instant notifications for assignments nearby.", attributes: [NSFontAttributeName: UIFont(name: "Kanit-Regular", size: 16.0)!, NSForegroundColorAttributeName: UIColor(red: 117.0 / 255.0, green: 117.0 / 255.0, blue: 117.0 / 255.0, alpha: 1.0)])

let cancelButton = popupDialogView.addButton("Cancel", textColor: UIColor(red: 189.0 / 255.0, green: 189.0 / 255.0, blue: 189.0 / 255.0, alpha: 1.0), backgroundColor: UIColor.clear, font: UIFont(name: "Kanit-Medium", size: 17.0)!, cornerRadius: 0)
cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)

let enableButton = popupDialogView.addButton("Enable", textColor: UIColor(red: 245.0 / 255.0, green: 0.0 / 255.0, blue: 7.0 / 255.0, alpha: 0.8), backgroundColor: UIColor.clear, font: UIFont(name: "Kanit-SemiBold", size: 18.0)!, cornerRadius: 0)
enableButton.addTarget(self, action: #selector(enableButtonTapped(_:)), for: .touchUpInside)

popupDialogView.show(YKPopupDialogAnimationPattern.fadeInOut)
```

#### All properties
```swift
public var closeOnTap: Bool

public var popupViewInnerPadding: CGFloat

public var popupViewWidth: CGFloat

public var popupViewCornerRadius: CGFloat

public var popupViewBackgroundColor: UIColor

public var overlayViewBackgroundColor: UIColor

public var buttonHeight: CGFloat

public var buttonPadding: CGFloat

public var imageSize: CGSize

public var animationDuration: TimeInterval

public var buttonAlignment: YKPopupDialogView.YKPopupDialogButtonAlignment

public private(set) var isShown: Bool!
```

## Requirements

- iOS 10.0+
- Swift 3+

## Roadmap
- [x] Add custom animations
- [x] CocoaPods support
- [ ] Carthage support

## Author

Yusuf Kıldan, kildanyusuf@gmail.com

## License

YKPopupDialogView is available under the MIT license. See the LICENSE file for more info.
