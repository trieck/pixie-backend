module inverter;

import std.stdio: FILE;
import invrecs;
import util.prime;

class Inverter
{
public:
    this() {
        _size = Prime.prime(MAX_COUNT);
        _count = 0;
    }

    void insert(string term, ulong anchor) {
        ;
    }

    uint getCount() {
        return _count;
    }

    bool isFull() {
        return _count >= MAX_COUNT;
    }

    void write(FILE* stream) {
        compact();
        sort();
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

    enum { MAX_COUNT = 100000 } // max. number of index records
    InverterRecs _records;      // hash table of records
    uint _count;                // number of records in table
    ulong _size;                // size of hash table, should be prime
}
