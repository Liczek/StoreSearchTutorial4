//
//  GradientView.swift
//  StoreSearchTutorial4
//
//  Created by Paweł Liczmański on 27.03.2017.
//  Copyright © 2017 Paweł Liczmański. All rights reserved.
//

import Foundation
import UIKit

class GradientView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        // rozciągnięcie gradientu w momencie obracania, tak żeby zawse pokrywał całe VIEW
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
        // rozciągnięcie gradientu w momencie obracania, tak żeby zawse pokrywał całe VIEW
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    override func draw(_ rect: CGRect) {
                            // RGB   red,green,blue alpha / red,green,blue,alpha <- czarny kolor z różną alpha
        let components: [CGFloat] = [0, 0, 0, 0.3, 0, 0, 0, 0.7]
                            //position 0 - center, 1 - obwód koła to wartości w % 0.2 było by to 20% promienia w danym kolorze
        let locations: [CGFloat] = [0, 1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        // mid x to przekątna x , a midy przekątna y (potrzebne do okreslenia rozmiaru koła)
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        // max(x,y) wyznacza średnicę poprzez wybranie albo x albo y - ktora wartość większa zależnie od ustawienia ekranu
        let radius = max(x, y)
        
        
        // to już samo rysowanie zawsze okrelsamy context i pozneij okrelsamy opcje rysowania
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
}
