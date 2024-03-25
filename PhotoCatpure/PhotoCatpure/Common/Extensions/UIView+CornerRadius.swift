//
//  UIView+CornerRadius.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 21.03.2024.
//

import UIKit

extension UIView {
    
    func makeCorners(
        radius: CGFloat,
        maskedCorners: CACornerMask =  [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
    ) {
        layer.cornerRadius = radius
        layer.maskedCorners = maskedCorners
        clipsToBounds = true
    }
    
    func makeCircle() {
      clipsToBounds = true
      layer.cornerRadius = frame.size.height / 2
    }

    
}
