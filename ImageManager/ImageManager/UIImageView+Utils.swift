//
//  UIImageView+Utils.swift
//  ImageManager
//


import UIKit

extension UIImageView {
    
    public func scaledCropRectForFrame(frame:CGRect) -> CGRect
    {
        var widthScale:CGFloat  = self.bounds.size.width / self.image!.size.width;
        var heightScale:CGFloat = self.bounds.size.height / self.image!.size.height;
        
        var x, y, w, h, offset :CGFloat
        if (widthScale<heightScale) {
            offset = (self.bounds.size.height - (self.image!.size.height*widthScale))/2;
            x = frame.origin.x / widthScale;
            y = (frame.origin.y-offset) / widthScale;
            w = frame.size.width / widthScale;
            h = frame.size.height / widthScale;
        } else {
            offset = (self.bounds.size.width - (self.image!.size.width*heightScale))/2;
            x = (frame.origin.x-offset) / heightScale;
            y = frame.origin.y / heightScale;
            w = frame.size.width / heightScale;
            h = frame.size.height / heightScale;
        }
        return CGRectMake(x, y, w, h);
    }
}
