//
//  KohanaTextField.swift
//  KohanaTextField
//
//  Created by Natan Grando on 3/30/17.
//  Copyright © 2017. All rights reserved.
//

import UIKit

@IBDesignable
public class KohanaTextField: UIView {
    
    private var imageView: UIImageView?
    private var placeholderLabel: UILabel?
    private var textField: UITextField?
    private var toggleSecureTextButton: UIButton?
    
    public var textFieldDelegate: UITextFieldDelegate?
    
    fileprivate var placeholderVisible: Bool = true {
        willSet {
            if placeholderVisible != newValue {
                newValue ? showPlaceholder(animated: true) : hidePlaceholder(animated: true)
            }
        }
    }
    
    @IBInspectable
    public var image: UIImage? {
        didSet {
            imageView?.image = image
        }
    }
    
    @IBInspectable
    public var text: String? {
        set {
            textField?.text = newValue
            if (text?.isEmpty ?? true) {
                showPlaceholder(animated: false)
            } else {
                hidePlaceholder(animated: false)
            }
        }
        get {
            return textField?.text
        }
    }
    
    @IBInspectable
    public var textColor: UIColor = UIColor(red: 75/255, green: 68/255, blue: 54/255, alpha: 1) {
        didSet {
            textField?.textColor = textColor
        }
    }
    
    @IBInspectable
    public var textFontSize: CGFloat = 15 {
        didSet {
            textField?.font = UIFont.systemFont(ofSize: textFontSize)
        }
    }
    
    @IBInspectable
    public var placeholder: String? {
        didSet {
            placeholderLabel?.text = placeholder
        }
    }
    
    @IBInspectable
    public var placeholderTextColor: UIColor = UIColor(red: 168/255, green: 164/255, blue: 155/255, alpha: 1) {
        didSet {
            placeholderLabel?.textColor = placeholderTextColor
        }
    }
    
