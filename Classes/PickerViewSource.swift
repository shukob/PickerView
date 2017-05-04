//
//  PickerViewSource.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

open class PickerViewSource: NSObject {
    public typealias PickerViewComponentsInformation = (pickerView: PickerView, components: [(row: Int, component: Int)])

    open fileprivate(set) var components = [PickerViewComponentType]()
    
    open var titleFor: ((PickerViewComponentsInformation) -> String?)?
    open var didSelect: ((PickerViewComponentsInformation) -> Void)?
    
    public override init() {
        super.init()
    }
    
    public convenience init(closure: ((PickerViewSource) -> Void)) {
        self.init()
        closure(self)
    }
    
    @discardableResult
    open func add(component: PickerViewComponentType) -> Self {
        self.components.append(component)
        return self
    }
    
    @discardableResult
    open func add(components: [PickerViewComponentType]) -> Self {
        self.components.append(contentsOf: components)
        return self
    }
    
    @discardableResult
    open func createComponent(closure: ((PickerViewComponent) -> Void)) -> Self {
        return add(component: PickerViewComponent() { closure($0) })
    }
    
    @discardableResult
    open func createComponents<E>(for elements: [E], closure: ((E, PickerViewComponent) -> Void)) -> Self {
        let components = elements.map { (element) -> PickerViewComponent in
            return PickerViewComponent() { closure(element, $0) }
        }
        return add(components: components)
    }
}

extension PickerViewSource {
    
    public func component(for component: Int) -> PickerViewComponentType {
        return components[component]
    }
}


extension PickerViewSource {
    
    public func numberOfComponents(in pickerView: PickerView) -> Int {
        return components.count
    }
    
    public func pickerView(_ pickerView: PickerView, numberOfRowsInComponent component: Int) -> Int {
        return components[component].rows.count
    }
}

extension PickerViewSource {
    
    public func pickerView(_ pickerView: PickerView, widthForComponent component: Int) -> CGFloat {
        let c = self.component(for: component)
        if let width = c.width {
            return width
        } else if let width = (c as? PickerViewComponentDelegateType)?.widthFor(pickerView, component: component) {
            return width
        } else {
            let components = numberOfComponents(in: pickerView)
            return (PickerView.screenWidth / CGFloat(components)) - 4
        }
    }
    
    public func pickerView(_ pickerView: PickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let r = self.component(for: component).row(for: row)
        if let title = r.title {
            return title
        } else if let title = (r as? PickerViewRowDelegateType)?.titleFor(pickerView, row: row, component: component) {
            return title
        } else {
            return nil
        }
    }
    
    public func pickerView(_ pickerView: PickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let r = self.component(for: component).row(for: row)
        if let title = r.attributedTitle {
            return title
        } else if let title = (r as? PickerViewRowDelegateType)?.attributedTitleFor(pickerView, row: row, component: component) {
            return title
        } else {
            return nil
        }
    }
    
    public func pickerView(_ pickerView: PickerView, didSelectRow row: Int, inComponent component: Int) {
        var c = self.component(for: component)
        c.index = row
        
        let r = c.row(for: row) as? PickerViewRowDelegateType
        r?.didSelect(pickerView, row: row, component: component)
        
        let components = self.components.enumerated().map({ ($0.element.index, $0.offset) })
        didSelect?((pickerView, components))
    }
}
