//
//  PhotoCaptureService.swift
//  FaceApp2
//
//  Created by Emrullah Yılmaz on 17.01.2026.
//

//
//  PhotoCaptureService.swift
//  FaceFotoV2
//
//  Created by Emrullah Yılmaz on 30.11.2025.
//

import AVFoundation
import Photos
import UIKit
import Combine

class PhotoCaptureService: NSObject, ObservableObject, AVCapturePhotoCaptureDelegate {
    let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private var photoCaptureCompletion: ((UIImage) -> Void)?
    
    override init() {
        super.init()
        setup()
    }
    
    func setup() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.configureSession()
                    } else {
                        print("Kamera izni reddedildi. Lütfen Ayarlar > Gizlilik > Kamera'dan izin verin.")
                    }
                }
            }
        case .denied, .restricted:
            print("Kamera izni yok. Lütfen Ayarlar > Gizlilik > Kamera'dan izin verin.")
        @unknown default:
            print("Bilinmeyen kamera izni durumu")
        }
    }
    
    private func configureSession() {
        session.beginConfiguration()

        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video,
                                                   position: .back),
              let input = try? AVCaptureDeviceInput(device: camera) else {
            session.commitConfiguration()
            print("Kamera girişi oluşturulamadı")
            return
        }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }

        session.commitConfiguration()
    }
    
    func startSession() {
        if !session.isRunning {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            guard status == .authorized else {
                print("Kamera izni olmadan oturum başlatılamaz.")
                return
            }
            DispatchQueue.global(qos: .background).async {
                self.session.startRunning()
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .background).async {
                self.session.stopRunning()
            }
        }
    }
    
    func capturePhoto(completion: @escaping (UIImage) -> Void) {
        let settings = AVCapturePhotoSettings()
        self.photoCaptureCompletion = completion
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let img = UIImage(data: data) else { return }
        
        photoCaptureCompletion?(img)
    }
    
    func savePhotoToGallery(_ image: UIImage) {
        #if compiler(>=5.5)
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .authorized, .limited:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Fotoğraf galeriye kaydedildi")
                        } else if let error = error {
                            print("Galeriye kaydetme hatası: \(error.localizedDescription)")
                        } else {
                            print("Galeriye kaydetme başarısız, bilinmeyen hata")
                        }
                    }
                }
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized || newStatus == .limited {
                            self.savePhotoToGallery(image)
                        } else {
                            print("Fotoğraf ekleme izni reddedildi veya kısıtlı: \(newStatus)")
                        }
                    }
                }
            case .denied, .restricted:
                print("Fotoğraf ekleme izni yok. Lütfen Ayarlar > Gizlilik > Fotoğraflar'dan izin verin.")
            @unknown default:
                print("Bilinmeyen fotoğraf izni durumu")
            }
        } else {
            let status = PHPhotoLibrary.authorizationStatus()
            switch status {
            case .authorized:
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            print("Fotoğraf galeriye kaydedildi")
                        } else if let error = error {
                            print("Galeriye kaydetme hatası: \(error.localizedDescription)")
                        } else {
                            print("Galeriye kaydetme başarısız, bilinmeyen hata")
                        }
                    }
                }
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { newStatus in
                    DispatchQueue.main.async {
                        if newStatus == .authorized {
                            self.savePhotoToGallery(image)
                        } else {
                            print("Fotoğraf ekleme izni reddedildi: \(newStatus)")
                        }
                    }
                }
            case .denied, .restricted, .limited:
                print("Fotoğraf ekleme izni yok veya kısıtlı. Lütfen Ayarlar'dan izin verin.")
            @unknown default:
                print("Bilinmeyen fotoğraf izni durumu")
            }
        }
        #else
        // Eski derleyiciler için basit kontrol
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .authorized {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                DispatchQueue.main.async {
                    if success {
                        print("Fotoğraf galeriye kaydedildi")
                    } else if let error = error {
                        print("Galeriye kaydetme hatası: \(error.localizedDescription)")
                    } else {
                        print("Galeriye kaydetme başarısız, bilinmeyen hata")
                    }
                }
            }
        } else if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized {
                        self.savePhotoToGallery(image)
                    } else {
                        print("Fotoğraf ekleme izni reddedildi: \(newStatus)")
                    }
                }
            }
        } else {
            print("Fotoğraf ekleme izni yok. Lütfen Ayarlar'dan izin verin.")
        }
        #endif
    }
}
