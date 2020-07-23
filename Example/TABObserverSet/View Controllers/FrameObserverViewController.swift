//
//  FrameObserverViewController.swift
//  TABObserverSet
//
//  Created by Luqman Fauzi on 20/08/2017.
//  Copyright © 2017 Kin + Carta. All rights reserved.
//

import UIKit
import TABObserverSet

final class FrameObserverViewController: UIViewController {
  
  private typealias SquareTransform = CGAffineTransform
  
  @IBOutlet private weak var scaleLabel: UILabel!
  @IBOutlet private weak var rotatingRadiusLabel: UILabel!
  
  private let scaleObserver = ObserverSet<SquareTransform>()
  private lazy var squareView: UIView = {
    let squareView = UIView()
    squareView.frame.size = CGSize(width: 200.0, height: 200.0)
    squareView.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 100.0)
    squareView.backgroundColor = .red
    return squareView
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    scaleObserver.add(self, FrameObserverViewController.transformSizeChanges)
    view.addSubview(squareView)
  }
  
  @IBAction private func rotatingRadiusSliderDidChange(_ sender: UISlider) {
    rotatingRadiusLabel.text = "Rotate: " + String(format: "%.0f ", sender.value) + "%"
    
    let angle = CGFloat(sender.value)
    let rotatingTransform = CGAffineTransform(rotationAngle: angle)
    
    /// Broadcast the rotating transform
    scaleObserver.notify(rotatingTransform)
  }
  
  @IBAction private func scaleSliderDidChange(_ sender: UISlider) {
    scaleLabel.text = "Scale: " + String(format: "%.2f", sender.value)
    
    let scale = CGFloat(sender.value)
    let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
    
    /// Broadcast the scale transform
    scaleObserver.notify(scaleTransform)
  }
  
  private func transformSizeChanges(_ transform: SquareTransform) {
    UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: [], animations: {
      /// Apply transform to squareView
      self.squareView.transform = transform
    }, completion: nil)
  }
}
