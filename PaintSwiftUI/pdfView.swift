//
//  pdfView.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 27.08.2024.
//



import SwiftUI

struct PDFViewSwiftUI: View {
    @ObservedObject var canvasViewModel: CanvasViewModel

    var body: some View {
        VStack {
            Button(action: {
                canvasViewModel.savePDF()
            }) {
                Text("Save PDF")
                    .padding()
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            CanvasView(canvasViewModel: canvasViewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}





/*
import SwiftUI
import PDFKit
import PencilKit

struct PDFViewContainer: View {
    @ObservedObject var canvasViewModel: CanvasViewModel

    var body: some View {
        ZStack {
            // PDFView
            PDFViewWrapper(canvasViewModel: canvasViewModel)
                .edgesIgnoringSafeArea(.all)

            // Tool Picker
            ToolPickerView(canvasViewModel: canvasViewModel)
        }
    }
}

struct PDFViewWrapper: UIViewRepresentable {
    @ObservedObject var canvasViewModel: CanvasViewModel
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()

        // PDFView'i oluştur ve ekle
        let pdfView = PDFView()
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        containerView.addSubview(pdfView)

        // Kısıtlamaları ayarla
        NSLayoutConstraint.activate([
            pdfView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: containerView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        // PDF document'ı ayarla
        pdfView.document = canvasViewModel.pdfDocument

        return containerView
    }


    func updateUIView(_ uiView: UIView, context: Context) {
        if let pdfView = uiView.subviews.first(where: { $0 is PDFView }) as? PDFView {
            pdfView.document = canvasViewModel.pdfDocument
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: PDFViewWrapper

        init(_ parent: PDFViewWrapper) {
            self.parent = parent
        }

        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            if gesture.state == .began || gesture.state == .changed {
                if let pdfView = parent.canvasViewModel.canvasView.superview?.subviews.first(where: { $0 is PDFView }) as? PDFView {
                    if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                        let translation = gesture.translation(in: scrollView)
                        scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x - translation.x,
                                                          y: scrollView.contentOffset.y - translation.y)
                        gesture.setTranslation(.zero, in: scrollView)
                    }
                }
            }
        }

        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            if gesture.state == .began || gesture.state == .changed {
                if let pdfView = parent.canvasViewModel.canvasView.superview?.subviews.first(where: { $0 is PDFView }) as? PDFView {
                    if let scrollView = pdfView.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
                        scrollView.zoomScale *= gesture.scale
                        gesture.scale = 1.0
                    }
                }
            }
        }
    }
}

struct ToolPickerView: UIViewRepresentable {
    @ObservedObject var canvasViewModel: CanvasViewModel

    func makeUIView(context: Context) -> UIView {
        let toolPickerContainer = UIView()
        let toolPicker = PKToolPicker()
        toolPicker.addObserver(canvasViewModel.canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasViewModel.canvasView)
        canvasViewModel.canvasView.becomeFirstResponder()
        return toolPickerContainer
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
*/
