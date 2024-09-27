//
//  BaseLevelScene.swift


import CoreMotion
import AudioToolbox
import SpriteKit

class BaseLevelScene: SKScene {
   
    // MARK: - Global Properties
    var levelData: Level!
    
    // MARK: - Private Properties
    private var gravitationDirection: GravitationDirections = .down
    
    private let motionManager = CMMotionManager()
    
    private var drop: SKSpriteNode?
    
    private var timers: [Timer] = []
    
    private var dropIsActive = false
    private var collisionOccurred = false
    
    private var clouds = [
        "cloud_1",
        "cloud_2",
        "cloud_3",
        "cloud_4"
    ]
    private var stormClouds = [
        "stormCloud_1",
        "stormCloud_2",
        "stormCloud_3",
        "stormCloud_4"
    ]
    
    private var cloudCollisionsCounter = 0
    private var addWildFireSwitcher = 0
    private var level = 0
    
    // MARK: - Calculated Properties
    private var score = 0 {
        willSet {
            NotificationCenter.default.post(
                name: Notification.Name("scoreHaschanged"),
                object: nil,
                userInfo: ["score": score, "level": level]
            )
        }
    }
    private var xGravity: Double = 10 {
        didSet {
            configureGravityDirection(xGravity, yGravity)
        }
    }
    private var yGravity: Double = 10 {
        didSet {
            configureGravityDirection(xGravity, yGravity)
        }
    }
    
    private var currentCloudName = "" {
        didSet {
            if oldValue == currentCloudName {
                cloudCollisionsCounter += 1
                
                collisionOccurred =
                cloudCollisionsCounter > 1 ?
                true :
                false
                
            } else { cloudCollisionsCounter = 0 }
        }
    }
    
    private var wildFiersCounter = 0 {
        didSet {
            if wildFiersCounter == 0 {
                levelCompleted()
            }
        }
    }
    
    // MARK: - override funcs
    override func didMove(to view: SKView) {
        
        score = levelData.score
        score -= 1
        level = levelData.level
        xGravity = levelData.xGravity
        
        if levelData.isGravityDiviation,
           levelData.isFixedGravity {
            Timer.scheduledTimer(
                withTimeInterval: 10,
                repeats: true) { [weak self] _ in
                    self?.setGravityDistination()
                }
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshDrop),
            name: Notification.Name("evaporationButtonTapped"),
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(turbulenceFlowButtonTapped),
            name: Notification.Name("turbulenceFlowButtonTapped"),
            object: nil
        )
        
        physicsWorld.contactDelegate = self
        
        setBackGround()
        setBoard()
        setDrop()
        
        if levelData.isGravityDiviation, !levelData.isFixedGravity {
            motionManager.startAccelerometerUpdates()
        } else if levelData.isGravityDiviation, levelData.isFixedGravity {
            physicsWorld.gravity = CGVector(
                dx: xGravity,
                dy: yGravity
            )
            NotificationCenter.default.post(
                name: Notification.Name("gravityDirectionHasChanged"),
                object: nil,
                userInfo: ["x": xGravity, "y": yGravity]
            )
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if levelData.isGravityDiviation,
           !levelData.isFixedGravity,
           let accelerometerData = motionManager.accelerometerData {
            physicsWorld.gravity = CGVector(
                dx: accelerometerData.acceleration.x * xGravity,
                dy: accelerometerData.acceleration.y * yGravity
            )
            
            NotificationCenter.default.post(
                name: Notification.Name("gravityDirectionHasChanged"),
                object: nil,
                userInfo: [
                    "x": accelerometerData.acceleration.x * xGravity,
                    "y": accelerometerData.acceleration.y * yGravity
                ]
            )
        }
        
        if levelData.isGravityDiviation, levelData.isFixedGravity {
            physicsWorld.gravity = CGVector(
                dx: xGravity,
                dy: yGravity
            )
            
            NotificationCenter.default.post(
                name: Notification.Name("gravityDirectionHasChanged"),
                object: nil,
                userInfo: ["x": xGravity, "y": yGravity]
            )
            
        }
        
    }
    
