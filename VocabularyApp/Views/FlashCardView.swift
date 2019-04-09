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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
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
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }
    }
}
