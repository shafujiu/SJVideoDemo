//
//  TestViewController.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/28.
//

import UIKit

class TestViewController: UIViewController {

    private lazy var guideV: YDGuideArrowView = {
        let view = YDGuideArrowView()
        return view
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
        
        view.addSubview(guideV)
        guideV.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        
        
        
        
        
        
        
//        let boardLayer = CAShapeLayer()
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 100, y: 100))
//        path.addLine(to: CGPoint(x: 100, y: 200))
//
//        path.addQuadCurve(to: CGPoint(x: 275, y: 200), controlPoint: CGPoint(x: 195, y: 170))
//        UIColor.red.set()
//        path.stroke()
//        path.close()
//        boardLayer.strokeColor = UIColor.red.cgColor
//        boardLayer.path = path.cgPath
//
//        boardLayer.frame = self.view.bounds
//        self.view.layer.addSublayer(boardLayer)
        
    }

    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        
    }
}
