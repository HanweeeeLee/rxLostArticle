//
//  APIDefine.swift
//  SeoulLost
//
//  Created by hanwe on 2020/06/07.
//  Copyright © 2020 hanwe. All rights reserved.
//
import UIKit

enum LostArticleType:String,CaseIterable {
    case wallet = "지갑"
    case shoppingBag = "쇼핑백"
    case briefcase = "서류봉투"
    case bag = "가방"
    case backpack = "베낭"
    case cellPhone = "핸드폰"
    case clothing = "옷"
    case book = "책"
    case file = "파일"
    case etc = "기타"
    
    typealias koreanLostArticleType = String
    
    init?(id : Int) {
        switch id {
        case 1: self = .wallet
        case 2: self = .shoppingBag
        case 3: self = .briefcase
        case 4: self = .bag
        case 5: self = .backpack
        case 6: self = .cellPhone
        case 7: self = .clothing
        case 8: self = .book
        case 9: self = .file
        case 10: self = .etc
        default: return nil
        }
    }
    
    static public func allEnumKoreanArray() -> Array<koreanLostArticleType> {
        var resultArr:Array = Array<String>()
        for value in LostArticleType.allCases {
            resultArr.append(value.rawValue)
        }
        return resultArr
    }
    
    static public func getEnumFromKoreanType(korean:koreanLostArticleType) -> LostArticleType {
        var returnEnum:LostArticleType = .etc
        switch korean {
        case self.wallet.rawValue:
            returnEnum = .wallet
            break
        case self.shoppingBag.rawValue:
            returnEnum = .shoppingBag
            break
        case self.briefcase.rawValue:
            returnEnum = .briefcase
            break
        case self.bag.rawValue:
            returnEnum = .bag
            break
        case self.backpack.rawValue:
            returnEnum = .backpack
            break
        case self.cellPhone.rawValue:
            returnEnum = .cellPhone
            break
        case self.clothing.rawValue:
            returnEnum = .clothing
            break
        case self.book.rawValue:
            returnEnum = .book
            break
        case self.file.rawValue:
            returnEnum = .file
            break
        case self.etc.rawValue:
            returnEnum = .etc
            break
        default:
            break
        }
        return returnEnum
    }
}

enum LostPlaceType:String,CaseIterable {
    case bus = "b1" //버스
    case villageBus = "b2" //마을버스
    case corporateTaxi = "t1" //법인택시
    case privateTaxi = "t2" //개인택시
    case subway1_4 = "s1" //지하철(1~4호선)
    case subway5_8 = "s2" //지하철(5~8호선)
    case subway9 = "s4" //지하철(9호선)
    case korail = "s3" //코레일
    
    typealias koreanLostPlaceType = String
    
    init?(id : Int) {
        switch id {
        case 1: self = .bus
        case 2: self = .villageBus
        case 3: self = .corporateTaxi
        case 4: self = .privateTaxi
        case 5: self = .subway1_4
        case 6: self = .subway5_8
        case 7: self = .subway9
        case 8: self = .korail
        default: return nil
        }
    }
    
    static public func allEnumKoreanArray() -> Array<koreanLostPlaceType> {
        var resultArr:Array = Array<String>()
        for value in LostPlaceType.allCases {
            switch value {
            case .bus:
                resultArr.append("버스")
                break
            case .villageBus:
                resultArr.append("마을버스")
                break
            case .corporateTaxi:
                resultArr.append("법인택시")
                break
            case .privateTaxi:
                resultArr.append("개인택시")
                break
            case .subway1_4:
                resultArr.append("지하철(1~4호선)")
                break
            case .subway5_8:
                resultArr.append("지하철(5~8호선)")
                break
            case .subway9:
                resultArr.append("지하철(9호선)")
                break
            case .korail:
                resultArr.append("코레일")
                break
            }
        }
        return resultArr
    }
    
    static public func getEnumFromKoreanType(korean:koreanLostPlaceType) -> LostPlaceType {
        var returnEnum:LostPlaceType = .bus
        switch korean {
        case "버스":
            returnEnum = .bus
            break
        case "마을버스":
            returnEnum = .villageBus
            break
        case "법인택시":
            returnEnum = .corporateTaxi
            break
        case "개인택시":
            returnEnum = .privateTaxi
            break
        case "지하철(1~4호선)":
            returnEnum = .subway1_4
            break
        case "지하철(5~8호선)":
            returnEnum = .subway5_8
            break
        case "지하철(9호선)":
            returnEnum = .subway9
            break
        case "코레일":
            returnEnum = .korail
            break
        default:
            break
        }
        return returnEnum
    }
}

class APIDefine: NSObject {
    static let SEOUL_API_SERVER_ADDR                   = "http://openAPI.seoul.go.kr:8088"
    static let SEOUL_API_KEY                           = "63595468556c686133396249724949" // 제발 이상한짓 하지 말아주세요ㅠㅠ
    
    
    static let GET_LOST_ARTICLE_ORIGIN_API                    = String(format: "%@/%@/json/SearchLostArticleService",SEOUL_API_SERVER_ADDR,SEOUL_API_KEY)
    static let GET_LOST_ARTICLE_IMAGE_ORIGIN_API              = String(format: "%@/%@/json/SearchLostArticleImageService",SEOUL_API_SERVER_ADDR,SEOUL_API_KEY)
    
    static func getLostArticleAPIAddress(startIndex:Int,endIndex:Int,type:LostArticleType,place:LostPlaceType,searchTxt:String?) -> String {
        var apiAddr:String = ""
        apiAddr = GET_LOST_ARTICLE_ORIGIN_API + "/" + String(startIndex) + "/" + String(endIndex) + "/" + type.rawValue + "/" + place.rawValue
        
        if searchTxt != nil {
            apiAddr = apiAddr + "/" + searchTxt!
        }
        let encodedString = apiAddr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return encodedString
    }
    
    static func getLostArticleImageAPIAddress(startIndex:Int,endIndex:Int,lostArticleID:String?) -> String {
        var apiAddr:String = ""
        apiAddr = GET_LOST_ARTICLE_IMAGE_ORIGIN_API + "/" + String(startIndex) + "/" + String(endIndex)
        
        if lostArticleID != nil {
            apiAddr = apiAddr + "/" + lostArticleID!
        }
        let encodedString = apiAddr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        return encodedString
    }
    
}
