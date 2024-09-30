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






