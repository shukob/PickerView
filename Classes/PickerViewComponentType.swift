//
//  PickerViewComponentType.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

public protocol PickerViewComponentType {
    var rows: [PickerViewRowType] { get }
    
    var width: CGFloat? { get }
    var index: Int { get set }
    
    func row(for index: Int) -> PickerViewRowType
    
    @discardableResult
    func removeRow(_ index: Int) -> PickerViewRowType
    func insertRow(_ row: PickerViewRowType, index: Int)
}

protocol PickerViewComponentDelegateType {
    func widthFor(_ pickerView: PickerView, component: Int) -> CGFloat?
}
