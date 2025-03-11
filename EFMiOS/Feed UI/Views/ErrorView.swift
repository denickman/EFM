//
//  ErrorView.swift
//  EFMiOS
//
//  Created by Denis Yaremenko on 11.03.2025.
//

import UIKit

public final class ErrorView: UIView {
    
    @IBOutlet private var label: UILabel!
    
    public var message: String? {
        get { isVisible ? label.text : nil }
        set { setMessageAnimated(newValue) }
    }
    
    private var isVisible: Bool { alpha > 0 }
    
    private func setMessageAnimated(_ message: String?) {
        if let message {
            showMessage(message)
        } else {
            hideMessage()
        }
    }
    
    private func showMessage(_ message: String) {
        label.text = message
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
    
    private func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed { self.label.text = nil }
            })
    }
}
