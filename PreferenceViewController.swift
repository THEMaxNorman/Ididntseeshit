import UIKit

final class PreferenceViewController: UIViewController {
    @IBOutlet private weak var urlField: UITextField?
    @IBOutlet private weak var streamNameField: UITextField?
    @IBOutlet weak var watermark: UITextField!
    let defaults = UserDefaults.standard
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let savedPrefs = defaults.object(forKey: "SavedPrefs") as? Data {
            let decoder = JSONDecoder()
            if let loadedPrefs = try? decoder.decode(Preference.self, from: savedPrefs) {
                print(loadedPrefs.uri! as String)
                Preference.defaultInstance = loadedPrefs
            }
        }
        urlField?.text = Preference.defaultInstance.uri
        streamNameField?.text = Preference.defaultInstance.streamName
        watermark?.text = Preference.defaultInstance.waterMark
    }

    @IBAction func on(open: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: "PopUpLive")
        present(controller, animated: true, completion: nil)
    }
}

extension PreferenceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if urlField == textField {
            Preference.defaultInstance.uri = textField.text
        }
        if streamNameField == textField {
            Preference.defaultInstance.streamName = textField.text
        }
        if watermark == textField {
            Preference.defaultInstance.waterMark = textField.text!
        }
        textField.resignFirstResponder()
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(Preference.defaultInstance) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: "SavedPrefs")
        }
        return true
    }
}