    @IBInspectable
    public var placeholderTextFontSize: CGFloat = 15 {
        didSet {
            placeholderLabel?.font = UIFont.systemFont(ofSize: placeholderTextFontSize)
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor(red: 233/255, green: 232/255, blue: 229/255, alpha: 1) {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    public var borderRadius: CGFloat = 4 {
        didSet {
            layer.borderWidth = borderRadius
        }
    }
    
    @IBInspectable
    public var isSecureTextEntry: Bool = false {
        didSet {
            textField?.isSecureTextEntry = isSecureTextEntry
            
            let title = isSecureTextEntry ? showText : hideText
            toggleSecureTextButton?.setTitle(title, for: .normal)
            setNeedsLayout()
        }
    }
    
    @IBInspectable
    public var toggleSecureTextButtonVisible: Bool = false {
        didSet {
            if toggleSecureTextButtonVisible {
                initToggleSecureTextButton()
            } else {
                toggleSecureTextButton?.removeFromSuperview()
            }
        }
    }
    
    @IBInspectable
    public var toggleSecureTextButtonFontSize: CGFloat = 10 {
        didSet {
            toggleSecureTextButton?.titleLabel?.font = UIFont.systemFont(ofSize: toggleSecureTextButtonFontSize)
        }
    }
    
    @IBInspectable
    public var showText: String = "SHOW"
    
    @IBInspectable
    public var hideText: String = "HIDE"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let placeholderRect = CGRect(x: 12, y: bounds.height/2 - 10, width: bounds.width - 24, height: 20)
        placeholderLabel?.frame = placeholderRect
        
        let imageViewRect = CGRect(x: 12, y: bounds.height/2 - 10, width: 20, height: 20)
        imageView?.frame = imageViewRect
        
        if toggleSecureTextButtonVisible {
            toggleSecureTextButton?.sizeToFit()
            let buttonWidth = toggleSecureTextButton?.bounds.width ?? 0
            let buttonRect = CGRect(x: bounds.width - buttonWidth - 12, y: 0, width: buttonWidth, height: bounds.height)
            toggleSecureTextButton?.frame = buttonRect
            let textFieldRect = CGRect(x: 44, y: 0, width: bounds.width - 68 - buttonWidth, height: bounds.height)
            textField?.frame = textFieldRect
        } else {
            let textFieldRect = CGRect(x: 44, y: 0, width: bounds.width - 56, height: bounds.height)
            textField?.frame = textFieldRect
        }
    }
    
    private func commonInit() {
        initImageView()
        initPlaceholderLabel()
        initTextField()
        addClickRecognizer()
        addBorder()
        clipsToBounds = true
    }
    
    private func initImageView() {
        let rect = CGRect(x: 12, y: bounds.height/2 - 10, width: 20, height: 20)
        imageView = UIImageView(frame: rect)
        imageView?.alpha = 0
        addSubview(imageView!)
    }
    
    private func initPlaceholderLabel() {
        placeholderLabel = UILabel(frame: frame)
        placeholderLabel?.textColor = UIColor(red: 168/255, green: 164/255, blue: 155/255, alpha: 1)
        addSubview(placeholderLabel!)
    }
    
    private func initTextField() {
        let rect = CGRect(x: 44, y: 0, width: bounds.width - 56, height: bounds.height)
        textField = UITextField(frame: rect)
        textField?.delegate = self
        textField?.alpha = 0
        textField?.textColor = UIColor(red: 75/255, green: 68/255, blue: 54/255, alpha: 1)
        addSubview(textField!)
    }
    
    private func initToggleSecureTextButton() {
        let rect = CGRect(x: 44, y: 0, width: bounds.width - 56, height: bounds.height)
        toggleSecureTextButton = UIButton(frame: rect)
        toggleSecureTextButton?.alpha = 0
        toggleSecureTextButton?.setTitleColor(UIColor(red: 75/255, green: 68/255, blue: 54/255, alpha: 1), for: .normal)
        let title = isSecureTextEntry ? showText : hideText
        toggleSecureTextButton?.setTitle(title, for: .normal)
        toggleSecureTextButton?.addTarget(self, action: #selector(showSecureTextClicked), for: .touchUpInside)
        toggleSecureTextButton?.titleLabel?.font = UIFont.systemFont(ofSize: toggleSecureTextButtonFontSize)
        addSubview(toggleSecureTextButton!)
    }
    
    private func addClickRecognizer() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(requestFocus))
        addGestureRecognizer(gestureRecognizer)
    }
    
    private func addBorder() {
        layer.cornerRadius = 4
        layer.borderColor = UIColor(red: 233/255, green: 232/255, blue: 229/255, alpha: 1).cgColor
        layer.borderWidth = 1
    }
    
    private func showPlaceholder(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.3) {
                self.showPlaceholder(animated: false)
            }
        } else {
            self.imageView?.alpha = 0
            self.imageView?.frame.origin.x = -20
            self.textField?.alpha = 0
            self.toggleSecureTextButton?.alpha = 0
            self.placeholderLabel?.frame.origin.x = 12
            self.placeholderLabel?.alpha = 1
        }
    }
    
    private func hidePlaceholder(animated: Bool) {
        if (animated) {
            UIView.animate(withDuration: 0.3) {
                self.hidePlaceholder(animated: false)
            }
        } else {
            self.placeholderLabel?.frame.origin.x = 44
            self.placeholderLabel?.alpha = 0
            self.imageView?.frame.origin.x = 12
            self.imageView?.alpha = 1
            self.textField?.alpha = 1
            self.toggleSecureTextButton?.alpha = 1
        }
    }
    
    func showSecureTextClicked() {
        isSecureTextEntry = !isSecureTextEntry
    }
    
    override func becomeFirstResponder() -> Bool {
        return textField?.becomeFirstResponder() ?? false
    }
}


extension KohanaTextField: UITextFieldDelegate {
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        placeholderVisible = false
        textFieldDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty ?? true {
            placeholderVisible = true
        }
        textFieldDelegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    @available(iOS 10.0, *)
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.text?.isEmpty ?? true {
            placeholderVisible = true
        }
        textFieldDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textFieldDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return textFieldDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return  textFieldDelegate?.textFieldShouldReturn?(textField) ?? true
    }
}
