import std.file;
import core.stdc.stdlib;
import std.stdio;
import std.string : chomp;
import std.format;

void main () {
    string Separator;
    version (Windows) {
        Separator = "\\";
    } else {
        Separator = "/";
    }

    bool doDelete = checkDeleteOrNot();

    if (exists(getcwd()~Separator~"docs") && doDelete) {
        rmdirRecurse(getcwd()~Separator~"docs");
        writeln(format("%s is cleared.", getcwd()~Separator~"docs"));
    }
    system("hugo");
}

bool checkDeleteOrNot () {
    writeln("Do you want to clear the previous directory before building the site? [Y/N]");
    stdout.flush;
    while (true) {
        auto reply = readln.chomp;
        if (reply == "Y") return true;
        if (reply == "N") return false;
        writeln("Please follow the specified format.");
    }
}
