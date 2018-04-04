//
//  ImageManagerViewController.swift
//  ImageManager
//


import UIKit
import Photos

public protocol ImageManagerDelegate {
    func imageManagerController(controller:ImageManagerViewController, didFinishEditingImage image:UIImage)
    func imageManagerControllerDidCancel(controller:ImageManagerViewController)
}

public class ImageManagerViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var croppingView: UIView!
    
    public var delegate: ImageManagerDelegate?
    public var displayedImage : UIImage?
    
    //MARK: - View Life Cycle
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init() {
        let frameworkBundleID = "-PG.ImageManager"
        let bundle = Bundle(identifier: frameworkBundleID)
        self.init(nibName: "ImageManagerViewController", bundle: bundle)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupCroppingView()
        
        initializeGestureRecognizers(targetView: imageView)
    }

    //MARK: - Actions

    @IBAction func cropAndSave(_ sender: Any) {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            DispatchQueue.main.async() {
                switch status {
                case .authorized:
                    self.saveImageToPhotoLibrary()
                default:
                    self.showErrorSavingImageMessage()
                }
            }
        }
    }

    @IBAction func cancel(_ sender: Any) {
        if let delegate = delegate {
            delegate.imageManagerControllerDidCancel(controller: self)
        }

        dismissController()
    }

    func dismissController() {
        if isModal() {
            dismiss(animated: true, completion: nil)
        }
        else {
            navigationController?.popViewController(animated: true)
        }
    }

    
    //MARK: - Private
    
    private func setupImageView() {
        imageView.isUserInteractionEnabled = true
        imageView.image = displayedImage
    }
    
    private func setupCroppingView() {
        let customColor = UIColor( red: 0, green: 1.0, blue:0, alpha: 1.0 )
        croppingView.layer.borderColor = customColor.cgColor
        croppingView.layer.borderWidth = 2.0
        croppingView.alpha = 1.0
        croppingView.backgroundColor = .clear
        croppingView.isUserInteractionEnabled = false
    }
    
    private func initializeGestureRecognizers(targetView: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panAction(recognizer:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        targetView.addGestureRecognizer(panGesture)
        
        let rotateGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(gesture:)))
        rotateGesture.delegate = self
        targetView.addGestureRecognizer(rotateGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(recognizer:)))
        pinchGesture.delegate = self
        targetView.addGestureRecognizer(pinchGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        targetView.addGestureRecognizer(doubleTapGesture)
    }
    
    private func saveImageToPhotoLibrary() {
        let croppingRectRelativeToImageView = view.convert(croppingView.frame, to: imageView)
        let scaledCroppingFrame  =  imageView.scaledCropRectForFrame(frame: croppingRectRelativeToImageView)
        guard let croppedImage = imageView.image!.cropWithCroppingFrame(croppingFrame: scaledCroppingFrame) else {
            showErrorSavingImageMessage()
            return
        }
        UIImageWriteToSavedPhotosAlbum(croppedImage, nil, nil, nil)
        showDoneSavingImageMessage()
    }
    
    private func showDoneSavingImageMessage() {
        let alert = UIAlertController (title:"Image Saved", message: "Your image has been saved to your camera roll", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (action) -> Void in
            self!.dismissController()
        }))
        present(alert, animated: true, completion:nil)
        
        if let delegate = delegate {
            delegate.imageManagerController(controller: self, didFinishEditingImage: displayedImage!)
        }
    }
    
    private func showErrorSavingImageMessage() {
        let alert = UIAlertController (title:"Error saving image", message: "Permissions not granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // MARK: - Gesture Handlers
    
    @objc func panAction(recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: view)
        if let view = recognizer.view {
            view.transform = view.transform.translatedBy(x: translation.x, y: translation.y)
        }
        recognizer.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func handlePinch(recognizer : UIPinchGestureRecognizer) {
        switch recognizer.state {
        case .changed:
            if let view = recognizer.view {

                view.transform = view.transform.scaledBy(x: recognizer.scale, y: recognizer.scale)
                recognizer.scale = 1
            }
        case .ended:
            view.transform = CGAffineTransform.identity
        default:
            return
        }
    }
    
    @objc func rotate(gesture: UIRotationGestureRecognizer) {
        switch gesture.state {
        case .ended:
            var angle: CGFloat = 0.0
            if gesture.rotation > 0 {
                angle = 90.0
            } else {
                angle = -90.0
            }
            
            let degreesToRadians: (CGFloat) -> CGFloat = {
                return $0 / 180.0 * .pi
            }

            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                let t = self.imageView.transform.rotated(by: degreesToRadians(angle))
                self.imageView.transform = t
            }, completion: { (result) -> Void in
                let newImage: UIImage? = self.displayedImage?.imageRotatedByDegrees(degrees: angle)
                self.displayedImage = newImage
                self.imageView.image = newImage
                let t = self.imageView.transform.rotated(by: degreesToRadians(-angle))
                self.imageView.transform = t
            })
        case .changed:
            return
        default:
            return
        }
    }
    
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.imageView.transform = CGAffineTransform.identity
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
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                  shouldRecognizeSimultaneouslyWith shouldRecognizeSimultaneouslyWithGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
