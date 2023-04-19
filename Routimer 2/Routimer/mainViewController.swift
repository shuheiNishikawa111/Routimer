
import UIKit
import Intents

/*----------▼グローバル宣言▼----------*/
var Num1: Int? = nil
var toTaskViewSwitch: Bool = false
var totalMin: Int = 0
var totalSec: Int = 0
//ショートカット起動変数
var shortcutSwitch: Bool = false


/*------------------------------▼taskList中身▼------------------------------*/
//taskStringList[0]タスク名
//taskIntList[0]タスク時間,[1]タスクの止め方,[2]タスクショートカット,[3]QRコード
//[0]タスクのアナウンス

class mainViewController: UIViewController, shortCutDelegate {
    /*----------------------------------------▼ラベル紐付け▼----------------------------------------*/
    @IBOutlet weak var mainTableView: UITableView!
    
    /*----------------------------------------▼変数宣言▼----------------------------------------*/
    //  userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    //初回起動スイッチ
    var initSwitch: Bool = false
    //タスク予定宣言
    var taskTimeTotal: [[Int]] = []
    
    //レコード(単体)宣言
    var taskLastRecord: [[[Int]]] = []
    //タスクセーブデータ
    var taskSaveData: [[[Int]]] = []
    
    //レコード(合計)宣言
    var taskLastRecordTotal: [[Int]] = []
    
    var routinNameListInst: [String] = []
    var taskStringListInst: [[[String]]] = []
    var taskIntListInst: [[[Int]]] = []
    var taskBoolListInst: [[[Bool]]] = []
    //ランキング変数
    var rankList: [[[Int]]] = []
    
    //QR変数
    var QRURLListInst: [String] = []
    var QRNameListInst: [String] = []
    
    
    
    //タイマーインスタンス
    var mainTimer: Timer!
    //時間変数
    var mainTimerNum: Int = 0
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //SceneDelegateを取得
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        sceneDelegate.delegateShortcut = self
        
        //デリゲート宣言
        mainTableView.delegate = self
        mainTableView.dataSource = self
        //ドラッグドロップデリゲート宣言
        mainTableView.dropDelegate = self
        mainTableView.dragDelegate = self
        //ドラッグできるようにする
        mainTableView.dragInteractionEnabled = true
        
        
        //エディットモード
        mainTableView.isEditing = false
        
        
        /*------------------------------▼ユーザーデフォルト登録▼------------------------------*/
        userDefaults.register(defaults: ["iS": true])//initSwitch初回のみ判定スイッチ
        
        /*----------▼削除必須▼----------*/
        userDefaults.register(defaults: ["rNL": ["チュートリアル"]])//routinNameList
        userDefaults.register(defaults: ["tSL": [[[""]]]])//taskStringList
        userDefaults.register(defaults: ["tIL": [[[0,0,0,-1]]]])//taskIntList//4番目はQRコード
        userDefaults.register(defaults: ["tBL": [[[false]]]])//taskBoolList
        /*----------▲ここまで▲----------*/
        
        //音量登録
        userDefaults.register(defaults: ["tV": [0.5,0.5]])//taskVolume
        //合計タイムの入れ物登録...[Num1!][Num2][0,1,2]0が時間,1が分,2が秒
        userDefaults.register(defaults: ["tTT": [[0,0,0]]])//taskTimeTotal
        //今回のタイム(合計)保持配列...0が時間,1が分,2が秒
        userDefaults.register(defaults: ["tLRT": [[0,0,0]]])//taskLastRecordTotal
        //今回のタイム保持配列...0が時間,1が分,2が秒
        userDefaults.register(defaults: ["tLR": [[[0,0,0]]]])//taskLastRecord
        //次回読み込み用データ
        userDefaults.register(defaults: ["tSD": [[[0,0,0]]]])//taskSaveData
        //ランキングを登録する配列
        userDefaults.register(defaults: ["rL": [[[100,0,0,0,0,0]]]])//rankList
        
        /*----------▼削除必須▼----------*/
        //QRコードURLリスト
        userDefaults.register(defaults: ["QUL": [""]])//QRURLList
        //QRコード名前リスト
        userDefaults.register(defaults: ["QNL": [""]])//QRNameList
        /*----------▲ここまで▲----------*/
        
        //バックグラウンド用時間
        userDefaults.register(defaults: ["oT": [0,0,0]])//outTime
        userDefaults.register(defaults: ["iT": [0,0,0]])//inTime
        userDefaults.register(defaults: ["dT": [0,0,0]])//diffTime←何分間バックグラウンドにいてたか
        
