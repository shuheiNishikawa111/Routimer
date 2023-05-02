
import UIKit

/*----------------------------------------▼グローバル宣言▼----------------------------------------*/
var Num4: Int = 0

class settingQRcodeViewController: UIViewController {
/*----------------------------------------▼紐付け▼----------------------------------------*/
    @IBOutlet weak var tableview: UITableView!
    
    /*----------------------------------------▼変数▼----------------------------------------*/
    var userDefaults = UserDefaults.standard
    
    //QR入れ宣言
    var taskStringListInst: [[[String]]] = []
    //QRリスト宣言
    var QRURLList: [String] = []
    var QRNameList: [String] = []
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        //デリゲート宣言
        tableview.delegate = self
        tableview.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        taskStringListInst = userDefaults.array(forKey: "tSL") as! [[[String]]]//QRコードを入れる箱
        QRURLList = userDefaults.array(forKey: "QUL") as! [String]//QRコードのURL
        QRNameList = userDefaults.array(forKey: "QNL") as! [String]//QRコードの名前
        
        tableview.reloadData()
    }
    /*----------------------------------------▼関数▼----------------------------------------*/
    
    /*----------------------------------------▼アクション紐付け▼----------------------------------------*/
    @IBAction func addButtonAction(_ sender: Any) {
        QRURLList.append("")
        QRNameList.append("新規コード")
        
        userDefaults.set(QRURLList, forKey: "QUL")
        userDefaults.set(QRNameList, forKey: "QNL")

        performSegue(withIdentifier: "toQRReader", sender: nil)
    }
    
}


/*----------------------------------------▼テーブルビュー▼----------------------------------------*/
/*------------------------------▼データソース▼------------------------------*/
extension settingQRcodeViewController: UITableViewDataSource {
    
    //セルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return QRNameList.count
    }
    
    //セルの詳細
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //セルを定義
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath)
        cell.textLabel?.text = QRNameList[indexPath.row]
        //もしそのセルが選択状態ならアクセサリービューをつける
        if tempIntList[Num2!][3] == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        //もしセルの中身が空の時、そのセルを削除して再度更新
        if QRURLList[indexPath.row] == "" {
            QRURLList.remove(at: indexPath.row)
            QRNameList.remove(at: indexPath.row)
            //もし選択済みQRが消される時
            if tempIntList[Num2!][3] == indexPath.row{
                tempIntList[Num2!][3] = -1
            }
            //もし選択済みQRより上が消される時
            else if tempIntList[Num2!][3] > indexPath.row{
                tempIntList[Num2!][3] = tempIntList[Num2!][3] - 1
            }
            //下の場合は特に何もしない
            tableView.reloadData()
        }
        
        
        //セルに入れる
        return cell
    }
    
    
    //「削除」動作
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        QRURLList.remove(at: indexPath.row)
        QRNameList.remove(at: indexPath.row)
        //もし選択済みQRが消される時
        if tempIntList[Num2!][3] == indexPath.row{
            tempIntList[Num2!][3] = -1
        }
        //もし選択済みQRより上が消される時
        else if tempIntList[Num2!][3] > indexPath.row{
            tempIntList[Num2!][3] = tempIntList[Num2!][3] - 1
        }
        //下の場合は特に何もしない
        
        
        tableView.reloadData()
    }
}
/*------------------------------▼デリゲート▼------------------------------*/
extension settingQRcodeViewController: UITableViewDelegate {
    //セルをタップした時の動作
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tempIntList[Num2!][3] != indexPath.row{
            tempIntList[Num2!][3] = indexPath.row
        }
        else {
            tempIntList[Num2!][3] = -1
        }
        tableview.reloadData()
    }
    
}
