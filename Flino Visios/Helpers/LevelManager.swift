//
//  LevelManager.swift


import SpriteKit

class LevelManager {
    
    static let shared = LevelManager()
    private init() {}
    
    func load(level: Level, into view: SKView) {
        
        if let scene = SKScene(fileNamed: level.sceneName) as? BaseLevelScene {
            
            scene.levelData = level
            
            scene.backgroundColor = .clear
            scene.scaleMode = .aspectFit
            
            view.presentScene(
                scene,
                transition: SKTransition.fade(withDuration: 2)
            )
        }
    }
    
}
