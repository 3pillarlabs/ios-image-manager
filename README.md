[![Carthage compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/badge/CocoaPods-Compatible-4BC51D.svg?style=flat)](https://github.com/CocoaPods/CocoaPods)
[![Swift 4.0](https://img.shields.io/badge/Swift-Compatible-orange.svg)](https://swift.org)

# iOS image manager
Image Manager is a Swift based iOS module that provides basic image manipulation features. This module can be used as an alternative to the UIImagePickerController editor. It is available starting with iOS 8.

![](screenshots/demoImageManagerFramework.gif)

**Project Rationale**

The purpose of the framework is to provide a simple in app solution for basic image editing, by offering the following features:

*	Pan, zoom and rotation
*	Double tap to reset
*	Handles EXIF orientations
*	Crop and save in image library

**Still To do Features**

* Make cropping rectangle adjustable like in the Photos App
* Add possibility to customise cropping rectangle features - border colour, border width
* The minimum zoom level should be set so that the larger side of the image fits exactly inside the cropping rectangle, thus preventing the user to zoom out too much

**Known Issues**

* While zooming the rotate action can be easily triggered

## Installation


Available in iOS 8.0 and later.

### CocoaPods

- Run Terminal

- Navigate to project folder

- Use command:

```
pod init
```

- Add code to podfile

```
platform :ios, '8.0'

target 'YourProjectName' do
  use_frameworks!
    pod 'ImageManager'
end
```

- Run command:

```
pod install
```

Remember to open project using workspace

### Carthage

- Run Terminal

- Navigate to project folder

- Use command in terminal:
```
touch cartfile
```

- Add code to Cartfile:

```
github "3pillarlabs/ios-image-manager"
```

- Run carthage by using command:

```
carthage update
```
- In order to link your app with the framework, you have to add the ImageManager in 'Embedded Binaries' list from 'General' section on application's target from Carthage/Build/iOS in project folder.

## Usage
1. Import Image Manager Framework
2. Create an instance of ImageManagerViewController class.
3. Set the 'displayedImage' property with the image we wand to edit.
4. Present the Image Manager view controller in a way that it makes sense in your project.
5. If you want to be notified when the editing process has ended or if it was canceled, you can implement the following Image Manager delegate methods:

```swift
func imageManagerController(controller:ImageManagerViewController, didFinishEditingImage image: UIImage)

func imageManagerControllerDidCancel(controller:ImageManagerViewController)
```

```swift
let imageName = "photo"
let image = UIImage(named: imageName)

if let aImage =  image {
  let imageManagerVc = ImageManagerViewController()
  imageManagerVc.displayedImage = image
  // present the image manager view controller in the way that it makes sense in your application
}
```  

## License

iOS image manager  is released under MIT license. See [LICENSE](LICENSE) for details.  

## About this project

[![3Pillar Global](https://www.3pillarglobal.com/wp-content/themes/base/library/images/logo_3pg.png)](http://www.3pillarglobal.com/)

**iOS image manager** is developed and maintained by [3Pillar Global](http://www.3pillarglobal.com/).
