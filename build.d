import std.file;
import core.stdc.stdlib;

void main () {
    string Separator;
    version (Windows) {
        Separator = "\\";
    } else {
        Separator = "/";
    }

    if (exists(getcwd()~Separator~"docs")) {
        rmdirRecurse(getcwd()~Separator~"docs");
    }
    system("hugo");
}
