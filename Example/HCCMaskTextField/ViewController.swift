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
import HCCMaskTextField

class ViewController: UIViewController {
    //手机号输入框
    @IBOutlet weak var phoneNumberTextField: HCCMaskTextField!
    @IBOutlet weak var phoneNumberButton: UIButton!
    @IBOutlet weak var phoneNumberShowLabel: UILabel!
    //身份证号输入框
    @IBOutlet weak var idNumberTextField: HCCMaskTextField!
    @IBOutlet weak var idNumberButton: UIButton!
    @IBOutlet weak var idNumberShowLabel: UILabel!
    //银行卡号输入框
    @IBOutlet weak var cardNumberTextField: HCCMaskTextField!
    @IBOutlet weak var cardNumberButton: UIButton!
    @IBOutlet weak var cardNumberShowLabel: UILabel!
    //掩码起始位 掩码长度 掩码字符
    @IBOutlet weak var customBeginMaskIndexTextField: UITextField!
    @IBOutlet weak var customMaskLengthTextField: UITextField!
    @IBOutlet weak var customMaskCharactersTextField: UITextField!
    //自定义输入框
    @IBOutlet weak var customTextField: HCCMaskTextField!
    @IBOutlet weak var customButton: UIButton!
    @IBOutlet weak var customShowLabel: UILabel!
    
    
    lazy var maskTextField: HCCMaskTextField = {
        let maskTF = HCCMaskTextField(frame: CGRect(x: 20, y: 700, width: 250, height: 25))
        maskTF.initialConfig(.phone, self)
        maskTF.borderStyle = UITextBorderStyle.roundedRect
        maskTF.clearButtonMode = .whileEditing
        return maskTF
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        customBeginMaskIndexTextField.delegate = self
        customMaskLengthTextField.delegate = self
        customMaskCharactersTextField.delegate = self
        
//        self.view.addSubview(maskTextField)
        
        //传入输入框类型和代理
        phoneNumberTextField.initialConfig(.phone, self)
        idNumberTextField.initialConfig(.idCard, self)
        cardNumberTextField.initialConfig(.bankCard, self)
        customTextField.initialConfig(.custom(0, 0, "*"), self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //getMaskText() 获取掩码后的相应字符串
    @IBAction func phoneNumberButtonClick(_ sender: Any) {
        phoneNumberTextField.resignFirstResponder()
        phoneNumberShowLabel.text = phoneNumberTextField.getMaskText()
    }
    @IBAction func changePhoneNumberToNonMask(_ sender: Any) {
        phoneNumberTextField.resignFirstResponder()
        phoneNumberShowLabel.text = phoneNumberTextField.getNonMaskText()
    }
    
    @IBAction func idNumberButtonClick(_ sender: Any) {
        idNumberTextField.resignFirstResponder()
        idNumberShowLabel.text = idNumberTextField.getMaskText()
    }
    
    @IBAction func cardNumberButtonClick(_ sender: Any) {
        cardNumberTextField.resignFirstResponder()
        cardNumberShowLabel.text = cardNumberTextField.getMaskText()
    }
    
    @IBAction func customButtonClick(_ sender: Any) {
        customTextField.resignFirstResponder()
        customShowLabel.text = customTextField.getMaskText()
    }
    
    @IBAction func changeCustomToNonMask(_ sender: Any) {
        customTextField.resignFirstResponder()
        customShowLabel.text = customTextField.getNonMaskText()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.window?.endEditing(true)
    }
    
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let customMaskStartIndex = customBeginMaskIndexTextField.text, let customMaskLength = customMaskLengthTextField.text, let customMaskCharacters = customMaskCharactersTextField.text {
            customTextField.initialConfig(.custom(Int(customMaskStartIndex) ?? 0, Int(customMaskLength) ?? 0, customMaskCharacters), self)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            return true
        }
        if textField == customBeginMaskIndexTextField || textField == customMaskLengthTextField {
            return string.isNumber() ? true : false
        }
        return true
    }
}

extension ViewController: HCCMaskTextFieldDelegate{
    func showError(errorCode: MakeMaskTextError) {
        var messageText = ""
        switch errorCode {
        case .phoneNumberError:
            messageText = "手机号有误"
        case .idCardNumberError:
            messageText = "身份证号有误"
        case .bandCardNumberError:
            messageText = "银行卡号有误"
        case .custonmError:
            messageText = "输入字符串长度小于规定长度"
        case .custonmSettingError:
            messageText = "输入起始位应大于零"
        }
        let alert:UIAlertController = UIAlertController(title: "温馨提示", message: messageText, preferredStyle: UIAlertController.Style.alert)
        let yesAction = UIAlertAction(title: "确定", style: .cancel) { (UIAlertAction) in
        }
        alert.addAction(yesAction)
        //以模态方式弹出
        self.present(alert, animated: true, completion: nil)
    }
}

extension String {
    func isNumber() -> Bool {
         let pattern = "^[0-9]+$"
         if NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self) {
             return true
         }
         return false
     }
}
