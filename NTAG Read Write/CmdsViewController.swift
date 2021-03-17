//
//  CmdsViewController.swift
//  NTAG Read Write
//
//  Created by richardstockdale on 09/03/2021.
//

import UIKit


//import CoreNFC

class CmdsViewController: UIViewController, NFCTagReaderSessionDelegate {
    var ledCommand: String?
    var session: NFCTagReaderSession?
    let sramSize = 64
    
    @IBOutlet weak var temperatureSwitch: UISwitch!
    @IBOutlet weak var infoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func orangeTapped(_ sender: Any) {
        ledCommand = "L1"
        connect()
    }
    
    @IBAction func blueTapped(_ sender: Any) {
        ledCommand = "L2"
        connect()
    }
    
    @IBAction func greenTapped(_ sender: Any) {
        ledCommand = "L3"
        connect()
    }
    
    func connect() {
        session = NFCTagReaderSession(pollingOption: .iso14443, delegate: self)
        session?.begin()
    }
    
    // MARK: - TagReaderSessionDelegate Methods
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        self.log(message: "Session did become active: \(session.description)", isError: false)
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        let errorCode = (error as NSError).code
        if errorCode == 200 { return } // This is user terminating the read
        if errorCode == 201 {
            log(message: "Session timed out", isError: false)
            return } // Timed out
        
        log(message: "\n ** ERROR ** \(error.localizedDescription)", isError: true)
        session.invalidate()
        
        log(message: "Will restart polling...", isError: false)
        DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
            session.restartPolling()
            self.log(message: "Restarting polling", isError: false)
        })
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        print("Tag found")
        
        
        guard let tag = tags.first else {
            return
        }
        
        if case let NFCTag.miFare(tag) = tag {
            session.connect(to: tags.first!) { (error) in
                if let error = error {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 1, execute: {
                        session.restartPolling()
                        self.log(message: "Restarting polling", isError: false)
                    })
                    
                    self.log(message: "Error connecting to tag (will restart session): \(error.localizedDescription)", isError: true)
                    
                    return
                }
                
                self.printTagDescription(tag: tag)
                self.sendCmd(tag: tag)
            }
        }  
    }
    
    private func sendCmd(tag: NFCMiFareTag) {
        guard let led = ledCommand else {
            return
        }
        
        log(message: "\n Sending command...", isError: false)
        
        let dataTx = NSMutableData(length: sramSize)!
        
        // The switches
        let ledData = led.data(using: .ascii)
        let ledNSData = NSData(data: ledData!)
        let b = ledNSData.bytes
        dataTx.replaceBytes(in: NSMakeRange(sramSize - 4, 2), withBytes: b)
        
        // The on value to be written to turn on various bits of functionality
        let tData = "E".data(using: .ascii)
        let tNSData = NSData(data: tData!)
        let tb = tNSData.bytes
        
        // Temperature
        DispatchQueue.main.async {
            if self.temperatureSwitch.isOn {
                dataTx.replaceBytes(in: NSMakeRange(self.sramSize - 9, 1), withBytes: tb)
            }
            
            dataTx.replaceBytes(in: NSMakeRange(self.sramSize - 10, 1), withBytes: tb)
            self.write(tag: tag, dataTx: dataTx)
        }
    }
    
    private func write(tag: NFCMiFareTag, dataTx: NSMutableData) {
        var charArray = [CUnsignedChar](repeating: 0, count: 3)
        charArray[0] = 0xA6
        charArray[1] = 0xF0 // Start
        charArray[2] = 0xF0 + 0x0F // End
        
        let cmd = NSMutableData(bytes: charArray, length: charArray.count)
        cmd.append(dataTx as Data)
        
        tag.sendMiFareCommand(commandPacket: cmd as Data) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                
                self.log(message: "Error sending command: \(error.localizedDescription)",
                         isError: true)
            }
            
            // Wait 100ms. Do a read of the memory.
            // This is what the iOS and Android apps do
            // May not be nessesary
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.read(tag: tag)
            }
        }
    }
    
    private func read(tag: NFCMiFareTag) {
        var charArray = [CUnsignedChar](repeating: 0, count: 3)
        charArray[0] = 0x3A
        charArray[1] = 0xF0 // Start
        charArray[2] = 0xFF // End
        
        let cmd = NSMutableData(bytes: charArray, length: charArray.count)
        tag.sendMiFareCommand(commandPacket: cmd as Data) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
            }
            
            self.parseData(data: data)
        }
    }
    
    private func parseData(data: Data) {
        DispatchQueue.main.async {
            let parser = DataParser()
            let result = parser.update(data, isTempEnabled: self.temperatureSwitch.isOn)
            
            self.log(message: result, isError: false)
        }
    }
    
    private func printTagDescription(tag: NFCMiFareTag) {
        let uid = tag.identifier.map{ String(format: "%2hhx", $0) }.joined()
        let info = """
Tag details...

MIFARE Tag Identifier: \(uid)
MIFARE Tag Family: \(tag.mifareFamily)
MIFARE Tag Historial Bytes: \(tag.historicalBytes?.count ?? 0)
MIFARE Tag Type: \(tag.type)
MIFARE Tag description: \(tag.description)
"""
        log(message: info, isError: false)
    }
    
    private func log(message: String, isError: Bool) {
        print(message)
        
        DispatchQueue.main.async {
            self.infoTextView.text = self.infoTextView.text.appending("\n\(message)")
            
            if isError {
                self.infoTextView.textColor = .red
            }
        }
    }
}
