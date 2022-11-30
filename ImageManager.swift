//
//  ImageManager.swift
//  Cash Clicker
//
//  Created by Aman preet on 3/7/19.
//  Copyright © 2019 Aman preet. All rights reserved.
//

import Foundation
import UIKit
import AVKit

protocol ImageManagerDelegate{
    
    func didImageSelect(image:UIImage, url:URL?, mediaType:String?)
    func didImageCancel()
}

class ImageManager: NSObject
{
    var imageDelegate:ImageManagerDelegate? = nil
    let imageController = UIImagePickerController()
    
    class func manager() -> ImageManager {
        struct Static {
            static let manager = ImageManager()
        }
        return Static.manager
    }
    
    override init() {
        super.init()
        imageController.delegate = self
    }
}

 // MARK: -ImagePicker Delegate Methods
extension ImageManager : UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {
            if mediaType  == "public.image" {
                if let selectedImage = info[.editedImage] as? UIImage {
                    self.imageDelegate?.didImageSelect(image: selectedImage, url: info[.imageURL] as? URL, mediaType: mediaType)
                }
            } else if mediaType == "public.movie" {
                if let outputVideo = info[.mediaURL] as? URL {
                    self.imageDelegate?.didImageSelect(image: UIImage(), url: outputVideo, mediaType: mediaType)
                }
            }
        }
        // Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Cancelled")
        self.imageDelegate?.didImageCancel()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func decreaseImageQuality(img: UIImage) -> UIImage {
        let size = __CGSizeApplyAffineTransform(img.size, CGAffineTransform.init(scaleX: 0.2, y: 0.2))
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        img.draw(in: CGRect(origin: CGPoint.zero, size: size))
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension ImageManager {
    func openCamera(vc: UIViewController, mediaType: [String])
    {
    if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imageController.sourceType = UIImagePickerController.SourceType.camera
            imageController.allowsEditing = true
            imageController.mediaTypes = mediaType
            vc.present(imageController, animated: true, completion: nil)
        }
        else
        {
           // showAlert(title: "Error", message: "You don't have camera")
        }
    }
    
    // MARK: -  Open gallery
    func openGallary(vc: UIViewController, mediaType: [String])
    {
        imageController.sourceType = UIImagePickerController.SourceType.photoLibrary
        imageController.allowsEditing = true
        imageController.mediaTypes = mediaType
        vc.present(imageController, animated: true, completion: nil)
    }
}
