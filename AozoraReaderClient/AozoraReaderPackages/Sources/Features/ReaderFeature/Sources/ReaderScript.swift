import Foundation

/// 青空文庫の HTML は 2001 年ごろの XHTML で `viewport` を持たない。
/// そのままだと PC 幅で描かれて字が読めないので、読める形に直すぶんだけ差し込む。
enum ReaderScript {
    static let css = """
    body { margin: 1.2em 1.1em 3em; line-height: 1.9; }
    .main_text { font-size: 17px; }
    .metadata { margin-bottom: 2em; }
    """

    static var source: String {
        source(css: css)
    }

    static func source(css: String) -> String {
        """
        (function () {
            var head = document.head;
            if (!head) { return; }

            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1';
            head.appendChild(meta);

            var style = document.createElement('style');
            style.textContent = \(quoted(css));
            head.appendChild(style);
        })();
        """
    }

    /// CSS を JS の文字列リテラルに埋めるので、壊す文字を潰しておく。
    private static func quoted(_ css: String) -> String {
        let escaped = css
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "'", with: "\\'")
            .replacingOccurrences(of: "\n", with: "\\n")
        return "'\(escaped)'"
    }
}
