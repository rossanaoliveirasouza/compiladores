 (* \n a cell will live if exactly 1 of \n itself and it's immediate 
*)

-- TESTE

class Main {
    cells : CellularAutomaton;
    variavel : Bool ;
    variavelstring : String ;
   
    main() : SELF_TYPE {
        {
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        variavelstring <- "qualquer string";
                        cells.evolve();
                        cells.print();
                        variavel <-  true;
                        countdown <- countdown - 1;
                    }
                pool
            );  end let countdown
            self;
        }
    };
};


