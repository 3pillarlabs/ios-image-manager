//
//  UIImage+Rotation.swift
//  ImageManager
//

import UIKit

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage? {
        
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * .pi
        }
        
        guard let nImage = normalizedImage() else { return nil }
        guard let cgImage = nImage.cgImage else { return nil }
        let rotatedSize = CGSize(width: nImage.size.height, height: nImage.size.width)
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        guard let bitmap = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        //   // Rotate the image context
        bitmap.rotate(by: degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1, y: -1.0)
        bitmap.draw(cgImage, in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width, height: size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func normalizedImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    public func cropWithCroppingFrame(croppingFrame : CGRect) -> UIImage? {
        guard let imageRef = self.cgImage?.cropping(to: croppingFrame) else { return nil }
        let croppedImage = UIImage(cgImage: imageRef)
        return croppedImage
    }
}
