import std.stdio;
import std.c.process;
import util.common;
import util.timer;
import content.defs;
import content.repos;
import io.dstream;

import std.file;

int main(string[] argv)
{    
    if (argv.length < 2) {
        stderr.writeln("usage: chkidx database");
        exit(1);
    }

    Timer t = new Timer;

    try {
        checkIndex(argv[1]);
    } catch (Exception e) {
        stderr.writeln(e.msg);
        exit(1);
    }

    writef("    elapsed time %s\n", t);

    return 0;
}

void checkIndex(string db)
{
    Repository repos = Repository.instance();

    string index = repos.getIndexPath(db);

    DataStream dis = new DataStream(index, "rb");

    uint magicno = dis.readInt();
    if (magicno != INDEX_MAGIC_NO) {
        throw new Exception("file not in index format.");
    }

    writef("    Index filename: %s\n", index);
    writef("    Index file size: %s bytes\n", comma(dis.length()));

    int nfields = dis.readInt();  // number of fields
    writef("    Index field count: %s\n", comma(nfields));

    while (nfields-- > 0) {
        dis.readUTF(); // index field
    }

    uint nterms = dis.readInt();
    writef("    Index term count: %s\n", comma(nterms));

    ulong hash_tbl_size = dis.readLong();
    writef("    Hash table size: 0x%08x\n", hash_tbl_size);

    ulong hash_tbl_offset = dis.readLong();
    writef("    Hash table offset: 0x%08x\n", hash_tbl_offset);

    // check the hash table
    dis.seek(hash_tbl_offset);

    ulong nfilled = 0;
    for (ulong i = 0; i < hash_tbl_size; i++) {
        if (dis.readLong() != 0) {
            nfilled++;
        }
    }

    writef("    Hash table fill factor: %.2f%%\n", (100 * (nfilled / cast(double) hash_tbl_size)));

    dis.close();
}