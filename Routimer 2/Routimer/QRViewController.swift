
import UIKit
//読み上げ
import AVFoundation

class QRViewController: UIViewController {
/*----------------------------------------▼変数▼----------------------------------------*/
    var captureSession = AVCaptureSession()
    var currentDevice: AVCaptureDevice?
    var metadataOutput: AVCaptureMetadataOutput!
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer!
    var outputString = ""
    var detectionArea: CGRect!
    var areaOfInterest: CGRect! // 0.0-1.0の範囲
    
    var authStatus: AuthorizedStatus = .authorized
    
    enum AuthorizedStatus {
        case authorized
        case notAuthorized
        case failed
    }
    
    static func fromStoryboard() -> QRViewController? {
        return UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "QRViewController") as? QRViewController
    }
    
    /*----------------------------------------▼view系▼----------------------------------------*/
    override func viewDidLoad() {
        super.viewDidLoad()

        setupCloseButton()
        setupMessage()
        
        cameraAuth()
        //もし認可されていなければ
        if authStatus != .authorized {
            dismiss(animated: true)
            return
        }
        // 認識エリアの計算
        setupDetectionArea()
        // カメラの準備
        setupDevice()
        // 入力と出力の設定
        setupInputOutput()
        // バーコード探索中のプレビュー表示
        setupPreviewLayer()
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }
        
    }
    
    /*----------------------------------------▼関数▼----------------------------------------*/
    // 認識エリアの計算
    func setupDetectionArea() {
        // まず赤枠のサイズを決める（横幅の70%のサイズの正方形を上から30%の位置に表示）
        detectionArea = CGRect(x: view.bounds.width * 0.15, y: view.bounds.height * 0.3, width: view.bounds.width * 0.7, height: view.bounds.width * 0.7)
        // 画面の大きさで割って割合を計算
        let interest = CGRect(x: detectionArea.origin.x / view.bounds.width, y: detectionArea.origin.y / view.bounds.height, width: detectionArea.width / view.bounds.width, height: detectionArea.height / view.bounds.height)
        // 縦横を入れ替える
        areaOfInterest = CGRect(x: interest.origin.y, y: interest.origin.x, width: interest.height, height: interest.width) // 縦横入れ替え
    }
    
    // カメラの準備
    func setupDevice() {
        // 通常広角カメラの背面カメラを探す
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .back)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            currentDevice = device
            break
        }
    }
   
    // 入力と出力の設定
    func setupInputOutput() {
        guard let device = currentDevice else {
            print("No camera available")
            return
        }
        
        do {
            // 入力
            let captureDeviceInput = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(captureDeviceInput)
            // 出力
            metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureSession.addOutput(metadataOutput)
            // QRコードを認識します。addOutputより後ろで設定すること
            metadataOutput.metadataObjectTypes = [.qr]
            // 認識エリアを指定する
            metadataOutput.rectOfInterest = areaOfInterest
            
        } catch {
            print(error)
        }
    }

    // バーコード探索中のプレビュー表示
    func setupPreviewLayer() {
        // 背面全部を映す
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = view.bounds
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
 
        // 認識エリアに赤枠を出す
        let borderView = UIView(frame: detectionArea)
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = UIColor.red.cgColor
        view.addSubview(borderView)
    }

    
    func foundBarcode() {
        captureSession.stopRunning()
        self.dismiss(animated: true)
    }
    
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadataObject in metadataObjects {
            if let metadata = metadataObject as? AVMetadataMachineReadableCodeObject {
                if metadata.type == .qr {
                    // 文字列が取れたら画面を閉じます
                    if let string = metadata.stringValue {
                        //もし文字列と設定しているQRurlと比較
                        if tempQRurl == string{
                            //次に進める変数をオンにする
                            chkNextTask = true
                            self.foundBarcode()
                        }
                    }
                }
            }
        }
    }
    
}

extension QRViewController {
    //
    func cameraAuth() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
            //権限状態が未決定の時にアクセス権限要求アラートが表示されます。
        case .notDetermined:
            // 初回起動時、許可を求める
            AVCaptureDevice.requestAccess(for: .video) {[unowned self] authorized in
                print("初回", authorized.description)
                if authorized {
                    self.authStatus = .authorized
                } else {
                    self.authStatus = .notAuthorized
                }
            }
        case .restricted, .denied:
            authStatus = .notAuthorized
        case .authorized:
            authStatus = .authorized
        @unknown default:
            fatalError()
        }
    }
    //閉じるボタン表示
    func setupCloseButton() {
        let button = UIButton()
        button.setTitle("✗", for: .normal)
        button.tintColor = UIColor.white
        button.backgroundColor = UIColor(white: 0.1, alpha: 0.8)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(tapClose(_:)), for: .touchUpInside)
        view.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        button.topAnchor.constraint(equalTo: view.topAnchor, constant: 32).isActive = true
        button.widthAnchor.constraint(equalToConstant: 32).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
    }
    
    //閉じるボタンアクション
    @objc func tapClose(_ button: UIButton) {
        dismiss(animated: true)
    }
    
    //ラベルの表示
    func setupMessage() {
        let label = UILabel()
        label.text = "QRコードを読み取ってください"
        label.numberOfLines = 2
        label.textColor = UIColor.white
        view.addSubview(label)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 128).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 32).isActive = true
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 32).isActive = true
    }
}
