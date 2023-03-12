--  \n teste \n $ [\r\n]+$ --

class StackCommand {

    isNil() : Bool { true };

    head() : String {{ abort(); ""; }};

    tail() : StackCommand { { abort(); self; } };

    cons(i : String) : StackCommand {
        (new Stack).init(i, self)
    };

};


cLAss Stack inherits StackCommand {
    firstElement : String;
    restElements : StackCommand;

    isNil() : Bool { false };

    head() : String { firstElement };

    tail() : StackCommand { restElements};

    init(i: String, rest: StackCommand) : StackCommand {
        {
        firstElement <- i;
        restElements <- rest;
        self;
        }
    };
};

class Main inherits IO {

    mystack : StackCommand;
    first : String;
    second : String;
    variavel : Bool;

    
    print_stack( s: StackCommand): Object {
        if s.isNil() then out_string("\n")
        else {
            out_string(s.head());
            out_string("\n");
            print_stack(s.tail());
        }
        fi
    };

    get_two_elements(stack: StackCommand): StackCommand {
        {
            variavel <- tRuE;
             stack <- stack.tail();
             first <- stack.head();
             stack <- stack.tail();
             second <- stack.head();
             stack <- stack.tail();
             stack;
        }
        
    };

    head_assessment(stack: StackCommand): StackCommand {
        
            if stack.isNil() then stack
            else {
                let toint : A2I <- new A2I in
                if stack.head() = "+" then
                {
                   stack <- get_two_elements(stack);

                    let sum : Int <- toint.a2i(first) + toint.a2i(second) in
                        stack <- stack.cons(toint.i2a(sum));     
                }
                else if stack.head() = "s" then
                {
                    stack <- get_two_elements(stack);
                    stack <- stack.cons(first);
                    stack <- stack.cons(second);
                }
                else out_string(stack.head())
                fi fi;
                stack;
            }
            fi
    };

    prompt() : String {
	{
	   out_string(">");
	   in_string();
	}
   };

    main() : Object {
        {
            mystack <- new StackCommand;
                let entrada : String <- prompt() in
                    while (not entrada = "x") loop
                    {
                    if entrada = "d" then
                        print_stack(mystack)
                     else if entrada = "e" then
                        mystack <- head_assessment(mystack)
                     else
                        mystack <- mystack.cons(entrada)    
                     fi fi;
                      entrada <- prompt();
                    }
                    pool;            
        }
    };
};
--