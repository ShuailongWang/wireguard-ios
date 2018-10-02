//
//  Copyright © 2018 WireGuard LLC. All rights reserved.
//

import UIKit
import PromiseKit

enum GoVersionError: Error {
    case noDelegate
}

protocol SettingsTableViewControllerDelegate: class {
    func exportTunnels(settingsTableViewController: SettingsTableViewController, sourceView: UIView)
}

class SettingsTableViewController: UITableViewController {

    weak var delegate: SettingsTableViewControllerDelegate?
    @IBOutlet weak var versionInfoCell: UITableViewCell!
    @IBOutlet weak var goVersionInfoCell: UITableViewCell!
    @IBOutlet weak var exportCell: UITableViewCell!

    @IBOutlet weak var versionInfoLabel: UILabel!
    @IBOutlet weak var goVersionInfoLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        versionInfoLabel.text = versionInformation
        goVersionInfoLabel.text = goVersionInformation
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            switch cell {
            case versionInfoCell, goVersionInfoCell:
                UIPasteboard.general.string = ["WireGuard for iOS:", versionInformation, "Go userspace backend:", goVersionInfoLabel.text ?? ""].joined(separator: "\n")
                showCopyConfirmation()
            case exportCell:
                delegate?.exportTunnels(settingsTableViewController: self, sourceView: exportCell)
            default:
                ()
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    var versionInformation: String {
        var versionElements: [String] = []
        if let appBuildNumber = Bundle.main.infoDictionary!["CFBundleVersion"] as? String, let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String {
            versionElements.append(appVersion)
            versionElements.append("(\(appBuildNumber))")
        }

        return versionElements.joined(separator: " ")
    }

    var goVersionInformation: String {
        return Bundle.main.infoDictionary!["WireGuardGoVersion"] as? String ?? "Unknown!!!"
    }

    private func showNotEnabledAlert() {
        let notEnabledAlertController = UIAlertController(title: NSLocalizedString("Go version", comment: ""), message: NSLocalizedString("Enable a WireGuard config by connecting or by selecting one in the VPN section of the device Settings app.", comment: ""), preferredStyle: .alert)
        notEnabledAlertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Generic OK button"), style: .default, handler: nil))

        present(notEnabledAlertController, animated: true, completion: nil)
    }

    private func showCopyConfirmation() {
        let confirmationAlertController = UIAlertController(title: NSLocalizedString("Copied version information", comment: ""), message: UIPasteboard.general.string, preferredStyle: .alert)
        confirmationAlertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: "Generic OK button"), style: .default, handler: nil))

        present(confirmationAlertController, animated: true, completion: nil)

    }
}

extension SettingsTableViewController: Identifyable {}