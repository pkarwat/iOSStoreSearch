//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Patryk on 05.12.2016.
//  Copyright © 2016 Patryk. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    //called after cell obj has been loaded from the nib but before the cell is added to the table view
    //IN INIT THE NAMELABEL OUTLET`LL STILL BE NIL BUT IN AWAKEFROMNIB THEY`LL PROPERLY HOOKED UP TO THER UILABEL OBJS
    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
