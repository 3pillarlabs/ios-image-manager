//
//  AddPhotoViewController.swift
//  ImageManager
//


import UIKit
import Photos
import AVFoundation
//import ImageManager

class AddPhotoViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var addPhotoButton: UIButton!
    
    let picker = UIImagePickerController()
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
    }
    
    //MARK: - private
    
    func showActionSheet() {
        let optionMenu = buildActionSheetOptionMenu()
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ) {
            if let popoverController = optionMenu.popoverPresentationController {
                popoverController.sourceView = addPhotoButton
                popoverController.sourceRect = addPhotoButton.bounds
            }
        }
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func buildActionSheetOptionMenu() -> UIAlertController {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addPhotosFromCameraAction = getAddPhotosFromCameraAction()
        let addPhotosFromLibraryAction = getAddPhotosFromLibraryAction()
        let cancelAction = getCancelAction()
        
        optionMenu.addAction(addPhotosFromCameraAction)
        optionMenu.addAction(addPhotosFromLibraryAction)
        optionMenu.addAction(cancelAction)
        return optionMenu
    }
    
    func getAddPhotosFromCameraAction() -> UIAlertAction {
        let addPhotosFromCameraAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showPickerWithSourceTypeCamera()
        })
        return addPhotosFromCameraAction
    }
    
    func getAddPhotosFromLibraryAction() -> UIAlertAction {
        let addPhotosFromLibraryAction = UIAlertAction(title: "Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.showPickerWithSourceTypeLibrary()
        })
        return addPhotosFromLibraryAction
    }
    
    func getCancelAction() -> UIAlertAction {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        return cancelAction
    }
    
    func showPickerWithSourceTypeLibrary() {
        PHPhotoLibrary.requestAuthorization { (status:PHAuthorizationStatus) -> Void in
            switch status {
            case .authorized,.notDetermined:
                self.picker.allowsEditing = false
                self.picker.sourceType = .photoLibrary
                self.navigationController!.present(self.picker, animated: true, completion: nil)
            default:
                self.showNoLibraryPermissionsMessage()
            }
        }
    }
    
    func showPickerWithSourceTypeCamera() {
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            self.launchCameraIfTheDeviceHasOne()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted :Bool) -> Void in
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
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            navigationController!.present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    func launchImageManagerWithImage(image : UIImage) {
        let imageManagerVc = ImageManagerViewController()
        imageManagerVc.displayedImage = image
        self.navigationController?.pushViewController(imageManagerVc, animated: true)
    }
    
    func noCamera(){
        let alertVC = UIAlertController(title: "No Camera", message: "Sorry, this device has no camera", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertVC.addAction(okAction)
        present(alertVC, animated: true, completion: nil)
    }
    
    func showNoLibraryPermissionsMessage(){
        let alert = UIAlertController (title:"Error launching photo library", message: "Permissions not granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showNoCameraPermissionsMessage() {
        let alert = UIAlertController (title:"Error launching camera", message: "Permissions not granted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Actions
    
    @IBAction func addPhotoButtonPressed(sender: AnyObject) {
        showActionSheet()
    }
    
    //MARK: - ImagePicker Delegate methods

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated: true) { () -> Void in
            self.launchImageManagerWithImage(image: chosenImage)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
