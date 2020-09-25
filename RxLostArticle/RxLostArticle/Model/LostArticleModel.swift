//
//  LostArticleModel.swift
//  RxLostArticle
//
//  Created by hanwe lee on 2020/09/25.
//

struct LostArticleModel:HWDataProtocol {
    var id:Int = -1
    var takePlace:String = ""
    var getName:String = ""
    var getDate:String = ""
    var getPosition:String = ""
    
    enum CodingKeys : String, CodingKey {
        case id = "ID"
        case takePlace = "TAKE_PLACE"
        case getName = "GET_NAME"
        case getDate = "GET_DATE"
        case getPosition = "GET_POSITION"
    }
}
