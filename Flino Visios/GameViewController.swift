//
//  GameViewController.swift

import SpriteKit

class GameViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var evaLabel: UILabel!
    
    @IBOutlet var tFLabels: [UILabel]!
    
    @IBOutlet weak var skView: SKView!
    
    @IBOutlet weak var gravityDirectionImage: UIImageView!
    
    // MARK: - Private properties
    private let uD = StorageManager.shared
    private let levelManager = LevelManager.shared
    
    private var userInfo = UserDataInfo()
    
    private var evaCount = 0
    private var tFCount = 0
    
    private var gravitationDirection: GravitationDirections = .down
    
    private var savedScore = 0
    
    // MARK: - Override funcs
    override func viewDidLoad() {
        super.viewDidLoad()
        
        skView.backgroundColor = .clear
        
        userInfo.bestScore = uD.fatchStatistics().bestScore
        uD.save(userInfo)
        
        setNotifications()
        
        scoreLabel.textColor = .black
        scoreLabel.text = "SCORE: \(userInfo.score)"
        levelLabel.text = "LEVEL: \(userInfo.level)"
        evaLabel.text = "EVA: \(userInfo.evaCounter)"
        tFLabels.forEach{ $0.text = "TF: \(userInfo.tFCounter)" }
        
        setLevelView(for: userInfo.level)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        uD.save(userInfo)
    }
    
    // system override funcs
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Private funcs
    /// all notifications
    private func setNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(gameOver),
            name: Notification.Name("levelCompleted"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(setLabels),
            name: Notification.Name("scoreHaschanged"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(configureGravityDirectionImage),
            name: Notification.Name("gravityDirectionHasChanged"),
            object: nil
        )
    }
    
    /// the main func which adjusts a scene according to a level
    private func setLevelView(for level: Int) {
        
        var levelData = Level()
        
        switch level {
            
        case 1:
            levelData.maxCloudsInRange = 5
            levelData.minCloudsInRange = 2
            levelData.wildFireRestoreInterval = 50
            levelData.dropDiameter = 60
            levelData.tFPrice = 17
            levelData.deviationByX = 900
            levelData.bgColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        case 2:
            let range = [5000, 10000, 3000, 100, 500, 1000, 1000, 100]
            levelData.deviationByY = range.randomElement()! * [-1, 1].randomElement()!
            levelData.dropDiameter = 50
            levelData.maxCloudsInRange = 6
            levelData.minCloudsInRange = 2
            levelData.bgColor = #colorLiteral(red: 0.3568137853, green: 0.8410677813, blue: 0.9012210876, alpha: 0.55)
            levelData.tFPrice = 22
            levelData.evaPrice = 55
            levelData.deviationByX = 300
            levelData.cloudCollisionPrice = 1
            levelData.stormCloudCollisionPrice = 3
            levelData.wildFireRestoreInterval = 60
        case 3:
            levelData.dropDiameter = 40
            levelData.maxCloudsInRange = 7
            levelData.minCloudsInRange = 2
            levelData.bgColor = #colorLiteral(red: 0.5464277018, green: 0.6973573371, blue: 0.9012210876, alpha: 0.55)
            levelData.tFPrice = 30
            levelData.evaPrice = 60
            levelData.deviationByX = 500
            levelData.cloudCollisionPrice = 1
            levelData.stormCloudCollisionPrice = 3
            levelData.isGravityDiviation = true
            levelData.isFixedGravity = false
            levelData.xGravity = 10
            levelData.yGravity = 10
            levelData.wildFireRestoreInterval = 10
            
        case 4:
            levelData.dropDiameter = 30
            levelData.maxCloudsInRange = 8
            levelData.minCloudsInRange = 3
            levelData.bgColor = #colorLiteral(red: 0.9012210876, green: 0.6507516332, blue: 0.6547421639, alpha: 0.55)
            levelData.evaPrice = 65
            levelData.tFPrice = 15
            levelData.deviationByX = 200
            levelData.cloudCollisionPrice = 2
            levelData.stormCloudCollisionPrice = 4
            levelData.isGravityDiviation = true
            levelData.isFixedGravity = true
            levelData.xGravity = 0
            levelData.yGravity = -10
            levelData.wildFireRestoreInterval = 60
            
        case 5:
            levelData.dropDiameter = 30
            levelData.maxCloudsInRange = 9
            levelData.minCloudsInRange = 2
            levelData.bgColor = #colorLiteral(red: 1, green: 0.6235294118, blue: 0.03921568627, alpha: 0.8114243659)
            levelData.evaPrice = 70
            levelData.tFPrice = 50
            levelData.deviationByX = 100
            levelData.cloudCollisionPrice = 2
            levelData.stormCloudCollisionPrice = 5
            levelData.wildFireRestoreInterval = 100
            
        case 6:
            levelData.dropDiameter = 30
            levelData.maxCloudsInRange = 10
            levelData.minCloudsInRange = 2
            levelData.bgColor = #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1)
            levelData.evaPrice = 100
            levelData.tFPrice = 300
            levelData.deviationByX = 100
            levelData.cloudCollisionPrice = 3
            levelData.stormCloudCollisionPrice = 100
            levelData.isGravityDiviation = true
            levelData.isFixedGravity = false
            levelData.xGravity = 10
            levelData.yGravity = 10
            levelData.wildFireRestoreInterval = 20
            
        case 7:
            levelData.dropDiameter = 25
            levelData.maxCloudsInRange = 11
            levelData.minCloudsInRange = 3
            levelData.bgColor = #colorLiteral(red: 0, green: 0.6140567681, blue: 0.9469888041, alpha: 0.55)
            levelData.evaPrice = 250
            levelData.tFPrice = 20
            levelData.deviationByX = 90
            levelData.cloudCollisionPrice = 10
            levelData.stormCloudCollisionPrice = 50
            levelData.isGravityDiviation = true
            levelData.isFixedGravity = true
            levelData.xGravity = 0
            levelData.yGravity = 8
            levelData.wildFireRestoreInterval = 160
        case 8:
            levelData.dropDiameter = 25
            levelData.maxCloudsInRange = 12
            levelData.minCloudsInRange = 2
            levelData.bgColor = #colorLiteral(red: 0.5058823824, green: 0.3372549117, blue: 0.06666667014, alpha: 0.8796610809)
            levelData.evaPrice = 80
            levelData.tFPrice = 70
            levelData.deviationByX = 100
            levelData.cloudCollisionPrice = 20
            levelData.stormCloudCollisionPrice = 50
            levelData.wildFireRestoreInterval = 120
        case 9:
            levelData.dropDiameter = 22
            levelData.maxCloudsInRange = 14
            levelData.minCloudsInRange = 5
            levelData.bgColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
            levelData.evaPrice = 50
            levelData.tFPrice = 5
            levelData.deviationByX = 100
            levelData.cloudCollisionPrice = 90
            levelData.stormCloudCollisionPrice = 100
            levelData.wildFireRestoreInterval = 10
        default:
            levelData.dropDiameter = 80
            levelData.maxCloudsInRange = 4
            levelData.minCloudsInRange = 2
            levelData.isGravityDiviation = false
            levelData.isFixedGravity = true
            levelData.xGravity = 10
            levelData.yGravity = 10
            levelData.evaPrice = 50
            levelData.tFPrice = 15
            levelData.cloudCollisionPrice = 1
            levelData.stormCloudCollisionPrice = 2
            levelData.deviationByX = 1000
            levelData.deviationByY = 1000
            levelData.bgColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
            levelData.wildFireRestoreInterval = 40
        }
        
        levelData.level = userInfo.level
        levelData.score = userInfo.score
        levelManager.load(level: levelData, into: skView)
        
        gravityDirectionImage.isHidden = !levelData.isGravityDiviation
        
        savedScore = userInfo.score
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.backgroundColor = .clear
    }
    
    
    // MARK: - objc funcs
    /// defines the direction of gravitation with force vector and set the arrow
    @objc private func configureGravityDirectionImage(_ notification: Notification) {
        let (x, y) = (
            notification.userInfo?["x"] as! Double,
            notification.userInfo?["y"] as! Double
        )
        
        switch (x, y) {
        case (0.01..., -1.5...1.5):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.right.rawValue
            )
        case (-1.5...1.5, 0.01...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.up.rawValue
            )
        case (0.01..., 0.01...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.upRight.rawValue
            )
        case (...0, ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.downLeft.rawValue
            )
        case (...0, -1.5...1.5):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.left.rawValue
            )
        case (-1.5...1.5, ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.down.rawValue
            )
        case (...0, 0.01...):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.upLeft.rawValue
            )
        case (0.01..., ...0):
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.downRight.rawValue
            )
        default:
            gravityDirectionImage.image = UIImage(
                systemName: GravitationDirections.down.rawValue
            )
        }
        
    }
    
    /// preparetion the view for the level's completion
    @objc private func gameOver(_ notification: Notification) {
        
        setLabels(notification)
        
        let alert = userInfo.score > 0 ?
        UIAlertController(
            title: userInfo.level < 9 ? "LEVEL COMPETED" : "GAME OVER",
            message: "Your Score: \(userInfo.level < 9 ? userInfo.score + 1 : userInfo.score)",
            preferredStyle: .alert
        ) :
        UIAlertController(
            title: "LEVEL NOT COMPETED",
            message: "Your Score Is Below Zero!",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: userInfo.score > 0 ?
            (userInfo.level < 9 ? "NEXT LEVEL" : "END THE GAME") :
                "TRY AGAIN",
            style: .default
        ) { [weak self] _ in
            
            
            guard let strongSelf = self
            else { return }
            
            strongSelf.userInfo.level += strongSelf.userInfo.score > 0 ? 1 : 0
            
            if strongSelf.userInfo.score < 0 { strongSelf.userInfo.score = strongSelf.savedScore }
            
            strongSelf.uD.save(strongSelf.userInfo)
            
            strongSelf.userInfo.level <= 9 ?
            strongSelf.setLevelView(for: strongSelf.userInfo.level) :
            strongSelf.dismiss(animated: true)
            
        }
        
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    ///  update labels and data every time score changes
    @objc private func setLabels(_ notification: Notification) {
        
        let score = notification.userInfo?["score"] as! Int
        let level = notification.userInfo?["level"] as! Int
        
        userInfo.score <= score ?
        scoreLabel.animatePulseAndColorChange(.green) :
        scoreLabel.animatePulseAndColorChange(.red)
        
        userInfo.score = score
        userInfo.level = level
        
        if userInfo.score > userInfo.bestScore {
            userInfo.bestScore = userInfo.score
        }
        
        userInfo.evaCounter = evaCount
        userInfo.tFCounter = tFCount
        
        uD.save(userInfo)
        
        scoreLabel.text = "SCORE: \(userInfo.score)"
        levelLabel.text = "LEVEL: \(userInfo.level)"
        evaLabel.text = "EVA: \(userInfo.evaCounter)"
        tFLabels.forEach{ $0.text = "TF: \(userInfo.tFCounter)" }
        
    }
    
    // MARK: - IBActions
    @IBAction func turbulenceFlowButtonPressed(_ sender: UIButton) {
        tFCount += 1
        NotificationCenter.default.post(
            name: Notification.Name("turbulenceFlowButtonTapped"),
            object: nil,
            userInfo: ["tag": sender.tag]
        )
    }
    
    @IBAction func evaporationButtonTapped(_ sender: Any) {
        evaCount += 1
        NotificationCenter.default.post(
            name: Notification.Name("evaporationButtonTapped"),
            object: nil
        )
    }
    
    // MARK: - deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
