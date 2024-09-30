//
//  CanvasView.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 25.08.2024.
//


import SwiftUI

struct CanvasView: UIViewControllerRepresentable {
    @ObservedObject var canvasViewModel: CanvasViewModel

    func makeUIViewController(context: Context) -> CanvasViewController {
        return CanvasViewController(canvasViewModel: canvasViewModel)
    }

    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
        if let pdfDocument = canvasViewModel.pdfDocument {
            uiViewController.pdfView.document = pdfDocument
        }
    }
}






