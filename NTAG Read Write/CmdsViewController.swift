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
        
        if case let NFCTag.miFare(tag) = tag {
            session.connect(to: tags.first!) { (error) in
                if let error = error {
                    self.infoTextView.text = error.localizedDescription
                    return
                }
                
                DispatchQueue.main.async {
                    self.printTagDescription(tag: tag)
                }
                
                sendCmd(tag: tag)
            }
        }  
    }
    
    private func printTagDescription(tag: NFCMiFareTag) {
        
        let info = """
Tag detected.

MIFARE Tag Identifier: \(tag.identifier)
MIFARE Tag Family: \(tag.mifareFamily)
MIFARE Tag Historial Bytes: \(tag.historicalBytes?.count ?? 0)
MIFARE Tag Type: \(tag.type)
MIFARE Tag description: \(tag.description)
"""
        print(info)
        infoTextView.text = info
    }
}

private func sendCmd(tag: NFCMiFareTag) {
    let sramSize = 64
    let dataTx = NSMutableData(length: sramSize)!
    
    // TODO: Should do the foloowing in swift, but I cant work out the new API here. Drop in to NS
    let led = "L1".data(using: .ascii)
    let ledData = NSData(data: led!)
    let ledBytes = ledData.bytes
    dataTx.replaceBytes(in: NSMakeRange(sramSize - 4, 2), withBytes: ledBytes)
    
    write(tag: tag, dataTx: dataTx)
}

private func write(tag: NFCMiFareTag, dataTx: NSMutableData) {
    var charArray = [CUnsignedChar](repeating: 0, count: 3)
    charArray[0] = 0xA6
    charArray[1] = 0xF0
    charArray[2] = 0xF0 + 0x0F
    
    let cmd = NSMutableData(bytes: charArray, length: charArray.count)
    cmd.append(dataTx as Data)
    
    tag.sendMiFareCommand(commandPacket: cmd as Data) { (data, error) in
        if let error = error {
            print(error.localizedDescription)
        }
    }
}
