import std.stdio;
import std.c.process;
import jsonindex;
import timer;

import std.file;

int main(string[] argv)
{    
    if (argv.length < 2) {
        stderr.writeln("usage: content database");
        exit(1);
    }

    Timer t = new Timer;

    try {
        JSONIndexer indexer = new JSONIndexer;
        indexer.load(argv[1]);
    } catch (Exception e) {
        stderr.writeln(e);
        exit(2);
    }

    writef("    elapsed time %s\n", t);

    return 0;
}
