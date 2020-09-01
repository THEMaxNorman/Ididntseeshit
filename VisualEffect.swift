import AVFoundation
import HaishinKit

import UIKit
//This is where the black/hopefully blur come from.

final class PronamaEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CISourceOverCompositing")
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil)
    var bounds = CGRect(x: 0,y: 0,width: 0,height: 0)
    let screenSize: CGRect = UIScreen.main.bounds
    //Timer will count to 60 and reset
    var timer = 0
    var extent = CGRect.zero {
    didSet {
            if extent == oldValue && timer < 60 {
                //return for time based on - fps
                timer += 1
                return
            }
        timer = 0
            UIGraphicsBeginImageContext(extent.size)
        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }

        // 2
        context.saveGState()

        // 3
        defer {
          context.restoreGState()
        }
        
        UIColor.red.setStroke()
        UIColor.black.setFill()
        // 4
        //Adds in the face bar makes it span the whole X and 9% bigger than detected face bounds on the Y
        let faceBar = CGRect(x: 0, y: bounds.minY, width: screenSize.width * 3, height: bounds.height + (bounds.height * 0.09))
        print(faceBar)
        context.addRect(faceBar)
        context.fill(faceBar)

        // 5
        

        // 6
        context.strokePath()
        context.fillPath()
        //let atts = [NSFontAttributeName:NSFont.init(name: "Georgia", size: 30)]
        let water = Preference.defaultInstance.waterMark
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        let attributes = [
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32.0),
            NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
            
        ]

        let myText = water
        let attributedString = NSAttributedString(string: myText, attributes: attributes)

        let stringRect = CGRect(x: screenSize.width/2 - 50, y: screenSize.maxY, width: screenSize.width, height: screenSize.height)
        attributedString.draw(in: stringRect)
            //let image = UIImage(named: "Icon.png")!
        print(bounds.minX)
        print(bounds.minY)
       // image.draw(at: CGPoint(x: bounds.minX, y: bounds.minY))
            pronama = CIImage(image: UIGraphicsGetImageFromCurrentImageContext()!, options: nil)
            UIGraphicsEndImageContext()
        }
    }
    var pronama: CIImage?

    override init() {
        super.init()
    }

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        extent = image.extent
        //Checks to see if we should look for faces
        if (timer == 59){
            let faces = faceDetector?.features(in: image)
            let face = faces?.first
            if(face?.bounds != nil){
                print("Found, Face")
                bounds = face?.bounds as! CGRect
            }
            else{
                bounds = CGRect.zero
            }
            print(bounds)
        }
        filter.setValue(pronama!, forKey: "inputImage")
        filter.setValue(image, forKey: "inputBackgroundImage")
        return filter.outputImage!
    }
}

final class MonochromeEffect: VideoEffect {
    let filter: CIFilter? = CIFilter(name: "CIColorMonochrome")

    override func execute(_ image: CIImage, info: CMSampleBuffer?) -> CIImage {
        guard let filter: CIFilter = filter else {
            return image
        }
        filter.setValue(image, forKey: "inputImage")
        filter.setValue(CIColor(red: 0.75, green: 0.75, blue: 0.75), forKey: "inputColor")
        filter.setValue(1.0, forKey: "inputIntensity")
        return filter.outputImage!
    }
}
