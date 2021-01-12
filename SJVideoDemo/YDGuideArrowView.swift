//
//  YDGuideArrowView.swift
//  SJVideoDemo
//
//  Created by Shafujiu on 2020/12/29.
//

import UIKit

class YDGuideArrowView: UIView {
    private lazy var louLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        
        self.layer.addSublayer(louLayer)
//        isOpaque = false
//        backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        // 半透明区域
//        UIColor.black.withAlphaComponent(0.7).setFill()
//        UIRectFill(rect)
        let btnRect = CGRect(x: 100, y: 100, width: 100, height: 40)
        fillLayer(rect: rect, btnRect: btnRect)
        
        borderShape(rect: rect, btnRect: btnRect)
        
        drawpath(beginP: CGPoint(x: 100, y: 200), endP: CGPoint(x: 275, y: 200), ctrlP: CGPoint(x: 195, y: 160))
        drawRightTriangle(point: CGPoint(x: 275, y: 200))
        drawLeftTriangle(point: CGPoint(x: 100, y: 200))
    }
    // 按钮边框
    private func borderShape(rect: CGRect, btnRect: CGRect) {
        let tRect = btnRect
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        let path = UIBezierPath(roundedRect: tRect, cornerRadius: 6)
        shapeLayer.path = path.cgPath
        shapeLayer.frame = rect
        shapeLayer.lineCap = .square
        self.layer.addSublayer(shapeLayer)
        // 白 透
        shapeLayer.lineDashPattern = [0.5, 2]
    }
    
    // 镂空
    private func fillLayer(rect: CGRect, btnRect: CGRect) {
        
        let tRect = btnRect
        let path = UIBezierPath(rect: rect)
        let louPath = UIBezierPath(roundedRect: tRect, cornerRadius: 6)
        
        let louPath2 = UIBezierPath(roundedRect: CGRect(x: 200, y: 200, width: 100, height: 40), cornerRadius: 6)
        
        path.append(louPath)
        path.append(louPath2)
        
        path.usesEvenOddFillRule = true
//        let fillLayer = CAShapeLayer()
        let fillLayer = louLayer
        fillLayer.path = path.cgPath
        fillLayer.fillRule = .evenOdd
        fillLayer.fillColor = UIColor.black.cgColor
        fillLayer.opacity = 0.7
//        self.layer.addSublayer(fillLayer)
    }
    
    // 弧线
    private func drawpath(beginP: CGPoint, endP: CGPoint, ctrlP: CGPoint) {
        let path = UIBezierPath()
        path.move(to: beginP)
        path.addQuadCurve(to: endP, controlPoint: ctrlP)
        UIColor.clear.set()
        path.stroke()
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.lineCap = .square
        shapeLayer.lineDashPattern = [1,4]
        self.layer.addSublayer(shapeLayer)
    }
    // 箭头
    private func drawRightTriangle(point: CGPoint) {
        let shape = CAShapeLayer()

        let p1 = point
        let p2 = CGPoint(x: point.x - 10, y: point.y)
        let p3 = CGPoint(x: point.x-7, y: point.y-7)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        UIColor.white.set()
        path.close()
        path.stroke()
        shape.path = path.cgPath
        shape.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(shape)
    }
    
    private func drawLeftTriangle(point: CGPoint) {
        let shape = CAShapeLayer()
        
        
        let p1 = point
        let p2 = CGPoint(x: point.x+10, y: point.y)
        let p3 = CGPoint(x: point.x+7, y: point.y-7)
        
        let path = UIBezierPath()
        path.move(to: p1)
        path.addLine(to: p2)
        path.addLine(to: p3)
        UIColor.white.set()
        
        path.close()
        path.stroke()
        shape.path = path.cgPath
        shape.fillColor = UIColor.white.cgColor
        self.layer.addSublayer(shape)
    }
    
    
}
