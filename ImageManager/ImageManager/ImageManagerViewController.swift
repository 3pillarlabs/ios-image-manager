//
//  ImageManagerViewController.swift
//  ImageManager
//


import UIKit
import Photos

protocol ImageManagerDelegate {
    func imageManagerController(controller:ImageManagerViewController, didFinishEditingImage image:UIImage)
    func imageManagerControllerDidCancel(controller:ImageManagerViewController)
}

class ImageManagerViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var croppingView: UIView!
    
//    var image: UIImage?
    var delegate: ImageManagerDelegate?
    var displayedImage : UIImage?
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupCroppingView()
        
        initializeGestureRecognizers(imageView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Private
    
    func setupImageView(){
        imageView.userInteractionEnabled = true
//        image = UIImage(named: "image.jpg")
        imageView.image = displayedImage
    }
    
    func setupCroppingView() {
        var myColor : UIColor = UIColor( red: 0, green: 1.0, blue:0, alpha: 1.0 )
        croppingView.layer.borderColor = myColor.CGColor
        croppingView.layer.borderWidth = 2.0
        croppingView.alpha = 1.0
        croppingView.backgroundColor = UIColor.clearColor()
        croppingView.userInteractionEnabled = false
    }
    
    func initializeGestureRecognizers(targetView:UIView) {
        var panGesture: UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panAction:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        targetView.addGestureRecognizer(panGesture)
        
        var rotateGesture: UIRotationGestureRecognizer = UIRotationGestureRecognizer(target: self, action: Selector("rotate:"))
        rotateGesture.delegate = self
        targetView.addGestureRecognizer(rotateGesture)
        
        var pinchGesture: UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        pinchGesture.delegate = self
        targetView.addGestureRecognizer(pinchGesture)
        
        var doubleTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTap:"))
        doubleTapGesture.numberOfTapsRequired = 2
        targetView.addGestureRecognizer(doubleTapGesture)
    }
    
    func saveImageToPhotoLibrary() {
        var croppingRectRelativeToImageView: CGRect = view.convertRect(croppingView.frame, toView: imageView)
        var scaledCroppingFrame : CGRect =  imageView.scaledCropRectForFrame(croppingRectRelativeToImageView)
        let croppedImage : UIImage = imageView.image!.cropWithCroppingFrame(scaledCroppingFrame)
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        showDoneSavingImageMessage()
    }
    
    func showDoneSavingImageMessage(){
        let alert = UIAlertController (title:"Image Saved", message: "Your image has been saved to your camera roll", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
        
        if let delegate = self.delegate {
            delegate.imageManagerController(self, didFinishEditingImage: displayedImage!)
        }
        
        dismissController()
    }
    
    func showErrorSavingImageMessage(){
        let alert = UIAlertController (title:"Error saving image", message: "Permissions not granted", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    @IBAction func cropAndSaveAction(sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            switch status {
                case .Authorized:
                    self.saveImageToPhotoLibrary()
                default:
                    self.showErrorSavingImageMessage()
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if let delegate = self.delegate {
            delegate.imageManagerControllerDidCancel(self)
        }
        
        dismissController()
    }
    
    func dismissController() {
        if isModal() {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Gesture Handlers
    
    func panAction(recognizer: UIPanGestureRecognizer) {
        
        var frame:CGRect? = recognizer.view?.frame
        let translation = recognizer.translationInView(self.view)
        var transform:CGAffineTransform = CGAffineTransformTranslate(view.transform, translation.x, translation.y)
        var finalRect: CGRect = CGRectApplyAffineTransform(frame!, transform)
//        var contains: Bool = CGRectContainsRect(finalRect, croppingView.frame)

        if let view = recognizer.view {
            view.transform = CGAffineTransformTranslate(view.transform, translation.x, translation.y)
        }

        
        recognizer.setTranslation(CGPointZero, inView: self.view)
    }
    
    func handlePinch(recognizer : UIPinchGestureRecognizer) {
        
        var frame:CGRect? = recognizer.view?.frame
        var transform:CGAffineTransform = CGAffineTransformScale(view.transform,
            recognizer.scale, recognizer.scale)
        var finalRect: CGRect = CGRectApplyAffineTransform(frame!, transform)
//        var contains: Bool = CGRectContainsRect(finalRect, croppingView.frame)
        
        switch recognizer.state {
            case .Changed:
                if let view = recognizer.view {
                    view.transform = CGAffineTransformScale(view.transform,
                        recognizer.scale, recognizer.scale)
                    recognizer.scale = 1
                }
            case .Ended:
                view.transform = CGAffineTransformIdentity

            default:
                return
        }
        
        
    }
    
    func rotate(gesture:UIRotationGestureRecognizer)
    {
        switch gesture.state
        {
            case .Ended:
                var angle: CGFloat = 0.0
                if gesture.rotation > 0 {
                    angle = 90.0
                }
                else {
                    angle = -90.0
                }
                
                let degreesToRadians: (CGFloat) -> CGFloat = {
                    return $0 / 180.0 * CGFloat(M_PI)
                }
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    let t = CGAffineTransformRotate(self.imageView.transform, degreesToRadians(angle));
                    self.imageView.transform = t
                    }, completion: { (result) -> Void in
                        var newImage: UIImage? = self.displayedImage?.imageRotatedByDegrees(angle)
                        self.displayedImage = newImage
                        self.imageView.image = newImage
                        let t = CGAffineTransformRotate(self.imageView.transform, degreesToRadians(-angle));
                        self.imageView.transform = t
                })
     
            case .Changed:
                NSLog("angle:%f", gesture.rotation)
            default:
                print("")
        }
    }
    
    func handleDoubleTap(gesture:UITapGestureRecognizer)
    {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            let t = CGAffineTransformIdentity
            self.imageView.transform = t
        })
        
    }
    
    //MARK:- Utils
    
    func isModal() -> Bool
    {
        if (self.presentingViewController != nil) {
            return true
        }
        if (self.presentingViewController?.presentedViewController == self) {
            return true
        }
        if (self.navigationController?.presentingViewController?.presentedViewController == self.navigationController) {
            return true
        }
        
        return false
    }
    
}

// MARK:- Gesture Delegate

extension ImageManagerViewController:UIGestureRecognizerDelegate
{
    func gestureRecognizer(UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }
}
