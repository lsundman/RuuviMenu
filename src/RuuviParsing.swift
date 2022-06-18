import Foundation

let ruuviBytes = Data([0x99, 0x04])

func smush(_ data: Data, _ range: Range<Data.Index>) -> UInt16 {
  let bytes = data.subdata(in: range)
  return UInt16(bytes[0]) << 8 | UInt16(bytes[1])
}

func dataToHex(_ data: Data, separator: String) -> String {
  return data.map { b in String(format: "%02X", b) }.joined(separator: separator)
}

struct RuuviMeasurement: CustomStringConvertible {
  var timestamp: Date
  var device: UUID
  var mac: String
  var rssi: Int
  var temperature: Double
  var humidity: Double
  var pressure: Double
  var battery: Double
  var sequenceNumber: UInt16
  var rawRecord: String

  init(timestamp: Date, device: UUID, rssi: Int, data: Data) {
    self.timestamp = timestamp
    self.device = device
    self.rssi = rssi

    let payload = data.subdata(in: 2..<26)

    temperature = Double(smush(payload, 1..<3)) * 0.005
    humidity = Double(smush(payload, 3..<5)) * 0.0025
    pressure = (Double(smush(payload, 5..<7)) + 50000.0) / 100
    battery = Double((smush(payload, 13..<15) >> 5) + UInt16(1600)) / 1000
    sequenceNumber = smush(payload, 16..<18)

    mac = dataToHex(payload.subdata(in: 18..<23), separator: ":")
    rawRecord = dataToHex(payload, separator: "")
  }

  var description: String {
    var result = [mac]
    result += [temperature, humidity, pressure, battery].map {
      String(format: "%.2f", $0)
    }
    result.append(String(format: "%d", rssi))
    return result.joined(separator: " ")
  }
}
