//
//  DetailArticleViewController.swift
//  RxLostArticle
//
//  Created by hanwe on 2020/09/30.
//

import UIKit
import ReactorKit
import RxCocoa

class DetailArticleViewController: CommonPushedViewController,StoryboardView {
    
    //MARK: IBOutlet
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var takePlaceLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var getDateLabel: UILabel!
    @IBOutlet weak var getPositionLabel: UILabel!
    
    //MARK: property
    
    var disposeBag:DisposeBag = DisposeBag()
    var viewModel:DetailArticleViewModel = DetailArticleViewModel()
    
    //MARK: lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        self.reactor = self.viewModel
        initUI()
    }
    
    func bind(reactor: DetailArticleViewModel) {
        reactor.state.map {
            $0.infoData
        }.distinctUntilChanged()
        .subscribe(onNext : { [weak self] data in
            print("data:\(data)")
            self?.takePlaceLabel.text = data.takePlace
            self?.nameLabel.text = data.getName
            self?.getDateLabel.text = data.getDate
            self?.getPositionLabel.text = data.getPosition
            self?.reactor?.action.onNext(.getImgUrl(id: String(format: "%d", data.id)))
        })
    }
    
    //MARK: function
    
    func initUI() {
        
    }
    
    func setInfoData(_ data:LostArticleModel) {
        print("set data")
        self.reactor?.action.onNext(.setInfoData(data: data))
    }
    
    
    //MARK: action



}
