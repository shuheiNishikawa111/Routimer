
import UIKit
/*------------------------------▼グローバル宣言▼------------------------------*/
var tag: Int? = nil

var cellIdentifier: String = ""

var Num2 :Int? = nil
/*----------▼仮保存変数▼----------*/
var tempStringList: [[String]] = []//[0]...タスク名
var tempIntList: [[Int]] = []//[0]...タスク時間,[1]...タスクの止め方,[2]...タスクショートカット
var tempBoolList: [[Bool]] = []//[0]...タスクのアナウンス
var tempTimeTotal: [Int] = []
var tempSaveData: [[Int]] = []
//編集前の中身保存リスト
var lastRoutineName: String = ""
var lastStringList: [[String]] = []
var lastIntList: [[Int]] = []
var lastBoolList: [[Bool]] = []
//変更されたか確認変数
var editChk:Bool = true

class taskViewController: UIViewController, CatchProtocol {
    /*----------------------------------------▼宣言▼----------------------------------------*/
    var totalNum: Int = 0
    
    var hourNum: Int = 0
    var minNum: Int = 0
    var secNum: Int = 0
    
    var userDefaults = UserDefaults.standard
    
    /*----------------------------------------▼ラベル紐付け▼----------------------------------------*/
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var tasktableView: UITableView!
    @IBOutlet weak var routinName: UITextField!
    @IBOutlet weak var totalTimeLabel: UILabel!
    @IBOutlet weak var saveButtonLabel: UIButton!
    
    
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //戻るボタン非表示
        navigationItem.hidesBackButton = true
        
        //デリゲート宣言
        tasktableView.delegate = self
        tasktableView.dataSource = self
        //ドラッグドロップデリゲート宣言
        tasktableView.dropDelegate = self
        tasktableView.dragDelegate = self
        tasktableView.dragInteractionEnabled = true
        
        //inputAccesoryViewに入れるtoolbar
        let toolbar = UIToolbar()
        
