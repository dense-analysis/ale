#include <iostream>

class Test {
 private:
    inline void dummy() {
        cout << "error";
        return;
    }
};
