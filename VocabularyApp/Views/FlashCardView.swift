//
//  FlashCardView.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 09.04.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import UIKit
import SnapKit

class FlashCardView: UIView {
    let text = UILabel()
    var pair: VocabularyPairLocalDataModel? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func updateColor(color: UIColor) {
        if color == UIColor.black {
            self.backgroundColor = UIColor.orange
        } else {
            self.backgroundColor = color
        }
    }
    
    private func setupView() {
        self.backgroundColor = UIColor.orange
        
        self.dropShadow()
        self.text.translatesAutoresizingMaskIntoConstraints = false
        self.text.font = UIFont.systemFont(ofSize: FontConstants.xLarge)
        self.text.textColor = UIColor.black
        self.text.textAlignment = .center
        self.text.numberOfLines = 0
        
        self.addSubview(self.text)
        
        self.text.snp.makeConstraints { make in
            make.left.equalTo(self).offset(LayoutConstants.buX2)
            make.top.equalTo(self).offset(LayoutConstants.buX2)
            make.bottom.equalTo(self).offset(-LayoutConstants.buX2)
            make.right.equalTo(self).offset(-LayoutConstants.buX2)
        }
    }
}
