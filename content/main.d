import std.stdio;
import std.c.process;
import jsonindex;
import timer;

int main(string[] argv)
{
    if (argv.length < 2) {
        stderr.writeln("usage: content database");
        exit(1);
    }

    Timer t = new Timer();

    writef("    elapsed time %s\n", t);

    return 0;
}
