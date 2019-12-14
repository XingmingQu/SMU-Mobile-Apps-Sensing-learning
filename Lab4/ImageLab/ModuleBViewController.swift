//
//  ModuleBViewController.swift
//  ImageLab
//
//  Created by Xingming on 10/24/19.
//  Copyright © 2019 Eric Larson. All rights reserved.
//

import UIKit
import Charts



class ModuleBViewController: UIViewController {
    var videoManager:VideoAnalgesic! = nil
    let bridge = OpenCVBridge()
    @IBOutlet weak var heartRateCharts: LineChartView!
    @IBOutlet weak var heartRateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = nil
        self.videoManager = VideoAnalgesic.sharedInstance
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.bridge.setTransforms(self.videoManager.transform)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        
        if !videoManager.isRunning{
            videoManager.start()
        }
        //self.videoManager.turnOnFlashwithLevel(1.0)
        // Do any additional setup after loading the view.
        self.heartRateCharts.backgroundColor = UIColor.white
    }
    
    // need to fix turnOnFlashwithLevel bug. It was called once at the first time switched to modual B

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.videoManager.setCameraPosition(position: AVCaptureDevice.Position.back)
        self.bridge.setTransforms(self.videoManager.transform)
        self.videoManager.setProcessingBlock(newProcessBlock: self.processImage)
        if !videoManager.isRunning{
            videoManager.start()
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
            self.videoManager.turnOnFlashwithLevel(1.0)
            //self.videoManager.toggleFlash()
        }
        
    }
    //charts
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.videoManager.turnOffFlash()
//        videoManager.stop()
    }

    func processImage(inputImage:CIImage) -> CIImage{
//        self.videoManager.turnOnFlashwithLevel(1.0)
        var retImage = inputImage
        
        // use this code if you are using OpenCV and want to overwrite the displayed image via OpenCv
        // this is a BLOCKING CALL
        self.bridge.setImage(retImage, withBounds: retImage.extent, andContext: self.videoManager.getCIContext())
        self.bridge.processHeartRate()
        retImage = self.bridge.getImage()
        //if the array is full, we start to calculate heart rate and update the chart
        if (self.bridge.isFull){
            
            let heartRate = self.bridge.calculatedHeartRate(from: self.bridge.returnHeartData(), withlenth: self.bridge.bufferSizeVar, withWindowSize: 10)
            // the reason why we choose withWindowSize: 10 is that we assume ones heart is under 3 times / second.
            // so we just count the peak within 1/3 second

            let pointer: UnsafeMutablePointer<Float> = self.bridge.returnHeartData()
            
            let heartRateData = Array(UnsafeBufferPointer(start: pointer, count: Int(self.bridge.bufferSizeVar)))
            
            var dataEntries: [ChartDataEntry] = []
            
            for i in 0..<self.bridge.bufferSizeVar {
                let dataEntry = ChartDataEntry(x: Double(i), y: Double(heartRateData[Int(i)]))
                dataEntries.append(dataEntry)
            }
            
            let chartDataSet = LineChartDataSet(entries: dataEntries, label: "PPG signal")
            chartDataSet.drawCirclesEnabled = false
            chartDataSet.setColor(UIColor.red)
            let chartData = LineChartData(dataSet: chartDataSet)

            DispatchQueue.main.async {
                self.heartRateCharts.data = chartData
                self.heartRateLabel.text=String(heartRate)
            }
            self.bridge.needReset = true
        }
        return retImage
    }

}
