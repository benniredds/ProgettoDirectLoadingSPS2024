USING libreriaMotion;
USING LibreriaMotionOOP;
USING controllore;
USING udt;
USING Siemens.Simatic.S71500.MotionControl.Native;

PROGRAM MyProgram
    VAR_EXTERNAL
        start : BOOL;
        tavolaRotante : interfacciaTavola;
        braccioDx : interfacciaAsse;
        braccioSx : interfacciaAsse;
        fineCiclo : BOOL;
    END_VAR

    VAR
        instControlloTavolaRot : controlloAsse;
        instControlloBraccioSx : controlloBraccio;
        instControlloBraccioDx : controlloBraccio;
        instControllore : controlloreCentrale;
    END_VAR

    VAR CONSTANT
        posAxisLeftDB  : UINT := UINT#3;
        posAxisRightDB  : UINT := UINT#6;
        posAxisRotDB  : UINT := UINT#16;
    END_VAR

    VAR_TEMP
        posAxisLeftDBRef  : REF_TO TO_PositioningAxis;
        posAxisRightDBRef  : REF_TO TO_PositioningAxis;
        posAxisRotDBRef  : REF_TO TO_PositioningAxis;
    END_VAR



    instControllore(start := start,
                asseRot := tavolaRotante,
                asseDx := braccioDx,
                asseSx := braccioSx,
                cicloAutomatico => fineCiclo);

    instControlloTavolaRot(axisOn := tavolaRotante.accendi,
                            home := tavolaRotante.vaiHome,
                            goToPos1 := tavolaRotante.vaiPos1,
                            goToPos2 := tavolaRotante.vaiPos2,
                            Pos1 := 270,
                            Pos2 := 90,
                            asse := posAxisRotDB,
                            powered => tavolaRotante.acceso,
                            referenced => tavolaRotante.referenziato,
                            inPos1 => tavolaRotante.inPos1,
                            inPos2 => tavolaRotante.inPos2,
                            error => tavolaRotante.errori);

    posAxisRotDBRef := AsPositioningAxisRef(posAxisRotDB);
    tavolaRotante.posizioneAttuale := posAxisRotDBRef^.ActualPosition;
    
    instControlloBraccioSx(prendi := braccioSx.prendi,
                            posa := braccioSx.posa,
                            accendiAsse := braccioSx.accendiAsse,
                            vaiAHomeAsse := braccioSx.vaiAHomeAsse,
                            asse := posAxisLeftDB,
                            finePresa := braccioSx.fineMissionePresa,
                            finePosa := braccioSx.fineMissionePosa,
                            pinzaAperta => braccioSx.pinzaAperta,
                            pinzaChiusa => braccioSx.pinzaChiusa,
                            inPosAlta => braccioSx.inPosAlta,
                            inPosBassa => braccioSx.inPosBassa,
                            asseAcceso => braccioSx.asseAcceso,
                            asseReferenziato => braccioSx.asseReferenziato,
                            errore => braccioSx.errori);

    posAxisLeftDBRef := AsPositioningAxisRef(posAxisLeftDB);
    braccioSx.posizioneAttuale := posAxisLeftDBRef^.ActualPosition;

instControlloBraccioDx(prendi := braccioDx.prendi,
                            posa := braccioDx.posa,
                            accendiAsse := braccioDx.accendiAsse,
                            vaiAHomeAsse := braccioDx.vaiAHomeAsse,
                            asse := posAxisRightDB,
                            finePresa := braccioDx.fineMissionePresa,
                            finePosa := braccioDx.fineMissionePosa,
                            pinzaAperta => braccioDx.pinzaAperta,
                            pinzaChiusa => braccioDx.pinzaChiusa,
                            inPosAlta => braccioDx.inPosAlta,
                            inPosBassa => braccioDx.inPosBassa,
                            asseAcceso => braccioDx.asseAcceso,
                            asseReferenziato => braccioDx.asseReferenziato,
                            errore => braccioDx.errori);

    posAxisRightDBRef := AsPositioningAxisRef(posAxisRightDB);
    braccioDx.posizioneAttuale := posAxisRightDBRef^.ActualPosition;
                            

END_PROGRAM


