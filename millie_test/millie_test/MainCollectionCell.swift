//
//  MainCollectionCell.swift
//  millie_test
//
//  Created by Hyeonjoon Kim_M1 on 2024/04/18.
//

import UIKit

class MainCollectionCell: UICollectionViewCell {
    
    static let identifier = "MainCollectionCell"
    
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    var articleModel: ArticleModel? {
        didSet {
            updateUi()
        }
    }
     
    override class func awakeFromNib() {
        super.awakeFromNib()

    }
    
    private func updateUi() {
        
        layer.cornerRadius = 5
        layer.borderWidth = 1
        layer.borderColor = UIColor(220, 220, 220).cgColor
        
        guard let articleModel else {
            return
        }
        
        authorLabel.text = articleModel.author ?? "정보 없음"
        dateLabel.text = articleModel.date()
        titleLabel.text = articleModel.title
        
        if let url = articleModel.urlToImage {
            ImageFileManager.shared.getImage(urlString: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }
}
