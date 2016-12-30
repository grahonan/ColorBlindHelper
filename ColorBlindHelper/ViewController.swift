import UIKit
import GPUImage
import AVFoundation

var stripeImage = UIImage(named:"stripes0-min.png")! // First frame of stripe animation
var pictureInput = PictureInput(image:stripeImage)


class ViewController: UIViewController {
    var renderView: RenderView!

    let blendFilter = ChromaKeyBlend()
    let multiplyFilter = MultiplyBlend()
    let satFilter = SaturationAdjustment()
    let rgbFilter = RGBAdjustment()
    var camera:Camera!
    
    var boost: Float = 1.0 // saved Red/Green adjustment value
    let greenSensitivity: Float = 0.42
    let redSensitivity: Float = 0.35
    let intensityScaleFactor: Float = 10.0
    let defaultVal:Float = 1.0
    
    @IBOutlet weak var stripeControl: UISegmentedControl!
    @IBOutlet weak var satSlider: UISlider!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var counter = 0 // Frame counter for stripe animation
    var timer = Timer() // Timer for stripe animation
    override var prefersStatusBarHidden: Bool { // Hide status bar (carrier, battery, etc)
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 0.30, target: self, selector: #selector(ViewController.timerCB), userInfo: nil, repeats: true) // 300 ms timer
        
        do {
            
            camera = try Camera(sessionPreset: AVCaptureSessionPresetHigh)
            camera.runBenchmark = true
            
            
            blendFilter.thresholdSensitivity = greenSensitivity
            blendFilter.colorToReplace = Color.green

            
            camera --> satFilter --> blendFilter  --> rgbFilter --> renderView
            
            // Generate stripe pattern on camera ouput
            camera --> multiplyFilter
            pictureInput --> multiplyFilter --> blendFilter


            pictureInput.processImage()

            camera.startCapture()
        }
        catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
    }
    
    func timerCB() {
        
        
        stripeImage = UIImage(named: "stripes\(counter)-min.png")!  // Attach newest frame of animation to stripeImage
        
        // Reset pictureInput and reprocess with new stripeImage
        pictureInput.removeAllTargets()
        pictureInput = PictureInput(image:stripeImage)
        pictureInput --> multiplyFilter --> blendFilter
        
        pictureInput.processImage()
        
        counter += 5
        counter %= 25
    }
    
    
    // Set the correct threshold and replacement color based on user's selection
    @IBAction func stripeModeSwitch(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            // set Chroma threshold and color
            blendFilter.thresholdSensitivity = greenSensitivity
            blendFilter.colorToReplace = Color.green
            
            // set RGB adjustment filter
            rgbFilter.red = boost
            rgbFilter.green = defaultVal
            
        case 1:
            // set Chroma threshold and color
            blendFilter.thresholdSensitivity = redSensitivity
            blendFilter.colorToReplace = Color.red
            
            // set RGB adjustment filter
            rgbFilter.green = boost
            rgbFilter.red = defaultVal
        default:
            break;
        }
    }
    
    // Saturation slider adjusts both saturation and red/green intensity in non-striped region
    @IBAction func satChangeSlider(_ sender: UISlider) {
        
        satFilter.saturation = sender.value + defaultVal
        boost = (sender.value/intensityScaleFactor) + defaultVal
        
        if(stripeControl.selectedSegmentIndex == 0){ // if Green, boost the red in the non-striped region
            rgbFilter.red = boost
            rgbFilter.green = defaultVal
        }
        else { // if Red, boost the green in the non-striped region
            
            rgbFilter.green = boost
            rgbFilter.red = defaultVal
        }
        
    }
    
    @IBAction func showHelp(_ sender: UIButton) {
        infoView.isHidden = false
    }
    
    @IBAction func hideHelp(_ sender: UIBarButtonItem) {
        infoView.isHidden = true
    }
    
    
}

