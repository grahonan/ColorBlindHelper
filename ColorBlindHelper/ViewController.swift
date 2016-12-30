import UIKit
import CoreImage
import GPUImage
import AVFoundation

var testImage = UIImage(named:"stripes1-min.png")!

var pictureInput = PictureInput(image:testImage)


class ViewController: UIViewController {
    var renderView: RenderView!
    
    let saturationFilter = SaturationAdjustment()
    let blendFilter = ChromaKeyBlend()
    let multiplyFilter = MultiplyBlend()
    let hueFilter = HueAdjustment()
    let satFilter = SaturationAdjustment()
    let testFilter = LuminanceThreshold()
    let rgbFilter = RGBAdjustment()
    var camera:Camera!
    
    var boost: Float = 1.0
    
    @IBOutlet weak var stripeControl: UISegmentedControl!
    @IBOutlet weak var satSlider: UISlider!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var counter = 1
    var timer = Timer()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 0.30, target: self, selector: #selector(ViewController.doSomeAnimation), userInfo: nil, repeats: true)
        do {
            
            camera = try Camera(sessionPreset: AVCaptureSessionPresetHigh)
            camera.runBenchmark = true
            blendFilter.thresholdSensitivity = 0.4
            blendFilter.smoothing = 0.1
            blendFilter.colorToReplace = Color.init(red: 0, green: 1, blue: 0, alpha: 1.0)
            
            satFilter.saturation = 1

            
            camera --> satFilter --> blendFilter  --> rgbFilter --> renderView
            camera --> multiplyFilter
            pictureInput --> multiplyFilter --> blendFilter


            pictureInput.processImage()

            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
    }
    
    func doSomeAnimation() {
        
        
        testImage = UIImage(named: "stripes\(counter)-min.png")!
        

        pictureInput.removeAllTargets()
        pictureInput = PictureInput(image:testImage)
        pictureInput --> multiplyFilter --> blendFilter
        
        pictureInput.processImage()
        
        counter += 5
        counter %= 25
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func stripeModeSwitch(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            blendFilter.thresholdSensitivity = 0.42
            blendFilter.colorToReplace = Color.init(red: 0, green: 1, blue: 0, alpha: 1.0)
            rgbFilter.red = boost
            rgbFilter.green = 1
            
        case 1:
            blendFilter.thresholdSensitivity = 0.35
            blendFilter.colorToReplace = Color.init(red: 1, green: 0, blue: 0, alpha: 1.0)
            
            rgbFilter.green = boost
            rgbFilter.red = 1
        default:
            break;
        }
    }
    @IBAction func satChangeSlider(_ sender: UISlider) {
        satFilter.saturation = sender.value + 1
        boost = (sender.value/10.0) + Float(1.0)
        if(stripeControl.selectedSegmentIndex == 0){
            rgbFilter.red = boost
            rgbFilter.green = 1
        } else {
            
            rgbFilter.green = boost
            rgbFilter.red = 1
        }
        
    }
    
    @IBAction func showHelp(_ sender: UIButton) {
        infoView.isHidden = false
    }
    
    @IBAction func hideHelp(_ sender: UIBarButtonItem) {
        infoView.isHidden = true
    }
    
    
}

