module util.common;

import std.conv;
import std.range;

string comma(ulong l)
{
    auto output = "";

    auto rep = to!string(l);

    size_t n = rep.length;
    size_t j = n -1, k = 1;
    
    foreach(c; retro(rep)) {
        output ~= c;
        if (k % 3 == 0 && j > 0 && j < n - 1)
            output ~= ',';

        j--, k++;
    }

    output = output.reverse();

    return output;
}

string reverse(string input)
{
    auto output = "";

    foreach(c; retro(input)) {
        output ~= c;
    }

    return output;
}