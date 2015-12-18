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

#Installation

Image manager framework works with iOS 8.0 or later. Make sure that the framework is added to 'Embedded Binaries' list. After this, you just import the framework in the file where you will use it.

#Usage
1. Import Image Manager Framework
2. Create an instance of ImageManagerViewController class.
3. Set the 'displayedImage' property with the image we wand to edit.
4. Present the Image Manager view controller in a way that it makes sense in your project. 
5. If you want to be notified when the editing process has ended or if it was canceled, you can implement the following Image Manager delegate methods:

*    func imageManagerController(controller:ImageManagerViewController, didFinishEditingImage image: UIImage)

*    func imageManagerControllerDidCancel(controller:ImageManagerViewController) 

let imageName = "photo"
let image = UIImage(named: imageName)

if let aImage =  image {
let imageManagerVc = ImageManagerViewController()
imageManagerVc.displayedImage = image
// present the image manager view controller in the way that it makes sense in your application
}

In the demo project you're able to see how the framework is used.        

## License

iOS image manager  is released under MIT license. See [LICENSE](LICENSE) for details.  

## About this project

![3Pillar Global] (http://www.3pillarglobal.com/wp-content/themes/base/library/images/logo_3pg.png)

**iOS image manager** is developed and maintained by [3Pillar Global](http://www.3pillarglobal.com/).


