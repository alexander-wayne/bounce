//
//  GameViewController.swift
//  Bounce
//
//  Created by Alex Wayne on 4/4/20.
//  Copyright © 2020 Wayne Apps. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import GoogleMobileAds

class GameViewController: UIViewController, UIScrollViewDelegate, GADInterstitialDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageViewControl: UIPageControl!
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var htpLabel: UILabel!
    @IBOutlet weak var ttdLabel: UILabel!
    
    var interstitial: GADInterstitial!
    
    let gameScene = GameScene(fileNamed: "GameScene")
    
    public func share(image: UIImage){
      //  let image = getScreenshot()
        let gameURL = "https://apps.apple.com/us/app/bounce-dodge/id1506481285?ls=1"
        let items = [image, URL(string: gameURL)] as [Any]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(ac, animated: true)
    }
    
    public func getHelp() -> UIView {
        return menu
    }
        
    
    func createSlides() -> [Help] {

        let slide1:Help = Bundle.main.loadNibNamed("help", owner: self, options: nil)?.first as! Help
        slide1.label.text = "Tilt your phone to move the ball"
        slide1.imageView.loadGif(asset: "tilt")
        
        let slide2:Help = Bundle.main.loadNibNamed("help", owner: self, options: nil)?.first as! Help
        slide2.label.text = "Don't let the ball get past the paddle"
        slide2.imageView.loadGif(asset: "paddleGif")
        
        let slide3:Help = Bundle.main.loadNibNamed("help", owner: self, options: nil)?.first as! Help
        slide3.label.text = "Don't let the ball leave the screen entirely"
        slide3.imageView.image = nil
        
        let slide4:Help = Bundle.main.loadNibNamed("help", owner: self, options: nil)?.first as! Help
        slide4.label.text = "Avoid the red squares!"
        slide4.imageView.loadGif(asset: "squareGif")
        
        
        return [slide1, slide2, slide3, slide4]
    }
    
    func setupSlideScrollView(slides : [Help]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: 290, height: menu.frame.height * 0.6)
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        scrollView.isPagingEnabled = true
        
        print(scrollView.frame.width)
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: scrollView.frame.width * CGFloat(i), y: 0, width: 290, height: scrollView.frame.height)
            scrollView.addSubview(slides[i])
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / (scrollView.frame.width) )
            pageViewControl.currentPage = Int(pageIndex)
            
            let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
            let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
            
            // vertical
            let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
            let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
            
            let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
            let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
            
            
            /*
             * below code changes the background color of view on paging the scrollview
             */
    //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
            
        
            /*
             * below code scales the imageview on paging the scrollview
             */
            let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
            
            
        }
    
    var slides:[Help] = [];
    
    func createAndLoadInterstitial() -> GADInterstitial {
//        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        
        var interstitial = GADInterstitial(adUnitID:  "ca-app-pub-3058646248757517/6570991365")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
      print("interstitialDidReceiveAd")
    }

    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
      print("interstitialWillPresentScreen")
    }

    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
      print("interstitialWillDismissScreen")
    }

    /// Tells the delegate the interstitial had been animated off the screen.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("interstitialDidDismissScreen")
        interstitial = createAndLoadInterstitial()

    }

    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
      print("interstitialWillLeaveApplication")
    }
    
    public func showAd(){
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasnt ready")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        scrollView.delegate = self
        
        
        interstitial = createAndLoadInterstitial()
        interstitial.delegate = self

        menu.frame = CGRect(x: 25, y: view.frame.height * 0.25, width: view.frame.width - 50, height: view.frame.height * 0.6)
        menu.layer.cornerRadius = 50
        menu.center = view.center
        
        htpLabel.translatesAutoresizingMaskIntoConstraints = false
        pageViewControl.translatesAutoresizingMaskIntoConstraints = false
        ttdLabel.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        htpLabel.widthAnchor.constraint(equalTo: menu.widthAnchor).isActive = true
        htpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        htpLabel.topAnchor.constraint(equalTo: menu.topAnchor, constant: 15).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: pageViewControl.topAnchor, constant: 0).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: menu.centerXAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalTo: menu.heightAnchor, multiplier: 0.6).isActive = true
        scrollView.widthAnchor.constraint(equalToConstant: 290).isActive = true

        pageViewControl.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 15).isActive = true
        pageViewControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageViewControl.bottomAnchor.constraint(equalTo: ttdLabel.topAnchor, constant: -15).isActive = true
        
        ttdLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        ttdLabel.widthAnchor.constraint(equalTo: menu.widthAnchor).isActive = true
      //  ttdLabel.topAnchor.constraint(equalTo: pageViewControl.bottomAnchor, constant: 10).isActive = true
        ttdLabel.bottomAnchor.constraint(equalTo: menu.bottomAnchor, constant: -10).isActive = true

        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = MainMenu(fileNamed: "MainMenu") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.size = view.bounds.size
                // Present the scene
                
                scene.controller = self
                view.presentScene(scene)
                
                
                slides = createSlides()
                setupSlideScrollView(slides: slides)
                
                pageViewControl.numberOfPages = slides.count
                pageViewControl.currentPage = 0
                view.bringSubviewToFront(pageViewControl)
                
            }
            
            view.ignoresSiblingOrder = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
}
