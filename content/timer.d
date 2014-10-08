module timer;

import std.datetime;
import std.string : format;

class Timer 
{
private:
    StopWatch sw;
public:
    this() {
        sw.start();
    }

    override string toString() {
        string output;

        ulong diff = sw.peek().msecs;

        ulong hours = (diff / 1000) / 3600;
        ulong minutes = (diff / 1000 % 3600) / 60;
        ulong seconds = (diff / 1000) % 60;
        ulong hundredths = (diff % 1000) / 10;

        if (hours != 0) {
            output = format("%.2s:%.2s:%.2s hours", hours, minutes, seconds);
        } else if (minutes != 0) {
            output = format("%.2s:%.2s minutes", minutes, seconds);
        } else {
            output = format("%.2s:%.2s seconds", seconds, hundredths);
        }

        return output;
    }
}
