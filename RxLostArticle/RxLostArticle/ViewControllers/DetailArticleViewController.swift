//
//  DetailArticleViewController.swift
//  RxLostArticle
//
//  Created by hanwe on 2020/09/30.
//

import UIKit
import ReactorKit
import RxCocoa
import SDWebImage

class DetailArticleViewController: CommonPushedViewController,StoryboardView {
    
    //MARK: IBOutlet
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var mainContainerView: UIView!
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
        self.reactor = self.viewModel
        initUI()
        
    }
    
    func bind(reactor: DetailArticleViewModel) {
        reactor.state.map {
            $0.infoData
        }.distinctUntilChanged()
        .subscribe(onNext : { [weak self] data in
            self?.takePlaceLabel.text = data.takePlace
            self?.nameLabel.text = data.getName
            self?.getDateLabel.text = data.getDate
            self?.getPositionLabel.text = data.getPosition
            self?.reactor?.action.onNext(.getImgUrl(id: String(format: "%d", data.id)))
        })
        
        reactor.state.map {
            $0.imgUrl
        }.distinctUntilChanged()
        .subscribe(onNext: { [weak self] urlStr in
            print("url:\(urlStr)")
//            https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png //testImgUrl
            if let url = URL.init(string: urlStr) {
                self?.imgView.sd_setImage(with: url, placeholderImage: UIImage.init(named: "ImagePlaceHolder"), options: .lowPriority, completed: nil)
            }
        }).disposed(by: self.disposeBag)
    }
    
    //MARK: function
    
    func initUI() {
        self.backgroundView.backgroundColor = CommonDefine.themeColor1
    }
    
    func setInfoData(_ data:LostArticleModel) {
        self.reactor?.action.onNext(.setInfoData(data: data))
    }
    
    
    //MARK: action



}
