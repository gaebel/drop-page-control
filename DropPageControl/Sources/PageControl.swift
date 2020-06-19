//
//  PageControl.swift
//  DropPageControl
//
//  Created by Jan Gaebel on 19.06.20.
//  Copyright © 2020 Jan Gaebel. All rights reserved.
//

import UIKit

class PageControl: UIPageControl {

    // MARK: - PageControl

    var scale: CGFloat = 2
    var size: CGFloat = 10

    var dropColor: CGColor = UIColor.orange.cgColor
    var circleColor: CGColor = UIColor.black.withAlphaComponent(0.2).cgColor
    var lineWidth: CGFloat = 1

    var isDrawing = false
    var isSetup = false

    var percent: CGFloat = 1 {
        didSet {
            setNeedsDisplay()
        }
    }

    var scrollView: UIScrollView? {
        didSet {
            scrollView?.delegate = self
        }
    }

    private(set) var mode: Mode = .morph

    private var previousLayer: CAShapeLayer?
    private var currentLayer: CAShapeLayer?

    enum Mode {
        case slide
        case morph
        case scale
    }

    // Drawing

    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)

        isDrawing = true

        previousLayer?.removeFromSuperlayer()
        previousLayer = nil

        currentLayer?.removeFromSuperlayer()
        currentLayer = nil

        let previousLayer = makeDropletShape(with: percent < 0 ? .scale : .morph)
        subviews[currentPage - 1].layer.addSublayer(previousLayer)
        self.previousLayer = previousLayer

        let currentLayer = makeDropletShape(with: .slide)
        subviews[currentPage].layer.addSublayer(currentLayer)
        self.currentLayer = currentLayer

        isDrawing = false
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        if isSetup == false {
            drawStaticCircles()
            isSetup = true
        }
    }

    func drawStaticCircles() {
        self.transform = CGAffineTransform.init(scaleX: scale, y:  scale)

        self.subviews.forEach {
            $0.layer.addSublayer(makeCircleShape())
        }
    }

    // MARK: - Factories

    func makeCircleShape() -> CAShapeLayer {
        let shape = CAShapeLayer()
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        let path = UIBezierPath(ovalIn: rect).cgPath
        shape.path = path
        shape.strokeColor = circleColor
        shape.fillColor = .none
        shape.lineWidth = lineWidth
        return shape
    }

    func makeDropletShape(with mode: Mode) -> CAShapeLayer {
        let halfSize = CGSize(width: self.size / 2, height: self.size / 2)

        var path: UIBezierPath

        switch mode {
        case .slide:
            path = makeDroplet(with: halfSize, mode: .slide)
        case .morph:
            path = makeDroplet(with: halfSize, mode: .morph)
        case .scale:
            path = makeCircle(with: percent, size: halfSize)
        }

        let shape = CAShapeLayer()
        shape.path = path.cgPath
        shape.fillColor = dropColor
        shape.strokeColor = dropColor
        shape.lineWidth = lineWidth
        shape.isOpaque = mode == .slide ? false : true
        shape.opacity = Float(mode == .slide ? 1 - percent : 1)

        let offset = shape.bounds.origin.y + ((self.size) * percent) + (self.size)
        shape.bounds.origin.y = mode == .slide ? (offset) : shape.bounds.origin.y

        return shape
    }

    private func makeDroplet(with size: CGSize, mode: Mode) -> UIBezierPath {
        let percent = mode == .slide ? 1 : self.percent

        var path: UIBezierPath

        let startAngle = self.radians(of: 145)
        let endAngle = self.radians(of: 35)

        let center = self.center(of: size)
        let radius = self.radius(of: size)

        path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle,
                            endAngle: endAngle, clockwise: true)

        let startPoint = path.currentPoint
        let endPoint = self.circlePoint(at: 145, size: size)

        let leftOffsetX = ((5 - 2) * percent) + 2
        let rightOffsetX =  (5 - leftOffsetX) + 5
        let offsetY = ((size.height - 0) * percent) + 0

        let leftControlPoint = CGPoint(x: leftOffsetX, y: -offsetY)
        let rightControlPoint = CGPoint(x: rightOffsetX, y: -offsetY)

        let maxPoint = CGPoint(x: size.width, y: -offsetY)

        path.addCurve(to: maxPoint,
                            controlPoint1: startPoint,
                            controlPoint2: leftControlPoint)

        path.addCurve(to: endPoint,
                            controlPoint1: rightControlPoint,
                            controlPoint2: endPoint)

        return path
    }

    private func makeCircle(with percent: CGFloat, size: CGSize) -> UIBezierPath {
        let sizeInPercent = (self.size * percent) + self.size
        let rect = CGRect(x: (size.width - (sizeInPercent / 2)),
                          y: (size.width - (sizeInPercent / 2)),
                          width: sizeInPercent, height: sizeInPercent)
        return UIBezierPath(ovalIn: rect)
    }

    // MARK: - Helpers

    private func circlePoint(at degree: CGFloat, size: CGSize) -> CGPoint {
        let radius = self.radius(of: size)
        let x =  size.width + cos(radians(of: degree)) * radius
        let y = size.width + sin(radians(of: degree)) * radius

        return CGPoint(x: x, y: y)
    }

    private func center(of size: CGSize) -> CGPoint {
        CGPoint(x: size.width, y: size.height)
    }

    private func radius(of size: CGSize) -> CGFloat {
        -(size.width)
    }

    private func radians(of degrees: CGFloat) -> CGFloat {
        degrees / 180 * .pi
    }
}

extension PageControl: UIScrollViewDelegate {

    // MARK: - UIScrollViewDelegate

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !isDrawing {
            guard scrollView.contentOffset.x >= 0  else { return }
            guard (scrollView.contentOffset.x + scrollView.frame.width) < scrollView.contentSize.width  else { return }

            let newPage = Int(scrollView.contentOffset.x / scrollView.frame.width) + 1

            if currentPage != newPage { currentPage = newPage }

            let scrollViewOffset = scrollView.contentOffset.x - (CGFloat(currentPage - 1) * scrollView.frame.width)
            let scrollViewHalf = scrollView.frame.width / 2

            self.percent = 1 - scrollViewOffset / scrollViewHalf
        }
    }
}
