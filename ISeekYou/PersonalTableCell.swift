//
//  PersonTableCell.swift
//  ISeekYou
//
//  Created by lunner on 7/27/15.
//  Copyright (c) 2015 lunner. All rights reserved.
//

import UIKit

class PersonalTableCell: UITableViewCell {
	@IBOutlet weak var profileImageview: UIImageView!
	@IBOutlet weak var nicknameLable: UILabel!
	@IBOutlet weak var indentiferLabel: UILabel!
	@IBOutlet weak var twoDimensionCodeImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
