//
//  NDefWriteViewController.swift
//  NTAG Read Write
//
//  Created by richardstockdale on 08/03/2021.
//

import UIKit
import CoreNFC

class NDefWriteViewController: UIViewController {
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var infoTextView: UITextView!
    
    let placeholderText = "Leave blank for text text with data and time"
    var session: NFCNDEFReaderSession?
    
    override func viewDidLoad() {
        super .viewDidLoad()
    }
    
    @IBAction func writeTapped(_ sender: Any) {
        messageTextView.text = ndefMessage
        messageTextView.resignFirstResponder()
        session = NFCNDEFReaderSession(delegate: self,
                                       queue: .main,
                                       invalidateAfterFirstRead: false)
        session?.begin()
    }
    
    private var ndefMessage: String {
        get {
            guard let message = messageTextView.text,
                  !message.isEmpty,
                  message != placeholderText else { return timeInfo }
            return message
        }
    }
    
    private var timeInfo: String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        
        return "NDEF Message at \(df.string(from: Date()))"
    }
}

extension NDefWriteViewController: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // NOT USED HERE
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        let errorCode = (error as NSError).code
        if errorCode == 200 { return } // This is user terminating the read
        
        infoTextView.text = error.localizedDescription
        infoTextView.textColor = .red
        session.invalidate()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            infoTextView.text = "Detected \(tags.count) tags. Move any other tags away and try again."
            infoTextView.textColor = .red
            session.invalidate()
            
            return
        }
        
        guard let tag = tags.first else { return }
        
        tag.queryNDEFStatus(completionHandler: { (status, capacity, error) in
            if let error = error {
                self.infoTextView.text = "Error getting tag info: \(error.localizedDescription)"
                self.infoTextView.textColor = .red
                session.invalidate()
                return
            }
            
            self.infoTextView.text = "Tag capacity: \(capacity) bytes"
            self.handleTag(tag: tag, status: status)
        })
    }
    
    private func handleTag(tag: NFCNDEFTag, status: NFCNDEFStatus) {
        switch status {
        case .notSupported:
            self.infoTextView.text.append("\n !!! THIS TAG IS NOT SUPPORTED")
            self.infoTextView.textColor = .red
        case .readWrite:
            self.infoTextView.text.append("\n Tag is writable...\n")
            createMessage(tag: tag)
        case .readOnly:
            self.infoTextView.text.append("\n !!! THIS TAG IS NOT WRITABLE")
            self.infoTextView.textColor = .red
        @unknown default:
            self.infoTextView.text.append("\n !!! UNKNOWN TAG TYPE")
            self.infoTextView.textColor = .red
        }
    }
    
    private func createMessage(tag: NFCNDEFTag) {
        guard let record = NFCNDEFPayload.wellKnownTypeTextPayload(string: ndefMessage,
                                                                   locale: .autoupdatingCurrent) else {
            session?.invalidate()
            infoTextView.text.append("\n Could not create record")
            infoTextView.textColor = .red
            
            return
        }
        
        let message = NFCNDEFMessage(records: [record])
        writeMessage(tag: tag, message: message)
    }
    
    private func writeMessage(tag: NFCNDEFTag, message: NFCNDEFMessage) {
        session?.connect(to: tag, completionHandler: { (error) in
            if let error = error {
                let fail = "Connect to tag failed \(error.localizedDescription)"
                self.session?.alertMessage = fail
                self.infoTextView.text.append("\n \(fail)")
                self.infoTextView.textColor = .red
                
                return
            }
            
            tag.writeNDEF(message) { (error) in
                if let error = error {
                    let fail = "Write failed: \(error.localizedDescription)"
                    self.session?.alertMessage = fail
                    self.infoTextView.text.append("\n \(fail)")
                    self.infoTextView.textColor = .red
                    
                    return
                }
                else {
                    self.session?.alertMessage = "Write NDEF message successful!"
                    self.infoTextView.text.append("\n\nWrite NDEF message successful!")
                    self.infoTextView.textColor = .black
                    
                }
                
                self.session?.invalidate()
            }
        })
    }
}
