//
//  ViewController.swift
//  NTAG Read Write
//
//  Created by richardstockdale on 08/03/2021.
//

import UIKit
import CoreNFC

class NDefReadViewController: UIViewController {

    @IBOutlet weak var resultsTextView: UITextView!
    
    var session: NFCNDEFReaderSession?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard NFCReaderSession.readingAvailable else {
            resultsTextView.text = "This device does not support NFC"
            resultsTextView.textColor = .red
            
            return
        }
    }

    @IBAction func readNDef(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self, queue: DispatchQueue.main, invalidateAfterFirstRead: false)
        session?.begin()
    }
}

extension NDefReadViewController: NFCNDEFReaderSessionDelegate {
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let errorCode = (error as NSError).code
        if errorCode == 200 { return } // This is user terminating the read
        
        resultsTextView.text = error.localizedDescription
        resultsTextView.textColor = .red
        session.invalidate()
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        resultsTextView.textColor = .black
        var messageText = "\(messages.count) MESSAGES FOUND...\n\n"
        
        for (index, message) in messages.enumerated() {
            for record in message.records {
                if let string = String(data: record.payload, encoding: .ascii) {
                    messageText.append("Message - \(index)\n\(string)\n\n")
                }
            }
        }
        
        session.invalidate()
        resultsTextView.text = messageText
    }
}

