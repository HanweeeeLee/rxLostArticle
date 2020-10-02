//
//  LostArticleListViewModel.swift
//  RxLostArticle
//
//  Created by hanwe lee on 2020/09/25.
//

import UIKit
import ReactorKit
import SwiftyJSON

class LostArticleListViewModel: Reactor {

    //MARK: property
    
    let queryOnceCnt:UInt = 20 //한번에 쿼리하는 양
    
    var initialState: State = State()
    var disposeBag:DisposeBag = DisposeBag()
    
    
    
    //MARK: lifeCycle
    
    enum Action {
        case updateArticleList
        case changeLostArticleType(type:LostArticleType)
        case changeLostPlace(place:LostPlaceType)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case updateArticleList(JSON)
        case changeLostArticleType(LostArticleType)
        case changeLostPlace(LostPlaceType)
        case setError(Error?)
        case setServerErrorNil
    }
    
    struct State {
        var selectedPlace:LostPlaceType = .bus
        var selectedType:LostArticleType = .wallet
        var isLoading:Bool = false
        var currentPage:Int = 0
        var lostArticleData:Array<LostArticleModel> = Array()
        var error:Error?
        var serverErr:String?
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateArticleList:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.getLostArticleList(page: currentState.currentPage, type: self.currentState.selectedType, place: self.currentState.selectedPlace).map { [weak self] result in
                    switch result {
                    case let .success(json):
                        return Mutation.updateArticleList(json)
                    case let .failure(err):
                        return Mutation.setError(err)
                    }
                },
                Observable.just(Mutation.setError(nil)),
                Observable.just(Mutation.setServerErrorNil),
                Observable.just(Mutation.setLoading(false))
            ])
        case .changeLostPlace(place: let place):
            return Observable.concat([
                Observable.just(Mutation.changeLostPlace(place))
            ])
        case .changeLostArticleType(type: let type):
            return Observable.concat([
                Observable.just(Mutation.changeLostArticleType(type))
            ])
        }
        
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState:State = state
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .updateArticleList(json):
//            print("json:\(json)")
            if json["SearchLostArticleService"]["RESULT"]["CODE"] == "INFO-000" {
                newState.currentPage += Int(self.queryOnceCnt)
                let items:JSON = json["SearchLostArticleService"]["row"]
                var newArticleList:Array<LostArticleModel> = Array()
                for i in 0..<items.count {
                    if let obj:LostArticleModel = LostArticleModel.fromJson(jsonData: items[i].rawString()?.data(using: .utf8), object: LostArticleModel()) {
                        newArticleList.append(obj)
                    }
                }
                newState.lostArticleData = newArticleList
            }
            else if json["RESULT"]["CODE"].stringValue == "INFO-200" { //데이터 없음
                print("해당하는 데이터가 없습니다.")
                print("error msg:\(json["RESULT"]["MESSAGE"].stringValue)")
                newState.lostArticleData.removeAll()
                newState.serverErr = json["RESULT"]["CODE"].stringValue
            }
            else {
                // error 처리
            }
            
        case let .setError(err):
            newState.error = err
        case let .changeLostArticleType(type):
            newState.selectedType = type
        case let .changeLostPlace(place):
            newState.selectedPlace = place
        case .setServerErrorNil:
            newState.serverErr = nil
        }
        return newState
    }
    
    //MARK: func
    
    func getLostArticleList(page:Int,type:LostArticleType,place:LostPlaceType) -> Observable<Result<JSON,Error>> {
        let url:String = APIDefine.getLostArticleAPIAddress(startIndex: page, endIndex: page + Int(self.queryOnceCnt), type: type, place: place, searchTxt: nil)
        print("type:\(type) place:\(place)")
        return DataApiManager.requestGETURLRx(url, headers: nil)
            .observeOn(MainScheduler.instance)
            .retry(3)
            .map{
                usleep(1 * 1000 * 1000)
                return .success($0)
            }
            .catchError{
                .just(.failure($0))
            }
    }
}
