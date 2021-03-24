import AdaptiveCards_bridge

class FakeInputTime: ACSTimeInput {
    public var value: String?
    public var placeholder: String?
    public var max: String?
    public var min: String?

    open override func getValue() -> String? {
        return value
    }
    
    open override func setValue(_ value: String?) {
        self.value = value
    }
    
    open override func getPlaceholder() -> String? {
        return placeholder
    }
    
    override func setPlaceholder(_ value: String) {
        placeholder = value
    }
    
    override func getMax() -> String? {
        return max
    }
    
    override func setMax(_ value: String?) {
        max = value
    }
    
    override func getMin() -> String? {
        return min
    }
    
    override func setMin(_ value: String?) {
        min = value
    }
    
    override func getId() -> String? {
        return "input-time"
    }
    
    override func getIsVisible() -> Bool {
        return true
    }
}

extension FakeInputTime {
    static func make(value: String? = "", placeholder: String? = "", max: String? = "", min: String? = "") -> FakeInputTime {
        let fakeInputTime = FakeInputTime()
        fakeInputTime.value = value
        fakeInputTime.placeholder = placeholder
        fakeInputTime.max = max
        fakeInputTime.min = min
        return fakeInputTime
    }
}