PROGRAM MyProgramOOP
    VAR_EXTERNAL
        start : BOOL;
        tavolaRotante : interfacciaTavola;
        braccioDx : interfacciaAsse;
        braccioSx : interfacciaAsse;
        fineCiclo : BOOL;
    END_VAR

    VAR
        instControlloTavolaRot : controlloAsseOOP;
        instControlloBraccioSx : controlloBraccioOOP;
        instControlloBraccioDx : controlloBraccioOOP;
        instControllore : controlloreCentrale;

        _StateTavolaRot:DINT;
        _StateBraccioSx:DINT;
        _StateBraccioDx:DINT;
    END_VAR

    VAR CONSTANT
        posAxisLeftDB  : UINT := UINT#3;
        posAxisRightDB  : UINT := UINT#6;
        posAxisRotDB  : UINT := UINT#16;
    END_VAR

    VAR_TEMP
        posAxisLeftDBRef  : REF_TO TO_PositioningAxis;
        posAxisRightDBRef  : REF_TO TO_PositioningAxis;
        posAxisRotDBRef  : REF_TO TO_PositioningAxis;
    END_VAR



    instControllore(start := start,
                asseRot := tavolaRotante,
                asseDx := braccioDx,
                asseSx := braccioSx,
                cicloAutomatico => fineCiclo);

    


    CASE _StateTavolaRot OF
        0:
            if instControlloTavolaRot.Attach(posAxisRotDB) THEN
                _StateTavolaRot:=10;
            END_IF;
        10:
            if   tavolaRotante.accendi THEN
                if instControlloTavolaRot.AxisOn() THEN
                _StateTavolaRot:=20;
                END_IF;
            END_IF;

        20:
            if tavolaRotante.vaiHome THEN
                IF instControlloTavolaRot.Home() AND instControlloTavolaRot.Referenced THEN
                    tavolaRotante.referenziato:=TRUE;
                END_IF;
            ELsif tavolaRotante.vaipos1 THEN
                IF instControlloTavolaRot.Move(270) AND instControlloTavolaRot.inPosition THEN
                    tavolaRotante.InPos1:=TRUE;
                END_IF;
            ELsif tavolaRotante.vaipos2 THEN
                IF instControlloTavolaRot.Move(90) AND instControlloTavolaRot.inPosition THEN
                    tavolaRotante.InPos1:=TRUE;
                END_IF;
            END_IF;
    END_CASE;

    posAxisRotDBRef := AsPositioningAxisRef(posAxisRotDB);
    tavolaRotante.posizioneAttuale := posAxisRotDBRef^.ActualPosition;
    
    CASE _StateBraccioSx OF
        0:
            if instControlloBraccioSx.DefinisciAsse(posAxisLeftDB) THEN
                _StateTavolaRot:=10;
            END_IF;

        10:
            if bracciosx.accendiAsse THEN
                
                if instControlloBraccioSx.AsseAcceso THEN
                    braccioSx.asseAcceso:=TRUE;
                    _StateTavolaRot:=20;
                ELSE
                    instControlloBraccioSx.AccendiAsse();
                END_IF;
            END_IF;

        20:                
            if bracciosx.vaiAHomeAsse THEN
                IF instControlloBraccioSx.AsseReferenziato THEN
                    braccioSx.asseReferenziato:=TRUE;
                    _StateTavolaRot:=30;
                ELSE
                    instControlloBraccioSx.vaiaHomeAsse();
                END_IF;
            END_IF;

        30:
            IF (NOT bracciosx.fineMissionePosa AND braccioSx.prendi) THEN
                bracciosx.fineMissionePosa:=instControlloBraccioSx.Posa();
            ELSIF (NOT bracciosx.finemissionepresa AND braccioSx.posa) THEN
                bracciosx.fineMissionePresa:=instControlloBraccioSx.Prendi();
            END_IF;
            
            braccioSx.pinzaAperta:=instControlloBraccioSx.PinzaAperta;
            braccioSx.pinzaChiusa:=instControlloBraccioSx.PinzaChiusa;
            braccioSx.inPosAlta:=instControlloBraccioSx.inPosAlta;
            braccioSx.inPosBassa:=instControlloBraccioSx.inPosBassa;

            braccioSx.errori:=instControlloBraccioSx.Errore;
    END_CASE;


    posAxisLeftDBRef := AsPositioningAxisRef(posAxisLeftDB);
    braccioSx.posizioneAttuale := posAxisLeftDBRef^.ActualPosition;

    CASE _StateBraccioDx OF
        0:
            if instControlloBraccioDx.DefinisciAsse(posAxisRightDB) THEN
                _StateBraccioDx:=10;
            END_IF;

        10:
            if bracciodx.accendiAsse THEN
                
                if instControlloBracciodx.AsseAcceso THEN
                    bracciodx.asseAcceso:=TRUE;
                    _StateBraccioDx:=20;
                ELSE
                    instControlloBracciodx.AccendiAsse();
                END_IF;
            END_IF;

        20:                
            if braccioDx.vaiAHomeAsse THEN
                IF instControlloBraccioDx.AsseReferenziato THEN
                    braccioDx.asseReferenziato:=TRUE;
                    _StateBraccioDx:=30;
                ELSE
                    instControlloBraccioDx.vaiaHomeAsse();
                END_IF;
            END_IF;

        30:
            IF (NOT braccioDx.fineMissionePosa AND braccioDx.prendi) THEN
                braccioDx.fineMissionePosa:=instControlloBraccioDx.Posa();
            ELSIF (NOT braccioDx.finemissionepresa AND braccioDx.posa) THEN
                braccioDx.fineMissionePresa:=instControlloBraccioDx.Prendi();
            END_IF;
            
            braccioDx.pinzaAperta:=instControlloBraccioDx.PinzaAperta;
            braccioDx.pinzaChiusa:=instControlloBraccioDx.PinzaChiusa;
            braccioDx.inPosAlta:=instControlloBraccioDx.inPosAlta;
            braccioDx.inPosBassa:=instControlloBraccioDx.inPosBassa;

            braccioDx.errori:=instControlloBraccioDx.Errore;
    END_CASE;

    posAxisRightDBRef := AsPositioningAxisRef(posAxisRightDB);
    braccioDx.posizioneAttuale := posAxisRightDBRef^.ActualPosition;
                            

END_PROGRAM

