//
//  CarAnimator.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//

import Foundation
import GoogleMaps

struct CarAnimator {
    let carMarker: GMSMarker
    let mapView: GMSMapView
    
    func animate(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        // Keep Rotation Short
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        CATransaction.setCompletionBlock({
            // you can do something here
        })
        carMarker.rotation = source.bearing(to: destination)
        carMarker.groundAnchor = CGPoint(x: CGFloat(0.5), y: CGFloat(0.5))
        CATransaction.commit()
        
        // Movement
        CATransaction.begin()
        CATransaction.setAnimationDuration(1)
        carMarker.position = destination
        
        // Center Map View
        let camera = GMSCameraUpdate.setTarget(destination)
        mapView.animate(with: camera)
        
        CATransaction.commit()
    }
    
    func pauseLayer(layer: CALayer) {
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
        layer.speed = 0.0
        layer.timeOffset = pausedTime
    }
    
    func resumeLayer(layer: CALayer) {
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}


