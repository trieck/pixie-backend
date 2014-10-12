module index;

import concord;
import repos;

class Index
{
public:
    this() {
        _concord = new Concordance;
        _repos = Repository.instance();
    }

    void insert(string term, ulong anchor) {
        _concord.insert(term, anchor);
    }

private:
    enum { MAGIC_NO = 0xc001d00d }  // file magic number
    Repository _repos;               // content repository
    Concordance _concord;            // term concordance    
}
