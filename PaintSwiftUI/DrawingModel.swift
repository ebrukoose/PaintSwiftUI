//
//  DrawingModel.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 25.08.2024.
//

import Foundation
import SwiftUI
import PencilKit

struct CodablePoint: Codable {
    var x: CGFloat
    var y: CGFloat

    init(_ point: CGPoint) {
        self.x = point.x
        self.y = point.y
    }

    func toCGPoint() -> CGPoint {
        return CGPoint(x: x, y: y)
    }
}

struct CodableColor: Codable {
    var red: CGFloat
    var green: CGFloat
    var blue: CGFloat
    var alpha: CGFloat

    init(color: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    func toUIColor() -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

struct Drawing: Codable {
    var points: [CodablePoint]
    var color: CodableColor
    var lineWidth: CGFloat
}

extension PKDrawing {
    func convertToDrawings() -> [Drawing] {
        var drawings = [Drawing]()

        for stroke in self.strokes {
            let color = CodableColor(color: stroke.ink.color)
            let lineWidth = stroke.path.first?.size.width ?? 1.0

            let points = stroke.path.map { point in
                return CodablePoint(point.location)
            }

            let drawing = Drawing(points: points, color: color, lineWidth: lineWidth)
            drawings.append(drawing)
        }

        return drawings
    }

    static func fromDrawings(_ drawings: [Drawing]) -> PKDrawing {
        var strokes = [PKStroke]()

        for drawing in drawings {
            let strokePoints = drawing.points.map { point -> PKStrokePoint in
                return PKStrokePoint(
                    location: point.toCGPoint(),
                    timeOffset: 0,
                    size: CGSize(width: drawing.lineWidth, height: drawing.lineWidth),
                    opacity: 1,
                    force: 1,
                    azimuth: .zero,
                    altitude: .zero
                )
            }

            let strokePath = PKStrokePath(controlPoints: strokePoints, creationDate: Date())
            let ink = PKInk(.pen, color: drawing.color.toUIColor())
            let stroke = PKStroke(ink: ink, path: strokePath)
            strokes.append(stroke)
        }

        return PKDrawing(strokes: strokes)
    }
}
