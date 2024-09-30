//
//  CanvasViewModel.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 28.08.2024.
//


import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers

class CanvasViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
   

    @Published var canvasView = PKCanvasView()
    @Published var pdfDocument: PDFDocument!
    var canvasViews: [Int: PKCanvasView] = [:] // Her sayfa için ayrı canvas saklanıyor

    override init() {
        super.init()
        setupCanvasView()
    }

    func setupCanvasView() {
        canvasView.drawingPolicy = .anyInput
    }


 



    func loadPDF(from url: URL) {
        if let pdfDocument = PDFDocument(url: url) {
            self.pdfDocument = pdfDocument
         
        }
    }

    
    

    func addPostIt() {
        let postItView = PostItView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(postItView)
        }
    }

    func savePDF() {
        guard let pdfDocument = pdfDocument else {
            print("PDF document is nil")
            return
        }

        let pageCount = pdfDocument.pageCount

        // Geçici dosya konumunu oluştur
        let temporaryDirectory = FileManager.default.temporaryDirectory
        let fileURL = temporaryDirectory.appendingPathComponent("annotated.pdf")

        // PDF Renderer oluşturuluyor
        let renderer = UIGraphicsPDFRenderer(bounds: pdfDocument.page(at: 0)!.bounds(for: .mediaBox))

        let pdfData = renderer.pdfData { context in
            // Her sayfa için işlem yap
            for pageIndex in 0..<pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else {
                    print("Failed to get page \(pageIndex)")
                    continue
                }

                // Yeni bir PDF sayfası başlat
                context.beginPage(withBounds: page.bounds(for: .mediaBox), pageInfo: [:])

                // Orijinal PDF sayfasını çizdir
                page.draw(with: .mediaBox, to: context.cgContext)

                // İlk sayfa için çizim yap
                if pageIndex == 0 {
                    // Çizim işlemi için bağlamı kaydedin
                    context.cgContext.saveGState()

                    // Y ekseni ters çevirmesini kaldırın ve bağlamı düz çizin
                    context.cgContext.translateBy(x: 0, y: page.bounds(for: .mediaBox).height)
                    context.cgContext.scaleBy(x: 1.0, y: -1.0)

                    // Çizimi ekleyin
                    let canvasFrame = CGRect(x: 0, y: 0, width: page.bounds(for: .mediaBox).width, height: page.bounds(for: .mediaBox).height)
                    let canvasImage = canvasView.drawing.image(from: canvasView.bounds, scale: 1.0)

                    // Görüntüyü doğru şekilde çizin
                    context.cgContext.draw(canvasImage.cgImage!, in: canvasFrame)

                    // Bağlamı eski haline döndürün
                    context.cgContext.restoreGState()
                }
            }
        }

        // PDF dosyasını kaydet
        do {
            try pdfData.write(to: fileURL)
            print("PDF başarıyla kaydedildi: \(fileURL.path)")
            presentDocumentPicker(for: fileURL)
        } catch {
            print("PDF kaydedilirken hata oluştu: \(error)")
        }
    }




    // UIDocumentPickerViewController'ı kullanarak dosyayı seçilen konuma kaydetme
    func presentDocumentPicker(for fileURL: URL) {
        let documentPicker = UIDocumentPickerViewController(forExporting: [fileURL], asCopy: true)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        
        // UIViewController içinde bu metodun çağrılması gerekiyor
        if let topController = UIApplication.shared.windows.first?.rootViewController {
            topController.present(documentPicker, animated: true, completion: nil)
        }
    }

    // UIDocumentPickerDelegate Metodları
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let url = urls.first {
            print("Dosya başarıyla kaydedildi: \(url.path)")
        }
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Kullanıcı dosya kaydetme işlemini iptal etti.")
    }
}







