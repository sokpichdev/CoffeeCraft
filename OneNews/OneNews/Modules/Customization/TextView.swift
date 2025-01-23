//
//  TextView.swift
//  OneNews
//
//  Created by Sok Pich on 1/21/25.
//

import SwiftUI
import UIKit

struct TextView: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var padding: CGFloat = 16.0

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.isScrollEnabled = true
        textView.backgroundColor = UIColor.optionBtn1
        textView.textColor = UIColor.placeholderText
        textView.text = placeholder
        textView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        textView.textContainer.lineFragmentPadding = 0
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = UIColor.placeholderText
        } else {
            uiView.text = text
            uiView.textColor = UIColor.label
        }
        uiView.textContainerInset = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextView

        init(_ parent: TextView) {
            self.parent = parent
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = UIColor.label
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = UIColor.placeholderText
            }
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }
    }
}
