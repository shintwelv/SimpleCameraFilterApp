//
//  EditPhotoWorker.swift
//  CameraFilterApp
//
//  Created by siheo on 12/15/23.
//  Copyright (c) 2023 ___ORGANIZATIONNAME___. All rights reserved.

import UIKit
import RxSwift

class EditPhotoWorker: NSObject
{
    var savePhotoResult = PublishSubject<EditPhoto.SavePhotoResult<UIImage>>()
    
    func savePhoto(_ image:UIImage) {
        if let _ = image.cgImage { // UIImage가 CGImage 기반이어야 저장이 가능
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_: didFinishSavingWithError: contextInfo:)), nil)
        } else {
            guard let ciImage = image.ciImage else {
                self.savePhotoResult.onNext(EditPhoto.SavePhotoResult.Failure(.noCIImage("UIImage 내에 CIImage가 존재하지 않습니다")))
                return
            }
            
            guard let uiImage = convert(ciImage) else {
                self.savePhotoResult.onNext(EditPhoto.SavePhotoResult.Failure(.cannotConvert("CIImage를 UIImage로 변환할 수 없습니다")))
                return
            }
            
            UIImageWriteToSavedPhotosAlbum(uiImage, self, #selector(imageSaved(_: didFinishSavingWithError: contextInfo:)), nil)
        }
    }
    
    @objc private func imageSaved(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            self.savePhotoResult.onNext(EditPhoto.SavePhotoResult.Failure(.cannotSave(error.localizedDescription)))
        } else {
            self.savePhotoResult.onNext(EditPhoto.SavePhotoResult.Success(result: image))
        }
    }
    
    private func convert(_ ciImage:CIImage) -> UIImage? {
        let context:CIContext = CIContext(options: nil)
        guard let cgImage:CGImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let image:UIImage = UIImage(cgImage: cgImage)
        return image
    }
}
