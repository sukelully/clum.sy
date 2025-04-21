//
//  GameScene.swift
//  gameTest
//
//  Created by Luke S on 04/11/2022.
//

import SpriteKit
import AudioKit
import UIKit

// Global Variables.
// Global access to Sampler and two UIColors for buttons/switches.
var sampler: Sampler!
let switchOnColor = UIColor(red: 167/255, green: 236/255, blue: 181/255, alpha: 1)
let switchOffColor = UIColor(red: 233/255, green: 210/255, blue: 168/255, alpha: 1)
let bassBallSize: CGFloat = 33
let bassBall = SKShapeNode(circleOfRadius: bassBallSize)
let bassBallPhysicsBody = SKPhysicsBody(circleOfRadius: bassBallSize)

// Used to dynamically set properties of the menu labels.
class MenuLabel: SKLabelNode {
    convenience init(text: String, position: CGPoint, zPosition: CGFloat, name: String, hidden: Bool) {
        self.init(fontNamed: "AvenirNext-HeavyItalic")
        self.text = text
        self.position = position
        self.zPosition = zPosition
        self.fontSize = 40
        self.name = name
        self.isHidden = hidden
    }
}

// Used to dynamically set properties of the seven chord bouncers.
class Bouncer: SKShapeNode {
    init(path: CGMutablePath, shapeLength: CGFloat, bouncerColor: UIColor) {
        super.init()
        self.path = path
        physicsBody = SKPhysicsBody(edgeLoopFrom: path)
        physicsBody?.affectedByGravity = false
        physicsBody?.isDynamic = false
        physicsBody?.restitution = 1
        self.fillColor = bouncerColor
        strokeColor = .clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("Error")
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Access to GameViewController.
    weak var viewController: GameViewController?
    
    // Colors.
    let wallpaperColor = UIColor(red: 235/255, green: 237/255, blue: 200/255, alpha: 1)
    let ballColor = UIColor(red: 116/255, green: 105/255, blue: 140/255, alpha: 1)
    let bouncerColor = UIColor(red: 193/255, green: 134/255, blue: 123/255, alpha: 1)
    let settingsMenuColor = UIColor(red: 1, green: 227/255, blue: 176/255, alpha: 1)
    
    // Menu labels & objects.
    var pauseLabel: SKLabelNode!
    var effectsLabel: SKLabelNode!
    var settingsLabel: SKLabelNode!
    var aboutLabel: SKLabelNode!
    var aboutText: UITextView!
    var settingsMenu: SKShapeNode!
    
    // Lists and Indexes.
    var effectsList: [String] = ["CREATE", "FILTER", "REVERB"]
    var effectsIndex: Int = 0
    var PKIndex: Int = 1
    var buttonArray = [Bool]()          // Used to keep track of which chord buttons are hidden.
    
    // Bouncers for bassBall chords.
    var I_bouncer: Bouncer!
    var ii_bouncer: Bouncer!
    var iii_bouncer: Bouncer!
    var IV_bouncer: Bouncer!
    var V_bouncer: Bouncer!
    var vi_bouncer: Bouncer!
    var vii_bouncer: Bouncer!
    
    // Other Variables
    let menuLabelFontSize = 40
    var coinFlip = Bool.random()        // Used to randomly generate positive & negative numbers.
    var totalPKBalls: Int = 0           // Total number of pianoKey balls in GameScene.
    var activeChord: Int = 0            // Represents the most recent chord to be hit by the bassBall.
                                        // 0 = I, 1 = ii, 2 = iii, 3 = IV, etc.
    
    // Pauses GameScene when true, plays when false.
    var timePaused: Bool = false {
        didSet {
            if timePaused {
                pauseLabel.text = "PAUSED"
                self.isPaused = true
            } else {
                pauseLabel.text = "PLAYING"
                self.isPaused = false
            }
        }
    }
    
    // Adds a background to GameScene.
    func addBackground() {
        let background = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 1030, height: 780))
        background.blendMode = .replace
        background.zPosition = -1
        background.fillColor = wallpaperColor
        addChild(background)
    }
    
    // Loads initially when game is ran.
    // Used to set up GameScene.
    override func didMove(to view: SKView) {
        // Adds background and nstantiates sampler object to GameScene.
        sampler = Sampler()
        addBackground()
        
        // Adds effects label to GameScene.
        effectsLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        effectsLabel.text = "CREATE"
        effectsLabel.fontSize = 40
        effectsLabel.position = CGPoint(x: 128, y: 720)
        addChild(effectsLabel)
        
        // Adds pause time label to GameScene.
        pauseLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        pauseLabel.text = "PLAYING"
        pauseLabel.fontSize = 40
        pauseLabel.position = CGPoint(x: 384, y: 720)
        addChild(pauseLabel)
        
        // Add about label to GameScene.
        aboutLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        aboutLabel.text = "ABOUT"
        aboutLabel.fontSize = 40
        aboutLabel.position = CGPoint(x: 640, y: 720)
        addChild(aboutLabel)
        
        // Adds settings label to GameScene.
        settingsLabel = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        settingsLabel.text = "SETTINGS"
        settingsLabel.fontSize = 40
        settingsLabel.position = CGPoint(x: 896, y: 720)
        addChild(settingsLabel)
        
        // Adds both menus to GameScene (initially hidden).
        // Populates buttonsArray to keep track of which are toggled.
        makeSettingsMenu()
        makeAboutMenu()
        buttonArray = Array(repeating: true, count: 7)

        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)    // Adds physics simulation to all nodes.
        physicsWorld.contactDelegate = self                 // Watches for collisions between nodes.
        
        // Draw four pieano keys on the right half of the screen.
        // These correspond to the 1st, 3rd, 5th and 7th degrees of a tonal 7th chord in C major.
        makePianoKey(at: CGPoint(x: 573, y: 0))
        makePianoKey(at: CGPoint(x: 703, y: 0))
        makePianoKey(at: CGPoint(x: 833, y: 0))
        makePianoKey(at: CGPoint(x: 961, y: 0))
        
        // Draw shapes (paths) for SKShapeNode bouncers.
        // Variables used
        let shapeLength: CGFloat = 40
        let center = CGPoint(x: 0, y: 0)
        
        // Draw circle path.
        let circle = CGMutablePath()
        circle.addArc(center: center, radius: shapeLength, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        
        // Draw semi-circle paths.
        let semiCircleL = CGMutablePath()
        semiCircleL.addArc(center: center, radius: shapeLength, startAngle: .pi/2, endAngle: .pi*3/2, clockwise: true)
        
        let semiCircleR = CGMutablePath()
        semiCircleR.addArc(center: center, radius: shapeLength, startAngle: .pi/2, endAngle: .pi*3/2, clockwise: false)
        
        // Draw quarter-circle paths.
        // DL, UR correspond to Down-Left, Up-Right etc
        let quarterCircleDL = CGMutablePath()
        quarterCircleDL.addArc(center: center, radius: shapeLength, startAngle: .pi/2, endAngle: 0, clockwise: true)
        quarterCircleDL.addLine(to: center)
        quarterCircleDL.closeSubpath()
        
        let quarterCircleDR = CGMutablePath()
        quarterCircleDR.addArc(center: center, radius: shapeLength, startAngle: .pi/2, endAngle: .pi, clockwise: false)
        quarterCircleDR.addLine(to: center)
        quarterCircleDR.closeSubpath()
        
        let quarterCircleUL = CGMutablePath()
        quarterCircleUL.addArc(center: center, radius: shapeLength, startAngle: 0, endAngle: .pi*3/2, clockwise: true)
        quarterCircleUL.addLine(to: center)
        quarterCircleUL.closeSubpath()
        
        let quarterCircleUR = CGMutablePath()
        quarterCircleUR.addArc(center: center, radius: shapeLength, startAngle: .pi*3/2, endAngle: .pi, clockwise: true)
        quarterCircleUR.addLine(to: center)
        quarterCircleUR.closeSubpath()
        
        // Adds bouncers to GameScene.
        I_bouncer = Bouncer(path: circle, shapeLength: shapeLength, bouncerColor: bouncerColor)
        I_bouncer.position = CGPoint(x: 256, y: 384 - shapeLength/2)
        addChild(I_bouncer)
        
        ii_bouncer = Bouncer(path: quarterCircleUL, shapeLength: shapeLength, bouncerColor: bouncerColor)
        ii_bouncer.position = CGPoint(x: 0, y: 700)
        addChild(ii_bouncer)
    
        iii_bouncer = Bouncer(path: quarterCircleUR, shapeLength: shapeLength, bouncerColor: bouncerColor)
        iii_bouncer.position = CGPoint(x: 512, y: 700)
        addChild(iii_bouncer)
        
        IV_bouncer = Bouncer(path: semiCircleL, shapeLength: shapeLength, bouncerColor: bouncerColor)
        IV_bouncer.position = CGPoint(x: 0, y: 384 - shapeLength/2)
        addChild(IV_bouncer)
        
        V_bouncer = Bouncer(path: semiCircleR, shapeLength: shapeLength, bouncerColor: bouncerColor)
        V_bouncer.position = CGPoint(x: 512, y: 384 - shapeLength/2)
        addChild(V_bouncer)
        
        vi_bouncer = Bouncer(path: quarterCircleDL, shapeLength: shapeLength, bouncerColor: bouncerColor)
        vi_bouncer.position = CGPoint(x: 0, y: 0)
        addChild(vi_bouncer)
        
        vii_bouncer = Bouncer(path: quarterCircleDR, shapeLength: shapeLength, bouncerColor: bouncerColor)
        vii_bouncer.position = CGPoint(x: 512, y: 0)
        addChild(vii_bouncer)
        
        // Draw dividers.
        makeDivider(at: CGPoint(x: 516, y: 316), size: CGSize(width: 5, height: 768))
        makeDivider(at: CGPoint(x: 516, y: 700), size: CGSize(width: 1038, height: 5))
        
        // Adds bassBall to GameScene.
        bassBall.fillColor = ballColor
        bassBall.position = CGPoint(x: 256, y: 192)
        bassBall.name = "bassBall"
        
        // Add physics body and detect object collisions.
        bassBall.physicsBody = bassBallPhysicsBody
        bassBall.physicsBody?.contactTestBitMask = 1
        bassBall.physicsBody?.collisionBitMask = 1
        bassBall.physicsBody?.categoryBitMask = 1
        bassBall.physicsBody?.restitution = 1
        bassBall.physicsBody?.friction = 0
        bassBall.physicsBody?.linearDamping = 0
        bassBall.physicsBody?.affectedByGravity = false
    
        // Adds bassBall to screen and sets it off on a random vector.
        addChild(bassBall)
        let randomVelocity = coinFlip ? Int.random(in: 40...50) : -Int.random(in: 40...50)
        let bassBallVector = CGVector(dx: randomVelocity, dy: randomVelocity)
        bassBall.physicsBody?.applyImpulse(bassBallVector)
    }
    
    // Ran immediately after initial touch.
    // Can either spawn balls when editingMode is false or adjust the filter when editingMode is true.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let objects = nodes(at: location)           // Used to interact with nodes through their variable name.
        let touchedNode = self.atPoint(location)    // Used to interact with nodes through their name property.
        let spark = SKEmitterNode(fileNamed: "Bokeh.sks")!
        spark.position = location
        spark.zPosition = 1

        switch effectsIndex {
        case 0:
            break
        case 1:
            sampler.adjustFilter(x: location.x, y: location.y)
            
            self.addChild(spark)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            spark.run(SKAction.sequence([wait, remove]))
        case 2:
            sampler.adjustReverb(x: location.x, y: location.y)
            
            self.addChild(spark)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            spark.run(SKAction.sequence([wait, remove]))
        default:
            break
        }
        
        // Checks if the point tapped on a screen contains a node.
        if objects.contains(effectsLabel) {
            // Increments 0 to 2 through and displays effects label list when effects label is touched.
            effectsIndex += 1
            if effectsIndex > 2 {
                effectsIndex = 0
            }
            effectsLabel.text = "\(effectsList[effectsIndex])"
        
        // Plays or pauses time when play/pause label is touched.
        } else if objects.contains(pauseLabel) {
            timePaused.toggle()
            
        // Shows/hides the about menu when the label is pressed.
        } else if objects.contains(aboutLabel) {
            aboutText.isHidden.toggle()
            
        // Shows/hides the settings menu when the label is pressed.
        } else if objects.contains(settingsLabel) {
            // Makes the about page transparent if it is open whilst the settings menu is accessed.
            if settingsMenu.isHidden == true {
                aboutText.alpha = 0
            } else {
                aboutText.alpha = 1
            }

            toggleSettingsMenu()
            
            // Shows/hides chord bouncers button-switches in the settings menu.
            for child in self.children {
               if let name = child.name, name == "toggleHidden" || name == "I_chord" || name == "ii_chord" || name == "iii_chord" || name == "IV_chord" || name == "V_chord" || name == "vi_chord" || name == "vii°_chord"{
                   toggleHideNodeAndChildren(child)
               }
            }
            
        // If the switch-buttons surrounding the label are pressed.
       } else if effectsIndex != 0 || settingsMenu.isHidden == false, let shapeNode = touchedNode as? SKShapeNode {
          switch shapeNode.name {
          case "I_chord":
              if buttonArray[0] {
                  shapeNode.fillColor = switchOffColor          // Turns the I chord button to the off color.
                  I_bouncer.isHidden = true                     // Hides the I chord bouncer.
                  I_bouncer.physicsBody?.categoryBitMask = 0    // Turns off collisions for the physics body.
                  buttonArray[0].toggle()                       // Toggles the index in the array keeping track of
                                                                // button onOff statuses.
              } else {
                  shapeNode.fillColor = switchOnColor
                  I_bouncer.isHidden = false
                  I_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[0].toggle()
              }
          case "ii_chord":
              if buttonArray[1] == true {
                  shapeNode.fillColor = switchOffColor
                  ii_bouncer.isHidden = true
                  ii_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[1].toggle()
              } else {
                  shapeNode.fillColor = switchOnColor
                  ii_bouncer.isHidden = false
                  ii_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[1].toggle()
              }
          case "iii_chord":
              if buttonArray[2] == true {
                  shapeNode.fillColor = switchOffColor
                  iii_bouncer.isHidden = true
                  iii_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[2].toggle()
              } else {
                  shapeNode.fillColor = switchOnColor
                  iii_bouncer.isHidden = false
                  iii_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[2].toggle()
              }
          case "IV_chord":
              if buttonArray[3] == true {
                  shapeNode.fillColor = switchOffColor
                  IV_bouncer.isHidden = true
                  IV_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[3].toggle()
              } else {
                  shapeNode.fillColor = switchOnColor
                  IV_bouncer.isHidden = false
                  IV_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[3].toggle()
              }
          case "V_chord":
              if buttonArray[4] == true {
                  shapeNode.fillColor = switchOffColor
                  V_bouncer.isHidden = true
                  V_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[4].toggle()
              } else {
                  shapeNode.fillColor = switchOnColor
                  V_bouncer.isHidden = false
                  V_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[4].toggle()
              }
          case "vi_chord":
              if buttonArray[5] == true {
                  shapeNode.fillColor = switchOffColor
                  vi_bouncer.isHidden = true
                  vi_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[5].toggle()
              } else {
                  shapeNode.fillColor = switchOnColor
                  vi_bouncer.isHidden = false
                  vi_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[5].toggle()
              }
          case "vii°_chord":
              if buttonArray[6] == true {
                  shapeNode.fillColor = switchOffColor
                  vii_bouncer.isHidden = true
                  vii_bouncer.physicsBody?.categoryBitMask = 0
                  buttonArray[6].toggle()
                  
              } else {
                  shapeNode.fillColor = switchOnColor
                  vii_bouncer.isHidden = false
                  vii_bouncer.physicsBody?.categoryBitMask = 1
                  buttonArray[6].toggle()
              }
          default:
              break
          }
           
        // If the labels on top of the switch-buttons are pressed.
        } else if let labelNode = touchedNode as? SKLabelNode, let shapeParent = touchedNode.parent as? SKShapeNode {
            switch labelNode.name {
            case "I_chord":
                if buttonArray[0] == true {
                    shapeParent.fillColor = switchOffColor
                    I_bouncer.isHidden = true
                    I_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[0].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    I_bouncer.isHidden = false
                    I_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[0] = true
                }
            case "ii_chord":
                if buttonArray[1] == true {
                    shapeParent.fillColor = switchOffColor
                    ii_bouncer.isHidden = true
                    ii_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[1].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    ii_bouncer.isHidden = false
                    ii_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[1].toggle()
                }
            case "iii_chord":
                if buttonArray[2] == true {
                    shapeParent.fillColor = switchOffColor
                    iii_bouncer.isHidden = true
                    iii_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[2].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    iii_bouncer.isHidden = false
                    iii_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[2].toggle()
                }
            case "IV_chord":
                if buttonArray[3] == true {
                    shapeParent.fillColor = switchOffColor
                    IV_bouncer.isHidden = true
                    IV_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[3].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    IV_bouncer.isHidden = false
                    IV_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[3].toggle()
                }
            case "V_chord":
                if buttonArray[4] == true {
                    shapeParent.fillColor = switchOffColor
                    V_bouncer.isHidden = true
                    V_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[4].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    V_bouncer.isHidden = false
                    V_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[4].toggle()
                }
            case "vi_chord":
                if buttonArray[5] == true {
                    shapeParent.fillColor = switchOffColor
                    vi_bouncer.isHidden = true
                    vi_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[5].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    vi_bouncer.isHidden = false
                    vi_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[5].toggle()
                }
            case "vii°_chord":
                if buttonArray[6] == true {
                    shapeParent.fillColor = switchOffColor
                    vii_bouncer.isHidden = true
                    vii_bouncer.physicsBody?.categoryBitMask = 0
                    buttonArray[6].toggle()
                } else {
                    shapeParent.fillColor = switchOnColor
                    vii_bouncer.isHidden = false
                    vii_bouncer.physicsBody?.categoryBitMask = 1
                    buttonArray[6].toggle()
                }
            default:
                break
            }

        // Creates balls on the right side of the screen.
        // Checks the settings menu is not in the way.
        } else if objects.doesNotContain(settingsMenu){
            // Checks whether the location touched is within the right half of the screen.
            if 520 < location.x && location.x < 1024 {
                if 0 < location.y && location.y < 695 {
                    // Creates a ball when "CREATE" is displayed on the effects label list - effectsLabel[0].
                    if effectsIndex == 0 {
                        // Create a ball and set physics.
                        let ball = SKShapeNode(circleOfRadius: 22)
                        ball.fillColor = ballColor
                        ball.strokeColor = .clear
                        
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: 20)
                        ball.physicsBody?.restitution = 1 // Bounce.
                        ball.physicsBody?.friction = 0
                        ball.physicsBody?.linearDamping = 0
                        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0   // Detect object collisions.
                        ball.position = location
                        ball.name = "ball"
                        
                        // Limit to four balls at a time.
                        if totalPKBalls < 4 {
                            addChild(ball)
                            totalPKBalls += 1
                        }
                    }
                }
            }
        }
    }
    
    // Ran whenever a touch is moved.
    // Adjusts the filter cutoff (X-axis) and resonance (Y-axis) or reverb wetDryMix.
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let spark = SKEmitterNode(fileNamed: "Bokeh.sks")!
        spark.position = location
        spark.zPosition = 1

        switch effectsIndex {
        case 0:
            break
        case 1:
            sampler.adjustFilter(x: location.x, y: location.y)
            
            self.addChild(spark)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            spark.run(SKAction.sequence([wait, remove]))
        case 2:
            sampler.adjustReverb(x: location.x, y: location.y)
            
            self.addChild(spark)
            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            spark.run(SKAction.sequence([wait, remove]))
        default:
            break
        }
    }
    
    // Detects collisions between any two nodes.
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Prevents crashes.
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        // Runs collision() when one of the nodes involved in a collision is a ball.
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
            // Applies angular velocity with each collision.
            nodeA.physicsBody?.applyAngularImpulse(nodeA.physicsBody!.angularVelocity * 0.1)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
            nodeB.physicsBody?.applyAngularImpulse(nodeB.physicsBody!.angularVelocity * 0.1)
        }
        
        // If the bassBall collides with anything apply the previously calculated impulse vector.
        if nodeA.name == "bassBall" {
            bassCollision(between: nodeA, object: nodeB)
        } else if nodeB.name == "bassBall" {
            bassCollision(between: nodeB, object: nodeA)
        }
    }
    
    // If a ball touches a pianoKey it plays the corresponding note in the chord.
    func collision(between ball: SKNode, object: SKNode) {
        let velocity: Int = calculateVelocity(between: ball)
        
        switch activeChord {
        case 0:
            switch object.name {
            case "PK1":
                sampler.playC(velocity: velocity)
            case "PK2":
                sampler.playE(velocity: velocity)
            case "PK3":
                sampler.playG(velocity: velocity)
            case "PK4":
                sampler.playB(velocity: velocity)
            default:
                // Ball collides with something that isn't a piano key.
                break
            }
        case 1:
            switch object.name {
            case "PK1":
                sampler.playD(velocity: velocity)
            case "PK2":
                sampler.playF(velocity: velocity)
            case "PK3":
                sampler.playA(velocity: velocity)
            case "PK4":
                sampler.playHighC(velocity: velocity)
            default:
                break
            }
        case 2:
            switch object.name {
            case "PK1":
                sampler.playE(velocity: velocity)
            case "PK2":
                sampler.playG(velocity: velocity)
            case "PK3":
                sampler.playB(velocity: velocity)
            case "PK4":
                sampler.playHighD(velocity: velocity)
            default:
                break
            }
        case 3:
            switch object.name {
            case "PK1":
                sampler.playF(velocity: velocity)
            case "PK2":
                sampler.playA(velocity: velocity)
            case "PK3":
                sampler.playC(velocity: velocity)
            case "PK4":
                sampler.playHighE(velocity: velocity)
            default:
                // Ball collides with something that isn't a piano key.
                break
            }
        case 4:
            switch object.name {
            case "PK1":
                sampler.playG(velocity: velocity)
            case "PK2":
                sampler.playB(velocity: velocity)
            case "PK3":
                sampler.playD(velocity: velocity)
            case "PK4":
                sampler.playHighF(velocity: velocity)
            default:
                // Ball collides with something that isn't a piano key.
                break
            }
        case 5:
            switch object.name {
            case "PK1":
                sampler.playA(velocity: velocity)
            case "PK2":
                sampler.playC(velocity: velocity)
            case "PK3":
                sampler.playE(velocity: velocity)
            case "PK4":
                sampler.playHighG(velocity: velocity)
            default:
                // Ball collides with something that isn't a piano key.
                break
            }
        case 6:
            switch object.name {
            case "PK1":
                sampler.playB(velocity: velocity)
            case "PK2":
                sampler.playD(velocity: velocity)
            case "PK3":
                sampler.playF(velocity: velocity)
            case "PK4":
                sampler.playHighA(velocity: velocity)
            default:
                // Ball collides with something that isn't a piano key.
                break
            }
        default:
            break
        }
    }
    
    // Checks if the other node involved in a collision with the bassBall is a chordBouncer.
    func bassCollision(between bassBall: SKNode, object: SKNode) {
        let velocity: Int = calculateVelocity(between: bassBall) + 30
        let randomVelocity = coinFlip ? Int.random(in: 35...50) : -Int.random(in: 35...50)
        if velocity < 30 {
            bassBall.physicsBody?.applyImpulse(CGVector(dx: randomVelocity, dy: randomVelocity))
        }
        
        // Plays the corresponding bassNote and sets the active chord upon impact.
        switch object {
        case I_bouncer:
            sampler.playBassC(velocity: velocity)
            activeChord = 0
        case ii_bouncer:
            sampler.playBassD(velocity: velocity)
            activeChord = 1
        case iii_bouncer:
            sampler.playBassE(velocity: velocity)
            activeChord = 2
        case IV_bouncer:
            sampler.playBassF(velocity: velocity)
            activeChord = 3
        case V_bouncer:
            sampler.playBassG(velocity: velocity)
            activeChord = 4
        case vi_bouncer:
            sampler.playBassA(velocity: velocity)
            activeChord = 5
        case vii_bouncer:
            sampler.playBassB(velocity: velocity)
            activeChord = 6
        default:
            break
        }
    }
    
    // Adjusts the gravity of the GameScene.
    func setGravity(_ gravity: Float) {
        physicsWorld.gravity = CGVector(dx: 0, dy: CGFloat(gravity))
    }
    
    // Calculates speed of a node using its vector and updates with a new speed.
    func setNodeSpeed(speed: CGFloat, for node: SKPhysicsBody) {
        let currentSpeed: CGFloat = sqrt(pow(node.velocity.dx, 2) + pow(node.velocity.dy, 2))
        let scaleFactor = speed / currentSpeed
        node.velocity.dx *= scaleFactor
        node.velocity.dy *= scaleFactor
    }
    
    // Hides/unhides a node and all its children.
    func toggleHideNodeAndChildren(_ node: SKNode) {
        node.isHidden.toggle()
        for child in node.children {
            toggleHideNodeAndChildren(child)
        }
    }
    
    // Calculates velocity of a ball upon impact.
    func calculateVelocity(between ball: SKNode) -> Int {
        let velX: Float = Float(ball.physicsBody!.velocity.dx)  // X-vector velocity of a ball upon impact.
        let velY: Float = Float(ball.physicsBody!.velocity.dy)  // Y-vector velocity of a ball upon impact.
        let velAvg: Float = (abs(velX) + abs(velY) / 2)         // The average of the absolute value of the sum of both vectors.
        
        var velocity: Int = Int((2/13) * velAvg - 23)           // Approximately converts values into 0-127 MIDI velocity range.
        
        if velocity < 0 {                                       // Prevents velocity from reaching MIDI values that could cause crashes.
            velocity *= -1
        }
        if velocity > 128 {
            velocity = 128
        }
        if velocity < 35 {
            velocity = 35
        }
        
        return velocity
    }
    
    // Remove all pianoKey balls from GameScene.
    func removeBalls() {
        for child in self.children {
            if child.name == "ball" {
                child.removeFromParent()
            }
        }
        totalPKBalls = 0
    }
    
    // Shows/hides the settings menu.
    func toggleSettingsMenu() {
        // Show/hide effect labels & sliders.
        viewController?.filterLabel.isHidden.toggle()
        viewController?.filterSwitch.isHidden.toggle()
        
        viewController?.reverbLabel.isHidden.toggle()
        viewController?.reverbSwitch.isHidden.toggle()
        
        viewController?.delayLabel.isHidden.toggle()
        viewController?.delaySwitch.isHidden.toggle()
        viewController?.delayWetLabel.isHidden.toggle()
        viewController?.delayWetSlider.isHidden.toggle()
        viewController?.delayTimeLabel.isHidden.toggle()
        viewController?.delayTimeSlider.isHidden.toggle()
        
        viewController?.soundLabel.isHidden.toggle()
        viewController?.soundPicker.isHidden.toggle()
        
        // Show/hide physics labels & sliders, and the menu itself.
        viewController?.speedLabel.isHidden.toggle()
        viewController?.speedSlider.isHidden.toggle()
        viewController?.gravityLabel.isHidden.toggle()
        viewController?.gravitySlider.isHidden.toggle()
        viewController?.resetButton.isHidden.toggle()
        
        settingsMenu.isHidden.toggle()
    }
    
    // Creates the settings menu (initially hidden).
    func makeSettingsMenu() {
        // Draw menu background.
        settingsMenu = SKShapeNode(rect: CGRect(x: 100, y: 100, width: 824, height: 568), cornerRadius: 22)
        settingsMenu.zPosition = 0.5
        settingsMenu.isHidden = true
        settingsMenu.fillColor = settingsMenuColor
        addChild(settingsMenu)
        
        // Adds dividers to the menu screen.
        makeMenuDivider(at: CGPoint(x: 374.666, y: 384), size: CGSize(width: 5, height: 568), name: "toggleHidden")
        makeMenuDivider(at: CGPoint(x: 649.333, y: 384), size: CGSize(width: 5, height: 568), name: "toggleHidden")
        
        // Add labels to menu.
        let chordsLabel = MenuLabel(text: "CHORDS", position: CGPoint(x: 238, y: 575), zPosition: 0.6, name: "toggleHidden", hidden: true)
        addChild(chordsLabel)

        let physicsLabel = MenuLabel(text: "PHYSICS", position: CGPoint(x: 512, y: 575), zPosition: 0.6, name: "toggleHidden", hidden: true)
        addChild(physicsLabel)
        
        let effectsMenuLabel = MenuLabel(text: "SOUNDS", position: CGPoint(x: 786, y: 575), zPosition: 0.6, name: "toggleHidden", hidden: true)
        addChild(effectsMenuLabel)
        
        // Create interactive switch buttons used to customise the harmony of the app.
        makeChordLabel(at: CGPoint(x: 237.333, y: 525), size: CGSize(width: 200, height: 50), chord: "I")
        makeChordLabel(at: CGPoint(x: 177, y: 425), size: CGSize(width: 75, height: 50), chord: "ii")
        makeChordLabel(at: CGPoint(x: 297.666, y: 425), size: CGSize(width: 75, height: 50), chord: "iii")
        makeChordLabel(at: CGPoint(x: 177, y: 325), size: CGSize(width: 75, height: 50), chord: "IV")
        makeChordLabel(at: CGPoint(x: 297.666, y: 325), size: CGSize(width: 75, height: 50), chord: "V")
        makeChordLabel(at: CGPoint(x: 177, y: 225), size: CGSize(width: 75, height: 50), chord: "vi")
        makeChordLabel(at: CGPoint(x: 297.666, y: 225), size: CGSize(width: 75, height: 50), chord: "vii°")
    }
    
    // Creates the information page (hidden by default).
    func makeAboutMenu() {
        // Adds hidden text view with coloured frame to GameScene.
        aboutText = UITextView(frame: CGRect(x: 192, y: 142, width: 700, height: 500))
        aboutText.textAlignment = .center
        aboutText.isScrollEnabled = false
        aboutText.layer.cornerRadius = 22
        aboutText.text = "INFORMATION HAS BEEN INTENTIONLLY RESTRICTED ON CLUM.SY TO ENCOURAGE EXPERIMENTING & EXPLORING. HOWEVER... YOU COULD TRY TAPPING THE RIGHT SIDE OF THE SCREEN WHEN 'CREATE' IS DISPLAYED IN THE UPPER LEFT... OR MAYBE TAP CREATE TILL YOU SEE 'FILTER' AND MOVE YOUR FINGER AROUND THE SCREEN... THINGS LIKE THAT."
        aboutText.font = UIFont(name: "AvenirNext-HeavyItalic", size: 28)
        aboutText.textColor = UIColor.white
        aboutText.backgroundColor = settingsMenuColor
        aboutText.isEditable = false
        aboutText.isSelectable = false
        aboutText.isHidden = true
        aboutText.layer.zPosition = 0.4
        self.view?.addSubview(aboutText)

        // Adjusts text container to centre it within the frame.
        aboutText.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        aboutText.layoutManager.ensureLayout(for: aboutText.textContainer)
        let textHeight = aboutText.layoutManager.usedRect(for: aboutText.textContainer).height
        let viewHeight = aboutText.frame.size.height
        let topInset = (viewHeight - textHeight) / 2
        aboutText.textContainerInset = UIEdgeInsets(top: topInset, left: 20, bottom: 0, right: 20)
    }
    
    // Draws a piano key at the specified position.
    // Each piano key is given a unique .name property using PKIndex so that there is a
    // way to identify them for collisions.
    func makePianoKey(at position: CGPoint) {
        let pianoKey = SKShapeNode(rect: CGRect(x: -57, y: -10, width: 124, height: 25), cornerRadius: 10)
        pianoKey.physicsBody = SKPhysicsBody(rectangleOf: pianoKey.frame.size, center: pianoKey.position)
        pianoKey.physicsBody?.isDynamic = false
        pianoKey.physicsBody?.restitution = 1
        pianoKey.physicsBody?.friction = 0
        
        pianoKey.name = "PK\(PKIndex)"
        pianoKey.position = position
        pianoKey.zPosition = -0.5
        pianoKey.fillColor = bouncerColor
        pianoKey.strokeColor = .clear
        
        addChild(pianoKey)
        PKIndex += 1
    }
    
    // Creates a label at the specified position.
    func makeLabel(name: String, at position: CGPoint, text: String) {
        let label = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        label.position = position
        label.text = text
        label.name = name
        addChild(label)
    }
    
    // Draws a thin line used to divide the screen into its separate sections.
    func makeDivider(at position: CGPoint, size: CGSize) {
        let box = SKSpriteNode(color: .white, size: size)
        box.position = position
        box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
        box.physicsBody?.isDynamic = false
        addChild(box)
    }
    
    // Draws similar lines used for the menu screen, as a result there is no need for physics properties.
    func makeMenuDivider(at position: CGPoint, size: CGSize, name: String) {
        let box = SKSpriteNode(color: .white, size: size)
        box.position = position
        box.zPosition = 0.6
        box.name = name
        box.isHidden = true
        addChild(box)
    }
    
    // Draws the chord button-switches used in the settings menu to select or deselect
    // which chords are currently active.
    func makeChordLabel(at position: CGPoint, size: CGSize, chord: String) {
        let shape = SKShapeNode(rectOf: size, cornerRadius: 22)
        shape.fillColor = switchOnColor
        shape.position = position
        shape.zPosition = 0.65
        shape.name = "\(chord)_chord"
        shape.isHidden = true
        
        let label = SKLabelNode(fontNamed: "AvenirNext-HeavyItalic")
        label.text = chord
        label.position.y -= size.height / 3.5
        label.zPosition = 0.7
        label.name = "\(chord)_chord"
        label.isHidden = true
        
        shape.addChild(label)
        addChild(shape)
    }
}
