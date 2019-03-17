//
//  ModalSpinnerView.swift
//  VocabularyApp
//
//  Created by Chris Braunschweiler on 17.03.19.
//  Copyright © 2019 braunsch. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ModalSpinnerView: UIView {
    
    private let appearanceAnimationDuraiton = AnimationConstants.appearanceDuration
    private let bag = DisposeBag()
    private let backgroundBlur = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let spinner = SpinnerView()
    
    let animating = PublishSubject<Bool>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    func setupView() {
        self.backgroundColor = UIColor.clear
        self.isUserInteractionEnabled = false
        
        //Hide everything by default
        self.backgroundBlur.alpha = 0
        
        self.addSubview(self.backgroundBlur)
        self.addSubview(self.spinner)
        
        setupConstraints()
        
        self.animating.bind(to: self.spinner.animating).disposed(by: bag)
        self.animating.distinctUntilChanged().subscribe(
            onNext: { animating in
                self.isUserInteractionEnabled = animating
                let startAlpha = animating ? 0 : 1
                let endAlpha = animating ? 1 : 0
                self.backgroundBlur.alpha = CGFloat(startAlpha)
                
                UIView.animate(withDuration: self.appearanceAnimationDuraiton) {
                    self.backgroundBlur.alpha = CGFloat(endAlpha)
                }
        }
            ).disposed(by: bag)
    }
    
    func setupConstraints() {
        self.backgroundBlur.snp.makeConstraints { make in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
        }
        self.spinner.snp.makeConstraints { make in
            make.centerX.equalTo(self)
            make.centerY.equalTo(self)
        }
    }
}
