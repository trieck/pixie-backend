module jsonindex;

import std.json;
import repos;
import index;

class JSONIndexer 
{
private:
    Repository repos;   // repository instance
    Index index;        // index instance
    ushort filenum;     // current file number while indexing
    uint offset;        // offset into current file
}