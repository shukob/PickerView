//
//  PickerView.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

open class PickerView: UITextField {
    @IBInspectable open var top: CGFloat = 0
    @IBInspectable open var left: CGFloat = 0
    @IBInspectable open var bottom: CGFloat = 0
    @IBInspectable open var right: CGFloat = 0
    
    @IBInspectable open var normalBorderColor: UIColor? = nil
    @IBInspectable open var highlightBorderColor: UIColor? = nil
    
    @IBInspectable open var normalBackgroundImage: UIImage? = nil
    @IBInspectable open var highlightBackgroundImage: UIImage? = nil

    public var source: PickerViewSource? {
        didSet {
            updateTitle()
        }
    }
    
    public var beginEditing: (() -> Void)?
    public var endEditing: ((PickerViewSource.PickerViewComponentsInformation) -> Void)?
    
    static var screenWidth: CGFloat {
        return UIApplication.shared.keyWindow?.bounds.width ?? UIScreen.main.bounds.width
    }
    
    fileprivate var pickerView: UIPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
            inputView = pickerView
        }
    }
    
    fileprivate var toolbar: UIToolbar! {
        didSet {
            let flexibleSpaceItem = UIBarButtonItem(
                barButtonSystemItem: .flexibleSpace,
                target: nil,
                action: nil
            )
            let completionButtonItem = UIBarButtonItem(
                title: "完了",
                style: .plain,
                target: self,
                action: #selector(tapCompletionButton(_:))
            )
            
            toolbar.items = [flexibleSpaceItem, completionButtonItem]
            toolbar.frame = CGRect(
                x: 0,
                y: 0,
                width: PickerView.screenWidth,
                height: 44
            )
            
            inputAccessoryView = toolbar
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 長押しで表示されるメニューを非表示
        UIMenuController.shared.isMenuVisible = false
        return false
    }
    
    open override func textRect(forBounds bounds: CGRect) -> CGRect {
        return textFieldRect(forBounds: bounds)
    }
    
    open override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textFieldRect(forBounds: bounds)
    }
    
    open override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return textFieldRect(forBounds: bounds)
    }
    
    open override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let leftViewBounds = leftView?.bounds else {
            return .zero
        }
        
        let y = bounds.height / 2.0 - leftViewBounds.height / 2.0
        return CGRect(
            x: bounds.minX + left,
            y: y < 0 ? 0 : y,
            width: leftViewBounds.width,
            height: leftViewBounds.height
        )
    }
    
    open override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        guard let rightViewBounds = rightView?.bounds else {
            return .zero
        }
        
        let y = bounds.height / 2.0 - rightViewBounds.height / 2.0
        return CGRect(
            x: bounds.maxX - right - rightViewBounds.width,
            y: y < 0 ? 0 : y,
            width: rightViewBounds.width,
            height: rightViewBounds.height
        )
    }
}

// MARK: UIPickerView
extension PickerView {
    open var numberOfComponents: Int {
        return pickerView.numberOfComponents
    }
    
    open func numberOfRows(inComponent component: Int) -> Int {
        return pickerView.numberOfRows(inComponent: component)
    }
    
    open func rowSize(forComponent component: Int) -> CGSize {
        return pickerView.rowSize(forComponent: component)
    }
    
    open func view(forRow row: Int, forComponent component: Int) -> UIView? {
        return pickerView.view(forRow: row, forComponent: component)
    }
    
    open func reloadAllComponents() {
        return pickerView.reloadAllComponents()
    }
    
    open func reloadComponent(_ component: Int) {
        return pickerView.reloadComponent(component)
    }
    
    open func selectRow(_ row: Int, inComponent component: Int, animated: Bool) {
        pickerView.selectRow(row, inComponent: component, animated: animated)
    }
    
    open func selectedRow(inComponent component: Int) -> Int {
        return pickerView.selectedRow(inComponent: component)
    }
}

// MARK:
extension PickerView {
    
    fileprivate var selectedRows: [(row: Int, component: Int)] {
        return (0 ..< pickerView.numberOfComponents)
            .flatMap { self.source?.component(for: $0).index }
            .enumerated()
            .map { ($0.element, $0.offset) }
    }

    fileprivate func setupView() {
        pickerView = UIPickerView()
        toolbar = UIToolbar()
        tintColor = .clear
        
        addTarget(self, action: #selector(editingDidBegin(_:)), for: .editingDidBegin)
        addTarget(self, action: #selector(editingDidEnd(_:)), for: .editingDidEnd)
    }
    
    fileprivate func updateTitle() {
        if let closure = source?.titleFor {
            text = closure((self, selectedRows))
        } else {
            text = selectedRows.flatMap { (row, component) -> String? in
                return self.source?.pickerView(self, titleForRow: row, forComponent: component)
            }.reduce("", +)
        }
    }
    
    fileprivate func textFieldRect(forBounds bounds: CGRect) -> CGRect {
        let leftViewBounds = leftView?.bounds ?? .zero
        let rightViewBounds = rightView?.bounds ?? .zero
        
        let leftPadding = leftViewBounds.width > 0 ? left : 0
        let rightPadding = rightViewBounds.width > 0 ? right : 0
        return CGRect(
            x: bounds.minX + left + leftViewBounds.width + leftPadding,
            y: bounds.minY + top,
            width: bounds.width - left - right - leftViewBounds.width - leftPadding - rightViewBounds.width - rightPadding,
            height: bounds.height - top - bottom
        )
    }
}

// MARK: Event
extension PickerView {
    
    @objc fileprivate func tapCompletionButton(_ sender: Any) {
        resignFirstResponder()
    }
    
    @objc fileprivate func editingDidBegin(_ sender: Any) {
        beginEditing?()
        
        selectedRows.forEach { (row, component) in
            self.selectRow(row, inComponent: component, animated: false)
        }
        
        if let highlightBorderColor = highlightBorderColor {
            layer.borderColor = highlightBorderColor.cgColor
        }
        
        if let highlightBackgroundImage = highlightBackgroundImage {
            background = highlightBackgroundImage
        }
    }
    
    @objc fileprivate func editingDidEnd(_ sender: Any) {
        endEditing?((self, selectedRows))
        
        if let normalBorderColor = normalBorderColor {
            layer.borderColor = normalBorderColor.cgColor
        }
        
        if let normalBackgroundImage = normalBackgroundImage {
            background = normalBackgroundImage
        }
    }
}

// MARK: UIPickerViewDataSource
extension PickerView: UIPickerViewDataSource {
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        let n = source?.numberOfComponents(in: self) ?? 0
        return n
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let n = source?.pickerView(self, numberOfRowsInComponent: component) ?? 0
        return n
    }
}

// MARK: UIPickerViewDelegate
extension PickerView: UIPickerViewDelegate {
    
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return source?.pickerView(self, widthForComponent: component) ?? PickerView.screenWidth - 4
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return source?.pickerView(self, titleForRow: row, forComponent: component)
    }
    
    public func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return source?.pickerView(self, attributedTitleForRow: row, forComponent: component)
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        source?.pickerView(self, didSelectRow: row, inComponent: component)
        updateTitle()
    }
}
