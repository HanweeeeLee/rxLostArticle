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
                self?.tableView.reloadData()
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
        
        self.typePickerView.delegate = self
        self.typePickerView.dataSource = self
        self.placePickerView.delegate = self
        self.placePickerView.dataSource = self
    }
    
    //MARK: action
    
    @objc func doneTapped(_ recognizer: UITapGestureRecognizer) {
        
    }
    
    @objc func cancelTapped(_ recognizer: UITapGestureRecognizer) {
        
    }

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
            cell.infoData = $0.lostArticleData[indexPath.row]
        }).disposed(by: self.disposeBag)
        cell.selectionStyle = .none
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
}

extension LostArticleListViewController:UIPickerViewDelegate,UIPickerViewDataSource {
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
            returnValue = LostPlaceType.getKoreanFromLostPlaceType(type: LostPlaceType.allCases[row])
        }
        else if pickerView === self.typePickerView {
            returnValue = LostArticleType.allCases[row].rawValue
            
        }
        return returnValue
    }
    
    
}
