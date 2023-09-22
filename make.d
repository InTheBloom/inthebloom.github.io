import std.file;
import std.stdio;
import std.string;

string Template = r"---
title: 
# description: 

date: 
# lastmod: yyyy-mm-dd
# hidedate: true

# ogimage: https://hoge/fuga/piyo.img

tags:
  - 
archives:
  - 
  - 
# sample
# - yyyy
# - yyyy-mm

# math: true
# toc: false
# build: {list: never}
---";

void main () {
    string FileName;

    FileName = getFileName();
    if (FileName.length < 3 || FileName[$-3..$] != ".md") {
        format("Your file name is \"%s\".\nIt doesn't seem to be a markdown file. Is it really ok? (Y/N)", FileName).writeln;
        while (true) {
            auto input = readln.chomp;
            if (input == "Y") break;
            if (input == "N") {
                writeln("OK. Operation is canceled.");
                return;
            }
            writeln("Answer by Y/N.");
        }
    }

    makeNewArticle(FileName);
}

string getFileName () {
    write("File Name? >");
    return readln.chomp;
}

void makeNewArticle (string FileName) {
    string Partition;
    version (Windows) {
        Partition = "\\";
    } else {
        Partition = "/";
    }

    string ContentPath = getcwd() ~ Partition ~ "content" ~ Partition ~ "post" ~ Partition ~ FileName;

    if (std.file.exists(ContentPath)) {
        stderr.writeln("File already exists!");
        return;
    }

    std.file.write(ContentPath, Template);

    writeln(format("successed! new articles is created to %s", ContentPath));
}
