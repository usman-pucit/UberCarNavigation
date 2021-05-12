//
//  CarNavigationUseCase.swift
//  UberCarNavigation
//
//  Created by Muhammad Usman on 10/05/2021.
//  
//

import Combine
import Foundation

protocol CarNavigationUseCaseType {
    func request(_ request: Request) -> AnyPublisher<Result<MapPath, APIError>, Never>
}

class CarNavigationUseCase {
    // MARK: -  Properties

    var apiClient: APIClientType

    // MARK: - Initializer

    init(apiClient: APIClientType = APIClient()) {
        self.apiClient = apiClient
    }
}

// MARK: - Extension

extension CarNavigationUseCase: CarNavigationUseCaseType {
    func request(_ request: Request) -> AnyPublisher<Result<MapPath, APIError>, Never> {
        return apiClient
            .execute(request)
            .subscribe(on: Scheduler.backgroundWorkScheduler)
            .receive(on: Scheduler.mainScheduler)
            .eraseToAnyPublisher()
    }
}
