//
//  UIImage+Rotation.swift
//  ImageManager
//

import UIKit

extension UIImage {
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        let nImage = normalizedImage()
        
        let rotatedSize = CGSizeMake(nImage.size.height, nImage.size.width)
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees))
        
        // Now, draw the rotated/scaled image into the context
        CGContextScaleCTM(bitmap, 1, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), nImage.CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    public func normalizedImage() -> UIImage {
        if imageOrientation == .Up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        drawInRect(CGRectMake(0, 0, size.width, size.height))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
    public func cropWithCroppingFrame(croppingFrame : CGRect) -> UIImage {
        // Create a new UIImage
        let imageRef = CGImageCreateWithImageInRect(CGImage, croppingFrame)!
        let croppedImage = UIImage(CGImage: imageRef)
        return croppedImage
    }
}
