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
import SkeletonView

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
    @IBOutlet weak var tableView: HWTableView!
    
    
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
    }
    
    func bind(reactor: LostArticleListViewModel) {
        
        self.reactor?.action.onNext(.updateArticleList)
        
        reactor.state.map { $0.isLoading }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isLoading in
                if isLoading {
                    print("loading start")
                    self?.tableView.hideNoResultView(completion: {[weak self] in
                        self?.tableView.showSkeletonHW()
                    })
                }
                else {
                    print("loading end")
                    self?.tableView.hideSkeletonHW()
                }
            }).disposed(by: self.disposeBag)
        
        reactor.state.map{ $0.lostArticleData }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] data in
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
//            self?.reactor?.action.onNext(.updateArticleList)
        }).disposed(by: self.disposeBag)
        
        reactor.state.map{
            $0.error
        }
        .compactMap{ $0 }
        .subscribe(onNext: { [weak self] value in
            print("error value:\(value)")
        }).disposed(by: self.disposeBag)
        
        reactor.state.map {
            $0.serverErr
        }
        .compactMap{ $0 }
        .subscribe(onNext: { [weak self] value in
            print("server error value:\(value)")
            self?.tableView.showNoResultView(completion: nil)
        }).disposed(by: self.disposeBag)
        
    }
    
    //MARK: func
    
    func initUI() {
        self.backgroundView.backgroundColor = CommonDefine.mainBackgroundColor
        self.mainContainerView.backgroundColor = .clear
        self.inputContainerView.backgroundColor = .clear
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: "LostArticleType1TableViewCell", bundle: nil), forCellReuseIdentifier: "LostArticleType1TableViewCell")
        self.tableView.tableView.separatorStyle = .none // 이거 왜 안되지.. 봐야함
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.addNoResultView((NoResultView.loadFromNibNamed(nibNamed: "NoResultView") as! NoResultView))
        self.tableView.hideNoResultView(completion: nil)
        
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

extension LostArticleListViewController: HWTableViewDatasource, HWTableViewDelegate {
    func hwTableView(_ hwTableView: HWTableView, numberOfRowsInSection section: Int) -> Int {
        var numOfRows = 0
        numOfRows = self.viewModel.currentState.lostArticleData.count
        print("self.viewModel.currentState.lostArticleData.count:\(self.viewModel.currentState.lostArticleData.count)")
        return numOfRows
    }
    
    func hwTableView(_ hwTableView: HWTableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LostArticleType1TableViewCell", for: indexPath) as! LostArticleType1TableViewCell
        cell.infoData = self.viewModel.currentState.lostArticleData[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func hwTableViewSekeletonViewCellIdentifier(_ hwTableView: HWTableView) -> String {
        return "LostArticleType1TableViewCell"
    }
    
    func hwTableViewSekeletonViewCount(_ hwTableView: HWTableView) -> Int {
        return 4
    }
    
    func hwTableView(_ hwtableView: HWTableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func hwTableView(_ hwTableVIew: HWTableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = mainStoryboard.instantiateViewController(withIdentifier: "DetailArticleViewController") as? DetailArticleViewController {
//            print("send to :\(self.viewModel.currentState.lostArticleData[indexPath.row])")
//            vc.setInfoData(self.viewModel.currentState.lostArticleData[indexPath.row])
            let detailArticleViewModel:DetailArticleViewModel = DetailArticleViewModel()
            detailArticleViewModel.action.onNext(.setInfoData(data: self.viewModel.currentState.lostArticleData[indexPath.row]))
            vc.viewModel = detailArticleViewModel
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func callNextPage(_ scrollView: UIScrollView) {
        if !(self.reactor?.currentState.isQuerying ?? true) {
            self.reactor?.action.onNext(.callNextPage)
        }
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
            self.reactor?.action.onNext(.changeLostPlace(place: LostPlaceType.getEnumFromKoreanType(korean: place)))
            self.reactor?.action.onNext(.updateArticleList)
        }
        else if fromPickerView === self.typePickerView {
            let type = self.allArticleTypeNameArr[fromPickerView.selectedRow(inComponent: 0)]
            self.reactor?.action.onNext(.changeLostArticleType(type: LostArticleType.getEnumFromKoreanType(korean: type)))
            self.reactor?.action.onNext(.updateArticleList)
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
