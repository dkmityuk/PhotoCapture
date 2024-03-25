//
//  Optional+Extensions.swift
//  PhotoCatpure
//
//  Created by Dmytro Kmytiuk on 25.03.2024.
//

import Foundation

// MARK: - Optional
public extension Optional {
  
  var isNil: Bool {
    return self == nil
  }
  
  var isNotNil: Bool {
    return !isNil
  }
}