/*
import SwiftUI
import PDFKit
import PencilKit
import UniformTypeIdentifiers
class CanvasViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var canvasView = PKCanvasView()
    @Published var pdfDocument: PDFDocument?

    override init() {
        super.init()
        setupCanvasView()
    }

    func setupCanvasView() {
        canvasView.drawingPolicy = .anyInput // Only use the Apple Pencil for drawing
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
    }

    func loadPDF(from url: URL) {
        if let pdfDocument = PDFDocument(url: url) {
            self.pdfDocument = pdfDocument
        }
    }

    func addPostIt() {
        let postItView = PostItView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(postItView)
        }
    }

    func savePDF() {
        guard let pdfDocument = pdfDocument else {
            print("PDF document is nil")
            return
        }
        
        let pageCount = pdfDocument.pageCount
        for pageIndex in 0..<pageCount {
            guard let page = pdfDocument.page(at: pageIndex) else {
                print("Failed to get page \(pageIndex)")
                continue
            }

            // PDF Renderer oluşturuluyor
            let renderer = UIGraphicsPDFRenderer(bounds: page.bounds(for: .mediaBox))
            let pdfData = renderer.pdfData { context in
                context.beginPage()
                page.draw(with: .mediaBox, to: context.cgContext)

                // Ana iş parçacığında çizim işlemi, async kullanılarak bloke edilmeden yapılır
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    // canvasView doğrudan erişim sağlanarak çizim yapılır
                    self.canvasView.drawHierarchy(in: page.bounds(for: .mediaBox), afterScreenUpdates: true)
                }
            }

            let fileName = "annotated.pdf"
            if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentsDirectory.appendingPathComponent(fileName)
                do {
                    try pdfData.write(to: fileURL)
                    print("PDF başarıyla kaydedildi: \(fileURL.path)")
                } catch {
                    print("PDF kaydedilirken hata oluştu: \(error)")
                }
            }
        }
    }


      
   }
*/



/*  save fonksiyonunu değiştirmeden önceki hali

import SwiftUI
import PDFKit
import PencilKit

class CanvasViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var canvasView = PKCanvasView()
    @Published var pdfDocument: PDFDocument?

    override init() {
        super.init()
        setupCanvasView()
    }

    func setupCanvasView() {
        canvasView.drawingPolicy = .anyInput // Only use the Apple Pencil for drawing
        canvasView.isOpaque = false
        canvasView.backgroundColor = .clear
    }

    func loadPDF(from url: URL) {
        
        if let pdfDocument = PDFDocument(url: url) {
            self.pdfDocument = pdfDocument
        }
        
    }

    func addPostIt() {
        let postItView = PostItView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(postItView)
        }
    }

    func savePDF() {
            guard let pdfDocument = pdfDocument else { return }
            let pageCount = pdfDocument.pageCount
            for pageIndex in 0..<pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }

                let renderer = UIGraphicsPDFRenderer(bounds: page.bounds(for: .mediaBox))
                let pdfData = renderer.pdfData { context in
                    context.beginPage()
                    page.draw(with: .mediaBox, to: context.cgContext)
                    canvasView.drawHierarchy(in: page.bounds(for: .mediaBox), afterScreenUpdates: true)
                }

                let fileName = "annotated.pdf"
                // Documents klasörüne kaydetmek için yol oluştur
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    do {
                        try pdfData.write(to: fileURL)
                        print("PDF başarıyla kaydedildi: \(fileURL.path)")
                    } catch {
                        print("PDF kaydedilirken hata oluştu: \(error)")
                    }
                }
            }
        }
}


*/




/*
import SwiftUI
import PDFKit
import PencilKit

class CanvasViewModel: NSObject, ObservableObject, UIDocumentPickerDelegate {
    @Published var canvasView = PKCanvasView()
    @Published var pdfDocument: PDFDocument?

    override init() {
        super.init()
        setupCanvasView()
    }

    func setupCanvasView() {
        canvasView.drawingPolicy = .anyInput
    }

    func loadPDF(from url: URL) {
        if let pdfDocument = PDFDocument(url: url) {
            self.pdfDocument = pdfDocument
        }
    }

    func addPostIt() {
        let postItView = PostItView(frame: CGRect(x: 100, y: 100, width: 150, height: 150))
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.addSubview(postItView)
        }
    }
    func savePDF() {
            guard let pdfDocument = pdfDocument else { return }
            let pageCount = pdfDocument.pageCount
            for pageIndex in 0..<pageCount {
                guard let page = pdfDocument.page(at: pageIndex) else { continue }

                let renderer = UIGraphicsPDFRenderer(bounds: page.bounds(for: .mediaBox))
                let pdfData = renderer.pdfData { context in
                    context.beginPage()
                    page.draw(with: .mediaBox, to: context.cgContext)
                    canvasView.drawHierarchy(in: page.bounds(for: .mediaBox), afterScreenUpdates: true)
                }

                let fileName = "annotated.pdf"
                // Documents klasörüne kaydetmek için yol oluştur
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let fileURL = documentsDirectory.appendingPathComponent(fileName)
                    do {
                        try pdfData.write(to: fileURL)
                        print("PDF başarıyla kaydedildi: \(fileURL.path)")
                    } catch {
                        print("PDF kaydedilirken hata oluştu: \(error)")
                    }
                }
            }
        }

}

*/
