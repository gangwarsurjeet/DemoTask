//
//  BreedImagesViewController.swift
//  DemoTask
//
//  Created by Surjeet on 06/07/21.
//

import UIKit

class BreedImagesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    open var breed: Breed?
    
    private var imagesArray = [BreedImage]()
    private var pageNum = 0
    private var limit = 20
    private var isNextPageAvailable: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initializeUI()
        
        fetchImages(pageNum: pageNum, limit: limit)
    }
    
    private func initializeUI() {
        
        self.title = breed?.name
        
        let layout = FlickrLayout()
        // All layouts support this configs
        layout.contentPadding = ItemsPadding(horizontal: 15, vertical: 15)
        layout.cellsPadding = ItemsPadding(horizontal: 10, vertical: 10)

        collectionView.collectionViewLayout = layout
        collectionView.setContentOffset(CGPoint.zero, animated: false)
        collectionView.reloadData()
        
    }
    
    private func fetchImages(pageNum: Int, limit: Int) {
        
        if pageNum == 0 {
            imagesArray.removeAll()
        }
        let breedId = "\(breed?.id ?? 0)"
        self.showLoadingIndicator()
        AppManager.fetchImages(breedId: breedId, pageNum: pageNum, limit: limit) {[weak self] (data, status, error) in
            self?.hideLoadingIndicator()
            switch status {
            case .success:
                if let responseData = data {
                    AppManager.decodeData(raw: responseData, withType: [BreedImage].self) { [weak self] (items, error) in
                        if let _items = items {
                            self?.imagesArray.append(contentsOf: _items)
                            self?.isNextPageAvailable = _items.count == limit
                        }
                        self?.collectionView.reloadData()
                    }
                }
            default:
                print("Failed")
            }
        }
    }
}

extension BreedImagesViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.className, for: indexPath) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.setData(imagesArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == imagesArray.count - 1 {  //numberofitem count
            fetchNextPageImages()
        }
    }

    func fetchNextPageImages(){
        if isNextPageAvailable { // Need to check for next page
            pageNum += 1
            fetchImages(pageNum: pageNum, limit: limit)
        }
    }
}
