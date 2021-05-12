//
//  CarNavigationViewModel.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//  
//

import Combine
import Foundation

protocol CarNavigationViewModelType {
    func requestPath(_ from: Coordinate, destination: Coordinate)
}

/// define all states of view.
enum CarNavigationViewModelState {
    case show(MapPathViewModel)
    case error(String)
}

class CarNavigationViewModel {
    
    @Published var isLoading = false
    /// define immutable `stateDidUpdate` property so that subscriber can only read from it.
    private(set) lazy var stateDidUpdate = stateDidUpdateSubject.eraseToAnyPublisher()
    
    // MARK: - Private Properties
    
    private var cancellable: [AnyCancellable] = []
    private let useCase: CarNavigationUseCaseType
    private let stateDidUpdateSubject = PassthroughSubject<CarNavigationViewModelState, Never>()

    // MARK: Initializer

    init(useCase: CarNavigationUseCaseType) {
        self.useCase = useCase
    }
}

extension CarNavigationViewModel: CarNavigationViewModelType {
   
    func requestPath(_ from: Coordinate, destination: Coordinate){
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json") else {
            return
        }
        
        var queryRequest = [String: String]()
        queryRequest["origin"] = "\(from.latitude),\(from.longitude)"
        queryRequest["destination"] = "\(destination.latitude),\(destination.longitude)"
        queryRequest["sensor"] = "false"
        queryRequest["mode"] = "driving"
        queryRequest["key"] = Environment.GOOGLE_SERVICES_API
        
        let request = Request(url: url, parameters: queryRequest)
        cancellable.forEach { $0.cancel() }
        cancellable.removeAll()
        isLoading = true
        useCase.request(request)
            .sink { [weak self] result in
                guard let `self` = self else { return }
                self.isLoading = false
                switch result {
                case .success(let value):
                    if let mapPath = self.prepareViewModel(value){
                        self.stateDidUpdateSubject.send(.show(mapPath))
                    }else{
                        self.stateDidUpdateSubject.send(.error("Preparing map path failed!!"))
                    }
                case .failure(let error):
                    self.stateDidUpdateSubject.send(.error(error.localizedDescription))
                }
            }.store(in: &cancellable)
    }
    
    private func prepareViewModel(_ mapPath: MapPath) -> MapPathViewModel?{
        guard let pathString = mapPath.routes?.first?.overview_polyline?.points,
        let distance = mapPath.routes?.first?.legs?.first?.distance?.text,
        let duration = mapPath.routes?.first?.legs?.first?.duration?.text else { return nil}
        
        return MapPathViewModel(pathString: pathString, distance: distance, duration: duration)
    }
}
