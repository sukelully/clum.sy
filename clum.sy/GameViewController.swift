import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Declare a variable to hold a reference to the current game scene.
    var currentGame: GameScene?
    
    // Outlets for the various UI elements.
    @IBOutlet weak var filterSwitch: UISwitch!
    @IBOutlet weak var reverbSwitch: UISwitch!
    @IBOutlet weak var delaySwitch: UISwitch!
    
    @IBOutlet weak var filterLabel: UILabel!
    @IBOutlet weak var reverbLabel: UILabel!
    @IBOutlet weak var delayLabel: UILabel!
    @IBOutlet weak var delayWetLabel: UILabel!
    @IBOutlet weak var delayTimeLabel: UILabel!
    @IBOutlet weak var soundLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var gravityLabel: UILabel!
    
    @IBOutlet weak var delayWetSlider: UISlider!
    @IBOutlet weak var delayTimeSlider: UISlider!
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var gravitySlider: UISlider!
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var soundPicker: UIPickerView!
    var soundPickerArray: [String] = ["MARIMBA", "PLUCK", "CLAV", "LITTLE_EP", "GRAND", "MUTED", "HARP"]
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'.
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window.
                scene.scaleMode = .aspectFill
                
                // Present the scene.
                view.presentScene(scene)
                
                // Used if multiple scenes are required.
                currentGame = scene as? GameScene
                currentGame?.viewController = self
            }
            
            // Set properties for the SKView.
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
        }
        
        // Hide the labels.
        filterLabel.isHidden = true
        reverbLabel.isHidden = true
        delayLabel.isHidden = true
        delayWetLabel.isHidden = true
        delayTimeLabel.isHidden = true
        soundLabel.isHidden = true
        speedLabel.isHidden = true
        gravityLabel.isHidden = true
        resetButton.isHidden = true
        
        // Hide and set up the sound picker.
        soundPicker.isHidden = true
        soundPicker.delegate = self
        soundPicker.dataSource = self
        
        // Hide and style the switches.
        filterSwitch.isHidden = true
        filterSwitch.onTintColor = switchOnColor

        delaySwitch.isHidden = true
        delaySwitch.onTintColor = switchOnColor

        reverbSwitch.isHidden = true
        reverbSwitch.onTintColor = switchOnColor
        
        // Hide and style the sliders.
        delayWetSlider.isHidden = true
        delayWetSlider.minimumTrackTintColor = .white
        
        delayTimeSlider.isHidden = true
        delayTimeSlider.minimumTrackTintColor = .white
        
        speedSlider.isHidden = true
        speedSlider.minimumTrackTintColor = .white
        
        gravitySlider.isHidden = true
        gravitySlider.minimumTrackTintColor = .white
        
    }
    
    // Sets the sample used to whatever the soundPicker is currently displaying.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // GameScene needs to be paused whilst the sampler loads a new
        // file otherwise it will not load correctly.
        let isPausedTemp = currentGame?.isPaused
        
        if currentGame?.isPaused == false {
            currentGame?.isPaused.toggle()
        }
        
        switch soundPickerArray[row] {
        case "MARIMBA":
            try! samplerMIDI.loadWav("marimba")
        case "PLUCK":
            try! samplerMIDI.loadWav("pluck")
        case "CLAV":
            try! samplerMIDI.loadWav("clav")
        case "LITTLE_EP":
            try! samplerMIDI.loadWav("littleEP")
        case "GRAND":
            try! samplerMIDI.loadWav("grand")
        case "MUTED":
            try! samplerMIDI.loadWav("muted")
        case "HARP":
            try! samplerMIDI.loadWav("harp")
        default:
            break
        }
        
        currentGame?.isPaused = isPausedTemp!
    }
    
    // Actions for the switches.
    @IBAction func filterSwitchChanged(_ sender: Any) {
        sampler.toggleFilter()
    }
    
    @IBAction func reverbSwitchChanged(_ sender: Any) {
        sampler.toggleReverb()
    }
    
    @IBAction func delaySwitchChanged(_ sender: Any) {
        sampler.toggleDelay()
    }
    
    @IBAction func delayWetSliderChanged(_ sender: Any) {
        sampler.adjustDelayWet(wet: delayWetSlider.value)
    }
    
    @IBAction func delayTimeSliderChanged(_ sender: Any) {
        sampler.adjustDelayTime(time: delayTimeSlider.value)
    }
    
    @IBAction func speedSliderChanged(_ sender: Any) {
        currentGame?.setNodeSpeed(speed: CGFloat(speedSlider.value), for: bassBallPhysicsBody)
    }
    
    @IBAction func gravitySliderChanged(_ sender: Any) {
        currentGame?.setGravity(gravitySlider.value * -1)
    }
    
    // Removes all pianoKey balls from the GameScene and sets the bassBall off on a random vector.
    @IBAction func resetButtonChanged(_ sender: Any) {
        // Used to set the bassBall of on a randomVector.
        let coinFlip = Bool.random()
        let randomVelocity = coinFlip ? Int.random(in: 40...50) : -Int.random(in: 40...50)
        let bassBallVector = CGVector(dx: randomVelocity, dy: randomVelocity)
        
        // Removes pianoKey balls and applys a random impulse vector to the bassBall.
        currentGame?.removeBalls()
        currentGame?.setNodeSpeed(speed: CGFloat(0), for: bassBallPhysicsBody)
        bassBall.physicsBody?.applyImpulse(bassBallVector)
        
        sampler.resetEngine()
    }
    
    // Autorotation and status bar settings.
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
    
    // Dispose of any resources that can be recreated.
    override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()

        }
    
    // Return the number of compnent (columns) in the picker view.
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Return the number of rows for a given component.
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent: Int) -> Int {
        return soundPickerArray.count
    }
    
    // Return the title of a given row for a given component.
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return soundPickerArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel()
        label.text = soundPickerArray[row]
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-HeavyItalic", size: 20)
        return label
    }
}
