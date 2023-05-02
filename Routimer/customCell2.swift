//
//  customCell2.swift
//  Routimer
//
//  Created by 西川修平 on 2023/04/21.
//

import Foundation

import UIKit

//プロトコル宣言
protocol CatchProtocol {
    func catchData(id:Int)
}

class customCell2: UITableViewCell {
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
        if tempSaveData[reloadButton.tag][0] > 0 {
            tempSaveData[reloadButton.tag][1] += tempSaveData[reloadButton.tag][0] * 60
            tempSaveData[reloadButton.tag][0] = 0
        }
        if tempSaveData[reloadButton.tag][1] > 100 {
            tempSaveData[reloadButton.tag][1] = 99
            tempSaveData[reloadButton.tag][2] = 59
        }
        let totalNum = tempSaveData[reloadButton.tag][1] * 100 + tempSaveData[reloadButton.tag][2] * 1
        
        tempIntList[reloadButton.tag][0] = totalNum
        delegate?.catchData(id: 0)
    }
}
