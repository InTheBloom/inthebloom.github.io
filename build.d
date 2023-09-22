import std.file;
import core.stdc.stdlib;

void main () {
    string Separator;
    version (Windows) {
        Separator = "\\";
    } else {
        Separator = "/";
    }

    if (exists(getcwd()~Separator~"public")) {
        rmdirRecurse(getcwd()~Separator~"public");
    }
    system("hugo");
}
