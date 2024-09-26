//
//  Level.swift


import UIKit

struct Level {
    
    var sceneName = "BaseLevelScene"
    var isGravityDiviation = false
    var isFixedGravity = true
    var xGravity: Double = 10
    var yGravity: Double = 10
    var wildFireRestoreInterval: Double = 30
    var maxCloudsInRange = 4
    var minCloudsInRange = 2
    var dropDiameter: CGFloat = 80
    var evaPrice = 50
    var tFPrice = 15
    var deviationByX: Int = 1000
    var deviationByY: Int = 1000
    var bgColor: UIColor = #colorLiteral(red: 0.702839592, green: 0.1938713611, blue: 0.9012210876, alpha: 0.55)
    var cloudCollisionPrice = 1
    var stormCloudCollisionPrice = 2
    var level: Int = 0
    var score: Int = 0

}

