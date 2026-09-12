extension Task where Success == Never, Failure == Never {
    /// `!Task.isCancelled`。guard の否定を読みやすくするためのもの。
    public static var isNotCancelled: Bool { !isCancelled }
}
