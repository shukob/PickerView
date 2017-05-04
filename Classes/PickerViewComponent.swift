//
//  PickerViewComponent.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

open class PickerViewComponent: PickerViewComponentType {
    public typealias PickerViewComponentInformation = (pickerViewRow: PickerViewComponent, pickerView: PickerView, component: Int)
    
    open fileprivate(set) var rows = [PickerViewRowType]()
    
    public var width: CGFloat?
    public var index = 0
    
    public init() {
    }
    
    public convenience init(closure: ((PickerViewComponent) -> Void)) {
        self.init()
        closure(self)
    }
    
    open var widthFor: ((PickerViewComponentInformation) -> CGFloat?)?
}

extension PickerViewComponent {
    
    public func row(for index: Int) -> PickerViewRowType {
        return rows[index]
    }
    
    @discardableResult
    public func removeRow(_ index: Int) -> PickerViewRowType {
        return rows.remove(at: index)
    }
    
    public func insertRow(_ row: PickerViewRowType, index: Int) {
        rows.insert(row, at: index)
    }
}

extension PickerViewComponent {
    
    @discardableResult
    public func add(row: PickerViewRowType) -> Self {
        rows.append(row)
        return self
    }
    
    @discardableResult
    public func add(rows: [PickerViewRowType]) -> Self {
        self.rows.append(contentsOf: rows)
        return self
    }
    
    @discardableResult
    public func createRow(closure: ((PickerViewRow) -> Void)) -> Self {
        return add(row: PickerViewRow() { closure($0) })
    }
    
    @discardableResult
    public func createRows<E>(elements: [E], closure: ((E, PickerViewRow) -> Void)) -> Self {
        let rows = elements.map { (element) -> PickerViewRow in
            return PickerViewRow() { closure(element, $0) }
        }
        return add(rows: rows)
    }
}

extension PickerViewComponent: PickerViewComponentDelegateType {
    
    func widthFor(_ pickerView: PickerView, component: Int) -> CGFloat? {
        return widthFor?((self, pickerView, component))
    }
}
