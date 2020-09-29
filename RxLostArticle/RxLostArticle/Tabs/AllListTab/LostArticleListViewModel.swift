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
        case  updateArticleList(place:LostPlaceType,type:LostArticleType)
        //        case updateNotice
        //        case getNoticeContents(code:String)
    }
    
    enum Mutation {
        case setLoading(Bool)
        case updateArticleList(JSON,LostPlaceType,LostArticleType)
        case setError(Error)
        //        case appendMoreData
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
        case .updateArticleList(place: let place, type: let type):
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                self.getLostArticleList(page: currentState.currentPage, type: type, place: place).map { [weak self] result in
                    switch result {
                    case let .success(json):
                        return Mutation.updateArticleList(json,place,type)
//                        return Mutation.updateArticleList(JSON.null, .bus, .backpack, 1)
                    case let .failure(err):
                        return Mutation.setError(err)
                    }
                },
                Observable.just(Mutation.setLoading(false))
            ])
        }
        //        case .updateNotice:
        //            return Observable.concat([
        //                Observable.just(Mutation.setLoading(true)),
        //                self.getNoticeQuery(page: 0).map { result in
        //                    switch result {
        //                    case let .success(json):
        //                        return Mutation.updateNoticeQuery(json)
        //                    case let .failure(err):
        //                        return Mutation.setError(CommonAlertViewType1SetData(message: LocalizedMap.NETWORK_ERROR.localized,subMessage: err.localizedDescription))
        //                    }
        //                },
        //                Observable.just(Mutation.setLoading(false))
        //            ])
        //        case .loadNextPageNotice:
        //            guard !self.currentState.isMoreQuerying else { return Observable.empty() }
        //            return Observable.concat([
        //                Observable.just(Mutation.setIsQuerying(true)),
        //                self.getNoticeQuery(page: Int(self.currentPage)).map { result in
        //                    switch result {
        //                    case let .success(json):
        //                        return Mutation.loadNextPageNoticeQuery(json)
        //                    case let .failure(err):
        //                        return Mutation.setError(CommonAlertViewType1SetData(message: LocalizedMap.NETWORK_ERROR.localized,subMessage: err.localizedDescription))
        //                    }
        //                },
        //                Observable.just(Mutation.setIsQuerying(false))
        //            ])
        
        
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState:State = state
        switch mutation {
        //        case let .setLoading(isLoading):
        //            newState.isLoading = isLoading
        //        case let .setIsQuerying(isQuerying):
        //            newState.isMoreQuerying = isQuerying
        //        case let .updateNoticeQuery(responseJson):
        //            //            print("json:\(responseJson)")
        //            if 200..<300 ~= responseJson["code"].intValue  {
        //                var newNoticeList:Array<NoticeData> = Array()
        //                for i in 0..<responseJson["data"]["list"].count {
        //                    let item:JSON = responseJson["data"]["list"][i]
        //                    if let model:NoticeData = NoticeData.fromJson(jsonData: item.rawString()?.data(using: .utf8), object: NoticeData()) {
        //                        newNoticeList.append(model)
        //                    }
        //                }
        //                newState.infoData = newNoticeList
        //                if self.getNoticePagingCnt > responseJson["data"]["list"].count { //reach end
        //                    newState.reachEnd = true
        //                }
        //                else {
        //                    newState.reachEnd = false
        //                    self.currentPage = 1
        //                }
        //            }
        //            else {
        //                newState.error = CommonAlertViewType1SetData(message: LocalizedMap.SERVER_ERROR.localized,subMessage: "[\(responseJson["code"])]\n" + LocalizedMap.SERVER_ERROR.localized)
        //            }
        //            break
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .updateArticleList(json,place,type):
//            print("json:\(json)")
            if json["SearchLostArticleService"]["RESULT"]["CODE"] == "INFO-000" {
                newState.selectedPlace = place
                newState.selectedType = type
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
        }
        return newState
    }
    
    //MARK: func
    
    func getLostArticleList(page:Int,type:LostArticleType,place:LostPlaceType) -> Observable<Result<JSON,Error>> {
        let url:String = APIDefine.getLostArticleAPIAddress(startIndex: page, endIndex: page + Int(self.queryOnceCnt), type: type, place: place, searchTxt: nil)
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
