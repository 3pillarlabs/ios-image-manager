//
//  UIImageView+Utils.swift
//  ImageManager
//


import UIKit

extension UIImageView {
    
    public func scaledCropRectForFrame(frame: CGRect) -> CGRect {
        let widthScale:CGFloat  = bounds.size.width / image!.size.width
        let heightScale:CGFloat = bounds.size.height / image!.size.height
        
        var x, y, w, h, offset :CGFloat
        
        if widthScale < heightScale {
            offset = (bounds.size.height - (image!.size.height*widthScale))/2
            x = frame.origin.x / widthScale
            y = (frame.origin.y-offset) / widthScale
            w = frame.size.width / widthScale
            h = frame.size.height / widthScale
        } else {
            offset = (bounds.size.width - (image!.size.width*heightScale))/2
            x = (frame.origin.x-offset) / heightScale
            y = frame.origin.y / heightScale
            w = frame.size.width / heightScale
            h = frame.size.height / heightScale
        }
        return CGRectMake(x, y, w, h)
    }
}
