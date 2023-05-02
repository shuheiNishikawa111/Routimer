
import UIKit
//読み上げ
import AVFoundation
import MediaPlayer

var taskVolumeInst: [Float] = [0,0]

class settingViewController: UIViewController {
    /*----------------------------------------▼紐付け▼----------------------------------------*/
    @IBOutlet weak var announceVolume: UISlider!
    @IBOutlet weak var soundEffectVolume: UISlider!
    /*----------------------------------------▼宣言▼----------------------------------------*/
    //ユーザーデフォルト宣言
    var userDefaults = UserDefaults.standard
    //SEプレイヤー宣言
    var audioPlayer:AVAudioPlayer!
    //合成音声宣言
    var synthesizer = AVSpeechSynthesizer()
    
    
    /*----------▼新合成音声▼----------*/
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var eqEffect = AVAudioUnitEQ()
    var converter = AVAudioConverter(from: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatInt16, sampleRate: 22050, channels: 1, interleaved: false)!, to: AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!)

    var bufferCounter: Int = 0
    
    let audioSession = AVAudioSession.sharedInstance()
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()
        /*----------▼バックミュージック流しながらでも効果音を流すコード▼----------*/
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.ambient)
            try audioSession.setActive(true)
        } catch let error {
            print(error)
        }
        /*----------▼音声設定UD呼出し▼----------*/
        taskVolumeInst = userDefaults.object(forKey: "tV") as! [Float]
        announceVolume.value = taskVolumeInst[0] / 28
        soundEffectVolume.value = taskVolumeInst[1] / 10
        
        /*----------▼SE設定▼----------*/
        let path = Bundle.main.path(forResource: "SE_complete01", ofType: "caf")
        let url = URL(fileURLWithPath: path!)
        try! audioPlayer = AVAudioPlayer(contentsOf: url)
        //事前準備
        audioPlayer.prepareToPlay()
        /*----------▼新合成音声▼----------*/
        
        let outputFormat = AVAudioFormat(commonFormat: AVAudioCommonFormat.pcmFormatFloat32, sampleRate: 22050, channels: 1, interleaved: false)!
        setupAudio(format: outputFormat, globalGain: 0)
        /*----------▲ここまで▲----------*/
    }
    /*----------------------------------------▼関数▼----------------------------------------*/
    func activateAudioSession() {
        do {
            try audioSession.setCategory(.ambient, mode: .voicePrompt, options: [.mixWithOthers])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("エラー02")
        }
    }
    func play(word: String,volume: Float) {
        self.player.stop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.eqEffect.globalGain = volume
            let utterance = AVSpeechUtterance(string: word)
            self.synthesizer.write(utterance) { buffer in
                guard let pcmBuffer = buffer as? AVAudioPCMBuffer, pcmBuffer.frameLength > 0 else {
//                    print("エラー01")
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
//                            print(self.bufferCounter)
                            if self.bufferCounter == 0 {
                                self.player.stop()
                                self.engine.stop()
//                                try! self.audioSession.setActive(false, options: [])
                            }
                        }
                        
                    })
                    
                    self.converter!.reset()
                    self.player.prepare(withFrameCount: convertedBuffer.frameLength)
                }
                catch _ {
//                    print(error.localizedDescription)
                }
            }
            self.activateAudioSession()
            
            if !self.engine.isRunning {
                try! self.engine.start()
            }
            if !self.player.isPlaying {
                self.player.play()
            }
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
    /*----------------------------------------▼アクション紐付け▼----------------------------------------*/
    /*----------------------------------------▼アナウンス▼----------------------------------------*/
    
    @IBAction func announceVolumeAction(_ sender: Any) {
        
        
    }
    /*----------▼タッチ離した時▼----------*/
    @IBAction func aVATouchCancel(_ sender: Any) {
        /*----------▼合成音声出力▼----------*/
        if audioPlayer.isPlaying == true {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        taskVolumeInst[0] = announceVolume.value * 28
        userDefaults.set(taskVolumeInst, forKey: "tV")
        self.play(word: "テスト再生中", volume: taskVolumeInst[0])
        /*----------▲ここまで▲----------*/
    }
    /*----------------------------------------▼効果音▼----------------------------------------*/
    
    @IBAction func soundEffectVolumeAction(_ sender: Any) {
        
        
    }
    /*----------▼タッチ離した時▼----------*/
    @IBAction func sEVATouchCancel(_ sender: Any) {
        /*----------▼SE音声出力▼----------*/
        if audioPlayer.isPlaying == true {
            audioPlayer.stop()
            audioPlayer.currentTime = 0
        }
        taskVolumeInst[1] = soundEffectVolume.value * 10
        audioPlayer.volume = taskVolumeInst[1]
        userDefaults.set(taskVolumeInst, forKey: "tV")
        audioPlayer.play()
        /*----------▲ここまで▲----------*/
    }
}
