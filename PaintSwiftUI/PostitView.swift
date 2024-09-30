//
//  PostitView.swift
//  PaintSwiftUI
//
//  Created by EBRU KÖSE on 27.08.2024.
//

import SwiftUI

class PostItView: UIView {
    private let textField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = .clear
        textField.textColor = .black
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.placeholder = "Type something..."
        textField.isUserInteractionEnabled = true // Ensure textField is interactable
        return textField
    }()

    private let toolBar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "OK", style: .done, target: PostItView.self, action: #selector(doneButtonTapped))
        toolBar.setItems([doneButton], animated: false)
        return toolBar
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.systemPink.withAlphaComponent(0.8)
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        setupTextField()
        setupPanGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextField() {
        textField.frame = bounds.insetBy(dx: 10, dy: 10)
        textField.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textField.inputAccessoryView = toolBar
        addSubview(textField)
    }

    private func setupPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        gesture.setTranslation(.zero, in: superview)
    }

    @objc private func doneButtonTapped() {
        textField.resignFirstResponder()
    }
}





#Preview {
    PostItView()
}
