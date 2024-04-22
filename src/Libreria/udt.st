NAMESPACE udt
    TYPE
        interfacciaAsse : STRUCT
            prendi : BOOL;
            posa : BOOL;
            accendiAsse : BOOL;
            vaiAHomeAsse : BOOL;
            pinzaAperta : BOOL;
            pinzaChiusa : BOOL;
            inPosAlta : BOOL;
            inPosBassa : BOOL;
            asseAcceso : BOOL;
            asseReferenziato : BOOL;
            errori : BOOL;
            fineMissionePresa : BOOL;
            fineMissionePosa : BOOL;
            posizioneAttuale : LReal;
        END_STRUCT;
    END_TYPE

    TYPE
        interfacciaTavola : STRUCT
            accendi : BOOL;
            vaiHome : BOOL;
            vaiPos1 : BOOL;
            vaiPos2 : BOOL;
            acceso : BOOL;
            referenziato : BOOL;
            inPos1 : BOOL;
            inPos2 : BOOL;
            errori : BOOL;
            posizioneAttuale : LReal;
        END_STRUCT;
    END_TYPE

END_NAMESPACE