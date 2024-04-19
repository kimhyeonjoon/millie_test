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
    
    var selectedIndex: [Int] = []

    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .initialize:
            return .merge(.just(.setLoading(true)), loadData())
        case .itemSelected(let index):
            guard let model = currentState.apiModel?.articles?[safe: index] else {
                return .empty()
            }
            
            if selectedIndex.contains(index) == false {
                selectedIndex.append(index)
            }
            
            return Observable.concat([
                 Observable.just(Mutation.itemSelected(model)),
                 Observable.just(Mutation.itemSelected(nil))
             ])
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
        case .itemSelected(let model):
            newState.selectedItem = model
        }
        
        return newState
    }
}


// action, mutation, state
extension MainViewReactor {
    
    enum Action {
        case initialize
        
        case itemSelected(Int)
    }
    
    enum Mutation {
        case updateData(ApiModel)
        case setLoading(Bool)
        case isError(Error)
        
        case itemSelected(ArticleModel?)
    }
    
    struct State {
        @Pulse var apiModel: ApiModel?
        var isLoading: Bool = false
        @Pulse var error: Error?
        
        var selectedItem: ArticleModel?
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
