//
//  ContentView.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 25.08.2024.
//
import SwiftUI
import PDFKit
import PencilKit

struct ContentView: View {
    @StateObject var canvasViewModel = CanvasViewModel()
    @State private var isLeftMenuVisible = false
    @State private var isRightMenuVisible = false
    @State private var showPDFView = false
    @State private var showDocumentPicker = false
    private let firestoreManager = FirestoreManager.shared

    var body: some View {
        ZStack {
            // Canvas View
            CanvasView(canvasViewModel: canvasViewModel)
                .edgesIgnoringSafeArea(.all)
                .background(Color(UIColor.systemGray6))

            // Left Side Menu
            if isLeftMenuVisible {
                HStack {
                    VStack(alignment: .leading, spacing: 20) {
                        Spacer().frame(height: 50) // Adjust spacing from top

                        Button(action: {
                            //canvasViewModel.addPostIt()
                        }) {
                            Text("Add Post-it")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            showDocumentPicker = true
                        }) {
                            Text("Load PDF")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                             canvasViewModel.savePDF()
                        }) {
                            Text("Save PDF")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(15)

                    Spacer()
                }
            }

            // Right Side Menu
            if isRightMenuVisible {
                HStack {
                    Spacer()

                    VStack(alignment: .trailing, spacing: 20) {
                        Spacer().frame(height: 50) // Adjust spacing from top

                        Button(action: {
                            firestoreManager.saveDrawingToFirestore(canvasViewModel.canvasView.drawing)
                        }) {
                            Text("Save to Firestore")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Button(action: {
                            firestoreManager.bringDrawingsFromFirestore { drawings in
                                if let drawings = drawings {
                                    var combinedDrawing = PKDrawing()
                                    combinedDrawing = PKDrawing.fromDrawings(drawings)
                                    canvasViewModel.canvasView.drawing = combinedDrawing
                                }
                            }
                        }) {
                            Text("Bring from Firestore")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.brown.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        Spacer()
                    }
                    .padding()
                    .frame(width: 200)
                    .background(Color.purple.opacity(0.2))
                    .cornerRadius(15)
                }
            }

            // Top Bar with Buttons to Toggle Menus
            VStack {
                HStack {
                    Button(action: {
                        withAnimation {
                            isLeftMenuVisible.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 30, height: 20)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }

                    Spacer()

                    Button(action: {
                        withAnimation {
                            isRightMenuVisible.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .resizable()
                            .frame(width: 30, height: 20)
                            .padding()
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(8)
                    }
                }
                Spacer()
            }
            .padding()

        }
        .sheet(isPresented: $showPDFView) {
            PDFViewSwiftUI(canvasViewModel: canvasViewModel)
        }
        .sheet(isPresented: $showDocumentPicker) {
            DocumentPickerView { url in
                canvasViewModel.loadPDF(from: url)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

