//
//  NoResultView.swift
//  RxLostArticle
//
//  Created by hanwe on 2020/09/30.
//

import UIKit

class NoResultView: UIView {
    
    //MARK: IBOutlet
    @IBOutlet weak var contetnsLabel: UILabel!
    
    //MARK: property
    
    //MARK: lifeCycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    
    //MARK: function
    
    func initUI() {
        self.contetnsLabel.text = "검색결과가 없습니다."
    }
    
    class func loadFromNibNamed(nibNamed: String, bundle : Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
    
    //MARK: action

}
