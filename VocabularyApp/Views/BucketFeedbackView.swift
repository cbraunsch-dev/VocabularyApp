//
//  BucketFeedbackView.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 16.06.21.
//  Copyright © 2021 braunsch. All rights reserved.
//

import UIKit

class BucketFeedbackView: UIView {
    let image = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func showSuccess() {
        self.backgroundColor = UIColor.green
        self.image.image = UIImage(named: "Check")
        self.changeImageColor()
    }
    
    func showFailure() {
        self.backgroundColor = UIColor.red
        self.image.image = UIImage(named: "Clear")
        self.changeImageColor()
    }
    
    private func changeImageColor() {
        let tintableImage = image.image?.withRenderingMode(.alwaysTemplate)
        image.image = tintableImage
        image.tintColor = UIColor.white
    }

    private func setupView() {
        self.layer.cornerRadius = 10
        self.image.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(self.image)
        
        self.image.snp.makeConstraints { make in
            make.left.equalTo(self).offset(LayoutConstants.buX2)
            make.top.equalTo(self).offset(LayoutConstants.buX2)
            make.bottom.equalTo(self).offset(-LayoutConstants.buX2)
            make.right.equalTo(self).offset(-LayoutConstants.buX2)
        }
    }
}
