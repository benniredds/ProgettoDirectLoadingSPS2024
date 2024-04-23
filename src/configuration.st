USING udt;
CONFIGURATION MyConfiguration
    TASK Main(Interval := T#300ms, Priority := 1);
    PROGRAM P1 WITH Main: MyProgram;

    {S7.extern=ReadWrite}
    VAR_GLOBAL
        start : BOOL;
        tavolaRotante : interfacciaTavola;
        braccioSx : interfacciaAsse;
        braccioDx : interfacciaAsse;
        fineCiclo : BOOL;
    END_VAR

END_CONFIGURATION
