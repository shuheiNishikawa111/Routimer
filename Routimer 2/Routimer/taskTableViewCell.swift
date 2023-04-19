

import UIKit
//プロトコル宣言
protocol CatchProtocol {
    func catchData(id:Int)
}

class taskTableViewCell: UITableViewCell {
    /*----------------------------------------▼紐付け▼----------------------------------------*/

    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var taskNameLabel: UILabel!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var reloadTime: UILabel!
    
    @IBOutlet weak var upperBar: UIView!
    
    @IBOutlet weak var centerSquare: UIView!
    
    @IBOutlet weak var lowerBar: UIView!
    /*----------------------------------------▼宣言▼----------------------------------------*/
    //デリゲート宣言
    var delegate: CatchProtocol?
    
    //userDefaultsの定義
    var userDefaults = UserDefaults.standard
    
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    /*----------------------------------------▼ボタンアクション▼----------------------------------------*/
    //読み込みボタン
    @IBAction func reloadButtonAction(_ sender: Any) {
        
        let totalNum = tempSaveData[reloadButton.tag][0] * 360 + tempSaveData[reloadButton.tag][1] * 60 + tempSaveData[reloadButton.tag][2] * 1
        
        tempIntList[reloadButton.tag][0] = totalNum
        delegate?.catchData(id: 0)
    }
}
