
import UIKit

class scoreViewController: UIViewController {
    /*----------------------------------------▼ラベル紐付け▼----------------------------------------*/
    /*----------▼タイトル▼----------*/
    @IBOutlet weak var routinNameLabel: UINavigationItem!
    @IBOutlet weak var label1: UILabel!
    
    @IBOutlet weak var label2: UILabel!
    /*----------▼ランキング時間▼----------*/
    @IBOutlet weak var rankTime1: UILabel!
    @IBOutlet weak var rankTime2: UILabel!
    @IBOutlet weak var rankTime3: UILabel!
    /*----------▼ランキング日付▼----------*/
    @IBOutlet weak var rankDay1: UILabel!
    @IBOutlet weak var rankDay2: UILabel!
    @IBOutlet weak var rankDay3: UILabel!
    /*----------▼ランクの番号▼----------*/
    @IBOutlet weak var rankNum1: UILabel!
    @IBOutlet weak var rankNum2: UILabel!
    @IBOutlet weak var rankNum3: UILabel!
    /*----------▼ゴミ箱ボタン▼----------*/
    @IBOutlet weak var trashButton1: UIButton!
    
    @IBOutlet weak var trashButton2: UIButton!
    
    @IBOutlet weak var trashButton3: UIButton!
    /*----------------------------------------▼宣言▼----------------------------------------*/
    //ユーザーデフォルト宣言
    var userDefaults = UserDefaults.standard
    //いつもの
    var routinNameListInst:[String] = []
    var taskStringListInst:[[[String]]] = []
    var taskIntListInst:[[[Int]]] = []
    var taskBoolListInst:[[[Bool]]] = []
    //レコード(単体)宣言
    var taskLastRecord: [[[Int]]] = []
    //レコード(合計)宣言
    var taskLastRecordTotal: [[Int]] = []
    //ルーチン予定時間
    var taskTimeTotal: [[Int]] = []
    //ランキング用配列
    var rankList: [[[Int]]] = []//0が時間,1が分,2が秒,345が年月日
    //今回挿入したランクを光らせるための変数[3のときは何も光らせない]
    var highLightNum: Int = 3

    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //戻るボタン非表示
        navigationItem.hidesBackButton = true
        /*------------------------------▼一番上ラベルの設定▼------------------------------*/
        /*----------▼userDefaults新規登録▼----------*/
        
        /*----------▼userDefaults読み出し▼----------*/
        //タスク系全部読み出し
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        //タスク記録単体
        taskLastRecord = userDefaults.array(forKey: "tLR") as! [[[Int]]]
        //タスク記録合計
        taskLastRecordTotal = userDefaults.array(forKey: "tLRT") as! [[Int]]//0が時間、1が分,2が秒
        //ルーチン予定時間
        taskTimeTotal = userDefaults.array(forKey: "tTT") as! [[Int]]
        
        //ランキング（時間＋日付）
        rankList = userDefaults.array(forKey: "rL") as! [[[Int]]]//0が時間、1が分,2が秒
        
        /*----------▼ランキング配列初期化▼----------*/
        //ランクリストの数が1つしかない時、3つに増やす[初期化]
        if rankList[Num1!].count < 3 {
            rankList[Num1!][0][0] = 100 
            rankList[Num1!].append([100,0,0,0,0,0])
            rankList[Num1!].append([100,0,0,0,0,0])
        }
        
