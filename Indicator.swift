//
//  Indicator.swift
//  AppdeftChat
//
//  Created by Gaurav on 04/04/22.
//

import Foundation
import UIKit
import NVActivityIndicatorView
import SwiftGifOrigin
class Indicator{
    
    private enum indicatorTypes{
        case NVIndicator
        case Gif
    }
    
    static let shared = Indicator()
    private var backgroundView = UIView()
    private var indicatorType: indicatorTypes = .Gif
    private var indicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 90, height: 90), type: .ballPulseRise, color: AppColors.color1, padding: 15)
    
    func start(){
        DispatchQueue.main.async {
            
            switch self.indicatorType {
            case .NVIndicator:
                self.backgroundView.removeFromSuperview()
                self.indicatorView.stopAnimating()
            case .Gif:
                self.backgroundView.removeFromSuperview()
            }
            
            let window = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .compactMap({$0 as? UIWindowScene})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            self.backgroundView = UIView(frame: window?.bounds ?? .zero )
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            switch self.indicatorType {
            case .NVIndicator:
                self.indicatorView.center = self.backgroundView.center
                self.indicatorView.backgroundColor = .white
                self.indicatorView.layer.cornerRadius = 10
                self.backgroundView.addSubview(self.indicatorView)
                window?.addSubview(self.backgroundView )
                self.indicatorView.startAnimating()
            case .Gif:
                let img = UIImageView()
                img.frame = CGRect(x: 0, y: 0, width: 90, height: 90)
                img.center = self.backgroundView.center
                img.layer.cornerRadius = 10
                img.loadGif(name: "wrench")
                img.clipsToBounds = true
                self.backgroundView.addSubview(img)
                window?.addSubview(self.backgroundView)
            }
        }
    }
    
    func stop(){
        DispatchQueue.main.async {
            switch self.indicatorType {
            case .NVIndicator:
                self.backgroundView.removeFromSuperview()
                self.indicatorView.stopAnimating()
            case .Gif:
                self.backgroundView.removeFromSuperview()
            }
        }
    }
}
