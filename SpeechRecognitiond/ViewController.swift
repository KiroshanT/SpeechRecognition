//
//  ViewController.swift
//  SpeechRecognitiond
//
//  Created by Kiroshan Thayaparan on 7/3/22.
//

import UIKit
import Speech

class ViewController: UIViewController {
    
    let textView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = .boldSystemFont(ofSize: 20)
        return textView
    }()
    let buttonStart: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
        button.tag = 0
        button.addTarget(self, action: #selector(buttonStartAction), for: .touchUpInside)
        return button
    }()
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
    }
    
    
    @objc func buttonStartAction(sender: UIButton) {
        if sender.tag == 0 {
            sender.setBackgroundImage(UIImage(systemName: "stop.circle"), for: .normal)
            sender.tag = 1
            recordAndRecognizeSpeech()
        } else {
            cancelRecording()
            sender.setBackgroundImage(UIImage(systemName: "play.circle"), for: .normal)
            sender.tag = 0
        }
    }
    
    func viewSetup() {
        view.addSubview(textView)
        view.addSubview(buttonStart)
        
        NSLayoutConstraint.activate([
            
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: buttonStart.topAnchor),
            textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5),
            textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5),
            
            buttonStart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            buttonStart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonStart.heightAnchor.constraint(equalToConstant: 80),
            buttonStart.widthAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    //MARK: - Recognize Speech
    func recordAndRecognizeSpeech() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            self.sendAlert(title: "Speech Recognizer Error", message: "There has been an audio engine error.")
            return print(error)
        }
        guard let myRecognizer = SFSpeechRecognizer() else {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not supported for your current locale.")
            return
        }
        if !myRecognizer.isAvailable {
            self.sendAlert(title: "Speech Recognizer Error", message: "Speech recognition is not currently available. Check back at a later time.")
            // Recognizer is not available right now
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
//                var lastString: String = ""
//                for segment in result.bestTranscription.segments {
//                    let indexTo = bestString.index(bestString.startIndex, offsetBy: segment.substringRange.location)
//                    lastString = String(bestString[indexTo...])
//                }
                self.textView.text = bestString
            } else if let error = error {
                self.sendAlert(title: "Speech Recognizer Error", message: "There has been a speech recognition error.")
                print(error)
            }
        })
    }
    
    func cancelRecording() {
        recognitionTask?.finish()
        recognitionTask = nil
        
        // stop audio
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    //MARK: - Alert
    func sendAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
