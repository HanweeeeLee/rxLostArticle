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
    
    enum ViewType {
        case tableView
        case collectionView
    }
    
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
    @IBOutlet weak var collectionView: HWCollectionView!
    @IBOutlet weak var transformBtnView: UIView!
    
    
    //MARK: property
    var disposeBag:DisposeBag = DisposeBag()
    var viewModel:LostArticleListViewModel = LostArticleListViewModel()
    
    let typePickerView:ToolbarPickerView = ToolbarPickerView()
    let placePickerView:ToolbarPickerView = ToolbarPickerView()
    
    var allArticleTypeNameArr:Array<LostArticleType.koreanLostArticleType> = LostArticleType.allEnumKoreanArray()
    var allPlaceNameArr:Array<LostPlaceType.koreanLostPlaceType> = LostPlaceType.allEnumKoreanArray()
    
    var currentShowViewType:ViewType = .collectionView {
        didSet {
            switch self.currentShowViewType {
            case .tableView:
                //todo animation
                self.tableView.isHidden = false
                self.collectionView.isHidden = true
                break
            case .collectionView:
                //todo animation
                self.tableView.isHidden = true
                self.collectionView.isHidden = false
                break
            }
        }
    }
    
    var collectionViewMargin:CGFloat = 10
    var collectionViewCellLeftRightMargin:CGFloat = 5
    var collectionViewCellTopBottomMargin:CGFloat = 5
    
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
                        self?.collectionView.showSkeletonHW()
                        self?.tableView.showSkeletonHW()
                    })
                }
                else {
                    print("loading end")
                    self?.collectionView.hideSkeletonHW()
                    self?.tableView.hideSkeletonHW()
                }
            }).disposed(by: self.disposeBag)
        
        reactor.state.map{ $0.lostArticleData }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] data in
                self?.tableView.reloadData()
                self?.collectionView.reloadData()
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
        self.tableView.separatorStyle = .none
        
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
        
        self.transformBtnView.layer.cornerRadius = 15
        self.transformBtnView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
        
        self.tableView.isHidden = true
        self.collectionView.backgroundColor = CommonDefine.themeColor1
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "LostArticleType1CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "LostArticleType1CollectionViewCell")
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = self.collectionViewCellTopBottomMargin
        layout.minimumInteritemSpacing = self.collectionViewCellLeftRightMargin
        self.collectionView.collectionViewLayout = layout
//        self.collectionView.isHidden = true
    }
    
    //MARK: action
    @IBAction func transformBtnClick(_ sender: Any) {
        if self.currentShowViewType == .collectionView {
            self.currentShowViewType = .tableView
        }
        else {
            currentShowViewType = .collectionView
        }
    }
}

extension LostArticleListViewController: HWTableViewDatasource, HWTableViewDelegate {
    func hwTableViewSekeletonViewHeight(_ hwTableView: HWTableView) -> CGFloat {
        return 100
    }
    
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
        if (!(self.reactor?.currentState.isQuerying ?? true) && !(self.reactor?.currentState.reachEnd ?? true)) {
            self.reactor?.action.onNext(.callNextPage)
        }
    }
    
}

extension LostArticleListViewController: HWCollectionViewDelegate, HWCollectionViewDatasource, HWCollectionViewDelegateFlowLayout {
    func hwCollectionView(_ collectionView: HWCollectionView, numberOfItemsInSection section: Int) -> Int {
        var numOfRows = 0
        numOfRows = self.viewModel.currentState.lostArticleData.count
        return numOfRows
    }
    
    func hwCollectionView(_ collectionView: HWCollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell:LostArticleType1CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LostArticleType1CollectionViewCell", for: indexPath) as! LostArticleType1CollectionViewCell
        cell.infoData = self.viewModel.currentState.lostArticleData[indexPath.row]
        return cell
    }
    
    func hwCollectionView(_ collectionView: HWCollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth:CGFloat = (UIScreen.main.bounds.width - (self.collectionViewMargin * 2) - self.collectionViewCellLeftRightMargin)/2
        let cellHeight:CGFloat = cellWidth
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func hwCollectionView(_ collectionView: HWCollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: self.collectionViewMargin, left: self.collectionViewMargin, bottom: self.collectionViewMargin, right: self.collectionViewMargin)
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
