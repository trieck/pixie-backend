module invrec;

import std.algorithm: cmp;

class InverterRecord {
public:
    this() {
        _term = "";
        _buffer = [];
    }

    string _term;
    ulong[] _buffer;

    override int opCmp(Object rhs) const {
        if (this is rhs)
            return 0;

        auto that = cast(InverterRecord)rhs;
        if (!that) return 1;

        return cmp(this._term, that._term);
    }

}

