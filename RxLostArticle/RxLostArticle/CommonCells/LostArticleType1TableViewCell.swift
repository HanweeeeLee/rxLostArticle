//
//  LostArticleType1TableViewCell.swift
//  RxLostArticle
//
//  Created by hanwe lee on 2020/09/25.
//

import UIKit

class LostArticleType1TableViewCell: UITableViewCell {

    //MARK: outlet
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: property
    
    var infoData:LostArticleModel? = nil {
        didSet {
            guard let info = self.infoData else { return }
            self.nameLabel.text = info.getName
            self.placeLabel.text = "습득장소 : " + info.getPosition
            self.dateLabel.text = "습득날짜 : " + info.getDate
        }
    }
    
    //MARK: lifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    //MARK: func
    
    func initUI() {
        self.mainContainerView.backgroundColor = .clear
        self.nameLabel.textColor = .black
        self.placeLabel.textColor = .black
        self.dateLabel.textColor = .black
    }
    
    //MARK: action
    
    
    
    
}