        /*----------▼ラベル表示▼----------*/
        //もしタスク記録合計が1時間超えてたら
        if taskLastRecordTotal[Num1!][0] >= 1 {
            label1.text = ("記録：\(taskLastRecordTotal[Num1!][0])時間\(taskLastRecordTotal[Num1!][1])分\(taskLastRecordTotal[Num1!][2])秒")
        }
        else if taskLastRecordTotal[Num1!][1] > 0 {
            label1.text = ("記録：\(taskLastRecordTotal[Num1!][1])分\(taskLastRecordTotal[Num1!][2])秒")
        }
        else {
            label1.text = ("記録：\(taskLastRecordTotal[Num1!][2])秒")
        }
        /*------------------------------▼予定時間と今回記録の比較▼------------------------------*/
        //予定時間の合計
        let taskTimeTotalSum = taskTimeTotal[Num1!][0] * 360 + taskTimeTotal[Num1!][1] * 60 + taskTimeTotal[Num1!][2] * 1
        //今回記録の合計
        let taskLastRecordSum = taskLastRecordTotal[Num1!][0] * 360 + taskLastRecordTotal[Num1!][1] * 60 + taskLastRecordTotal[Num1!][2] * 1
        //もし予定時間より早く完了した時
        if taskTimeTotalSum > taskLastRecordSum {
            var recHour = taskTimeTotal[Num1!][0] - taskLastRecordTotal[Num1!][0]
            var recMin = taskTimeTotal[Num1!][1] - taskLastRecordTotal[Num1!][1]
            //もし分がマイナスになったら
            if recMin < 0 {
                recHour -= 1
                recMin += 60
            }
            var recSec = taskTimeTotal[Num1!][2] - taskLastRecordTotal[Num1!][2]
            if recSec < 0 {
                recMin -= 1
                if recMin < 0 {
                    recHour -= 1
                    recMin += 60
                }
                recSec += 60
            }
            if recHour == 0 {
                if recMin > 0 {
                    label2.text = ("(予定より\(recMin)分\(recSec)秒早く完了しました！)")
                }
                else {
                    label2.text = ("(予定より\(recSec)秒早く完了しました！)")
                }
            }
            else {
                label2.text = ("(予定より\(recHour)時間\(recMin)分\(recSec)秒早く完了しました！)")
            }
        }
        //予定時間より時間がかかった時
        else if taskLastRecordSum > taskTimeTotalSum {
            var recHour = taskLastRecordTotal[Num1!][0] - taskTimeTotal[Num1!][0]
            var recMin = taskLastRecordTotal[Num1!][1] - taskTimeTotal[Num1!][1]
            //もし分がマイナスになったら
            if recMin < 0 {
                recHour -= 1
                recMin += 60
            }
            var recSec = taskLastRecordTotal[Num1!][2] - taskTimeTotal[Num1!][2]
            if recSec < 0 {
                recMin -= 1
                if recMin < 0 {
                    recHour -= 1
                    recMin += 60
                }
                recSec += 60
            }
            if recHour == 0 {
                if recMin > 0 {
                    label2.text = ("(予定より\(recMin)分\(recSec)秒多くかかりました)")
                }
                else {
                    label2.text = ("(予定より\(recSec)秒多くかかりました)")
                }
            }
            else {
                label2.text = ("(予定より\(recHour):\(recMin):\(recSec)多くかかりました)")
            }
        }
        //予定通り完了
        else {
            if taskTimeTotal[Num1!][0] == 0 {
                if taskTimeTotal[Num1!][1] > 0 {
                    label2.text = ("(予定通り\(taskTimeTotal[Num1!][1])分\(taskTimeTotal[Num1!][2])秒で完了しました！)")
                }
                else {
                    label2.text = ("(予定通り\(taskTimeTotal[Num1!][2])秒で完了しました！)")
                }
            }
            else {
                label2.text = ("(予定通り\(taskTimeTotal[Num1!][0])時間\(taskTimeTotal[Num1!][1])分\(taskTimeTotal[Num1!][2])秒で完了しました！)")
            }
        }
        
        //ランキングリスト更新
//        rankSort()
        //今回記録代入
        rankCompare()
        
        reloadRank()
        
        userDefaults.set(rankList, forKey: "rL")
        