        //完了ボタンを右寄せにする為に、左側を埋めるスペース作成
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                    target: nil,
                                    action: nil)
        //完了ボタンを作成
        let done = UIBarButtonItem(title: "完了",
                                   style: .done,
                                   target: self,
                                   action: #selector(didTapDoneButton))
        
        //toolbarのitemsに作成したスペースと完了ボタンを入れる。実際にも左から順に表示されます。
        toolbar.items = [space, done]
        toolbar.sizeToFit()
        
        //作成したtoolbarをtextFieldのinputAccessoryViewに入れる
        routinName.inputAccessoryView = toolbar
        
        //カスタムセルの登録
        tasktableView.register(UINib(nibName: "taskTableViewCell", bundle: nil), forCellReuseIdentifier: "customCell")
        
        routinName.placeholder = "ルーチン名を入力"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if toTaskViewSwitch == true {
            
            let routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
            let taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
            let taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
            let taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
            let taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
            let taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]

            routinName.text! = routinNameListInst[Num1!]
            tempStringList = taskStringListInst[Num1!]
            tempIntList = taskIntListInst[Num1!]
            tempBoolList = taskBoolListInst[Num1!]
            tempTimeTotal = taskTimeTotal[Num1!]
            tempSaveData = taskSaveData[Num1!]
            
            //直前のデータ保存
            lastRoutineName = routinName.text!
            lastStringList = tempStringList
            lastIntList = tempIntList
            lastBoolList = tempBoolList
        }
        
        reloadItem()
        
        tasktableView.reloadData()

        toTaskViewSwitch = false
        
        
    }
    //キーボード外を触れた時の動作
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        reloadItem()
        self.view.endEditing(true)
    }
    
    /*----------------------------------------▼関数▼----------------------------------------*/
    //テーブルビュー以外の情報を更新
    func reloadItem(){
        
        var hourNumTotal = 0
        var minNumTotal = 0
        var secNumTotal = 0
        //0からイントリストの最後カウントまで回す
        for i in 0 ..< tempIntList.count {
            timeConvert(time: tempIntList[i][0])
            secNumTotal += secNum
            if secNumTotal >= 60 {
                minNumTotal += 1
                secNumTotal -= 60
                if minNumTotal >= 60 {
                    hourNumTotal += 1
                    minNumTotal -= 60
                }
            }
            minNumTotal += minNum
            if minNumTotal >= 60 {
                hourNumTotal += 1
                minNumTotal -= 60
            }
            hourNumTotal += hourNum
            //時間が99を超えたら時間をMAXに
            if hourNumTotal > 99 {
                hourNumTotal = 99
                minNumTotal = 59
                secNumTotal = 59
            }
            
        }
        //合計時間を入れに保存
        tempTimeTotal[0] = hourNumTotal
        tempTimeTotal[1] = minNumTotal
        tempTimeTotal[2] = secNumTotal
        
        //totalNumを合計時間に代入
        totalTimeLabel.text = ("\(hourNumTotal)時間\(minNumTotal)分\(secNumTotal)秒")
        
        editChk = true
        //ルーチンネーム比較
        if lastRoutineName != routinName.text! {
            editChk = false
        }
        else if lastStringList.count != tempStringList.count || lastIntList.count != tempStringList.count || lastBoolList.count != tempStringList.count {
            editChk = false
        }
        else {
            for i in 0 ..< tempStringList.count {
                //クラッシュ防止
                if i == lastStringList.count {
                    editChk = false
                    break
                }
                //string確認[0]...タスク名
                if lastStringList[i][0] != tempStringList[i][0] {
                    editChk = false
                    break
                }
                //Int確認[0]...タスク時間,[1]...タスクの止め方,[2]...タスクショートカット
                if lastIntList[i][0] != tempIntList[i][0] || lastIntList[i][1] != tempIntList[i][1] || lastIntList[i][2] != tempIntList[i][2] {
                    editChk = false
                    break
                }
                //bool確認[0]...タスクのアナウンス
                if lastBoolList[i][0] != tempBoolList[i][0] {
                    editChk = false
                    break
                }
                
            }
        }
        
        if editChk == false {
            saveButtonLabel.isHidden = false
        }
        else {
            saveButtonLabel.isHidden = true
        }
        
    }
    //数字を時間に変換
    func timeConvert(time: Int){
        
        var tempTime = time
        //時間の位を代入
        hourNum = tempTime / 10000
        //元時間を分のくらいにする
        tempTime = tempTime % 10000
        
        //分の位を代入
        minNum = tempTime / 100
        //もし60分以上ある場合、繰り上げ
        if minNum >= 60 {
            minNum -= 60
            hourNum += 1
        }
        //元時間を秒の位にする
        tempTime = tempTime % 100
        //秒の位を代入
        secNum = tempTime / 1
        //もし60秒以上の時繰り上げ
        if secNum >= 60 {
            secNum -= 60
            minNum += 1
            //もし60分以上ある場合、繰り上げ
            if minNum >= 60 {
                minNum -= 60
                hourNum += 1
            }
        }
        if hourNum > 99 {
            hourNum = 99
        }
    }
    //カスタムセル動作
    func catchData(id:Int) {
        if id == 0 {
            reloadItem()
            tasktableView.reloadData()
        }
    }
    /*----------------------------------------▼アクション紐付け▼----------------------------------------*/
    //キーボード完了ボタンを押した時の処理
    @objc func didTapDoneButton() {
        reloadItem()
        routinName.resignFirstResponder()
    }
    //ルーチンネームのエンターキーの動作
    @IBAction func taskNameTextFieldEnterAction(_ sender: Any) {
        reloadItem()
        self.view.endEditing(true)
    }
    //下のタスク追加ボタン{{
    @IBAction func addTaskButtonAction(_ sender: Any) {
        
        //追加するタスク
        
        let newStringList: [String] = [""]
        let newIntList: [Int] = [0, 0, 0, -1]
        let newBoolList: [Bool] = [false]
        
        
        tempStringList.append(newStringList)
        tempIntList.append(newIntList)
        tempBoolList.append(newBoolList)
        tempSaveData.append([0,0,0])
        
        reloadItem()
        tasktableView.reloadData()
    }
    //右上の保存ボタン
    @IBAction func saveTask(_ sender: Any) {
        
        var routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        var taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        var taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        var taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        var taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
        var taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]
        
        routinNameListInst[Num1!] = routinName.text!
        taskStringListInst[Num1!] = tempStringList
        taskIntListInst[Num1!] = tempIntList
        taskBoolListInst[Num1!] = tempBoolList
        taskSaveData[Num1!] = tempSaveData
        taskTimeTotal[Num1!] = tempTimeTotal
        
        userDefaults.set(routinNameListInst, forKey: "rNL")
        userDefaults.set(taskStringListInst, forKey: "tSL")
        userDefaults.set(taskIntListInst, forKey: "tIL")
        userDefaults.set(taskBoolListInst, forKey: "tBL")
        userDefaults.set(taskSaveData, forKey: "tSD")
        userDefaults.set(taskTimeTotal, forKey: "tTT")
        
        self.navigationController?.popViewController(animated: true)
    }
    //左上のキャンセルボタン
    @IBAction func cancelButtonAction(_ sender: Any) {
        editChk = true
        //ルーチンネーム比較
        if lastRoutineName != routinName.text! {
            editChk = false
        }
        else if lastStringList.count != tempStringList.count || lastIntList.count != tempStringList.count || lastBoolList.count != tempStringList.count {
            editChk = false
        }
        else {
            for i in 0 ..< tempStringList.count {
                //クラッシュ防止
                if i == lastStringList.count {
                    editChk = false
                    break
                }
                //string確認[0]...タスク名
                if lastStringList[i][0] != tempStringList[i][0] {
                    editChk = false
                    break
                }
                //Int確認[0]...タスク時間,[1]...タスクの止め方,[2]...タスクショートカット
                if lastIntList[i][0] != tempIntList[i][0] || lastIntList[i][1] != tempIntList[i][1] || lastIntList[i][2] != tempIntList[i][2] {
                    editChk = false
                    break
                }
                //bool確認[0]...タスクのアナウンス
                if lastBoolList[i][0] != tempBoolList[i][0] {
                    editChk = false
                    break
                }
                
            }
        }
        if editChk == false {
            //アラート
            let alert = UIAlertController(title: "確認", message: "変更を中止しますか？", preferredStyle: .alert)
            
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.navigationController?.popToRootViewController(animated: true)
                
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                
            })
            
            alert.addAction(OK)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    //全体読み込み
    @IBAction func reloadAllTime(_ sender: Any) {
        //アラート
        let alert = UIAlertController(title: "確認", message: "前回記録を全て読み込みますか？", preferredStyle: .alert)
        let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            for i in 0 ..< tempStringList.count {
                if tempSaveData[i][0] > 0 {
                    tempSaveData[i][1] += tempSaveData[i][0] * 60
                    tempSaveData[i][0] = 0
                }
                if tempSaveData[i][1] > 100 {
                    tempSaveData[i][1] = 99
                    tempSaveData[i][2] = 59
                }
                tempIntList[i][0] = tempSaveData[i][1] * 100 + tempSaveData[i][2] * 1
            }
            self.reloadItem()
            self.tasktableView.reloadData()
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            //何もなし
        })
        
        alert.addAction(OK)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

