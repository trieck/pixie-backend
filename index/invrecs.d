module invrecs;

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
    }

    void sort(uint count) {
    }

    void clear() {
    }

    bool isEmpty(uint index) {
        return _records[index] is null;
    }

    string getTerm(uint index) {
        return _records[index].term;
    }

    void put(uint index, string term) {
        assert (_records[index] is null);

        _records[index] = new InverterRecord;
        _records[index].buffer = [];
        _records[index].term = term;
    }

    void insert(uint index, ulong anchor) {
        assert (!(_records[index] is null));

        ulong[] buffer = _records[index].buffer;
        if (buffer.length > 0) {
            if (buffer[buffer.length - 1] == anchor) {
                return; // exists
            }

            assert (buffer[buffer.length - 1] < anchor);
        }

        buffer ~= anchor;
    }

private:
    InverterRecord[] _records;
    int _size;   // size of table, should be prime
}
