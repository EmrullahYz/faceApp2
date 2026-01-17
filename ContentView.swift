//
//  ContentView.swift
//  FaceApp2
//
//  Created by Emrullah Yılmaz on 17.01.2026.
//



import SwiftUI

struct ContentView: View {
    @State private var showPicker = false
    @State private var referenceImage: UIImage? = nil
    @State private var openCamera = false
    @State private var openCameraWithoutReference = false
    @State private var showPhotoPreview = false
    @State private var capturedImage: UIImage? = nil
    
    var body: some View {
        NavigationView {
            ZStack {
                // Arka plan gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.purple.opacity(0.1)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // BAŞLIK
                    VStack(spacing: 8) {
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .padding(.bottom, 5)
                        
                        Text("FaceFoto Ghost Overlay")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Referans fotoğraf ile mükemmel çekimler yapın")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 40)
                    
                    // REFERANS FOTOĞRAF KARTI
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "photo.stack")
                            Text("Referans Fotoğraf")
                                .font(.headline)
                        }
                        .foregroundColor(.blue)
                        
                        if let img = referenceImage {
                            // Fotoğraf önizleme
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                                )
                            
                            // Butonlar
                            HStack(spacing: 15) {
                                Button(action: {
                                    showPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "arrow.triangle.2.circlepath")
                                        Text("Değiştir")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(10)
                                }
                                
                                Button(action: {
                                    openCamera = true
                                }) {
                                    HStack {
                                        Image(systemName: "camera.fill")
                                        Text("Devam Et")
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                                }
                            }
                        } else {
                            // Fotoğraf seçilmediyse
                            VStack(spacing: 20) {
                                Image(systemName: "photo.on.rectangle.angled")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                Text("Henüz referans fotoğraf seçilmedi")
                                    .foregroundColor(.secondary)
                                
                                Button(action: {
                                    showPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "photo")
                                        Text("Fotoğraf Seç")
                                    }
                                    .padding(.horizontal, 30)
                                    .padding(.vertical, 15)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .shadow(color: .blue.opacity(0.3), radius: 5, y: 3)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 2, dash: [10]))
                            )
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal)
                    
                    // VEYA SEPARATOR
                    HStack {
                        VStack { Divider() }
                        Text("veya")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 10)
                        VStack { Divider() }
                    }
                    .padding(.horizontal)
                    
                    // DİREKT KAMERA KARTI
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Direkt Kamera ile Çek")
                                .font(.headline)
                        }
                        .foregroundColor(.green)
                        
                        Text("Referans fotoğraf olmadan direkt çekim yapabilirsiniz")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 10)
                        
                        Button(action: {
                            openCameraWithoutReference = true
                        }) {
                            HStack {
                                Image(systemName: "camera.shutter.button")
                                Text("Kamerayı Aç")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(color: .green.opacity(0.3), radius: 5, y: 3)
                        }
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showPicker) {
                PhotoPicker(selectedImage: $referenceImage)
            }
            .fullScreenCover(isPresented: $openCamera) {
                if let referenceImage = referenceImage {
                    CameraView(referenceImage: referenceImage, showGrid: true)
                }
            }
            .fullScreenCover(isPresented: $openCameraWithoutReference) {
                CameraView(referenceImage: nil, showGrid: true)
            }
            .fullScreenCover(isPresented: $showPhotoPreview) {
                if let image = capturedImage {
                    PhotoPreviewView(image: image, onSave: {
                        saveImageToGallery(image)
                        showPhotoPreview = false
                    }, onCancel: {
                        showPhotoPreview = false
                    })
                }
            }
        }
    }
    
    private func saveImageToGallery(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

struct PhotoPreviewView: View {
    let image: UIImage
    let onSave: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Fotoğraf önizleme
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                
                // Butonlar
                HStack(spacing: 20) {
                    Button(action: onCancel) {
                        HStack {
                            Image(systemName: "xmark")
                            Text("İptal")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    
                    Button(action: onSave) {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Kaydet")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
