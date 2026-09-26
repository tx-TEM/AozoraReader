import AozoraAPIResponse
import Foundation
import Observation
import Repository

@MainActor
@Observable
public final class RecommendViewModel {
    private(set) var sections: [RecommendationSectionResponse] = []
    private(set) var hasFailed = false

    private let repository: any RecommendationRepositoryProtocol
    /// 一度取れたら、タブを行き来しても取り直さない。
    private var needsLoading = true

    public init(repository: any RecommendationRepositoryProtocol = RecommendationRepository()) {
        self.repository = repository
    }

    /// タブを開いたときに呼ぶ。まだ取れていなければ取りに行く。
    func task() async {
        guard needsLoading else { return }
        await load()
    }

    /// 再読み込みボタンを押したときに呼ぶ。
    func reload() async {
        await load()
    }

    private func load() async {
        do {
            sections = try await repository.recommendations().sections
            hasFailed = false
            needsLoading = false
        } catch {
            hasFailed = true
        }
    }
}
