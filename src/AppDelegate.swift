import Cocoa
import Combine
import CoreBluetooth
import os

class AppDelegate: NSObject, NSApplicationDelegate {
  var subscription: Cancellable?
  var statusBar: StatusBarController?

  var windowController: NSWindowController!
  var window: NSWindow!

  var bluetoothDelegate = BluetoothDelegate()
  var ruuviLogger = Logger(subsystem: "RuuviMenu", category: "RuuviMsg")

  @objc func openPrefsWindow() {
    if window == nil {
      window = NSWindow(
        contentRect: NSScreen.main?.frame ?? .zero,
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false)

      window.contentViewController = PrefsViewController()

      window.setFrame(NSRect(x: 800, y: 600, width: 200, height: 250), display: false)

      windowController = NSWindowController()
      windowController.contentViewController = window.contentViewController
      windowController.window = window
      // windowController.windowFrameAutosaveName = "PrefsWindow"

    }

    NSApp.activate(ignoringOtherApps: true)
    windowController.showWindow(self)

    print("Hepp")
  }

  @objc func closePrefsWindow() {
    self.window.close()

  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {

    // Get application name
    let bundleInfoDict: NSDictionary = Bundle.main.infoDictionary! as NSDictionary
    let appName = bundleInfoDict["CFBundleName"] as! String

    // Add menu
    let mainMenu = NSMenu()
    let mainMenuFileItem = NSMenuItem(title: "File", action: nil, keyEquivalent: "")
    let fileMenu = NSMenu(title: "File")

    fileMenu.addItem(
      withTitle: "Quit",
      action: #selector(NSApplication.terminate(_:)),
      keyEquivalent: "q")

    fileMenu.addItem(
      withTitle: "Close window",
      action: #selector(closePrefsWindow),
      keyEquivalent: "w")

    mainMenuFileItem.submenu = fileMenu
    mainMenu.addItem(mainMenuFileItem)
    NSApp.mainMenu = mainMenu

    let publisher = bluetoothDelegate.initScan()

    subscription = publisher.sink(receiveValue: {
      self.ruuviLogger.info("\($0.description, privacy: .public)")
    })

    statusBar = StatusBarController()
    statusBar?.subscribe(ruuviPublisher: bluetoothDelegate.publisher)

    openPrefsWindow()
  }

  private func applicationWillTerminate() {
    subscription?.cancel()
  }
}
