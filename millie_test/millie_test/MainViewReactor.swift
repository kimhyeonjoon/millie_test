//
//  MainViewReactor.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit

import ReactorKit
import RxSwift

class MainViewReactor: Reactor {
    
    let initialState: State = State()

    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .initialize:
            return .merge(.just(.setLoading(true)), loadData())
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .updateData(let apiModel):
            newState.isLoading = false
            newState.apiModel = apiModel
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .isError(let error):
            newState.error = error
            newState.isLoading = false
        }
        
        return newState
    }
}


// action, mutation, state
extension MainViewReactor {
    
    enum Action {
        case initialize
    }
    
    enum Mutation {
        case updateData(ApiModel)
        case setLoading(Bool)
        case isError(Error)
    }
    
    struct State {
        @Pulse var apiModel: ApiModel?
        var isLoading: Bool = false
        @Pulse var error: Error?
    }
}


extension MainViewReactor {
    
    private func loadData() -> Observable<Mutation> {
        
        return NetworkManager.shared.request()
            .asObservable()
            .map({ model -> Mutation in
                return .updateData(model)
            })
            .catch { error -> Observable<Mutation> in
                return .just(.isError(error))
            }
    }
}
