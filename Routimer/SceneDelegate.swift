
import UIKit
import AVFAudio
/*----------------------------------------▼グローバル宣言▼----------------------------------------*/
var outTime: [Int] = [0,0,0]
var diffTime: [Int] = [0,0,0]
//バックグラウンド重複防止変数
var backChk: Bool = false
var foreChk: Bool = false
/*----------------------------------------▼プロトコル▼----------------------------------------*/
protocol backgroundTimerDelegate: AnyObject {
    //フォアグラウンド時にタイマーを開始
    func foreStartTimer()
    //バックグラウンド時にタイマー止める
    func backGroundTimer()
    //バックグラウンドから帰った時の時間を反映
    func reloadBackGround()
    //バックグラウンド時にプッシュ通知を予約する
    func reserveNotification()
    //もしフォアグラウンドに戻ったらプッシュ通知を全削除
    func removeNotification()
    //現在の音声全て止める
    func stopPlaySound()
}
protocol shortCutDelegate: AnyObject {
    //ショートカット起動した時に起動する
    func shortcutPlay()
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    

    var window: UIWindow?
    /*----------------------------------------▼宣言▼----------------------------------------*/
    //デリゲート
    weak var delegate: backgroundTimerDelegate?
    //ショートカットデリゲート
    weak var delegateShortcut: shortCutDelegate?
    //  userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    var routinNameListInst: [String] = []
    /*----------------------------------------▲ここまで▲----------------------------------------*/

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let _ = (scene as? UIWindowScene) else { return }
        print("[sc]willConnectTo")
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        print("[sc]sceneDidDisconnect")
        //アプリ落とされた時通知前削除
        delegate?.removeNotification()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("[sc]sceneDidBecomeActive")
        
        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("[sc]sceneWillResignActive")
        
    }
    //フォアグラウンド時
    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[sc]sceneWillEnterForeground")
        if foreChk == true && checkTimer == true {

            print("---------------フォアグランド処理---------------")
            
            //帰ってきた時刻
            let now = Date()
            
            let time = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
            //            print(time.hour!)
            //            print(time.minute!)
            //            print(time.second!)
            //inTime - outTime を diffTimeに代入
            diffTime[0] = time.hour! - outTime[0]
            //もし日をまたぐ時
            if diffTime[0] < 0 {
                diffTime[0] += 24
            }
            
            diffTime[1] = time.minute! - outTime[1]
            if diffTime[1] < 0 {
                diffTime[0] -= 1
                diffTime[1] += 60
            }
            
            diffTime[2] = time.second! - outTime[2]
            if diffTime[2] < 0 {
                diffTime[1] -= 1
                diffTime[2] += 60
            }
            //通知前削除
            delegate?.removeNotification()
            
            delegate?.reloadBackGround()
            delegate?.foreStartTimer()
            
            print("-------------フォアグランド処理ここまで----------------")
        }
        print("※※※※繰り返し処理※※※※ * 1ならセーフ")
    }
    
    //バックグラウンド移行する時
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("[sc]sceneDidEnterBackground")
        print("-------------バックグラウンドいきます-------------")
        
        backChk = true
        if backChk == true && checkTimer == true {
            //デリゲート現在ある音声全部消す
            delegate?.stopPlaySound()
            //通知予約
            delegate?.reserveNotification()
            //時間経過計算
            delegate?.backGroundTimer()
            
            foreChk = true
            
            let now = Date()

            let time = Calendar.current.dateComponents([.hour, .minute, .second], from: now)
//            print(time.hour!)
//            print(time.minute!)
//            print(time.second!)
            //現在時刻をoutTimeに代入（UD）
            outTime = [time.hour!, time.minute!, time.second!]
        }
        /*------------------------------▲ここまで▲------------------------------*/
        print("※※※※繰り返し処理※※※※ * 1ならセーフ")
    }
    
    func scene(_ scene: UIScene, willContinueUserActivityWithType userActivityType: String) {
        print("[sc]willContinueUserActivityWithType")
    }
    //ショートカット起動時に実行するコード
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("[sc]continue(ショートカット用)")
        if userActivity.activityType == String(describing: RoutinLaunchIntent.self) {
            if let intent = userActivity.interaction?.intent as? RoutinLaunchIntent {
                /*----------▼intentから必要なデータを取り出して、状態復元処理を行う▼----------*/
                //起動するルーチンの番号を格納
                let routinNum: Int = intent.launchRoutin as! Int
                //読み出し
                Num1 = routinNum
                
                delegateShortcut?.shortcutPlay()
                /*------------------------------▲ここまで▲------------------------------*/
            }
        }
    }
}

