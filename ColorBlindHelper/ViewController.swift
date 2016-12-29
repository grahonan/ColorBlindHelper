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
    var camera:Camera!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            camera = try Camera(sessionPreset: AVCaptureSessionPresetHigh)
            camera.runBenchmark = true
            blendFilter.thresholdSensitivity = 0.4
            blendFilter.smoothing = 0.1
            
            camera --> blendFilter --> renderView
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

}

