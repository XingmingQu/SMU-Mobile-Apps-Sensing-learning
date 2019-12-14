//
//  ModuleAViewController.swift
//  ImageLab
//
//  Created by Xingming on 10/24/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

import UIKit



class ModuleAViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,URLSessionDelegate  {
    
    //MARK: Class Properties
    
    var videoManager:VideoAnalgesic! = nil
    var detector:CIDetector! = nil
    var blinkTimes = 0
    let bridge = OpenCVBridge()
    let mytool = tools()
    let operationQueue = OperationQueue()
    var session = URLSession()
    var timer : Timer?
    
    @IBOutlet weak var resultLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 25.0
        sessionConfig.timeoutIntervalForResource = 28.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        self.view.backgroundColor = nil
        
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        
        // create dictionary for face detection
        // HINT: you need to manipulate these proerties for better face detection efficiency
        let optsDetector = [CIDetectorAccuracy:CIDetectorAccuracyLow]
        
        // setup a face detector in swift
        self.detector = CIDetector(ofType: CIDetectorTypeFace,
                                   context: self.videoManager.getCIContext(), // perform on the GPU if possible
            options: optsDetector)
        
        self.bridge.setTransforms(self.videoManager.transform)
        
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.front)
        self.bridge.setTransforms(self.videoManager.transform)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning{
            videoManager.start()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
          
                let randomNumber = Int.random(in: 1...20)
                print("Number: \(randomNumber)")
                
                let frame = self.videoManager.currentFrame!
                let currentImage = UIImage(ciImage: frame)
                let _ = self.sendFeatures(currentImage)

              if (self.blinkTimes > 2){
                //update DB
                self.blinkTimes = 0
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
                if videoManager.isRunning{
            videoManager.stop()
        }
        
        
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    
    //MARK: Process image output
    
    func processImage(inputImage:CIImage) -> CIImage{
//        print(self.blinkTimes)
        // --------detect faces and high light-----------------------
        let f = getFaces(img: inputImage)
        // if no faces, just return original image
        if f.count == 0 { return inputImage }
        var retImage = inputImage
        
        //Highlights multiple faces in the scene using CoreImage filters
        for faces in f {
            self.bridge.setImage(retImage, withBounds: faces.bounds, andContext: self.videoManager.getCIContext())

            
            //-------------display if the user is smiling or blinking (and with which eye)------------
            if(faces.hasSmile){
                print("Smile")
            }else{
                print("Not Smile")
            }
            
            if(faces.leftEyeClosed){
                print("leftEyeClosed")
            }else{
                print("leftEyeOpen")
            }
            
            if(faces.rightEyeClosed){
                print("rightEyeClosed")
            }else{
                print("rightEyeOpen")
            }
            
            if (faces.leftEyeClosed && faces.rightEyeClosed){
                print("BothClosed")
                self.blinkTimes = self.blinkTimes + 1
            }
        }
        //------------------------------------------------------
        return retImage
    }
    
    func getFaces(img:CIImage) -> [CIFaceFeature]{
        // this ungodly mess makes sure the image is the correct orientation
        let optsFace = [CIDetectorAccuracy:CIDetectorAccuracyHigh, CIDetectorImageOrientation:self.videoManager.ciOrientation,CIDetectorSmile:true, CIDetectorEyeBlink:true] as [String : Any]
        // get Face Features
        return self.detector.features(in: img, options: optsFace) as! [CIFaceFeature]
        
    }
    
    @IBAction func switchCamera(_ sender: UIButton) {
        self.videoManager.toggleCameraPosition()
    }
    
    //MARK: Comm with Server
    func sendFeatures(_ image:UIImage) -> (Int){
        
        let SERVER_URL = self.mytool.globalServerURL
        let targetURL = "http://\(SERVER_URL):8000"
        let baseURL = "\(targetURL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        
        let targetSize = CGSize(width: 300, height: 400)

//        let newCgIm = image.cgImage!.copy()
//        let newImage = UIImage(cgImage: newCgIm!, scale: image.scale, orientation: .right)
        let rotatedImage = image.rotate(radians: .pi/2)

        let resizedImg = self.mytool.resize(image: rotatedImage, targetSize: targetSize)

//
        
        let jpegData = UIImageJPEGRepresentation(resizedImg, 1.0)
        let encodedString = jpegData?.base64EncodedString()
//        print(image.size.width)
        let jsonUpload:NSDictionary = ["feature":encodedString!,
                                       ]
        
        let requestBody:Data? = self.mytool.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody

        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.mytool.convertDataToDictionary(with: data)
//                    print(jsonDictionary["feature"]!)
                    print(jsonDictionary["prediction"]!)
                    print(jsonDictionary["RFprediction"]!)
                    print(jsonDictionary["name"]!)
                    let labelResponse = jsonDictionary["prediction"]!
//                        let RFlabelResponse = jsonDictionary["RFprediction"]!
//                        let RF_est_number = jsonDictionary["RF_est_number"]!
                    DispatchQueue.main.async{
                        // update label when set
                        let strResult = labelResponse as? String
                        self.resultLabel.text = "SVM: \(strResult!)"
                    }
                }
        })
        
        postTask.resume() // start the task

        return 0
    }

    
}


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
