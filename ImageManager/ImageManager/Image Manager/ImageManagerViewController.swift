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
    
    var delegate: ImageManagerDelegate?
    var displayedImage : UIImage?
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupCroppingView()
        
        initializeGestureRecognizers(imageView)
    }
    
    //MARK: - Private
    
    func setupImageView() {
        imageView.userInteractionEnabled = true
        imageView.image = displayedImage
    }
    
    func setupCroppingView() {
        let customColor = UIColor( red: 0, green: 1.0, blue:0, alpha: 1.0 )
        croppingView.layer.borderColor = customColor.CGColor
        croppingView.layer.borderWidth = 2.0
        croppingView.alpha = 1.0
        croppingView.backgroundColor = .clearColor()
        croppingView.userInteractionEnabled = false
    }
    
    func initializeGestureRecognizers(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: Selector("panAction:"))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        targetView.addGestureRecognizer(panGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: Selector("rotate:"))
        rotateGesture.delegate = self
        targetView.addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
        pinchGesture.delegate = self
        targetView.addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: Selector("handleDoubleTap:"))
        doubleTapGesture.numberOfTapsRequired = 2
        targetView.addGestureRecognizer(doubleTapGesture)
    }
    
    func saveImageToPhotoLibrary() {
        let croppingRectRelativeToImageView = view.convertRect(croppingView.frame, toView: imageView)
        let scaledCroppingFrame  =  imageView.scaledCropRectForFrame(croppingRectRelativeToImageView)
        let croppedImage = imageView.image!.cropWithCroppingFrame(scaledCroppingFrame)
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        showDoneSavingImageMessage()
    }
    
    func showDoneSavingImageMessage() {
        let alert = UIAlertController (title:"Image Saved", message: "Your image has been saved to your camera roll", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { [weak self] (action) -> Void in
            self!.dismissController()
            }))
        presentViewController(alert, animated: true, completion:nil)
        
        if let delegate = delegate {
            delegate.imageManagerController(self, didFinishEditingImage: displayedImage!)
        }
    }
    
    func showErrorSavingImageMessage() {
        let alert = UIAlertController (title:"Error saving image", message: "Permissions not granted", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    @IBAction func cropAndSaveAction(sender: AnyObject) {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                switch status {
                case .Authorized:
                    self.saveImageToPhotoLibrary()
                default:
                    self.showErrorSavingImageMessage()
                }
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        if let delegate = delegate {
            delegate.imageManagerControllerDidCancel(self)
        }
        
        dismissController()
    }
    
    func dismissController() {
        if isModal() {
            dismissViewControllerAnimated(true, completion: nil)
        }
        else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - Gesture Handlers
    
    func panAction(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translationInView(view)
        if let view = recognizer.view {
            view.transform = CGAffineTransformTranslate(view.transform, translation.x, translation.y)
        }
        recognizer.setTranslation(CGPointZero, inView: view)
    }
    
    func handlePinch(recognizer : UIPinchGestureRecognizer) {
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
    
    func rotate(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .Ended:
            var angle: CGFloat = 0.0
            if gesture.rotation > 0 {
                angle = 90.0
            } else {
                angle = -90.0
            }
            
            let degreesToRadians: (CGFloat) -> CGFloat = {
                return $0 / 180.0 * CGFloat(M_PI)
            }
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                let t = CGAffineTransformRotate(self.imageView.transform, degreesToRadians(angle));
                self.imageView.transform = t
                }, completion: { (result) -> Void in
                    let newImage: UIImage? = self.displayedImage?.imageRotatedByDegrees(angle)
                    self.displayedImage = newImage
                    self.imageView.image = newImage
                    let t = CGAffineTransformRotate(self.imageView.transform, degreesToRadians(-angle));
                    self.imageView.transform = t
            })
        case .Changed:
            return
        default:
            return
        }
    }
    
    func handleDoubleTap(gesture: UITapGestureRecognizer) {
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageView.transform = CGAffineTransformIdentity
        })
    }
    
    //MARK:- Utils
    
    func isModal() -> Bool {
        if presentingViewController != nil {
            return true
        }
        if presentingViewController?.presentedViewController == self {
            return true
        }
        if navigationController?.presentingViewController?.presentedViewController == navigationController {
            return true
        }
        
        return false
    }
    
}

// MARK:- Gesture Delegate

extension ImageManagerViewController:UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer:UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
        return true
    }
}
