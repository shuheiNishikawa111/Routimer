
import UIKit
//読み上げ
import AVFoundation

/*----------------------------------------▼グローバル宣言▼----------------------------------------*/
//QRコード格納用変数
var tempQRurl: String = ""
//次に進むかチェックする変数
var chkNextTask: Bool = false
//タイマー動作チェック変数
var checkTimer: Bool = false

//[0]タスク名
//[0]タスク時間,[1]タスクの止め方,[2]タスクショートカット
//[0]タスクのアナウンス

//タスクの停止方法　タイマー[1]


class playViewController: UIViewController, backgroundTimerDelegate{
    func stopPlaySound() {
        self.synthesizer.stopSpeaking(at: .immediate)
        
    }
    
    func backGroundTimer() {
        self.routinTimer.invalidate()
        print("タイマー停止！！")
    }
    
    func foreStartTimer() {
        startTimer()
        checkTimer = true
        print("タイマー開始！！")
        
    }
    //バックグラウンド時にプッシュ通知を予約する
    func reserveNotification(){
        //現在タスクまでの合計時間
        var totalNum: Double = 0
        //アナウンス用関数
        var halfNum: Double = 0
        var threeQuatersNum: Double = 0
        //for文で回して、もしタイマー以外もしくはNum1外にでたらブレイク
        //タイマーが来た時点で現在時間から何秒後に完了か通知予約
        //残り時間アナウンスがオンの時1/2と3/4で通知予約
        for i in Num3 ..< taskStringListInst[Num1!].count {
            var notifiMinNum: Int
            var notifiSecNum: Int
            //初回の時は現在時刻を代入
            if i == Num3 {
                notifiMinNum = minNum
                notifiSecNum = secNum
            }
            else {
                notifiMinNum = newTimeConvert(time: taskIntListInst[Num1!][i][0]).minNum
                notifiSecNum = newTimeConvert(time: taskIntListInst[Num1!][i][0]).secNum
            }
            //合計時間変数 合計時間を秒に変換
            let tempTotalTime = newTimeConvert(time: taskIntListInst[Num1!][i][0])
            //合計時間秒に変換した変数
            let tempTotalSec = tempTotalTime.minNum * 60 + tempTotalTime.secNum
            /*------------------------------▼タイマー以外▼------------------------------*/
            //タイマー以外で時間が過ぎたら通知予約（サウンドは警告音）してブレイク
            if taskIntListInst[Num1!][i][1] != 1 {
                /*-----▼アナウンスオンの時、1/2,3/4予約▼-----*/
                if taskBoolListInst[Num1!][i][0] == true {
                    //1/2を出す
                    halfNum = Double(tempTotalSec / 2)
                    //3/4を計算
                    threeQuatersNum = halfNum / 2
                    
                    //読み上げ時間：合計時間と足す
                    //経過時間計算
                    let progressTime: Double = Double(tempTotalSec - ((notifiMinNum * 60) + notifiSecNum))
                    var timeHalfNum: Double
                    var timeThreeQuatersNum: Double
                    //もし最後のタスクの時、
                    if i == Num3 {
                        timeHalfNum = halfNum - progressTime
                        timeThreeQuatersNum = halfNum + (halfNum / 2) - progressTime
                    }
                    else {
                        timeHalfNum = totalNum + halfNum
                        timeThreeQuatersNum = totalNum + halfNum + (halfNum / 2)
                    }
                    
                    //読み上げ少数切り捨て
                    let sayHalfNum: Int = Int(floor(halfNum))
                    let sayThreeQuaterNum: Int = Int(floor(threeQuatersNum))
                    //1/2予約
                    if timeHalfNum > 0 {
                        //もし通知時間が60秒以上の時
                        if timeHalfNum > 59 {
                            let sayHalfNumCon = timeConvertSecMin(time: sayHalfNum)
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayHalfNumCon.tempMinNum)分\(sayHalfNumCon.tempSecNum)秒です", sound: "SE_halfTime01.caf", time: timeHalfNum, identifier: "\(i)half")
                            print("予約残り\(sayHalfNumCon.tempMinNum)分\(sayHalfNumCon.tempSecNum)秒です")
                        }
                        //もし通知時間が59秒以下の時
                        else {
                            
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayHalfNum)秒です", sound: "SE_halfTime01.caf", time: timeHalfNum, identifier: "\(i)half")
                            print("\(i)番目：\(timeHalfNum)秒後予約")
                        }
                    }
                    
                    //3/4予約
                    if timeThreeQuatersNum > 0 {
                        //もし通知時間が60秒以上の時
                        if timeThreeQuatersNum > 59 {
                            let sayThreeQuaterNumCon = timeConvertSecMin(time: sayThreeQuaterNum)
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayThreeQuaterNumCon.tempMinNum)分\(sayThreeQuaterNumCon.tempSecNum)秒です", sound: "SE_halfTime01.caf", time: timeThreeQuatersNum, identifier: "\(i)threeQuaters")
                            print("\(i)番目：\(timeThreeQuatersNum)秒後予約")
                        }
                        //もし通知時間が59秒以下の時
                        else {
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayThreeQuaterNum)秒です", sound: "SE_halfTime01.caf", time: timeThreeQuatersNum, identifier: "\(i)threeQuaters")
                            print("\(i)番目：\(timeThreeQuatersNum)秒後予約")
                        }
                    }
                }
                //FIXME:
                /*-------------▼完了時間予約▼-------------*/
                //もし現在のタスクの時は、これが、すでに0でないか確認
                if i == Num3 {
                    
                    if notifiSecNum > 0 && notifiMinNum >= 0 && plusLabel.isHidden == true {
                        //タスク＋トータルタイムを足した値を時間予約
                        //もしi=Num3(初回)の時は【現在の残り時間】で予約
                        var reserveTime: Double = 0
                        reserveTime = totalNum + Double((notifiMinNum * 60) + notifiSecNum)
                        //上の時間で予約
                        pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "予定時刻を過ぎました", sound: "SE_alert01.caf", time: reserveTime, identifier: "\(i)complete")
                        print("\(i)番目：\(reserveTime)秒後予約")
                    }
                }
                //次のタスク以降の時は確実に予約
                else {
                    if notifiSecNum > 0 && notifiMinNum >= 0 {
                        var reserveTime: Double = 0
                        //もしi=Num3(初回)の時は【現在の残り時間】で予約
                        if i == Num3 {
                            reserveTime = totalNum + Double((notifiMinNum * 60) + notifiSecNum)
                        }
                        else {
                            //それ以外は合計時間＋そのタスク時間で予約
                            reserveTime = totalNum + Double(tempTotalSec)
                        }
                        //上の時間で予約
                        pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "予定時刻を過ぎました", sound: "SE_alert01.caf", time: reserveTime, identifier: "\(i)complete")
                        print("\(i)番目：\(reserveTime)秒後予約")
                    }
                }
                break
            }
            
            /*------------------------------▼タイマーストップ時▼------------------------------*/
            else {
                /*--------▼アナウンスオンの時1/2,3/4予約▼------*/
                if taskBoolListInst[Num1!][i][0] == true {
                    //1/2を出す
                    halfNum = Double(tempTotalSec / 2)
                    //3/4を計算
                    threeQuatersNum = halfNum / 2
                    
                    //読み上げ時間：合計時間と足す
                    //経過時間計算
                    let progressTime: Double = Double(tempTotalSec - ((notifiMinNum * 60) + notifiSecNum))
                    var timeHalfNum: Double
                    var timeThreeQuatersNum: Double
                    if i == Num3 {
                        timeHalfNum = halfNum - progressTime
                        timeThreeQuatersNum = halfNum + (halfNum / 2) - progressTime
                    }
                    else {
                        timeHalfNum = totalNum + halfNum
                        timeThreeQuatersNum = totalNum + halfNum + (halfNum / 2)
                    }
                    
                    //読み上げ少数切り捨て
                    let sayHalfNum: Int = Int(floor(halfNum))
                    let sayThreeQuaterNum: Int = Int(floor(threeQuatersNum))
                    //1/2予約
                    if timeHalfNum > 0 {
                        //もし通知時間が60秒以上の時
                        if timeHalfNum > 59 {
                            let sayHalfNumCon = timeConvertSecMin(time: sayHalfNum)
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayHalfNumCon.tempMinNum)分\(sayHalfNumCon.tempSecNum)秒です", sound: "SE_halfTime01.caf", time: timeHalfNum, identifier: "\(i)half")
                        }
                        //もし通知時間が59秒以下の時
                        else {
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayHalfNum)秒です", sound: "SE_halfTime01.caf", time: timeHalfNum, identifier: "\(i)half")
                            print("\(i)番目：\(timeHalfNum)秒後予約")
                        }
                    }
                    //3/4予約
                    if timeThreeQuatersNum > 0 {
                        //もし通知時間が60秒以上の時
                        if timeThreeQuatersNum > 59 {
                            let sayThreeQuaterNumCon = timeConvertSecMin(time: sayThreeQuaterNum)
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayThreeQuaterNumCon.tempMinNum)分\(sayThreeQuaterNumCon.tempSecNum)秒です", sound: "SE_halfTime01.caf", time: timeThreeQuatersNum, identifier: "\(i)threeQuaters")
                            print("\(i)番目：\(timeThreeQuatersNum)秒後予約")
                        }
                        //もし通知時間が59秒以下の時
                        else {
                            pushNotification(title: "\(taskStringListInst[Num1!][i][0])", body: "残り\(sayThreeQuaterNum)秒です", sound: "SE_halfTime01.caf", time: timeThreeQuatersNum, identifier: "\(i)threeQuaters")
                            print("\(i)番目：\(timeThreeQuatersNum)秒後予約")
                        }
                    }
                }
                //FIXME:
                /*-------------▼完了時間予約▼-------------*/
                //もし最後のタスクじゃなければ(最後のタスクなら完了通知ブレイク)
                if !(notifiSecNum <= 0 && notifiMinNum <= 0) && plusLabel.isHidden == true {
                    if i != taskStringListInst[Num1!].count - 1 {
                        //タスク＋トータルタイムを足した値を時間予約
                        //もしi=Num3(初回)の時は【現在の残り時間】で予約
                        var reserveTime: Double = 0
                        if i == Num3 {
                            reserveTime = totalNum + Double((notifiMinNum * 60) + notifiSecNum)
                        }
                        //それ以外は合計時間＋そのタスク時間で予約
                        else {
                            reserveTime = totalNum + Double(tempTotalSec)
                        }
                        pushNotification(title: "\(taskStringListInst[Num1!][i][0])を完了", body: "\(taskStringListInst[Num1!][i + 1][0])を始めてください", sound: "SE_complete01.caf", time: reserveTime, identifier: "\(i)complete")
                        print("\(i)番目：\(reserveTime)秒後予約")
                    }
                    //タイマーで最後のタスクの時、ルーチン全て完了の通知(これで全て完了しました等)ブレイク
                    else {
                        //タスク＋トータルタイムを足した値を時間予約
                        //もしi=Num3(初回)の時は【現在の残り時間】で予約
                        var reserveTime: Double = 0
                        if i == Num3 {
                            reserveTime = totalNum + Double((notifiMinNum * 60) + notifiSecNum)
                        }
                        //それ以外は合計時間＋そのタスク時間で予約
                        else {
                            reserveTime = totalNum + Double(tempTotalSec)
                        }
                        
                        pushNotification(title: "\(routinNameListInst[Num1!])を全て完了", body: "お疲れ様でした", sound: "SE_complete01.caf", time: reserveTime, identifier: "\(i)complete")
                        print("\(i)番目：\(reserveTime)秒後予約")
                        break
                    }
                }
                    
                //ブレイクされていない時現在のNum3の時間をtotalNumに加算
                //【初回の時】現在経過時間secNumとminNumを足した値を代入
                if i == Num3 {
                    totalNum += Double(( notifiMinNum * 60 ) + notifiSecNum)
                }
                //それ以外はそのタスク時間を代入
                else {
                    totalNum += Double(tempTotalSec)
                }
            }
        }
    }
    //通知予約関数
    func pushNotification(title: String, body: String, sound: String, time: Double, identifier: String){
        let content = UNMutableNotificationContent()
        content.title = "\(title)"
        content.body = "\(body)"
        content.sound = UNNotificationSound.init(named: UNNotificationSoundName(rawValue: sound))
        //完了までの時間を代入秒後に通知を表示
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    //もしフォアグラウンドに戻ったらプッシュ通知を全削除
    func removeNotification(){
        let lcNotification = UNUserNotificationCenter.current()
        lcNotification.removeAllPendingNotificationRequests()
    }
    
    /*----------------------------------------▼ラベル紐付け▼----------------------------------------*/
    //分ラベル
    @IBOutlet weak var minLabel: UILabel!
    //秒ラベル
    @IBOutlet weak var secLabel: UILabel!
    //一つ後のタスク名ラベル
    @IBOutlet weak var nextTaskNameLabel: UILabel!
    //一つ前のタスク名のラベル
    @IBOutlet weak var beforeTaskNameLabel: UILabel!
    //ストップボタン
    @IBOutlet weak var stopButton: UIButton!
    //完了ボタン
    @IBOutlet weak var completionButton: UIButton!
    //時間横のプラスマーク
    @IBOutlet weak var plusLabel: UILabel!
    //次タスクボタン
    @IBOutlet weak var nextTaskButton: UIButton!
    //前タスクボタン
    @IBOutlet weak var beforeTaskButton: UIButton!
    //次タスクラベル
    @IBOutlet weak var nexrtTaskLabel: UILabel!
    //前タスクラベル
    @IBOutlet weak var beforeTaskLabel: UILabel!
    //ルーチン名(1/8)を表示ラベル
    @IBOutlet weak var routinNameLabel: UINavigationItem!
    //前にタスク追加ボタン
    @IBOutlet weak var addBeforeTaskButton: UIButton!
    //次にタスク追加ボタン
    @IBOutlet weak var addNextTaskButton: UIButton!
    //テキストフィールド
    @IBOutlet weak var taskNameTextField: UITextField!
    //削除ボタン
    @IBOutlet weak var deleteTaskButton: UIButton!
    
    /*----------▼ボタン関係▼----------*/
    //カメラボタン
    @IBOutlet weak var cameraButton: UIButton!
    //充電ボタン
    @IBOutlet weak var butteryButton: UIButton!
    //イヤホンボタン
    @IBOutlet weak var earPhoneButton: UIButton!
    //Apple Watchボタン
    @IBOutlet weak var appleWatchButton: UIButton!
    //ショートカットボタン
    @IBOutlet weak var shortCutButton: UIButton!
    /*----------▲ここまで▲----------*/
    
    //停止方法ラベル
    @IBOutlet weak var stopMethodLabel: UILabel!
    
    /*----------------------------------------▼変数宣言▼----------------------------------------*/
    /*--------------------▼一般▼--------------------*/
    //秒数カウント
    var count = 0
    //効果音の音量倍率
    let volumeNum: Float = 1
    
    //タイマーインスタンス
    var routinTimer: Timer!
    //タイマーの動作状況チェック(ストップボタンで使用)
    var timerPlayChk = true
    //ユーザーデフォルト宣言
    var userDefaults = UserDefaults.standard
    
    var routinNameListInst:[String] = []
    var taskStringListInst:[[[String]]] = []
    var taskIntListInst:[[[Int]]] = []
    var taskBoolListInst:[[[Bool]]] = []
    
    //レコード(単体)宣言
    var taskLastRecord: [[[Int]]] = []
    //レコード(合計)宣言
    var taskLastRecordTotal: [[Int]] = []
    //セーブデータ宣言
    var taskSaveData: [[[Int]]] = []
    //SEプレイヤー01宣言
    var audioPlayer01:AVAudioPlayer!
    //SEプレイヤー02宣言
    var audioPlayer02:AVAudioPlayer!
    //合成音声宣言
    var synthesizer = AVSpeechSynthesizer()
    /*----------▼新合成音声▼----------*/
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var eqEffect = AVAudioUnitEQ()
    var converter = AVAudioConverter(from: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 22050, channels: 1, interleaved: false)!, to: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!)

    var bufferCounter: Int = 0
    
    let audioSession = AVAudioSession.sharedInstance()
    
    /*--------------------▼時間系▼--------------------*/
    //タスク毎の変数
    var Num3: Int = 0
    //タスク時間の仮箱
    var timeNum: Int = 0
    //タスク時間(秒と時間)
    var minNum: Int = 0
    var secNum: Int = 0
    //元の時間(秒と時間)
    var tmpMinNum: Int = 0
    var tmpSecNum: Int = 0
    //時間の合計
    var recHourTotal = 0
    var recMinTotal = 0
    var recSecTotal = 0
    
    //半分の時間
    var halfNum = 0
    //分
    var minHalfNum = 0
    //秒
    var secHalfNum = 0
    //3/4の時間
    var threeQuatersNum = 0
    //分
    var minThreeQuatersum = 0
    var secThreeQuatersNum = 0
    //QRリスト宣言
    var QRURLList: [String] = []
    var QRNameList: [String] = []
    
    //イヤホン検知変数
    var sensorEarphone: Bool = false

    /*----------------------------------------▼viewLoad系▼----------------------------------------*/
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        
        //SceneDelegateを取得
                guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate else {
                    return
                }
        sceneDelegate.delegate = self
        