    // MARK: - Private funcs
    private func levelCompleted() {
        
        dropIsActive = true
        
        timers.forEach { $0.invalidate() }
        timers = []
        
        let wait = SKAction.wait(forDuration: 0.4)
        let go = SKAction.run { [weak self] in
            NotificationCenter.default.post(
                name: Notification.Name("levelCompleted"),
                object: nil,
                userInfo: [
                    "score": self?.score ?? 0,
                    "level": self?.level ?? 0
                ]
            )
        }
        run(SKAction.sequence([wait, go]))
    }
    
    private func configureGravityDirection(_ x: Double, _ y: Double) {
        switch (x, y) {
        case (8, 0): gravitationDirection = .right
        case (0, 8):  gravitationDirection = .up
        case (8, 8):  gravitationDirection = .upRight
        case (-8, -8):gravitationDirection = .downLeft
        case (-8, 0): gravitationDirection = .left
        case (0, -8): gravitationDirection = .down
        case (-8, 8): gravitationDirection = .upLeft
        case (8, -8): gravitationDirection = .downRight
        default:      gravitationDirection = .down
        }
    }
    
    private func setBackGround() {
        
        let background = SKSpriteNode(imageNamed: "backGround")
        
        background.position = CGPoint(
            x: frame.width / 2,
            y: -130
        )
        background.size = CGSize(
            width: frame.width * 2,
            height: 2688 * 2 * frame.width / 1536
        )
        background.zPosition = -100
        
        addChild(background)
        
        
        let shift = CGFloat(level) * frame.width / 9
        
        let moveBackGround = SKAction.moveBy(
            x: -shift,
            y: 0,
            duration: 1
        )
        let wait = SKAction.wait(forDuration: 0.5)
        let sequence = SKAction.sequence(
            [
                wait,
                moveBackGround
            ]
        )
        background.run(sequence)
        
    }
    
    private func setCloud(position: CGPoint, isStorm: Bool = false) {
        
        let cloudType = !isStorm ?
        clouds.randomElement()! :
        stormClouds.randomElement()!
        
        let cloud = SKSpriteNode(imageNamed: cloudType)
        
        cloud.name = "\(cloudType)_\(UUID())"
        cloud.position = position
        cloud.size = CGSize(
            width: levelData.dropDiameter * 3,
            height: levelData.dropDiameter * 2
        )
        cloud.physicsBody = SKPhysicsBody(
            circleOfRadius: CGFloat(levelData.dropDiameter / 2)
        )
        cloud.physicsBody?.pinned = true
        cloud.physicsBody?.isDynamic = !isStorm ? true : false
        cloud.physicsBody?.restitution = !isStorm ? 0.1 : 0
        cloud.physicsBody?.friction = !isStorm ? 0.2 : 0.5
        cloud.physicsBody?.categoryBitMask = PhysicsCategory.defaultObject
        cloud.physicsBody?.collisionBitMask = PhysicsCategory.drop
        cloud.physicsBody?.contactTestBitMask = PhysicsCategory.drop
        
        addChild(cloud)
    }
    
