module index;

import std.file;
import io.dostream;
import concord;
import repos;
import indexfields;

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

    void write(string db, string[] fields) {
        // merge concordance blocks
        string concordFile = _concord.merge();

        auto outfile = _repos.getIndexPath(db);
        if (exists(outfile))
            remove(outfile);

        DataOutputStream ofile = new DataOutputStream(outfile, "wb+");

        // write file magic number
        ofile.writeInt(MAGIC_NO);

        // write the number of index fields
        ofile.writeInt(cast(int) fields.length);

        // write index fields
        foreach(field; fields) {
            ofile.writeUTF(field);
        }

        // write the total number of terms
        long term_count_offset = ofile.tell();
        ofile.writeInt(0); // not yet known
    }

private:
    enum { MAGIC_NO = 0xc001d00d }  // file magic number
    Repository _repos;               // content repository
    Concordance _concord;            // term concordance    
}
