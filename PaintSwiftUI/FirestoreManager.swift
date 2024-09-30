//
//  FirestoreManager.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 25.08.2024.
//
import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import PencilKit

class FirestoreManager: NSObject {
    let firestore: Firestore
    static let shared = FirestoreManager()
    
    private override init() {
        FirebaseApp.configure()
        self.firestore = Firestore.firestore()
        super.init()
    }

    func saveDrawingToFirestore(_ pkDrawing: PKDrawing) {
        let drawings = pkDrawing.convertToDrawings()
        
        do {
            let drawingData = try JSONEncoder().encode(drawings)
            let drawingDict = try JSONSerialization.jsonObject(with: drawingData, options: []) as? [[String: Any]]
            
            let db = Firestore.firestore()
            let drawingRef = db.collection("drawings").document()
            
            let timestamp = Timestamp(date: Date())
            let dateFormatter = ISO8601DateFormatter()
            let timestampString = dateFormatter.string(from: timestamp.dateValue())
            
            let dataToSave: [String: Any] = [
                "drawings": drawingDict ?? [],
                "timestamp": timestampString
            ]
            
            drawingRef.setData(dataToSave) { error in
                if let error = error {
                    print("Error saving drawing: \(error.localizedDescription)")
                } else {
                    print("Drawing saved successfully!")
                }
            }
        } catch {
            print("Error encoding drawing: \(error.localizedDescription)")
        }
    }
    
    func bringDrawingsFromFirestore(completion: @escaping ([Drawing]?) -> Void) {
        let db = Firestore.firestore()
        
        db.collection("drawings")
            .order(by: "timestamp", descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Error getting drawings: \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    print("No drawings found")
                    completion(nil)
                    return
                }
                
                do {
                    let drawings = try documents.compactMap { document -> [Drawing]? in
                        let data = document.data()
                        
                        guard let drawingArray = data["drawings"] as? [[String: Any]] else {
                            print("Drawing array not found in Firestore document")
                            return nil
                        }
                        
                        let jsonData = try JSONSerialization.data(withJSONObject: drawingArray, options: [])
                        return try JSONDecoder().decode([Drawing].self, from: jsonData)
                    }.flatMap { $0 }
                    
                    completion(drawings)
                } catch {
                    print("Error decoding drawing: \(error.localizedDescription)")
                    completion(nil)
                }
            }
    }
}

