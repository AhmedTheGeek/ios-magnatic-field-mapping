//
//  Room.swift
//  InMapper
//
//  Created by Ahmed Hussein on 7/15/18.
//  Copyright © 2018 Ahmed Hussein. All rights reserved.
//

import Foundation

class Room : Encodable{
    var name : String
    var mapPoints : [MagneticPoint] = []
    var gyroPoints : [gyroPoint] = [];
    init(roomName: String) {
        name = roomName
    }
    
    func addMappingPoint(point: MagneticPoint) {
        mapPoints.append(point)
    }
    
    func addGyroPoint(point: gyroPoint) {
        gyroPoints.append(point);
    }
    
    func calcualtePointMean(point: MagneticPoint) -> Double {
        return ( Double(point.x) + Double(point.y) + Double(point.z) ) / 3.0;
    }
    
    func train(){
        
    }
}
