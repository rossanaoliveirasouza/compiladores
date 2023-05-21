class Redeclared {
};

class Redeclared {
};

class Int {
};

class SELF_TYPE {
};

class InvalidTypes {
	a : Int;
	b : Bool;

	init(x : Int, y : Bool) : InvalidTypes {
        {
            a <- y;
            b <- x;
            self;
        }
	};
};

class InvalidParameters {
    init() : SELF_TYPE {
        {
            (new InvalidTypes).init(1, 1);
            (new InvalidTypes).init(1, true, 3);
            (new InvalidTypes).init(1, true);
            (new InvalidTypes);
        }
    };
};

Class Main {
	main(): SELF_TYPE {
        {
            (new InvalidParameters).init();
        }
	};
};
