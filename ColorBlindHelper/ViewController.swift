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
    var camera:Camera!
    
    @IBOutlet weak var stripeControl: UISegmentedControl!
    @IBOutlet weak var satSlider: UISlider!

    var counter = 1
    var timer = Timer()
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(ViewController.doSomeAnimation), userInfo: nil, repeats: true)
        do {
            
            camera = try Camera(sessionPreset: AVCaptureSessionPresetHigh)
            camera.runBenchmark = true
            blendFilter.thresholdSensitivity = 0.4
            blendFilter.smoothing = 0.1
            blendFilter.colorToReplace = Color.init(red: 0, green: 1, blue: 0, alpha: 1.0)
            
            satFilter.saturation = 1

            
            /*camera --> blendFilter --> satFilter --> renderView
            camera --> multiplyFilter
            pictureInput --> multiplyFilter --> blendFilter


            pictureInput.processImage()*/

            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
    }
    
    func doSomeAnimation() {
        //I have four pngs in my project, which are named frame1.png ... and so on
        print("stripes\(counter).png")
        
        if counter == 25 {
            
            counter = 1
            
        }else {
            
            counter += 2
        }
        
        testImage = UIImage(named: "stripes\(counter)-min.png")!
        
        //camera.stopCapture()
        camera.removeAllTargets()
        //blendFilter.removeAllTargets()
        //satFilter.removeAllTargets()
        //multiplyFilter.removeAllTargets()
        pictureInput.removeAllTargets()
        
        pictureInput = PictureInput(image:testImage)
        
        camera --> satFilter --> blendFilter --> renderView
        camera --> multiplyFilter
        pictureInput --> multiplyFilter --> blendFilter
        
        pictureInput.processImage()
        //camera.startCapture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func stripeModeSwitch(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex
        {
        case 0:
            blendFilter.colorToReplace = Color.init(red: 0, green: 1, blue: 0, alpha: 1.0)
        case 1:
            blendFilter.colorToReplace = Color.init(red: 1, green: 0, blue: 0, alpha: 1.0)
        default:
            break; 
        }
    }
    @IBAction func satChangeSlider(_ sender: UISlider) {
        satFilter.saturation = sender.value + 1
    }
    
    
}

