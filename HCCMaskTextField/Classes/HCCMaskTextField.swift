/*
* Copyright 2007-2022 Home Credit Xinchi Consulting Co. Ltd
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit

//输入框类型
public enum HCCMaskTextFieldType {
    case phone
    case idCard
    case bankCard
    case custom( _ customMaskStartIndex: Int, _ customMaskLength: Int, _ customMaskCharacters: String)
}

//输入框错误类型
public enum MakeMaskTextError {
    case phoneNumberError
    case idCardNumberError
    case bandCardNumberError
    case custonmError
    case custonmSettingError
}

public protocol HCCMaskTextFieldDelegate: UITextFieldDelegate {
    func showError(errorCode: MakeMaskTextError)
}

@IBDesignable public class HCCMaskTextField: UITextField {
    private var actualText: String = "" //实际数字
    private var showText: String = ""   //显示数字
    private var currentType: HCCMaskTextFieldType = .custom(0, 0, "*")
    public weak var hccMaskTFdelegate: HCCMaskTextFieldDelegate?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    //初始化 配置
    public func initialConfig( _ textFieldType: HCCMaskTextFieldType, _ delegate: HCCMaskTextFieldDelegate) {
        hccMaskTFdelegate = delegate
        currentType = textFieldType
    }
    
    //获取掩码后字符串
    public func getMaskText() -> String {
        switch currentType {
        case .phone:
            if actualText.validatePhoneNumber() {
                showText = actualText.prefix(3) + "****" + actualText.suffix(4)
            } else {
                showText = ""
                hccMaskTFdelegate?.showError(errorCode: .phoneNumberError)
            }
            break
        case .idCard:
            if actualText.validateIDNumber() {
                showText = actualText.prefix(6) + "************"
            } else {
                showText = ""
                hccMaskTFdelegate?.showError(errorCode: .idCardNumberError)
            }
            break
        case .bankCard:
            if actualText.validateBankCard() {
                showText = actualText.prefix(6) + "******" + actualText.suffix(4)
            } else {
                showText = ""
                hccMaskTFdelegate?.showError(errorCode: .bandCardNumberError)
            }
            break
        case let .custom(customMaskStartIndex, customMaskLength, customMaskCharacters):
            if customMaskStartIndex == 0 {
                showText = ""
                hccMaskTFdelegate?.showError(errorCode: .custonmSettingError)
            } else if actualText.count >= customMaskStartIndex + customMaskLength {
                showText = String(actualText.prefix(customMaskStartIndex-1) + addMask(customMaskLength, customMaskCharacters) + actualText.suffix(actualText.count - (customMaskStartIndex + customMaskLength-1)))
            } else {
                showText = ""
                hccMaskTFdelegate?.showError(errorCode: .custonmError)
            }
            break
        }
        return showText
    }
    
    //获取掩码后字符串
    public func getNonMaskText() -> String {
        return actualText
    }
    
    // MARK: EditingChanged handler
    @objc func textChanged(_ sender: UITextField) {
        if let textFieldString = sender.text  {
            switch currentType {
            case .phone:
                if textFieldString.count == 0 {
                    actualText = textFieldString
                } else if textFieldString.count > 11 {
                    self.text = actualText
                } else {
                    if textFieldString.validateNumber() {
                        actualText = textFieldString
                    } else {
                        self.text = actualText
                    }
                }
                break
            case .bankCard:
                if textFieldString.count == 0 {
                    actualText = textFieldString
                } else if textFieldString.count > 16 {
                    self.text = actualText
                } else {
                    if textFieldString.validateNumber() {
                        actualText = textFieldString
                    } else {
                        self.text = actualText
                    }
                }
                break
            case .idCard:
                if textFieldString.count == 0 {
                    actualText = textFieldString
                } else if textFieldString.count <= 17 {
                    if textFieldString.validateNumber() {
                        actualText = textFieldString
                    } else {
                        self.text = actualText
                    }
                } else if textFieldString.count > 18 {
                    self.text = actualText
                } else {
                    if textFieldString.validateNumberOretter() {
                        actualText = textFieldString
                    }else {
                        self.text = actualText
                    }
                }
                break
            default:
                actualText = textFieldString
            }
        }
        
    }
}

extension HCCMaskTextField {
    private func addMask( _ count: Int, _ customMaskCharacters: String) -> String {
        var returnText = ""
        var count = count
        while count > 0 {
            returnText = returnText + customMaskCharacters
            count -= 1
        }
        return returnText
    }
}

extension String {
    func validateNumber() -> Bool {
        let pattern = "^[0-9]+$" //纯数字
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
            return true
        }
        return false
    }
    
    func validateNumberOretter() -> Bool {
        let pattern = "^[A-Za-z0-9]+$" //数字 字母
        if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
            return true
        }
        return false
    }
    
    func validatePhoneNumber() -> Bool {
        let phoneNumberRegex = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9]))\\d{8}$" // 手机号
        let phoneNumberTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
        return phoneNumberTest.evaluate(with: self)
    }
    
    func validateIDNumber() -> Bool {
        let idNumberRegex = "^(\\d{14}|\\d{17})(\\d|[xX])$" // ⾝份证号
        let idNumberTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", idNumberRegex)
        return idNumberTest.evaluate(with: self)
    }
    
    func validateBankCard() -> Bool {
        let pattern = "^([0-9]{16}|[0-9]{19}|[0-9]{17}|[0-9]{18}|[0-9]{20}|[0-9]{21})$" //身份证
        let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.dotMatchesLineSeparators)
        if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) {
            return true
        }
        return false
    }
}

