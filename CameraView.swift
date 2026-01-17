//
//  CameraView.swift
//  FaceApp2
//
//  Created by Emrullah Yılmaz on 17.01.2026.
//

//
//  CameraView.swift
//  FaceFotoV2
//
//  Created by Emrullah Yılmaz on 30.11.2025.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @StateObject private var camera = PhotoCaptureService()
    var referenceImage: UIImage?
    var showGrid: Bool
    
    @State private var opacity: Double = 0.45
    @State private var showGridLines: Bool = true
    @State private var showPhotoPreview = false
    @State private var capturedImage: UIImage? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
                .ignoresSafeArea()
            
            // GRID LINES
            if showGrid && showGridLines {
                GridOverlayView()
            }
            
            // REFERANS OVERLAY (eğer varsa)
            if let referenceImage = referenceImage {
                ReferenceOverlayView(image: referenceImage, opacity: opacity)
                    .allowsHitTesting(false)
            }
            
            VStack {
                // ÜST BAR - Kontroller
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    // OPACITY SLIDER
                    VStack(spacing: 5) {
                        Text(String(format: "Şeffaflık: %.0f%%", opacity * 100))
                            .font(.caption)
                            .foregroundColor(.white)
                        
                        Slider(value: $opacity, in: 0.1...0.9, step: 0.05)
                            .frame(width: 150)
                            .accentColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.3))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    // GRID TOGGLE
                    Button(action: {
                        withAnimation {
                            showGridLines.toggle()
                        }
                    }) {
                        Image(systemName: showGridLines ? "grid" : "grid.circle")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(showGridLines ? .blue : .white)
                            .padding(12)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 60)
                
                Spacer()
                
                // ALT BAR - Çekim butonu
                VStack {
                    if referenceImage != nil {
                        Text("Referans fotoğrafı hizalayın")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                    }
                    
                    Button(action: {
                        camera.capturePhoto { image in
                            capturedImage = image
                            showPhotoPreview = true
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 75, height: 75)
                            
                            Circle()
                                .stroke(Color.white, lineWidth: 4)
                                .frame(width: 85, height: 85)
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { camera.startSession() }
        .onDisappear { camera.stopSession() }
        .fullScreenCover(isPresented: $showPhotoPreview) {
            if let image = capturedImage {
                PhotoPreviewView(image: image, onSave: {
                    camera.savePhotoToGallery(image)
                    dismiss()
                }, onCancel: {
                    showPhotoPreview = false
                })
            }
        }
    }
}

struct GridOverlayView: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let thirdWidth = width / 3
            let thirdHeight = height / 3
            
            Path { path in
                // Dikey çizgiler
                for i in 1...2 {
                    let x = thirdWidth * CGFloat(i)
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                
                // Yatay çizgiler
                for i in 1...2 {
                    let y = thirdHeight * CGFloat(i)
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.white.opacity(0.7), lineWidth: 1)
        }
        .allowsHitTesting(false)
    }
}
