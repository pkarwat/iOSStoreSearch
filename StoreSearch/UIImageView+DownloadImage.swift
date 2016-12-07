//
//  UIImageView+DownloadImage.swift
//  StoreSearch
//
//  Created by Patryk on 07.12.2016.
//  Copyright © 2016 Patryk. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1
        let downloadTask = session.downloadTask(with: url,
                                                completionHandler: { [weak self] url, response, error in
                                                    
                // I M P O R T A N T 
                //!!! [weak self] !!! page 121, point 4
                                                    
                //2 for the download task u`re given a URL where u can find the downloaded file (this
                //URL points to a local file rather than an internet address).
                if error == nil, let url = url,
                                    let data = try? Data(contentsOf: url),  //3
                                    let image = UIImage(data: data) {
                    // 4
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.image = image
                        }
                    }
                                                    }
        })
        // 5
        downloadTask.resume()
        return downloadTask
    }
}
