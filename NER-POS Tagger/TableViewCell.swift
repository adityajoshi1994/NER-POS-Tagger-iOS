//
//  TableViewCell.swift
//  NER-POS Tagger
//
//  Created by Aditya Joshi on 11/29/18.
//  Copyright © 2018 Aditya Joshi. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var tagLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let Color = UIColor (red:0, green:0.478431, blue:1, alpha:1.0);
        wordLabel.layer.borderWidth = 0.5;
        wordLabel.layer.cornerRadius = 5;
        wordLabel.layer.borderColor = Color.cgColor;
        wordLabel.isUserInteractionEnabled = true;
        tagLabel.layer.borderWidth = 0.5;
        tagLabel.layer.cornerRadius = 5;
        tagLabel.layer.borderColor = Color.cgColor;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }

}