        //プレイタイマー起動中か確認
        userDefaults.register(defaults: ["cT": [0,0,0]])//checkTimer
        
        /*------------------------------▲UD登録ここまで▲------------------------------*/
        
        //読み出し
        initSwitch = userDefaults.bool(forKey: "iS")
        
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        
        taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]
        taskLastRecord = userDefaults.array(forKey: "tLR") as! [[[Int]]]
        taskLastRecordTotal = userDefaults.array(forKey: "tLRT") as! [[Int]]
        taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
        //ランキング（時間*3＋日付）
        rankList = userDefaults.array(forKey: "rL") as! [[[Int]]]
        
        QRURLListInst = userDefaults.array(forKey: "QUL") as! [String]
        QRNameListInst = userDefaults.array(forKey: "QNL") as! [String]
        
        //記録保持配列を増やす←多分、初回登録で済み
//        taskTimeTotal.append([0,0,0])
//        taskLastRecord.append([[0]])
//        taskLastRecordTotal.append([0,0,0])
//        taskSaveData.append([[0,0,0]])
//        rankList.append([[100,0,0,0,0,0]])
        
        //初回起動時「」タスク追加する
        if initSwitch == true {
            
            let insertStringItem00 = [""]
            let insertStringItem01 = ["→右スワイプ【コピー・追加】→"]
            let insertStringItem02 = ["←左スワイプ【削除】←"]
            let insertStringItem03 = ["⚫︎長押しで順番入れ替え⚫︎"]
            
            
            
            taskStringListInst[0].append(insertStringItem01)//右スワイプ説明
            taskStringListInst[0].append(insertStringItem02)//左スワイプ説明
            taskStringListInst[0].append(insertStringItem03)//長押しスワイプ説明
            taskStringListInst[0].append(insertStringItem00)
            
            for _ in 0 ..< 4 {
                taskIntListInst[0].append([0,0,0,-1])
                taskBoolListInst[0].append([false])
                
                taskLastRecord[0].append([0])
                taskSaveData[0].append([0,0,0])
                rankList[0].append([100,0,0,0,0,0])
                initSwitch = false
            }
            
            
        }
        //保存
        userDefaults.set(routinNameListInst, forKey: "rNL")
        userDefaults.set(taskStringListInst, forKey: "tSL")
        userDefaults.set(taskIntListInst, forKey: "tIL")
        userDefaults.set(taskBoolListInst, forKey: "tBL")
        
        userDefaults.set(taskTimeTotal, forKey: "tTT")
        userDefaults.set(taskLastRecord, forKey: "tLR")
        userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
        userDefaults.set(taskSaveData, forKey: "tSD")
        userDefaults.set(rankList, forKey: "rL")
        
        userDefaults.set(initSwitch, forKey: "iS")
        
        mainTableView.reloadData()
        
        
    }

    override func viewWillAppear(_ animated: Bool) {
        //仮配列の初期化
        tempStringList.removeAll()
        tempIntList.removeAll()
        tempBoolList.removeAll()
        
        mainTableView.reloadData()
        
    }
    
    

    /*----------------------------------------▼関数▼----------------------------------------*/
    
    func shortcutPlay(){
        //ショートカットから起動したら
        
        if Num1! - 1 < routinNameListInst.count && Num1! > 0 {
            Num1 = Num1! - 1
            self.navigationController?.popToRootViewController(animated: true)
            performSegue(withIdentifier: "toPlayView", sender: nil)
        }
        else {
            /*------------------------------▼アラート▼------------------------------*/
            let alert = UIAlertController(title: "起動に失敗しました", message: "ルーチン[\(Num1!)]は存在しません", preferredStyle: .alert)
            
            
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                //OKを押した時の動作
            })
            
            alert.addAction(OK)
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    /*----------------------------------------▼ボタンアクション紐付け▼----------------------------------------*/
    //右上＋ボタン押した時
    @IBAction func addRoutinButtonAction(_ sender: Any) {
        
        //読み出し
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        
        taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]
        taskLastRecord = userDefaults.array(forKey: "tLR") as! [[[Int]]]
        taskLastRecordTotal = userDefaults.array(forKey: "tLRT") as! [[Int]]
        taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
        rankList = userDefaults.array(forKey: "rL") as! [[[Int]]]
        //新規タスクのインスタンス
        let newRoutin: String = ""
        
        
        routinNameListInst.append(newRoutin)
        taskStringListInst.append([[""]])
        taskIntListInst.append([[0,0,0,-1]])
        taskBoolListInst.append([[false]])
        

        userDefaults.set(routinNameListInst, forKey: "rNL")
        userDefaults.set(taskStringListInst, forKey: "tSL")
        userDefaults.set(taskIntListInst, forKey: "tIL")
        userDefaults.set(taskBoolListInst, forKey: "tBL")
        
        //記録保持配列を増やす
        taskTimeTotal.append([0,0,0])
        taskLastRecord.append([[0,0,0]])
            taskLastRecordTotal.append([0,0,0])
        taskSaveData.append([[0,0,0]])
        rankList.append([[100,0,0,0,0,0]])
        
        //保存
        userDefaults.set(taskTimeTotal, forKey: "tTT")
        userDefaults.set(taskLastRecord, forKey: "tLR")
        userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
        userDefaults.set(taskSaveData, forKey: "tSD")
        userDefaults.set(rankList, forKey: "rL")
        
        Num1 = routinNameListInst.count - 1
        toTaskViewSwitch = true
        mainTableView.reloadData()
        self.performSegue(withIdentifier: "toTask", sender: nil)
    }
    
    //アクセサリービューボタンのアクション
    @objc func tapRoutin(_ sender: UIButton){
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        
        if taskStringListInst[sender.tag].count > 0 {
            
            Num1 = sender.tag
            
            performSegue(withIdentifier: "toPlayView", sender: nil)
        } else {
            /*------------------------------▼アラート▼------------------------------*/
            let alert = UIAlertController(title: "アラート", message: "タスクが設定されていません", preferredStyle: .alert)
            
            
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                //OKを押した時の動作
            })
            
            alert.addAction(OK)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

