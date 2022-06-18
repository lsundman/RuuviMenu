import Combine
import CoreBluetooth

class BluetoothDelegate: NSObject, CBCentralManagerDelegate {
  var centralManager: CBCentralManager?
  var publisher: PassthroughSubject<RuuviMeasurement, Never> = PassthroughSubject()
  var seen: [UUID: UInt16] = [:]

  func centralManager(
    _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
    advertisementData: [String: Any], rssi RSSI: NSNumber
  ) {
    if let mfgData = advertisementData["kCBAdvDataManufacturerData"] {
      if let bytes = mfgData as? Data {
        if bytes.prefix(2) == ruuviBytes {

          let date: Date
          if let timestamp = advertisementData["kCBAdvDataTimestamp"] as? Double {
            date = Date(timeIntervalSinceReferenceDate: timestamp)
          } else {
            date = Date()
          }

          let meas = RuuviMeasurement(
            timestamp: date,
            device: peripheral.identifier,
            rssi: RSSI.intValue,
            data: bytes
          )

          if meas.sequenceNumber > seen[meas.device] ?? 0 {
            self.publisher.send(meas)
          }

          seen[meas.device] = meas.sequenceNumber
        }
      }
    }
  }

  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == CBManagerState.poweredOn {
      central.scanForPeripherals(withServices: nil, options: nil)
    }
  }

  func initScan() -> PassthroughSubject<RuuviMeasurement, Never> {
    centralManager = CBCentralManager(delegate: self, queue: nil)
    return publisher
  }
}
