//
//  ViewController.swift
//  StoreSearch
//
//  Created by Patryk on 03.12.2016.
//  Copyright © 2016 Patryk. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        //print("Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    //optional cause there`ll be only be an active LandscapeViewController instance if the phone is in landscape orientation. In portrait it`ll be nil
    var landscapeViewController: LandscapeViewController?
    
    //optional cause u won`t have a data task yet until the user performs a search
    //var dataTask: URLSessionDataTask?
    
    //var searchResults: [SearchResult] = []    //var searchResults = [String]()
    //var hasSearched = false
    //var isLoading = false
    
    let search = Search()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 64: 20=status bar + 44=Search Bar
        tableView.contentInset = UIEdgeInsets(top: 108, left: 0, bottom: 0, right: 0)
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
        
        tableView.rowHeight = 80    //fix for too small row height
        
        searchBar.becomeFirstResponder()    //show keyboard at the beginning
    }

    //remove white space from actionBar
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)  //deselect row
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! IndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
        }
    }
    
    //deselect row
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath
        }
    }
    
    // W E B
 
    func showNetworkError() {
        let alert = UIAlertController(title: "Whoops...",
                                      message: "There was an error reading from the iTunes Store. Please try again.",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    //invoked when the device is flipped over
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular, .unspecified:
            hideLandscape(with: coordinator)
        }
    }
    
    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeViewController == nil else { return }
        landscapeViewController = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeViewController {
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            view.addSubview(controller.view)    //add the landscape as a subview. This places it on top of the table view, search bar and segmented control
            addChildViewController(controller)  //if you forget this step then the new view controller may not always work correctly
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 1
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }, completion: { _ in
                controller.didMove(toParentViewController: self)
            })
            
            //controller.didMove(toParentViewController: self)
        }
    }
    
    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeViewController {
            controller.willMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { _ in
                controller.view.alpha = 0
            }, completion: { _ in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
        }
    }
    
}

// * * * * * E X T E N S I O N * * * E X T E N S I O N * * * E X T E N S I O N * * * * *

//invoked when the user taps the Search btn ok the keyboard
extension SearchViewController: UISearchBarDelegate {
    func performSearch() {
        
        //search.performSearch(for: searchBar.text!, category: segmentedControl.selectedSegmentIndex)
        
        search.performSearch(for: searchBar.text!,
                             category: segmentedControl.selectedSegmentIndex,
                             completion: { success in
                                if !success {
                                    self.showNetworkError()
                                }
                                self.tableView.reloadData()
        })
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
        
        /*if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel() //cancel previous request
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = []
            
            let url = self.iTunesURL(searchText: searchBar.text!,
                                     category: segmentedControl.selectedSegmentIndex) //1
            let session = URLSession.shared //2
            //shared - std config with respect to caching, cookies etc.
            //3 parameter data, response & error ARE OPTIONALS
            dataTask = session.dataTask(with: url, completionHandler: {
                data, response, error in
                
                print("On the main thread? " + (Thread.current.isMainThread ? "Yes" : "No") )
                
                if let error = error as? NSError, error.code == -999 {
                    print("Failure! \(error)")
                    return
                } else if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode == 200 {
                    //print("Success! \(data!)")
                    if let data = data, let jsonDictionary = self.parse(json: data) {
                        self.searchResults = self.parse(dictionary: jsonDictionary)
                        self.searchResults.sort(by: <)
                    
                        DispatchQueue.main.async {
                            print("On the main thread? " + (Thread.current.isMainThread ? "Yes" : "No") )
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                } else {
                    print("Failure! \(response)")
                }
                
                DispatchQueue.main.async {
                    print("Failure! \(response)")
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }
            })
            dataTask?.resume()
        }*/
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
            return 1
        } else {
            return search.searchResults.count
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        } else if search.searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell, for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
            
            let searchResult = search.searchResults[indexPath.row]
            cell.configure(for: searchResult)
            
            return cell
        }
        
        /*if searchResults.count == 0 {
            cell.textLabel!.text = "(Nothing found)"
            no longer need to write ! to unwrap cause the outlets are implicitly unwrapped optionals, not true optionals
            cell.nameLabel.text = "(Nothing found)"
        }*/
    }
}
