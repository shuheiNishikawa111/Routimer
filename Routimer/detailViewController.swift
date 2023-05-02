
import UIKit

//[0]タスク名
//[0]タスク時間,[1]タスクの止め方,[2]タスクショートカット
//[0]タスクのアナウンス




class detailViewController: UIViewController {
    
    /*----------------------------------------▼ラベル紐付け▼----------------------------------------*/
    //何番目のタスクか表示
    @IBOutlet weak var taskNumLabel: UINavigationItem!
    //タスク名
    @IBOutlet weak var taskNameTextField: UITextField!
    //タスク時間のテキストフィールド
    @IBOutlet weak var taskTimeTextField: UITextField!
    //タスク時間のラベル
    @IBOutlet weak var taskTimeLable: UILabel!
    //タスクアナウンススイッチ
    @IBOutlet weak var taskAnnounceSwitch: UISwitch!
    //左ボタン
    @IBOutlet weak var leftButton: UIButton!
    //右ボタン
    @IBOutlet weak var rightButton: UIButton!
    //右にタスクを一つ追加ボタン
    @IBOutlet weak var addTaskRightButton: UIBarButtonItem!
    /*----------------------------------------▼停止方法▼----------------------------------------*/
    //タイマー
    @IBOutlet weak var stopMethodTimer: UILabel!
    //QRコード
    @IBOutlet weak var stopMethodQRcode: UILabel!
    //充電
    @IBOutlet weak var stopMethodCharge: UILabel!
    //イヤホン装着
    @IBOutlet weak var stopMethodEarphone: UILabel!
    
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        taskNameTextField.placeholder = "例:歯磨き"
        //デリゲート宣言
        self.taskTimeTextField.delegate = self
        //更新
        reloadItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //もし停止方法がQRになっていて
        if tempIntList[Num2!][1] == 2{
            //QRコードが選択されていない時
            if tempIntList[Num2!][3] == -1 {
                stopMethodQRcode.text = "□"
                tempIntList[Num2!][1] = 0
            }
        }
        reloadItem()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if Num2 != nil {
            tempStringList[Num2!][0] = taskNameTextField.text!
            taskNameTextField.text! = ""//このコードいる？
        }
        
    }
    //キーボード外を触れた時の動作
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if taskTimeTextField.text != "" {
//            taskTimeTextField.placeholder = taskTimeTextField.text
            taskTimeTextField.text = ""
        }
        
        self.view.endEditing(true)
    }
    
    //タスクネームのエンターキーの動作
    @IBAction func taskNameTextFieldEnterAction(_ sender: Any) {
//        taskTimeTextField.placeholder = taskTimeTextField.text
        self.view.endEditing(true)
    }
    
    /*----------------------------------------▼関数▼----------------------------------------*/
    //（関数）左右ボタン非表示表示
    func leftRightButtonIsEnabled() {
        if Num2 == 0 {
            leftButton.isEnabled = false
        } else {
            leftButton.isEnabled = true
        }
        if Num2 == tempStringList.count - 1 {
            rightButton.isEnabled = false
        } else {
            rightButton.isEnabled = true
        }
        
        
        taskNameTextField.text = tempStringList[Num2!][0]
    }
    //アイテムを更新する関数
    func reloadItem(){
        //タスク番号変更
        taskNumLabel.title = ("タスク\(Num2! + 1)/\(tempStringList.count)")
        
        //タスクネーム更新
        taskNameTextField.text = tempStringList[Num2!][0]
        
        //タスクタイムラベル更新
        let tempTaskTime = tempIntList[Num2!][0]
        
        
        taskTimeLable.text = ("\((tempTaskTime / 1000) % 10 )\((tempTaskTime / 100) % 10):\((tempTaskTime / 10) % 10)\((tempTaskTime / 1) % 10)")
        
        
        taskTimeTextField.text = ""
        
        //タスクの止め方更新
        var checkMark = UIButton.Configuration.plain()
        checkMark.image = UIImage(systemName: "checkmark",withConfiguration: UIImage.SymbolConfiguration(scale: .small))
        //チェックマークをすべて外す
        deleteButtonImage()
        
        //新たに一つチェックする
        if tempIntList[Num2!][1] == 1 {
            stopMethodTimer.text = "☑︎"
        }
        if tempIntList[Num2!][1] == 2 {
            stopMethodQRcode.text = "☑︎"
        }
        if tempIntList[Num2!][1] == 3 {

        }
        if tempIntList[Num2!][1] == 4 {
            stopMethodCharge.text = "☑︎"
        }
        if tempIntList[Num2!][1] == 5 {
            stopMethodEarphone.text = "☑︎"
        }
        if tempIntList[Num2!][1] == 6 {
 
        }
        //アナウンス設定更新
        taskAnnounceSwitch.isOn = tempBoolList[Num2!][0]
        
        //左右ボタン非表示
        leftRightButtonIsEnabled()
        
    }
    //キーボード閉じる処理
    func endKeyboard(){
        taskNameTextField.endEditing(true)
        taskTimeTextField.endEditing(true)
    }
    //停止方法全て□にしてtempIntList[Num2!][1] = 0にする
    func removeCheckMark(){
        stopMethodTimer.text = "□"
        stopMethodQRcode.text = "□"
        stopMethodCharge.text = "□"
        stopMethodEarphone.text = "□"
        
        tempIntList[Num2!][1] = 0
    }
    //【使わない】ボタンをトグル式のチェックマークにする
    func checkMarkSwitch(button: UIButton,senderTag: Int){
        
//        var checkMark = UIButton.Configuration.plain()
//        checkMark.image = UIImage(systemName: "checkmark",withConfiguration: UIImage.SymbolConfiguration(scale: .small))
//        var brank = UIButton.Configuration.plain()
//        brank.image = UIImage(systemName: "")
//
//
//        //カラにする
//        if button.configuration?.image != nil {
//            button.configuration = brank
//            tempIntList[Num2!][1] = 0
//
//            //チェックをつける
//        } else {
//            deleteButtonImage()
//            button.configuration = checkMark
//            tempIntList[Num2!][1] = senderTag
//        }
//        print("タスクの止め方は\(tempIntList[Num2!][1])")
    }
    //全てのボタンの画像を外す
    func deleteButtonImage(){
        
        
        stopMethodTimer.text = "□"
        stopMethodQRcode.text = "□"

        stopMethodCharge.text = "□"
        stopMethodEarphone.text = "□"
        
    }
    /*----------------------------------------▼アクション紐付け▼----------------------------------------*/
    //左ボタン
    @IBAction func leftButtonAction(_ sender: Any) {
        endKeyboard()
        tempStringList[Num2!][0] = taskNameTextField.text!
        taskNameTextField.text! = ""
        
        Num2! = Num2! - 1
        
        //更新
        reloadItem()
        
        //左右ボタン非表示判定
        leftRightButtonIsEnabled()
    }
    //右ボタン
    @IBAction func rightButtonAction(_ sender: Any) {
        endKeyboard()
        
        tempStringList[Num2!][0] = taskNameTextField.text!
        taskNameTextField.text! = ""
        
        Num2! = Num2! + 1
        
        //更新
        reloadItem()
        //左右ボタン非表示判定
        leftRightButtonIsEnabled()
    }
    //タスクを右に一つ追加
    @IBAction func addTaskRightButtonAction(_ sender: Any) {
        endKeyboard()
        
        tempStringList[Num2!][0] = taskNameTextField.text!
        taskNameTextField.text! = ""
        
        let insertStringItem = [""]
        let insertIntItem = [0, 0, 0, -1]
        let insertBoolItem = [false]
        let insertSaveData = [0,0,0]
        
        tempStringList.insert(insertStringItem, at: Num2! + 1)
        tempIntList.insert(insertIntItem, at: Num2! + 1)
        tempBoolList.insert(insertBoolItem, at: Num2! + 1)
        tempSaveData.insert(insertSaveData, at: Num2! + 1)
        
        //左右ボタン非表示チェック
        leftRightButtonIsEnabled()
        
        Num2! = Num2! + 1
        
        //更新
        reloadItem()
        //左右ボタン非表示判定
        leftRightButtonIsEnabled()
        
    }
    //タスクを消して一つ前のタスクを表示
    @IBAction func trashButtonAction(_ sender: Any) {

        tempStringList.remove(at: Num2!)
        tempIntList.remove(at: Num2!)
        tempBoolList.remove(at: Num2!)
        tempSaveData.remove(at: Num2!)
        
        
        if tempStringList.count == 0 {
            Num2 = nil
            navigationController?.popViewController(animated: true)
        } else {
            
            if Num2! == tempStringList.count {
                Num2! -= 1
                
                //更新
                reloadItem()
                //左右ボタン非表示判定
                leftRightButtonIsEnabled()
            } else {
                
                //更新
                reloadItem()
                //左右ボタン非表示判定
                leftRightButtonIsEnabled()
            }
        }
    }
    //残り時間アナウンス
    @IBAction func taskAnnounceSwitchAction(_ sender: Any) {
        tempBoolList[Num2!][0].toggle()
        print("\(tempBoolList[Num2!][0])")
    }
    //ショートカットボタン
    @IBAction func taskShortCutButtonAction(_ sender: Any) {
    }
    //タスクの止め方ボタン
    @IBAction func stopMethodButtonAction(_ sender: Any) {
        let senderInst = sender as! UIButton
        //タイマー
        if senderInst.tag == 1 {
            if stopMethodTimer.text == "□"{
                removeCheckMark()
                stopMethodTimer.text = "☑︎"
                tempIntList[Num2!][1] = senderInst.tag
            } else {
                stopMethodTimer.text = "□"
                tempIntList[Num2!][1] = 0
            }
            
            //QRコード
        } else if senderInst.tag == 2 {
            if tempIntList[Num2!][3] != -1 {
                if stopMethodQRcode.text == "□"{
                    removeCheckMark()
                    stopMethodQRcode.text = "☑︎"
                    tempIntList[Num2!][1] = senderInst.tag
                } else {
                    stopMethodQRcode.text = "□"
                    tempIntList[Num2!][1] = 0
                }
            }
            else {
                //アラート
                let alert = UIAlertController(title: "アラート", message: "QRコードが設定されていません", preferredStyle: .alert)
                
                
                let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                    
                })
                
                alert.addAction(OK)
                
                self.present(alert, animated: true, completion: nil)
            }
            
            //ショートカット
        } else if senderInst.tag == 3 {
            
            //充電
        } else if senderInst.tag == 4 {
            if stopMethodCharge.text == "□"{
                removeCheckMark()
                stopMethodCharge.text = "☑︎"
                tempIntList[Num2!][1] = senderInst.tag
            } else {
                stopMethodCharge.text = "□"
                tempIntList[Num2!][1] = 0
            }
            
            //イヤホン
        } else if senderInst.tag == 5 {
            if stopMethodEarphone.text == "□"{
                removeCheckMark()
                stopMethodEarphone.text = "☑︎"
                tempIntList[Num2!][1] = senderInst.tag
            } else {
                stopMethodEarphone.text = "□"
                tempIntList[Num2!][1] = 0
            }
            
            //Apple Watch
        } else if senderInst.tag == 6 {

        }
    }
    //タイマー説明ボタン
    @IBAction func スキップ説明(_ sender: Any) {
        //アラート
        let alert = UIAlertController(title: "説明", message: "タイマーが0になると次のタスクに進みます", preferredStyle: .alert)
        
        
        let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            //オッケーを押した時の動作
        })
        
        alert.addAction(OK)
        
        self.present(alert, animated: true, completion: nil)
    }
}
/*----------------------------------------▼テキストフィールド▼----------------------------------------*/
//テキストフィールドデリゲート
extension detailViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        taskTimeLable.isHidden = false
        guard let value = textField.text else{
            return true
        }
        
        //入力された値以外
        print("valueは\(value)")
        
        //入力された値
        print("stringは\(string)")
        
        //上の合計
        var fullValue = value + string
        
        //文字削除時の動作
        if(string == ""){
            //フルバリューの値を更新
            //prefixはその時の値を表示
            fullValue = String(fullValue.prefix(fullValue.count - 1))
        }
        
        if fullValue.count == 0 {
            taskTimeLable.text = ("00:00")
        }
        
        if fullValue.count == 1 {
            taskTimeLable.text = ("00:0\(fullValue.prefix(1))")
        }
        
        if fullValue.count == 2 {
            taskTimeLable.text = ("00:\(fullValue.prefix(1))\(fullValue.prefix(2).suffix(1))")
        }
        
        if fullValue.count == 3 {
            
            print("\(value)")
            taskTimeLable.text = ("0\(fullValue.prefix(1)):\(fullValue.prefix(2).suffix(1))\(fullValue.prefix(3).suffix(1))")
        }
        
        if fullValue.count == 4 {
            if Int(fullValue.suffix(2))! > 59 {
                fullValue = fullValue.prefix(2) + "59"
            }
            taskTimeLable.text = ("\(fullValue.prefix(1))\(fullValue.prefix(2).suffix(1)):\(fullValue.prefix(3).suffix(1))\(fullValue.prefix(4).suffix(1))")
        }
        
        //5桁以上の入力があった場合、3桁目と4桁目の入力を入れ替える
        if fullValue.count >= 5 {
            if Int(value.prefix(1)) == 0 {
                fullValue = fullValue.prefix(4).suffix(3) + string
                textField.text = String(fullValue.prefix(3))
            } else {
                
                fullValue = value.prefix(3) + string
                
                textField.text = String(value.prefix(3))
            }
            if Int(fullValue.suffix(2))! > 59 {
                fullValue = fullValue.prefix(2) + "59"
            }
            taskTimeLable.text = ("\(fullValue.prefix(1))\(fullValue.prefix(2).suffix(1)):\(fullValue.prefix(3).suffix(1))\(fullValue.prefix(4).suffix(1))")
        }
        //フルバリュー
        print("fullValueは\(fullValue)")
        if fullValue.count != 0 {
            if Int(fullValue.suffix(2))! > 59 {
                if fullValue.count == 4 {
                    fullValue = fullValue.prefix(2) + "59"
                }
                else if fullValue.count == 3 {
                    fullValue = fullValue.prefix(1) + "59"
                }
                else if fullValue.count == 2 {
                    fullValue = "59"
                }
                
            }
            tempIntList[Num2!][0] = Int(fullValue)!
        }
        else {
            tempIntList[Num2!][0] = 0
        }
        print("fullValueは\(fullValue)")
        return true
    }
}
