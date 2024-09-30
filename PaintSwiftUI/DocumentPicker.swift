//
//  DocumentPicker.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 28.08.2024.
//

import SwiftUI
import UIKit

struct DocumentPickerView: UIViewControllerRepresentable {
    var completionHandler: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf], asCopy: true)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(completionHandler: completionHandler)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var completionHandler: (URL) -> Void

        init(completionHandler: @escaping (URL) -> Void) {
            self.completionHandler = completionHandler
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                completionHandler(url)
            }
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            print("Document picker was cancelled.")
        }
    }
}
