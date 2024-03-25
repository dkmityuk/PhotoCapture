//
//  SnapKit+Extensions.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 21.03.2024.
//

import UIKit
import SnapKit

extension UIView {
  var safeArea:  ConstraintLayoutGuideDSL {
    return self.safeAreaLayoutGuide.snp
  }
}
