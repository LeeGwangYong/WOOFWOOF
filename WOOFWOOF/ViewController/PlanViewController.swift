//
//  PlanViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import CHIPageControl

struct PlanDetail {
    let title: String
    let img: UIImage
    let content: String
}

class PlanViewController: UIViewController {
    @IBOutlet var pageController: CHIPageControlAji!
    @IBOutlet var pagingCollectionView: UICollectionView!
    var detailArr: [PlanDetail] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.pagingCollectionView.isPagingEnabled = true
        self.pagingCollectionView.setUp(target: self, cell: PlanCollectionViewCell.self)
        
        detailArr.append(PlanDetail(title: "Step 1", img: #imageLiteral(resourceName: "img1"), content: "테스트1"))
        detailArr.append(PlanDetail(title: "Step 2", img: #imageLiteral(resourceName: "img2"), content: "테스트2"))
        detailArr.append(PlanDetail(title: "Step 3", img: #imageLiteral(resourceName: "img3"), content: "테스트3"))
        detailArr.append(PlanDetail(title: "Step 4", img: #imageLiteral(resourceName: "img4"), content: "테스트4"))
        detailArr.append(PlanDetail(title: "Step 5", img: #imageLiteral(resourceName: "img5"), content: "테스트5"))
    }
}

extension PlanViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return detailArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PlanCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.planImage.image = detailArr[indexPath.row].img
        cell.textLabel.text = detailArr[indexPath.row].content
        cell.titleLabel.text = detailArr[indexPath.row].title
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = scrollView.contentSize.width - scrollView.bounds.width
        let offset = scrollView.contentOffset.x
        let percent = Double(offset / total)
        
        let progress = percent * Double(self.detailArr.count - 1)
        
        self.pageController.progress = progress
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
