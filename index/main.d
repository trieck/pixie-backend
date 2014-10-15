import std.stdio;
import std.c.process;
import xmlindex;
import util.timer;

import std.file;

int main(string[] argv)
{    
    if (argv.length < 3) {
        stderr.writeln("usage: index database fields");
        exit(1);
    }

    Timer t = new Timer;

    try {
        XMLIndexer indexer = new XMLIndexer;

        indexer.load(argv[1], argv[2..$]);
    } catch (Exception e) {
        stderr.writeln(e.msg);
        exit(2);
    }

    writef("    elapsed time %s\n", t);

    return 0;
}
