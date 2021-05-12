//
//  CarNavigationViewController.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//
//

import Combine
import CoreLocation
import GoogleMaps
import UIKit

class CarNavigationViewController: UIViewController {
    // MARK: - IBOutlet

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    // MARK: Properties

    private var viewModel: CarNavigationViewModel!
    private var cancellable: [AnyCancellable] = []
    private var myLocationMarker: GMSMarker!
    private var carAnimator: CarAnimator!
    private var bgTimer = Timer()
    private var isFirstTime = true
    private var destination = Coordinate(latitude: 38.9637, longitude: 35.2433)
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = CarNavigationViewModel(useCase: CarNavigationUseCase())
        bindViewModel()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        LocationManager.shared.startUpdatingLocation()
        backgroundService()
    }
    
    // MARK: - Private Function's
    
    private func configureUI() {
        mapView.setCustomStyle()
        setupMarker()
    }
    
    private func bindViewModel() {
        viewModel.stateDidUpdate.sink(receiveValue: { [weak self] state in
            guard let `self` = self else { return }
            switch state{
            case .show(let mapPath):
                self.labelDistance.text = mapPath.distance
                self.labelTime.text = mapPath.duration
                self.drawPath(mapPath.pathString)
            case .error(_):
                break
            }
        }).store(in: &cancellable)
        
        LocationManager.shared.locationUpdate.sink { [weak self] location in
            guard let `self` = self else { return }
            self.animateCar(location)
        }.store(in: &cancellable)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopBackgroundService()
        LocationManager.shared.stopUpdatingLocation()
    }
    
    
    private func backgroundService() {
        bgTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateMapViewRequest), userInfo: nil, repeats: true)
        bgTimer.fire()
    }
    
    private func stopBackgroundService() {
        bgTimer.invalidate()
    }
    
    @objc private func updateMapViewRequest() {
        guard let myLocation = LocationManager.shared.lastLocation?.coordinate else { return }
        let from = Coordinate(latitude: myLocation.latitude, longitude: myLocation.longitude)
        viewModel.requestPath(from, destination: destination)
    }
    
    
    @IBAction func recenterMap(_ sender: Any){
        guard let myLocation = LocationManager.shared.lastLocation else { return }
        mapView.updateMap(toLocation: myLocation, zoomLevel: 16)
    }
    
    /**
        Setting marker on MapView
     */
    
    
    private func setupMarker() {
        guard let myLocation = LocationManager.shared.lastLocation else { return }
        
        myLocationMarker = GMSMarker(position: myLocation.coordinate)
        myLocationMarker.icon = UIImage(named: "car")
        myLocationMarker.map = mapView
        carAnimator = CarAnimator(carMarker: myLocationMarker, mapView: mapView)

        let dropOffMarker = GMSMarker()
        dropOffMarker.icon = UIImage(named: "marker")
        dropOffMarker.position = CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)
        dropOffMarker.map = mapView
        
        guard let markerLayer = carAnimator?.carMarker.layer else { return }
        carAnimator.resumeLayer(layer: markerLayer)
    }
    
    /**
         Private Function
         Animate Car on GoogleMap
     */
    
    private func animateCar(_ location: CLLocation) {
        if myLocationMarker == nil {
            setupMarker()
            mapView.updateMap(toLocation: location, zoomLevel: 16)
        } else if let oldLocation = LocationManager.shared.previousLocation?.coordinate {
            mapView.updateMap(toLocation: location, zoomLevel: 16)
            carAnimator.animate(from: oldLocation, to: location.coordinate)
        }
    }
    
    /**
        Drawing Polygon
     */
    
    private func drawPath(_ encodedPathString: String) {
        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.0)
            guard let path = GMSPath(fromEncodedPath: encodedPathString) else { return }
            let line = GMSPolyline(path: path)
            
            self.mapView.clear()
            self.setupMarker()
            line.strokeWidth = 4.0
            line.strokeColor = .black
            line.isTappable = true
            line.map = self.mapView
            
            if self.isFirstTime {
                self.isFirstTime = false
                var bounds = GMSCoordinateBounds()
                for index in 1 ... path.count() {
                    bounds = bounds.includingCoordinate(path.coordinate(at: index))
                }
                self.mapView.moveCamera(GMSCameraUpdate.fit(bounds))
            }
            
            CATransaction.commit()
        }
    }
    
}
