//
//  CheckListViewController.swift
//  ImageLab
//
//  Created by Xingming Qu on 11/20/19.
//  Copyright © 2019 Eric Larson. All rights reserved.

import UIKit


class CheckListViewController: UIViewController,UINavigationControllerDelegate,UITextFieldDelegate,URLSessionDelegate  {
    
    //MARK: Class Properties
    
    let mytool = tools()
    let operationQueue = OperationQueue()
    var session = URLSession()
    @IBOutlet weak var resertButton: UIButton!
    @IBOutlet weak var checkListTestView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sessionConfig = URLSessionConfiguration.ephemeral
        
        sessionConfig.timeoutIntervalForRequest = 25.0
        sessionConfig.timeoutIntervalForResource = 28.0
        sessionConfig.httpMaximumConnectionsPerHost = 1
        
        self.session = URLSession(configuration: sessionConfig,
            delegate: self,
            delegateQueue:self.operationQueue)
        
        let _ = self.getCheckList(reset: false)
//        print(resultDict)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let _ = self.getCheckList(reset: false)

        }
        
    override func viewDidDisappear(_ animated: Bool) {

    }
    
    @IBAction func resetList(_ sender: UIButton) {
        let _ = self.getCheckList(reset: true)
    }
    
    //MARK: Comm with Server
    func getCheckList(reset: Bool) -> (Int){
        
        let SERVER_URL = self.mytool.globalServerURL
        let targetURL = "http://\(SERVER_URL):8000"
        var baseURL = ""
        if (reset == true ){
             baseURL = "\(targetURL)/ResetCheckList"
        }else{
             baseURL = "\(targetURL)/CheckList"
        }
        
        let postUrl = URL(string: "\(baseURL)")
        
        // create a custom HTTP POST request
        var request = URLRequest(url: postUrl!)
        
        let jsonUpload:NSDictionary = ["status":"OK",
                                       ]
        
        let requestBody:Data? = self.mytool.convertDictionaryToData(with:jsonUpload)
        
        request.httpMethod = "POST"
        request.httpBody = requestBody

//        var returnDict:NSDictionary?
        let postTask : URLSessionDataTask = self.session.dataTask(with: request,
            completionHandler:{(data, response, error) in
                if(error != nil){
                    if let res = response{
                        print("Response:\n",res)
                    }
                }
                else{
                    let jsonDictionary = self.mytool.convertDataToDictionary(with: data)
                    print(jsonDictionary["resultString"]!)
                    
                    DispatchQueue.main.async{
                        // update label when set
                        self.checkListTestView.text = jsonDictionary["resultString"]! as? String
                    }

//                    let labelResponse = jsonDictionary["prediction"]!
//                    print(jsonDictionary)
//                    returnDict = jsonDictionary
                    
                    

                }
        })
        
        postTask.resume() // start the task

        return 0
    }

    
}