//        //Siriショートカット設定
//        let userActivityType = NSUserActivity(activityType: "com.example.type")
//        //アクティビティに設定したタイトル名でSpotlight内での検索が可能
//        userActivityType.isEligibleForSearch = true
//        //ショートカットが使用可能
//        userActivityType.isEligibleForPrediction = true
//        //名前
//        userActivityType.title = "Sample Shortcut"
//        //アクティビティの状態を復元したい時に使用
//        userActivityType.userInfo = ["Key": "Value"]
//
//        self.userActivity = userActivityType
        
        
        /*------------------------------▼QRコード配列読み出し▼------------------------------*/
        QRURLList = userDefaults.array(forKey: "QUL") as! [String]//QRコードのURL
        QRNameList = userDefaults.array(forKey: "QNL") as! [String]//QRコードの名前
        
        
        
        
        //読み出し
        routinNameListInst = userDefaults.array(forKey: "rNL") as! [String]
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]
        taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        taskBoolListInst = userDefaults.array(forKey: "tBL") as! [[[Bool]]]
        
        taskLastRecord = userDefaults.array(forKey: "tLR") as! [[[Int]]]
        taskLastRecordTotal = userDefaults.array(forKey: "tLRT") as! [[Int]]
        taskSaveData = userDefaults.array(forKey: "tSD") as! [[[Int]]]
        
        /*----------▼音声設定呼出し▼----------*/
        taskVolumeInst = userDefaults.object(forKey: "tV") as! [Float]
        //バックミュージック流しながらでも効果音を流すコード
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.ambient)
            try audioSession.setActive(true)
        } catch let error {
            print(error)
        }
        /*----------▼SE設定▼----------*/
        let path01 = Bundle.main.path(forResource: "SE_complete01", ofType: "caf")
        let url01 = URL(fileURLWithPath: path01!)
        try! audioPlayer01 = AVAudioPlayer(contentsOf: url01)
        //事前準備
        audioPlayer01.prepareToPlay()
        /*----------▲ここまで▲----------*/
        //バックミュージック流しながらでも効果音を流すコード
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.ambient)
            try audioSession.setActive(true)
        } catch let error {
            print(error)
        }
        /*----------▼SE設定▼----------*/
        let path02 = Bundle.main.path(forResource: "SE_alert01", ofType: "caf")
        let url02 = URL(fileURLWithPath: path02!)
        try! audioPlayer02 = AVAudioPlayer(contentsOf: url02)
        //事前準備
        audioPlayer02.prepareToPlay()
        /*----------▲ここまで▲----------*/
        //完了ボタン非表示
        completionButton.isHidden = true
        //カメラボタン非表示
        cameraButton.isHidden = true
        //戻るボタン表示
        navigationItem.hidesBackButton = true
        
        plusLabel.isHidden = true
        
        minLabel.textColor = .systemCyan
        secLabel.textColor = .systemCyan
        
        
        Num3 = 0
        //テキストフィールド更新
        taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
        
        
        //タスクレコードのタスクリストの数を現在のタスクに合わせる
        if taskIntListInst[Num1!].count > taskLastRecord[Num1!].count{
            for _ in 0 ..< taskIntListInst[Num1!].count - taskLastRecord[Num1!].count {
                taskLastRecord[Num1!].append([0])
            }
        } else {
            for _ in 0 ..< taskLastRecord[Num1!].count - taskIntListInst[Num1!].count {
                taskLastRecord[Num1!].remove(at: 0)
            }
        }
        //セーブデータのタスクリストの数を現在のタスクに合わせる
        if taskIntListInst[Num1!].count > taskSaveData[Num1!].count {
            for _ in 0 ..< taskIntListInst[Num1!].count - taskSaveData[Num1!].count {
                taskSaveData[Num1!].append([0])
            }
        } else {
            for _ in 0 ..< taskSaveData[Num1!].count - taskIntListInst[Num1!].count {
                taskSaveData[Num1!].remove(at: 0)
            }
        }
        
        //タスクレコード（単体）中身がなければを増やす
        for i in 0 ..< taskLastRecord[Num1!].count {
            if taskLastRecord[Num1!][i].count < 3 {
                taskLastRecord[Num1!][i].append(0)
                taskLastRecord[Num1!][i].append(0)
            }
        }
        //タスクレコード（単体）の中身初期化
        for i in 0 ..< taskLastRecord[Num1!].count {
            taskLastRecord[Num1!][i][0] = 0
            taskLastRecord[Num1!][i][1] = 0
            taskLastRecord[Num1!][i][2] = 0
        }
        //セーブデータの中身がなければを増やす
        for i in 0 ..< taskSaveData[Num1!].count {
            if taskSaveData[Num1!][i].count < 3 {
                taskSaveData[Num1!][i].append(0)
                taskSaveData[Num1!][i].append(0)
            }
        }
        
        //タスクレコード（合計）中身をすべて0にする
        taskLastRecordTotal[Num1!][0] = 0//時間
        taskLastRecordTotal[Num1!][1] = 0//分
        taskLastRecordTotal[Num1!][2] = 0//秒
        
        //時間入力
        timeNum = taskIntListInst[Num1!][Num3][0]
        //時間コンバート
        timeConvert()
        //画面表示
        reloadItem()
        //時間をラベルに表示
        timeView()
        
        
        
        /*----------▼音声出力▼----------*/
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.play(word: "\(self.taskStringListInst[Num1!][self.Num3][0])を始めてください",volume: taskVolumeInst[0])
        }
        
        /*---------------▼イヤホン検知▼-----------------*/
        AVAudioSession.sharedInstance()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.didAudioSessionRouteChanged(_:)),
                                               name: AVAudioSession.routeChangeNotification, object: nil)

        /*-----------------▲ここまで▲---------------*/
        //バックミュージック流しながらでも効果音を流すコード
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.ambient)
            try audioSession.setActive(true)
        } catch let error {
            print(error)
        }
        /*----------▼新合成音声▼----------*/
        
        let outputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!
        setupAudio(format: outputFormat, globalGain: 0)
        /*----------------------------------------▲viewDidLoadここまで▲-----------------------------------*/
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        startTimer()
        checkTimer = true
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("viewDidDisappear")
        print("タイマー停止")
        self.routinTimer!.invalidate()
        checkTimer = false
        
    }
    
    //キーボード外を触れた時の動作
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    //タスクネームのエンターキーの動作
    @IBAction func taskNameTextFieldEnterAction(_ sender: Any) {
        self.view.endEditing(true)
    }
    /*----------------------------------------▼関数▼----------------------------------------*/
    //バックグラウンドから帰った時の時間を反映
    func reloadBackGround(){
        
        if foreChk == true {
            backChk = false
            
            //先に最後の完了ボタン押された判定入っていない時のみ進める、他はbreak（Num3>=.count）
            if Num3 < taskIntListInst[Num1!].count {
                print("Num3は\(Num3)")
                print("\(diffTime[2])秒経過")
                print("バックグラウンド反映前のタスク残り時間\(minNum)分\(secNum)秒")
                print("バックグラウンドでの計算は\(minNum)分\(secNum)秒 - \(diffTime[1])分\(diffTime[2])秒")
                /*----------------------------▼もし停止方法がタイマー以外の時▼---------------------*/
                if taskIntListInst[Num1!][Num3][1] != 1 {
                    //バックグラウンドに移る前の表示が赤じゃない時
                    if minLabel.textColor != .systemRed {
                        
                        secNum -= diffTime[2]
                        if secNum < 0 {
                            minNum -= 1
                            secNum += 60
                        }
                        
                        minNum -= diffTime[1]
                        //もし制限時間を超えていたら
                        if minNum < 0 {
                            //秒を反転させる(0:03で0:06経過した場合、-1:57になるが、
                            //正しくは+0:03と表示させたい)
                            //秒を変換(秒が0の時はそのまま使う)
                            if secNum != 0 {
                                secNum -= 60
                                secNum *= -1
                                //分を変換
                                minNum *= -1
                                minNum -= 1
                                
                            }
                            
                            minLabel.textColor = .systemRed
                            secLabel.textColor = .systemRed
                            
                            plusLabel.textColor = .systemRed
                            plusLabel.isHidden = false
                            
                            timeMinusView()
                            
                        }
                        //超えていない場合そのままタイム反映
                        else {
                            timeView()
                        }
                    }
                    //もし負の値のとき
                    else {
                        secNum += diffTime[2]
                        if secNum >= 60 {
                            secNum -= 60
                            minNum += 1
                        }
                        minNum += diffTime[1]
                        timeMinusView()
                    }
                    taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                    reloadItem()
                    /*------------------------------▲ここまで▲------------------------------*/
                }
                /*------------------------------▼停止方法がタイマーの時▼------------------------------*/
                else {
                    //Num3の最後まで回す（diffTimeから制限時間Numを引く）diffTimeが0以下:break
                    for i in Num3 ..< taskIntListInst[Num1!].count {
                        //一周目以外は更新
                        if i != Num3 {
                            timeNum = taskIntListInst[Num1!][i][0]
                            timeConvert()
                        }
                        print("iは\(i)：\(secNum) - \(diffTime[2])を計算")
                        /*----------▼回してる間でストップ方法「タイマー以外がきた時」(最後にブレイク)▼----------*/
                        if taskIntListInst[Num1!][i][1] != 1 {
                            timeNum = taskIntListInst[Num1!][i][0]
                            timeConvert()
                            
                            //負の値じゃない時
                            if minLabel.textColor != .systemRed {
                                
                                secNum -= diffTime[2]
                                if secNum < 0 {
                                    minNum -= 1
                                    secNum += 60
                                }
                                minNum -= diffTime[1]
                                //もし制限時間を超えていたら
                                if minNum < 0 {
                                    //秒を反転させる(0:03で0:06経過した場合、-1:57になるが、
                                    //正しくは+0:03と表示させたい)
                                    //秒を変換(秒が0の時はそのまま使う)
                                    if secNum != 0 {
                                        secNum -= 60
                                        secNum *= -1
                                        //分を変換
                                        minNum *= -1
                                        minNum -= 1
                                        
                                    }
                                    
                                    minLabel.textColor = .systemRed
                                    secLabel.textColor = .systemRed
                                    
                                    plusLabel.textColor = .systemRed
                                    plusLabel.isHidden = false
                                    
                                    timeMinusView()
                                    
                                }
                                //超えていない場合そのままタイム反映
                                else {
                                    timeView()
                                }
                            }
                            //もし負の値のとき
                            else {
                                secNum += diffTime[2]
                                if secNum >= 60 {
                                    secNum -= 60
                                    minNum += 1
                                }
                                timeMinusView()
                            }
                            Num3 = i
                            //先には進めないためブレイク
                            break
                            /*------------------------------▲ここまで▲------------------------------*/
                        }
                        //停止方法「タイマー」の時
                        else {
                            
                            
                            //secNum,minNum更新
                            let recHour = 0
                            let recMin = newTimeConvert(time: taskIntListInst[Num1!][i][0]).minNum
                            let recSec = newTimeConvert(time: taskIntListInst[Num1!][i][0]).secNum
                            
                            let currentMinNum = minNum
                            let currentSecNum = secNum
                            //元のdiffTime保存
                            let originalDiffTime: [Int] = [diffTime[0],diffTime[1],diffTime[2]]
                            //経過時間にタスク使用時間を反映する
                            //[1]まず秒から引く
                            diffTime[2] -= currentSecNum
                            //もし0以下になった時
                            if diffTime[2] < 0 {
                                if diffTime[1] > 0 {
                                    diffTime[1] -= 1
                                    diffTime[2] += 60
                                }
                                else if diffTime[0] > 0 {
                                    diffTime[0] -= 1
                                    diffTime[1] += 59
                                    diffTime[2] += 60
                                }
                            }
                            //[2]次に分から引く
                            diffTime[1] -= currentMinNum
                            //もし分が0以下になった時
                            if diffTime[1] < 0 {
                                if diffTime[0] > 0 {
                                    diffTime[0] -= 1
                                    diffTime[1] += 60
                                }
                            }
                            
                            //もしバックグラウンド時間の「秒」もしくは「分」が0以下になった時(元時間の方が長い)（タスク完了できず）
                            //
                            if diffTime[2] < 0 || diffTime[1] < 0 {
                                //diffTimeを引く前に戻す
                                //現在のNumを保存して、現在のNumで読み込み
                                //かつ時間からdiffTimeを引いてブレイク
                                
                                //diffTimeを引く前に戻す
                                diffTime[0] = originalDiffTime[0]
                                diffTime[1] = originalDiffTime[1]
                                diffTime[2] = originalDiffTime[2]
                                //Numを保存
                                Num3 = i
                                
                                //バックグラウンド時間を元に戻す
                                //                            if diffTime[2] > 0 || diffTime[1] > 0 || diffTime[0] > 0 {
                                //                                diffTime[2] += 2
                                //                                if diffTime[2] >= 60 {
                                //                                    diffTime[1] += 1
                                //                                    diffTime[2] -= 60
                                //                                    if diffTime[1] >= 60{
                                //                                        diffTime[0] += 1
                                //                                        diffTime[1] -= 60
                                //                                    }
                                //                                }
                                //                            }
                                
                                //元のタスクの時間からdifftimeを引く
                                secNum -= diffTime[2]
                                if secNum < 0 {
                                    minNum -= 1
                                    secNum += 60
                                }
                                minNum -= diffTime[1]
                                timeView()
                                
                                
                                break
                                
                            }
                            /*------------------------------▼タスク完了後のコード▼------------------------------*/
                            ///これからやること：タスク完了時の保存データおかしい件
                            ///タスクが次に進んだ時に時間が0のままになってる
                            //タスク保存←これいる？？？
                            taskLastRecord[Num1!][i][0] = recHour
                            taskLastRecord[Num1!][i][1] = recMin
                            taskLastRecord[Num1!][i][2] = recSec
                            
                            /*----------▼セーブデータに保存▼----------*/
                            taskSaveData[Num1!][i][0] = recHour
                            taskSaveData[Num1!][i][1] = recMin
                            taskSaveData[Num1!][i][2] = recSec
                            
                            /*----------▼時間合計▼----------*/
                            recSecTotal += recSec
                            if recSecTotal >= 60 {
                                recSecTotal -= 60
                                recMinTotal += 1
                                if recMinTotal >= 60 {
                                    recMinTotal -= 60
                                    recHourTotal += 1
                                }
                            }
                            recMinTotal += recMin
                            if recMinTotal >= 60 {
                                recMinTotal -= 60
                                recHourTotal += 1
                            }
                            recHourTotal += recHour
                            
                            taskLastRecordTotal[Num1!][0] = recHourTotal
                            taskLastRecordTotal[Num1!][1] = recMinTotal
                            taskLastRecordTotal[Num1!][2] = recSecTotal
                            
                            /*----------▼記録保存▼----------*/
                            userDefaults.set(taskLastRecord, forKey: "tLD")
                            userDefaults.set(taskSaveData, forKey: "tSD")
                            userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
                        
                            //テキストフィールドの中身更新最初のみ
                            if i == Num3 {
                                taskStringListInst[Num1!][i][0] = taskNameTextField.text!
                                userDefaults.set(taskStringListInst, forKey: "tSL")
                            }
                            
                            minLabel.textColor = .systemCyan
                            secLabel.textColor = .systemCyan
                            
                            plusLabel.isHidden = true
                            
                            //もし最後の最後までブレイクせずたどりついてたら画面遷移
                            if i == taskIntListInst[Num1!].count - 1 {
                                
                                //最後までいった時の実行
                                self.routinTimer!.invalidate()
                                checkTimer = false
                                //次の画面に遷移
                                self.performSegue(withIdentifier: "toScore", sender: nil)
                            }
                        }
                        /*------------------------------▲ここまで▲------------------------------*/
                    }
                    /*------------------------------▲ここまで▲------------------------------*/
                }
            }
        }
        taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
        reloadItem()
    }
    //全てリロード
    func reloadItem(){
        
        /*----------▼完了ボタンとカメラボタン切り替え設定▼----------*/
        //完了ボタン全て非表示
        hiddenButton()
        /*----------▼なし/タイマー▼----------*/
        if taskIntListInst[Num1!][Num3][1] == 0 || taskIntListInst[Num1!][Num3][1] == 1 {
            //完了ボタン表示
            completionButton.isHidden = false
        /*----------▼停止方法：QRコードの時▼----------*/
        } else if taskIntListInst[Num1!][Num3][1] == 2 {
            //カメラボタン表示・使用可能
            cameraButton.isHidden = false
            //QRコード変数に認証コード格納
            tempQRurl = QRURLList[taskIntListInst[Num1!][Num3][3]]
        }
        /*----------▼ショートカット▼----------*/
        else if taskIntListInst[Num1!][Num3][1] == 3 {
            shortCutButton.isHidden = false
        }
        /*----------▼充電▼----------*/
        else if taskIntListInst[Num1!][Num3][1] == 4 {
            butteryButton.isHidden = false
        }
        /*----------▼イヤホン▼----------*/
        else if taskIntListInst[Num1!][Num3][1] == 5 {
            earPhoneButton.isHidden = false
        }
        /*----------▼Apple Watch▼----------*/
        else if taskIntListInst[Num1!][Num3][1] == 6 {
            appleWatchButton.isHidden = false
        }
        /*--------------------▼左ボタン非表示▼--------------------*/
        if Num3 == 0 {
            beforeTaskButton.isHidden = true
        }
        else {
            beforeTaskButton.isHidden = false
        }
        /*--------------------▼右非表示▼--------------------*/
        if Num3 == taskStringListInst[Num1!].count - 1 {
            nextTaskButton.isHidden = true
        }
        else {
            nextTaskButton.isHidden = false
        }
        
        
        /*----------▼ラベル反映▼----------*/
                
        routinNameLabel.title = ("\(routinNameListInst[Num1!])(\(Num3 + 1)/\(taskStringListInst[Num1!].count))")
        /*--------------------▼前タスク更新▼--------------------*/
        if Num3 > 0 {
            beforeTaskNameLabel.text = ("前:\(taskStringListInst[Num1!][Num3 - 1][0])")
        }
        else {
            beforeTaskNameLabel.text = ("-")
        }
        /*--------------------▼次タスク更新▼--------------------*/
        if Num3 < taskStringListInst[Num1!].count - 1 {
            nextTaskNameLabel.text = ("次:\(taskStringListInst[Num1!][Num3 + 1][0])")
        }
        else {
            nextTaskNameLabel.text = ("-")
        }
        //時間読み込み
        timeNum = taskIntListInst[Num1!][Num3][0]
        /*----------▼停止方法ラベル反映▼----------*/
        if taskIntListInst[Num1!][Num3][1] == 0 {
            stopMethodLabel.text = "-"
        }
        else if taskIntListInst[Num1!][Num3][1] == 1 {
            stopMethodLabel.text = "タイマー"
        }
        else if taskIntListInst[Num1!][Num3][1] == 2 {
            stopMethodLabel.text = "QRコード:\(QRNameList[taskIntListInst[Num1!][Num3][3]])"
        }
        else if taskIntListInst[Num1!][Num3][1] == 3 {
            stopMethodLabel.text = "ショートカット"
        }
        else if taskIntListInst[Num1!][Num3][1] == 4 {
            stopMethodLabel.text = "充電"
        }
        else if taskIntListInst[Num1!][Num3][1] == 5 {
            stopMethodLabel.text = "イヤホン装着"
        }
        else if taskIntListInst[Num1!][Num3][1] == 6 {
            stopMethodLabel.text = "AppleWatch装着"
        }
        
        
    }
    //読み上げ用時間変換(時間コンバートの後に使用)
    func sayTimeConvert(){
        let totalNum = minNum * 60 + secNum * 1
        halfNum = totalNum / 2
        threeQuatersNum = halfNum / 2
        
        /*----------▼ハーフナムを分秒に変換▼----------*/
        minHalfNum = halfNum / 60
        secHalfNum = halfNum % 60
        /*----------▼3/4ナムを分秒に変換▼----------*/
        minThreeQuatersum = threeQuatersNum / 60
        secThreeQuatersNum = threeQuatersNum % 60
    }
    
    
    //時間コンバート
    func timeConvert(){
        /*----------▼分の位▼----------*/
        //分の位を代入
        minNum = timeNum / 100
        /*----------▼秒の位▼----------*/
        //元時間を秒の位にする
        timeNum = timeNum % 100
        //秒の位を代入
        secNum = timeNum / 1
        //もし60秒以上の時繰り上げ
        if secNum >= 60 {
            secNum -= 60
            minNum += 1

        }
        if minNum > 99 {
            minNum = 99
        }
        /*----------▼オリジナル時間を抜き取る▼----------*/
        tmpMinNum = minNum
        tmpSecNum = secNum
        /*----------▼音声用の時間変換▼----------*/
        sayTimeConvert()
    }
    //新時間コンバート...654=6分54秒
    func newTimeConvert(time: Int) -> (minNum: Int, secNum: Int){
        var minNum = 0
        var secNum = 0
        var timeNum = time
        /*----------▼分の位▼----------*/
        //分の位を代入
        minNum = timeNum / 100
        /*----------▼秒の位▼----------*/
        //元時間を秒の位にする
        timeNum = timeNum % 100
        //秒の位を代入
        secNum = timeNum / 1
        //もし60秒以上の時繰り上げ
        if secNum >= 60 {
            secNum -= 60
            minNum += 1

        }
        if minNum > 99 {
            minNum = 99
        }
        
        return (minNum, secNum)
    }
    //秒を分秒に変換
    func timeConvertSecMin(time: Int) -> (tempMinNum: Int, tempSecNum: Int){
        let tempMinNum = time / 60
        let tempSecNum = time % 60
        
        return (tempMinNum, tempSecNum)
    }
    //時間反映（正の値）！！！！時間しか読み込まれてない！！！！
    func timeView(){
        //分
        if minNum == 0 {
            minLabel.text = ("00")
        }
        else if minNum < 10 {
            minLabel.text = ("0\(minNum)")
        }
        else if minNum < 100 {
            minLabel.text = ("\(minNum)")
        }
        else {
            minLabel.text = ("99")
            secLabel.text = ("99")
        }
        //秒
        if minNum < 100 {
            if secNum == 0 {
                secLabel.text = ("00")
            }
            else if secNum < 10 {
                secLabel.text = ("0\(secNum)")
            }
            else {
                secLabel.text = ("\(secNum)")
            }
        }
    }
    //時間反映(負の値)←上と同じやわ！！！！時間しか読み込まれてない！！！！
    func timeMinusView(){
        //分
        if minNum == 0 {
            minLabel.text = ("00")
        }
        else if minNum < 10 {
            minLabel.text = ("0\(minNum)")
        }
        else if minNum < 100 {
            minLabel.text = ("\(minNum)")
        }
        else {
            minLabel.text = ("99")
            secLabel.text = ("99")
        }
        //秒
        if minNum < 100 {
            if secNum == 0 {
                secLabel.text = ("00")
            }
            else if secNum < 10 {
                secLabel.text = ("0\(secNum)")
            }
            else {
                secLabel.text = ("\(secNum)")
            }
        }
    }
    //ボタンをすべて使用不可
    func buttonNotUse(){
        completionButton.isEnabled = false
        cameraButton.isEnabled = false
//        if Num3 == taskIntListInst[Num1!].count{
//            nextTaskButton.isEnabled = false
//            beforeTaskButton.isEnabled = false
//            stopButton.isEnabled = false
//        }
    }
    //ボタンすべて使用可
    func buttonUse(){
        completionButton.isEnabled = true
        cameraButton.isEnabled = true
        nextTaskButton.isEnabled = true
        beforeTaskButton.isEnabled = true
        stopButton.isEnabled = true
    }
    //セーブデータ等の配列の数合わせ
    func reloadList(){
        //タスクレコードのタスクリストの数を現在のタスクに合わせる
        for _ in 0 ..< taskIntListInst[Num1!].count - taskLastRecord[Num1!].count {
            taskLastRecord[Num1!].append([0])
        }
        //セーブデータのタスクリストの数を現在のタスクに合わせる
        for _ in 0 ..< taskIntListInst[Num1!].count - taskSaveData[Num1!].count {
            taskSaveData[Num1!].append([0])
        }
        
        //タスクレコード（単体）中身がなければを増やす
        for i in 0 ..< taskLastRecord[Num1!].count {
            if taskLastRecord[Num1!][i].count < 3 {
                taskLastRecord[Num1!][i].append(0)
                taskLastRecord[Num1!][i].append(0)
            }
        }
    }
    //イヤホン検知
    @objc private func didAudioSessionRouteChanged(_ notification: Notification) {
        guard let desc = notification.userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AVAudioSessionRouteDescription
        else { return }
        let outputs = desc.outputs
        for component in outputs {
            if component.portType == AVAudioSession.Port.headphones ||
                component.portType == AVAudioSession.Port.bluetoothA2DP ||
                component.portType == AVAudioSession.Port.bluetoothLE ||
                component.portType == AVAudioSession.Port.bluetoothHFP {
                //イヤホン(Bluetooth含む)が抜かれた時の処理
                sensorEarphone = false
                return
            }
        }
        // イヤホン(Bluetooth含む)が刺された時の処理
        sensorEarphone = true
    }
    //完了ボタン全て非表示
    func hiddenButton(){
        cameraButton.isHidden = true
        butteryButton.isHidden = true
        shortCutButton.isHidden = true
        earPhoneButton.isHidden = true
        appleWatchButton.isHidden = true
        completionButton.isHidden = true
    }
    
    /*----------▼新合成音声▼----------*/
    func activateAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .voicePrompt, options: [.mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("エラー02")
        }
    }
    func play(word: String,volume: Float) {
        self.eqEffect.globalGain = volume
        let utterance = AVSpeechUtterance(string: word)
        synthesizer.write(utterance) { buffer in
            guard let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 else {
//                print("エラー01")
                return
            }
            
            //QUIRCKAVAudioEngineはAVSpeechSynthesizerから返される形式をサポートしていないため、バッファーを別の形式に変換する必要があります
            let convertedBuffer = AVAudioPCMBuffer(pcmFormat: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: pcmBuffer.format.sampleRate, channels: pcmBuffer.format.channelCount, interleaved: false)!, frameCapacity: pcmBuffer.frameCapacity)!
            do {
                try self.converter!.convert(to: convertedBuffer, from: pcmBuffer)
                self.bufferCounter += 1
                self.player.scheduleBuffer(convertedBuffer, completionCallbackType: .dataPlayedBack, completionHandler: { (type) -> Void in
                    DispatchQueue.main.async {
                        self.bufferCounter -= 1
//                        print(self.bufferCounter)
                        if self.bufferCounter == 0 {
                            self.player.stop()
                            self.engine.stop()
//                            try! self.audioSession.setActive(false, options: [])
                        }
                    }
                    
                })
                
                self.converter!.reset()
                //self.player.prepare(withFrameCount: convertedBuffer.frameLength)
            }
            catch _ {
//                print(error.localizedDescription)
            }
        }
        activateAudioSession()
        if !self.engine.isRunning {
            try! self.engine.start()
        }
        if !self.player.isPlaying {
            self.player.play()
        }
    }
    func setupAudio(format: AVAudioFormat, globalGain: Float) {

        try? self.audioSession.setCategory(.ambient, options: .mixWithOthers)
        
        eqEffect.globalGain = globalGain
        engine.attach(player)
        engine.attach(eqEffect)
        engine.connect(player, to: eqEffect, format: format)
        engine.connect(eqEffect, to: engine.mainMixerNode, format: format)
        engine.prepare()
        
    }
    /*------------------------------▼タイマー関係▼------------------------------*/
    //タイマー設定
    func startTimer() {
        self.routinTimer = Timer.scheduledTimer(timeInterval: 1,
                                                target:self,
                                                selector:#selector(self.changeTimerLable),
                                                userInfo:nil,
                                                repeats:true)
        }
    //1秒毎に実行する関数
    @objc func changeTimerLable() {
        
        count += 1
        print("\(count)秒：Num3は\(Num3)")
        let taskIntListInst = userDefaults.array(forKey: "tIL") as! [[[Int]]]
        //タスクが最後になるまで繰り返す
        if Num3 < taskIntListInst[Num1!].count {
            //ボタンを押せるように
            buttonUse()
            
            
            /*------------------------------▼タスク停止方法：なし▼------------------------------*/
            if taskIntListInst[Num1!][Num3][1] == 0 {
                //{値が正の時//分が0以上秒が1以上もしくは分が1以上秒が0} かつ　{ミンラベルが赤じゃないとき}
                if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                    //時間経過
                    secNum -= 1
                    //秒が0以下になったら
                    if secNum < 0 {
                        //60秒に戻す
                        secNum = 59
                        //分を1削る
                        minNum -= 1
                    }
                    /*ビュー表示*/
                    timeView()
                    /*----------▼残り時間アナウンス▼----------*/
                    if taskBoolListInst[Num1!][Num3][0] == true {
                        if (minNum == minHalfNum) && (secNum == secHalfNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        }
                    }
                }
                //値が負の時
                else {
                    
                    minLabel.textColor = .systemRed
                    secLabel.textColor = .systemRed
                    
                    plusLabel.textColor = .systemRed
                    plusLabel.isHidden = false
                    secNum += 1
                    
                    /*----------▼合成音声出力▼----------*/
                    
                    if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0 {
                        /*----------▼SE音声出力▼----------*/
                        if audioPlayer02.isPlaying {
                            audioPlayer02.stop()
                            audioPlayer02.currentTime = 0
                        }
                        audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                        audioPlayer02.play()
                        /*----------▲ここまで▲----------*/
                        DispatchQueue.main.asyncAfter(deadline: .now()){
                            self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                        }
                    }
                    //60秒以上になったら
                    if secNum >= 60 {
                        //0秒に戻す
                        secNum = 0
                        //分を1足す
                        minNum += 1
                    }
                    timeMinusView()
                    
                }
                taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                reloadItem()
            }
            /*------------------------------▼タスク停止方法：タイマー▼------------------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 1 {
                //値が正の時
                if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                    //時間経過
                    secNum -= 1
                    //秒が0以下になったら
                    if secNum < 0 {
                        //60秒に戻す
                        secNum = 59
                        //分を1削る
                        minNum -= 1
                    }
                    /*ビュー表示*/
                    timeView()
                    /*----------▼残り時間アナウンス▼----------*/
                    if taskBoolListInst[Num1!][Num3][0] == true {
                        if (minNum == minHalfNum) && (secNum == secHalfNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        }
                    }
                }
                //値が負の時：完了ボタン押した判定
                else {
                    self.completionButtonAction(completionButton as Any)
                }
            }
            /*------------------------------▼タスク停止方法：QRコード▼------------------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 2 {
                //もし認証が成立したら
                if chkNextTask == true{
                    chkNextTask = false
                    //完了ボタンを押した判定にする
                    self.completionButtonAction(completionButton as Any)
                }
                else {
                    //値が正の時
                    if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                        //時間経過
                        secNum -= 1
                        //秒が0以下になったら
                        if secNum < 0 {
                            //60秒に戻す
                            secNum = 59
                            //分を1削る
                            minNum -= 1
                        }
                        /*ビュー表示*/
                        timeView()
                        /*----------▼残り時間アナウンス▼----------*/
                        if taskBoolListInst[Num1!][Num3][0] == true {
                            if (minNum == minHalfNum) && (secNum == secHalfNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            }
                        }
                    }
                    //値が負の時
                    else {
                        
                        minLabel.textColor = .systemRed
                        secLabel.textColor = .systemRed
                        
                        plusLabel.textColor = .systemRed
                        plusLabel.isHidden = false
                        secNum += 1
                        
                        /*----------▼合成音声出力▼----------*/
                        
                        if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0  {
                            /*----------▼SE音声出力▼----------*/
                            if audioPlayer02.isPlaying {
                                audioPlayer02.stop()
                                audioPlayer02.currentTime = 0
                            }
                            audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                            audioPlayer02.play()
                            /*----------▲ここまで▲----------*/
                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                            }
                        }
                        //60秒以上になったら
                        if secNum >= 60 {
                            //0秒に戻す
                            secNum = 0
                            //分を1足す
                            minNum += 1
                        }
                        timeMinusView()
                        
                    }
                    taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                    reloadItem()
                }
            }
            /*------------------------------▼タスク停止方法：ショートカット完了▼-----------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 3 {
                //値が正の時
                if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                    
                    //時間経過
                    secNum -= 1
                    //秒が0以下になったら
                    if secNum < 0 {
                        //60秒に戻す
                        secNum = 59
                        //分を1削る
                        minNum -= 1
                    }
                    /*ビュー表示*/
                    timeView()
                    /*----------▼残り時間アナウンス▼----------*/
                    if taskBoolListInst[Num1!][Num3][0] == true {
                        if (minNum == minHalfNum) && (secNum == secHalfNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        }
                    }
                }
                //値が負の時
                else {
                    
                    minLabel.textColor = .systemRed
                    secLabel.textColor = .systemRed
                    
                    plusLabel.textColor = .systemRed
                    plusLabel.isHidden = false
                    secNum += 1
                    
                    /*----------▼合成音声出力▼----------*/
                    
                    if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0  {
                        /*----------▼SE音声出力▼----------*/
                        if audioPlayer02.isPlaying {
                            audioPlayer02.stop()
                            audioPlayer02.currentTime = 0
                        }
                        audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                        audioPlayer02.play()
                        /*----------▲ここまで▲----------*/
                        DispatchQueue.main.asyncAfter(deadline: .now()){
                            self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                        }
                    }
                    //60秒以上になったら
                    if secNum >= 60 {
                        //0秒に戻す
                        secNum = 0
                        //分を1足す
                        minNum += 1
                    }
                    timeMinusView()
                    
                }
                taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                reloadItem()
            }
            /*------------------------------▼タスク停止方法：充電▼------------------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 4 {
                /*------------------------------▼充電関係▼------------------------------*/
                //充電中検知
                let batStatus: UIDevice.BatteryState = UIDevice.current.batteryState
                UIDevice.current.isBatteryMonitoringEnabled = true
                
                if batStatus == .charging || batStatus == .full {
                    self.completionButtonAction(completionButton as Any)
                }
                else{
                    //値が正の時
                    if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                        //時間経過
                        secNum -= 1
                        //秒が0以下になったら
                        if secNum < 0 {
                            //60秒に戻す
                            secNum = 59
                            //分を1削る
                            minNum -= 1
                        }
                        /*ビュー表示*/
                        timeView()
                        /*----------▼残り時間アナウンス▼----------*/
                        if taskBoolListInst[Num1!][Num3][0] == true {
                            if (minNum == minHalfNum) && (secNum == secHalfNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            }
                        }
                    }
                    //値が負の時
                    else {
                        
                        minLabel.textColor = .systemRed
                        secLabel.textColor = .systemRed
                        
                        plusLabel.textColor = .systemRed
                        plusLabel.isHidden = false
                        secNum += 1
                        
                        /*----------▼合成音声出力▼----------*/
                        
                        if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0  {
                            /*----------▼SE音声出力▼----------*/
                            if audioPlayer02.isPlaying {
                                audioPlayer02.stop()
                                audioPlayer02.currentTime = 0
                            }
                            audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                            audioPlayer02.play()
                            /*----------▲ここまで▲----------*/
                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                            }
                        }
                        //60秒以上になったら
                        if secNum >= 60 {
                            //0秒に戻す
                            secNum = 0
                            //分を1足す
                            minNum += 1
                        }
                        timeMinusView()
                        
                    }
                    taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                    reloadItem()
                }
            }
            /*------------------------------▼タスク停止方法：bluetoothイヤホン装着▼-------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 5 {
                if sensorEarphone == true {
                    sensorEarphone = false
                    self.completionButtonAction(completionButton as Any)
                }else{
                    
                    //値が正の時
                    if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                        //時間経過
                        secNum -= 1
                        //秒が0以下になったら
                        if secNum < 0 {
                            //60秒に戻す
                            secNum = 59
                            //分を1削る
                            minNum -= 1
                        }
                        /*ビュー表示*/
                        timeView()
                        /*----------▼残り時間アナウンス▼----------*/
                        if taskBoolListInst[Num1!][Num3][0] == true {
                            if (minNum == minHalfNum) && (secNum == secHalfNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                                /*----------▼合成音声出力▼----------*/
                                self.synthesizer.stopSpeaking(at: .immediate)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now()) {
                                    if self.minNum > 0 || self.secNum > 0 {
                                        if self.minNum > 0 {
                                            if self.secNum > 0 {
                                                self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                            } else {
                                                self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                            }
                                        } else {
                                            self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        }
                                        
                                    }
                                }
                                /*----------▲ここまで▲----------*/
                            }
                        }
                    }
                    //値が負の時
                    else {
                        
                        minLabel.textColor = .systemRed
                        secLabel.textColor = .systemRed
                        
                        plusLabel.textColor = .systemRed
                        plusLabel.isHidden = false
                        secNum += 1
                        
                        /*----------▼合成音声出力▼----------*/
                        
                        if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0  {
                            /*----------▼SE音声出力▼----------*/
                            if audioPlayer02.isPlaying {
                                audioPlayer02.stop()
                                audioPlayer02.currentTime = 0
                            }
                            audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                            audioPlayer02.play()
                            /*----------▲ここまで▲----------*/
                            DispatchQueue.main.asyncAfter(deadline: .now()){
                                self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                            }
                        }
                        //60秒以上になったら
                        if secNum >= 60 {
                            //0秒に戻す
                            secNum = 0
                            //分を1足す
                            minNum += 1
                        }
                        timeMinusView()
                        
                    }
                    taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                    reloadItem()
                }
            }
            /*------------------------------▼タスク停止方法：appleWatch装着▼-----------------------*/
            else if taskIntListInst[Num1!][Num3][1] == 6 {
                //もしアップルウォッチが装着されたら...
                
                //されてない時
                //値が正の時
                if ((minNum >= 0 && secNum > 0) || (minNum > 0 && secNum == 0)) && minLabel.textColor != .systemRed {
                    //時間経過
                    secNum -= 1
                    //秒が0以下になったら
                    if secNum < 0 {
                        //60秒に戻す
                        secNum = 59
                        //分を1削る
                        minNum -= 1
                    }
                    /*ビュー表示*/
                    timeView()
                    /*----------▼残り時間アナウンス▼----------*/
                    if taskBoolListInst[Num1!][Num3][0] == true {
                        if (minNum == minHalfNum) && (secNum == secHalfNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        } else if (minNum == minThreeQuatersum) && (secNum == secThreeQuatersNum) {
                            /*----------▼合成音声出力▼----------*/
                            self.synthesizer.stopSpeaking(at: .immediate)
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()) {
                                if self.minNum > 0 || self.secNum > 0 {
                                    if self.minNum > 0 {
                                        if self.secNum > 0 {
                                            self.play(word: "残り\(self.minNum)分\(self.secNum)秒です",volume: taskVolumeInst[0])
                                        } else {
                                            self.play(word: "残り\(self.minNum)分です",volume: taskVolumeInst[0])
                                        }
                                    } else {
                                        self.play(word: "残り\(self.secNum)秒です",volume: taskVolumeInst[0])
                                    }
                                    
                                }
                            }
                            /*----------▲ここまで▲----------*/
                        }
                    }
                }
                //値が負の時
                else {
                    
                    minLabel.textColor = .systemRed
                    secLabel.textColor = .systemRed
                    
                    plusLabel.textColor = .systemRed
                    plusLabel.isHidden = false
                    secNum += 1
                    
                    /*----------▼合成音声出力▼----------*/
                    
                    if secNum == 1 && minNum == 0 && taskIntListInst[Num1!][Num3][0] != 0  {
                        /*----------▼SE音声出力▼----------*/
                        if audioPlayer02.isPlaying {
                            audioPlayer02.stop()
                            audioPlayer02.currentTime = 0
                        }
                        audioPlayer02.volume = taskVolumeInst[1] * volumeNum
                        audioPlayer02.play()
                        /*----------▲ここまで▲----------*/
                        DispatchQueue.main.asyncAfter(deadline: .now()){
                            self.play(word: "予定時刻を過ぎました",volume: taskVolumeInst[0])
                        }
                    }
                    //60秒以上になったら
                    if secNum >= 60 {
                        //0秒に戻す
                        secNum = 0
                        //分を1足す
                        minNum += 1
                    }
                    timeMinusView()
                    
                }
                taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
                reloadItem()
            }
            
        }
        /*----------▼タスクが最後まで行ったら止める▼----------*/
        else {
//            print("タイマーを破棄")
//            self.routinTimer!.invalidate()
//            checkTimer = false
            
            userDefaults.set(taskLastRecord, forKey: "tLR")
            userDefaults.set(taskSaveData, forKey: "tSD")
            userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
            //次の画面に遷移
            self.performSegue(withIdentifier: "toScore", sender: nil)
        }
        
    }
    /*----------------------------------------▼ボタンアクション▼----------------------------------------*/
    //完了ボタンアクション
    @IBAction func completionButtonAction(_ sender: Any) {
        //アナウンス停止
        self.player.stop()
        //ボタン使えなくする
        buttonNotUse()
        //今回の記録変数の宣言(毎回初期化)
        var recHour = 0
        var recMin = 0
        var recSec = 0
        /*------------------------------▼時間単体保存▼------------------------------*/
        /*----------▼制限内に押した時▼----------*/
        if plusLabel.isHidden == true {
            //完了までの時間=元時間-現在の時間
            recMin = tmpMinNum - minNum
            recSec = tmpSecNum - secNum
            if recSec < 0 {
                recMin -= 1
                recSec += 60
            }
        }
        /*----------▼制限時間外に押した時▼----------*/
        else {
            //元時間+現在の時間
            recSec = tmpSecNum + secNum
            if recSec >= 60 {
                recSec -= 60
                minNum += 1
                if minNum >= 60 {
                    minNum -= 60
                    recHour += 1
                }
            }
            recMin = tmpMinNum + minNum
            if recMin >= 60 {
                recMin -= 60
                recHour += 1
            }
        }
        /*----------▼記録保存▼----------*/
//        taskLastRecord[Num1!][Num3][0] = recHour
//        taskLastRecord[Num1!][Num3][1] = recMin
//        taskLastRecord[Num1!][Num3][2] = recSec
        
        /*----------▼セーブデータに保存▼----------*/
        taskSaveData[Num1!][Num3][0] = recHour
        taskSaveData[Num1!][Num3][1] = recMin
        taskSaveData[Num1!][Num3][2] = recSec
        
        //時間分秒を保存
        userDefaults.set(taskLastRecord, forKey: "tLR")
        userDefaults.set(taskSaveData, forKey: "tSD")
        /*------------------------------▼時間合計▼------------------------------*/
        recSecTotal += recSec
        if recSecTotal >= 60 {
            recSecTotal -= 60
            recMinTotal += 1
            if recMinTotal >= 60 {
                recMinTotal -= 60
                recHourTotal += 1
            }
        }
        recMinTotal += recMin
        if recMinTotal >= 60 {
            recMinTotal -= 60
            recHourTotal += 1
        }
        recHourTotal = recHourTotal + recHour
        
        
        taskLastRecordTotal[Num1!][0] = recHourTotal
        taskLastRecordTotal[Num1!][1] = recMinTotal
        taskLastRecordTotal[Num1!][2] = recSecTotal
        /*----------▼記録保存▼----------*/
        userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
        
        //テキストフィールドの情報更新
        taskStringListInst[Num1!][Num3][0] = "\((taskNameTextField.text)!)"
        userDefaults.set(taskStringListInst, forKey: "tSL")
        
        /*------------------------------▼次のタスクに移行▼------------------------------*/
        Num3 += 1
        //ボタン使用不可
        if Num3 == taskIntListInst[Num1!].count {
            nextTaskButton.isEnabled = false
            beforeTaskButton.isEnabled = false
            stopButton.isEnabled = false
            addNextTaskButton.isEnabled = false
            addBeforeTaskButton.isEnabled = false
            deleteTaskButton.isEnabled = false
        }
        
        
        minLabel.textColor = .systemCyan
        secLabel.textColor = .systemCyan
        
        plusLabel.isHidden = true
        
        if Num3 == taskIntListInst[Num1!].count {
            self.synthesizer.stopSpeaking(at: .immediate)
            //効果音
            /*----------▼SE音声出力▼----------*/
            if audioPlayer01.isPlaying {
                audioPlayer01.stop()
                audioPlayer01.currentTime = 0
            }
            audioPlayer01.volume = taskVolumeInst[1]
            audioPlayer01.play()
            /*----------▲ここまで▲----------*/
            
            //戻るボタン非表示
            navigationItem.hidesBackButton = true
            
            self.routinTimer!.invalidate()
            checkTimer = false
            
            userDefaults.set(taskLastRecord, forKey: "tLR")
            userDefaults.set(taskSaveData, forKey: "tSD")
            userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
            //次の画面に遷移
            self.performSegue(withIdentifier: "toScore", sender: nil)
        } else {
            taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
            reloadItem()
            //時間コンバート
            timeConvert()
            
            timeView()
            
            /*----------▼音声出力▼----------*/
            self.synthesizer.stopSpeaking(at: .immediate)
            //効果音
            /*----------▼SE音声出力▼----------*/
            if audioPlayer01.isPlaying {
                audioPlayer01.stop()
                audioPlayer01.currentTime = 0
            }
            audioPlayer01.volume = taskVolumeInst[1]
            audioPlayer01.play()
            /*----------▲ここまで▲----------*/
            
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.play(word: "\(self.taskStringListInst[Num1!][self.Num3][0])を始めてください",volume: taskVolumeInst[0])
            }
        }
        
        
    }
    //ストップボタンアクション
    @IBAction func stopButtonAction(_ sender: Any) {
        buttonNotUse()
        //スタートボタンイメージ
        var playImage = UIButton.Configuration.filled()
        playImage.image = UIImage(systemName: "play.fill",withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        playImage.cornerStyle = .capsule
        playImage.baseBackgroundColor = .lightGray
        //ストップボタンイメージ
        var stopImage = UIButton.Configuration.filled()
        stopImage.image = UIImage(systemName: "pause.fill",withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        stopImage.cornerStyle = .capsule
        stopImage.baseBackgroundColor = .lightGray
        
        if timerPlayChk == true {
            //タイマーを止める
            self.routinTimer!.invalidate()
            checkTimer = false
            
            stopButton.configuration = playImage
            timerPlayChk.toggle()
        } else {
            //タイマー開始
            startTimer()
            checkTimer = true
            
            stopButton.configuration = stopImage
            timerPlayChk.toggle()
        }
        
    }
    //次タスクボタンアクション
    @IBAction func nextTaskButtonAction(_ sender: Any) {
        //アナウンス停止
        self.player.stop()
        //ボタン使えなくする
        buttonNotUse()
        if Num3 == taskIntListInst[Num1!].count - 2 {
            nextTaskButton.isEnabled = false
        }
        else {
            nextTaskButton.isEnabled = true
        }
        
        taskStringListInst[Num1!][Num3][0] = "\((taskNameTextField.text)!)"
        userDefaults.set(taskStringListInst, forKey: "tSL")
        
        Num3 += 1
        
        if Num3 == taskIntListInst[Num1!].count {
            nextTaskButton.isEnabled = false
            beforeTaskButton.isEnabled = false
            stopButton.isEnabled = false
            addNextTaskButton.isEnabled = false
            addBeforeTaskButton.isEnabled = false
            deleteTaskButton.isEnabled = false
        }
        
        minLabel.textColor = .systemCyan
        secLabel.textColor = .systemCyan
        
        plusLabel.isHidden = true
        
        //タスクの数以内ならリロード実行
        if Num3 < taskIntListInst[Num1!].count {
            taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
            
            reloadItem()
            //時間コンバート
            timeConvert()
            
            timeView()
            /*----------▼音声出力▼----------*/
            self.player.stop()
            //効果音
            DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.play(word: "\(self.taskStringListInst[Num1!][self.Num3][0])を始めてください",volume: taskVolumeInst[0])
            }
        } else {
            //戻るボタン非表示
            navigationItem.hidesBackButton = true
            
            self.synthesizer.stopSpeaking(at: .immediate)
            
            /*----------▼SE音声出力▼----------*/
            if audioPlayer01.isPlaying {
                audioPlayer01.stop()
                audioPlayer01.currentTime = 0
            }
            audioPlayer01.volume = taskVolumeInst[1]
            audioPlayer01.play()
            /*----------▲ここまで▲----------*/
            
            self.routinTimer!.invalidate()
            checkTimer = false
            
            userDefaults.set(taskLastRecord, forKey: "tLR")
            userDefaults.set(taskSaveData, forKey: "tSD")
            userDefaults.set(taskLastRecordTotal, forKey: "tLRT")
            //次の画面に遷移
            self.performSegue(withIdentifier: "toScore", sender: nil)
        }
        
    }
    //前タスクボタンアクション
    @IBAction func beforeTaskButtonAction(_ sender: Any) {
        //アナウンス停止
        self.player.stop()
        //ボタン使えなくする
        buttonNotUse()
        if Num3 == taskIntListInst[Num1!].count - 2 {
            nextTaskButton.isEnabled = false
        }
        else {
            nextTaskButton.isEnabled = true
        }
        taskStringListInst[Num1!][Num3][0] = "\((taskNameTextField.text)!)"
        userDefaults.set(taskStringListInst, forKey: "tSL")
        
        Num3 -= 1
        
        taskNameTextField.text = taskStringListInst[Num1!][Num3][0]
        
        minLabel.textColor = .systemCyan
        secLabel.textColor = .systemCyan
        
        plusLabel.isHidden = true
        
        
        reloadItem()
        //時間コンバート
        timeConvert()
    
        timeView()
        
        /*----------▼音声出力▼----------*/
        self.player.stop()
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.play(word: "\(self.taskStringListInst[Num1!][self.Num3][0])を始めてください",volume: taskVolumeInst[0])
        }
    }
    //前タスク追加ボタン
    @IBAction func addBeforeTaskButtonAction(_ sender: Any) {
        //黙らせる
        self.player.stop()
        //タイマーを止める
        var chkTimer: Bool = false
        if checkTimer == true {
            self.routinTimer!.invalidate()
            checkTimer = false
            chkTimer = true
        }
        //アラート
        let alert = UIAlertController(title: "前に新規タスクを追加", message: "", preferredStyle: .alert)
        //テキストフィールド
        alert.addTextField(configurationHandler: nil)
        alert.textFields?.first?.placeholder = "新規タスク"
                
        
        let add = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("OK")
            //追加する前にテキスト追加
            self.taskStringListInst[Num1!][self.Num3][0] = "\((self.taskNameTextField.text)!)"
            self.userDefaults.set(self.taskStringListInst, forKey: "tSL")
            //ここから実行内容
            let insertStringItem = ["\((alert.textFields?.first?.text)!)"]
            let insertIntItem = [0, 0, 0]
            let insertBoolItem = [false]
            let insertLastRecord = [0,0,0]
            let insertSabeData = [0,0,0]
            
            self.taskStringListInst[Num1!].insert(insertStringItem,at: self.Num3)
            self.taskIntListInst[Num1!].insert(insertIntItem,at: self.Num3)
            self.taskBoolListInst[Num1!].insert(insertBoolItem,at: self.Num3)
            self.taskLastRecord[Num1!].insert(insertLastRecord,at: self.Num3)
            self.taskSaveData[Num1!].insert(insertSabeData,at: self.Num3)
            
            self.userDefaults.set(self.taskStringListInst, forKey: "tSL")
            self.userDefaults.set(self.taskIntListInst, forKey: "tIL")
            self.userDefaults.set(self.taskBoolListInst, forKey: "tBL")
            self.userDefaults.set(self.taskLastRecord, forKey: "tLR")
            self.userDefaults.set(self.taskSaveData, forKey: "tSD")
            
            //テキスト更新
            self.taskNameTextField.text = self.taskStringListInst[Num1!][self.Num3][0]
            //ここまで
            
            self.minLabel.textColor = .systemBlue
            self.secLabel.textColor = .systemBlue
            
            self.plusLabel.isHidden = true
            
            self.reloadItem()
            //時間コンバート
            self.timeConvert()
            
            self.timeView()
            
            //タイマー開始
            if chkTimer == true {
                self.startTimer()
                checkTimer = true
                chkTimer = false
            }
            
            /*----------▼音声出力▼----------*/
            self.player.stop()
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.play(word: "\(self.taskStringListInst[Num1!][self.Num3][0])を始めてください",volume: taskVolumeInst[0])
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
            //タイマー開始
            if chkTimer == true {
                self.startTimer()
                checkTimer = true
                chkTimer = false
            }
        })
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    //次タスク追加ボタン
    @IBAction func addNextTaskButtonAction(_ sender: Any) {
        //黙らせる
        self.player.stop()
        //タイマーを止める
        var chkTimer: Bool = false
        if checkTimer == true {
            self.routinTimer!.invalidate()
            checkTimer = false
            chkTimer = true
        }
        //追加する前にテキスト追加
        self.taskStringListInst[Num1!][self.Num3][0] = "\((self.taskNameTextField.text)!)"
        userDefaults.set(taskStringListInst, forKey: "tSL")
        //アラート
        let alert = UIAlertController(title: "次に新規タスクを追加", message: "", preferredStyle: .alert)
        //テキストフィールド
        alert.addTextField(configurationHandler: nil)
                alert.textFields?.first?.placeholder = "新規タスク"
        
        let add = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("OK")
            //ここから実行内容
            let insertStringItem = ["\((alert.textFields?.first?.text)!)"]
            let insertIntItem = [0, 0, 0]
            let insertBoolItem = [false]
            let insertLastRecord = [0,0,0]
            let insertSabeData = [0,0,0]
            
            self.taskStringListInst[Num1!].insert(insertStringItem,at: self.Num3 + 1)
            self.taskIntListInst[Num1!].insert(insertIntItem,at: self.Num3 + 1)
            self.taskBoolListInst[Num1!].insert(insertBoolItem,at: self.Num3 + 1)
            self.taskLastRecord[Num1!].insert(insertLastRecord,at: self.Num3 + 1)
            self.taskSaveData[Num1!].insert(insertSabeData,at: self.Num3 + 1)
            
            self.userDefaults.set(self.taskStringListInst, forKey: "tSL")
            self.userDefaults.set(self.taskIntListInst, forKey: "tIL")
            self.userDefaults.set(self.taskBoolListInst, forKey: "tBL")
            self.userDefaults.set(self.taskLastRecord, forKey: "tLR")
            self.userDefaults.set(self.taskSaveData, forKey: "tSD")
            
            //テキスト更新
            self.taskNameTextField.text = self.taskStringListInst[Num1!][self.Num3][0]
            self.reloadItem()
            //ここまで
            
//            self.minLabel.textColor = .systemBlue
//            self.secLabel.textColor = .systemBlue
            
//            self.plusLabel.isHidden = true
//
//            self.reloadItem()
            //時間コンバート
//            self.timeConvert()
            
//            self.timeView()
            
            //タイマー開始
            if chkTimer == true {
                self.startTimer()
                checkTimer = true
                chkTimer = false
            }
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
            //タイマー開始
            if chkTimer == true {
                self.startTimer()
                checkTimer = true
                chkTimer = false
            }
        })
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    //タスク削除ボタン
    @IBAction func deleteTaskButtonAction(_ sender: Any) {
        buttonNotUse()
        //タイマーを止める
        self.routinTimer!.invalidate()
        checkTimer = false
        
        //アラート
        let alert = UIAlertController(title: "確認", message: "【\(taskStringListInst[Num1!][Num3][0])】を削除しますか？", preferredStyle: .alert)
        
        let delete = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            print("OK")
            
            self.taskStringListInst[Num1!].remove(at: self.Num3)
            self.taskIntListInst[Num1!].remove(at: self.Num3)
            self.taskBoolListInst[Num1!].remove(at: self.Num3)
            self.taskLastRecord[Num1!].remove(at: self.Num3)
            self.taskSaveData[Num1!].remove(at: self.Num3)
            
            self.userDefaults.set(self.taskStringListInst, forKey: "tSL")
            self.userDefaults.set(self.taskIntListInst, forKey: "tIL")
            self.userDefaults.set(self.taskBoolListInst, forKey: "tBL")
            self.userDefaults.set(self.taskLastRecord, forKey: "tLR")
            self.userDefaults.set(self.taskSaveData, forKey: "tSD")
            
            
            //ボタン使用不可
            if self.Num3 == self.taskIntListInst[Num1!].count {
                self.nextTaskButton.isEnabled = false
                self.beforeTaskButton.isEnabled = false
                self.stopButton.isEnabled = false
                self.addNextTaskButton.isEnabled = false
                self.addBeforeTaskButton.isEnabled = false
                self.deleteTaskButton.isEnabled = false
            }
            
            
            if self.Num3 < self.taskIntListInst[Num1!].count {
                
                //テキスト更新
                
                
                
                self.minLabel.textColor = .systemCyan
                self.secLabel.textColor = .systemCyan
                
                self.plusLabel.isHidden = true
                
                self.taskNameTextField.text = self.taskStringListInst[Num1!][self.Num3][0]
                self.reloadItem()
                //時間コンバート
                self.timeConvert()
                
                self.timeView()
                
                /*----------▼音声出力▼----------*/
                self.synthesizer.stopSpeaking(at: .immediate)
                
                /*----------▼SE音声出力▼----------*/
                if self.audioPlayer01.isPlaying {
                    self.audioPlayer01.stop()
                    self.audioPlayer01.currentTime = 0
                }
                self.audioPlayer01.volume = taskVolumeInst[1]
                self.audioPlayer01.play()
                /*----------▲ここまで▲----------*/
                
                
                
            }
            self.startTimer()
            checkTimer = true
            
            
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
            print("キャンセル")
            self.startTimer()
            checkTimer = true
        })
        
        alert.addAction(delete)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    //カメラボタン
    @IBAction func cameraButtonAction(_ sender: Any) {
        
    }
    //キャンセルボタン
    @IBAction func cancelButtonAction(_ sender: Any) {
        self.routinTimer.invalidate()
        checkTimer = false
        buttonNotUse()
        //戻る前にテキスト追加
        self.taskStringListInst[Num1!][self.Num3][0] = "\((self.taskNameTextField.text)!)"
        userDefaults.set(taskStringListInst, forKey: "tSL")
        //アラート
        let alert = UIAlertController(title: "確認", message: "ホーム画面へ戻ります", preferredStyle: .alert)
            
            let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                self.navigationController?.popToRootViewController(animated: true)
            })
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) -> Void in
                self.startTimer()
                checkTimer = true
                
            })
            
            alert.addAction(OK)
            alert.addAction(cancel)
            
            self.present(alert, animated: true, completion: nil)
    }
    //イヤホン装着ボタン
    @IBAction func earPhoneButtonAction(_ sender: Any) {
        //アラート
        let alert = UIAlertController(title: "イヤホンを装着してください", message: "", preferredStyle: .alert)
        
        let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
        })
        
        alert.addAction(OK)
        
        self.present(alert, animated: true, completion: nil)
    }
    //充電ボタン
    @IBAction func butteryButtonAction(_ sender: Any) {
        //アラート
        let alert = UIAlertController(title: "携帯を充電してください", message: "", preferredStyle: .alert)
        
        let OK = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
        })
        
        alert.addAction(OK)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //    @IBAction func settingButtonAction(_ sender: Any) {
//        let vc = settingViewController(nibName: nil, bundle: nil)
//        if let sheet = vc.sheetPresentationController {
//            sheet.detents = [.medium(), .large()]
//        }
//            present(vc, animated: true)
//    }
    
}

final class MaterialBarcodeReaderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
