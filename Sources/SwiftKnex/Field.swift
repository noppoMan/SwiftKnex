public protocol Field {
    var alias: String? { get set }
    func `as`(_ alias: String)  -> Self
    func build() -> String
}

extension Field {
    public func `as`(_ alias: String)  -> Self {
        var new = self
        new.alias = alias
        return new
    }
}
