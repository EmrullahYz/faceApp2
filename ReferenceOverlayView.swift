//
//  Untitled.swift
//  FaceApp2
//
//  Created by Emrullah Yılmaz on 17.01.2026.
//

//
//  ReferenceOverlayView.swift
//  FaceFotoV2
//
//  Created by Emrullah Yılmaz on 30.11.2025.
//

import SwiftUI

struct ReferenceOverlayView: View {
    var image: UIImage
    var opacity: Double
    
    var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .blendMode(.screen)
            .opacity(opacity)
            .allowsHitTesting(false)
    }
}
