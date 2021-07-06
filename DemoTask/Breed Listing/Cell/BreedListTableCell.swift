//
//  BreedListTableCell.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit

class BreedListTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ breed: Breed) {
        titleLabel.text = breed.name
        detailLabel.text = breed.bredFor
    }

}
