import UIKit
import CoreImage
import GPUImage
import AVFoundation

let testImage = UIImage(named:"stripesbw.png")!
let pictureInput = PictureInput(image:testImage)

class ViewController: UIViewController {
    var renderView: RenderView!
    
    let saturationFilter = SaturationAdjustment()
    let blendFilter = ChromaKeyBlend()
    let alphaFilter = MultiplyBlend()
    let hueFilter = HueAdjustment()
    let satFilter = SaturationAdjustment()
    let testFilter = LuminanceThreshold()
    var camera:Camera!
    @IBOutlet weak var stripeSwitch: UISwitch!
    @IBOutlet weak var satSlider: UISlider!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("test")
        do {
            camera = try Camera(sessionPreset: AVCaptureSessionPresetHigh)
            camera.runBenchmark = true
            blendFilter.thresholdSensitivity = 0.4
            blendFilter.smoothing = 0.1
            blendFilter.colorToReplace = Color.init(red: 1, green: 0, blue: 0, alpha: 1.0)
            
            satFilter.saturation = 1
            
            camera --> blendFilter --> satFilter --> renderView
            camera --> alphaFilter
            pictureInput --> alphaFilter --> blendFilter


            pictureInput.processImage()
            camera.startCapture()
        } catch {
            fatalError("Could not initialize rendering pipeline: \(error)")
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    @IBAction func stripeModeSwitch(_ sender: UISwitch) {
        if sender.isOn {
            blendFilter.colorToReplace = Color.init(red: 0, green: 1, blue: 0, alpha: 1.0)
        } else {
            blendFilter.colorToReplace = Color.init(red: 1, green: 0, blue: 0, alpha: 1.0)
        }
    }
    @IBAction func satChangeSlider(_ sender: UISlider) {
        satFilter.saturation = sender.value + 1
    }
    
    
}

