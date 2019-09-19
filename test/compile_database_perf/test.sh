#!/bin/bash

# Generate source files for ALE to read. They don't have to be very long, the delay is in reading compile_commands, not actually running tests
mkdir -p gen_src
for i in {1..400}; do echo "const char *GeneratedFunc${i}() { return \"Word ${i}\"; }" > gen_src/source${i}.cpp; done

# Create the compile_commands database
echo "[ {" > compile_commands.json

for i in {1..399}; do 
  {
    echo "\"command\": \"clang++ -c $(pwd)/gen_src/source${i}.cpp -o $(pwd)/build/obj/Debug/source${i}.o -MF $(pwd)/build/obj/Debug/source${i}.d -MMD -MP\","
    echo "\"directory\": \"$(pwd)/build\","
    echo "\"file\": \"$(pwd)/gen_src/source${i}.cpp\""
    echo "}, {"
  } >> compile_commands.json
done

{
  echo "\"command\": \"clang++ -c $(pwd)/gen_src/source400.cpp -o $(pwd)/build/obj/Debug/source400.o -MF $(pwd)/build/obj/Debug/source400.d -MMD -MP\","
  echo "\"directory\": \"$(pwd)/build\","
  echo "\"file\": \"$(pwd)/gen_src/source400.cpp\""
  echo "} ]"
} >> compile_commands.json

# Start up vim and switch back and forth between files -- at least one of the files must be near the bottom of compile_commands.json
time vim -c "for i in range(0,20) | edit gen_src/source10.cpp | edit gen_src/source400.cpp | endfor" \
  -c "noautocmd qa!" \
  `find . | grep "source..\.cpp"`
