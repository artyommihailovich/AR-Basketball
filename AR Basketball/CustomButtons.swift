//
//  CustomButtons.swift
//  AR Basketball
//
//  Created by Artyom Mihailovich on 9/14/20.
//

import UIKit

class CustomButtons: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        costumizeButtons()
    }
    
    func costumizeButtons() {
        backgroundColor = UIColor.lightGray
        
        layer.cornerRadius = 12.0
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.white.cgColor
    }
}
