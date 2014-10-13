module inverter;

import std.stdio;
import invrecs;
import util.prime;
import util.hash32;
import io.dostream;

class Inverter
{
public:
    this() {
        _size = cast(uint)Prime.prime(MAX_COUNT);
        _count = 0;
    }

    void insert(string term, ulong anchor) {
        if (_records is null) {
            alloc();
        }

        uint i = lookup(term);

        if (_records.isEmpty(i)) {
            _records.put(i, term);
            _count++;
        }

        _records.insert(i, anchor);
    }

    uint getCount() {
        return _count;
    }

    bool isFull() {
        return _count >= MAX_COUNT;
    }

    string term;
    ulong[] anchors;

    void write(FILE* stream) {
        compact();
        sort();

        DataOutputStream dos = new DataOutputStream(stream);

        for (auto i = 0; i < _count; ++i) {
            term = _records.getTerm(i);
            anchors = _records.getAnchors(i);

            dos.writeUTF(term);
            dos.writeInt(cast(int)anchors.length);  // size of anchor list

            foreach(anchor; anchors) {
                dos.writeLong(anchor);
            }
        }

        fflush(stream);
        clear();
    }

private:
   void compact() {
        _records.compact();
    }

    void sort() {
        _records.sort(_count);
    }

    void clear() {
        _records.clear();
        _count = 0;
    }

    void alloc() {
        _records = InverterRecs.allocate(_size);
    }

    uint lookup(string term) {

        uint i = (Hash32.hash(term) & 0x7FFFFFFF) % _size;

        while (!_records.isEmpty(i) && _records.getTerm(i) != term) {
            i = (i + 1) % _size;
        }
        
        return i;
    }

    enum { MAX_COUNT = 100000 } // max. number of index records
    InverterRecs _records;      // hash table of records
    uint _count;                // number of records in table
    uint _size;                 // size of hash table, should be prime
}
