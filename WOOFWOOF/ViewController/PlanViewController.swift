//
//  PlanViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import CHIPageControl
import AVFoundation

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
        
        detailArr.append(PlanDetail(title: "Step 1", img: #imageLiteral(resourceName: "img1"), content: """
먼저 앉아를 명령하세요.
이번에는 보상을 급하게 하지 마세요.
냄새를 맡을 수 있는 거리에서 보상을
강아지 앞에 두세요.
"""))
        detailArr.append(PlanDetail(title: "Step 2", img: #imageLiteral(resourceName: "img2"), content: "반려견의 코앞에서 천천히 보상을 밑으로 내려주세요."))
        detailArr.append(PlanDetail(title: "Step 3", img: #imageLiteral(resourceName: "img3"), content: """
반려견이 엎드리기 시작하면 클릭 하고 보상을 주세요!
(엎드릴 때까지 기다려주세요)
"""))
        detailArr.append(PlanDetail(title: "Step 4", img: #imageLiteral(resourceName: "img4"), content: "반려견의 몸이 지면에 닿은 엎드려 상태가 되면 클릭 후 더 좋은 보상을 주세요!"))
        detailArr.append(PlanDetail(title: "Step 5", img: #imageLiteral(resourceName: "img5"), content: "전 과정을 반복해주세요."))
    }
    
    @IBAction func clickerAction(_ sender: UIButton) {
        playSound()
    }
    
    
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "clicker", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            
            /* iOS 10 and earlier require the following line:
             player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
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