        routinNameLabel.title = "\(routinNameListInst[Num1!])"
    }
    
    //時間、分、秒を入力して合計秒を換算する関数
    func timeConvert(hour: Int,min: Int,sec: Int) -> Int {
        var time: Int
        time = hour * 360 + min * 60 + sec * 1
        return time
    }

    //ランクリストを早い順に並び替え
    func rankSort(){
        var tmpTime0 = timeConvert(hour: rankList[Num1!][0][0], min: rankList[Num1!][0][1], sec: rankList[Num1!][0][2])
        var tmpTime1 = timeConvert(hour: rankList[Num1!][1][0], min: rankList[Num1!][1][1], sec: rankList[Num1!][1][2])
        var tmpTime2 = timeConvert(hour: rankList[Num1!][2][0], min: rankList[Num1!][2][1], sec: rankList[Num1!][2][2])
        
        if tmpTime0 > tmpTime1 {
            let tmp0 = rankList[Num1!][0][0]
            let tmp1 = rankList[Num1!][0][1]
            let tmp2 = rankList[Num1!][0][2]
            let tmp3 = rankList[Num1!][0][3]
            let tmp4 = rankList[Num1!][0][4]
            let tmp5 = rankList[Num1!][0][5]
            let tmp = tmpTime0
            
            rankList[Num1!][0][0] = rankList[Num1!][1][0]
            rankList[Num1!][0][1] = rankList[Num1!][1][1]
            rankList[Num1!][0][2] = rankList[Num1!][1][2]
            rankList[Num1!][0][3] = rankList[Num1!][1][3]
            rankList[Num1!][0][4] = rankList[Num1!][1][4]
            rankList[Num1!][0][5] = rankList[Num1!][1][5]
            tmpTime0 = tmpTime1
            
            rankList[Num1!][1][0] = tmp0
            rankList[Num1!][1][1] = tmp1
            rankList[Num1!][1][2] = tmp2
            rankList[Num1!][1][3] = tmp3
            rankList[Num1!][1][4] = tmp4
            rankList[Num1!][1][5] = tmp5
            tmpTime1 = tmp
        }
        if tmpTime1 > tmpTime2 {
            let tmp0 = rankList[Num1!][1][0]
            let tmp1 = rankList[Num1!][1][1]
            let tmp2 = rankList[Num1!][1][2]
            let tmp3 = rankList[Num1!][1][3]
            let tmp4 = rankList[Num1!][1][4]
            let tmp5 = rankList[Num1!][1][5]
            let tmp = tmpTime1
            
            rankList[Num1!][1][0] = rankList[Num1!][2][0]
            rankList[Num1!][1][1] = rankList[Num1!][2][1]
            rankList[Num1!][1][2] = rankList[Num1!][2][2]
            rankList[Num1!][1][3] = rankList[Num1!][2][3]
            rankList[Num1!][1][4] = rankList[Num1!][2][4]
            rankList[Num1!][1][5] = rankList[Num1!][2][5]
            tmpTime1 = tmpTime2
            
            rankList[Num1!][2][0] = tmp0
            rankList[Num1!][2][1] = tmp1
            rankList[Num1!][2][2] = tmp2
            rankList[Num1!][2][3] = tmp3
            rankList[Num1!][2][4] = tmp4
            rankList[Num1!][2][5] = tmp5
            tmpTime2 = tmp
        }
        if tmpTime0 > tmpTime1 {
            let tmp0 = rankList[Num1!][0][0]
            let tmp1 = rankList[Num1!][0][1]
            let tmp2 = rankList[Num1!][0][2]
            let tmp3 = rankList[Num1!][0][3]
            let tmp4 = rankList[Num1!][0][4]
            let tmp5 = rankList[Num1!][0][5]
            let tmp = tmpTime0
            
            rankList[Num1!][0][0] = rankList[Num1!][1][0]
            rankList[Num1!][0][1] = rankList[Num1!][1][1]
            rankList[Num1!][0][2] = rankList[Num1!][1][2]
            rankList[Num1!][0][3] = rankList[Num1!][1][3]
            rankList[Num1!][0][4] = rankList[Num1!][1][4]
            rankList[Num1!][0][5] = rankList[Num1!][1][5]
            tmpTime0 = tmpTime1
            
            rankList[Num1!][1][0] = tmp0
            rankList[Num1!][1][1] = tmp1
            rankList[Num1!][1][2] = tmp2
            rankList[Num1!][1][3] = tmp3
            rankList[Num1!][1][4] = tmp4
            rankList[Num1!][1][5] = tmp5
            tmpTime1 = tmp
        }
        
    }
    //今回のレコード合計とこれまでの記録を比較して登録するか決める
    func rankCompare() {
        //今回の記録
        let tmpLast = timeConvert(hour: taskLastRecordTotal[Num1!][0], min: taskLastRecordTotal[Num1!][1], sec: taskLastRecordTotal[Num1!][2])
        let tmpTime0 = timeConvert(hour: rankList[Num1!][0][0], min: rankList[Num1!][0][1], sec: rankList[Num1!][0][2])
        let tmpTime1 = timeConvert(hour: rankList[Num1!][1][0], min: rankList[Num1!][1][1], sec: rankList[Num1!][1][2])
        let tmpTime2 = timeConvert(hour: rankList[Num1!][2][0], min: rankList[Num1!][2][1], sec: rankList[Num1!][2][2])
        //現在時刻を8桁で取得
        //現在時刻
        let now = Date()
        let day = Calendar.current.dateComponents([.year, .month, .day], from: now)
        
        if tmpLast != 0 {
            //今回記録が一番早かった時
            if tmpTime0 > tmpLast || tmpTime0 == 0 {
                rankList[Num1!][2][0] = rankList[Num1!][1][0]
                rankList[Num1!][2][1] = rankList[Num1!][1][1]
                rankList[Num1!][2][2] = rankList[Num1!][1][2]
                rankList[Num1!][2][3] = rankList[Num1!][1][3]
                rankList[Num1!][2][4] = rankList[Num1!][1][4]
                rankList[Num1!][2][5] = rankList[Num1!][1][5]
                
                rankList[Num1!][1][0] = rankList[Num1!][0][0]
                rankList[Num1!][1][1] = rankList[Num1!][0][1]
                rankList[Num1!][1][2] = rankList[Num1!][0][2]
                rankList[Num1!][1][3] = rankList[Num1!][0][3]
                rankList[Num1!][1][4] = rankList[Num1!][0][4]
                rankList[Num1!][1][5] = rankList[Num1!][0][5]
                
                rankList[Num1!][0][0] = taskLastRecordTotal[Num1!][0]
                rankList[Num1!][0][1] = taskLastRecordTotal[Num1!][1]
                rankList[Num1!][0][2] = taskLastRecordTotal[Num1!][2]
                rankList[Num1!][0][3] = day.year!
                rankList[Num1!][0][4] = day.month!
                rankList[Num1!][0][5] = day.day!
                
                //ランク光らせるための変数更新
                highLightNum = 0
            }
            //今回記録が2番目に早かった時
            else if tmpTime1 > tmpLast || tmpTime1 == 0{
                rankList[Num1!][2][0] = rankList[Num1!][1][0]
                rankList[Num1!][2][1] = rankList[Num1!][1][1]
                rankList[Num1!][2][2] = rankList[Num1!][1][2]
                rankList[Num1!][2][3] = rankList[Num1!][1][3]
                rankList[Num1!][2][4] = rankList[Num1!][1][4]
                rankList[Num1!][2][5] = rankList[Num1!][1][5]
                
                rankList[Num1!][1][0] = taskLastRecordTotal[Num1!][0]
                rankList[Num1!][1][1] = taskLastRecordTotal[Num1!][1]
                rankList[Num1!][1][2] = taskLastRecordTotal[Num1!][2]
                rankList[Num1!][1][3] = day.year!
                rankList[Num1!][1][4] = day.month!
                rankList[Num1!][1][5] = day.day!
                
                //ランク光らせるための変数更新
                highLightNum = 1
            }
            //今回記録が3番目に早かった時
            else if tmpTime2 > tmpLast || tmpTime2 == 0 {
                rankList[Num1!][2][0] = taskLastRecordTotal[Num1!][0]
                rankList[Num1!][2][1] = taskLastRecordTotal[Num1!][1]
                rankList[Num1!][2][2] = taskLastRecordTotal[Num1!][2]
                rankList[Num1!][2][3] = day.year!
                rankList[Num1!][2][4] = day.month!
                rankList[Num1!][2][5] = day.day!
                
                //ランク光らせるための変数更新
                highLightNum = 2
            }
            else{
                //ランク光らせるための変数更新
                highLightNum = 3
            }
        }
    }
    
    //ランク反映関数
    func reloadRank(){
        //もし何もない時,削除ボタン押せなくする
        if rankList[Num1!][0][0] == 100 {
            rankTime1.text = ("-")
            rankDay1.text = ("")
            trashButton1.isEnabled = false
        }
        //ある時削除ボタン復活と時間反映
        else {
            trashButton1.isEnabled = true
            rankTime1.text = ("\(rankList[Num1!][0][0])時間\(rankList[Num1!][0][1])分\(rankList[Num1!][0][2])秒")
            rankDay1.text = ("\(rankList[Num1!][0][3])/\(rankList[Num1!][0][4])/\(rankList[Num1!][0][5])")
            //もし今回の追加がこれの時、色変える
            if highLightNum == 0 {
                rankNum1.textColor = .systemGreen
                rankTime1.textColor = .systemGreen
                rankDay1.textColor = .systemGreen
            }
            //それ以外の時色戻す
            else {
                rankNum1.textColor = UIColor(hex: "212121")
                rankTime1.textColor = UIColor(hex: "212121")
                rankDay1.textColor = UIColor(hex: "212121")
            }
        }
        if rankList[Num1!][1][0] == 100 {
            rankTime2.text = ("-")
            rankDay2.text = ("")
            trashButton2.isEnabled = false
        }
        else {
            trashButton2.isEnabled = true
            rankTime2.text = ("\(rankList[Num1!][1][0])時間\(rankList[Num1!][1][1])分\(rankList[Num1!][1][2])秒")
            rankDay2.text = ("\(rankList[Num1!][1][3])/\(rankList[Num1!][1][4])/\(rankList[Num1!][1][5])")
            //もし今回の追加がこれの時、色変える
            if highLightNum == 1 {
                rankNum2.textColor = .systemGreen
                rankTime2.textColor = .systemGreen
                rankDay2.textColor = .systemGreen
            }
            //それ以外の時色戻す
            else {
                rankNum2.textColor = UIColor(hex: "212121")
                rankTime2.textColor = UIColor(hex: "212121")
                rankDay2.textColor = UIColor(hex: "212121")
            }
        }
        if rankList[Num1!][2][0] == 100 {
            rankTime3.text = ("-")
            rankDay3.text = ("")
            trashButton3.isEnabled = false
        }
        else {
            trashButton3.isEnabled = true
            rankTime3.text = ("\(rankList[Num1!][2][0])時間\(rankList[Num1!][2][1])分\(rankList[Num1!][2][2])秒")
            rankDay3.text = ("\(rankList[Num1!][2][3])/\(rankList[Num1!][2][4])/\(rankList[Num1!][2][5])")
            //もし今回の追加がこれの時、色変える
            if highLightNum == 2 {
                rankNum3.textColor = .systemGreen
                rankTime3.textColor = .systemGreen
                rankDay3.textColor = .systemGreen
            }
            //それ以外の時色戻す
            else {
                rankNum3.textColor = UIColor(hex: "212121")
                rankTime3.textColor = UIColor(hex: "212121")
                rankDay3.textColor = UIColor(hex: "212121")
            }
        }
    }
    
    /*----------------------------------------▼アクション紐付け▼----------------------------------------*/
    //完了ボタン
    @IBAction func toHomeButtonAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
    //ゴミ箱ボタン
    @IBAction func trashButtonAction1(_ sender: Any) {
        rankList[Num1!][0][0] = 100
        rankList[Num1!][0][1] = 0
        rankList[Num1!][0][2] = 0
        rankList[Num1!][0][3] = 0
        rankList[Num1!][0][4] = 0
        rankList[Num1!][0][5] = 0
        rankSort()
        reloadRank()
        userDefaults.set(rankList, forKey: "rL")
    }
    @IBAction func trashButtonAction2(_ sender: Any) {
        rankList[Num1!][1][0] = 100
        rankList[Num1!][1][1] = 0
        rankList[Num1!][1][2] = 0
        rankList[Num1!][1][3] = 0
        rankList[Num1!][1][4] = 0
        rankList[Num1!][1][5] = 0
        rankSort()
        reloadRank()
        userDefaults.set(rankList, forKey: "rL")
    }
    @IBAction func trashButtonAction3(_ sender: Any) {
        rankList[Num1!][2][0] = 100
        rankList[Num1!][2][1] = 0
        rankList[Num1!][2][2] = 0
        rankList[Num1!][2][3] = 0
        rankList[Num1!][2][4] = 0
        rankList[Num1!][2][5] = 0
        rankSort()
        reloadRank()
        userDefaults.set(rankList, forKey: "rL")
    }
    @IBAction func shareButtonAction(_ sender: Any) {
        let shareText = "\(routinNameListInst[Num1!])\n\((label1.text)!)\n\((label2.text)!)\n\n#routinTimer\n↓アプリをインストール\nhttps://apps.apple.com/jp/app/routimer/id6447537508"
            let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
    }
}
