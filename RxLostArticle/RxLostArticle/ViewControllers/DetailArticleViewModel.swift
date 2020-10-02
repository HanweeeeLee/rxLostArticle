//
//  DetailArticleViewModel.swift
//  RxLostArticle
//
//  Created by hanwe on 2020/09/30.
//

import UIKit
import ReactorKit
import SwiftyJSON

class DetailArticleViewModel: Reactor {

    //MARK: IBOutlet
    //MARK: property
    var disposeBag:DisposeBag = DisposeBag()
    var initialState: State = State()
    
    //MARK: lifeCycle
    
    enum Action {
        case setInfoData(data:LostArticleModel)
        case getImgUrl(id:String)
    }
    
    enum Mutation {
        case setInfoData(LostArticleModel)
        case setError(Error?)
        case setImgUrl(JSON)
    }
    
    struct State {
        var infoData:LostArticleModel = LostArticleModel()
        var imgUrl:String = ""
        var error:Error? = nil
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setInfoData(data: let data):
            return Observable.concat([
                Observable.just(Mutation.setInfoData(data))
            ])
            
        case .getImgUrl(id: let id):
            return Observable.concat([
                self.getLostArticlePhotoURL(id: id).map { [weak self] result in
                    switch result {
                    case let .success(json):
                        return Mutation.setImgUrl(json)
                    case let .failure(err):
                        return Mutation.setError(err)
                    }
                }
//                },
//                Observable.just(Mutation.setError(nil)),
//                Observable.just(Mutation.setServerErrorNil)
            ])
        }
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState:State = state
        switch mutation {
        case let .setInfoData(data):
            newState.infoData = data
        case .setError(let err):
            newState.error = err
        case .setImgUrl(let json):
            print("imgUrl response:\(json)")
            print("test:\(json["SearchLostArticleImageService"]["row"][0]["ID"].stringValue)")
            newState.imgUrl = json["SearchLostArticleImageService"]["row"][0]["IMAGE_URL"].stringValue
        }
        return newState
    }
    //MARK: function
    
    func getLostArticlePhotoURL(id:String) -> Observable<Result<JSON,Error>> {
        let url:String = APIDefine.getLostArticleImageAPIAddress(startIndex: 0, endIndex: 1, lostArticleID: id)
        print("url:\(url)")
        return DataApiManager.requestGETURLRx(url, headers: nil)
            .observeOn(MainScheduler.instance)
            .retry(3)
            .map{
                return .success($0)
            }
            .catchError{
                .just(.failure($0))
            }
    }
}
