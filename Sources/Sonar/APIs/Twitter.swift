import Accounts
import Social

private let kTwitterURL = URL(string: "https://api.twitter.com/1.1/statuses/update.json")

final class Twitter: BugTracker {

    func login(getTwoFactorCode: @escaping (_ closure: @escaping (_ code: String?) -> Void) -> Void,
               closure: @escaping (Result<Void, SonarError>) -> Void)
    {
        return closure(.success())
    }

    func create(radar: Radar, closure: @escaping (Result<Int, SonarError>) -> Void) {
        let account = ACAccountStore()
        let accountType = account.accountType(withAccountTypeIdentifier: ACAccountTypeIdentifierTwitter)

        let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .POST, url: kTwitterURL, parameters: ["status": radar.shortDescription])
        request?.account = account.accounts(with: accountType).first as! ACAccount
        request?.perform { (data, response, error) in
            if response?.statusCode != 200 {
                closure(.failure(SonarError(message: "Couldn't post tweet")))
            }
        }
    }
}
