//
//  LostArticleListViewController.swift
//  RxLostArticle
//
//  Created by hanwe lee on 2020/09/25.
//

import UIKit
import ReactorKit
import RxCocoa
import Then

class LostArticleListViewController: UIViewController,StoryboardView {
    //MARK: outlet
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var articleTypeTitleLabel: UILabel!
    @IBOutlet weak var articleTypeTextFieldContainerView: UIView!
    @IBOutlet weak var articleTypeTextField: UITextField!
    @IBOutlet weak var articlePlaceTitleLabel: UILabel!
    @IBOutlet weak var articlePlaceTextFieldContainerView: UIView!
    @IBOutlet weak var articlePlaceTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: property
    var disposeBag:DisposeBag = DisposeBag()
    var viewModel:LostArticleListViewModel = LostArticleListViewModel()
    
    let typePickerView:ToolbarPickerView = ToolbarPickerView()
    let placePickerView:ToolbarPickerView = ToolbarPickerView()
    
    var allArticleTypeNameArr:Array<LostArticleType.koreanLostArticleType> = LostArticleType.allEnumKoreanArray()
    var allPlaceNameArr:Array<LostPlaceType.koreanLostPlaceType> = LostPlaceType.allEnumKoreanArray()
    
    //MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor = self.viewModel
        initUI()
        
        print("test:\(APIDefine.getLostArticleAPIAddress(startIndex: 0, endIndex: 10, type: .bag, place: .bus, searchTxt: nil))")
    }
    
    func bind(reactor: LostArticleListViewModel) {
        reactor.action.onNext(.updateArticleList(place: reactor.currentState.selectedPlace, type: reactor.currentState.selectedType))
        
        reactor.state.map{ $0.lostArticleData }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] data in
                print("articleData:\(data)")
                self?.tableView.reloadData()
            }).disposed(by: self.disposeBag)
        
        reactor.state.map{ $0.selectedPlace
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] value in
            self?.articlePlaceTextField.text = LostPlaceType.getKoreanFromLostPlaceType(type: self!.viewModel.currentState.selectedPlace)
        }).disposed(by: self.disposeBag)
        
        reactor.state.map{ $0.selectedType
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] value in
            self?.articleTypeTextField.text = self?.viewModel.currentState.selectedType.rawValue
        }).disposed(by: self.disposeBag)
        
        reactor.state.map{
            $0.error
        }
        .compactMap{ $0 }
        .subscribe(onNext: { [weak self] value in
            print("value:\(value)")
        }).disposed(by: self.disposeBag)
        
    }
    
    //MARK: func
    
    func initUI() {
        self.backgroundView.backgroundColor = CommonDefine.mainBackgroundColor
        self.mainContainerView.backgroundColor = .clear
        self.inputContainerView.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: "LostArticleType1TableViewCell", bundle: nil), forCellReuseIdentifier: "LostArticleType1TableViewCell")
        self.tableView.separatorStyle = .none
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.articleTypeTitleLabel.textColor = .black
        self.articleTypeTitleLabel.text = "타입"
        self.articleTypeTextFieldContainerView.backgroundColor = CommonDefine.themeColor2
        self.articleTypeTextFieldContainerView.layer.cornerRadius = 10
        self.articleTypeTextField.textColor = .darkGray
        self.articleTypeTextField.inputView = self.typePickerView
        self.articleTypeTextField.text = self.viewModel.currentState.selectedType.rawValue
        self.articleTypeTextField.tintColor = .clear
        self.articleTypeTextField.inputAccessoryView = self.typePickerView.toolbar
        
        self.articlePlaceTitleLabel.textColor = .black
        self.articlePlaceTitleLabel.text = "장소"
        self.articlePlaceTextFieldContainerView.backgroundColor = CommonDefine.themeColor2
        self.articlePlaceTextFieldContainerView.layer.cornerRadius = 10
        self.articlePlaceTextField.textColor = .darkGray
        self.articlePlaceTextField.inputView = self.placePickerView
        self.articlePlaceTextField.text = LostPlaceType.getKoreanFromLostPlaceType(type: self.viewModel.currentState.selectedPlace)
        self.articlePlaceTextField.tintColor = .clear
        self.articlePlaceTextField.inputAccessoryView = self.placePickerView.toolbar
        
        self.typePickerView.delegate = self
        self.typePickerView.dataSource = self
        self.typePickerView.toolbarDelegate = self
        
        self.placePickerView.delegate = self
        self.placePickerView.dataSource = self
        self.placePickerView.toolbarDelegate = self
    }
    
    //MARK: action
}

extension LostArticleListViewController: UITableViewDelegate, UITableViewDataSource {
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 0
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView:/*class name*/ = tableView.dequeueReusableHeaderFooterView(withIdentifier: /*class id name*/) as! /*class name*/
//
//        switch section {
//        case 0:
//            break
//        default:
//            break
//        }
//        return headerView
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 36
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        
        self.viewModel.state.subscribe(onNext : { [weak self] in
            print("test1:\($0.lostArticleData.count)")
            numOfRows = $0.lostArticleData.count
        }).disposed(by: self.disposeBag)
        
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LostArticleType1TableViewCell", for: indexPath) as! LostArticleType1TableViewCell
        self.viewModel.state.subscribe(onNext: {
            if $0.lostArticleData.count-1 >= indexPath.row {
                cell.infoData = $0.lostArticleData[indexPath.row]
            }
        }).disposed(by: self.disposeBag)
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

extension LostArticleListViewController:UIPickerViewDelegate,UIPickerViewDataSource,ToolbarPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var returnCnt:Int = 0
        if pickerView === self.placePickerView {
            returnCnt = LostPlaceType.allCases.count
        }
        else if pickerView === self.typePickerView {
            returnCnt = LostArticleType.allCases.count
        }
        return returnCnt
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var returnValue:String = ""
        if pickerView === self.placePickerView {
            returnValue = self.allPlaceNameArr[row]
        }
        else if pickerView === self.typePickerView {
            returnValue = self.allArticleTypeNameArr[row]
        }
        return returnValue
    }
    
    func didTapDone(fromPickerView: ToolbarPickerView) {
        if fromPickerView === self.placePickerView {
            let place = self.allPlaceNameArr[fromPickerView.selectedRow(inComponent: 0)]
            self.reactor?.action.onNext(.updateArticleList(place:LostPlaceType.getEnumFromKoreanType(korean: place), type: self.viewModel.currentState.selectedType))
        }
        else if fromPickerView === self.typePickerView {
            let type = self.allArticleTypeNameArr[fromPickerView.selectedRow(inComponent: 0)]
            
            self.reactor?.action.onNext(.updateArticleList(place:self.viewModel.currentState.selectedPlace, type: LostArticleType.getEnumFromKoreanType(korean: type)))
        }
        else {
            
        }
        self.view.endEditing(true)
    }
    
    func didTapCancel(fromPickerView: ToolbarPickerView) {
        if fromPickerView == self.placePickerView {
            
        }
        else if fromPickerView == self.typePickerView {
            
        }
        else {
            
        }
        self.view.endEditing(true)
    }
    
}
