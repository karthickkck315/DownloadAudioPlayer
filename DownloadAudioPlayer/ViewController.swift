//
//  ViewController.swift
//  DownloadAudioPlayer
//
//  Created by Karthick on 8/14/18.
//  Copyright © 2018 Karthick. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBAction func playAction(_ sender: Any) {
    let quranAudioPlayer = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuranAudioPlayer") as? QuranAudioPlayer
    quranAudioPlayer?.view.backgroundColor =  UIColor.init(red:0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.5)
    self.addChildViewController(quranAudioPlayer!)
    quranAudioPlayer?.didMove(toParentViewController: self)
    self.view.addSubview((quranAudioPlayer?.view)!)
  }
  override func viewDidLoad() {
    super.viewDidLoad()
   
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}

