//
//  Motion.swift
//  InMapper
//
//  Created by Ahmed Hussein on 7/15/18.
//  Copyright © 2018 Ahmed Hussein. All rights reserved.
//

import CoreMotion
import UIKit

protocol MotionDelegate: class {
    func magneticDataUpdate(point: MagneticPoint)
    func pedoDataUpdate(data: CMPedometerData)
    func motionTrackingIntervalUpdated(interval: Double, steps: Int)
}

class Motion{
    
    var manager : CMMotionManager = CMMotionManager()
    var pedoManager : CMPedometer = CMPedometer()
    var operationQueue : OperationQueue = OperationQueue()
    var currentMGPoint : MagneticPoint?
    var isTracking : Bool = false
    var motionTrackingInterval = 0.5
    var delegate : MotionDelegate?
    var movingInterval : Double?
    var lastRecordedPace : Double?
    var lastRecordedPaceTime : Date?
    
    func startMagneticFieldTracking() {
        manager.magnetometerUpdateInterval = motionTrackingInterval
        manager.startMagnetometerUpdates(to: operationQueue) { (magnetData, error) in
            if(error == nil && magnetData != nil) {
                self.handleMagneticFieldUpdate(mgData: magnetData!.magneticField)
            }
        }
    }
    
    func startPedometerTracking(){
        //self.adjustTrackingInterval(steps: 0, pace: nil)
        lastRecordedPaceTime = Date()
        pedoManager.startUpdates(from: Date()) { (pedoData, error) in
            if(error == nil) {
                self.handlePedoUpdate(pedoData: pedoData!)
            }
        }
    }
    
    func handlePedoUpdate(pedoData: CMPedometerData) {
        self.delegate?.pedoDataUpdate(data: pedoData)
        //self.adjustTrackingInterval(steps: Int(truncating: pedoData.numberOfSteps), pace: pedoData.currentPace)
    }
    
    func handleMagneticFieldUpdate(mgData: CMMagneticField) {
        self.currentMGPoint = MagneticPoint(x: mgData.x, y: mgData.y, z: mgData.z)
        self.delegate?.magneticDataUpdate(point: self.currentMGPoint!);
    }
    
    func adjustTrackingInterval(steps: Int, pace: NSNumber?) {
        if let lastPaceDate = lastRecordedPaceTime {
            if let currentPace = pace {
                if lastRecordedPace != nil && lastRecordedPace! > 0 {
                    
                    if DateInterval(start: lastPaceDate, end: Date()).duration >= 60.0 {
                        let changeInPace = Double(truncating: currentPace) - lastRecordedPace! / lastRecordedPace!
                        let changeValue = motionTrackingInterval * changeInPace
                        
                        if(changeValue > 0){
                            if motionTrackingInterval > changeValue {
                                motionTrackingInterval -= changeValue
                            }
                        } else {
                            motionTrackingInterval += changeValue
                        }
                        
                        lastRecordedPaceTime = Date()
                    }
                }
                
                lastRecordedPace = Double(truncating: currentPace)
            }
        }
        self.manager.magnetometerUpdateInterval = self.motionTrackingInterval
        self.delegate?.motionTrackingIntervalUpdated(interval: self.motionTrackingInterval, steps: steps)
    }

    
}
