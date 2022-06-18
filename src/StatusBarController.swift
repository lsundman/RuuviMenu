import AppKit
import Combine
import Foundation

let tsOpts: ISO8601DateFormatter.Options = [
  .withYear,
  .withMonth,
  .withDay,
  .withTime,
  .withDashSeparatorInDate,
  .withColonSeparatorInTime,
]

func formatTemp(_ meas: RuuviMeasurement) -> String {
  return String(format: "%.1f\u{2009}℃", meas.temperature)
}

func niceDesc(_ meas: RuuviMeasurement) -> String {
  return [
    meas.mac,
    "│",
    formatTemp(meas),
    String(format: "%.1f\u{2009}RH", meas.humidity),
    String(format: "%.1f\u{2009}kPa", meas.pressure),
  ].joined(separator: " ")
}

func extraInfo(_ meas: RuuviMeasurement) -> String {
  return [
    ISO8601DateFormatter.string(
      from: meas.timestamp,
      timeZone: TimeZone.current,
      formatOptions: tsOpts
    ).replacingOccurrences(of: "T", with: "\u{2009}"),
    String(format: "%.2f\u{2009}V", meas.battery),
    String(format: "%.d\u{2009}dBm", meas.rssi),
  ].joined(separator: " ")
}

class StatusBarController {
  var statusItem: NSStatusItem = NSStatusItem()
  var subscription: Cancellable?

  var deviceCache: [UUID: RuuviMeasurement] = [:]
  var menuItemCache: [UUID: NSMenuItem] = [:]
  var sortedDevices: [UUID] = []
  var selected: UUID?

  private func selectDevice(device: UUID) {
    self.selected = device

    for (id, menuItem) in menuItemCache {
      if id == self.selected {
        menuItem.state = NSControl.StateValue.on
      } else {
        menuItem.state = NSControl.StateValue.off
      }
    }

    if let meas = deviceCache[device] {
      self.statusItem.button?.title = formatTemp(meas)
    }
  }

  @objc func itemClicked(sender: NSMenuItem) {
    selectDevice(device: sortedDevices[sender.tag])
  }

  private func update(_ meas: RuuviMeasurement) {
    deviceCache[meas.device] = meas

    sortedDevices = deviceCache.keys.sorted {
      return $0.uuidString > $1.uuidString
    }

    for (index, id) in sortedDevices.enumerated() {
      let deviceMeas = deviceCache[id]!
      let title = "\(niceDesc(deviceMeas))"

      if !menuItemCache.keys.contains(id) {
        let menuItem = NSMenuItem(
          title: title,
          action: #selector(itemClicked), keyEquivalent: "")

        menuItem.target = self
        menuItem.isEnabled = true

        menuItemCache[id] = menuItem
        statusItem.menu?.insertItem(menuItem, at: 0)
      }

      if let menuItem = menuItemCache[id] {
        menuItem.title = title
        menuItem.tag = index
        menuItem.toolTip = extraInfo(deviceMeas)
      }

      if id == selected {
        statusItem.button?.title = formatTemp(deviceMeas)
      }
    }

    if selected == nil && !deviceCache.isEmpty {
      selectDevice(device: deviceCache.first!.key)
    }

  }

  init() {
    statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

    if let button = statusItem.button {
      button.title = "…"
    }

    statusItem.menu = NSMenu()
    statusItem.menu?.autoenablesItems = true
    statusItem.button?.title = "…"

    let quitButton = NSMenuItem(
      title: "Quit",
      action: #selector(NSApplication.shared.terminate),
      keyEquivalent: "")

    if let menu = statusItem.menu {
      menu.addItem(NSMenuItem.separator())
      menu.addItem(quitButton)
    }
  }

  func subscribe(ruuviPublisher: PassthroughSubject<RuuviMeasurement, Never>) {
    subscription = ruuviPublisher.sink(receiveValue: update)
  }

  func applicationWillTerminate(_ notification: Notification) {
    subscription?.cancel()
  }
}
