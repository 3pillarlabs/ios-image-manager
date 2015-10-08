//
//  UIImage+Rotation.swift
//  ImageManager
//

import UIKit

extension UIImage
{
    public func imageRotatedByDegrees(degrees: CGFloat) -> UIImage {
        let radiansToDegrees: (CGFloat) -> CGFloat = {
            return $0 * (180.0 / CGFloat(M_PI))
        }
        let degreesToRadians: (CGFloat) -> CGFloat = {
            return $0 / 180.0 * CGFloat(M_PI)
        }
        
        var nImage:UIImage = normalizedImage();
        
        let rotatedSize = CGSizeMake(nImage.size.height, nImage.size.width)
        NSLog("size:%@",NSStringFromCGSize(rotatedSize))
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width / 2.0, rotatedSize.height / 2.0);
        
        //   // Rotate the image context
        CGContextRotateCTM(bitmap, degreesToRadians(degrees));
        
        // Now, draw the rotated/scaled image into the context
        CGContextScaleCTM(bitmap, 1, -1.0)
        CGContextDrawImage(bitmap, CGRectMake(-size.width / 2, -size.height / 2, size.width, size.height), nImage.CGImage)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("orientation:%d",self.imageOrientation.rawValue)
        print("orientation1:%d",newImage.imageOrientation.rawValue)
        
        return newImage
    }
    
    public func normalizedImage() -> UIImage
    {
        if (self.imageOrientation == UIImageOrientation.Up)
        {
            return self;
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.drawInRect(CGRectMake(0, 0, size.width, size.height))
        var normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    public func cropWithCroppingFrame(croppingFrame : CGRect) -> UIImage {
        // Create a new UIImage
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(self.CGImage, croppingFrame)
        let croppedImage : UIImage = UIImage(CGImage: imageRef)!
        return croppedImage;
    }
}
