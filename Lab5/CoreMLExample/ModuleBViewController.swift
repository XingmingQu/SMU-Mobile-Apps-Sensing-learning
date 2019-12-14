//
//  ViewController.swift
//  CoreMLExample
//
//  Created by Eric Larson on 9/5/17.
//  Copyright © 2017 Eric Larson. All rights reserved.
//
import UIKit
import CoreML
import Vision
import CoreImage
import Accelerate

//let SERVER_URL = "http://10.8.107.62:8000" // change this for your server name!!!

class ModuleBViewController: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate,URLSessionDelegate {
    
    //MARK: UI View Elements
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var RFstatusLabel: UILabel!
    @IBOutlet weak var dsidLabel: UILabel!

    @IBOutlet weak var URLtextField: UITextField!
    @IBOutlet weak var mainImageView: UIImageView!

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
      textField.resignFirstResponder()
      return true
    }
    var SERVER_URL = "10.8.107.72" {
        didSet{
            DispatchQueue.main.async{
                // update label when set
                
                self.URLtextField.text = (self.SERVER_URL)
            }
        }
    }
    let mytool = tools()
    let operationQueue = OperationQueue()
    var session = URLSession()
    let animation = CATransition()
    var dsid:Int = 0 {
        didSet{
            DispatchQueue.main.async{
                // update label when set
                self.dsidLabel.layer.add(self.animation, forKey: nil)
                self.dsidLabel.text = "Current DSID: \(self.dsid)"
            }
        }
    }
    @IBAction func uploadImage(_ sender: UIButton) {
        let _ = sendFeatures(mainImageView.image!)
//        sleep(1)
//        if result == 0{
//            statusLabel.text = "Upload Success!"
//            statusLabel.isHidden = false
//            mainImageView.image =  UIImage(named: "ok")
//
//        }
    }
    
    //MARK: Comm with Server
    func sendFeatures(_ image:UIImage) -> (Int){
        let targetURL = "http://\(self.URLtextField.text!):8000"
        let baseURL = "\(targetURL)/PredictOne"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jpegData = UIImageJPEGRepresentation(image, 1.0)
        let encodedString = jpegData?.base64EncodedString()
//        print(image.size.width)
        let jsonUpload:NSDictionary = ["feature":encodedString!,
                                       "dsid":self.dsid]
        
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
                    let labelResponse = jsonDictionary["prediction"]!
                    let RFlabelResponse = jsonDictionary["RFprediction"]!
                    let RF_est_number = jsonDictionary["RF_est_number"]!
                    DispatchQueue.main.async{
                        // update label when set
                        let strResult = labelResponse as? String
                        self.statusLabel.text = "SVM: \(strResult!)"
                        let RFstrResult = RFlabelResponse as? String
                        self.RFstatusLabel.text = "RF (E=\(RF_est_number)):\(RFstrResult!)"
                    }
                }
        })
        
        postTask.resume() // start the task

        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        URLtextField.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
        dsid = 1
        URLtextField.delegate = self
        URLtextField.text = SERVER_URL
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 25.0
        sessionConfig.timeoutIntervalForResource = 28.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
    }
    
    //MARK: ML Model Load

    
    //MARK: Camera View Presentation
    @IBAction func takePicture(_ sender: UIButton) {
        DispatchQueue.main.async{
            // update label when set
            self.statusLabel.text = "It takes ~2s to predict"
        }
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = (self as UIImagePickerControllerDelegate & UINavigationControllerDelegate)
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        cameraPicker.cameraDevice = .front
        present(cameraPicker, animated: true)
    }
}

extension ModuleBViewController: UIImagePickerControllerDelegate {
    
    //MARK: Camera View Callbacks
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true)
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        }

        let targetSize = CGSize(width: 300, height: 400)
        let resizedImg = self.mytool.resize(image: image, targetSize: targetSize)
        mainImageView.image = resizedImg
//        print(resizedImg.size.width)
    }
}

