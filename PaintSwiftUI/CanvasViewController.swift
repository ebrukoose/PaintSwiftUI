//
//  CanvasViewController.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 28.08.2024.
//

import SwiftUI
import PDFKit
import PencilKit

class CanvasViewController: UIViewController, PKToolPickerObserver, UIScrollViewDelegate,PDFViewDelegate {
    
    
    var canvasViewModel: CanvasViewModel
    var pdfView: PDFView!
    var canvasView: PKCanvasView!
    var toolPicker: PKToolPicker!
    var isToolPickerVisible = true // ToolPicker initially visible
    
    
    // ScrollView for both PDF and Canvas
    var sharedScrollView: UIScrollView!
    
    init(canvasViewModel: CanvasViewModel) {
        self.canvasViewModel = canvasViewModel
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        // Set up the shared ScrollView for both PDFView and CanvasView  eklemeler bunun üstündekiler
        sharedScrollView = UIScrollView()
        sharedScrollView.delegate = self
        //  sharedScrollView.minimumZoomScale = 1.0
        // sharedScrollView.maximumZoomScale = 3.0
        sharedScrollView.bounces = false
        sharedScrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sharedScrollView)
        
        // Create and add PDFView inside the scrollView
        pdfView = PDFView(frame: .zero)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.translatesAutoresizingMaskIntoConstraints = false
        pdfView.isUserInteractionEnabled = false
        sharedScrollView.addSubview(pdfView)
        
        // Create and add PKCanvasView inside the scrollView
        canvasView = canvasViewModel.canvasView
        canvasView.backgroundColor = .clear
        
        
        
        canvasView.translatesAutoresizingMaskIntoConstraints = false
        sharedScrollView.addSubview(canvasView)
        
        // Set constraints for scrollView, PDFView, and CanvasView
        NSLayoutConstraint.activate([
            sharedScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sharedScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sharedScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            sharedScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            pdfView.leadingAnchor.constraint(equalTo: sharedScrollView.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: sharedScrollView.trailingAnchor),
            pdfView.topAnchor.constraint(equalTo: sharedScrollView.topAnchor),
            pdfView.bottomAnchor.constraint(equalTo: sharedScrollView.bottomAnchor),
            pdfView.widthAnchor.constraint(equalToConstant: 2000), // Adjust size as needed
            pdfView.heightAnchor.constraint(equalToConstant: 2000), // Adjust size as needed
            
            
            canvasView.leadingAnchor.constraint(equalTo: pdfView.leadingAnchor),// bunlar shared değil pdfview di
            canvasView.trailingAnchor.constraint(equalTo: pdfView.trailingAnchor),
            canvasView.topAnchor.constraint(equalTo: pdfView.topAnchor),
            canvasView.bottomAnchor.constraint(equalTo: pdfView.bottomAnchor),
            
        ])
        
        // Initialize ToolPicker
        toolPicker = PKToolPicker()
        toolPicker.addObserver(canvasView)
        toolPicker.setVisible(true, forFirstResponder: canvasView) // Initially visible
        canvasView.becomeFirstResponder()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keepToolPickerVisible), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateToolPickerVisibility), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        
        
        // Add and position pen button
        let penButton = UIButton(type: .system)
        penButton.setImage(UIImage(systemName: "pencil"), for: .normal)
        penButton.translatesAutoresizingMaskIntoConstraints = false
        penButton.addTarget(self, action: #selector(toggleToolPicker), for: .touchUpInside)
        view.addSubview(penButton)
        
        // Set constraints for pen button
        NSLayoutConstraint.activate([
            penButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            penButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            penButton.widthAnchor.constraint(equalToConstant: 40),
            penButton.heightAnchor.constraint(equalToConstant: 40)
        ])
        //   updateCanvasSize()
    }
   
    
    @objc private func keepToolPickerVisible() {
        if isToolPickerVisible {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    @objc private func updateToolPickerVisibility() {
        if isToolPickerVisible {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
        }
    }
    
    @objc private func toggleToolPicker() {
        isToolPickerVisible.toggle()
        if isToolPickerVisible {
            // Show ToolPicker and disable scroll gestures, enable drawing
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            canvasView.becomeFirstResponder()
            canvasView.isUserInteractionEnabled = true
            sharedScrollView.isScrollEnabled = false // Disable scrolling when drawing
            canvasView.drawingPolicy = .anyInput // Allow drawing only with Pencil
        } else {
            // Hide ToolPicker, enable scrolling/zooming, disable drawing
            toolPicker.setVisible(false, forFirstResponder: canvasView)
            canvasView.resignFirstResponder()
            canvasView.isUserInteractionEnabled = false
            sharedScrollView.isScrollEnabled = true // Enable scrolling when not drawing
            // canvasView.drawingPolicy = .pencilOnly // Disable drawing completely
        }
    }
    
    // UIScrollViewDelegate method to allow zooming
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return pdfView// Zoom PDF and canvas together
        
    }
}







