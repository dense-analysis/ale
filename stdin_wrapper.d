// Author: w0rp <devw0rp@gmail.com>
// Description: This file provides a D program for implementing
//              the stdin-wrapper on Windows.

import std.algorithm;
import std.array;
import std.file;
import std.process;
import std.stdio;
import std.path;

@safe
auto createTemporaryFilename(string fileExtension) {
    import std.uuid;

    string filename;

    do {
        const randomPart = randomUUID().toString.replace("-", "_");

        filename = buildPath(tempDir(), "ale_" ~ randomPart ~ fileExtension);
    } while (exists(filename));

    return filename;
}

@trusted
void readStdinToFile(ref File tempFile) {
    stdin.byChunk(4096).copy(tempFile.lockingTextWriter());
}

// Expand program names like "csslint" to "csslint.cmd"
// D is not able to perform this kind of expanstion in spawnProcess
@safe
string expandedProgramName(string name) {
    auto extArray = environment["PATHEXT"].split(";");

    foreach(pathDir; environment["PATH"].split(";")) {
        foreach(extension; extArray) {
            const candidate = buildPath(pathDir, name ~ extension);

            if (exists(candidate)) {
                return candidate;
            }
        }
    }

    // We were given a full path for a program name, so use that.
    if (exists(name)) {
        return name;
    }

    return "";
}

@trusted
int runLinterProgram(string[] args) {
    const expandedName = expandedProgramName(args[0]);

    writeln(expandedName);

    if (expandedName) {
        return wait(spawnProcess([expandedName] ~ args[1..$]));
    }

    return 1;
}

@safe
int main(string[] args) {
    const filename = createTemporaryFilename(args[1]);

    auto tempFile = File(filename, "w");

    scope(exit) {
        tempFile.close();
        remove(filename);
    }

    readStdinToFile(tempFile);
    tempFile.close();

    return runLinterProgram(args[2..$] ~ [filename]);
}
