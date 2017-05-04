//
//  PickerViewRow.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

open class PickerViewRow: PickerViewRowType {
    public typealias PickerViewRowInformation = (pickerViewRow: PickerViewRow, pickerView: PickerView, row: Int, component: Int)
    
    public var title: String?
    public var attributedTitle: NSAttributedString?
    
    public init() {
    }
    
    public convenience init(closure: ((PickerViewRow) -> Void)) {
        self.init()
        closure(self)
    }
    
    open var titleFor: ((PickerViewRowInformation) -> String?)?
    open var attributedTitleFor: ((PickerViewRowInformation) -> NSAttributedString?)?
    open var didSelect: ((PickerViewRowInformation) -> Void)?
}

extension PickerViewRow: PickerViewRowDelegateType {
    
    func titleFor(_ pickerView: PickerView, row: Int, component: Int) -> String? {
        return titleFor?((self, pickerView, row, component))
    }
    
    func attributedTitleFor(_ pickerView: PickerView, row: Int, component: Int) -> NSAttributedString? {
        return attributedTitleFor?((self, pickerView, row, component))
    }
    
    func didSelect(_ pickerView: PickerView, row: Int, component: Int) {
        didSelect?((self, pickerView, row, component))
    }
}
