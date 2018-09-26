//
//  String+extension.swift
//  YourLastTime
//
//  Created by Alberto Banet Masa on 26/09/2018.
//  Copyright © 2018 abanet. All rights reserved.
//

import UIKit

extension String {
  func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.height)
  }
  
  func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
    let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
    let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
    
    return ceil(boundingBox.width)
  }
}

extension StringProtocol where Index == String.Index {
  var lines: [SubSequence] {
    return split(maxSplits: .max, omittingEmptySubsequences: true, whereSeparator: { $0 == "\n" })
  }
  var removingAllExtraNewLines: String {
    return lines.joined(separator: "\n")
  }
}