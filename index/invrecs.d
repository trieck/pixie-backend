module invrecs;

import std.algorithm;
import invrec;

class InverterRecs
{
public:
    this() {
    }

    static InverterRecs allocate(uint size) {
        InverterRecs recs = new InverterRecs;
        recs._size = size;
        recs._records = new InverterRecord[size];
        return recs;
    }

    void compact() {
        for (size_t i = 0, j = 0; i < _records.length; i++) {
            if (_records[i] !is null) {
                continue;
            }

            for (; j < _records.length; j++) {
                if (j > i && _records[j] !is null) {
                    break;
                }
            }

            if (j >= _records.length) {
                break;
            }

            _records[i] = _records[j];
            _records[j] = null;
        }
    }

    // must be compacted first
    void sort(uint count) {
        _records[0..count].sort;
    }

    void clear() {
        for (size_t i = 0; i < _size; i++) {
            _records[i] = null;
        }
    }

    bool isEmpty(uint index) {
        return _records[index] is null;
    }

    string getTerm(uint index) {
        return _records[index]._term;
    }

    ulong[] getAnchors(uint index) {
        return _records[index]._buffer;
    }

    void put(uint index, string term) {
        assert (_records[index] is null);

        _records[index] = new InverterRecord;
        _records[index]._term = term;
    }

    void insert(uint index, ulong anchor) {
        assert (_records[index] !is null);

        auto buffer = _records[index]._buffer;
        if (buffer.length > 0) {
            if (buffer[buffer.length - 1] == anchor) {
                return; // exists
            }

            assert (buffer[buffer.length - 1] < anchor);
        }

        _records[index]._buffer ~= anchor;
    }

private:
    InverterRecord[] _records;
    size_t _size;   // size of table, should be prime
}
