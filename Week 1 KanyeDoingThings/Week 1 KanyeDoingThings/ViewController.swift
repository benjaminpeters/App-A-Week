//
//  ViewController.swift
//  Week 1 KanyeDoingThings
//
//  Created by Ben Peters on 2016-03-20.
//  Copyright © 2016 Orange Chips. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var kanyeImageView: UIImageView!
    
    let imagePicker = UIImagePickerController()

    @IBAction func loadImageButtonTapper(sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    @IBAction func takeImageButtonTapper(sender: UIBarButtonItem) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)

    }
    
    func saveImageButtonTapper() {
        
        // Add a UIView then add the photos and stickers to it to save
        let DynamicView = UIView(frame: view.bounds)
        self.view.addSubview(DynamicView)
        DynamicView.addSubview(imageView)
        DynamicView.addSubview(kanyeImageView)
        
        UIGraphicsBeginImageContextWithOptions(DynamicView.bounds.size, true, 0)
        DynamicView.drawViewHierarchyInRect(DynamicView.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        if error == nil {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        } else {
            let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "ios-linen.jpg")!)

        imagePicker.delegate = self
        
        let navigationBar = UINavigationBar(frame: CGRectMake(0, 0, self.view.frame.size.width, 44)) // Offset by 20 pixels vertically to take the status bar into account
        
        // Create a navigation item with a title
        let navigationItem = UINavigationItem()
        navigationItem.title = "Kanye Doing Things"
        
        let rightButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("saveImageButtonTapper"))
        
        navigationItem.rightBarButtonItem = rightButton
        
        navigationBar.items = [navigationItem]
        
        self.view.addSubview(navigationBar)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Handle the PanGesture for a Kanye
    @IBAction func handlePan(recognizer: UIPanGestureRecognizer){
        let translations = recognizer.translationInView(self.view)
        
        if let view = recognizer.view{
            view.center = CGPoint(x:view.center.x + translations.x, y:view.center.y + translations.y)
        }
        recognizer.setTranslation(CGPointZero, inView: self.view)
        
        if recognizer.state == UIGestureRecognizerState.Ended {
            // 1
            let velocity = recognizer.velocityInView(self.view)
            let magnitude = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y))
            let slideMultiplier = magnitude / 800
            print("magnitude: \(magnitude), slideMultiplier: \(slideMultiplier)")
            
            // 2
            let slideFactor = 0.1 * slideMultiplier     //Increase for more of a slide
            // 3
            var finalPoint = CGPoint(x:recognizer.view!.center.x + (velocity.x * slideFactor),
                y:recognizer.view!.center.y + (velocity.y * slideFactor))
            // 4
            finalPoint.x = min(max(finalPoint.x, 0), self.view.bounds.size.width)
            finalPoint.y = min(max(finalPoint.y, 0), self.view.bounds.size.height)
            
            // 5
            UIView.animateWithDuration(Double(slideFactor * 2),
                delay: 0,
                // 6
                options: UIViewAnimationOptions.CurveEaseOut,
                animations: {recognizer.view!.center = finalPoint },
                completion: nil)
        }
    }
    
    // Handle Kanye Pinch
    @IBAction func handlePinch(recognizer : UIPinchGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformScale(view.transform,
                recognizer.scale, recognizer.scale)
            recognizer.scale = 1
        }
    }
    
    //Handle Kanye rotate
    @IBAction func handleRotate(recognizer : UIRotationGestureRecognizer) {
        if let view = recognizer.view {
            view.transform = CGAffineTransformRotate(view.transform, recognizer.rotation)
            recognizer.rotation = 0
        }
    }
    
    // Simultaneous gesture recognizers
    func gestureRecognizer(recognizer : UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWithGestureRecognizer:UIGestureRecognizer) -> Bool {
            return true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

