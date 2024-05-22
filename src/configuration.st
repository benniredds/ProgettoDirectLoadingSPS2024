USING udt;
CONFIGURATION MyConfiguration
    TASK Main(Interval := T#300ms, Priority := 1);
    TASK MainOOP(Interval:=T#300ms,Priority:=2);
    PROGRAM P1 WITH Main: MyProgram;
    PROGRAM P2 WITH MainOOP:MyProgramOOP;
    {S7.extern=ReadWrite}
    {OpcUa=ReadWrite}
    VAR_GLOBAL
        start : BOOL;
        tavolaRotante : interfacciaTavola;
        braccioSx : interfacciaAsse;
        braccioDx : interfacciaAsse;
        fineCiclo : BOOL;
    END_VAR

END_CONFIGURATION
