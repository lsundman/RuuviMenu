import AppKit

class PrefsViewController: NSViewController {

  override func loadView() {
    self.view = NSTabView()

    let tabNames = NSTabViewItem()
    tabNames.label = "Tags"

    let view = self.view as! NSTabView
    view.addTabViewItem(tabNames)

  }
}
