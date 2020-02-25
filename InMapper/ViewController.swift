//
//  ViewController.swift
//  InMapper
//
//  Created by Ahmed Hussein on 7/15/18.
//  Copyright © 2018 Ahmed Hussein. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController, MotionDelegate{
    
    //the outlets
    
    @IBOutlet weak var updateIntervalLabel: UILabel!
    @IBOutlet weak var magneticXLabel: UILabel!
    @IBOutlet weak var magneticYLabel: UILabel!
    @IBOutlet weak var magneticZLabel: UILabel!
    @IBOutlet weak var stepCountLabel: UILabel!
    
    @IBOutlet weak var addNewRoomButton: UIBarButtonItem!
    
    @IBOutlet weak var underScanningRoomNameLabel: UILabel!
    
    @IBOutlet weak var recordedPointsCountLabel: UILabel!
    
    @IBOutlet weak var scanningView: UIView!
    
    @IBOutlet weak var pauseResumeButton: UIButton!
    @IBOutlet weak var gyroLabel: UILabel!
    
    var motionManager : Motion = Motion()
    var underScanningRoom : Room?
    var isScanning : Bool = false
    var CMMotion : CMMotionManager?
    var gyroTimer : Timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        motionManager.delegate = self
        motionManager.startMagneticFieldTracking()
        motionManager.startPedometerTracking()
        
        self.startGyroUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pedoDataUpdate(data: CMPedometerData) {
        
    }
    
    func startGyroUpdates() {
        self.CMMotion = CMMotionManager();
        CMMotion?.gyroUpdateInterval = 0.1
        CMMotion?.startGyroUpdates();
        
        // Configure a timer to fetch the accelerometer data.
        self.gyroTimer = Timer.scheduledTimer (withTimeInterval: 0.5, repeats: true, block: { (timer) in
            // Get the gyro data.
            if let data = self.CMMotion?.gyroData {
                let x = data.rotationRate.x
                let y = data.rotationRate.y
                let z = data.rotationRate.z
                
                DispatchQueue.main.async {
                    self.gyroLabel.text = "\(x.rounded()), \(y.rounded()), \(z.rounded())"
                }
                
                if(self.isScanning) {
                    let thePoint: gyroPoint = gyroPoint.init(x: x, y: y, z: z)
                    self.underScanningRoom?.addGyroPoint(point: thePoint)
                }
            }
        })
    }
    
    func magneticDataUpdate(point: MagneticPoint) {
        
        if self.isScanning {
            self.underScanningRoom?.addMappingPoint(point: point);
        }
        
        DispatchQueue.main.async {
            self.magneticXLabel.text = "\(point.x.rounded())"
            self.magneticYLabel.text = "\(point.y.rounded())"
            self.magneticZLabel.text = "\(point.z.rounded())"
            
            if self.isScanning {
                if let recordedPoints = self.underScanningRoom {
                    self.recordedPointsCountLabel.text = "\(recordedPoints.mapPoints.count)"
                }
            }
        }
    }
    
    func motionTrackingIntervalUpdated(interval: Double, steps: Int) {
        DispatchQueue.main.async {
            self.updateIntervalLabel.text = "\(interval)"
            self.stepCountLabel.text = "\(steps)"
        }
    }
    
    @IBAction func addNewRoom(_ sender: Any) {
        let alertBox = UIAlertController(title: "Add new room", message: "Enter room name and press create to start scanning", preferredStyle: .alert)
        
        alertBox.addTextField { (textField) in }
        
        alertBox.addAction(UIAlertAction(title: "Create", style: .default, handler: { (alertAction) in
            self.startNewScan(roomName: (alertBox.textFields?.last?.text)!)
            alertBox.dismiss(animated: true, completion: nil)
        }))
        
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            alertBox.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alertBox, animated: true)
    }
    
    func startNewScan(roomName: String) {
        addNewRoomButton.isEnabled = false
        
        isScanning = true
        
        underScanningRoom = Room(roomName: roomName)
        
        underScanningRoomNameLabel.text = roomName
        
        scanningView.isHidden = false
    }
    
    @IBAction func showScans(_ sender: Any) {
        
    }
    
    @IBAction func pauseResumeScanning(_ sender: Any) {
        if isScanning == true {
            pauseResumeButton.setTitle("Resume", for: .normal)
            isScanning = false
        } else {
            pauseResumeButton.setTitle("Pause", for: .normal)
            isScanning = true
        }
    }
    
    @IBAction func finishScanning(_ sender: Any) {
        isScanning = false
        addNewRoomButton.isEnabled = true
        scanningView.isHidden = true
        
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(underScanningRoom)
            
            let documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            
            let file2ShareURL = documentsDirectoryURL.appendingPathComponent("data_ouput.json")

            do {
                try jsonData.write(to: file2ShareURL)
                
                createShareDialog(fileURL: file2ShareURL)
            } catch {
                print(error)
            }
            
        } catch {
            
        }
        
    }
    
    func createShareDialog(fileURL : URL) {
        let shareActivity = UIActivityViewController(activityItems: ["Save JSON data file", fileURL], applicationActivities: nil);
        
        self.present(shareActivity, animated: true)
    }
    
    func calculate() {
    }
}

