//
//  BreedListViewController.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit

class BreedListViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var breedArray = [Breed]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initializeUI()
    }
    
    func initializeUI() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 50
        tableView.tableFooterView = UIView()
        
        self.title = "Search"
        searchBar.placeholder = "Search for Breed Name"
    }
}


extension BreedListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let text = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty {
            self.showLoadingIndicator()
            AppManager.fetchBreeds(searchText: text) {[weak self](data, status, error) in
                self?.hideLoadingIndicator()
                switch status {
                case .success:
                    if let responseData = data {
                        AppManager.decodeData(raw: responseData, withType: [Breed].self) { [weak self] (items, error) in
                            self?.breedArray.removeAll()
                            if let _items = items {
                                self?.breedArray.append(contentsOf: _items)
                            }
                            self?.tableView.reloadData()
                        }
                    }
                default:
                    print("Failed")
                }
            }
            searchBar.resignFirstResponder()
        }
    }
}

extension BreedListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return breedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: BreedListTableCell.className, for: indexPath) as? BreedListTableCell else {
            return UITableViewCell()
        }
        cell.setData(breedArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let controller = self.storyboard?.instantiateViewController(identifier: BreedImagesViewController.className) as? BreedImagesViewController else { return }
        controller.breed = breedArray[indexPath.row]
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
