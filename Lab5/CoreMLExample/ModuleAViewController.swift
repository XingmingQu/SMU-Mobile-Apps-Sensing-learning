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

class ModuleAViewController: UIViewController, UINavigationControllerDelegate,UITextFieldDelegate,URLSessionDelegate {
    
    //MARK: UI View Elements
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dsidLabel: UILabel!
    @IBOutlet weak var parameterTextField: UITextField!
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var URLtextField: UITextField!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var classifierLabel: UILabel!
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
        let _ = sendFeatures(mainImageView.image!, withLabel: NameTextField.text!)
        sleep(1)
//        if result == 0{
//            statusLabel.text = "Upload Success!"
//            statusLabel.isHidden = false
//            mainImageView.image =  UIImage(named: "ok")
//
//        }
    }
    
    @IBAction func TrainYourModel(_ sender: UIButton) {
        
        // create a GET request for server to update the ML model with current data
        let targetURL = "http://\(self.URLtextField.text!):8000"
        let baseURL = "\(targetURL)/UpdateModel"
        let query = "?dsid=\(self.dsid)"
        
        let getUrl = URL(string: baseURL+query)
        let request: URLRequest = URLRequest(url: getUrl!)
        let dataTask : URLSessionDataTask = self.session.dataTask(with: request,
              completionHandler:{(data, response, error) in
                // handle error!
                if (error != nil) {
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.mytool.convertDataToDictionary(with: data)
                    
                    if let resubAcc = jsonDictionary["log"]{
                        print("log is", resubAcc)
                    }
                }
                                                                    
        })
        
        dataTask.resume() // start the task
    }
    //MARK: Comm with Server
    func sendFeatures(_ image:UIImage, withLabel label:String) -> (Int){
        let targetURL = "http://\(self.URLtextField.text!):8000"
        let baseURL = "\(targetURL)/AddDataPoint"
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        // data to send in body of post request (send arguments as json)
        let jpegData = UIImageJPEGRepresentation(image, 1.0)
        let encodedString = jpegData?.base64EncodedString()
//        print(image.size.width)
        let jsonUpload:NSDictionary = ["feature":encodedString!,
                                       "label":"\(label)",
            "Parameter":"\(self.parameterTextField.text!)",
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
                    print(jsonDictionary["label"]!)
                    let labelResponse = jsonDictionary["status"]!
                    print(jsonDictionary["status"]!)
                    DispatchQueue.main.async{
                        // update label when set
                        self.statusLabel.text = labelResponse as? String
                    }
                }
        })
        
        postTask.resume() // start the task

        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NameTextField.delegate = self
        URLtextField.delegate = self
        parameterTextField.delegate = self
        parameterTextField.text = "100"
        // Do any additional setup after loading the view, typically from a nib.
        dsid = 1
        URLtextField.text = SERVER_URL
        let sessionConfig = URLSessionConfiguration.ephemeral
//        statusLabel.isHidden = true
        sessionConfig.timeoutIntervalForRequest = 5.0
        sessionConfig.timeoutIntervalForResource = 8.0
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
            self.statusLabel.text = "Take a selfie!"
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

extension ModuleAViewController: UIImagePickerControllerDelegate {
    
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

