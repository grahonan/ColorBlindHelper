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
    
    var torchOn: Bool = false;
    var cameraCapturing: Bool = true // save whether we're in freeze frame mode or not
    var stripesOn: Bool = true // save whether stripes are on or off
    var boost: Float = 1.0 // saved Red/Green adjustment value
    var redThreshold: Float = 0.2;
    var greenThreshold: Float = 0.4;
    let greenSensitivity: Float = 0.4
    let redSensitivity: Float = 0.2
    let intensityScaleFactor: Float = 10.0
    let defaultVal:Float = 1.0
    let defaultUIColor: UIColor = UIColor.init(red: 0, green: 0.478, blue: 1, alpha: 1)
    
    @IBOutlet weak var stripeControl: UISegmentedControl!
    @IBOutlet weak var satSlider: UISlider!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var freezeButton: UIButton!
    @IBOutlet weak var lightButton: UIButton!
    
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
        
        if(stripesOn){
            stripeImage = UIImage(named: "stripes\(counter)-min.png")!  // Attach newest frame of animation to stripeImage
        }
        else {
            stripeImage = UIImage(named: "white.png")!  // Attach white image to turn off stripes
        }
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
            greenThreshold = (satSlider.value/intensityScaleFactor) + greenSensitivity;
            blendFilter.thresholdSensitivity = greenThreshold
            blendFilter.colorToReplace = Color.green
            blendFilter.smoothing = 0.1
            
            // set RGB adjustment filter
            rgbFilter.red = boost
            rgbFilter.green = defaultVal
            
            stripesOn = true
            
        case 1:
            // set Chroma threshold and color
            redThreshold = (satSlider.value/intensityScaleFactor) + redSensitivity;
            blendFilter.thresholdSensitivity = redThreshold;
            blendFilter.colorToReplace = Color.red
            
            // set RGB adjustment filter
            rgbFilter.green = boost
            rgbFilter.red = defaultVal
            
            stripesOn = true
            
        case 2:
            // turn off stripe pattern
            stripesOn = false

        default:
            break;
        }
    }
    
    // Saturation slider adjusts both saturation and red/green intensity in non-striped region
    @IBAction func satChangeSlider(_ sender: UISlider) {
        
        satFilter.saturation = sender.value + defaultVal
        
        boost = (sender.value/intensityScaleFactor) + defaultVal
        
        if(stripeControl.selectedSegmentIndex == 0){ // if Green, boost the red in the non-striped region
            greenThreshold = (sender.value/intensityScaleFactor) + greenSensitivity;
            blendFilter.thresholdSensitivity = greenThreshold;
            rgbFilter.red = boost
            rgbFilter.green = defaultVal
        }
        else { // if Red, boost the green in the non-striped region
            redThreshold = (sender.value/intensityScaleFactor) + redSensitivity;
            blendFilter.thresholdSensitivity = redThreshold;
            rgbFilter.green = boost
            rgbFilter.red = defaultVal
        }
        
    }
    
    @IBAction func freezeToggle(_ sender: UIButton) {
        if(cameraCapturing){
            camera.stopCapture()
            cameraCapturing = false
            sender.setTitle("Unfreeze", for: UIControlState.normal)
            sender.tintColor = UIColor.red
        }
        else {
            camera.startCapture()
            if(torchOn){
                torchOn = false;
                toggleFlash(lightButton);
            }
            cameraCapturing = true
            sender.setTitle("Freeze", for: UIControlState.normal)
            sender.tintColor = defaultUIColor
        }
    }
    
    @IBAction func showHelp (_ sender: UIButton) {
        infoView.isHidden = false
    }
    
    @IBAction func hideHelp(_ sender: UIBarButtonItem) {
        infoView.isHidden = true
    }
    
    @IBAction func toggleFlash(_ sender: UIButton) {
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        if (device?.hasTorch)! {
            do {
                try device?.lockForConfiguration()
                if (torchOn) {
                    device?.torchMode = AVCaptureTorchMode.off
                    torchOn = false;
                } else {
                    do {
                        try device?.setTorchModeOnWithLevel(1.0)
                        torchOn = true;
                    } catch {
                        print(error)
                    }
                }
                device?.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
    
    
}

