module concrecord;

import io.dstream;

class ConcordRecord
{
public:
    string term;        // record term
    uint size;          // size of anchor list
    DataStream stream;  // input stream
}
