//
//  QuranAudioPlayer.swift
//  Quran
//
//  Created by Karthick on 8/10/18.
//  Copyright © 2018 Quran.com. All rights reserved.
//

import UIKit
import AVFoundation

class QuranAudioPlayer: UIViewController, URLSessionDownloadDelegate,AVAudioPlayerDelegate {
  private var audioPlayer: AVAudioPlayer?
  var player : AVPlayer?
  @IBOutlet weak var downloadView: UIView!
  @IBOutlet weak var progressBar: UIProgressView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  var audioTimer = Timer()
  //PLay View
  @IBOutlet weak var palyView: UIView!
  @IBOutlet weak var playProgressBar: UIProgressView!
  @IBOutlet weak var playPauseButton: UIButton!
  @IBOutlet weak var cancelButton: UIButton!
  @IBOutlet weak var playTitleLabel: UILabel!
  var isPlaying = true {
      didSet {
        setButtonState()
        playPauseAudio()
      }
    }
  var task : URLSessionTask!
//  var audioUrl = NSURL()
   var audioUrl = NSURL()
  var counter:Float = 0.0 {
    didSet {
      let fractionalProgress = Float(counter) / 100.0
      let animated = counter != 0
      progressBar.setProgress(fractionalProgress, animated: animated)
      //progressCount.text = ("\(counter)%")
    }
  }
  lazy var session : URLSession = {
    let config = URLSessionConfiguration.ephemeral
    config.allowsCellularAccess = false
    let session = Foundation.URLSession(configuration: config,delegate: self, delegateQueue: OperationQueue.main)
    return session
  }()
  override func viewDidLoad() {
    closeButton.setTitleColor(.red, for: .normal)
    cancelButton.setTitle("Cancel", for: .normal)
    cancelButton.setTitleColor(.red, for: .normal)
    cancelButton.backgroundColor = .clear
    downloadView.isHidden = false
    palyView.isHidden = true
    progressBar.setProgress(0.0, animated: true)
    playProgressBar.setProgress(0.0, animated: true)
    titleLabel.textAlignment = .center
    self.view.backgroundColor = UIColor.init(red:0/255.0 , green: 0/255.0, blue: 0/255.0, alpha: 0.5)
    if self.task != nil {
      return
    }
      titleLabel.text = "Downloading..."
      playTitleLabel.text = "Play"
      playTitleLabel.backgroundColor = .clear
    
    //progressCount.text = "0%"
    if self.task != nil {
      return
    }
    audioUrl = NSURL(string:"http://freetone.org/ring/stan/iPhone_5-Alarm.mp3")!
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent!)
    if FileManager.default.fileExists(atPath: destinationUrl.path) {
      print("The file already exists at path")
      playdownload()
    } else {
      let req = NSMutableURLRequest(url:audioUrl as URL)
      let task = self.session.downloadTask(with: req as URLRequest)
      self.task = task
      task.resume()
    }
  }
 /* @IBAction func doElaborateHTTP (sender:AnyObject!) {
    progressCount.text = "0%"
    if self.task != nil {
      return
    }
    audioUrl = NSURL(string:"http://freetone.org/ring/stan/iPhone_5-Alarm.mp3")!
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent!)
    if FileManager.default.fileExists(atPath: destinationUrl.path) {
      print("The file already exists at path")
      //playdownload()
    } else {
      let req = NSMutableURLRequest(url:audioUrl as URL)
      let task = self.session.downloadTask(with: req as URLRequest)
      self.task = task
      task.resume()
    }
  }*/
  
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64) {
    print("downloaded \(100*writ/exp)")
    DispatchQueue.main.async {
      self.counter = Float(100*writ/exp)
      return
    }
  }
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
    print(expectedTotalBytes)
    // unused in this example
  }
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    print("completed: error: \(error)")
  }
  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent!)
    print(destinationUrl)
    do {
      try FileManager.default.moveItem(at: location, to: destinationUrl)
      print("File moved to documents folder")
      self.playdownload()
    } catch let error as NSError {
      print(error.localizedDescription)
    }
  }
  func playdownload() {
    palyView.isHidden = false
    downloadView.isHidden = true
    progressBar.setProgress(0.0, animated: true)
    makeTimer()
    // if let audioURL = audioUrl {
    let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let destinationUrl = documentsDirectoryURL.appendingPathComponent(audioUrl.lastPathComponent!)
    //      let playerItem = AVPlayerItem.init(url: destinationUrl)
    //      player = AVPlayer.init(playerItem: playerItem)
    //player?.play()
    do {
    audioPlayer = try AVAudioPlayer(contentsOf: destinationUrl as URL)
    audioPlayer?.play()
      audioPlayer?.delegate = self
    } catch {
      print(error)
    }
    //}
  }
  func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
    print(flag)
    print("here")
    if flag == true{
      playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
  }
  func makeTimer() {
    if audioTimer != nil {
      audioTimer.invalidate()
    }
    audioTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimer), userInfo: nil, repeats: true)
  }
  @objc func onTimer() {
    guard let currentTime = audioPlayer?.currentTime, let duration = audioPlayer?.duration else {
      return
    }
    let percentCompleted = currentTime / duration
    playProgressBar.progress = Float(percentCompleted)
  }
  @IBAction func didTapCloseAction(_ sender: Any) {
    self.view.removeFromSuperview()
  }
  // MARK: IBActions
  @IBAction func playButtonTapped(sender: UIButton) {
    isPlaying = !isPlaying
  }
  func setButtonState() {
    if isPlaying {
      //playPauseButton.setTitle("Pause", for: .normal)
      playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
    } else {
      //playPauseButton.setTitle("Play", for: .normal)
      playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
  }
  func playPauseAudio() {
    guard let audioPlayer = audioPlayer else {
      return
    }
    if isPlaying {
      audioPlayer.play()
       playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "pause"), for: .normal)
    } else {
      audioPlayer.pause()
      playPauseButton.setBackgroundImage(#imageLiteral(resourceName: "play"), for: .normal)
    }
  }
  @IBAction func closeButtonAction(_ sender: Any) {
    guard let audioPlayer = audioPlayer else {
      return
    }
      audioPlayer.pause()
    self.view.removeFromSuperview()
  }
}
