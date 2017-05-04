//
//  ViewController.swift
//  PickerView
//
//  Created by Tomoki Koga on 2017/05/02.
//  Copyright © 2017年 tomoponzoo. All rights reserved.
//

import UIKit
import PickerView

class ViewController: UIViewController {

    @IBOutlet weak var pickerView: PickerView!
    
    fileprivate var items = [
        ["こだわらない", "15歳", "16歳", "17歳", "18歳", "19歳", "20歳"],
        ["〜"],
        ["こだわらない", "18歳", "19歳", "20歳", "21歳", "22歳", "23歳", "24歳", "25歳", "26歳", "27歳", "28歳", "29歳", "30歳"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setSource()
        pickerView.rightView = UIImageView(image: UIImage(named: "arrow"))
        pickerView.rightViewMode = .always
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController {
    
    func setSource() {
        pickerView.placeholder = "未選択"
        
        pickerView.source = PickerViewSource() { source in
            source.createComponents(for: items) { (item, component) in
                component.createRows(elements: item) { (title, row) in
                    row.title = title
                    row.didSelect = { (info) in
                        print(">> Did select row")
                        print("Component:\(info.component), Row:\(info.row)")
                        print("<< Did select row")
                    }
                }
                component.index = item.count - 1
            }
            source.titleFor = { (info) in
                let component0 = info.components[0]
                let component2 = info.components[2]
                switch (component0.row, component2.row) {
                case (0, 0):
                    return nil
                case (0, _):
                    return "〜\(self.items[component2.component][component2.row])"
                case (_, 0):
                    return "\(self.items[component0.component][component0.row])〜"
                default:
                    return "\(self.items[component0.component][component0.row])〜\(self.items[component2.component][component2.row])"
                }
            }
            source.didSelect = { (info) in
                print(">> Did select")
                info.components.forEach { (row, component) in
                    print("Component:\(component), Row:\(row)")
                }
                print("<< Did select")
            }
        }
        
        pickerView.beginEditing = { _ in
            print(">> Begin editing")
            print("<< Begin editing")
        }
        
        pickerView.endEditing = { (info) in
            print(">> End editing")
            info.components.forEach { (row, component) in
                print("Component:\(component), Row:\(row)")
            }
            print("<< End editing")
        }
        
        pickerView.reloadAllComponents()
    }
}