/*----------------------------------------▼テーブルビュー▼----------------------------------------*/
/*------------------------------▼データソース▼------------------------------*/
extension mainViewController: UITableViewDataSource {
    //セル高さ
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 70
//    }
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        //routinTaskClassの数を返す
        return routinNameListInst.count
        
    }
    //セルの詳細
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //ルーチンネームのインスタンス
        let routinNameListInst: [String] = userDefaults.array(forKey: "rNL") as! [String]
        
        //セルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainCell", for: indexPath)
        
        //セルのテキストラベルにリストのテキストを入れる
        cell.textLabel?.text = "\(indexPath.row + 1): \(routinNameListInst[indexPath.row])"
        
        //セルカラー
        cell.textLabel?.textColor = UIColor(hex: "212121")
        //アクセサリビューを設定
        //ボタンのインスタンスを作成　大きさは縦横50,50
        let playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        
        //ボタンのイメージを設定
        playButton.setImage(UIImage(systemName: "play.circle")!, for: .normal)
        
        //ボタンのタグをインデックスパスに設定
        playButton.tag = indexPath.row
        
        //セルのアクセサリービューの位置にボタンを入れる
        cell.accessoryView = playButton
        cell.accessoryView?.tintColor = .systemCyan
        
        //アクセサリビューをタップした時
        playButton.addTarget(self, action: #selector(self.tapRoutin(_:)), for: UIControl.Event.touchUpInside)
        
        //セルに入れる
        return cell
    }
    //並び替え（このままでOK）下の関数がメイン
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    //並び替え
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        rankList = userDefaults.array(forKey: "rL") as! [[[Int]]]
        
        let insertroutinName = routinNameListInst[sourceIndexPath.row]
        let insertStringListItem = taskStringListInst[sourceIndexPath.row]
        let insertIntListItem = taskIntListInst[sourceIndexPath.row]
        let insertBoolListItem = taskBoolListInst[sourceIndexPath.row]
        let insertRankListItem = rankList[sourceIndexPath.row]
        
        routinNameListInst.remove(at: sourceIndexPath.row)
        taskStringListInst.remove(at: sourceIndexPath.row)
        taskIntListInst.remove(at: sourceIndexPath.row)
        taskBoolListInst.remove(at: sourceIndexPath.row)
        rankList.remove(at: sourceIndexPath.row)
        
        routinNameListInst.insert(insertroutinName, at: destinationIndexPath.row)
        taskStringListInst.insert(insertStringListItem, at: destinationIndexPath.row)
        taskIntListInst.insert(insertIntListItem, at: destinationIndexPath.row)
        taskBoolListInst.insert(insertBoolListItem, at: destinationIndexPath.row)
        rankList.insert(insertRankListItem, at: destinationIndexPath.row)

        //保存
        userDefaults.set(routinNameListInst, forKey: "rNL")
        userDefaults.set(taskStringListInst, forKey: "tSL")
        userDefaults.set(taskIntListInst, forKey: "tIL")
        userDefaults.set(taskBoolListInst, forKey: "tBL")
        userDefaults.set(rankList, forKey: "rL")
        
        tableView.reloadData()
    }
    //「削除」動作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        //読み出し
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        
        taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]
        taskLastRecord = userDefaults.array(forKey: "tLR") as! [[[Int]]]
        taskLastRecordTotal = userDefaults.array(forKey: "tLRT") as! [[Int]]
        taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
        rankList = userDefaults.array(forKey: "rL") as! [[[Int]]]
        
        
        //取り除く
        routinNameListInst.remove(at: indexPath.row)
        taskStringListInst.remove(at: indexPath.row)
        taskIntListInst.remove(at: indexPath.row)
        taskBoolListInst.remove(at: indexPath.row)
        
        taskTimeTotal.remove(at: indexPath.row)
        taskLastRecord.remove(at: indexPath.row)
        taskLastRecordTotal.remove(at: indexPath.row)
        taskSaveData.remove(at: indexPath.row)
        rankList.remove(at: indexPath.row)
        
        //保存
        userDefaults.set(routinNameListInst, forKey: "rNL")
        userDefaults.set(taskStringListInst, forKey: "tSL")
        userDefaults.set(taskIntListInst, forKey: "tIL")
        userDefaults.set(taskBoolListInst, forKey: "tBL")
        
        userDefaults.set(taskTimeTotal, forKey: "tTT")
        userDefaults.set(taskLastRecord, forKey: "tLR")
        userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
        userDefaults.set(taskSaveData, forKey: "tSD")
        userDefaults.set(rankList, forKey: "rL")
        
        tableView.reloadData()
        
        
    }
}
/*------------------------------▼デリゲート▼------------------------------*/
extension mainViewController: UITableViewDelegate {
    //セルをタップした時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.row)を持って移動します。")
        print("セクションは\(indexPath.section)")
        Num1 = indexPath.row
        toTaskViewSwitch = true
        self.performSegue(withIdentifier: "toTask", sender: nil)
    }
    //右スワイプ時の動作　＊今回は「追加」機能を追加
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        //コピー動作
        let copyAction = UIContextualAction(style: .normal, title: "Copy") { (action, view, completionHandler) in
            //読み出し
            var routinNameListInst = self.userDefaults.array(forKey: "rNL") as! [String]
            var taskStringListInst = self.userDefaults.array(forKey: "tSL") as! [[[String]]]
            var taskIntListInst = self.userDefaults.array(forKey: "tIL") as! [[[Int]]]
            var taskBoolListInst = self.userDefaults.array(forKey: "tBL") as! [[[Bool]]]
            
            var taskTimeTotal = self.userDefaults.array(forKey: "tTT") as! [[Int]]
            var taskLastRecord = self.userDefaults.array(forKey: "tLR") as! [[[Int]]]
            var taskLastRecordTotal = self.userDefaults.array(forKey: "tLRT") as! [[Int]]
            var taskSaveData = self.userDefaults.array(forKey: "tSD") as! [[[Int]]]
            var rankList = self.userDefaults.array(forKey: "rL") as! [[[Int]]]
            
            //インサートアイテム宣言
            let inssetRoutinName = routinNameListInst[indexPath.row]
            let insertStringItem = taskStringListInst[indexPath.row]
            let insertIntItem = taskIntListInst[indexPath.row]
            let insertBoolItem = taskBoolListInst[indexPath.row]
//            let insertSaveData = taskSaveData[indexPath.row]
//            let insertRankListItem = rankList[indexPath.row]
//            let insertTimeTotal = taskTimeTotal[indexPath.row]
//            let insertLastRecord = taskLastRecord[indexPath.row]
//            let insertLastRecordTotal = taskLastRecordTotal[indexPath.row]
            
            
            //インサート
            routinNameListInst.insert(inssetRoutinName, at: indexPath.row + 1)
            taskStringListInst.insert(insertStringItem, at: indexPath.row + 1)
            taskIntListInst.insert(insertIntItem, at: indexPath.row + 1)
            taskBoolListInst.insert(insertBoolItem, at: indexPath.row + 1)
//            taskSaveData.insert(insertSaveData, at: indexPath.row + 1)
//            rankList.insert(insertRankListItem, at: indexPath.row + 1)
//            taskTimeTotal.insert(insertTimeTotal, at: indexPath.row + 1)
//            taskLastRecord.insert(insertLastRecord, at: indexPath.row + 1)
//            taskLastRecordTotal.insert(insertLastRecordTotal, at: indexPath.row + 1)
            
            //記録保持配列を増やす
            rankList.append([[100,0,0,0,0,0]])
            taskTimeTotal.append([0,0,0])
            taskLastRecord.append([[0,0,0]])
            taskLastRecordTotal.append([0,0,0])
            taskSaveData.append([[0,0,0]])
            //セーブデータはインデックスパスのtaskIntListの数分増やす
            for _ in 0 ..< taskIntListInst[indexPath.row].count - 1 {
                taskSaveData[indexPath.row + 1].append([0,0,0])
            }
            
            //セット
            self.userDefaults.set(routinNameListInst, forKey: "rNL")
            self.userDefaults.set(taskStringListInst, forKey: "tSL")
            self.userDefaults.set(taskIntListInst, forKey: "tIL")
            self.userDefaults.set(taskBoolListInst, forKey: "tBL")
            
            self.userDefaults.set(taskTimeTotal, forKey: "tTT")
            self.userDefaults.set(taskLastRecord, forKey: "tLR")
            self.userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
            self.userDefaults.set(taskSaveData, forKey: "tSD")
            self.userDefaults.set(rankList, forKey: "rL")
            
            tableView.reloadData()
            
            completionHandler(true)
        }
        //追加動作