/*----------------------------------------▼テーブルビュー▼----------------------------------------*/
/*------------------------------▼データソース▼------------------------------*/
extension taskViewController: UITableViewDataSource {
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         
        return tempStringList.count
    }
    
    //セルの詳細
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //セルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell2", for: indexPath) as! customCell2
        
        if tempStringList[indexPath.row][0] == "" {
            cell.taskNameLabel.textColor = .lightGray
            cell.taskNameLabel.text = "例:歯磨き"
        }
        else if tempStringList[indexPath.row][0] == "○タップで編集○" {
            cell.taskNameLabel.textColor = .darkGray
            cell.taskNameLabel.text = tempStringList[indexPath.row][0]
        }
        else if tempStringList[indexPath.row][0] == "→右スワイプ【コピー・追加】→" {
            cell.taskNameLabel.textColor = .systemCyan
            cell.taskNameLabel.text = tempStringList[indexPath.row][0]
        }
        else if tempStringList[indexPath.row][0] == "←左スワイプ【削除】←"{
            cell.taskNameLabel.textColor = .systemPink
            cell.taskNameLabel.text = tempStringList[indexPath.row][0]
        }
        else if tempStringList[indexPath.row][0] == "⚫︎長押しで順番入れ替え⚫︎" {
            cell.taskNameLabel.textColor = .darkGray
            cell.taskNameLabel.text = tempStringList[indexPath.row][0]
        }
        else {
            cell.taskNameLabel.textColor = UIColor(hex: "212121")
            cell.taskNameLabel.text = tempStringList[indexPath.row][0]
        }
        
        let tempTaskTime = tempIntList[indexPath.row][0]
        
        
        
        
        if tempTaskTime / 1000 == 0 && tempTaskTime / 100 == 0 && tempTaskTime / 10 == 0 {
            cell.timeLabel.text = ("\((tempTaskTime / 1) % 10)秒")
        }
        else if tempTaskTime / 1000 == 0 && tempTaskTime / 100 == 0 {
            cell.timeLabel.text = ("\((tempTaskTime / 10) % 10)\((tempTaskTime / 1) % 10)秒")
        }
        else if tempTaskTime / 1000 == 0 {
            cell.timeLabel.text = ("\((tempTaskTime / 100) % 10)分\((tempTaskTime / 10) % 10)\((tempTaskTime / 1) % 10)秒")
        }
        else {
            cell.timeLabel.text = ("\((tempTaskTime / 1000) % 10 )\((tempTaskTime / 100) % 10)分\((tempTaskTime / 10) % 10)\((tempTaskTime / 1) % 10)秒")
        }
        
        //セーブデータの合計値計算
        var totalNum = tempSaveData[indexPath.row][0] * 3600 + tempSaveData[indexPath.row][1] * 60 + tempSaveData[indexPath.row][2] * 1
        if totalNum > 5999 {
            totalNum = 5999
        }
        
        //もしsaveDataが0秒の時、リロードボタンを打てなくする
        if ( tempSaveData[indexPath.row][0] == 0 && tempSaveData[indexPath.row][1] == 0 && tempSaveData[indexPath.row][2] == 0 ) || totalNum == ((tempIntList[indexPath.row][0] / 100 ) * 60 + (tempIntList[indexPath.row][0] % 100)) {
            cell.reloadButton.isHidden = true
            cell.reloadTime.isHidden = true
        }
        else {
            cell.reloadButton.isHidden = false
            cell.reloadTime.isHidden = false
        }
        
        
        
        //左のイラスト変更
        if indexPath.row == 0 && indexPath.row == tempStringList.count - 1 {
            cell.upperBar.isHidden = true
            cell.centerSquare.isHidden = false
            cell.lowerBar.isHidden = true
        }
        else if indexPath.row == 0 {
            cell.upperBar.isHidden = true
            cell.centerSquare.isHidden = false
            cell.lowerBar.isHidden = false
        }
        else if indexPath.row == tempStringList.count - 1 {
            cell.upperBar.isHidden = false
            cell.centerSquare.isHidden = false
            cell.lowerBar.isHidden = true
        }
        else {
            cell.upperBar.isHidden = false
            cell.centerSquare.isHidden = false
            cell.lowerBar.isHidden = false
        }
        //セーブデータの時間配置
        if tempSaveData[indexPath.row][1] > 9 || tempSaveData[indexPath.row][0] > 0 {
            if tempSaveData[indexPath.row][0] > 0 {
                tempSaveData[indexPath.row][1] += tempSaveData[indexPath.row][0] * 60
                tempSaveData[indexPath.row][0] = 0
            }
            if tempSaveData[indexPath.row][1] > 100 {
                tempSaveData[indexPath.row][1] = 99
                tempSaveData[indexPath.row][2] = 59
            }
            if tempSaveData[indexPath.row][2] > 9 {
                cell.reloadTime.text = ("(\(tempSaveData[indexPath.row][1]):\(tempSaveData[indexPath.row][2]))")
            }
            else {
                cell.reloadTime.text = ("(\(tempSaveData[indexPath.row][1]):0\(tempSaveData[indexPath.row][2]))")
            }
        }
        else {
            if tempSaveData[indexPath.row][2] > 9{
                cell.reloadTime.text = ("(0\(tempSaveData[indexPath.row][1]):\(tempSaveData[indexPath.row][2]))")
            }
            else {
                cell.reloadTime.text = ("(0\(tempSaveData[indexPath.row][1]):0\(tempSaveData[indexPath.row][2]))")
            }
        }
        cell.reloadButton.tag = indexPath.row
        
        cell.delegate = self
        //セルに入れる
        return cell
    }
    
    //並び替え（このままでOK）下の関数がメイン
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //並び替え
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let insertStringItem = tempStringList[sourceIndexPath.row]
        let insertIntItem = tempIntList[sourceIndexPath.row]
        let insertBoolItem = tempBoolList[sourceIndexPath.row]
        let insertSaveData = tempSaveData[sourceIndexPath.row]
        
        tempStringList.remove(at: sourceIndexPath.row)
        tempIntList.remove(at: sourceIndexPath.row)
        tempBoolList.remove(at: sourceIndexPath.row)
        tempSaveData.remove(at: sourceIndexPath.row)
        
        tempStringList.insert(insertStringItem, at: destinationIndexPath.row)
        tempIntList.insert(insertIntItem, at: destinationIndexPath.row)
        tempBoolList.insert(insertBoolItem, at: destinationIndexPath.row)
        tempSaveData.insert(insertSaveData, at: destinationIndexPath.row)
        
        reloadItem()
        tableView.reloadData()
    }
    
    //「削除」動作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        tempStringList.remove(at: indexPath.row)
        tempIntList.remove(at: indexPath.row)
        tempBoolList.remove(at: indexPath.row)
        tempSaveData.remove(at: indexPath.row)
        
        reloadItem()
        tableView.reloadData()
    }
}
/*------------------------------▼デリゲート▼------------------------------*/
extension taskViewController: UITableViewDelegate {
    //セルをタップした時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Num2 = indexPath.row
        self.performSegue(withIdentifier: "toDetail", sender: nil)
    }
    //右スワイプ時の動作　＊今回は「コピー、追加」機能を追加
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let copyAction = UIContextualAction(style: .normal, title: "コピー") { (action, view, completionHandler) in
            
            let insertStringItem = tempStringList[indexPath.row]
            let insertIntItem = tempIntList[indexPath.row]
            let insertBoolItem = tempBoolList[indexPath.row]
            let insertSaveData = tempSaveData[indexPath.row]
           
            tempStringList.insert(insertStringItem, at: indexPath.row + 1)
            tempIntList.insert(insertIntItem, at: indexPath.row + 1)
            tempBoolList.insert(insertBoolItem, at: indexPath.row + 1)
            tempSaveData.insert(insertSaveData, at: indexPath.row + 1)
            
            self.reloadItem()
            tableView.reloadData()
            
            completionHandler(true)
        }
        let addAction = UIContextualAction(style: .normal, title: "追加") { (action, view, completionHandler) in

            let insertStringItem = [""]
            let insertIntItem = [0, 0, 0, -1]
            let insertBoolItem = [false]
            
           
            tempStringList.insert(insertStringItem, at: indexPath.row + 1)
            tempIntList.insert(insertIntItem, at: indexPath.row + 1)
            tempBoolList.insert(insertBoolItem, at: indexPath.row + 1)
            tempSaveData.insert([0,0,0], at: indexPath.row + 1)
            
            self.reloadItem()
            tableView.reloadData()
            
            completionHandler(true)
        }
        
        addAction.backgroundColor = UIColor.systemCyan
        copyAction.backgroundColor = UIColor.systemGray
        
        return UISwipeActionsConfiguration(actions: [copyAction,addAction])
        
    }
}

/*------------------------------▼ドラッグデリゲート▼------------------------------*/
extension taskViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        //セルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell2", for: indexPath) as! customCell2
        cell.upperBar.isHidden = true
        cell.centerSquare.isHidden = false
        cell.lowerBar.isHidden = true
        return []
    }
}
/*------------------------------▼ドロップデリゲート▼------------------------------*/
extension taskViewController: UITableViewDropDelegate{
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        // Dropした際の並び替えの実装
    }
}
