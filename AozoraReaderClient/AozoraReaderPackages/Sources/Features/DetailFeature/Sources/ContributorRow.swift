import AozoraAPIResponse
import SwiftUI

/// 関係者 1 人。役割を問わず出す。
struct ContributorRow: View {
    let contributor: ContributorResponse

    var body: some View {
        LabeledContent {
            Text(contributor.name)
            if let years {
                Text(years).font(.caption)
            }
        } label: {
            Text(contributor.role)
        }
    }

    /// 生没年。月日まで出すと読みにくいので年だけにする。片方だけ欠けることがある。
    private var years: String? {
        let birth = contributor.birthDate.map(year(of:))
        let death = contributor.deathDate.map(year(of:))
        guard birth != nil || death != nil else { return nil }
        return "\(birth ?? "") - \(death ?? "")"
    }

    private func year(of date: String) -> String {
        String(date.prefix(4))
    }
}
