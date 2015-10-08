//
//  AddPhotoViewController.swift
//  ImageManager
//


import UIKit
import Photos
import AVFoundation

class AddPhotoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    let picker = UIImagePickerController()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initImagePicker()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - private
    
    func showActionSheet() {
        let optionMenu = buildActionSheetOptionMenu()
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad ) {
            if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = addPhotoButton
                popoverController.sourceRect = addPhotoButton.bounds
            }
        }
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    func buildActionSheetOptionMenu() -> UIAlertController {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let addPhotosFromCameraAction = getAddPhotosFromCameraAction()
        let addPhotosFromLibraryAction = getAddPhotosFromLibraryAction()
        let cancelAction = getCancelAction()
        
        optionMenu.addAction(addPhotosFromCameraAction)
        optionMenu.addAction(addPhotosFromLibraryAction)
        optionMenu.addAction(cancelAction)
        return optionMenu
    }
    
    func getAddPhotosFromCameraAction() -> UIAlertAction {
        let addPhotosFromCameraAction = UIAlertAction(title: "Camera", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showPickerWithSourceTypeCamera()
        })
        return addPhotosFromCameraAction
    }
    
    func getAddPhotosFromLibraryAction() -> UIAlertAction {
        let addPhotosFromLibraryAction = UIAlertAction(title: "Library", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showPickerWithSourceTypeLibrary()
        })
        return addPhotosFromLibraryAction
    }
    
    func getCancelAction() -> UIAlertAction {
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        return cancelAction
    }
    
    func initImagePicker() {
        picker.delegate = self
    }
    
    func showPickerWithSourceTypeLibrary() {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            switch status {
            case .Authorized,.NotDetermined:
                self.picker.allowsEditing = false
                self.picker.sourceType = .PhotoLibrary
                self.navigationController!.presentViewController(self.picker, animated: true, completion: nil)
            default:
                self.showNoLibraryPermissionsMessage()
            }
        }
    }
    
    func showPickerWithSourceTypeCamera() {
        let status: AVAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch status {
        case .Authorized:
            self.launchCameraIfTheDeviceHasOne()
        case .NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
                if(granted){
                    self.launchCameraIfTheDeviceHasOne()
                } else {
                    self.showNoCameraPermissionsMessage()
                }
            })
        default:
            self.showNoCameraPermissionsMessage()
        }
    }
    
    func launchCameraIfTheDeviceHasOne() {
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
            self.picker.allowsEditing = false
            self.picker.sourceType = UIImagePickerControllerSourceType.Camera
            self.picker.cameraCaptureMode = .Photo
            self.navigationController!.presentViewController(self.picker, animated: true, completion: nil)
        } else {
            println("no camera")
            self.noCamera()
        }
    }
    
    func launchImageManagerWithImage(image : UIImage) {
        let imageManagerVc = ImageManagerViewController(nibName: "ImageManagerViewController", bundle: nil)
        imageManagerVc.displayedImage = image
        self.navigationController?.pushViewController(imageManagerVc, animated: true)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style:.Default, handler: nil)
        alertVC.addAction(okAction)
        presentViewController(alertVC, animated: true, completion: nil)
    }
    
    func showNoLibraryPermissionsMessage(){
        let alert = UIAlertController (title:"Error launching photo library", message: "Permissions not granted", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showNoCameraPermissionsMessage() {
        let alert = UIAlertController (title:"Error launching camera", message: "Permissions not granted", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    @IBAction func addPhotoButtonPressed(sender: AnyObject) {
        showActionSheet()
    }
    
    //MARK: - ImagePicker Delegate methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        var chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismissViewControllerAnimated(true) { () -> Void in
            self.launchImageManagerWithImage(chosenImage)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
