//
//  ActiveViewController.swift
//  WOOFWOOF
//
//  Created by 이광용 on 2018. 2. 2..
//  Copyright © 2018년 이광용. All rights reserved.
//

import UIKit
import KDCircularProgress
import Charts

struct Active {
    let weekDay: String
    let day: Int
    let value: Int
}
class ActiveViewController: UIViewController {
    @IBOutlet var profileImage: RoundedImageView!
    @IBOutlet var remainLabel: UILabel!
    @IBOutlet var progressBar: KDCircularProgress!
    @IBOutlet var barChart: BarChartView!
    @IBOutlet var weekCollectionView: UICollectionView!
    
    var datas: [Active] = []
    let months = ["1월", "2월", "3월", "4월", "5월", "6월", "7월", "8월", "9월", "10월", "11월", "12월"]
    let unitsSold = [20.0, 4.0, 6.0, 3.0, 12.0, 16.0, 4.0, 18.0, 2.0, 4.0, 5.0, 4.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.profileImage.image = Profile.getProfile()
        
        setChart(months, values: unitsSold)
        self.weekCollectionView.setUp(target: self, cell: CalendarCollectionViewCell.self)
        setCal()

//        self.weekCollectionView.isPrefetchingEnabled = false
    }
    
    func setChart(_ dataPoints: [String], values: [Double]){
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 1...31 {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(0 + Int(arc4random_uniform(UInt32(101)))))
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "활동량")
        
        chartDataSet.colors = [UIColor(displayP3Red: 56/255, green: 190/255, blue: 239/255, alpha: 1) ]
        let chartData = BarChartData(dataSet: chartDataSet)
        barChart.data = chartData
        barChart.drawGridBackgroundEnabled = false
    }
    
    func setCal() {
        for i in 1...31 {
            var str = "일"
            switch i % 7 {
            case 0:
                str = "일"
            case 1:
                str = "월"
            case 2:
                str = "화"
            case 3:
                str = "수"
            case 4:
                str = "목"
            case 5:
                str = "금"
            case 6:
                str = "토"
            default:
                break
            }
            datas.append(Active(weekDay: str,day: i, value: 0 + Int(arc4random_uniform(UInt32(61)))))
        }
        datas.append(Active(weekDay: "목", day: 1, value: 0 + Int(arc4random_uniform(UInt32(61)))))
        datas.append(Active(weekDay: "금", day: 2, value: 0))
        self.weekCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        self.profileImage.setRounded()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.progressBar.animate(fromAngle: 0, toAngle: 0, duration: 2) { (active) in
            if !active {print("Error")}
        }
        self.barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
//        self.weekCollectionView.scrollToItem(at: IndexPath(row: 32, section: 0)
//            , at: .right, animated: true)
        self.weekCollectionView.selectItem(at: IndexPath(row: 32, section: 0), animated: true, scrollPosition: .right )
        
    }
}

extension ActiveViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CalendarCollectionViewCell = collectionView.dequeueReusableCell(forIndexPath: indexPath)
        cell.weekdayLabel.text = datas[indexPath.row].weekDay
        cell.dayLabel.text = String(describing: datas[indexPath.row].day)
        cell.progressBar.animate(fromAngle: -90, toAngle: Double(datas[indexPath.row].value * 6), duration: 1, completion: nil)
        //cell.reload()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width / 7.1, height: collectionView.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        progressBar.animate(toAngle:  Double(datas[indexPath.row].value * 6), duration: 2, completion: nil)
        //(fromAngle: -90, toAngle: Double(datas[indexPath.row].value * 6), duration: 2, completion: nil)
        remainLabel.text = "\(datas[indexPath.row].value)/60분"

    }
}

