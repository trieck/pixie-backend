module jsonindex;

import std.json;
import repos;
import index;

class JSONIndexer 
{
public:
    this() {
        repos = Repository.instance();
    }

    void load(string db) {
    }

private:
    Repository repos;   // repository instance
    Index index;        // index instance
    ushort filenum;     // current file number while indexing
    uint offset;        // offset into current file
}