USING Siemens.Simatic.S71500.MotionControl;
USING Siemens.Simatic.S71500.MotionControl.Native;
USING System.Timer;
NAMESPACE LibreriaMotionOOP
    CLASS PUBLIC ControlloAsseOOP
    VAR PUBLIC
        Powered     :BOOL;
        Referenced  :BOOL;
        inPosition  :BOOL;
        Error       :BOOL;
        ErrorID     :WORD;
        sStatus     :STRING;
    END_VAR

    VAR PRIVATE
        _Axis                 : itfPosAxis;
        _positioningAxis_Inst : PosAxis;
        _AxisAttached         : BOOL;
        _itfCommand           : itfCommand;
        _cmdBusy              : BOOL;
    END_VAR

    VAR CONSTANT
        TOL : LREAL := 0.5;
    END_VAR

    //-----------------------
    METHOD PUBLIC Reset
        _Axis.ResetAlarms();
        _itfCommand :=NULL;
        Powered     :=FALSE;
        Referenced  :=FALSE;
        inPosition  :=FALSE;
        Error       :=FALSE;
        ErrorID     :=FALSE;
        sStatus     :='';
    END_Method
    //------------------------
    METHOD PUBLIC Attach : BOOL
        VAR_INPUT
            Asse :DB_ANY;
        END_VAR
    IF _positioningAxis_Inst.Attach(Asse) THEN
            _Axis:=_positioningAxis_Inst;
            Attach          :=TRUE;
            _AxisAttached   :=TRUE;
    ELSE
            _AxisAttached:=FALSE;
            Attach:=FALSE;
    END_IF;
    END_METHOD
    //------------------------

    METHOD PUBLIC AxisOn:BOOL
        IF NOT _cmdBusy THEN
            _itfCommand:= _Axis.PowerON(TRUE);
            _cmdBusy        :=TRUE;
        ELSE
            if _itfCommand.Done() OR _Axis.GetStatus().enable THEN
                Powered     :=TRUE;
                _CmdBusy    :=FALSE;
                _itfCommand :=NULL;
                AxisOn      :=TRUE;
            ELSIF _itfCommand.Error() THEN
                _CmdBusy    :=FALSE;
                _itfCommand :=NULL;   
                Error       :=TRUE;
                ErrorID     :=_itfCommand.ErrorID();
                sStatus:='Errore durante la messa in coppia';
            END_IF;
        END_IF;
    END_METHOD
    //--------------------------
    METHOD PUBLIC Home:BOOL
        IF NOT _cmdBusy THEN
            _itfCommand:= _Axis.HomeDirect(Position := 0.0, Mode :=HomingModeDirect#ActualPositionAbsolute );
            _cmdBusy        :=TRUE;
            Referenced      :=FALSE;
        ELSE
            if _itfCommand.Done() AND _Axis.GetStatus().homingDone THEN
                Referenced  :=TRUE;
                _CmdBusy    :=FALSE;
                _itfCommand := NULL;
                Home            :=TRUE;
            ELSIF _itfCommand.Error() THEN
                _CmdBusy    :=FALSE;
                _itfCommand :=NULL;   
                Error       :=TRUE;
                ErrorID     :=_itfCommand.ErrorID();
                sStatus:='Errore durante la procedura di homing';
            END_IF;
        END_IF;
    END_METHOD
    //-----------------------------------------
    METHOD PUBLIC Move:BOOL
        VAR_INPUT
            Pos:LREAL;
        END_VAR

        VAR
            minPos:LREAL;
            maxPos:LREAL;
            ActualPosition:LREAL;
        END_VAR

        minPos:=Pos-TOL;
        maxPos:=Pos-TOL;
        ActualPosition:=_axis.GetPositioningAxisRef()^.ActualPosition;
        IF NOT _cmdBusy THEN
            _itfCommand:= _Axis.MoveAbsolute(Position :=Pos ,  Direction := 3);
            _cmdBusy        :=TRUE;
            inPosition      :=FALSE;
        ELSE
            if _itfCommand.Done() or 
                (minPos<ActualPosition  AND ActualPosition<maxPos)THEN
                inPosition  :=TRUE;
                _CmdBusy    :=FALSE;
                _itfCommand := NULL;
                Move            :=TRUE;
            ELSIF _itfCommand.Error() THEN
                _CmdBusy    :=FALSE;
                _itfCommand :=NULL;   
                Error       :=TRUE;
                ErrorID     :=_itfCommand.ErrorID();
                sStatus:='Errore durante il posizionamento';
            END_IF;
        END_IF;
    END_METHOD
END_CLASS  

    CLASS PUBLIC ControlloPinzaOOP
        VAR PUBLIC 
            Aperta:BOOL;
            Chiusa:BOOL;
        END_VAR

        VAR PRIVATE
            _instTimerChiudi:OnDelay;
            _instTimerApri:OnDelay;
        END_VAR

        METHOD PUBLIC Apri:BOOL
            VAR_INPUT
                timerpinza:LTIME;
            END_VAR
            Chiusa:=False;
            _instTimerApri(signal := TRUE, duration := timerPinza, output => Aperta);
            Apri:=Aperta;
            if Aperta THEN
                _instTimerApri(signal := FALSE);
            END_IF;
            ;
        END_METHOD

        METHOD PUBLIC Chiudi:BOOL
            VAR_INPUT
                timerpinza:LTIME;
            END_VAR
            Aperta:=False;
            _instTimerChiudi(signal := TRUE, duration := timerPinza, output => Chiusa);
            Chiudi:=Chiusa;
            if Aperta THEN
                _instTimerApri(signal := FALSE);
            END_IF;
            ;
        END_METHOD
            
    END_CLASS

    CLASS PUBLIC ControlloBraccioOOP
        VAR PRIVATE
            _AxCtrl :Controlloasseoop;
            _PinzaCtrl:ControlloPinzaOOP;
            _PresaBraccioState:DINT;
            _PosaBraccioState:DINT;
            _AsseAgganciato:BOOL;
        END_VAR

        VAR PUBLIC
            Errore      :BOOL;
            Stato       :STRING;
            PinzaAperta :BOOL;
            PinzaChiusa :BOOL;
            inPosAlta   :BOOL;
            inPosBassa  :BOOL;
            AsseAcceso  :BOOL;
            AsseReferenziato:BOOL;
            uscitaPinza:BOOL;
        END_VAR

        VAR CONSTANT
            PosAttesa:LREAL:=5.0;
            PosPresa:LREAL:=100.0;
        END_VAR

        METHOD PUBLIC Posa:BOOL
            CASE _PosaBraccioState OF
                0:
                    IF _AxCtrl.Move(PosPresa) THEN
                        _PosaBraccioState:=10;
                    END_IF;

                10:
                    IF _PinzaCtrl.Aperta THEN
                        _PosaBraccioState:=20;
                    ELSE
                        _PinzaCtrl.Apri(LT#500ms);
                    END_IF;

                20:
                    IF _AxCtrl.Move(PosAttesa) THEN
                        _PosaBraccioState:=30;
                    END_IF;
                30:
                    _PosaBraccioState:=0;
                    Posa:=TRUE;
            END_CASE;
        END_METHOD

        METHOD PUBLIC Prendi :BOOL
            ;
            CASE _PresaBraccioState OF
                0:
                    if _PinzaCtrl.Aperta THEN
                        _PresaBraccioState:=10;
                    ELSE
                        _PinzaCtrl.Apri(LT#500ms);
                    END_IF;

                10:
                    IF _AxCtrl.Move(PosPresa) THEN
                        _PresaBraccioState:=20;
                    END_IF;

                20:
                    IF _PinzaCtrl.Chiusa THEN
                        _PresaBraccioState:=30;
                    ELSE
                        _PinzaCtrl.Chiudi(LT#500ms);
                    END_IF;

                30:
                    IF _AxCtrl.Move(PosAttesa) THEN
                        _PresaBraccioState:=40;
                    END_IF;
                40:
                    _PresaBraccioState:=0;
                    Prendi:=TRUE;
            
            END_CASE;      
        END_METHOD
        
        //----------------------------------------------
        METHOD PUBLIC AccendiAsse
            IF _AxCtrl.AxisOn() AND _AxCtrl.Powered THEN
                AsseAcceso:=TRUE ;
            ELSIF _AxCtrl.Error THEN
                Errore:=TRUE;
                Stato:='Errore durante messa in coppia';
            END_IF;
        END_METHOD
        //---------------------------------------------
        METHOD PUBLIC vaiaHomeAsse
            IF _AxCtrl.Home() AND _AxCtrl.Referenced THEN
                AsseReferenziato:=TRUE ;
            ELSIF _AxCtrl.Error THEN
                Errore:=TRUE;
                Stato:='Errore durante Homing';
            END_IF;
            ;
        END_METHOD
        //----------------------------------------
        Method Public DefinisciAsse :BOOL
            VAR_INPUT
                Asse :DB_ANY;
            END_VAR
            IF _AxCtrl.Attach(Asse) THEN
                DefinisciAsse:=TRUE;
                _AsseAgganciato:=TRUE;
            ELSIF _AxCtrl.Error THEN
                Errore:=TRUE;
                Stato:='Errore durante definizione asse';
            END_IF;
        END_METHOD
        //-----------------------------------------
    END_CLASS

END_NAMESPACE
 

