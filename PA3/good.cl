class A {
};

Class BB__ inherits A {
};

class C {
    prop : String;
    propWithInitialization : String <- "foo";
};

class ArithmeticExpressions {
    a : Int <- 10;
    b : Int <- 20;
    c : Int <- a * b;

    io : IO <- new IO;

    main(): Object {{
        io.out_int(c);
        io.out_string("\n");
        self;
    }};
};

class Main {
    main() : Object {{
        self;
    }};
};

