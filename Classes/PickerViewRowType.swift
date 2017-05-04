//
//  PickerViewRowType.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit

public protocol PickerViewRowType {
    var title: String? { get }
    var attributedTitle: NSAttributedString? { get }
}

protocol PickerViewRowDelegateType {
    func titleFor(_ pickerView: PickerView, row: Int, component: Int) -> String?
    func attributedTitleFor(_ pickerView: PickerView, row: Int, component: Int) -> NSAttributedString?
    func didSelect(_ pickerView: PickerView, row: Int, component: Int)
}
