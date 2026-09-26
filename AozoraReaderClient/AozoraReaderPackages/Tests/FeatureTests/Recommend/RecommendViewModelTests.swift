import AozoraAPIResponse
import Testing

@testable import RecommendFeature

@Suite("おすすめタブ")
@MainActor
struct RecommendViewModelTests {
    struct Failure: Error {}

    nonisolated private static let literature = RecommendationsResponse(sections: [
        RecommendationSectionResponse(
            category: CategoryResponse(id: "9", name: "文学"),
            books: [BookSummaryResponse(id: 1567, title: "走れメロス", contributors: [])]
        ),
    ])

    nonisolated private static let history = RecommendationsResponse(sections: [
        RecommendationSectionResponse(
            category: CategoryResponse(id: "2", name: "歴史"),
            books: [BookSummaryResponse(id: 43035, title: "手紙", contributors: [])]
        ),
    ])

    @Test("開いたらおすすめを取って出す")
    func loadsOnFirstOpen() async {
        let model = RecommendViewModel(repository: RecommendationRepositoryMock(recommendations: { Self.literature }))

        await model.task()

        #expect(model.sections == Self.literature.sections)
        #expect(!model.hasFailed)
    }

    /// サーバーは呼ぶたびに違う中身を返す。取り直していれば中身が変わる。
    @Test("一度取れたら、開き直しても中身が変わらない")
    func keepsSectionsOnReopen() async {
        let model = RecommendViewModel(repository: RecommendationRepositoryMock(
            recommendations: sequence(.success(Self.literature), .success(Self.history))
        ))

        await model.task()
        await model.task()

        #expect(model.sections == Self.literature.sections)
    }

    @Test("失敗したらエラーを出す")
    func failsOnError() async {
        let model = RecommendViewModel(repository: RecommendationRepositoryMock(recommendations: { throw Failure() }))

        await model.task()

        #expect(model.hasFailed)
        #expect(model.sections.isEmpty)
    }

    /// 取れていないので、開き直したときも取りに行く。
    @Test("失敗したあとに開き直すと取り直す")
    func retriesOnReopenAfterFailure() async {
        let model = RecommendViewModel(repository: RecommendationRepositoryMock(
            recommendations: sequence(.failure(Failure()), .success(Self.literature))
        ))

        await model.task()
        await model.task()

        #expect(!model.hasFailed)
        #expect(model.sections == Self.literature.sections)
    }

    @Test("再読み込みで取り直し、成功したらエラーを消す")
    func reloadRecovers() async {
        let model = RecommendViewModel(repository: RecommendationRepositoryMock(
            recommendations: sequence(.failure(Failure()), .success(Self.literature))
        ))

        await model.task()
        await model.reload()

        #expect(!model.hasFailed)
        #expect(model.sections == Self.literature.sections)
    }
}
