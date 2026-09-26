import Synchronization

/// 呼ぶたびに、渡した結果を先頭から順に返すクロージャを作る。
/// 渡した数より多く呼ばれたら、最後の結果を返し続ける。
///
/// モックに渡して、「1 回目は失敗、2 回目は成功」のような振る舞いを書くために使う。
func sequence<Value: Sendable>(
    _ results: Result<Value, any Error>...
) -> @Sendable () async throws -> Value {
    let remaining = Mutex(results)
    return {
        try remaining.withLock { remaining in
            remaining.count > 1 ? remaining.removeFirst() : remaining[0]
        }.get()
    }
}