    private func setFire(on position: CGPoint) {
        if let wildFire = SKEmitterNode(fileNamed: "wildFire") {
            wildFire.position = position
            wildFire.particleSize = CGSize(
                width: Double(levelData.dropDiameter) * 2.7,
                height: 100.0
            )
            wildFire.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(
                    width: Double(levelData.dropDiameter) * 2.7,
                    height: 100.0
                )
            )
            wildFire.physicsBody?.isDynamic = false
            wildFire.physicsBody?.categoryBitMask = PhysicsCategory.aim
            wildFire.physicsBody?.collisionBitMask = PhysicsCategory.none
            wildFire.physicsBody?.contactTestBitMask = PhysicsCategory.drop
            
            addChild(wildFire)
            
            wildFiersCounter += 1
        }
    }
    
    private func setSmoke(on position: CGPoint) {
        if let smoke = SKEmitterNode(fileNamed: "smoke") {
            smoke.position = position
            smoke.particleSize = CGSize(
                width: 30 * 2.7,
                height: 100.0
            )
            smoke.physicsBody = SKPhysicsBody(
                rectangleOf: CGSize(
                    width: Double(levelData.dropDiameter) * 2.7,
                    height: 100.0
                )
            )
            smoke.physicsBody?.isDynamic = false
            smoke.physicsBody?.categoryBitMask = PhysicsCategory.aim
            smoke.physicsBody?.collisionBitMask = PhysicsCategory.none
            smoke.physicsBody?.contactTestBitMask = PhysicsCategory.drop
            
            addChild(smoke)
            
            wildFiersCounter += 1
        }
    }
    
    private func setRain(on position: CGPoint) {
        if let rain = SKEmitterNode(fileNamed: "rain") {
            rain.position = position
            rain.particleSize = CGSize(
                width: levelData.dropDiameter * 1.5,
                height: levelData.dropDiameter * 1.5
            )
            addChild(rain)
            
            let removeAfterDead = SKAction.sequence(
                [
                    SKAction.wait(forDuration: 3),
                    SKAction.removeFromParent()
                ]
            )
            rain.run(removeAfterDead)
        }
    }
    
    private func setSteam(on position: CGPoint) {
        if let steam = SKEmitterNode(fileNamed: "boil") {
            steam.position = position
            steam.particleSize = CGSize(
                width: levelData.dropDiameter * 1.5,
                height: levelData.dropDiameter * 1.5
            )
            addChild(steam)
            
            let removeAfterDead = SKAction.sequence(
                [
                    SKAction.wait(forDuration: 3),
                    SKAction.removeFromParent()
                ]
            )
            steam.run(removeAfterDead)
        }
    }
    
    private func setAim(on position: CGPoint) {
        let aim = SKSpriteNode(
            color: .clear,
            size: CGSize(
                width: levelData.dropDiameter * 4,
                height: levelData.dropDiameter * 3
            )
        )
        aim.position = position
        aim.physicsBody = SKPhysicsBody(
            rectangleOf: CGSize(
                width: levelData.dropDiameter * 4,
                height: levelData.dropDiameter * 3
            )
        )
        aim.physicsBody?.pinned = true
        aim.physicsBody?.isDynamic = false
        
        aim.physicsBody?.categoryBitMask = PhysicsCategory.aim
        aim.physicsBody?.collisionBitMask = PhysicsCategory.none
        aim.physicsBody?.contactTestBitMask = PhysicsCategory.drop
        
        addChild(aim)
        
        wildFiersCounter += 1
    }
    
    private func setBoard() {
        
        let minYPos =  -frame.height / 2 + 800
        
        for range in stride(from: levelData.maxCloudsInRange, to: levelData.minCloudsInRange - 1, by: -1) {
            
            let currentYPos = minYPos + CGFloat((levelData.maxCloudsInRange - range)) * levelData.dropDiameter * 3
            let rangeFrame = (CGFloat(range) - 1) / 2.0 * 4 * levelData.dropDiameter
            
            for i in stride(from: rangeFrame, to: -rangeFrame - 1, by: -4 * levelData.dropDiameter) {
                
                let cloudPosition = CGPoint(x: i, y: currentYPos)
                setCloud(position: cloudPosition, isStorm: Bool.random())
                
                if levelData.maxCloudsInRange - range == 1 {
                    
                    let aimPosition = CGPoint(x: i, y: minYPos - 210)
                    setAim(on: aimPosition)
                    
                    let firePosition = CGPoint(x: i, y: minYPos - 240)
                    setFire(on: firePosition)
                    
                    setSmoke(on: aimPosition)
                    
                }
            }
        }
        
        setFrame()
    }
    
    private func setFrame() {
        physicsBody = SKPhysicsBody(
            edgeLoopFrom: frame.inset(
                by: UIEdgeInsets(
                    top: 530,
                    left: 1,
                    bottom: 50,
                    right: 1
                )
            )
        )
    }
    
    private func setDrop() {
        drop?.removeFromParent()
        
        score += 1
        score -= 1
        
        guard !dropIsActive else { return }
        
        drop = SKSpriteNode(imageNamed: "newBall")
        guard let drop = drop else { return }
        drop.physicsBody = SKPhysicsBody(
            texture: SKTexture(imageNamed: "newBall"),
            size: CGSize(
                width: levelData.dropDiameter,
                height: levelData.dropDiameter
            )
        )
        drop.physicsBody?.affectedByGravity = true
        drop.physicsBody?.isDynamic = true
        drop.physicsBody?.mass = 1
        drop.physicsBody?.allowsRotation = true
        drop.physicsBody?.friction = 0.2
        drop.physicsBody?.restitution = 0.2
        drop.physicsBody?.categoryBitMask = PhysicsCategory.drop
        drop.physicsBody?.collisionBitMask = PhysicsCategory.defaultObject
        drop.physicsBody?.contactTestBitMask = PhysicsCategory.aim
        
        drop.position = CGPoint(
            x: Double.random(in: -levelData.dropDiameter * 3.5...levelData.dropDiameter * 3.5),
            y: frame.height / 2 - 120
        )
        drop.size = CGSize(
            width: levelData.dropDiameter * (level < 3 ? 1.2 : 1.5),
            height: levelData.dropDiameter * (level < 3 ? 1.2 : 1.5)
        )
        
        addChild(drop)
        
        dropIsActive = true
    }
    
    
    
    private func setGravityDistination() {
        xGravity = [8, -8, 0, 0, 0, 0].randomElement()!
        yGravity = [8, -8, 0, -8, -8, 0, 0, -8, -8].randomElement()!
        if xGravity == 0, yGravity == 0 {
            yGravity = -8
        }
    }
    
    private func setPointsLabel(
        position: CGPoint,
        text: String,
        color: UIColor,
        size: CGFloat = 50
    ) {
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        label.fontSize = size
        label.fontColor = color
        label.position = CGPoint(
            x: position.x - label.frame.width / 2,
            y: position.y
        )
        label.zRotation = CGFloat.random(in: -30...30) * .pi / 180
        
        label.text = text
        label.zPosition = 10
        label.horizontalAlignmentMode = .left
        
        let shadow = SKLabelNode(fontNamed: "HelveticaNeue-Light")
        shadow.fontSize = size
        shadow.fontColor = .black
        shadow.position = CGPoint(
            x: label.position.x + 1,
            y: label.position.y + 1
        )
        shadow.zPosition = label.zPosition - 1
        shadow.zRotation = label.zRotation
        
        shadow.text = text
        shadow.horizontalAlignmentMode = .left
        
        addChild(label)
        addChild(shadow)
        
        
        let moveUp = SKAction.moveBy(x: .random(in: -10...10), y: 100, duration: 0.5)
        let appear = SKAction.group(
            [
                SKAction.scale(to: 1, duration: 0.25),
                SKAction.fadeIn(withDuration: 0.25),
                moveUp
            ]
        )
        
        let disappear = SKAction.group(
            [
                SKAction.scale(to: 2, duration: 0.25),
                SKAction.fadeOut(withDuration: 0.25),
            ]
        )
        
        let sequence = SKAction.sequence(
            [
                SKAction.wait(forDuration: 0.5),
                appear,
                disappear,
                SKAction.removeFromParent()
            ]
        )
        
        label.run(sequence)
        shadow.run(sequence)
    }
    
    private func setCollision(with cloud: SKNode?) {
        
        guard let position = cloud?.position
        else { return }
        
        if cloud?.physicsBody?.isDynamic == false {
            score -= levelData.stormCloudCollisionPrice
            
            setPointsLabel(
                position: position,
                text: "-\(levelData.stormCloudCollisionPrice)",
                color: .red
            )
        } else {
            cloud?.run(
                SKAction.init(named: "Pulse")!,
                withKey: "fadeInOut"
            )
            score += levelData.cloudCollisionPrice
            
            setPointsLabel(
                position: position,
                text: "+\(levelData.cloudCollisionPrice)",
                color: .green
            )
            setRain(on: position)
        }
    }
    
    // MARK: - objc funcs
    @objc private func turbulenceFlowButtonTapped(_ notification: Notification) {
        
        let tag = notification.userInfo!["tag"] as! Int
        
        let impulse: CGVector
        
        switch gravitationDirection {
        case .right:
            impulse = CGVector(
                dx: -levelData.deviationByY,
                dy: tag == 0 ? levelData.deviationByX : -levelData.deviationByX
            )
        case .left:
            impulse = CGVector(
                dx: levelData.deviationByY,
                dy: tag == 0 ? levelData.deviationByX : -levelData.deviationByX
            )
        case .up:
            impulse = CGVector(
                dx: tag == 0 ? -levelData.deviationByX : levelData.deviationByX,
                dy: -levelData.deviationByY
            )
        case .down:
            impulse = CGVector(
                dx: tag == 0 ? levelData.deviationByX : -levelData.deviationByX,
                dy: levelData.deviationByY
            )
        case .downRight:
            impulse = CGVector(
                dx: -levelData.deviationByY,
                dy: tag == 0 ? levelData.deviationByX : -levelData.deviationByX * 2
            )
        case .downLeft:
            impulse = CGVector(
                dx: levelData.deviationByY,
                dy: tag == 0 ? levelData.deviationByX : -levelData.deviationByX * 2
            )
        case .upRight:
            impulse = CGVector(
                dx: tag == 0 ? -levelData.deviationByY : levelData.deviationByX,
                dy: -levelData.deviationByY
            )
        case .upLeft:
            impulse = CGVector(
                dx: tag == 0 ? -levelData.deviationByX : levelData.deviationByY,
                dy: -levelData.deviationByY
            )
        }
        
        drop?.physicsBody!.applyImpulse(impulse)
        
        score -= levelData.tFPrice
        
        setPointsLabel(
            position: CGPoint(
                x: 50 - frame.width / 2,
                y: frame.height / 2 - 350
            ),
            text: "-\(levelData.tFPrice)",
            color: .red
        )
        
    }
    
    @objc private func refreshDrop() {
        
        score -= levelData.evaPrice
        
        setPointsLabel(
            position: CGPoint(
                x: 55 - frame.width / 2,
                y: frame.height / 2 - 370
            ),
            text: "-\(levelData.evaPrice)",
            color: .red
        )
        
        dropIsActive = false
        setDrop()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - SKPhysicsContactDelegate
extension BaseLevelScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        let position = contact.contactPoint
        
        // collisions with fires
        if bodyB.categoryBitMask == PhysicsCategory.drop &&
            bodyA.categoryBitMask == PhysicsCategory.aim ||
            bodyA.categoryBitMask == PhysicsCategory.drop &&
            bodyB.categoryBitMask == PhysicsCategory.aim {
            
            if dropIsActive {
                dropIsActive.toggle()
                
                bodyA.node?.removeFromParent()
                bodyB.node?.removeFromParent()
                
                addWildFireSwitcher += 1
                
                if addWildFireSwitcher >= 3 {
                    timers.append(
                        Timer.scheduledTimer(
                            withTimeInterval: levelData.wildFireRestoreInterval * 1.6,
                            repeats: false) { [weak self] timer in
                                
                                if Bool.random() {
                                    self?.setFire(on: position)
                                } else {
                                    self?.setSmoke(on: position)
                                }
                                
                                timer.invalidate()
                            }
                    )
                    
                    addWildFireSwitcher = 0
                }
                
                setSteam(on: position)
                
                score += 100
                
                setPointsLabel(
                    position: position,
                    text: "+100",
                    color: .green
                )
                
                AudioServicesPlayAlertSoundWithCompletion(
                    SystemSoundID(
                        kSystemSoundID_Vibrate
                    ), {}
                )
                
                let wait = SKAction.wait(forDuration: 1)
                let go = SKAction.run { [weak self] in
                    self?.setDrop()
                }
                wildFiersCounter -= 1
                run(SKAction.sequence([wait, go]))
                
            }
            
        }
        
        // collisions with clouds
        if bodyA.categoryBitMask == PhysicsCategory.drop,
           bodyB.categoryBitMask == PhysicsCategory.defaultObject
        {
            
            if let cloudName = bodyB.node?.name {
                currentCloudName = cloudName
            }
            
            if !collisionOccurred {
                setCollision(with: bodyB.node)
            }
            
            UISelectionFeedbackGenerator().selectionChanged()
        }
        
    }
    
}
