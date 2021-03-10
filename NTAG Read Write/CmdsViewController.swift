//
//  CmdsViewController.swift
//  NTAG Read Write
//
//  Created by richardstockdale on 09/03/2021.
//

import UIKit


//import CoreNFC

class CmdsViewController: UIViewController, NFCTagReaderSessionDelegate {
    var session: NFCTagReaderSession?
    @IBOutlet weak var infoTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func led1ButtonTapped(_ sender: Any) {
//        NTAG_I2C_LIB.sharedInstance()?.initSession({ (nil) in
//            self.connected()
//        }, onFailure: { (error) in
//            print("failed to get the session")
//        })

        connect() // MINE
    }
    
    private func connected() {
        guard let lib = NTAG_I2C_LIB.sharedInstance() else {
            return
        }
        
        if lib.isConnect() != 3 { // 3 is connected apparently
            print("Not connected")
            return
        }

        let sramSize = 64
        let dataTx = NSMutableData(length: sramSize)!

        // TODO: Should do the foloowing in swift, but I cant work out the new API here. Drop in to NS
        let led = "L1".data(using: .ascii)
        let ledData = NSData(data: led!)
        let ledBytes = ledData.bytes
        dataTx.replaceBytes(in: NSMakeRange(sramSize - 4, 2), withBytes: ledBytes)
    }
    
    func connect() {
        //let concurrentQueue = DispatchQueue(label: "tagScan", attributes: .concurrent)
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.begin()
    }

    // MARK: - TagReaderSessionDelegate Methods
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        //infoTextView.text = "Session did become active: \(session.description)"
        print("Session did become active: \(session.description)")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let errorCode = (error as NSError).code
        if errorCode == 200 { return } // This is user terminating the read

//        infoTextView.text = error.localizedDescription
//        infoTextView.textColor = .red
        session.invalidate()
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            return
        }
        

        
        session.connect(to: tag) { (error) in
            
            
            
            print("Tag connected: \(tag.isAvailable)")
        }



        
    }
    
//    private func printTagDescription(tag: NFCTag) {
//
//        let info = """
//Tag detected.
//
//MIFARE Tag Identifier: \(tag.asNFCMiFareTag.identifier)
//MIFARE Tag Family: \(tag.asNFCMiFareTag.mifareFamily)
//MIFARE Tag Historial Bytes: \(tag)
//MIFARE Tag Type: \(tag)
//MIFARE Tag description: \(tag)
//"""
//
//    }
}


//extension CmdsViewController: NFCNDEFReaderSessionDelegate {
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        // NOT USED HERE
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        let errorCode = (error as NSError).code
//        if errorCode == 200 { return } // This is user terminating the read
//
//        infoTextView.text = error.localizedDescription
//        infoTextView.textColor = .red
//        session.invalidate()
//    }
//
//    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
//        if tags.count > 1 {
//            infoTextView.text = "Detected \(tags.count) tags. Move any other tags away and try again."
//            infoTextView.textColor = .red
//            session.invalidate()
//
//            return
//        }
//
//        guard let tag = tags.first else { return }
//
//        tag.queryNDEFStatus(completionHandler: { (status, capacity, error) in
//            if let error = error {
//                self.infoTextView.text = "Error getting tag info: \(error.localizedDescription)"
//                self.infoTextView.textColor = .red
//                session.invalidate()
//                return
//            }
//
//            self.infoTextView.text = "Tag capacity: \(capacity) bytes"
//            self.handleTag(tag: tag, status: status)
//        })
//    }
//
//    private func handleTag(tag: NFCNDEFTag, status: NFCNDEFStatus) {
//        switch status {
//        case .notSupported:
//            self.infoTextView.text.append("\n !!! THIS TAG IS NOT SUPPORTED")
//            self.infoTextView.textColor = .red
//        case .readWrite:
//            self.infoTextView.text.append("\n Tag is writable...\n")
//            sendCmd(tag: tag)
//        case .readOnly:
//            self.infoTextView.text.append("\n !!! THIS TAG IS NOT WRITABLE")
//            self.infoTextView.textColor = .red
//        @unknown default:
//            self.infoTextView.text.append("\n !!! UNKNOWN TAG TYPE")
//            self.infoTextView.textColor = .red
//        }
//    }
//
//    private func sendCmd(tag: NFCNDEFTag) {
//        session?.connect(to: tag, completionHandler: { (error) in
//            if let error = error {
//                let fail = "Connect to tag failed \(error.localizedDescription)"
//                self.session?.alertMessage = fail
//                self.infoTextView.text.append("\n \(fail)")
//                self.infoTextView.textColor = .red
//
//                return
//            }
//
//            let sramSize = 64
//            let dataTx = NSMutableData(length: sramSize)!
//
//            // TODO: Should do the foloowing in swift, but I cant work out the new API here. Drop in to NS
//            let led = "L1".data(using: .ascii)
//            let ledData = NSData(data: led!)
//            let ledBytes = ledData.bytes
//            dataTx.replaceBytes(in: NSMakeRange(sramSize - 4, 2), withBytes: ledBytes)
//
//            self.write(tag: tag, dataTx: dataTx)
//
//
//
//        })
//    }
//
//    private func write(tag: NFCNDEFTag, dataTx: NSMutableData) {
//        var charArray = [CUnsignedChar](repeating: 0, count: 3)
//        charArray[0] = 0xA6
//        charArray[1] = 0xF0
//        charArray[2] = 0xF0 + 0x0F
//
//        let cmd = NSMutableData(bytes: charArray, length: charArray.count)
//        cmd.append(dataTx as Data)
//
//
//        // TODO: Send the command
//        if let t = tag as? NFCMiFareTag {
//            t.sendMiFareCommand(commandPacket: cmd as Data) { (data, error) in
//
//
//
//
//            }
//        }
//
//    }
//}
