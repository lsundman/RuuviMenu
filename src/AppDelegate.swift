import Cocoa
import Combine
import CoreBluetooth
import os

class AppDelegate: NSObject, NSApplicationDelegate {
  var subscription: Cancellable?
  var statusBar: StatusBarController?

  var bluetoothDelegate = BluetoothDelegate()
  var ruuviLogger = Logger(subsystem: "RuuviMenu", category: "RuuviMsg")

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let publisher = bluetoothDelegate.initScan()

    subscription = publisher.sink(receiveValue: {
      self.ruuviLogger.info("\($0.description, privacy: .public)")
    })

    statusBar = StatusBarController()
    statusBar?.subscribe(ruuviPublisher: bluetoothDelegate.publisher)
  }

  private func applicationWillTerminate() {
    subscription?.cancel()
  }
}
