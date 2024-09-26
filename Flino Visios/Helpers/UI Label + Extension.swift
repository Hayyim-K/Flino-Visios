//
//  UI Label + Extension.swift


import UIKit

extension UILabel {
    
    func animatePulseAndColorChange(_ color: UIColor) {
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            self.textColor = color
        }, completion: { [weak self] _ in
            
            UIView.animate(withDuration: 0.3, animations: {
                self?.transform = CGAffineTransform.identity
                self?.textColor = .white
            })
        })
    }
}

