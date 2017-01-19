public protocol AliasAttacheble {
    var alias: String? { get set }
    func `as`(_ alias: String)  -> Self
}

extension AliasAttacheble {
    public func `as`(_ alias: String)  -> Self {
        var new = self
        new.alias = alias
        return new
    }
}

public protocol Field: AliasAttacheble {
    func build() -> String
}