//        let addAction = UIContextualAction(style: .normal, title: "Add") { (action, view, completionHandler) in
//
//            var routinNameListInst = self.userDefaults.array(forKey: "rNL") as! [String]
//            var taskStringListInst = self.userDefaults.array(forKey: "tSL") as! [[[String]]]
//            var taskIntListInst = self.userDefaults.array(forKey: "tIL") as! [[[Int]]]
//            var taskBoolListInst = self.userDefaults.array(forKey: "tBL") as! [[[Bool]]]
//
//            var taskTimeTotal = self.userDefaults.array(forKey: "tTT") as! [[Int]]
//            var taskLastRecord = self.userDefaults.array(forKey: "tLR") as! [[[Int]]]
//            var taskLastRecordTotal = self.userDefaults.array(forKey: "tLRT") as! [[Int]]
//            var taskSaveData = self.userDefaults.array(forKey: "tSD") as! [[[Int]]]
//            var rankList = self.userDefaults.array(forKey: "rL") as! [[[Int]]]
//
//            let inssetRoutinName = "新規ルーチン"
//            let insertStringItem = [["新規タスク"]]
//            let insertIntItem = [[0, 0, 0, -1]]
//            let insertBoolItem = [[false]]
//            let insertRankListItem = [[100,0,0,0,0,0]]
//
//            routinNameListInst.insert(inssetRoutinName, at: indexPath.row + 1)
//            taskStringListInst.insert(insertStringItem, at: indexPath.row + 1)
//            taskIntListInst.insert(insertIntItem, at: indexPath.row + 1)
//            taskBoolListInst.insert(insertBoolItem, at: indexPath.row + 1)
//            rankList.insert(insertRankListItem, at: indexPath.row + 1)
//
//            //記録保持配列を増やす
//            taskTimeTotal.append([0,0,0])
//            taskLastRecord.append([[0]])
//            taskLastRecordTotal.append([0,0,0])
//            taskSaveData.append([[0]])
//
//            self.userDefaults.set(routinNameListInst, forKey: "rNL")
//            self.userDefaults.set(taskStringListInst, forKey: "tSL")
//            self.userDefaults.set(taskIntListInst, forKey: "tIL")
//            self.userDefaults.set(taskBoolListInst, forKey: "tBL")
//
//            self.userDefaults.set(taskTimeTotal, forKey: "tTT")
//            self.userDefaults.set(taskLastRecord, forKey: "tLR")
//            self.userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
//            self.userDefaults.set(taskSaveData, forKey: "tSD")
//            self.userDefaults.set(rankList, forKey: "rL")
//
//            tableView.reloadData()
//
//            completionHandler(true)
//        }
//        addAction.backgroundColor = UIColor.systemCyan
        copyAction.backgroundColor = UIColor.systemGray
        
        return UISwipeActionsConfiguration(actions: [copyAction])
        
    }
}
/*------------------------------▼ドラッグデリゲート▼------------------------------*/
extension mainViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return []
    }
}
/*------------------------------▼ドロップデリゲート▼------------------------------*/
extension mainViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        // Dropした際の並び替えの実装
    }
}
