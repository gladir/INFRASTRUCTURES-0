{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/infrastructures-0)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Parking Management System
}

Program PARKING;

Uses {$IFDEF FPC}
      Crt,Dos,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      Crt,Dos,Graph
     {$ENDIF};

Procedure InitializeGraphics;
Var
 Driver, Mode: Integer;
 ErrCode: Integer;
Begin
 {$IFDEF FPC}
  Driver:=VGA;
  Mode:=VGAHi;
 {$ELSE}
  Driver:=Detect;
  Mode:=VGAHi;
 {$ENDIF}
 InitGraph(Driver,Mode,'');
 ErrCode:=GraphResult;
 If ErrCode=grOk Then Begin
  SetColor(White);
  SetLineStyle(0,0,1);
 End
  Else
 Begin
  WriteLn('Erreur graphique : ',GraphErrorMsg(ErrCode));
  Halt;
 End;
End;

{$IFNDEF FPC}
 Function MouseDriverFound: Boolean;
 Var
  Regs: Registers;
 Begin
  Regs.AX := 0;
  Intr($33, Regs);
  MouseDriverFound := Regs.AX = $FFFF;
 End;

 Procedure ShowMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0001;
  Intr($33, Regs);
 End;

 Procedure HideMouse;
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0002;
  Intr($33, Regs);
 End;

 Procedure GetMouseState(Var X, Y, Button: LongInt);
 Var
  Regs: Registers;
 Begin
  Regs.AX := $0003;
  Intr($33, Regs);
  Button := Regs.BX;
  X := Regs.CX;
  Y := Regs.DX;
 End;
{$ELSE}
 Function MouseDriverFound: Boolean;
 Begin
  MouseDriverFound := True;
 End;

 Procedure ShowMouse;
 Begin
  { Pas d'implémentation pour Free Pascal }
 End;

 Procedure HideMouse;
 Begin
  { Pas d'implémentation pour Free Pascal }
 End;
{$ENDIF}

{ ============================================================
  CONSTANTES GLOBALES
  ============================================================ }

Const
 PARKING_VERSION      = '1.00';
 PARKING_DATE         = '2026-05-31';

 SCREEN_W             = 640;
 SCREEN_H             = 480;
 MENUBAR_HEIGHT       = 20;
 STATUSBAR_HEIGHT     = 36;

 MAX_MENUS            = 10;
 MAX_MENU_ITEMS       = 16;

 MAX_COLS             = 20;
 MAX_ROWS             = 14;
 MAX_SPOTS            = MAX_COLS * MAX_ROWS;     { 280 }

 MAX_DURATIONS        = 9;
 MAX_HISTORY          = 256;
 MAX_DAILY            = 31;

 { Modules etendus }
 MAX_TARIFFS          = 8;        { zones tarifaires }
 MAX_SUBSCRIPTIONS    = 100;      { abonnements clients }
 MAX_CHART_POINTS     = 31;       { points pour graphique }
 MAX_REPORT_LINES     = 96;       { lignes texte pour rapports }
 MAX_HIST_VIEW        = 256;      { entrees affichables dans historique }
 MAX_FILTER_PLATE     = 15;       { longueur filtre plaque }

 { Types abonnement }
 SUB_WEEKLY           = 0;
 SUB_MONTHLY          = 1;
 SUB_QUARTERLY        = 2;
 SUB_YEARLY           = 3;
 SUB_TYPES            = 4;

 { Codes des zones tarifaires par defaut }
 TZ_DAY               = 0;
 TZ_NIGHT             = 1;
 TZ_WEEKEND           = 2;
 TZ_HOLIDAY           = 3;

 { Masques de jour pour les zones tarifaires (bit = jour) }
 DAY_MON              = 1;
 DAY_TUE              = 2;
 DAY_WED              = 4;
 DAY_THU              = 8;
 DAY_FRI              = 16;
 DAY_SAT              = 32;
 DAY_SUN              = 64;
 DAY_WEEKDAYS         = 31;       { 1+2+4+8+16 }
 DAY_WEEKEND          = 96;       { 32+64 }
 DAY_ALL              = 127;

 { Types de transaction (champ Kind) }
 TXK_RESERVE          = 0;
 TXK_RELEASE          = 1;
 TXK_EXTEND           = 2;
 TXK_SUB_NEW          = 3;
 TXK_SUB_RENEW        = 4;

 { Palette VGA 16 couleurs }
 CLR_BACKGROUND       = LightGray;
 CLR_TITLEBAR         = Blue;
 CLR_TITLEBAR_TEXT    = White;
 CLR_MENUBAR          = LightGray;
 CLR_MENU_HIGHLIGHT   = Blue;
 CLR_MENU_TEXT        = Black;
 CLR_BORDER           = DarkGray;
 CLR_BORDER_LIGHT     = White;
 CLR_DIALOG_BG        = LightGray;
 CLR_DIALOG_TEXT      = Black;
 CLR_BUTTON_FACE      = LightGray;
 CLR_BUTTON_TEXT      = Black;
 CLR_BUTTON_FOCUS     = Blue;
 CLR_BUTTON_DEFAULT   = Black;
 CLR_EDIT_BG          = White;
 CLR_EDIT_TEXT        = Black;
 CLR_EDIT_FOCUS_BG    = White;
 CLR_EDIT_FOCUS_TEXT  = Black;
 CLR_LABEL            = Black;
 CLR_GRID_BG          = White;
 CLR_SPOT_FREE        = LightGreen;
 CLR_SPOT_OCCUPIED    = LightRed;
 CLR_SPOT_EXPIRING    = Yellow;
 CLR_SPOT_EXPIRED     = Red;
 CLR_SPOT_RESERVED    = LightCyan;
 CLR_SPOT_TEXT        = Black;
 CLR_SPOT_BORDER      = Black;
 CLR_CAR              = Blue;
 CLR_CAR_WINDOW       = LightCyan;
 CLR_STATUS_BG        = DarkGray;
 CLR_STATUS_TEXT      = White;
 CLR_STATUS_OK        = LightGreen;
 CLR_STATUS_WARN      = Yellow;
 CLR_STATUS_BAD       = LightRed;
 CLR_REVENUE          = Yellow;
 CLR_SHADOW           = DarkGray;

 { Identifiants de menu }
 TAG_FILE_NEW         = 110;
 TAG_FILE_OPEN        = 111;
 TAG_FILE_SAVE        = 112;
 TAG_FILE_SAVEAS      = 113;
 TAG_FILE_QUIT        = 199;

 TAG_EDIT_CONFIG      = 210;
 TAG_EDIT_PRICING     = 211;
 TAG_EDIT_FREEALL     = 212;

 TAG_PARK_RESERVE     = 310;
 TAG_PARK_FREE        = 311;
 TAG_PARK_INFO        = 312;
 TAG_PARK_SEARCH      = 313;
 TAG_PARK_EXTEND      = 314;
 TAG_PARK_FORCE       = 315;

 TAG_STAT_OCCUPY      = 410;
 TAG_STAT_REVENUE     = 411;
 TAG_STAT_HISTORY     = 412;
 TAG_STAT_DURATIONS   = 413;

 TAG_VIEW_REFRESH     = 510;
 TAG_VIEW_ZOOM_NORM   = 511;

 TAG_HELP_ABOUT       = 910;
 TAG_HELP_KEYS        = 911;
 TAG_HELP_USAGE       = 912;

 { --- Modules etendus --- }
 { Menu Abonnements }
 TAG_SUB_LIST         = 1010;
 TAG_SUB_ADD          = 1011;
 TAG_SUB_RENEW        = 1012;
 TAG_SUB_DELETE       = 1013;
 TAG_SUB_SEARCH       = 1014;
 TAG_SUB_PRICES       = 1015;

 { Menu Tarifs etendus }
 TAG_TARIFF_ZONES     = 1110;
 TAG_TARIFF_TOGGLE    = 1111;
 TAG_TARIFF_RESET     = 1112;
 TAG_TARIFF_PREVIEW   = 1113;

 { Menu Rapports / Export }
 TAG_REPORT_DAILY     = 1410;
 TAG_REPORT_WEEKLY    = 1411;
 TAG_REPORT_MONTHLY   = 1412;
 TAG_REPORT_SUBS      = 1413;
 TAG_REPORT_OCCUPANCY = 1414;

 { Menu CSV }
 TAG_CSV_TRANS        = 1210;
 TAG_CSV_SUBS         = 1211;
 TAG_CSV_SPOTS        = 1212;
 TAG_CSV_DAILY        = 1213;
 TAG_CSV_PRICING      = 1214;
 TAG_CSV_ALL          = 1215;

 { Menu Graphiques }
 TAG_GRAPH_DAILY      = 1310;
 TAG_GRAPH_MONTHLY    = 1311;
 TAG_GRAPH_BYDUR      = 1312;
 TAG_GRAPH_OCCUPY     = 1313;
 TAG_GRAPH_SUBS       = 1314;
 TAG_GRAPH_HOURS      = 1315;

 { Historique avance }
 TAG_HIST_FILTER      = 1510;
 TAG_HIST_CLEAR       = 1511;
 TAG_HIST_EXPORT      = 1512;

 { Codes de duree (indice dans le tableau Pricing) }
 DUR_1H               = 0;
 DUR_2H               = 1;
 DUR_3H               = 2;
 DUR_8H               = 3;
 DUR_12H              = 4;
 DUR_24H              = 5;
 DUR_2D               = 6;
 DUR_7D               = 7;
 DUR_1M               = 8;

 { Largeur fixe d'un caractere du jeu par defaut 8x8 }
 CHARW                = 8;
 CHARH                = 8;

 { Bin BMP magique pour signature de fichier }
 PARK_FILE_MAGIC      = 'PARKINGv1';

{ ============================================================
  TYPES
  ============================================================ }

Type
 TStr15  = String[15];
 TStr31  = String[31];
 TStr63  = String[63];
 TStr127 = String[127];

 { Date et heure simple, lisible (pas Unix epoch). }
 TDateTime = Record
  Year   : Word;
  Month  : Byte;     { 1..12 }
  Day    : Byte;     { 1..31 }
  Hour   : Byte;     { 0..23 }
  Min    : Byte;     { 0..59 }
 End;

 { Etat d un stationnement }
 TSpotState = (ssFree, ssOccupied);

 { Code de duree de reservation }
 TDurCode = 0..8;     { DUR_1H .. DUR_1M }

 { Description d une duree de reservation }
 TDurationInfo = Record
  Code   : TDurCode;
  Label_ : String[20];
  Hours  : LongInt;        { en heures }
  Price  : Real;
 End;

 { Un stationnement individuel }
 TSpot = Record
  State    : TSpotState;
  Plate    : TStr15;       { plaque d immatriculation }
  Owner    : TStr31;       { nom proprietaire }
  Phone    : TStr15;       { telephone (optionnel) }
  StartDT  : TDateTime;    { debut reservation }
  EndDT    : TDateTime;    { fin reservation prevue }
  DurCode  : TDurCode;
  Paid     : Real;         { montant paye }
 End;

 { Evenements }
 TEventKind = (EV_NONE, EV_MOUSE_MOVE, EV_MOUSE_DOWN, EV_MOUSE_UP,
               EV_MOUSE_DBLCLICK, EV_KEY_DOWN, EV_KEY_CHAR, EV_TIMER);

 TMouseButton = (MB_NONE, MB_LEFT, MB_RIGHT, MB_MIDDLE);

 TEvent = Record
  Kind       : TEventKind;
  MouseX     : Integer;
  MouseY     : Integer;
  MouseBtn   : TMouseButton;
  KeyCode    : Word;
  KeyChar    : Char;
  Timestamp  : LongInt;
 End;

 { Menus (porte de GEANT4.PAS) }
 TMenuItem = Record
  Caption    : String[31];
  ShortCut   : String[15];
  Enabled    : Boolean;
  Checked    : Boolean;
  Separator  : Boolean;
  Tag        : LongInt;
 End;

 TMenu = Record
  Title      : String[15];
  Items      : Array[0..MAX_MENU_ITEMS - 1] Of TMenuItem;
  ItemCount  : Integer;
  X          : Integer;
  Width      : Integer;
 End;

 TMenuBar = Record
  Menus      : Array[0..MAX_MENUS - 1] Of TMenu;
  MenuCount  : Integer;
  Y          : Integer;
  Height     : Integer;
 End;

 { Transaction (historique) }
 TTransaction = Record
  Plate    : TStr15;
  Owner    : TStr31;
  StartDT  : TDateTime;
  EndDT    : TDateTime;
  Paid     : Real;
  SpotIdx  : Integer;
  Kind     : Byte;        { 0=reservation, 1=liberation, 2=extension }
 End;

 { Statistiques quotidiennes }
 TDailyStat = Record
  Date     : TDateTime;   { jour seulement }
  Revenue  : Real;
  Reservations : Integer;
  Released : Integer;
 End;

 { ----- Modules etendus ----- }

 { Zone tarifaire : applique un multiplicateur sur la grille de base }
 TTariffZone = Record
  Name       : String[20];
  StartHour  : Byte;     { 0..23 inclus }
  EndHour    : Byte;     { 0..23 exclus.  Si EndHour < StartHour : nuit }
  DayMask    : Byte;     { bitset DAY_MON..DAY_SUN }
  Multiplier : Real;     { 1.0 = base }
  Enabled    : Boolean;
 End;

 { Type d abonnement (hebdo, mensuel, trimestriel, annuel) }
 TSubType = Byte;

 TSubscription = Record
  Active     : Boolean;
  ID         : LongInt;
  SubType    : TSubType;
  Name       : TStr31;
  Plate      : TStr15;
  Phone      : TStr15;
  Email      : String[47];
  StartDT    : TDateTime;
  EndDT      : TDateTime;
  AmountPaid : Real;
  AssignedSpot : Integer;     { -1 si pas de place attitree }
  AutoRenew  : Boolean;
  RenewCount : Integer;
 End;

 { Criteres pour filtrer l historique }
 TFilterCriteria = Record
  HasDateRange : Boolean;
  FromDT       : TDateTime;
  ToDT         : TDateTime;
  PlateFrag    : TStr15;        { sous-chaine, '' = pas de filtre }
  KindMask     : Byte;          { bit 0=reserve, 1=release, etc. }
  SpotFrom     : Integer;       { -1 = pas de filtre }
  SpotTo       : Integer;
  MinAmount    : Real;
 End;

 { Un point pour graphique (barre / ligne / part) }
 TChartPoint = Record
  Label_     : String[15];
  Value      : Real;
  Color      : Byte;
 End;

 TChartArray = Array[0..MAX_CHART_POINTS - 1] Of TChartPoint;

 { Tableau de lignes texte pour rapports / aper\E7us }
 TReportLine  = String[78];
 TReportArray = Array[0..MAX_REPORT_LINES - 1] Of TReportLine;

 { Tarification specifique aux abonnements (par type) }
 TSubPricing = Record
  Label_   : String[20];
  Days     : LongInt;      { duree en jours }
  Price    : Real;
 End;

{ ============================================================
  VARIABLES GLOBALES
  ============================================================ }

Var
 { Etat de l application }
 QuitRequested  : Boolean;
 DirtyDisplay   : Boolean;
 CurrentFile    : String;

 { Souris }
 PrevMouseX     : Integer;
 PrevMouseY     : Integer;
 PrevMouseBtn   : LongInt;
 LastClickX     : Integer;
 LastClickY     : Integer;
 LastClickTime  : LongInt;
 LastClickBtn   : TMouseButton;

 { Barre de menus }
 MainMenuBar    : TMenuBar;
 OpenMenuIdx    : Integer;
 SelItemIdx     : Integer;
 MenuActive     : Boolean;
 MenuBgBuf      : Pointer;
 MenuBgX1, MenuBgY1, MenuBgX2, MenuBgY2 : Integer;
 MenuBgSaved    : Boolean;

 { Parking }
 ColCount       : Integer;        { 1..MAX_COLS }
 RowCount       : Integer;        { 1..MAX_ROWS }
 Spots          : Array[0..MAX_SPOTS - 1] Of TSpot;

 { Tarification }
 Pricing        : Array[0..MAX_DURATIONS - 1] Of TDurationInfo;

 { Compteurs en temps reel }
 CntFree        : Integer;
 CntOccupied    : Integer;
 CntExpiring    : Integer;
 CntExpired     : Integer;

 { Revenu journalier }
 DailyRevenue   : Real;
 DailyDate      : TDateTime;
 DailyReservations : Integer;
 DailyReleases  : Integer;

 { Historique (revenu par jour, derniers MAX_DAILY) }
 DailyStats     : Array[0..MAX_DAILY - 1] Of TDailyStat;
 DailyStatsCnt  : Integer;

 { Historique de transactions (anneau) }
 Transactions   : Array[0..MAX_HISTORY - 1] Of TTransaction;
 TransCnt       : Integer;        { nb total inseres, peut depasser MAX }
 TransHead      : Integer;        { position d insertion suivante }

 { Heure courante (rafraichie periodiquement) }
 NowDT          : TDateTime;
 LastClockSec   : LongInt;

 { Surlignement hover sur la grille }
 HoverSpot      : Integer;        { -1 si aucun }

 { Texte sauvegarde en tooltip (1 ligne) }
 TooltipText    : String[63];
 TooltipX, TooltipY : Integer;
 TooltipVisible : Boolean;

 { Zone parking (calculee selon ColCount/RowCount) }
 GridX, GridY, GridW, GridH : Integer;
 SpotW, SpotH               : Integer;

 { --- Modules etendus : globales --- }

 { Zones tarifaires actives }
 TariffZones    : Array[0..MAX_TARIFFS - 1] Of TTariffZone;
 TariffCount    : Integer;
 TariffEnabled  : Boolean;        { active/desactive le systeme global }

 { Abonnements clients }
 Subs           : Array[0..MAX_SUBSCRIPTIONS - 1] Of TSubscription;
 SubsCount      : Integer;
 NextSubID      : LongInt;

 { Tarifs abonnement }
 SubPricing     : Array[0..SUB_TYPES - 1] Of TSubPricing;

 { Dernier filtre d historique (memorise entre ouvertures) }
 LastFilter     : TFilterCriteria;

 { Repertoire de travail pour les exports }
 ExportDir      : String[63];

{ ============================================================
  UTILITAIRES DE BASE
  ============================================================ }

Function ScreenWidth: Integer;
Begin ScreenWidth := GetMaxX + 1; End;

Function ScreenHeight: Integer;
Begin ScreenHeight := GetMaxY + 1; End;

Function IMin(A, B: Integer): Integer;
Begin If A < B Then IMin := A Else IMin := B; End;

Function IMax(A, B: Integer): Integer;
Begin If A > B Then IMax := A Else IMax := B; End;

Function IClamp(V, Lo, Hi: Integer): Integer;
Begin
 If V < Lo Then IClamp := Lo
 Else If V > Hi Then IClamp := Hi
 Else IClamp := V;
End;

Function RMin(A, B: Real): Real;
Begin If A < B Then RMin := A Else RMin := B; End;

Function RMax(A, B: Real): Real;
Begin If A > B Then RMax := A Else RMax := B; End;

Function IntToStr(N: LongInt): String;
Var S: String;
Begin Str(N, S); IntToStr := S; End;

Function IntToStrW(N: LongInt; W: Integer): String;
Var S: String;
Begin Str(N:W, S); IntToStrW := S; End;

Function IntToStrPad(N: LongInt; W: Integer): String;
Var S: String;
Begin
 Str(N, S);
 While Length(S) < W Do S := '0' + S;
 IntToStrPad := S;
End;

Function RealToStr(R: Real; Width, Prec: Integer): String;
Var S: String;
Begin
 Str(R:Width:Prec, S);
 While (Length(S) > 0) And (S[1] = ' ') Do Delete(S, 1, 1);
 RealToStr := S;
End;

Function MoneyStr(R: Real): String;
Begin MoneyStr := RealToStr(R, 1, 2) + ' $'; End;

Function PadLeft(S: String; W: Integer): String;
Begin
 While Length(S) < W Do S := ' ' + S;
 PadLeft := S;
End;

Function PadRight(S: String; W: Integer): String;
Begin
 While Length(S) < W Do S := S + ' ';
 PadRight := S;
End;

Function UpStr(S: String): String;
Var I: Integer;
Begin
 For I := 1 To Length(S) Do S[I] := UpCase(S[I]);
 UpStr := S;
End;

Function TrimStr(S: String): String;
Begin
 While (Length(S) > 0) And ((S[1] = ' ') Or (S[1] = #9)) Do
  Delete(S, 1, 1);
 While (Length(S) > 0) And
       ((S[Length(S)] = ' ') Or (S[Length(S)] = #9) Or
        (S[Length(S)] = #13) Or (S[Length(S)] = #10)) Do
  Delete(S, Length(S), 1);
 TrimStr := S;
End;

Function StrToIntDef(S: String; Def: LongInt): LongInt;
Var N: LongInt; Code: Integer;
Begin
 S := TrimStr(S);
 If S = '' Then Begin StrToIntDef := Def; Exit; End;
 Val(S, N, Code);
 If Code = 0 Then StrToIntDef := N Else StrToIntDef := Def;
End;

Function StrToRealDef(S: String; Def: Real): Real;
Var R: Real; Code: Integer;
Begin
 S := TrimStr(S);
 If S = '' Then Begin StrToRealDef := Def; Exit; End;
 Val(S, R, Code);
 If Code = 0 Then StrToRealDef := R Else StrToRealDef := Def;
End;

Function GetTimestamp: LongInt;
Var H, M, S, S100: Word;
Begin
 GetTime(H, M, S, S100);
 GetTimestamp := (LongInt(H) * 3600000) +
                 (LongInt(M) * 60000) +
                 (LongInt(S) * 1000) +
                 (LongInt(S100) * 10);
End;

{ ============================================================
  GESTION DE LA DATE / HEURE
  ============================================================ }

Function IsLeap(Y: Word): Boolean;
Begin
 IsLeap := ((Y Mod 4 = 0) And (Y Mod 100 <> 0)) Or (Y Mod 400 = 0);
End;

Function DaysInMonth(Y: Word; M: Byte): Byte;
Begin
 Case M Of
  1, 3, 5, 7, 8, 10, 12: DaysInMonth := 31;
  4, 6, 9, 11:           DaysInMonth := 30;
  2: If IsLeap(Y) Then DaysInMonth := 29 Else DaysInMonth := 28;
  Else DaysInMonth := 30;
 End;
End;

Procedure GetCurrentDT(Var DT: TDateTime);
Var Y, M, D, DOW: Word;
    H, Mi, S, MS: Word;
Begin
 GetDate(Y, M, D, DOW);
 GetTime(H, Mi, S, MS);
 DT.Year := Y; DT.Month := M; DT.Day := D;
 DT.Hour := H; DT.Min  := Mi;
End;

Function SameDay(Const A, B: TDateTime): Boolean;
Begin
 SameDay := (A.Year = B.Year) And (A.Month = B.Month) And (A.Day = B.Day);
End;

Function CompareDT(Const A, B: TDateTime): Integer;
{ Retourne -1 si A<B, 0 si =, +1 si A>B }
Begin
 If A.Year  < B.Year  Then Begin CompareDT := -1; Exit; End;
 If A.Year  > B.Year  Then Begin CompareDT :=  1; Exit; End;
 If A.Month < B.Month Then Begin CompareDT := -1; Exit; End;
 If A.Month > B.Month Then Begin CompareDT :=  1; Exit; End;
 If A.Day   < B.Day   Then Begin CompareDT := -1; Exit; End;
 If A.Day   > B.Day   Then Begin CompareDT :=  1; Exit; End;
 If A.Hour  < B.Hour  Then Begin CompareDT := -1; Exit; End;
 If A.Hour  > B.Hour  Then Begin CompareDT :=  1; Exit; End;
 If A.Min   < B.Min   Then Begin CompareDT := -1; Exit; End;
 If A.Min   > B.Min   Then Begin CompareDT :=  1; Exit; End;
 CompareDT := 0;
End;

Procedure AddMinutes(Var DT: TDateTime; M: LongInt);
Var Tot: LongInt;
Begin
 Tot := DT.Min + M;
 While Tot >= 60 Do Begin
  Inc(DT.Hour); Dec(Tot, 60);
  If DT.Hour >= 24 Then Begin
   DT.Hour := 0; Inc(DT.Day);
   If DT.Day > DaysInMonth(DT.Year, DT.Month) Then Begin
    DT.Day := 1; Inc(DT.Month);
    If DT.Month > 12 Then Begin DT.Month := 1; Inc(DT.Year); End;
   End;
  End;
 End;
 While Tot < 0 Do Begin
  If DT.Hour = 0 Then Begin
   DT.Hour := 23;
   If DT.Day = 1 Then Begin
    If DT.Month = 1 Then Begin DT.Month := 12; Dec(DT.Year); End
    Else Dec(DT.Month);
    DT.Day := DaysInMonth(DT.Year, DT.Month);
   End Else Dec(DT.Day);
  End Else Dec(DT.Hour);
  Inc(Tot, 60);
 End;
 DT.Min := Tot;
End;

Procedure AddHours(Var DT: TDateTime; H: LongInt);
Begin AddMinutes(DT, H * 60); End;

Procedure AddDays(Var DT: TDateTime; D: LongInt);
Var I: LongInt;
Begin
 For I := 1 To D Do Begin
  Inc(DT.Day);
  If DT.Day > DaysInMonth(DT.Year, DT.Month) Then Begin
   DT.Day := 1; Inc(DT.Month);
   If DT.Month > 12 Then Begin DT.Month := 1; Inc(DT.Year); End;
  End;
 End;
End;

Procedure AddMonths(Var DT: TDateTime; M: LongInt);
Var I: LongInt;
Begin
 For I := 1 To M Do Begin
  Inc(DT.Month);
  If DT.Month > 12 Then Begin DT.Month := 1; Inc(DT.Year); End;
 End;
 If DT.Day > DaysInMonth(DT.Year, DT.Month) Then
  DT.Day := DaysInMonth(DT.Year, DT.Month);
End;

Function MinutesBetween(Const A, B: TDateTime): LongInt;
{ Difference B - A en minutes (peut etre negatif). }
Var DT: TDateTime; M: LongInt; Cmp: Integer; Neg: Boolean;
Begin
 Cmp := CompareDT(A, B);
 If Cmp = 0 Then Begin MinutesBetween := 0; Exit; End;
 Neg := Cmp > 0;
 If Neg Then Begin
  DT := B;
  M := 0;
  While Not SameDay(DT, A) Do Begin
   AddDays(DT, 1); M := M + 24 * 60;
  End;
  M := M + (LongInt(A.Hour) - DT.Hour) * 60 +
           (LongInt(A.Min) - DT.Min);
  MinutesBetween := -M;
 End Else Begin
  DT := A;
  M := 0;
  While Not SameDay(DT, B) Do Begin
   AddDays(DT, 1); M := M + 24 * 60;
  End;
  M := M + (LongInt(B.Hour) - DT.Hour) * 60 +
           (LongInt(B.Min) - DT.Min);
  MinutesBetween := M;
 End;
End;

Function MinutesBetween_Internal(Const A, B: TDateTime): LongInt;
Begin
 MinutesBetween_Internal := MinutesBetween(A, B);
End;

Function MonthName(M: Byte): String;
Begin
 Case M Of
  1 : MonthName := 'jan'; 2 : MonthName := 'fev'; 3 : MonthName := 'mar';
  4 : MonthName := 'avr'; 5 : MonthName := 'mai'; 6 : MonthName := 'jun';
  7 : MonthName := 'jul'; 8 : MonthName := 'aou'; 9 : MonthName := 'sep';
  10: MonthName := 'oct'; 11: MonthName := 'nov'; 12: MonthName := 'dec';
  Else MonthName := '???';
 End;
End;

Function FormatDate(Const DT: TDateTime): String;
Begin
 FormatDate := IntToStrPad(DT.Year, 4) + '-' +
               IntToStrPad(DT.Month, 2) + '-' +
               IntToStrPad(DT.Day, 2);
End;

Function FormatTime(Const DT: TDateTime): String;
Begin
 FormatTime := IntToStrPad(DT.Hour, 2) + ':' + IntToStrPad(DT.Min, 2);
End;

Function FormatDateTime(Const DT: TDateTime): String;
Begin
 FormatDateTime := FormatDate(DT) + ' ' + FormatTime(DT);
End;

Function FormatDurationMin(M: LongInt): String;
Var D, H, Mn: LongInt;
Begin
 If M < 0 Then Begin FormatDurationMin := '-' + FormatDurationMin(-M); Exit; End;
 D  := M Div (24 * 60);
 H  := (M Mod (24 * 60)) Div 60;
 Mn := M Mod 60;
 If D > 0 Then
  FormatDurationMin := IntToStr(D) + 'j ' +
                       IntToStrPad(H, 2) + 'h' +
                       IntToStrPad(Mn, 2)
 Else If H > 0 Then
  FormatDurationMin := IntToStrPad(H, 2) + 'h' + IntToStrPad(Mn, 2)
 Else
  FormatDurationMin := IntToStr(Mn) + ' min';
End;

{ Forward declarations dont on a besoin tot }
Procedure RedrawAll; Forward;
Procedure DrawMenuBar; Forward;
Procedure DrawStatusBar; Forward;
Procedure DrawParkingGrid; Forward;
Procedure ExecuteMenuItem(Var Item: TMenuItem); Forward;
Procedure UpdateCounters; Forward;
Procedure RecordTransaction(APlate: TStr15; AOwner: TStr31;
                            Const SD, ED: TDateTime;
                            APaid: Real; ASpotIdx: Integer;
                            AKind: Byte); Forward;
Function  ComputePrice(DurCode: TDurCode): Real; Forward;
Function  CountByState(State: TSpotState): Integer; Forward;
Function  ComputeRemainingMin(Idx: Integer): LongInt; Forward;
Procedure RebuildDailyStatsFromHistory; Forward;
Procedure ShowMessageBox(Title, Msg: String); Forward;
Function  ShowConfirmBox(Title, Msg: String): Boolean; Forward;

{ --- Forward decls modules etendus --- }
Function  ComputeFinalPrice(BaseCode: TDurCode;
                            Const StartDT: TDateTime): Real; Forward;
Function  GetTariffZoneIdx(Const DT: TDateTime): Integer; Forward;
Procedure InitDefaultTariffs; Forward;
Procedure InitDefaultSubPricing; Forward;
Procedure InitSubscriptions; Forward;
Function  FindActiveSubByPlate(Const APlate: TStr15): Integer; Forward;
Function  IsSubActive(Const S: TSubscription): Boolean; Forward;
Procedure CheckExpiredSubs; Forward;
Procedure DrawBarChart(X1, Y1, X2, Y2: Integer;
                       Var Pts: TChartArray; Count: Integer;
                       Title: String); Forward;
Procedure DrawPieChart(CX, CY, Radius: Integer;
                       Var Pts: TChartArray; Count: Integer); Forward;
Procedure DrawLineChart(X1, Y1, X2, Y2: Integer;
                        Var Pts: TChartArray; Count: Integer;
                        Title: String); Forward;
Function  CSVField(S: String): String; Forward;
Procedure ShowReportDialog(Title: String;
                           Var Lines: TReportArray;
                           Count: Integer); Forward;

{ Dialogues exposes a ExecuteMenuItem (defini plus haut que les modules etendus) }
Procedure DlgConfigureTariffs; Forward;
Procedure DlgToggleTariffs; Forward;
Procedure DlgPreviewTariffs; Forward;
Procedure DlgAddSubscription; Forward;
Procedure DlgListSubscriptions; Forward;
Procedure DlgRenewSubscription; Forward;
Procedure DlgDeleteSubscription; Forward;
Procedure DlgSearchSubscription; Forward;
Procedure DlgConfigureSubPricing; Forward;
Procedure DlgFilterHistory; Forward;
Procedure DlgDetailedHistory; Forward;
Procedure DlgReportDaily; Forward;
Procedure DlgReportWeekly; Forward;
Procedure DlgReportMonthly; Forward;
Procedure DlgReportSubs; Forward;
Procedure DlgReportOccupancy; Forward;
Procedure DlgGraphDailyRevenue; Forward;
Procedure DlgGraphMonthlyTrend; Forward;
Procedure DlgGraphByDuration; Forward;
Procedure DlgGraphOccupancy; Forward;
Procedure DlgGraphSubs; Forward;
Procedure DlgGraphHourlyActivity; Forward;
Procedure DlgExportCSV(Kind: Integer); Forward;

{ ============================================================
  DESSIN UTILITAIRE (boites 3D, ombres, texte centre)
  ============================================================ }

Procedure FillRect(X1, Y1, X2, Y2, Color: Integer);
Begin
 SetFillStyle(SolidFill, Color);
 Bar(X1, Y1, X2, Y2);
End;

Procedure DrawRect(X1, Y1, X2, Y2, Color: Integer);
Begin
 SetColor(Color);
 Rectangle(X1, Y1, X2, Y2);
End;

Procedure DrawHLine(X1, X2, Y, Color: Integer);
Begin SetColor(Color); Line(X1, Y, X2, Y); End;

Procedure DrawVLine(X, Y1, Y2, Color: Integer);
Begin SetColor(Color); Line(X, Y1, X, Y2); End;

Procedure DrawBox3D(X1, Y1, X2, Y2: Integer; Raised: Boolean;
                    FaceColor: Integer);
Var Hi, Lo: Integer;
Begin
 If Raised Then Begin
  Hi := CLR_BORDER_LIGHT;
  Lo := CLR_BORDER;
 End Else Begin
  Hi := CLR_BORDER;
  Lo := CLR_BORDER_LIGHT;
 End;
 FillRect(X1 + 1, Y1 + 1, X2 - 1, Y2 - 1, FaceColor);
 DrawHLine(X1, X2, Y1, Hi);
 DrawVLine(X1, Y1, Y2, Hi);
 DrawHLine(X1, X2, Y2, Lo);
 DrawVLine(X2, Y1, Y2, Lo);
End;

Procedure DrawShadow(X1, Y1, X2, Y2: Integer);
Begin
 FillRect(X1 + 4, Y2 + 1, X2 + 4, Y2 + 4, CLR_SHADOW);
 FillRect(X2 + 1, Y1 + 4, X2 + 4, Y2 + 4, CLR_SHADOW);
End;

Procedure DrawCenteredText(X1, Y, X2: Integer; Color: Integer;
                           S: String);
Var TX: Integer;
Begin
 TX := X1 + ((X2 - X1) - Length(S) * CHARW) Div 2;
 SetColor(Color);
 OutTextXY(TX, Y, S);
End;

Procedure DrawTextLeft(X, Y, Color: Integer; S: String);
Begin SetColor(Color); OutTextXY(X, Y, S); End;

Procedure DrawTextRight(X, Y, Color: Integer; S: String);
Var TX: Integer;
Begin
 TX := X - Length(S) * CHARW;
 SetColor(Color);
 OutTextXY(TX, Y, S);
End;

{ ============================================================
  EVENEMENTS (clavier + souris)
  ============================================================ }

Procedure ClearEvent(Var Ev: TEvent);
Begin
 Ev.Kind     := EV_NONE;
 Ev.MouseX   := 0;
 Ev.MouseY   := 0;
 Ev.MouseBtn := MB_NONE;
 Ev.KeyCode  := 0;
 Ev.KeyChar  := #0;
 Ev.Timestamp:= 0;
End;

Function BtnFromMask(Mask: LongInt): TMouseButton;
Begin
 If (Mask And 1) <> 0 Then BtnFromMask := MB_LEFT
 Else If (Mask And 2) <> 0 Then BtnFromMask := MB_RIGHT
 Else If (Mask And 4) <> 0 Then BtnFromMask := MB_MIDDLE
 Else BtnFromMask := MB_NONE;
End;

Function IsDoubleClick(X, Y: Integer; Btn: TMouseButton;
                       Now: LongInt): Boolean;
Var DX, DY: Integer;
Begin
 IsDoubleClick := False;
 If (Btn = LastClickBtn) And (LastClickBtn <> MB_NONE) Then Begin
  DX := X - LastClickX; If DX < 0 Then DX := -DX;
  DY := Y - LastClickY; If DY < 0 Then DY := -DY;
  If (DX <= 5) And (DY <= 5) And ((Now - LastClickTime) <= 350) Then
   IsDoubleClick := True;
 End;
End;

Procedure PollEvents(Var Ev: TEvent);
Var
 MX, MY, MBtn: LongInt;
 Now: LongInt;
 Ch: Char;
 Btn: TMouseButton;
Begin
 ClearEvent(Ev);
 Now := GetTimestamp;
 Ev.Timestamp := Now;

 If KeyPressed Then Begin
  Ch := ReadKey;
  If Ch = #0 Then Begin
   Ev.Kind := EV_KEY_DOWN;
   If KeyPressed Then Begin
    Ch := ReadKey;
    Ev.KeyCode := Ord(Ch);
   End;
   Ev.KeyChar := #0;
  End Else Begin
   Ev.Kind := EV_KEY_CHAR;
   Ev.KeyChar := Ch;
   Ev.KeyCode := Ord(Ch);
  End;
  Exit;
 End;

 MX := 0; MY := 0; MBtn := 0;
 GetMouseState(MX, MY, MBtn);
 Btn := BtnFromMask(MBtn);

 If (MBtn <> 0) And (PrevMouseBtn = 0) Then Begin
  If IsDoubleClick(Integer(MX), Integer(MY), Btn, Now) Then Begin
   Ev.Kind := EV_MOUSE_DBLCLICK;
   LastClickBtn := MB_NONE;
  End Else Begin
   Ev.Kind := EV_MOUSE_DOWN;
   LastClickX := Integer(MX);
   LastClickY := Integer(MY);
   LastClickTime := Now;
   LastClickBtn := Btn;
  End;
  Ev.MouseX := Integer(MX);
  Ev.MouseY := Integer(MY);
  Ev.MouseBtn := Btn;
 End
 Else If (MBtn = 0) And (PrevMouseBtn <> 0) Then Begin
  Ev.Kind := EV_MOUSE_UP;
  Ev.MouseX := Integer(MX);
  Ev.MouseY := Integer(MY);
  Ev.MouseBtn := BtnFromMask(PrevMouseBtn);
 End
 Else If (Integer(MX) <> PrevMouseX) Or
         (Integer(MY) <> PrevMouseY) Then Begin
  Ev.Kind := EV_MOUSE_MOVE;
  Ev.MouseX := Integer(MX);
  Ev.MouseY := Integer(MY);
  Ev.MouseBtn := Btn;
 End;

 PrevMouseX := Integer(MX);
 PrevMouseY := Integer(MY);
 PrevMouseBtn := MBtn;
End;

{ ============================================================
  MENUS DEROULANTS (porte depuis GEANT4.PAS)
  ============================================================ }

Procedure InitMenuItem(Var MI: TMenuItem; ACaption: String;
                       AShortCut: String; ATag: LongInt;
                       ASep: Boolean);
Begin
 MI.Caption := ACaption;
 MI.ShortCut := AShortCut;
 MI.Enabled := True;
 MI.Checked := False;
 MI.Separator := ASep;
 MI.Tag := ATag;
End;

Procedure AddMenuItem(Var M: TMenu; ACaption: String;
                      AShortCut: String; ATag: LongInt);
Begin
 If M.ItemCount < MAX_MENU_ITEMS Then Begin
  InitMenuItem(M.Items[M.ItemCount], ACaption, AShortCut, ATag, False);
  Inc(M.ItemCount);
 End;
End;

Procedure AddMenuSeparator(Var M: TMenu);
Begin
 If M.ItemCount < MAX_MENU_ITEMS Then Begin
  InitMenuItem(M.Items[M.ItemCount], '', '', 0, True);
  Inc(M.ItemCount);
 End;
End;

Procedure InitMenu(Var M: TMenu; ATitle: String);
Begin
 M.Title := ATitle;
 M.ItemCount := 0;
 M.X := 0;
 M.Width := 0;
End;

Function MenuItemWidth(Var M: TMenu): Integer;
Var I, W, MaxW: Integer;
Begin
 MaxW := 0;
 For I := 0 To M.ItemCount - 1 Do Begin
  If Not M.Items[I].Separator Then Begin
   W := Length(M.Items[I].Caption) + Length(M.Items[I].ShortCut) + 4;
   If W > MaxW Then MaxW := W;
  End;
 End;
 MenuItemWidth := MaxW * CHARW + 16;
End;

Procedure GetMenuRect(Idx: Integer; Var X1, Y1, X2, Y2: Integer);
Var M: TMenu; MW, MH, I, SW: Integer;
Begin
 M := MainMenuBar.Menus[Idx];
 X1 := M.X;
 Y1 := MainMenuBar.Height;
 MW := M.Width;
 If MW < 160 Then MW := 160;
 MH := 4;
 For I := 0 To M.ItemCount - 1 Do
  If M.Items[I].Separator Then MH := MH + 8 Else MH := MH + 16;
 SW := ScreenWidth;
 If X1 + MW + 2 > SW - 1 Then X1 := SW - 1 - MW - 2;
 If X1 < 0 Then X1 := 0;
 X2 := X1 + MW + 2;
 Y2 := Y1 + MH + 2;
End;

Procedure SaveMenuBackground(Idx: Integer);
Var BufSize: LongInt;
Begin
 GetMenuRect(Idx, MenuBgX1, MenuBgY1, MenuBgX2, MenuBgY2);
 BufSize := ImageSize(MenuBgX1, MenuBgY1, MenuBgX2, MenuBgY2);
 GetMem(MenuBgBuf, BufSize);
 GetImage(MenuBgX1, MenuBgY1, MenuBgX2, MenuBgY2, MenuBgBuf^);
 MenuBgSaved := True;
End;

Procedure RestoreMenuBackground;
Var BufSize: LongInt;
Begin
 If Not MenuBgSaved Then Exit;
 PutImage(MenuBgX1, MenuBgY1, MenuBgBuf^, NormalPut);
 BufSize := ImageSize(MenuBgX1, MenuBgY1, MenuBgX2, MenuBgY2);
 FreeMem(MenuBgBuf, BufSize);
 MenuBgBuf := Nil;
 MenuBgSaved := False;
End;

Procedure DrawMenuBar;
Var I, TX: Integer;
Begin
 SetColor(CLR_MENUBAR);
 SetFillStyle(SolidFill, CLR_MENUBAR);
 Bar(0, MainMenuBar.Y, ScreenWidth - 1,
     MainMenuBar.Y + MainMenuBar.Height - 1);
 SetColor(CLR_BORDER);
 Line(0, MainMenuBar.Y + MainMenuBar.Height - 1,
      ScreenWidth - 1, MainMenuBar.Y + MainMenuBar.Height - 1);
 TX := 4;
 For I := 0 To MainMenuBar.MenuCount - 1 Do Begin
  MainMenuBar.Menus[I].X := TX - 4;
  If I = OpenMenuIdx Then Begin
   SetFillStyle(SolidFill, CLR_MENU_HIGHLIGHT);
   Bar(TX - 4, MainMenuBar.Y,
       TX + Length(MainMenuBar.Menus[I].Title) * CHARW + 12,
       MainMenuBar.Y + MainMenuBar.Height - 2);
   SetColor(White);
  End Else
   SetColor(CLR_MENU_TEXT);
  OutTextXY(TX, MainMenuBar.Y + 6, MainMenuBar.Menus[I].Title);
  TX := TX + Length(MainMenuBar.Menus[I].Title) * CHARW + 16;
 End;
End;

Procedure DrawOpenMenu;
Var
 I, YPos, MX, MW, MH, SW: Integer;
 M: TMenu;
Begin
 If OpenMenuIdx < 0 Then Exit;
 M := MainMenuBar.Menus[OpenMenuIdx];
 MX := M.X;
 MW := M.Width;
 If MW < 160 Then MW := 160;
 MH := 4;
 For I := 0 To M.ItemCount - 1 Do
  If M.Items[I].Separator Then MH := MH + 8 Else MH := MH + 16;
 SW := ScreenWidth;
 If MX + MW + 2 > SW - 1 Then MX := SW - 1 - MW - 2;
 If MX < 0 Then MX := 0;
 { Ombre }
 SetFillStyle(SolidFill, CLR_SHADOW);
 Bar(MX + 2, MainMenuBar.Height + 2, MX + MW + 2,
     MainMenuBar.Height + MH + 2);
 { Fond }
 SetFillStyle(SolidFill, LightGray);
 Bar(MX, MainMenuBar.Height, MX + MW, MainMenuBar.Height + MH);
 { Bordure }
 SetColor(CLR_BORDER);
 Rectangle(MX, MainMenuBar.Height, MX + MW, MainMenuBar.Height + MH);
 YPos := MainMenuBar.Height + 2;
 For I := 0 To M.ItemCount - 1 Do Begin
  If M.Items[I].Separator Then Begin
   SetColor(CLR_BORDER);
   Line(MX + 2, YPos + 3, MX + MW - 2, YPos + 3);
   YPos := YPos + 8;
  End Else Begin
   If I = SelItemIdx Then Begin
    SetFillStyle(SolidFill, CLR_MENU_HIGHLIGHT);
    Bar(MX + 1, YPos, MX + MW - 1, YPos + 15);
    SetColor(White);
   End Else Begin
    If Not M.Items[I].Enabled Then SetColor(CLR_BORDER)
    Else SetColor(CLR_MENU_TEXT);
   End;
   If M.Items[I].Checked Then
    OutTextXY(MX + 4, YPos + 4, #251);
   OutTextXY(MX + 16, YPos + 4, M.Items[I].Caption);
   If Length(M.Items[I].ShortCut) > 0 Then Begin
    If I = SelItemIdx Then SetColor(White)
    Else SetColor(CLR_BORDER);
    OutTextXY(MX + MW - Length(M.Items[I].ShortCut) * CHARW - 8,
              YPos + 4, M.Items[I].ShortCut);
   End;
   YPos := YPos + 16;
  End;
 End;
End;

Procedure OpenMenuByIdx(Index: Integer);
Begin
 If (Index >= 0) And (Index < MainMenuBar.MenuCount) Then Begin
  If MenuActive Then RestoreMenuBackground;
  OpenMenuIdx := Index;
  SelItemIdx := -1;
  MenuActive := True;
  DrawMenuBar;
  SaveMenuBackground(Index);
  DrawOpenMenu;
 End;
End;

Procedure CloseMenuBar;
Begin
 RestoreMenuBackground;
 OpenMenuIdx := -1;
 SelItemIdx := -1;
 MenuActive := False;
 DrawMenuBar;
End;

Function MenuBarHitTest(MX, MY: Integer): Integer;
Var I, TX, TW: Integer;
Begin
 MenuBarHitTest := -1;
 If (MY < MainMenuBar.Y) Or
    (MY >= MainMenuBar.Y + MainMenuBar.Height) Then Exit;
 TX := 0;
 For I := 0 To MainMenuBar.MenuCount - 1 Do Begin
  TW := Length(MainMenuBar.Menus[I].Title) * CHARW + 16;
  If (MX >= TX) And (MX < TX + TW) Then Begin
   MenuBarHitTest := I;
   Exit;
  End;
  TX := TX + TW;
 End;
End;

Function MenuItemHitTest(MX, MY: Integer): Integer;
Var
 I, YPos, MW, MXOrig, SW: Integer;
 M: TMenu;
Begin
 MenuItemHitTest := -1;
 If OpenMenuIdx < 0 Then Exit;
 M := MainMenuBar.Menus[OpenMenuIdx];
 MW := M.Width;
 If MW < 160 Then MW := 160;
 MXOrig := M.X;
 SW := ScreenWidth;
 If MXOrig + MW + 2 > SW - 1 Then MXOrig := SW - 1 - MW - 2;
 If MXOrig < 0 Then MXOrig := 0;
 If (MX < MXOrig) Or (MX > MXOrig + MW) Then Exit;
 YPos := MainMenuBar.Height + 2;
 For I := 0 To M.ItemCount - 1 Do Begin
  If M.Items[I].Separator Then YPos := YPos + 8
  Else Begin
   If (MY >= YPos) And (MY < YPos + 16) Then Begin
    If M.Items[I].Enabled Then MenuItemHitTest := I;
    Exit;
   End;
   YPos := YPos + 16;
  End;
 End;
End;

Procedure HandleMenuEvent(Var Ev: TEvent);
Var Hit, ItemHit: Integer;
Begin
 If Ev.Kind = EV_MOUSE_DOWN Then Begin
  Hit := MenuBarHitTest(Ev.MouseX, Ev.MouseY);
  If Hit >= 0 Then Begin
   If (OpenMenuIdx = Hit) And MenuActive Then CloseMenuBar
   Else OpenMenuByIdx(Hit);
   Exit;
  End;
  If MenuActive And (OpenMenuIdx >= 0) Then Begin
   ItemHit := MenuItemHitTest(Ev.MouseX, Ev.MouseY);
   If ItemHit >= 0 Then Begin
    Hit := OpenMenuIdx; { sauve avant CloseMenuBar }
    ItemHit := ItemHit;
    CloseMenuBar;
    ExecuteMenuItem(MainMenuBar.Menus[Hit].Items[ItemHit]);
    Exit;
   End;
   CloseMenuBar;
  End;
 End
 Else If Ev.Kind = EV_MOUSE_MOVE Then Begin
  If MenuActive And (OpenMenuIdx >= 0) Then Begin
   Hit := MenuBarHitTest(Ev.MouseX, Ev.MouseY);
   If (Hit >= 0) And (Hit <> OpenMenuIdx) Then OpenMenuByIdx(Hit);
   ItemHit := MenuItemHitTest(Ev.MouseX, Ev.MouseY);
   If ItemHit <> SelItemIdx Then Begin
    SelItemIdx := ItemHit;
    DrawOpenMenu;
   End;
  End;
 End
 Else If Ev.Kind = EV_KEY_DOWN Then Begin
  If MenuActive Then Begin
   Case Ev.KeyCode Of
    72: Begin
     If OpenMenuIdx >= 0 Then Begin
      If SelItemIdx > 0 Then Dec(SelItemIdx)
      Else SelItemIdx := MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1;
      While (SelItemIdx >= 0) And
       MainMenuBar.Menus[OpenMenuIdx].Items[SelItemIdx].Separator Do
       Dec(SelItemIdx);
      DrawOpenMenu;
     End;
    End;
    80: Begin
     If OpenMenuIdx >= 0 Then Begin
      If SelItemIdx < MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1 Then
       Inc(SelItemIdx)
      Else SelItemIdx := 0;
      While (SelItemIdx < MainMenuBar.Menus[OpenMenuIdx].ItemCount) And
       MainMenuBar.Menus[OpenMenuIdx].Items[SelItemIdx].Separator Do
       Inc(SelItemIdx);
      DrawOpenMenu;
     End;
    End;
    75: Begin
     If OpenMenuIdx > 0 Then OpenMenuByIdx(OpenMenuIdx - 1)
     Else OpenMenuByIdx(MainMenuBar.MenuCount - 1);
    End;
    77: Begin
     If OpenMenuIdx < MainMenuBar.MenuCount - 1 Then
      OpenMenuByIdx(OpenMenuIdx + 1)
     Else OpenMenuByIdx(0);
    End;
   End;
  End Else Begin
   { Alt+lettre : ouvrir un menu (codes scan BIOS) }
   Case Ev.KeyCode Of
    $21: OpenMenuByIdx(0); { Alt+F : Fichier }
    $12: OpenMenuByIdx(1); { Alt+E : Edition }
    $19: OpenMenuByIdx(2); { Alt+P : Parking }
    $1F: OpenMenuByIdx(3); { Alt+S : Statistiques }
    $2F: OpenMenuByIdx(4); { Alt+V : Vue }
    $23: OpenMenuByIdx(5); { Alt+H : Aide }
   End;
  End;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  If MenuActive Then Begin
   Case Ev.KeyChar Of
    #13: Begin
     If (SelItemIdx >= 0) And (OpenMenuIdx >= 0) Then Begin
      Hit := OpenMenuIdx; ItemHit := SelItemIdx;
      CloseMenuBar;
      ExecuteMenuItem(MainMenuBar.Menus[Hit].Items[ItemHit]);
     End;
    End;
    #27: CloseMenuBar;
   End;
  End;
 End;
End;

Procedure BuildMainMenu;
Begin
 MainMenuBar.MenuCount := 0;
 MainMenuBar.Y := 0;
 MainMenuBar.Height := MENUBAR_HEIGHT;

 InitMenu(MainMenuBar.Menus[0], 'Fichier');
 AddMenuItem(MainMenuBar.Menus[0], 'Nouveau parking', 'Ctrl+N', TAG_FILE_NEW);
 AddMenuItem(MainMenuBar.Menus[0], 'Ouvrir...',       'Ctrl+O', TAG_FILE_OPEN);
 AddMenuItem(MainMenuBar.Menus[0], 'Enregistrer',     'Ctrl+S', TAG_FILE_SAVE);
 AddMenuItem(MainMenuBar.Menus[0], 'Enregistrer sous...', '',  TAG_FILE_SAVEAS);
 AddMenuSeparator(MainMenuBar.Menus[0]);
 AddMenuItem(MainMenuBar.Menus[0], 'Quitter',         'Alt+X',  TAG_FILE_QUIT);
 MainMenuBar.Menus[0].Width := MenuItemWidth(MainMenuBar.Menus[0]);

 InitMenu(MainMenuBar.Menus[1], 'Edition');
 AddMenuItem(MainMenuBar.Menus[1], 'Configurer la grille...', 'F2', TAG_EDIT_CONFIG);
 AddMenuItem(MainMenuBar.Menus[1], 'Tarification...',         'F3', TAG_EDIT_PRICING);
 AddMenuSeparator(MainMenuBar.Menus[1]);
 AddMenuItem(MainMenuBar.Menus[1], 'Liberer tous les espaces', '',  TAG_EDIT_FREEALL);
 MainMenuBar.Menus[1].Width := MenuItemWidth(MainMenuBar.Menus[1]);

 InitMenu(MainMenuBar.Menus[2], 'Parking');
 AddMenuItem(MainMenuBar.Menus[2], 'Reserver une place...',   'F5', TAG_PARK_RESERVE);
 AddMenuItem(MainMenuBar.Menus[2], 'Liberer une place...',    'F6', TAG_PARK_FREE);
 AddMenuItem(MainMenuBar.Menus[2], 'Etendre reservation...',  'F7', TAG_PARK_EXTEND);
 AddMenuItem(MainMenuBar.Menus[2], 'Infos sur une place...',  'F8', TAG_PARK_INFO);
 AddMenuSeparator(MainMenuBar.Menus[2]);
 AddMenuItem(MainMenuBar.Menus[2], 'Rechercher (plaque)...',  'F9', TAG_PARK_SEARCH);
 AddMenuItem(MainMenuBar.Menus[2], 'Forcer la liberation...', '',   TAG_PARK_FORCE);
 MainMenuBar.Menus[2].Width := MenuItemWidth(MainMenuBar.Menus[2]);

 InitMenu(MainMenuBar.Menus[3], 'Statistiques');
 AddMenuItem(MainMenuBar.Menus[3], 'Taux d''occupation...',   '', TAG_STAT_OCCUPY);
 AddMenuItem(MainMenuBar.Menus[3], 'Rapport revenus...',      '', TAG_STAT_REVENUE);
 AddMenuItem(MainMenuBar.Menus[3], 'Historique transactions...','', TAG_STAT_HISTORY);
 AddMenuItem(MainMenuBar.Menus[3], 'Repartition par duree...','', TAG_STAT_DURATIONS);
 AddMenuSeparator(MainMenuBar.Menus[3]);
 AddMenuItem(MainMenuBar.Menus[3], 'Historique detaille...',   '', TAG_HIST_FILTER);
 AddMenuItem(MainMenuBar.Menus[3], 'Effacer historique',       '', TAG_HIST_CLEAR);
 MainMenuBar.Menus[3].Width := MenuItemWidth(MainMenuBar.Menus[3]);

 InitMenu(MainMenuBar.Menus[4], 'Vue');
 AddMenuItem(MainMenuBar.Menus[4], 'Rafraichir',             'F5', TAG_VIEW_REFRESH);
 AddMenuItem(MainMenuBar.Menus[4], 'Vue normale',            '',   TAG_VIEW_ZOOM_NORM);
 MainMenuBar.Menus[4].Width := MenuItemWidth(MainMenuBar.Menus[4]);

 InitMenu(MainMenuBar.Menus[5], 'Clients');
 AddMenuItem(MainMenuBar.Menus[5], 'Liste des abonnements...',  '', TAG_SUB_LIST);
 AddMenuItem(MainMenuBar.Menus[5], 'Nouvel abonnement...',      '', TAG_SUB_ADD);
 AddMenuItem(MainMenuBar.Menus[5], 'Renouveler...',             '', TAG_SUB_RENEW);
 AddMenuItem(MainMenuBar.Menus[5], 'Supprimer...',              '', TAG_SUB_DELETE);
 AddMenuItem(MainMenuBar.Menus[5], 'Rechercher par plaque...',  '', TAG_SUB_SEARCH);
 AddMenuSeparator(MainMenuBar.Menus[5]);
 AddMenuItem(MainMenuBar.Menus[5], 'Tarifs d''abonnement...',   '', TAG_SUB_PRICES);
 MainMenuBar.Menus[5].Width := MenuItemWidth(MainMenuBar.Menus[5]);

 InitMenu(MainMenuBar.Menus[6], 'Tarifs');
 AddMenuItem(MainMenuBar.Menus[6], 'Zones tarifaires...',      '', TAG_TARIFF_ZONES);
 AddMenuItem(MainMenuBar.Menus[6], 'Activer/Desactiver',       '', TAG_TARIFF_TOGGLE);
 AddMenuItem(MainMenuBar.Menus[6], 'Apercu...',                '', TAG_TARIFF_PREVIEW);
 AddMenuSeparator(MainMenuBar.Menus[6]);
 AddMenuItem(MainMenuBar.Menus[6], 'Reset zones par defaut',   '', TAG_TARIFF_RESET);
 MainMenuBar.Menus[6].Width := MenuItemWidth(MainMenuBar.Menus[6]);

 InitMenu(MainMenuBar.Menus[7], 'Rapports');
 AddMenuItem(MainMenuBar.Menus[7], 'Rapport quotidien...',     '', TAG_REPORT_DAILY);
 AddMenuItem(MainMenuBar.Menus[7], 'Rapport hebdomadaire...',  '', TAG_REPORT_WEEKLY);
 AddMenuItem(MainMenuBar.Menus[7], 'Rapport mensuel...',       '', TAG_REPORT_MONTHLY);
 AddMenuItem(MainMenuBar.Menus[7], 'Rapport abonnements...',   '', TAG_REPORT_SUBS);
 AddMenuItem(MainMenuBar.Menus[7], 'Occupation detaillee...',  '', TAG_REPORT_OCCUPANCY);
 AddMenuSeparator(MainMenuBar.Menus[7]);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. revenu quotidien',  '', TAG_GRAPH_DAILY);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. tendance cumulee',  '', TAG_GRAPH_MONTHLY);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. par type duree',    '', TAG_GRAPH_BYDUR);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. occupation',        '', TAG_GRAPH_OCCUPY);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. abonnements',       '', TAG_GRAPH_SUBS);
 AddMenuItem(MainMenuBar.Menus[7], 'Graph. par heure',         '', TAG_GRAPH_HOURS);
 MainMenuBar.Menus[7].Width := MenuItemWidth(MainMenuBar.Menus[7]);

 InitMenu(MainMenuBar.Menus[8], 'Export');
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : Transactions',       '', TAG_CSV_TRANS);
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : Abonnements',        '', TAG_CSV_SUBS);
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : Places',             '', TAG_CSV_SPOTS);
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : Journalier',         '', TAG_CSV_DAILY);
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : Tarifs',             '', TAG_CSV_PRICING);
 AddMenuSeparator(MainMenuBar.Menus[8]);
 AddMenuItem(MainMenuBar.Menus[8], 'Tout exporter (5 CSV)',    '', TAG_CSV_ALL);
 MainMenuBar.Menus[8].Width := MenuItemWidth(MainMenuBar.Menus[8]);

 InitMenu(MainMenuBar.Menus[9], 'Aide');
 AddMenuItem(MainMenuBar.Menus[9], 'Mode d''emploi...',      '', TAG_HELP_USAGE);
 AddMenuItem(MainMenuBar.Menus[9], 'Raccourcis clavier...',  '', TAG_HELP_KEYS);
 AddMenuSeparator(MainMenuBar.Menus[9]);
 AddMenuItem(MainMenuBar.Menus[9], 'A propos...',            '', TAG_HELP_ABOUT);
 MainMenuBar.Menus[9].Width := MenuItemWidth(MainMenuBar.Menus[9]);

 MainMenuBar.MenuCount := 10;
End;

{ ============================================================
  FRAMEWORK DE DIALOGUES MODALES
  ============================================================
  Une boite de dialogue est un rectangle 3D avec une barre de
  titre, des controles (etiquettes, champs, boutons) et une
  boucle d evenements modale.

  Les controles sont identifies par un ID Integer.  Le dialogue
  garde le focus sur un controle.  Tab passe au suivant, Maj+Tab
  au precedent.  Enter active le bouton par defaut (Tag>0),
  Echap active le bouton d annulation (Tag<0).
  ============================================================ }

Const
 CT_LABEL    = 1;
 CT_EDIT     = 2;
 CT_BUTTON   = 3;
 CT_CHECK    = 4;
 CT_RADIO    = 5;
 CT_LISTBOX  = 6;
 CT_FRAME    = 7;
 CT_HLINE    = 8;

 MAX_CTRLS   = 64;
 MAX_LIST    = 64;
Type
 TListItemArr = Array[0..MAX_LIST - 1] Of String[63];
 TControl = Record
  Kind     : Integer;
  X, Y     : Integer;
  W, H     : Integer;
  Caption  : String[63];
  Text     : String[63];     { contenu d un edit }
  MaxLen   : Integer;
  Checked  : Boolean;
  Group    : Integer;        { groupe radio }
  Tag      : Integer;        { pour les boutons : +1=OK, -1=Cancel, autre }
  Enabled  : Boolean;
  Visible  : Boolean;
  Focusable: Boolean;
  CursorPos: Integer;
  Numeric  : Boolean;
  NumDecimal: Boolean;
  HotKey   : Char;
  ListItems: TListItemArr;
  ListCount: Integer;
  ListSel  : Integer;
  ListTop  : Integer;
 End;

 TDialog = Record
  Title    : String[63];
  X1, Y1, X2, Y2 : Integer;
  CtrlCount: Integer;
  Ctrls    : Array[0..MAX_CTRLS - 1] Of TControl;
  Focus    : Integer;
  Result   : Integer;        { tag du bouton presse }
  DefaultBtn : Integer;
  CancelBtn  : Integer;
  BgBuf    : Pointer;
  BgSaved  : Boolean;
 End;

{ --- Construction --- }

Procedure DlgInit(Var D: TDialog; ATitle: String;
                  W, H: Integer);
Begin
 D.Title := ATitle;
 If W > SCREEN_W - 8 Then W := SCREEN_W - 8;
 If H > SCREEN_H - 20 Then H := SCREEN_H - 20;
 D.X1 := (SCREEN_W - W) Div 2;
 D.Y1 := (SCREEN_H - H) Div 2;
 If D.X1 < 4 Then D.X1 := 4;
 If D.Y1 < 12 Then D.Y1 := 12;
 D.X2 := D.X1 + W;
 D.Y2 := D.Y1 + H;
 If D.X2 > SCREEN_W - 4 Then D.X2 := SCREEN_W - 4;
 If D.Y2 > SCREEN_H - 4 Then D.Y2 := SCREEN_H - 4;
 D.CtrlCount := 0;
 D.Focus := -1;
 D.Result := 0;
 D.DefaultBtn := -1;
 D.CancelBtn := -1;
 D.BgBuf := Nil;
 D.BgSaved := False;
End;

Function DlgAdd(Var D: TDialog): Integer;
Begin
 If D.CtrlCount >= MAX_CTRLS Then Begin
  DlgAdd := -1; Exit;
 End;
 DlgAdd := D.CtrlCount;
 With D.Ctrls[D.CtrlCount] Do Begin
  Kind := CT_LABEL;
  X := 0; Y := 0; W := 0; H := 0;
  Caption := ''; Text := '';
  MaxLen := 0; Checked := False; Group := 0; Tag := 0;
  Enabled := True; Visible := True; Focusable := False;
  CursorPos := 0; Numeric := False; NumDecimal := False;
  HotKey := #0; ListCount := 0; ListSel := -1; ListTop := 0;
 End;
 Inc(D.CtrlCount);
End;

Function DlgAddLabel(Var D: TDialog; AX, AY: Integer;
                     ACaption: String): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_LABEL;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := Length(ACaption) * CHARW;
 D.Ctrls[I].H := CHARH;
 D.Ctrls[I].Caption := ACaption;
 DlgAddLabel := I;
End;

Function DlgAddFrame(Var D: TDialog; AX, AY, AW, AH: Integer;
                     ACaption: String): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_FRAME;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := AH;
 D.Ctrls[I].Caption := ACaption;
 DlgAddFrame := I;
End;

Function DlgAddHLine(Var D: TDialog; AX, AY, AW: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_HLINE;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 1;
 DlgAddHLine := I;
End;

Function DlgAddEdit(Var D: TDialog; AX, AY, AW: Integer;
                    AText: String; AMaxLen: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_EDIT;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 18;
 D.Ctrls[I].Text := AText;
 D.Ctrls[I].MaxLen := AMaxLen;
 D.Ctrls[I].Focusable := True;
 D.Ctrls[I].CursorPos := Length(AText);
 DlgAddEdit := I;
End;

Function DlgAddNumEdit(Var D: TDialog; AX, AY, AW: Integer;
                       AText: String; AMaxLen: Integer;
                       ADecimal: Boolean): Integer;
Var I: Integer;
Begin
 I := DlgAddEdit(D, AX, AY, AW, AText, AMaxLen);
 D.Ctrls[I].Numeric := True;
 D.Ctrls[I].NumDecimal := ADecimal;
 DlgAddNumEdit := I;
End;

Function DlgAddButton(Var D: TDialog; AX, AY, AW: Integer;
                      ACaption: String; ATag: Integer;
                      AHotKey: Char): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_BUTTON;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 22;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Tag := ATag;
 D.Ctrls[I].Focusable := True;
 D.Ctrls[I].HotKey := UpCase(AHotKey);
 If ATag = 1 Then D.DefaultBtn := I;
 If ATag = -1 Then D.CancelBtn := I;
 DlgAddButton := I;
End;

Function DlgAddCheck(Var D: TDialog; AX, AY, AW: Integer;
                     ACaption: String; AChecked: Boolean): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_CHECK;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 14;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Checked := AChecked;
 D.Ctrls[I].Focusable := True;
 DlgAddCheck := I;
End;

Function DlgAddRadio(Var D: TDialog; AX, AY, AW: Integer;
                     ACaption: String; AGroup: Integer;
                     AChecked: Boolean): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_RADIO;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 14;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Group := AGroup;
 D.Ctrls[I].Checked := AChecked;
 D.Ctrls[I].Focusable := True;
 DlgAddRadio := I;
End;

Function DlgAddList(Var D: TDialog; AX, AY, AW, AH: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_LISTBOX;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := AH;
 D.Ctrls[I].ListCount := 0;
 D.Ctrls[I].ListSel := 0;
 D.Ctrls[I].ListTop := 0;
 D.Ctrls[I].Focusable := True;
 DlgAddList := I;
End;

Procedure DlgListAdd(Var D: TDialog; Idx: Integer; S: String);
Begin
 With D.Ctrls[Idx] Do
  If ListCount < MAX_LIST Then Begin
   ListItems[ListCount] := S;
   Inc(ListCount);
  End;
End;

Procedure DlgListClear(Var D: TDialog; Idx: Integer);
Begin
 D.Ctrls[Idx].ListCount := 0;
 D.Ctrls[Idx].ListSel := 0;
 D.Ctrls[Idx].ListTop := 0;
End;

{ Selectionne un radio du groupe (decoche les autres) }
Procedure DlgSelectRadio(Var D: TDialog; Idx: Integer);
Var I, G: Integer;
Begin
 G := D.Ctrls[Idx].Group;
 For I := 0 To D.CtrlCount - 1 Do
  If (D.Ctrls[I].Kind = CT_RADIO) And (D.Ctrls[I].Group = G) Then
   D.Ctrls[I].Checked := (I = Idx);
End;

Function DlgFirstFocusable(Const D: TDialog): Integer;
Var I: Integer;
Begin
 DlgFirstFocusable := -1;
 For I := 0 To D.CtrlCount - 1 Do
  If D.Ctrls[I].Focusable And D.Ctrls[I].Enabled And
     D.Ctrls[I].Visible Then Begin
   DlgFirstFocusable := I; Exit;
  End;
End;

Function DlgNextFocus(Const D: TDialog; Cur, Step: Integer): Integer;
Var I, N: Integer;
Begin
 N := D.CtrlCount;
 If N = 0 Then Begin DlgNextFocus := -1; Exit; End;
 I := Cur;
 For N := 1 To D.CtrlCount Do Begin
  I := I + Step;
  If I < 0 Then I := D.CtrlCount - 1;
  If I >= D.CtrlCount Then I := 0;
  If D.Ctrls[I].Focusable And D.Ctrls[I].Enabled And
     D.Ctrls[I].Visible Then Begin
   DlgNextFocus := I; Exit;
  End;
 End;
 DlgNextFocus := Cur;
End;

{ --- Dessin --- }

Procedure DrawButton(X1, Y1, X2, Y2: Integer; Caption: String;
                     HotKey: Char; Focused, Default: Boolean);
Var TX, I: Integer;
Begin
 If Default Then Begin
  SetColor(CLR_BUTTON_DEFAULT);
  Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
 End;
 DrawBox3D(X1, Y1, X2, Y2, True, CLR_BUTTON_FACE);
 TX := X1 + ((X2 - X1) - Length(Caption) * CHARW) Div 2;
 If Focused Then SetColor(CLR_BUTTON_FOCUS)
 Else SetColor(CLR_BUTTON_TEXT);
 OutTextXY(TX, Y1 + ((Y2 - Y1) - CHARH) Div 2, Caption);
 { Soulignement du raccourci }
 If HotKey <> #0 Then Begin
  For I := 1 To Length(Caption) Do
   If UpCase(Caption[I]) = HotKey Then Begin
    Line(TX + (I - 1) * CHARW,
         Y1 + ((Y2 - Y1) - CHARH) Div 2 + CHARH,
         TX + I * CHARW - 1,
         Y1 + ((Y2 - Y1) - CHARH) Div 2 + CHARH);
    Break;
   End;
 End;
End;

Procedure DrawEdit(X1, Y1, X2, Y2: Integer; Text: String;
                   CursorPos: Integer; Focused: Boolean);
Var TX, TY, MaxChars, CX: Integer; S: String;
Begin
 DrawBox3D(X1, Y1, X2, Y2, False, CLR_EDIT_BG);
 SetColor(CLR_EDIT_TEXT);
 TX := X1 + 4;
 TY := Y1 + ((Y2 - Y1) - CHARH) Div 2;
 MaxChars := (X2 - X1 - 8) Div CHARW;
 S := Text;
 { Scroll horizontal si le texte depasse }
 If Length(S) > MaxChars Then Begin
  If CursorPos > MaxChars - 2 Then
   S := Copy(Text, CursorPos - MaxChars + 2, MaxChars);
 End;
 OutTextXY(TX, TY, S);
 If Focused Then Begin
  If Length(Text) > MaxChars Then Begin
   If CursorPos > MaxChars - 2 Then
    CX := TX + (MaxChars - 2) * CHARW
   Else CX := TX + CursorPos * CHARW;
  End Else
   CX := TX + CursorPos * CHARW;
  SetColor(Black);
  Line(CX, TY, CX, TY + CHARH - 1);
  Line(CX + 1, TY, CX + 1, TY + CHARH - 1);
 End;
End;

Procedure DrawCheck(X1, Y, W: Integer; Checked, Focused: Boolean;
                    Caption: String);
Var BoxX1, BoxX2, BoxY1, BoxY2: Integer;
Begin
 BoxX1 := X1; BoxY1 := Y; BoxX2 := X1 + 12; BoxY2 := Y + 12;
 DrawBox3D(BoxX1, BoxY1, BoxX2, BoxY2, False, White);
 If Checked Then Begin
  SetColor(Black);
  Line(BoxX1 + 2, BoxY1 + 6, BoxX1 + 5, BoxY1 + 9);
  Line(BoxX1 + 5, BoxY1 + 9, BoxX1 + 10, BoxY1 + 3);
 End;
 If Focused Then SetColor(CLR_BUTTON_FOCUS)
 Else SetColor(CLR_LABEL);
 OutTextXY(BoxX2 + 6, Y + 2, Caption);
End;

Procedure DrawRadio(X1, Y, W: Integer; Checked, Focused: Boolean;
                    Caption: String);
Begin
 SetColor(Black);
 Circle(X1 + 6, Y + 6, 6);
 SetFillStyle(SolidFill, White);
 FloodFill(X1 + 6, Y + 6, Black);
 If Checked Then Begin
  SetFillStyle(SolidFill, Black);
  SetColor(Black);
  Circle(X1 + 6, Y + 6, 2);
  FloodFill(X1 + 6, Y + 6, Black);
 End;
 If Focused Then SetColor(CLR_BUTTON_FOCUS)
 Else SetColor(CLR_LABEL);
 OutTextXY(X1 + 16, Y + 2, Caption);
End;

Procedure DrawList(X1, Y1, X2, Y2: Integer; Focused: Boolean;
                   Var Items: TListItemArr; Count, Sel, Top: Integer);
Var I, YPos, VisRows: Integer;
Begin
 DrawBox3D(X1, Y1, X2, Y2, False, CLR_EDIT_BG);
 VisRows := (Y2 - Y1 - 4) Div CHARH;
 YPos := Y1 + 2;
 For I := Top To IMin(Count - 1, Top + VisRows - 1) Do Begin
  If (I = Sel) And Focused Then Begin
   FillRect(X1 + 1, YPos, X2 - 1, YPos + CHARH - 1, CLR_MENU_HIGHLIGHT);
   SetColor(White);
  End Else If I = Sel Then Begin
   FillRect(X1 + 1, YPos, X2 - 1, YPos + CHARH - 1, LightGray);
   SetColor(Black);
  End Else SetColor(CLR_EDIT_TEXT);
  OutTextXY(X1 + 4, YPos, Items[I]);
  YPos := YPos + CHARH;
 End;
End;

Procedure DrawDialog(Var D: TDialog);
Var
 I, TitleH, AX, AY, TitleMax: Integer;
 TitleStr: String;
 C: TControl;
Begin
 TitleH := 18;
 { Ombre }
 SetFillStyle(SolidFill, CLR_SHADOW);
 Bar(D.X2 + 1, D.Y1 + 6, D.X2 + 6, D.Y2 + 6);
 Bar(D.X1 + 6, D.Y2 + 1, D.X2 + 6, D.Y2 + 6);
 { Cadre exterieur 3D }
 DrawBox3D(D.X1, D.Y1, D.X2, D.Y2, True, CLR_DIALOG_BG);
 { Barre de titre }
 FillRect(D.X1 + 3, D.Y1 + 3, D.X2 - 3, D.Y1 + TitleH, CLR_TITLEBAR);
 SetColor(CLR_TITLEBAR_TEXT);
 Begin
  { Tronque le titre s il est trop long pour la barre }
  TitleMax := (D.X2 - D.X1 - 16) Div CHARW;
  If TitleMax < 1 Then TitleMax := 1;
  TitleStr := D.Title;
  If Length(TitleStr) > TitleMax Then
   TitleStr := Copy(TitleStr, 1, TitleMax - 1) + '.';
  OutTextXY(D.X1 + 8, D.Y1 + 6, TitleStr);
 End;

 For I := 0 To D.CtrlCount - 1 Do Begin
  C := D.Ctrls[I];
  If Not C.Visible Then Continue;
  AX := D.X1 + C.X;
  AY := D.Y1 + TitleH + 6 + C.Y;
  Case C.Kind Of
   CT_LABEL: Begin
    SetColor(CLR_LABEL);
    OutTextXY(AX, AY, C.Caption);
   End;
   CT_FRAME: Begin
    SetColor(CLR_BORDER);
    Rectangle(AX, AY, AX + C.W, AY + C.H);
    If C.Caption <> '' Then Begin
     FillRect(AX + 8, AY - 4, AX + 8 + Length(C.Caption) * CHARW + 4,
              AY + 4, CLR_DIALOG_BG);
     SetColor(CLR_LABEL);
     OutTextXY(AX + 10, AY - 4, C.Caption);
    End;
   End;
   CT_HLINE: Begin
    SetColor(CLR_BORDER);
    Line(AX, AY, AX + C.W, AY);
    SetColor(CLR_BORDER_LIGHT);
    Line(AX, AY + 1, AX + C.W, AY + 1);
   End;
   CT_EDIT: DrawEdit(AX, AY, AX + C.W, AY + C.H, C.Text,
                     C.CursorPos, I = D.Focus);
   CT_BUTTON: DrawButton(AX, AY, AX + C.W, AY + C.H, C.Caption,
                         C.HotKey, I = D.Focus, I = D.DefaultBtn);
   CT_CHECK: DrawCheck(AX, AY, C.W, C.Checked, I = D.Focus, C.Caption);
   CT_RADIO: DrawRadio(AX, AY, C.W, C.Checked, I = D.Focus, C.Caption);
   CT_LISTBOX: DrawList(AX, AY, AX + C.W, AY + C.H, I = D.Focus,
                        C.ListItems, C.ListCount, C.ListSel, C.ListTop);
  End;
 End;
End;

{ --- Saisie dans un edit --- }

Function IsNumChar(Ch: Char; AllowDecimal, AlreadyHasDot: Boolean): Boolean;
Begin
 If (Ch >= '0') And (Ch <= '9') Then IsNumChar := True
 Else If (Ch = '-') Then IsNumChar := True
 Else If (Ch = '.') And AllowDecimal And (Not AlreadyHasDot)
  Then IsNumChar := True
 Else IsNumChar := False;
End;

Function HasDot(S: String): Boolean;
Var I: Integer;
Begin
 HasDot := False;
 For I := 1 To Length(S) Do If S[I] = '.' Then HasDot := True;
End;

Procedure EditInsertChar(Var C: TControl; Ch: Char);
Begin
 If C.Numeric Then
  If Not IsNumChar(Ch, C.NumDecimal, HasDot(C.Text)) Then Exit;
 If Length(C.Text) >= C.MaxLen Then Exit;
 Insert(Ch, C.Text, C.CursorPos + 1);
 Inc(C.CursorPos);
End;

Procedure EditBackspace(Var C: TControl);
Begin
 If C.CursorPos > 0 Then Begin
  Delete(C.Text, C.CursorPos, 1);
  Dec(C.CursorPos);
 End;
End;

Procedure EditDelete(Var C: TControl);
Begin
 If C.CursorPos < Length(C.Text) Then
  Delete(C.Text, C.CursorPos + 1, 1);
End;

Procedure EditHandleKey(Var C: TControl; Ev: TEvent);
Begin
 If Ev.Kind = EV_KEY_DOWN Then Begin
  Case Ev.KeyCode Of
   75: If C.CursorPos > 0 Then Dec(C.CursorPos);            { Left }
   77: If C.CursorPos < Length(C.Text) Then Inc(C.CursorPos);{ Right }
   71: C.CursorPos := 0;                                    { Home }
   79: C.CursorPos := Length(C.Text);                       { End }
   83: EditDelete(C);                                       { Del }
  End;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  Case Ev.KeyChar Of
   #8 : EditBackspace(C);
   #9 : ;
   #13: ;
   #27: ;
   #32..#126: EditInsertChar(C, Ev.KeyChar);
  End;
 End;
End;

{ --- Hit test pour la souris --- }

Function DlgHitTest(Var D: TDialog; X, Y: Integer): Integer;
Var I, AX, AY: Integer; C: TControl; TitleH: Integer;
Begin
 DlgHitTest := -1;
 TitleH := 18;
 For I := 0 To D.CtrlCount - 1 Do Begin
  C := D.Ctrls[I];
  If Not (C.Visible And C.Enabled) Then Continue;
  If Not C.Focusable Then Continue;
  AX := D.X1 + C.X;
  AY := D.Y1 + TitleH + 6 + C.Y;
  Case C.Kind Of
   CT_EDIT, CT_BUTTON, CT_LISTBOX:
    If (X >= AX) And (X <= AX + C.W) And
       (Y >= AY) And (Y <= AY + C.H) Then Begin
     DlgHitTest := I; Exit;
    End;
   CT_CHECK, CT_RADIO:
    If (X >= AX) And (X <= AX + C.W) And
       (Y >= AY - 2) And (Y <= AY + 14) Then Begin
     DlgHitTest := I; Exit;
    End;
  End;
 End;
End;

{ --- Boucle modale --- }

Procedure DlgSaveBackground(Var D: TDialog);
Var BufSize: LongInt;
Begin
 BufSize := ImageSize(D.X1 - 1, D.Y1 - 1, D.X2 + 8, D.Y2 + 8);
 GetMem(D.BgBuf, BufSize);
 GetImage(D.X1 - 1, D.Y1 - 1, D.X2 + 8, D.Y2 + 8, D.BgBuf^);
 D.BgSaved := True;
End;

Procedure DlgRestoreBackground(Var D: TDialog);
Var BufSize: LongInt;
Begin
 If Not D.BgSaved Then Exit;
 PutImage(D.X1 - 1, D.Y1 - 1, D.BgBuf^, NormalPut);
 BufSize := ImageSize(D.X1 - 1, D.Y1 - 1, D.X2 + 8, D.Y2 + 8);
 FreeMem(D.BgBuf, BufSize);
 D.BgBuf := Nil;
 D.BgSaved := False;
End;

Function DlgRun(Var D: TDialog): Integer;
Var
 Ev: TEvent;
 Hit, I, VisRows, RY, TX: Integer;
 Done: Boolean;
 OldFocus: Integer;
Begin
 If D.Focus < 0 Then D.Focus := DlgFirstFocusable(D);
 DlgSaveBackground(D);
 DrawDialog(D);
 Done := False;
 D.Result := 0;
 Repeat
  PollEvents(Ev);
  OldFocus := D.Focus;
  Case Ev.Kind Of
   EV_KEY_DOWN: Begin
    Case Ev.KeyCode Of
     15: D.Focus := DlgNextFocus(D, D.Focus, -1);   { Shift+Tab }
    End;
    If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_EDIT) Then
     EditHandleKey(D.Ctrls[D.Focus], Ev);
    If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_LISTBOX) Then Begin
     With D.Ctrls[D.Focus] Do Begin
      Case Ev.KeyCode Of
       72: If ListSel > 0 Then Dec(ListSel);
       80: If ListSel < ListCount - 1 Then Inc(ListSel);
       73: ListSel := IMax(0, ListSel - 8);
       81: ListSel := IMin(ListCount - 1, ListSel + 8);
      End;
      { ajuste le scroll }
      VisRows := (H - 4) Div CHARH;
      If ListSel < ListTop Then ListTop := ListSel;
      If ListSel >= ListTop + VisRows Then
       ListTop := ListSel - VisRows + 1;
     End;
    End;
    DrawDialog(D);
   End;
   EV_KEY_CHAR: Begin
    Case Ev.KeyChar Of
     #9: D.Focus := DlgNextFocus(D, D.Focus, 1);
     #13: Begin
      If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_BUTTON) Then
       Begin
        D.Result := D.Ctrls[D.Focus].Tag;
        Done := True;
       End
      Else If D.DefaultBtn >= 0 Then Begin
       D.Result := D.Ctrls[D.DefaultBtn].Tag;
       Done := True;
      End;
     End;
     #27: Begin
      If D.CancelBtn >= 0 Then D.Result := D.Ctrls[D.CancelBtn].Tag
      Else D.Result := -1;
      Done := True;
     End;
     #32: Begin
      If (D.Focus >= 0) Then
       Case D.Ctrls[D.Focus].Kind Of
        CT_EDIT: EditHandleKey(D.Ctrls[D.Focus], Ev);
        CT_CHECK: D.Ctrls[D.Focus].Checked :=
                  Not D.Ctrls[D.Focus].Checked;
        CT_RADIO: DlgSelectRadio(D, D.Focus);
        CT_BUTTON: Begin
         D.Result := D.Ctrls[D.Focus].Tag;
         Done := True;
        End;
       End;
     End;
     Else Begin
      If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_EDIT) Then
       EditHandleKey(D.Ctrls[D.Focus], Ev)
      Else
       { Hotkey lettre : activer le bouton correspondant
         (seulement si le focus n est pas dans un edit, sinon les
         lettres taperaient les boutons au lieu de saisir le texte) }
       For I := 0 To D.CtrlCount - 1 Do
        If (D.Ctrls[I].Kind = CT_BUTTON) And
           (D.Ctrls[I].HotKey <> #0) And
           (UpCase(Ev.KeyChar) = D.Ctrls[I].HotKey) Then Begin
         D.Result := D.Ctrls[I].Tag;
         Done := True;
         Break;
        End;
     End;
    End;
    DrawDialog(D);
   End;
   EV_MOUSE_DOWN, EV_MOUSE_DBLCLICK: Begin
    Hit := DlgHitTest(D, Ev.MouseX, Ev.MouseY);
    If Hit >= 0 Then Begin
     D.Focus := Hit;
     Case D.Ctrls[Hit].Kind Of
      CT_CHECK: D.Ctrls[Hit].Checked := Not D.Ctrls[Hit].Checked;
      CT_RADIO: DlgSelectRadio(D, Hit);
      CT_BUTTON: Begin
       D.Result := D.Ctrls[Hit].Tag;
       Done := True;
      End;
      CT_LISTBOX: Begin
       With D.Ctrls[Hit] Do Begin
        RY := (Ev.MouseY - (D.Y1 + 18 + 6 + Y) - 2) Div CHARH;
        If (RY >= 0) And (ListTop + RY < ListCount) Then
         ListSel := ListTop + RY;
       End;
       If Ev.Kind = EV_MOUSE_DBLCLICK Then Begin
        { double-clic = OK implicite }
        If D.DefaultBtn >= 0 Then Begin
         D.Result := D.Ctrls[D.DefaultBtn].Tag;
         Done := True;
        End;
       End;
      End;
      CT_EDIT: Begin
       { positionne le curseur dans l edit }
       TX := Ev.MouseX - (D.X1 + D.Ctrls[Hit].X) - 4;
       D.Ctrls[Hit].CursorPos := IClamp(TX Div CHARW,
                                        0, Length(D.Ctrls[Hit].Text));
      End;
     End;
     DrawDialog(D);
    End;
   End;
  End;
 Until Done;
 DlgRestoreBackground(D);
 DlgRun := D.Result;
End;

{ ============================================================
  DIALOGUES STANDARD : MessageBox, Confirm, Input
  ============================================================ }

Procedure WrapMessage(Msg: String; MaxChars: Integer;
                      Var Lines: Array Of String; Var Count: Integer);
{ Decoupe Msg en lignes <= MaxChars caracteres. Coupe sur espaces
  et respecte les sauts de ligne #10 / #13. }
Var I, Start, LastSpace: Integer; Cur: String; Ch: Char;
Begin
 Count := 0;
 Cur := '';
 I := 1;
 While I <= Length(Msg) Do Begin
  Ch := Msg[I];
  If (Ch = #10) Or (Ch = #13) Then Begin
   If Count <= High(Lines) Then Begin Lines[Count] := Cur; Inc(Count); End;
   Cur := '';
   If (Ch = #13) And (I < Length(Msg)) And (Msg[I + 1] = #10) Then Inc(I);
  End Else Begin
   Cur := Cur + Ch;
   If Length(Cur) >= MaxChars Then Begin
    { Cherche le dernier espace pour couper }
    LastSpace := 0;
    For Start := Length(Cur) Downto 1 Do
     If Cur[Start] = ' ' Then Begin LastSpace := Start; Break; End;
    If LastSpace > 0 Then Begin
     If Count <= High(Lines) Then Begin
      Lines[Count] := Copy(Cur, 1, LastSpace - 1); Inc(Count);
     End;
     Cur := Copy(Cur, LastSpace + 1, Length(Cur) - LastSpace);
    End Else Begin
     If Count <= High(Lines) Then Begin Lines[Count] := Cur; Inc(Count); End;
     Cur := '';
    End;
   End;
  End;
  Inc(I);
 End;
 If (Cur <> '') And (Count <= High(Lines)) Then Begin
  Lines[Count] := Cur; Inc(Count);
 End;
 If Count = 0 Then Begin Lines[0] := ''; Count := 1; End;
End;

Procedure ShowMessageBox(Title, Msg: String);
Var D: TDialog; W, H, I, MaxLine, MaxChars: Integer;
    Lines: Array[0..15] Of String; LineCount: Integer;
Begin
 { Largeur max disponible (laisser marge ecran) }
 MaxChars := (SCREEN_W - 80) Div CHARW;     { ~70 chars }
 If MaxChars > 60 Then MaxChars := 60;
 WrapMessage(Msg, MaxChars, Lines, LineCount);
 MaxLine := 0;
 For I := 0 To LineCount - 1 Do
  If Length(Lines[I]) > MaxLine Then MaxLine := Length(Lines[I]);
 W := IMax(280, MaxLine * CHARW + 60);
 If W > SCREEN_W - 40 Then W := SCREEN_W - 40;
 H := 60 + LineCount * (CHARH + 4) + 30;
 DlgInit(D, Title, W, H);
 For I := 0 To LineCount - 1 Do
  DlgAddLabel(D, 20, 10 + I * (CHARH + 4), Lines[I]);
 DlgAddButton(D, (W - 80) Div 2, H - 50, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

Function ShowConfirmBox(Title, Msg: String): Boolean;
Var D: TDialog; R, W, H, I, MaxLine, MaxChars: Integer;
    Lines: Array[0..15] Of String; LineCount: Integer;
Begin
 MaxChars := (SCREEN_W - 80) Div CHARW;
 If MaxChars > 60 Then MaxChars := 60;
 WrapMessage(Msg, MaxChars, Lines, LineCount);
 MaxLine := 0;
 For I := 0 To LineCount - 1 Do
  If Length(Lines[I]) > MaxLine Then MaxLine := Length(Lines[I]);
 W := IMax(320, MaxLine * CHARW + 60);
 If W > SCREEN_W - 40 Then W := SCREEN_W - 40;
 H := 60 + LineCount * (CHARH + 4) + 30;
 DlgInit(D, Title, W, H);
 For I := 0 To LineCount - 1 Do
  DlgAddLabel(D, 20, 10 + I * (CHARH + 4), Lines[I]);
 DlgAddButton(D, (W Div 2) - 90, H - 50, 80, 'Oui', 1, 'O');
 DlgAddButton(D, (W Div 2) + 10, H - 50, 80, 'Non', -1, 'N');
 R := DlgRun(D);
 ShowConfirmBox := (R = 1);
End;

Function ShowInputBox(Title, Prompt: String; Var Value: String;
                      MaxLen: Integer): Boolean;
Var D: TDialog; R, IE: Integer;
Begin
 DlgInit(D, Title, 360, 130);
 DlgAddLabel(D, 16, 8, Prompt);
 IE := DlgAddEdit(D, 16, 30, 320, Value, MaxLen);
 DlgAddButton(D, 100, 70, 70, 'OK',     1, 'O');
 DlgAddButton(D, 180, 70, 70, 'Annuler',-1, 'A');
 R := DlgRun(D);
 If R = 1 Then Begin
  Value := D.Ctrls[IE].Text;
  ShowInputBox := True;
 End Else ShowInputBox := False;
End;

{ ============================================================
  TARIFICATION
  ============================================================ }

Procedure InitDefaultPricing;
Begin
 Pricing[0].Code := 0; Pricing[0].Label_ := '1 heure';   Pricing[0].Hours := 1;    Pricing[0].Price := 2.00;
 Pricing[1].Code := 1; Pricing[1].Label_ := '2 heures';  Pricing[1].Hours := 2;    Pricing[1].Price := 3.50;
 Pricing[2].Code := 2; Pricing[2].Label_ := '3 heures';  Pricing[2].Hours := 3;    Pricing[2].Price := 5.00;
 Pricing[3].Code := 3; Pricing[3].Label_ := '8 heures';  Pricing[3].Hours := 8;    Pricing[3].Price := 10.00;
 Pricing[4].Code := 4; Pricing[4].Label_ := '12 heures'; Pricing[4].Hours := 12;   Pricing[4].Price := 14.00;
 Pricing[5].Code := 5; Pricing[5].Label_ := '24 heures'; Pricing[5].Hours := 24;   Pricing[5].Price := 20.00;
 Pricing[6].Code := 6; Pricing[6].Label_ := '2 jours';   Pricing[6].Hours := 48;   Pricing[6].Price := 36.00;
 Pricing[7].Code := 7; Pricing[7].Label_ := '7 jours';   Pricing[7].Hours := 168;  Pricing[7].Price := 100.00;
 Pricing[8].Code := 8; Pricing[8].Label_ := '1 mois';    Pricing[8].Hours := 720;  Pricing[8].Price := 300.00;
End;

Function ComputePrice(DurCode: TDurCode): Real;
Begin ComputePrice := Pricing[DurCode].Price; End;

Function DurationHours(DurCode: TDurCode): LongInt;
Begin DurationHours := Pricing[DurCode].Hours; End;

Function DurationLabel(DurCode: TDurCode): String;
Begin DurationLabel := Pricing[DurCode].Label_; End;

{ ============================================================
  PARKING : OPERATIONS DE BASE
  ============================================================ }

Procedure ClearSpot(Var S: TSpot);
Begin
 S.State := ssFree;
 S.Plate := '';
 S.Owner := '';
 S.Phone := '';
 S.StartDT.Year := 2026; S.StartDT.Month := 1; S.StartDT.Day := 1;
 S.StartDT.Hour := 0; S.StartDT.Min := 0;
 S.EndDT := S.StartDT;
 S.DurCode := 0;
 S.Paid := 0;
End;

Procedure ClearAllSpots;
Var I: Integer;
Begin
 For I := 0 To MAX_SPOTS - 1 Do ClearSpot(Spots[I]);
End;

Function SpotCount: Integer;
Begin SpotCount := ColCount * RowCount; End;

Function SpotIdx(Col, Row: Integer): Integer;
Begin SpotIdx := Row * ColCount + Col; End;

Function CountByState(State: TSpotState): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To SpotCount - 1 Do If Spots[I].State = State Then Inc(N);
 CountByState := N;
End;

Function FindFreeSpot: Integer;
Var I: Integer;
Begin
 FindFreeSpot := -1;
 For I := 0 To SpotCount - 1 Do
  If Spots[I].State = ssFree Then Begin
   FindFreeSpot := I; Exit;
  End;
End;

Function FindByPlate(Plate: TStr15): Integer;
Var I: Integer;
Begin
 FindByPlate := -1;
 If Plate = '' Then Exit;
 Plate := UpStr(TrimStr(Plate));
 For I := 0 To SpotCount - 1 Do
  If (Spots[I].State = ssOccupied) And
     (UpStr(Spots[I].Plate) = Plate) Then Begin
   FindByPlate := I; Exit;
  End;
End;

Function ComputeRemainingMin(Idx: Integer): LongInt;
Begin
 If Spots[Idx].State <> ssOccupied Then Begin
  ComputeRemainingMin := 0; Exit;
 End;
 ComputeRemainingMin := MinutesBetween(NowDT, Spots[Idx].EndDT);
End;

Procedure ReserveSpot(Idx: Integer; APlate: TStr15; AOwner: TStr31;
                      APhone: TStr15; ADurCode: TDurCode);
Var Price: Real;
Begin
 If Idx < 0 Then Exit;
 GetCurrentDT(NowDT);
 Price := ComputePrice(ADurCode);
 Spots[Idx].State := ssOccupied;
 Spots[Idx].Plate := UpStr(TrimStr(APlate));
 Spots[Idx].Owner := TrimStr(AOwner);
 Spots[Idx].Phone := TrimStr(APhone);
 Spots[Idx].StartDT := NowDT;
 Spots[Idx].EndDT := NowDT;
 AddHours(Spots[Idx].EndDT, DurationHours(ADurCode));
 Spots[Idx].DurCode := ADurCode;
 Spots[Idx].Paid := Price;
 DailyRevenue := DailyRevenue + Price;
 Inc(DailyReservations);
 RecordTransaction(Spots[Idx].Plate, Spots[Idx].Owner,
                   Spots[Idx].StartDT, Spots[Idx].EndDT, Price,
                   Idx, 0);
End;

Procedure FreeSpot(Idx: Integer);
Begin
 If Idx < 0 Then Exit;
 If Spots[Idx].State = ssFree Then Exit;
 RecordTransaction(Spots[Idx].Plate, Spots[Idx].Owner,
                   Spots[Idx].StartDT, NowDT, 0, Idx, 1);
 Inc(DailyReleases);
 ClearSpot(Spots[Idx]);
End;

Procedure ExtendReservation(Idx: Integer; ExtraCode: TDurCode);
Var Price: Real;
Begin
 If Idx < 0 Then Exit;
 If Spots[Idx].State <> ssOccupied Then Exit;
 GetCurrentDT(NowDT);
 Price := ComputePrice(ExtraCode);
 AddHours(Spots[Idx].EndDT, DurationHours(ExtraCode));
 Spots[Idx].Paid := Spots[Idx].Paid + Price;
 DailyRevenue := DailyRevenue + Price;
 RecordTransaction(Spots[Idx].Plate, Spots[Idx].Owner,
                   Spots[Idx].StartDT, Spots[Idx].EndDT, Price,
                   Idx, 2);
End;

{ ============================================================
  HISTORIQUE DE TRANSACTIONS (anneau circulaire)
  ============================================================ }

Procedure RecordTransaction(APlate: TStr15; AOwner: TStr31;
                            Const SD, ED: TDateTime;
                            APaid: Real; ASpotIdx: Integer;
                            AKind: Byte);
Begin
 Transactions[TransHead].Plate := APlate;
 Transactions[TransHead].Owner := AOwner;
 Transactions[TransHead].StartDT := SD;
 Transactions[TransHead].EndDT := ED;
 Transactions[TransHead].Paid := APaid;
 Transactions[TransHead].SpotIdx := ASpotIdx;
 Transactions[TransHead].Kind := AKind;
 Inc(TransHead);
 If TransHead >= MAX_HISTORY Then TransHead := 0;
 Inc(TransCnt);
End;

Function TransAt(I: Integer): Integer;
{ Renvoie l indice "logique" en partant du plus recent (0 = plus recent). }
Var Total, Pos: Integer;
Begin
 Total := TransCnt;
 If Total > MAX_HISTORY Then Total := MAX_HISTORY;
 If I >= Total Then Begin TransAt := -1; Exit; End;
 Pos := TransHead - 1 - I;
 While Pos < 0 Do Pos := Pos + MAX_HISTORY;
 TransAt := Pos;
End;

Function TransCount: Integer;
Begin
 If TransCnt > MAX_HISTORY Then TransCount := MAX_HISTORY
 Else TransCount := TransCnt;
End;

{ ============================================================
  RAPPORTS QUOTIDIENS
  ============================================================ }

Procedure ResetDailyIfNewDay;
Var CurDT: TDateTime; K: Integer;
Begin
 GetCurrentDT(CurDT);
 If Not SameDay(CurDT, DailyDate) Then Begin
  { Pousse le jour precedent dans DailyStats }
  If DailyStatsCnt < MAX_DAILY Then Begin
   DailyStats[DailyStatsCnt].Date := DailyDate;
   DailyStats[DailyStatsCnt].Revenue := DailyRevenue;
   DailyStats[DailyStatsCnt].Reservations := DailyReservations;
   DailyStats[DailyStatsCnt].Released := DailyReleases;
   Inc(DailyStatsCnt);
  End Else Begin
   { Shift gauche (perte du plus ancien) }
   For K := 0 To MAX_DAILY - 2 Do DailyStats[K] := DailyStats[K + 1];
   DailyStats[MAX_DAILY - 1].Date := DailyDate;
   DailyStats[MAX_DAILY - 1].Revenue := DailyRevenue;
   DailyStats[MAX_DAILY - 1].Reservations := DailyReservations;
   DailyStats[MAX_DAILY - 1].Released := DailyReleases;
  End;
  DailyDate := CurDT;
  DailyRevenue := 0;
  DailyReservations := 0;
  DailyReleases := 0;
 End;
End;

Procedure RebuildDailyStatsFromHistory;
Begin
 { Stub : conserves les stats existantes en memoire. }
End;

{ ============================================================
  RENDU DE LA GRILLE DE STATIONNEMENT
  ============================================================ }

Procedure ComputeGridLayout;
Var Margin, AvailW, AvailH: Integer;
Begin
 Margin := 8;
 GridX := Margin;
 GridY := MENUBAR_HEIGHT + Margin;
 AvailW := ScreenWidth - 2 * Margin;
 AvailH := ScreenHeight - MENUBAR_HEIGHT - STATUSBAR_HEIGHT - 2 * Margin;
 SpotW := AvailW Div ColCount;
 SpotH := AvailH Div RowCount;
 If SpotW < 24 Then SpotW := 24;
 If SpotH < 18 Then SpotH := 18;
 If SpotW > 60 Then SpotW := 60;
 If SpotH > 50 Then SpotH := 50;
 GridW := SpotW * ColCount;
 GridH := SpotH * RowCount;
 { Centre dans l espace disponible }
 GridX := (ScreenWidth - GridW) Div 2;
 GridY := MENUBAR_HEIGHT +
          (ScreenHeight - MENUBAR_HEIGHT - STATUSBAR_HEIGHT - GridH) Div 2;
End;

Procedure DrawCarIcon(X1, Y1, X2, Y2: Integer; Color: Integer);
Var
 CX, CY, BW, BH: Integer;
Begin
 BW := X2 - X1 - 4;
 BH := Y2 - Y1 - 4;
 CX := (X1 + X2) Div 2;
 CY := (Y1 + Y2) Div 2;
 { Corps de la voiture }
 SetFillStyle(SolidFill, Color);
 Bar(X1 + 3, CY - BH Div 3, X2 - 3, CY + BH Div 3);
 { Capot et coffre (formes legerement inclinees) }
 SetColor(Color);
 Bar(X1 + 5, CY - BH Div 4, X2 - 5, CY + BH Div 4);
 { Fenetres }
 SetFillStyle(SolidFill, CLR_CAR_WINDOW);
 Bar(X1 + 7, CY - BH Div 5, CX - 1, CY + BH Div 5);
 Bar(CX + 1, CY - BH Div 5, X2 - 7, CY + BH Div 5);
 { Roues }
 SetColor(Black);
 SetFillStyle(SolidFill, Black);
 Bar(X1 + 4, CY - BH Div 3 - 2, X1 + 8, CY - BH Div 3);
 Bar(X1 + 4, CY + BH Div 3, X1 + 8, CY + BH Div 3 + 2);
 Bar(X2 - 8, CY - BH Div 3 - 2, X2 - 4, CY - BH Div 3);
 Bar(X2 - 8, CY + BH Div 3, X2 - 4, CY + BH Div 3 + 2);
End;

Function GetSpotColor(Idx: Integer): Integer;
Var RemMin: LongInt;
Begin
 If Spots[Idx].State = ssFree Then Begin
  GetSpotColor := CLR_SPOT_FREE; Exit;
 End;
 RemMin := ComputeRemainingMin(Idx);
 If RemMin < 0 Then GetSpotColor := CLR_SPOT_EXPIRED
 Else If RemMin < 30 Then GetSpotColor := CLR_SPOT_EXPIRING
 Else GetSpotColor := CLR_SPOT_OCCUPIED;
End;

Procedure DrawSpot(Idx: Integer);
Var
 Col, Row: Integer;
 X1, Y1, X2, Y2: Integer;
 BG: Integer;
 NumStr: String;
 TX: Integer;
Begin
 Col := Idx Mod ColCount;
 Row := Idx Div ColCount;
 X1 := GridX + Col * SpotW;
 Y1 := GridY + Row * SpotH;
 X2 := X1 + SpotW - 2;
 Y2 := Y1 + SpotH - 2;
 BG := GetSpotColor(Idx);
 { Bordure du stationnement (lignes blanches comme au sol) }
 FillRect(X1, Y1, X2, Y2, BG);
 SetColor(White);
 Line(X1, Y1, X1, Y2);
 Line(X2, Y1, X2, Y2);
 Line(X1, Y2, X2, Y2);
 { Trait de fond (numero) }
 NumStr := IntToStr(Idx + 1);
 SetColor(CLR_SPOT_BORDER);
 OutTextXY(X1 + 2, Y1 + 2, NumStr);

 If Spots[Idx].State = ssOccupied Then Begin
  DrawCarIcon(X1, Y1 + 8, X2, Y2 - 4, CLR_CAR);
  { Plaque }
  If SpotH >= 30 Then Begin
   TX := X1 + ((SpotW - Length(Spots[Idx].Plate) * 6) Div 2);
   SetColor(White);
   OutTextXY(TX, Y2 - 10, Spots[Idx].Plate);
  End;
 End;

 If Idx = HoverSpot Then Begin
  SetColor(Yellow);
  Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
 End;
End;

Procedure DrawParkingGrid;
Var I: Integer;
Begin
 { Efface la zone parking }
 FillRect(0, MENUBAR_HEIGHT,
          ScreenWidth - 1, ScreenHeight - STATUSBAR_HEIGHT - 1,
          CLR_BACKGROUND);
 { Cadre du parking (asphalte) }
 SetFillStyle(SolidFill, DarkGray);
 Bar(GridX - 4, GridY - 4, GridX + GridW + 4, GridY + GridH + 4);
 { Dessine chaque stationnement }
 For I := 0 To SpotCount - 1 Do DrawSpot(I);
End;

Function HitTestSpot(X, Y: Integer): Integer;
Var Col, Row: Integer;
Begin
 HitTestSpot := -1;
 If (X < GridX) Or (X >= GridX + GridW) Then Exit;
 If (Y < GridY) Or (Y >= GridY + GridH) Then Exit;
 Col := (X - GridX) Div SpotW;
 Row := (Y - GridY) Div SpotH;
 If (Col < 0) Or (Col >= ColCount) Then Exit;
 If (Row < 0) Or (Row >= RowCount) Then Exit;
 HitTestSpot := SpotIdx(Col, Row);
End;

{ ============================================================
  BARRE DE STATUT
  ============================================================ }

Procedure UpdateCounters;
Var I: Integer; RemMin: LongInt;
Begin
 CntFree := 0; CntOccupied := 0; CntExpiring := 0; CntExpired := 0;
 GetCurrentDT(NowDT);
 For I := 0 To SpotCount - 1 Do
  If Spots[I].State = ssFree Then Inc(CntFree)
  Else Begin
   Inc(CntOccupied);
   RemMin := MinutesBetween(NowDT, Spots[I].EndDT);
   If RemMin < 0 Then Inc(CntExpired)
   Else If RemMin < 30 Then Inc(CntExpiring);
  End;
End;

Procedure DrawStatusBar;
Var Y0, X: Integer; S: String;
Begin
 Y0 := ScreenHeight - STATUSBAR_HEIGHT;
 FillRect(0, Y0, ScreenWidth - 1, ScreenHeight - 1, CLR_STATUS_BG);
 SetColor(CLR_BORDER_LIGHT);
 Line(0, Y0, ScreenWidth - 1, Y0);
 { Ligne 1 : compteurs }
 X := 8;
 SetColor(CLR_STATUS_TEXT);
 OutTextXY(X, Y0 + 4, 'Total:');
 SetColor(White); X := X + 8 * CHARW;
 OutTextXY(X, Y0 + 4, IntToStr(SpotCount));
 X := X + 5 * CHARW;
 SetColor(CLR_STATUS_OK);
 OutTextXY(X, Y0 + 4, 'Libres:');
 X := X + 8 * CHARW;
 OutTextXY(X, Y0 + 4, IntToStr(CntFree));
 X := X + 5 * CHARW;
 SetColor(CLR_STATUS_BAD);
 OutTextXY(X, Y0 + 4, 'Occupes:');
 X := X + 9 * CHARW;
 OutTextXY(X, Y0 + 4, IntToStr(CntOccupied));
 X := X + 5 * CHARW;
 If CntExpiring > 0 Then Begin
  SetColor(CLR_STATUS_WARN);
  OutTextXY(X, Y0 + 4, 'Bientot:');
  X := X + 9 * CHARW;
  OutTextXY(X, Y0 + 4, IntToStr(CntExpiring));
  X := X + 5 * CHARW;
 End;
 If CntExpired > 0 Then Begin
  SetColor(CLR_SPOT_EXPIRED);
  OutTextXY(X, Y0 + 4, 'Expires:');
  X := X + 9 * CHARW;
  OutTextXY(X, Y0 + 4, IntToStr(CntExpired));
 End;
 { Ligne 2 : revenu et heure }
 SetColor(CLR_REVENUE);
 OutTextXY(8, Y0 + 18, 'Revenu jour:');
 SetColor(White);
 OutTextXY(8 + 13 * CHARW, Y0 + 18, MoneyStr(DailyRevenue));
 S := 'Reserv:' + IntToStr(DailyReservations) +
      '  Liber:' + IntToStr(DailyReleases);
 SetColor(CLR_STATUS_TEXT);
 OutTextXY(8 + 30 * CHARW, Y0 + 18, S);
 { Heure a droite }
 S := FormatDateTime(NowDT);
 SetColor(White);
 OutTextXY(ScreenWidth - Length(S) * CHARW - 8, Y0 + 18, S);
End;

Procedure RedrawAll;
Begin
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, ScreenWidth - 1, ScreenHeight - 1);
 DrawMenuBar;
 ComputeGridLayout;
 DrawParkingGrid;
 UpdateCounters;
 DrawStatusBar;
End;

{ ============================================================
  SAUVEGARDE / CHARGEMENT
  ============================================================
  Format texte ligne-orientee, lisible:
    PARKINGv1
    COLS=10
    ROWS=8
    DAILY_REV=123.45
    DAILY_DATE=2026-05-31
    DAILY_RES=12
    DAILY_REL=10
    PRICE 0=2.00
    PRICE 1=3.50
    ...
    PRICE 8=300.00
    SPOTS:
    0 FREE
    1 OCC ABC123|Jean Dupont|514-555-1234|2026-05-31 09:00|2026-05-31 17:00|3|10.00
    ...
    END
  ============================================================ }

Procedure SaveToFile(FName: String);
Var F: Text; I: Integer; S: TSpot;
Begin
 Assign(F, FName);
 {$I-} Rewrite(F); {$I+}
 If IOResult <> 0 Then Begin
  ShowMessageBox('Erreur', 'Impossible d''ouvrir : ' + FName);
  Exit;
 End;
 Writeln(F, PARK_FILE_MAGIC);
 Writeln(F, 'COLS=', ColCount);
 Writeln(F, 'ROWS=', RowCount);
 Writeln(F, 'DAILY_REV=', RealToStr(DailyRevenue, 1, 2));
 Writeln(F, 'DAILY_DATE=', FormatDate(DailyDate));
 Writeln(F, 'DAILY_RES=', DailyReservations);
 Writeln(F, 'DAILY_REL=', DailyReleases);
 For I := 0 To MAX_DURATIONS - 1 Do
  Writeln(F, 'PRICE ', I, '=', RealToStr(Pricing[I].Price, 1, 2));
 Writeln(F, 'SPOTS:');
 For I := 0 To SpotCount - 1 Do Begin
  S := Spots[I];
  If S.State = ssFree Then
   Writeln(F, I, ' FREE')
  Else
   Writeln(F, I, ' OCC ', S.Plate, '|', S.Owner, '|', S.Phone, '|',
           FormatDateTime(S.StartDT), '|', FormatDateTime(S.EndDT), '|',
           S.DurCode, '|', RealToStr(S.Paid, 1, 2));
 End;
 Writeln(F, 'END');
 Close(F);
 CurrentFile := FName;
End;

Function ParseDT(S: String): TDateTime;
Var DT: TDateTime;
Begin
 { Format YYYY-MM-DD HH:MM }
 DT.Year := 2026; DT.Month := 1; DT.Day := 1;
 DT.Hour := 0; DT.Min := 0;
 If Length(S) >= 16 Then Begin
  DT.Year  := StrToIntDef(Copy(S, 1, 4), 2026);
  DT.Month := StrToIntDef(Copy(S, 6, 2), 1);
  DT.Day   := StrToIntDef(Copy(S, 9, 2), 1);
  DT.Hour  := StrToIntDef(Copy(S, 12, 2), 0);
  DT.Min   := StrToIntDef(Copy(S, 15, 2), 0);
 End;
 ParseDT := DT;
End;

Function ParseDate(S: String): TDateTime;
Var DT: TDateTime;
Begin
 DT.Year := 2026; DT.Month := 1; DT.Day := 1;
 DT.Hour := 0; DT.Min := 0;
 If Length(S) >= 10 Then Begin
  DT.Year  := StrToIntDef(Copy(S, 1, 4), 2026);
  DT.Month := StrToIntDef(Copy(S, 6, 2), 1);
  DT.Day   := StrToIntDef(Copy(S, 9, 2), 1);
 End;
 ParseDate := DT;
End;

Function SplitField(Var S: String; Sep: Char): String;
Var P: Integer;
Begin
 P := Pos(Sep, S);
 If P = 0 Then Begin
  SplitField := S; S := '';
 End Else Begin
  SplitField := Copy(S, 1, P - 1);
  Delete(S, 1, P);
 End;
End;

Procedure LoadFromFile(FName: String);
Var
 F: Text; Line: String; Magic: String;
 PrefixSpot: Boolean;
 I, EqPos: Integer;
 Key, Val: String;
 Idx: Integer;
 NewCol, NewRow: Integer;
 PI: Integer;
 Fld: String;
Begin
 Assign(F, FName);
 {$I-} Reset(F); {$I+}
 If IOResult <> 0 Then Begin
  ShowMessageBox('Erreur', 'Fichier introuvable : ' + FName);
  Exit;
 End;
 Readln(F, Magic);
 Magic := TrimStr(Magic);
 If Magic <> PARK_FILE_MAGIC Then Begin
  Close(F);
  ShowMessageBox('Erreur', 'Format de fichier inconnu : ' + Magic);
  Exit;
 End;
 ClearAllSpots;
 NewCol := 10; NewRow := 8;
 DailyRevenue := 0;
 PrefixSpot := False;
 While Not Eof(F) Do Begin
  Readln(F, Line);
  Line := TrimStr(Line);
  If Line = '' Then Continue;
  If Line = 'END' Then Break;
  If Line = 'SPOTS:' Then Begin
   PrefixSpot := True; Continue;
  End;
  If Not PrefixSpot Then Begin
   EqPos := Pos('=', Line);
   If EqPos = 0 Then Continue;
   Key := TrimStr(Copy(Line, 1, EqPos - 1));
   Val := TrimStr(Copy(Line, EqPos + 1, Length(Line) - EqPos));
   If Key = 'COLS' Then NewCol := StrToIntDef(Val, 10)
   Else If Key = 'ROWS' Then NewRow := StrToIntDef(Val, 8)
   Else If Key = 'DAILY_REV'  Then DailyRevenue := StrToRealDef(Val, 0)
   Else If Key = 'DAILY_DATE' Then DailyDate := ParseDate(Val)
   Else If Key = 'DAILY_RES'  Then DailyReservations := StrToIntDef(Val, 0)
   Else If Key = 'DAILY_REL'  Then DailyReleases := StrToIntDef(Val, 0)
   Else If Copy(Key, 1, 5) = 'PRICE' Then Begin
    PI := StrToIntDef(TrimStr(Copy(Key, 6, Length(Key) - 5)), -1);
    If (PI >= 0) And (PI < MAX_DURATIONS) Then
     Pricing[PI].Price := StrToRealDef(Val, Pricing[PI].Price);
   End;
  End Else Begin
   { Format spot: "Idx FREE" ou "Idx OCC plate|owner|phone|sd|ed|dc|paid" }
   I := Pos(' ', Line);
   If I = 0 Then Continue;
   Idx := StrToIntDef(Copy(Line, 1, I - 1), -1);
   If (Idx < 0) Or (Idx >= MAX_SPOTS) Then Continue;
   Val := TrimStr(Copy(Line, I + 1, Length(Line) - I));
   If Copy(Val, 1, 4) = 'FREE' Then Begin
    ClearSpot(Spots[Idx]);
   End Else If Copy(Val, 1, 3) = 'OCC' Then Begin
    Delete(Val, 1, 4);
    Val := TrimStr(Val);
    Spots[Idx].State := ssOccupied;
    Spots[Idx].Plate := SplitField(Val, '|');
    Spots[Idx].Owner := SplitField(Val, '|');
    Spots[Idx].Phone := SplitField(Val, '|');
    Fld := SplitField(Val, '|'); Spots[Idx].StartDT := ParseDT(Fld);
    Fld := SplitField(Val, '|'); Spots[Idx].EndDT := ParseDT(Fld);
    Fld := SplitField(Val, '|'); Spots[Idx].DurCode := IClamp(StrToIntDef(Fld, 0), 0, 8);
    Spots[Idx].Paid := StrToRealDef(Val, 0);
   End;
  End;
 End;
 Close(F);
 ColCount := IClamp(NewCol, 1, MAX_COLS);
 RowCount := IClamp(NewRow, 1, MAX_ROWS);
 CurrentFile := FName;
End;

{ ============================================================
  DIALOGUES SPECIFIQUES AU PARKING
  ============================================================ }

{ --- Configurer la grille --- }

Procedure DlgConfigureGrid;
Var
 D: TDialog;
 IC, IR: Integer;
 R, NC, NR: Integer;
 Done: Boolean;
Begin
 DlgInit(D, 'Configurer la grille de stationnement', 360, 180);
 DlgAddLabel(D, 16, 8, 'Nombre de colonnes (1..' + IntToStr(MAX_COLS) + ') :');
 IC := DlgAddNumEdit(D, 240, 6, 80, IntToStr(ColCount), 3, False);
 DlgAddLabel(D, 16, 36, 'Nombre de rangees (1..' + IntToStr(MAX_ROWS) + ') :');
 IR := DlgAddNumEdit(D, 240, 34, 80, IntToStr(RowCount), 3, False);
 DlgAddHLine(D, 16, 70, 328);
 DlgAddLabel(D, 16, 80, 'Total : ' + IntToStr(ColCount * RowCount) +
             ' stationnements actuellement.');
 DlgAddLabel(D, 16, 96, 'Attention : changer la taille reinitialise les places.');
 DlgAddButton(D, 100, 124, 70, 'OK',      1, 'O');
 DlgAddButton(D, 180, 124, 70, 'Annuler',-1, 'A');
 Done := False;
 Repeat
  R := DlgRun(D);
  If R = 1 Then Begin
   NC := IClamp(StrToIntDef(D.Ctrls[IC].Text, ColCount), 1, MAX_COLS);
   NR := IClamp(StrToIntDef(D.Ctrls[IR].Text, RowCount), 1, MAX_ROWS);
   If (NC <> ColCount) Or (NR <> RowCount) Then Begin
    If ShowConfirmBox('Confirmation',
                      'Reinitialiser tout le parking ?') Then Begin
     ColCount := NC;
     RowCount := NR;
     ClearAllSpots;
     Done := True;
    End;
   End Else Done := True;
  End Else Done := True;
 Until Done;
End;

{ --- Tarification --- }

Procedure DlgConfigurePricing;
Var
 D: TDialog;
 IEdits: Array[0..MAX_DURATIONS - 1] Of Integer;
 I, R, Y: Integer;
Begin
 DlgInit(D, 'Tarification des stationnements', 360, 290);
 Y := 8;
 For I := 0 To MAX_DURATIONS - 1 Do Begin
  DlgAddLabel(D, 16, Y + 2, PadRight(Pricing[I].Label_, 12) + ' :');
  IEdits[I] := DlgAddNumEdit(D, 180, Y, 90,
                  RealToStr(Pricing[I].Price, 1, 2), 10, True);
  DlgAddLabel(D, 282, Y + 2, '$');
  Y := Y + 24;
 End;
 DlgAddButton(D, 60,  Y + 8, 80, 'OK',         1, 'O');
 DlgAddButton(D, 148, Y + 8, 90, 'Defauts',    2, 'D');
 DlgAddButton(D, 246, Y + 8, 80, 'Annuler',   -1, 'A');
 Repeat
  R := DlgRun(D);
  If R = 2 Then Begin
   InitDefaultPricing;
   For I := 0 To MAX_DURATIONS - 1 Do Begin
    D.Ctrls[IEdits[I]].Text := RealToStr(Pricing[I].Price, 1, 2);
    D.Ctrls[IEdits[I]].CursorPos := Length(D.Ctrls[IEdits[I]].Text);
   End;
  End;
 Until R <> 2;
 If R = 1 Then
  For I := 0 To MAX_DURATIONS - 1 Do
   Pricing[I].Price := StrToRealDef(D.Ctrls[IEdits[I]].Text,
                                    Pricing[I].Price);
End;

{ --- Reserver --- }

Procedure DlgReserve(SpotIndex: Integer);
Var
 D: TDialog;
 IPlate, IOwner, IPhone: Integer;
 IRadios: Array[0..MAX_DURATIONS - 1] Of Integer;
 ILabel: Integer;
 I, R, SelDur: Integer;
 Plate: TStr15;
 PrevSpot: Integer;
Begin
 If SpotIndex < 0 Then SpotIndex := FindFreeSpot;
 If SpotIndex < 0 Then Begin
  ShowMessageBox('Reservation', 'Aucune place libre disponible.');
  Exit;
 End;
 If Spots[SpotIndex].State <> ssFree Then Begin
  ShowMessageBox('Reservation',
                 'La place ' + IntToStr(SpotIndex + 1) +
                 ' est deja occupee.');
  Exit;
 End;
 DlgInit(D, 'Reserver la place no ' + IntToStr(SpotIndex + 1), 480, 400);
 DlgAddLabel(D, 16, 6, 'Plaque d''immatriculation :');
 IPlate := DlgAddEdit(D, 220, 4, 200, '', 12);
 DlgAddLabel(D, 16, 30, 'Nom du proprietaire :');
 IOwner := DlgAddEdit(D, 220, 28, 240, '', 30);
 DlgAddLabel(D, 16, 54, 'Telephone (optionnel) :');
 IPhone := DlgAddEdit(D, 220, 52, 200, '', 15);
 DlgAddFrame(D, 16, 84, 446, 220, 'Duree de reservation');
 SelDur := 0;
 For I := 0 To MAX_DURATIONS - 1 Do Begin
  IRadios[I] := DlgAddRadio(D, 30 + (I Mod 2) * 220,
                            104 + (I Div 2) * 22, 210,
                            Pricing[I].Label_ + '  (' +
                            MoneyStr(Pricing[I].Price) + ')',
                            1, I = 0);
 End;
 ILabel := DlgAddLabel(D, 30, 280,
                       'A payer : ' + MoneyStr(Pricing[0].Price));
 DlgAddButton(D, 180, 330, 90, 'Reserver',  1, 'R');
 DlgAddButton(D, 280, 330, 90, 'Annuler',  -1, 'A');
 Repeat
  R := DlgRun(D);
  { Recalcule la duree selectionnee }
  SelDur := 0;
  For I := 0 To MAX_DURATIONS - 1 Do
   If D.Ctrls[IRadios[I]].Checked Then SelDur := I;
  D.Ctrls[ILabel].Caption := 'A payer : ' + MoneyStr(Pricing[SelDur].Price);
 Until R <> 0;
 If R = 1 Then Begin
  Plate := UpStr(TrimStr(D.Ctrls[IPlate].Text));
  If Plate = '' Then Begin
   ShowMessageBox('Erreur', 'La plaque est obligatoire.');
   Exit;
  End;
  PrevSpot := FindByPlate(Plate);
  If PrevSpot >= 0 Then Begin
   ShowMessageBox('Doublon',
                  'Le vehicule ' + Plate + ' est deja a la place ' +
                  IntToStr(PrevSpot + 1) + '.');
   Exit;
  End;
  ReserveSpot(SpotIndex, Plate,
              D.Ctrls[IOwner].Text,
              D.Ctrls[IPhone].Text,
              SelDur);
  ShowMessageBox('Reservation',
                 'Reservation confirmee. Montant percu : ' +
                 MoneyStr(Pricing[SelDur].Price));
 End;
End;

{ --- Infos d une place + actions --- }

Procedure DlgSpotInfo(Idx: Integer);
Var
 D: TDialog;
 Y, R: Integer;
 Rem: LongInt;
 RemStr, Title: String;
 DD: TDialog; ExR, I, SelI: Integer;
 IRadsA: Array[0..MAX_DURATIONS - 1] Of Integer;
Begin
 If Idx < 0 Then Exit;
 If Spots[Idx].State = ssFree Then Begin
  If ShowConfirmBox('Place ' + IntToStr(Idx + 1) + ' libre',
                    'Voulez-vous reserver cette place ?') Then
   DlgReserve(Idx);
  Exit;
 End;
 Title := 'Place no ' + IntToStr(Idx + 1) + ' (occupee)';
 DlgInit(D, Title, 440, 280);
 Y := 10;
 DlgAddLabel(D, 16, Y, 'Plaque :   ' + Spots[Idx].Plate);    Y := Y + 18;
 DlgAddLabel(D, 16, Y, 'Proprio :  ' + Spots[Idx].Owner);    Y := Y + 18;
 DlgAddLabel(D, 16, Y, 'Telephone :' + Spots[Idx].Phone);    Y := Y + 18;
 DlgAddHLine(D, 16, Y + 4, 408);                              Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Debut :    ' + FormatDateTime(Spots[Idx].StartDT));  Y := Y + 18;
 DlgAddLabel(D, 16, Y, 'Fin :      ' + FormatDateTime(Spots[Idx].EndDT));   Y := Y + 18;
 DlgAddLabel(D, 16, Y, 'Duree :    ' + DurationLabel(Spots[Idx].DurCode));  Y := Y + 18;
 Rem := ComputeRemainingMin(Idx);
 If Rem >= 0 Then RemStr := 'Restant : ' + FormatDurationMin(Rem)
 Else RemStr := 'EXPIRE depuis ' + FormatDurationMin(-Rem);
 DlgAddLabel(D, 16, Y, RemStr);                              Y := Y + 18;
 DlgAddLabel(D, 16, Y, 'Paye :     ' + MoneyStr(Spots[Idx].Paid));
 DlgAddButton(D,  20, 230, 90, 'Etendre',  2, 'E');
 DlgAddButton(D, 120, 230, 90, 'Liberer',  3, 'L');
 DlgAddButton(D, 320, 230, 90, 'Fermer',  -1, 'F');
 R := DlgRun(D);
 If R = 3 Then Begin
  If ShowConfirmBox('Confirmation',
                    'Liberer la place ' + IntToStr(Idx + 1) + ' ?') Then
   FreeSpot(Idx);
 End Else If R = 2 Then Begin
  { Sub-dialog : choix de la duree d extension }
  DlgInit(DD, 'Etendre la reservation', 480, 300);
  DlgAddLabel(DD, 16, 8, 'Choisir une duree supplementaire :');
  For I := 0 To MAX_DURATIONS - 1 Do
   IRadsA[I] := DlgAddRadio(DD, 30 + (I Mod 2) * 220,
                            30 + (I Div 2) * 22, 210,
                            Pricing[I].Label_ + '  (' +
                            MoneyStr(Pricing[I].Price) + ')', 1, I = 0);
  DlgAddButton(DD, 130, 240, 90, 'Etendre',  1, 'E');
  DlgAddButton(DD, 240, 240, 90, 'Annuler', -1, 'A');
  ExR := DlgRun(DD);
  If ExR = 1 Then Begin
   SelI := 0;
   For I := 0 To MAX_DURATIONS - 1 Do
    If DD.Ctrls[IRadsA[I]].Checked Then SelI := I;
   ExtendReservation(Idx, SelI);
   ShowMessageBox('Extension', 'Reservation prolongee. Montant : ' +
                  MoneyStr(Pricing[SelI].Price));
  End;
 End;
End;

{ --- Liberer (choix de la place) --- }

Procedure DlgFreeSpot;
Var Plate: String; Idx: Integer;
Begin
 Plate := '';
 If Not ShowInputBox('Liberer une place',
                     'Entrez le numero de place ou la plaque :',
                     Plate, 15) Then Exit;
 Plate := UpStr(TrimStr(Plate));
 If Plate = '' Then Exit;
 { Essaie comme numero d abord }
 Idx := StrToIntDef(Plate, -1);
 If (Idx >= 1) And (Idx <= SpotCount) Then Idx := Idx - 1
 Else Idx := FindByPlate(Plate);
 If Idx < 0 Then Begin
  ShowMessageBox('Introuvable', 'Aucune place ne correspond.');
  Exit;
 End;
 DlgSpotInfo(Idx);
End;

{ --- Rechercher --- }

Procedure DlgSearchByPlate;
Var Plate: String; Idx: Integer;
Begin
 Plate := '';
 If Not ShowInputBox('Rechercher un vehicule',
                     'Plaque d''immatriculation :',
                     Plate, 12) Then Exit;
 Plate := UpStr(TrimStr(Plate));
 If Plate = '' Then Exit;
 Idx := FindByPlate(Plate);
 If Idx < 0 Then
  ShowMessageBox('Resultat', 'Plaque ' + Plate + ' non trouvee.')
 Else Begin
  HoverSpot := Idx;
  DrawParkingGrid;
  DlgSpotInfo(Idx);
 End;
End;

{ --- Statistiques d occupation --- }

Procedure DlgOccupancyStats;
Var
 D: TDialog;
 Total, Free, Occ, Exp: Integer;
 Rate: Real;
 Y: Integer;
Begin
 Total := SpotCount;
 Free := CountByState(ssFree);
 Occ := Total - Free;
 Exp := CntExpired;
 If Total = 0 Then Rate := 0
 Else Rate := (Occ * 100.0) / Total;
 DlgInit(D, 'Taux d''occupation', 380, 230);
 Y := 14;
 DlgAddLabel(D, 20, Y, 'Configuration :');                    Y := Y + 16;
 DlgAddLabel(D, 40, Y, 'Colonnes : ' + IntToStr(ColCount));   Y := Y + 14;
 DlgAddLabel(D, 40, Y, 'Rangees  : ' + IntToStr(RowCount));   Y := Y + 14;
 DlgAddLabel(D, 40, Y, 'Total    : ' + IntToStr(Total) +
             ' places');                                       Y := Y + 18;
 DlgAddHLine(D, 20, Y, 340);                                   Y := Y + 8;
 DlgAddLabel(D, 20, Y, 'Etat actuel :');                       Y := Y + 16;
 DlgAddLabel(D, 40, Y, 'Libres   : ' + IntToStr(Free));        Y := Y + 14;
 DlgAddLabel(D, 40, Y, 'Occupees : ' + IntToStr(Occ));         Y := Y + 14;
 DlgAddLabel(D, 40, Y, 'Expirees : ' + IntToStr(Exp));         Y := Y + 14;
 DlgAddLabel(D, 40, Y, 'Taux     : ' + RealToStr(Rate, 1, 1) + ' %');
 DlgAddButton(D, 150, 190, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- Rapport revenus --- }

Procedure DlgRevenueReport;
Var
 D: TDialog;
 I, ILst, Y: Integer;
 Total7, Total30, AvgDay: Real;
 N: Integer;
 S: String;
Begin
 Total7 := 0; Total30 := 0; N := 0;
 For I := DailyStatsCnt - 1 Downto 0 Do Begin
  Inc(N);
  If N <= 7  Then Total7  := Total7  + DailyStats[I].Revenue;
  If N <= 30 Then Total30 := Total30 + DailyStats[I].Revenue;
 End;
 Total7  := Total7  + DailyRevenue;
 Total30 := Total30 + DailyRevenue;
 If N = 0 Then AvgDay := DailyRevenue
 Else AvgDay := Total30 / (N + 1);

 DlgInit(D, 'Rapport des revenus', 460, 340);
 Y := 12;
 DlgAddLabel(D, 20, Y, 'Aujourd''hui     : ' +
             MoneyStr(DailyRevenue) +
             '   (' + IntToStr(DailyReservations) + ' reservations)');
 Y := Y + 16;
 DlgAddLabel(D, 20, Y, '7 derniers jours: ' + MoneyStr(Total7));   Y := Y + 16;
 DlgAddLabel(D, 20, Y, '30 derniers jours: '+ MoneyStr(Total30));  Y := Y + 16;
 DlgAddLabel(D, 20, Y, 'Moyenne/jour    : ' + MoneyStr(AvgDay));   Y := Y + 16;
 DlgAddHLine(D, 20, Y + 4, 420);                                   Y := Y + 14;
 DlgAddLabel(D, 20, Y, 'Detail des derniers jours :');             Y := Y + 16;
 ILst := DlgAddList(D, 20, Y, 420, 140);
 For I := DailyStatsCnt - 1 Downto 0 Do Begin
  S := FormatDate(DailyStats[I].Date) +
       '  ' + PadLeft(MoneyStr(DailyStats[I].Revenue), 10) +
       '   ' + IntToStr(DailyStats[I].Reservations) + ' res, ' +
       IntToStr(DailyStats[I].Released) + ' lib';
  DlgListAdd(D, ILst, S);
 End;
 DlgListAdd(D, ILst,
            FormatDate(DailyDate) + '  ' +
            PadLeft(MoneyStr(DailyRevenue), 10) +
            '   ' + IntToStr(DailyReservations) + ' res (auj.)');
 DlgAddButton(D, 190, 300, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- Historique des transactions --- }

Procedure DlgHistory;
Var
 D: TDialog;
 ILst, I, RealI, R: Integer;
 N: Integer;
 T: TTransaction;
 S, KindStr: String;
Begin
 DlgInit(D, 'Historique des transactions (recent en haut)', 520, 360);
 DlgAddLabel(D, 16, 8,
             'Date              Type   Plaque        Place   Montant');
 ILst := DlgAddList(D, 16, 26, 488, 280);
 N := TransCount;
 For I := 0 To N - 1 Do Begin
  RealI := TransAt(I);
  If RealI < 0 Then Break;
  T := Transactions[RealI];
  Case T.Kind Of
   0: KindStr := 'RES';
   1: KindStr := 'LIB';
   2: KindStr := 'EXT';
   Else KindStr := '???';
  End;
  S := FormatDateTime(T.StartDT) + '  ' + KindStr + '  ' +
       PadRight(T.Plate, 12) + ' #' + PadLeft(IntToStr(T.SpotIdx + 1), 4) +
       '  ' + PadLeft(MoneyStr(T.Paid), 10);
  DlgListAdd(D, ILst, S);
 End;
 If N = 0 Then DlgListAdd(D, ILst, '(aucune transaction encore)');
 DlgAddButton(D, 220, 320, 90, 'Fermer', 1, 'F');
 DlgRun(D);
End;

{ --- Repartition par duree --- }

Procedure DlgDurationStats;
Var
 D: TDialog;
 Counts: Array[0..MAX_DURATIONS - 1] Of Integer;
 Y, I, Total, ILst: Integer;
 S: String;
 Pct: Real;
Begin
 For I := 0 To MAX_DURATIONS - 1 Do Counts[I] := 0;
 Total := 0;
 For I := 0 To SpotCount - 1 Do
  If Spots[I].State = ssOccupied Then Begin
   Inc(Counts[Spots[I].DurCode]);
   Inc(Total);
  End;
 DlgInit(D, 'Repartition des reservations par duree', 420, 320);
 Y := 10;
 DlgAddLabel(D, 16, Y, 'Total occupees actuellement : ' + IntToStr(Total));
 Y := Y + 18;
 DlgAddHLine(D, 16, Y, 388);                                Y := Y + 8;
 ILst := DlgAddList(D, 16, Y, 388, 200);
 For I := 0 To MAX_DURATIONS - 1 Do Begin
  If Total = 0 Then Pct := 0
  Else Pct := (Counts[I] * 100.0) / Total;
  S := PadRight(Pricing[I].Label_, 12) +
       '  ' + PadLeft(IntToStr(Counts[I]), 4) +
       '   ' + PadLeft(RealToStr(Pct, 1, 1), 5) + '%' +
       '   (a ' + MoneyStr(Pricing[I].Price) + ')';
  DlgListAdd(D, ILst, S);
 End;
 DlgAddButton(D, 170, 280, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- A propos --- }

Procedure DlgAbout;
Var D: TDialog;
Begin
 DlgInit(D, 'A propos de PARKING', 400, 240);
 DlgAddLabel(D, 80, 10,  'PARKING Management System');
 DlgAddLabel(D, 130, 30, 'Version ' + PARKING_VERSION);
 DlgAddLabel(D, 130, 46, 'Date : ' + PARKING_DATE);
 DlgAddHLine(D, 20, 70, 360);
 DlgAddLabel(D, 20, 80,  'Auteur : Sylvain Maltais');
 DlgAddLabel(D, 20, 96,  'Site   : www.gladir.com/physiq');
 DlgAddLabel(D, 20, 112, 'Cible  : Turbo Pascal 7 / Free Pascal');
 DlgAddLabel(D, 20, 134, 'Programme de gestion complete d''un parc');
 DlgAddLabel(D, 20, 148, 'de stationnements automobile avec sauvegarde,');
 DlgAddLabel(D, 20, 162, 'tarification configurable et statistiques.');
 DlgAddButton(D, 160, 200, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- Raccourcis clavier --- }

Procedure DlgKeys;
Var D: TDialog; Y: Integer;
Begin
 DlgInit(D, 'Raccourcis clavier', 460, 320);
 Y := 10;
 DlgAddLabel(D, 16, Y, 'F2       Configurer la grille');                Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F3       Tarification');                        Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F5       Reserver / Rafraichir');               Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F6       Liberer une place');                   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F7       Etendre une reservation');             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F8       Infos sur une place');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F9       Rechercher par plaque');               Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+N   Nouveau parking');                     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+O   Ouvrir fichier');                      Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+S   Enregistrer');                         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Alt+X    Quitter');                             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Souris : clic sur une place pour ses infos.'); Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Tab / Maj+Tab : naviguer dans les dialogues.'); Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Entree = OK, Echap = Annuler.');
 DlgAddButton(D, 190, 280, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

Procedure DlgUsage;
Var D: TDialog; Y: Integer;
Begin
 DlgInit(D, 'Mode d''emploi', 500, 330);
 Y := 8;
 DlgAddLabel(D, 16, Y, 'PARKING gere un parc de stationnements.');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Chaque place est verte (libre) ou rouge (occupee),');     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'jaune si la reservation expire dans moins de 30 min,');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'rouge fonce si la reservation est deja expiree.');        Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'POUR RESERVER : cliquez une place libre ou F5.');         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'POUR LIBERER : cliquez une place occupee, "Liberer".');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'POUR ETENDRE : cliquez une place occupee, "Etendre".');   Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'Configurez la taille de la grille via Edition>Config.'); Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Reglez les tarifs via Edition>Tarification.');           Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Sauvegardez l etat via Fichier>Enregistrer.');           Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'Le revenu journalier se reinitialise automatiquement');  Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'au changement de jour, et est archive dans l historique.');
 DlgAddButton(D, 210, 290, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- Save / Load via input box --- }

Procedure DlgSaveAs;
Var FName: String;
Begin
 FName := CurrentFile;
 If FName = '' Then FName := 'parking.dat';
 If ShowInputBox('Enregistrer sous', 'Nom du fichier :', FName, 80) Then
  SaveToFile(FName);
End;

Procedure DlgOpenFile;
Var FName: String;
Begin
 FName := CurrentFile;
 If FName = '' Then FName := 'parking.dat';
 If ShowInputBox('Ouvrir fichier', 'Nom du fichier :', FName, 80) Then Begin
  LoadFromFile(FName);
  RedrawAll;
 End;
End;

Procedure DlgNewParking;
Begin
 If ShowConfirmBox('Nouveau',
                   'Effacer toutes les reservations et repartir a zero ?') Then
 Begin
  ClearAllSpots;
  DailyRevenue := 0;
  DailyReservations := 0;
  DailyReleases := 0;
  TransCnt := 0; TransHead := 0;
  CurrentFile := '';
  RedrawAll;
 End;
End;

{ ============================================================
  DISPATCHER DES MENUS
  ============================================================ }

Procedure ExecuteMenuItem(Var Item: TMenuItem);
Var P: String; I: Integer;
Begin
 P := '';
 Case Item.Tag Of
  TAG_FILE_NEW:     DlgNewParking;
  TAG_FILE_OPEN:    DlgOpenFile;
  TAG_FILE_SAVE:    Begin
   If CurrentFile = '' Then DlgSaveAs
   Else Begin
    SaveToFile(CurrentFile);
    ShowMessageBox('Enregistrement',
                   'Sauvegarde dans ' + CurrentFile);
   End;
  End;
  TAG_FILE_SAVEAS:  DlgSaveAs;
  TAG_FILE_QUIT:    Begin
   If ShowConfirmBox('Quitter', 'Quitter PARKING ?') Then
    QuitRequested := True;
  End;
  TAG_EDIT_CONFIG:  DlgConfigureGrid;
  TAG_EDIT_PRICING: DlgConfigurePricing;
  TAG_EDIT_FREEALL: Begin
   If ShowConfirmBox('Confirmation',
                     'Liberer toutes les places ?') Then
    ClearAllSpots;
  End;
  TAG_PARK_RESERVE: DlgReserve(-1);
  TAG_PARK_FREE:    DlgFreeSpot;
  TAG_PARK_INFO:    Begin
   P := '';
   If ShowInputBox('Place', 'Numero de la place :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) Then DlgSpotInfo(I)
    Else ShowMessageBox('Erreur', 'Numero invalide.');
   End;
  End;
  TAG_PARK_EXTEND:  Begin
   P := '';
   If ShowInputBox('Etendre', 'Numero de la place :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) And
       (Spots[I].State = ssOccupied) Then DlgSpotInfo(I)
    Else ShowMessageBox('Erreur', 'Place invalide ou libre.');
   End;
  End;
  TAG_PARK_SEARCH:  DlgSearchByPlate;
  TAG_PARK_FORCE:   Begin
   P := '';
   If ShowInputBox('Forcer la liberation',
                   'Numero de la place :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) Then Begin
     If ShowConfirmBox('Forcer',
                       'Liberer la place ' + IntToStr(I + 1) +
                       ' sans confirmation ?') Then
      FreeSpot(I);
    End;
   End;
  End;
  TAG_STAT_OCCUPY:   DlgOccupancyStats;
  TAG_STAT_REVENUE:  DlgRevenueReport;
  TAG_STAT_HISTORY:  DlgHistory;
  TAG_STAT_DURATIONS:DlgDurationStats;
  TAG_VIEW_REFRESH:  RedrawAll;
  TAG_VIEW_ZOOM_NORM: Begin
   ColCount := IClamp(ColCount, 1, MAX_COLS);
   RowCount := IClamp(RowCount, 1, MAX_ROWS);
   RedrawAll;
  End;
  TAG_HELP_ABOUT:  DlgAbout;
  TAG_HELP_KEYS:   DlgKeys;
  TAG_HELP_USAGE:  DlgUsage;

  { --- Abonnements --- }
  TAG_SUB_LIST:    DlgListSubscriptions;
  TAG_SUB_ADD:     DlgAddSubscription;
  TAG_SUB_RENEW:   DlgRenewSubscription;
  TAG_SUB_DELETE:  DlgDeleteSubscription;
  TAG_SUB_SEARCH:  DlgSearchSubscription;
  TAG_SUB_PRICES:  DlgConfigureSubPricing;

  { --- Tarifs multi-zones --- }
  TAG_TARIFF_ZONES:   DlgConfigureTariffs;
  TAG_TARIFF_TOGGLE:  DlgToggleTariffs;
  TAG_TARIFF_PREVIEW: DlgPreviewTariffs;
  TAG_TARIFF_RESET:   Begin InitDefaultTariffs;
                            ShowMessageBox('Tarifs', 'Zones par defaut restaurees.');
                      End;

  { --- Historique avance --- }
  TAG_HIST_FILTER: Begin DlgFilterHistory; DlgDetailedHistory; End;
  TAG_HIST_CLEAR:  Begin
   If ShowConfirmBox('Effacer',
        'Effacer tout l''historique de transactions ?') Then Begin
    TransCnt := 0; TransHead := 0;
   End;
  End;

  { --- Rapports --- }
  TAG_REPORT_DAILY:     DlgReportDaily;
  TAG_REPORT_WEEKLY:    DlgReportWeekly;
  TAG_REPORT_MONTHLY:   DlgReportMonthly;
  TAG_REPORT_SUBS:      DlgReportSubs;
  TAG_REPORT_OCCUPANCY: DlgReportOccupancy;

  { --- Graphiques --- }
  TAG_GRAPH_DAILY:   DlgGraphDailyRevenue;
  TAG_GRAPH_MONTHLY: DlgGraphMonthlyTrend;
  TAG_GRAPH_BYDUR:   DlgGraphByDuration;
  TAG_GRAPH_OCCUPY:  DlgGraphOccupancy;
  TAG_GRAPH_SUBS:    DlgGraphSubs;
  TAG_GRAPH_HOURS:   DlgGraphHourlyActivity;

  { --- Export CSV --- }
  TAG_CSV_TRANS:   DlgExportCSV(0);
  TAG_CSV_SUBS:    DlgExportCSV(1);
  TAG_CSV_SPOTS:   DlgExportCSV(2);
  TAG_CSV_DAILY:   DlgExportCSV(3);
  TAG_CSV_PRICING: DlgExportCSV(4);
  TAG_CSV_ALL:     DlgExportCSV(5);
 End;
 RedrawAll;
End;

{ ============================================================
  ============================================================
  MODULES ETENDUS
  Multi-tarifs, Abonnements, Historique avance, CSV, Graphiques,
  Rapports
  ============================================================
  ============================================================ }

{ --- Helpers communs --- }

Function DayMaskFromDate(Const DT: TDateTime): Byte;
{ Renvoie le bit correspondant au jour de la semaine de DT.
  Algo Zeller pour eviter de dependre d un Dos.DayOfWeek absent. }
Var Y, M, K, J, H: LongInt; DOW: Byte;
Begin
 Y := DT.Year; M := DT.Month;
 If M < 3 Then Begin M := M + 12; Y := Y - 1; End;
 K := Y Mod 100;
 J := Y Div 100;
 H := (DT.Day + (13 * (M + 1)) Div 5 + K + K Div 4 + J Div 4 + 5 * J) Mod 7;
 { Zeller : 0=Sam, 1=Dim, 2=Lun, ... 6=Ven }
 Case H Of
  0: DOW := DAY_SAT;
  1: DOW := DAY_SUN;
  2: DOW := DAY_MON;
  3: DOW := DAY_TUE;
  4: DOW := DAY_WED;
  5: DOW := DAY_THU;
  6: DOW := DAY_FRI;
  Else DOW := 0;
 End;
 DayMaskFromDate := DOW;
End;

Function BoolToStr(B: Boolean): String;
Begin If B Then BoolToStr := 'oui' Else BoolToStr := 'non'; End;

Function DayMaskLabel(Mask: Byte): String;
{ Convertit un masque de jours en abreviation compacte. }
Var S: String;
Begin
 S := '';
 If (Mask And DAY_MON) <> 0 Then S := S + 'L';
 If (Mask And DAY_TUE) <> 0 Then S := S + 'M';
 If (Mask And DAY_WED) <> 0 Then S := S + 'M';
 If (Mask And DAY_THU) <> 0 Then S := S + 'J';
 If (Mask And DAY_FRI) <> 0 Then S := S + 'V';
 If (Mask And DAY_SAT) <> 0 Then S := S + 'S';
 If (Mask And DAY_SUN) <> 0 Then S := S + 'D';
 If S = '' Then S := '-';
 DayMaskLabel := S;
End;

Function FormatHourRange(SH, EH: Byte): String;
{ "08h-18h" }
Begin
 FormatHourRange := IntToStrW(SH, 2) + 'h-' + IntToStrW(EH, 2) + 'h';
End;

{ ============================================================
  MODULE 1 : TARIFICATION MULTI-ZONES (jour/nuit/weekend/ferie)
  ============================================================ }

Procedure InitDefaultTariffs;
Begin
 TariffCount := 4;

 TariffZones[TZ_DAY].Name       := 'Jour ouvrable';
 TariffZones[TZ_DAY].StartHour  := 8;
 TariffZones[TZ_DAY].EndHour    := 18;
 TariffZones[TZ_DAY].DayMask    := DAY_WEEKDAYS;
 TariffZones[TZ_DAY].Multiplier := 1.00;
 TariffZones[TZ_DAY].Enabled    := True;

 TariffZones[TZ_NIGHT].Name       := 'Nuit';
 TariffZones[TZ_NIGHT].StartHour  := 18;
 TariffZones[TZ_NIGHT].EndHour    := 8;
 TariffZones[TZ_NIGHT].DayMask    := DAY_ALL;
 TariffZones[TZ_NIGHT].Multiplier := 0.70;
 TariffZones[TZ_NIGHT].Enabled    := True;

 TariffZones[TZ_WEEKEND].Name       := 'Fin de semaine';
 TariffZones[TZ_WEEKEND].StartHour  := 0;
 TariffZones[TZ_WEEKEND].EndHour    := 23;
 TariffZones[TZ_WEEKEND].DayMask    := DAY_WEEKEND;
 TariffZones[TZ_WEEKEND].Multiplier := 1.20;
 TariffZones[TZ_WEEKEND].Enabled    := True;

 TariffZones[TZ_HOLIDAY].Name       := 'Jour ferie';
 TariffZones[TZ_HOLIDAY].StartHour  := 0;
 TariffZones[TZ_HOLIDAY].EndHour    := 23;
 TariffZones[TZ_HOLIDAY].DayMask    := DAY_ALL;
 TariffZones[TZ_HOLIDAY].Multiplier := 1.50;
 TariffZones[TZ_HOLIDAY].Enabled    := False;

 TariffEnabled := True;
End;

Function HourInZone(H: Byte; SH, EH: Byte): Boolean;
{ Renvoie True si l heure H est dans la plage [SH..EH) avec
  passage minuit autorise (EH <= SH). }
Begin
 If SH = EH Then HourInZone := True
 Else If SH < EH Then HourInZone := (H >= SH) And (H < EH)
 Else HourInZone := (H >= SH) Or (H < EH);
End;

Function GetTariffZoneIdx(Const DT: TDateTime): Integer;
{ Premiere zone activee qui correspond au jour ET a l heure de DT.
  Renvoie -1 si aucune (tarif de base). }
Var I: Integer; DM: Byte;
Begin
 GetTariffZoneIdx := -1;
 If Not TariffEnabled Then Exit;
 DM := DayMaskFromDate(DT);
 For I := 0 To TariffCount - 1 Do
  If TariffZones[I].Enabled Then
   If (TariffZones[I].DayMask And DM) <> 0 Then
    If HourInZone(DT.Hour,
                  TariffZones[I].StartHour,
                  TariffZones[I].EndHour) Then Begin
     GetTariffZoneIdx := I;
     Exit;
    End;
End;

Function GetTariffMultiplier(Const DT: TDateTime): Real;
Var I: Integer;
Begin
 I := GetTariffZoneIdx(DT);
 If I < 0 Then GetTariffMultiplier := 1.00
 Else GetTariffMultiplier := TariffZones[I].Multiplier;
End;

Function GetTariffZoneName(Const DT: TDateTime): String;
Var I: Integer;
Begin
 I := GetTariffZoneIdx(DT);
 If I < 0 Then GetTariffZoneName := 'Base'
 Else GetTariffZoneName := TariffZones[I].Name;
End;

Function ComputeFinalPrice(BaseCode: TDurCode;
                           Const StartDT: TDateTime): Real;
{ Prix de base * multiplicateur de la zone active au moment de StartDT. }
Var Base, Mul: Real;
Begin
 Base := Pricing[BaseCode].Price;
 Mul := GetTariffMultiplier(StartDT);
 ComputeFinalPrice := Base * Mul;
End;

Procedure DlgConfigureTariffs;
{ Configure les zones tarifaires (activation, multiplicateur,
  plage horaire, jours). }
Var
 D: TDialog;
 IEnabled: Array[0..MAX_TARIFFS - 1] Of Integer;
 IMul    : Array[0..MAX_TARIFFS - 1] Of Integer;
 ISH     : Array[0..MAX_TARIFFS - 1] Of Integer;
 IEH     : Array[0..MAX_TARIFFS - 1] Of Integer;
 IDM     : Array[0..MAX_TARIFFS - 1] Of Integer;
 IGlobal : Integer;
 I, R, Y: Integer;
 Tmp: String;
 ErrCode: Integer;
 RVal: Real;
 IVal: LongInt;
Begin
 DlgInit(D, 'Configuration des zones tarifaires', 600, 400);
 DlgAddFrame(D, 12, 4, 576, 30, '');
 IGlobal := DlgAddCheck(D, 24, 12, 220,
                       'Activer la tarification multi-zones',
                       TariffEnabled);
 DlgAddLabel(D, 12, 44,
   'Zone               Actif  x Mult    Debut  Fin   Jours');
 Y := 60;
 For I := 0 To TariffCount - 1 Do Begin
  DlgAddLabel(D, 12, Y + 4, TariffZones[I].Name);
  IEnabled[I] := DlgAddCheck(D, 150, Y, 20, '',
                             TariffZones[I].Enabled);
  Str(TariffZones[I].Multiplier:5:2, Tmp);
  IMul[I] := DlgAddEdit(D, 200, Y - 2, 56, Tmp, 5);
  Str(TariffZones[I].StartHour:0, Tmp);
  ISH[I]  := DlgAddEdit(D, 280, Y - 2, 40, Tmp, 2);
  Str(TariffZones[I].EndHour:0, Tmp);
  IEH[I]  := DlgAddEdit(D, 340, Y - 2, 40, Tmp, 2);
  IDM[I]  := DlgAddEdit(D, 400, Y - 2, 160,
                        DayMaskLabel(TariffZones[I].DayMask), 7);
  Y := Y + 26;
 End;
 DlgAddHLine(D, 12, Y + 4, 576);
 DlgAddLabel(D, 12, Y + 12,
   'Jours : L M M J V S D - tapez les lettres pour activer.');
 DlgAddButton(D, 200, 350, 90, 'OK',         1, 'O');
 DlgAddButton(D, 300, 350, 90, 'Defaut',     2, 'D');
 DlgAddButton(D, 400, 350, 90, 'Annuler',   -1, 'A');
 Repeat R := DlgRun(D); Until (R = 1) Or (R = 2) Or (R = -1);

 If R = 2 Then Begin
  InitDefaultTariffs;
  ShowMessageBox('Tarifs', 'Configuration par defaut restauree.');
  Exit;
 End;
 If R <> 1 Then Exit;

 TariffEnabled := D.Ctrls[IGlobal].Checked;
 For I := 0 To TariffCount - 1 Do Begin
  TariffZones[I].Enabled := D.Ctrls[IEnabled[I]].Checked;
  Val(D.Ctrls[IMul[I]].Text, RVal, ErrCode);
  If ErrCode = 0 Then TariffZones[I].Multiplier := RVal;
  Val(D.Ctrls[ISH[I]].Text, IVal, ErrCode);
  If (ErrCode = 0) And (IVal >= 0) And (IVal <= 23) Then
   TariffZones[I].StartHour := IVal;
  Val(D.Ctrls[IEH[I]].Text, IVal, ErrCode);
  If (ErrCode = 0) And (IVal >= 0) And (IVal <= 23) Then
   TariffZones[I].EndHour := IVal;
  { Recalcule DayMask depuis le texte affiche }
  Tmp := UpStr(D.Ctrls[IDM[I]].Text);
  TariffZones[I].DayMask := 0;
  If Pos('L', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_MON;
  If Pos('MA', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_TUE
  Else If Pos('M', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_TUE Or DAY_WED;
  If Pos('J', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_THU;
  If Pos('V', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_FRI;
  If Pos('S', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_SAT;
  If Pos('D', Tmp) > 0 Then
   TariffZones[I].DayMask := TariffZones[I].DayMask Or DAY_SUN;
 End;
 ShowMessageBox('Tarifs', 'Configuration sauvegardee.');
End;

Procedure DlgToggleTariffs;
Begin
 TariffEnabled := Not TariffEnabled;
 If TariffEnabled Then
  ShowMessageBox('Tarifs', 'Tarification multi-zones ACTIVEE.')
 Else
  ShowMessageBox('Tarifs', 'Tarification multi-zones DESACTIVEE.');
End;

Procedure DlgPreviewTariffs;
{ Affiche un apercu du prix de chaque duree avec la zone courante. }
Var Lines: TReportArray; LC, I, Z: Integer; CurDT: TDateTime;
    L: TReportLine;
Begin
 GetCurrentDT(CurDT);
 Z := GetTariffZoneIdx(CurDT);
 LC := 0;
 Lines[LC] := 'Apercu de la tarification au ' +
              FormatDateTime(CurDT); Inc(LC);
 If Z >= 0 Then
  Lines[LC] := 'Zone active : ' + TariffZones[Z].Name +
               '  (multiplicateur x' +
               RealToStr(TariffZones[Z].Multiplier, 4, 2) + ')'
 Else
  Lines[LC] := 'Zone active : tarif de base (multiplicateur x1.00)';
 Inc(LC);
 Lines[LC] := ''; Inc(LC);
 Lines[LC] :=
   ' Duree              Base          Final';
 Inc(LC);
 Lines[LC] :=
   ' --------------------------------------------';
 Inc(LC);
 For I := 0 To MAX_DURATIONS - 1 Do Begin
  L := ' ' + Pricing[I].Label_;
  While Length(L) < 20 Do L := L + ' ';
  L := L + MoneyStr(Pricing[I].Price);
  While Length(L) < 35 Do L := L + ' ';
  L := L + MoneyStr(ComputeFinalPrice(I, CurDT));
  Lines[LC] := L; Inc(LC);
 End;
 ShowReportDialog('Apercu tarifs', Lines, LC);
End;

{ ============================================================
  MODULE 2 : ABONNEMENTS CLIENTS
  ============================================================ }

Procedure InitDefaultSubPricing;
Begin
 SubPricing[SUB_WEEKLY].Label_   := 'Hebdomadaire';
 SubPricing[SUB_WEEKLY].Days     := 7;
 SubPricing[SUB_WEEKLY].Price    := 50.00;

 SubPricing[SUB_MONTHLY].Label_  := 'Mensuel';
 SubPricing[SUB_MONTHLY].Days    := 30;
 SubPricing[SUB_MONTHLY].Price   := 180.00;

 SubPricing[SUB_QUARTERLY].Label_:= 'Trimestriel';
 SubPricing[SUB_QUARTERLY].Days  := 90;
 SubPricing[SUB_QUARTERLY].Price := 500.00;

 SubPricing[SUB_YEARLY].Label_   := 'Annuel';
 SubPricing[SUB_YEARLY].Days     := 365;
 SubPricing[SUB_YEARLY].Price    := 1800.00;
End;

Procedure InitSubscriptions;
Var I: Integer;
Begin
 SubsCount := 0;
 NextSubID := 1001;
 For I := 0 To MAX_SUBSCRIPTIONS - 1 Do Begin
  Subs[I].Active := False;
  Subs[I].ID := 0;
  Subs[I].SubType := SUB_MONTHLY;
  Subs[I].Name := '';
  Subs[I].Plate := '';
  Subs[I].Phone := '';
  Subs[I].Email := '';
  Subs[I].AssignedSpot := -1;
  Subs[I].AutoRenew := False;
  Subs[I].RenewCount := 0;
  Subs[I].AmountPaid := 0;
 End;
End;

Function IsSubActive(Const S: TSubscription): Boolean;
Var CurDT: TDateTime;
Begin
 If Not S.Active Then Begin IsSubActive := False; Exit; End;
 GetCurrentDT(CurDT);
 IsSubActive := CompareDT(CurDT, S.EndDT) <= 0;
End;

Function FindActiveSubByPlate(Const APlate: TStr15): Integer;
Var I: Integer; P: TStr15;
Begin
 FindActiveSubByPlate := -1;
 P := UpStr(TrimStr(APlate));
 If P = '' Then Exit;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active And (UpStr(Subs[I].Plate) = P) Then
   If IsSubActive(Subs[I]) Then Begin
    FindActiveSubByPlate := I;
    Exit;
   End;
End;

Function FindSubByID(SubID: LongInt): Integer;
Var I: Integer;
Begin
 FindSubByID := -1;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active And (Subs[I].ID = SubID) Then Begin
   FindSubByID := I;
   Exit;
  End;
End;

Function SubDays(SubType: TSubType): LongInt;
Begin
 If SubType > 3 Then SubDays := SubPricing[SUB_MONTHLY].Days
 Else SubDays := SubPricing[SubType].Days;
End;

Function SubPrice(SubType: TSubType): Real;
Begin
 If SubType > 3 Then SubPrice := SubPricing[SUB_MONTHLY].Price
 Else SubPrice := SubPricing[SubType].Price;
End;

Function SubTypeLabel(SubType: TSubType): String;
Begin
 If SubType > 3 Then SubTypeLabel := '?'
 Else SubTypeLabel := SubPricing[SubType].Label_;
End;

Function AddSubscription(SubType: TSubType; Name: TStr31; Plate: TStr15;
                         Phone: TStr15; Email: String;
                         AssignedSpot: Integer;
                         AutoRenew: Boolean): Integer;
{ Renvoie l indice (>=0) ou -1 si plein. }
Var I, Idx: Integer;
Begin
 Idx := -1;
 For I := 0 To SubsCount - 1 Do
  If Not Subs[I].Active Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin
  If SubsCount >= MAX_SUBSCRIPTIONS Then Begin
   AddSubscription := -1; Exit;
  End;
  Idx := SubsCount; Inc(SubsCount);
 End;
 Subs[Idx].Active := True;
 Subs[Idx].ID := NextSubID; Inc(NextSubID);
 Subs[Idx].SubType := SubType;
 Subs[Idx].Name := TrimStr(Name);
 Subs[Idx].Plate := UpStr(TrimStr(Plate));
 Subs[Idx].Phone := TrimStr(Phone);
 Subs[Idx].Email := TrimStr(Email);
 GetCurrentDT(Subs[Idx].StartDT);
 Subs[Idx].EndDT := Subs[Idx].StartDT;
 AddDays(Subs[Idx].EndDT, SubDays(SubType));
 Subs[Idx].AmountPaid := SubPrice(SubType);
 Subs[Idx].AssignedSpot := AssignedSpot;
 Subs[Idx].AutoRenew := AutoRenew;
 Subs[Idx].RenewCount := 0;
 DailyRevenue := DailyRevenue + Subs[Idx].AmountPaid;
 RecordTransaction(Subs[Idx].Plate, Subs[Idx].Name,
                   Subs[Idx].StartDT, Subs[Idx].EndDT,
                   Subs[Idx].AmountPaid,
                   AssignedSpot, TXK_SUB_NEW);
 AddSubscription := Idx;
End;

Procedure RenewSub(Idx: Integer);
Var NewStart: TDateTime;
Begin
 If (Idx < 0) Or (Idx >= SubsCount) Or (Not Subs[Idx].Active) Then Exit;
 { On part de la date de fin si encore valide, sinon date courante }
 GetCurrentDT(NewStart);
 If CompareDT(NewStart, Subs[Idx].EndDT) < 0 Then
  NewStart := Subs[Idx].EndDT;
 Subs[Idx].StartDT := NewStart;
 Subs[Idx].EndDT := NewStart;
 AddDays(Subs[Idx].EndDT, SubDays(Subs[Idx].SubType));
 Subs[Idx].AmountPaid := Subs[Idx].AmountPaid + SubPrice(Subs[Idx].SubType);
 Inc(Subs[Idx].RenewCount);
 DailyRevenue := DailyRevenue + SubPrice(Subs[Idx].SubType);
 RecordTransaction(Subs[Idx].Plate, Subs[Idx].Name,
                   Subs[Idx].StartDT, Subs[Idx].EndDT,
                   SubPrice(Subs[Idx].SubType),
                   Subs[Idx].AssignedSpot, TXK_SUB_RENEW);
End;

Procedure DeleteSub(Idx: Integer);
Begin
 If (Idx < 0) Or (Idx >= SubsCount) Then Exit;
 Subs[Idx].Active := False;
End;

Procedure CheckExpiredSubs;
Var I: Integer;
Begin
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active And Subs[I].AutoRenew And (Not IsSubActive(Subs[I])) Then
   RenewSub(I);
End;

Function CountActiveSubs: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active And IsSubActive(Subs[I]) Then Inc(N);
 CountActiveSubs := N;
End;

Function TotalSubRevenue: Real;
Var I: Integer; T: Real;
Begin
 T := 0;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active Then T := T + Subs[I].AmountPaid;
 TotalSubRevenue := T;
End;

Procedure DlgAddSubscription;
{ Ajoute un nouvel abonnement (formulaire complet). }
Var
 D: TDialog;
 IName, IPlate, IPhone, IEmail, IAuto, ISpot: Integer;
 IRads: Array[0..SUB_TYPES - 1] Of Integer;
 ILabel: Integer;
 I, R, SelType, SpotIdx: Integer;
 Tmp: String;
 ErrCode: Integer;
 Val_: LongInt;
Begin
 DlgInit(D, 'Nouvel abonnement', 520, 380);

 DlgAddLabel(D, 16, 6, 'Nom client :');
 IName  := DlgAddEdit(D, 130, 4, 360, '', 30);

 DlgAddLabel(D, 16, 30, 'Plaque :');
 IPlate := DlgAddEdit(D, 130, 28, 180, '', 12);

 DlgAddLabel(D, 16, 54, 'Telephone :');
 IPhone := DlgAddEdit(D, 130, 52, 180, '', 15);

 DlgAddLabel(D, 16, 78, 'Courriel :');
 IEmail := DlgAddEdit(D, 130, 76, 360, '', 40);

 DlgAddFrame(D, 16, 110, 480, 110, 'Type d''abonnement');
 SelType := SUB_MONTHLY;
 For I := 0 To SUB_TYPES - 1 Do
  IRads[I] := DlgAddRadio(D, 30 + (I Mod 2) * 220,
                          130 + (I Div 2) * 22, 210,
                          SubPricing[I].Label_ + '  (' +
                          MoneyStr(SubPricing[I].Price) + ', ' +
                          IntToStr(SubPricing[I].Days) + ' j)',
                          1, I = SUB_MONTHLY);

 DlgAddLabel(D, 16, 230, 'Place attitree (0=aucune) :');
 ISpot  := DlgAddEdit(D, 230, 228, 60, '0', 4);
 IAuto  := DlgAddCheck(D, 310, 230, 180, 'Renouvellement auto', False);

 ILabel := DlgAddLabel(D, 16, 260,
                       'Montant a payer : ' +
                       MoneyStr(SubPricing[SUB_MONTHLY].Price));

 DlgAddButton(D, 200, 320, 90, 'Confirmer', 1, 'C');
 DlgAddButton(D, 300, 320, 90, 'Annuler',  -1, 'A');

 Repeat
  R := DlgRun(D);
  SelType := SUB_MONTHLY;
  For I := 0 To SUB_TYPES - 1 Do
   If D.Ctrls[IRads[I]].Checked Then SelType := I;
  D.Ctrls[ILabel].Caption := 'Montant a payer : ' +
                              MoneyStr(SubPricing[SelType].Price);
 Until R <> 0;

 If R <> 1 Then Exit;

 Tmp := TrimStr(D.Ctrls[IName].Text);
 If Tmp = '' Then Begin
  ShowMessageBox('Erreur', 'Le nom est obligatoire.'); Exit;
 End;
 If TrimStr(D.Ctrls[IPlate].Text) = '' Then Begin
  ShowMessageBox('Erreur', 'La plaque est obligatoire.'); Exit;
 End;

 SpotIdx := -1;
 Val(D.Ctrls[ISpot].Text, Val_, ErrCode);
 If (ErrCode = 0) And (Val_ > 0) And (Val_ <= SpotCount) Then
  SpotIdx := Val_ - 1;

 I := AddSubscription(SelType,
                      D.Ctrls[IName].Text,
                      D.Ctrls[IPlate].Text,
                      D.Ctrls[IPhone].Text,
                      D.Ctrls[IEmail].Text,
                      SpotIdx,
                      D.Ctrls[IAuto].Checked);
 If I < 0 Then
  ShowMessageBox('Erreur', 'Capacite maximum d''abonnements atteinte.')
 Else
  ShowMessageBox('Abonnement',
                 'Abonnement ' + IntToStr(Subs[I].ID) +
                 ' cree.  Echeance : ' + FormatDateTime(Subs[I].EndDT));
End;

Procedure DlgListSubscriptions;
{ Affiche la liste des abonnements actifs avec details. }
Var
 D: TDialog;
 IList, IDetail, IRenew, IDel, IClose: Integer;
 SubIdx: Array[0..MAX_LIST - 1] Of Integer;
 I, J, R, K: Integer;
 Line: String;
 Detail: String;
Begin
 DlgInit(D, 'Abonnements clients', 600, 400);
 DlgAddLabel(D, 12, 4, 'ID    Type        Plaque   Nom              Expire le');
 IList := DlgAddList(D, 12, 18, 576, 220);
 J := 0;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active Then Begin
   If J >= MAX_LIST Then Break;
   Line := IntToStrW(Subs[I].ID, 4) + '  ';
   Line := Line + SubTypeLabel(Subs[I].SubType);
   While Length(Line) < 18 Do Line := Line + ' ';
   Line := Line + Subs[I].Plate;
   While Length(Line) < 28 Do Line := Line + ' ';
   Line := Line + Subs[I].Name;
   While Length(Line) < 45 Do Line := Line + ' ';
   Line := Line + FormatDateTime(Subs[I].EndDT);
   D.Ctrls[IList].ListItems[J] := Copy(Line, 1, 63);
   SubIdx[J] := I;
   Inc(J);
  End;
 D.Ctrls[IList].ListCount := J;
 D.Ctrls[IList].ListSel := 0;

 IDetail := DlgAddLabel(D, 12, 248, '');
 If J > 0 Then Begin
  K := SubIdx[0];
  Detail := 'Detail : ' + Subs[K].Name + ' / ' + Subs[K].Plate +
            ' / tel:' + Subs[K].Phone +
            ' / paye:' + MoneyStr(Subs[K].AmountPaid);
  D.Ctrls[IDetail].Caption := Copy(Detail, 1, 78);
 End;

 IRenew := DlgAddButton(D, 100, 350, 110, 'Renouveler', 2, 'R');
 IDel   := DlgAddButton(D, 220, 350, 110, 'Supprimer',  3, 'S');
 IClose := DlgAddButton(D, 360, 350, 100, 'Fermer',    -1, 'F');

 Repeat
  R := DlgRun(D);
  K := D.Ctrls[IList].ListSel;
  If (K >= 0) And (K < J) Then Begin
   I := SubIdx[K];
   Detail := 'Detail : ' + Subs[I].Name + ' / ' + Subs[I].Plate +
             ' / tel:' + Subs[I].Phone +
             ' / paye:' + MoneyStr(Subs[I].AmountPaid);
   D.Ctrls[IDetail].Caption := Copy(Detail, 1, 78);
  End;
  Case R Of
   2: If (K >= 0) And (K < J) Then Begin
       I := SubIdx[K];
       If ShowConfirmBox('Renouveler',
            'Renouveler l''abonnement de ' + Subs[I].Name + ' ?') Then Begin
        RenewSub(I);
        ShowMessageBox('Renouvellement',
          'Renouvele jusqu''au ' + FormatDateTime(Subs[I].EndDT));
       End;
       Exit;
      End;
   3: If (K >= 0) And (K < J) Then Begin
       I := SubIdx[K];
       If ShowConfirmBox('Supprimer',
            'Supprimer l''abonnement de ' + Subs[I].Name + ' ?') Then
        DeleteSub(I);
       Exit;
      End;
  End;
 Until R = -1;
End;

Procedure DlgRenewSubscription;
{ Renouvelle un abonnement par ID. }
Var ID: String; SubID: LongInt; I, ErrCode: Integer;
Begin
 ID := '';
 If Not ShowInputBox('Renouvellement',
                     'Numero d''abonnement :', ID, 6) Then Exit;
 Val(ID, SubID, ErrCode);
 If ErrCode <> 0 Then Begin
  ShowMessageBox('Erreur', 'Numero invalide.'); Exit;
 End;
 I := FindSubByID(SubID);
 If I < 0 Then Begin
  ShowMessageBox('Erreur', 'Abonnement introuvable.'); Exit;
 End;
 If Not ShowConfirmBox('Renouveler',
       'Renouveler abonnement ' + IntToStr(SubID) +
       ' (' + Subs[I].Name + ') ?') Then Exit;
 RenewSub(I);
 ShowMessageBox('Renouvellement',
                'Renouvele.  Nouvelle echeance : ' +
                FormatDateTime(Subs[I].EndDT));
End;

Procedure DlgDeleteSubscription;
Var ID: String; SubID: LongInt; I, ErrCode: Integer;
Begin
 ID := '';
 If Not ShowInputBox('Suppression',
                     'Numero d''abonnement :', ID, 6) Then Exit;
 Val(ID, SubID, ErrCode);
 If ErrCode <> 0 Then Begin
  ShowMessageBox('Erreur', 'Numero invalide.'); Exit;
 End;
 I := FindSubByID(SubID);
 If I < 0 Then Begin
  ShowMessageBox('Erreur', 'Abonnement introuvable.'); Exit;
 End;
 If Not ShowConfirmBox('Supprimer',
       'Supprimer abonnement ' + IntToStr(SubID) +
       ' (' + Subs[I].Name + ') ?') Then Exit;
 DeleteSub(I);
 ShowMessageBox('Suppression', 'Abonnement supprime.');
End;

Procedure DlgSearchSubscription;
Var P: String; I: Integer; S: TSubscription;
Begin
 P := '';
 If Not ShowInputBox('Recherche abonnement',
                     'Plaque a rechercher :', P, 12) Then Exit;
 I := FindActiveSubByPlate(P);
 If I < 0 Then Begin
  ShowMessageBox('Recherche',
                 'Aucun abonnement actif pour cette plaque.');
  Exit;
 End;
 S := Subs[I];
 ShowMessageBox('Abonnement #' + IntToStr(S.ID),
   'Client : ' + S.Name + #13#10 +
   'Plaque : ' + S.Plate + #13#10 +
   'Type   : ' + SubTypeLabel(S.SubType) + #13#10 +
   'Debut  : ' + FormatDateTime(S.StartDT) + #13#10 +
   'Fin    : ' + FormatDateTime(S.EndDT) + #13#10 +
   'Paye   : ' + MoneyStr(S.AmountPaid) + #13#10 +
   'Place  : ' +
     IntToStr(S.AssignedSpot + 1));
End;

Procedure DlgConfigureSubPricing;
Var
 D: TDialog;
 IPrice: Array[0..SUB_TYPES - 1] Of Integer;
 IDays : Array[0..SUB_TYPES - 1] Of Integer;
 I, R: Integer; Tmp: String; ErrCode: Integer;
 RVal: Real; IVal: LongInt;
Begin
 DlgInit(D, 'Tarifs des abonnements', 460, 250);
 DlgAddLabel(D, 16, 8,
   'Type              Prix ($)   Duree (jours)');
 For I := 0 To SUB_TYPES - 1 Do Begin
  DlgAddLabel(D, 16, 36 + I * 26, SubPricing[I].Label_);
  Str(SubPricing[I].Price:0:2, Tmp);
  IPrice[I] := DlgAddEdit(D, 160, 32 + I * 26, 100, Tmp, 8);
  Str(SubPricing[I].Days:0, Tmp);
  IDays[I]  := DlgAddEdit(D, 290, 32 + I * 26, 80, Tmp, 4);
 End;
 DlgAddButton(D, 130, 180, 90, 'OK',       1, 'O');
 DlgAddButton(D, 230, 180, 90, 'Defaut',   2, 'D');
 DlgAddButton(D, 330, 180, 90, 'Annuler', -1, 'A');
 Repeat R := DlgRun(D); Until R <> 0;

 If R = 2 Then Begin InitDefaultSubPricing; Exit; End;
 If R <> 1 Then Exit;
 For I := 0 To SUB_TYPES - 1 Do Begin
  Val(D.Ctrls[IPrice[I]].Text, RVal, ErrCode);
  If ErrCode = 0 Then SubPricing[I].Price := RVal;
  Val(D.Ctrls[IDays[I]].Text, IVal, ErrCode);
  If (ErrCode = 0) And (IVal > 0) Then SubPricing[I].Days := IVal;
 End;
End;

{ ============================================================
  MODULE 3 : HISTORIQUE TRANSACTIONNEL DETAILLE
  ============================================================ }

Function TxKindLabel(K: Byte): String;
Begin
 Case K Of
  TXK_RESERVE  : TxKindLabel := 'RES';
  TXK_RELEASE  : TxKindLabel := 'LIB';
  TXK_EXTEND   : TxKindLabel := 'EXT';
  TXK_SUB_NEW  : TxKindLabel := 'ABN';
  TXK_SUB_RENEW: TxKindLabel := 'RNV';
  Else TxKindLabel := '???';
 End;
End;

Function GetTransactionAt(Logical: Integer; Var T: TTransaction): Boolean;
{ Acces logique (0 = plus ancien) dans l anneau circulaire. }
Var Start, Tot, Pos_: Integer;
Begin
 GetTransactionAt := False;
 If TransCnt = 0 Then Exit;
 Tot := TransCnt;
 If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;
 If (Logical < 0) Or (Logical >= Tot) Then Exit;
 If TransCnt <= MAX_HISTORY Then Start := 0
 Else Start := TransHead;
 Pos_ := (Start + Logical) Mod MAX_HISTORY;
 T := Transactions[Pos_];
 GetTransactionAt := True;
End;

Function ResetFilter: TFilterCriteria;
Var F: TFilterCriteria;
Begin
 F.HasDateRange := False;
 F.PlateFrag := '';
 F.KindMask := $FF;
 F.SpotFrom := -1;
 F.SpotTo := -1;
 F.MinAmount := 0;
 ResetFilter := F;
End;

Function MatchFilter(Const T: TTransaction;
                     Const F: TFilterCriteria): Boolean;
Var OK: Boolean;
Begin
 OK := True;
 If F.HasDateRange Then Begin
  If CompareDT(T.StartDT, F.FromDT) < 0 Then OK := False;
  If CompareDT(T.StartDT, F.ToDT) > 0 Then OK := False;
 End;
 If OK And (F.PlateFrag <> '') Then
  If Pos(UpStr(F.PlateFrag), UpStr(T.Plate)) = 0 Then OK := False;
 If OK Then
  If (F.KindMask And (Byte(1) Shl T.Kind)) = 0 Then OK := False;
 If OK And (F.SpotFrom >= 0) Then Begin
  If T.SpotIdx < F.SpotFrom Then OK := False;
  If (F.SpotTo >= 0) And (T.SpotIdx > F.SpotTo) Then OK := False;
 End;
 If OK And (F.MinAmount > 0) Then
  If T.Paid < F.MinAmount Then OK := False;
 MatchFilter := OK;
End;

Procedure DlgFilterHistory;
{ Edite les criteres de filtre courants LastFilter. }
Var
 D: TDialog;
 IPlate, ISpotF, ISpotT, IMin: Integer;
 IDate, IFromY, IFromM, IFromD, IToY, IToM, IToD: Integer;
 IRes, ILib, IExt, ISubN, ISubR: Integer;
 R, ErrCode: Integer;
 Tmp: String; Val_: LongInt; RVal: Real;
Begin
 DlgInit(D, 'Filtrer l''historique', 520, 340);

 IDate := DlgAddCheck(D, 16, 10, 220, 'Filtrer par date',
                      LastFilter.HasDateRange);
 DlgAddLabel(D, 16, 32, 'De   AAAA');
 Str(LastFilter.FromDT.Year:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := IntToStr(NowDT.Year);
 IFromY := DlgAddEdit(D, 90, 30, 60, Tmp, 4);
 DlgAddLabel(D, 156, 32, 'MM'); Str(LastFilter.FromDT.Month:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := IntToStr(NowDT.Month);
 IFromM := DlgAddEdit(D, 180, 30, 40, Tmp, 2);
 DlgAddLabel(D, 226, 32, 'JJ'); Str(LastFilter.FromDT.Day:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := '01';
 IFromD := DlgAddEdit(D, 250, 30, 40, Tmp, 2);

 DlgAddLabel(D, 16, 56, 'A    AAAA');
 Str(LastFilter.ToDT.Year:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := IntToStr(NowDT.Year);
 IToY := DlgAddEdit(D, 90, 54, 60, Tmp, 4);
 DlgAddLabel(D, 156, 56, 'MM'); Str(LastFilter.ToDT.Month:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := IntToStr(NowDT.Month);
 IToM := DlgAddEdit(D, 180, 54, 40, Tmp, 2);
 DlgAddLabel(D, 226, 56, 'JJ'); Str(LastFilter.ToDT.Day:0, Tmp);
 If Not LastFilter.HasDateRange Then Tmp := '31';
 IToD := DlgAddEdit(D, 250, 54, 40, Tmp, 2);

 DlgAddLabel(D, 16, 88, 'Plaque contient :');
 IPlate := DlgAddEdit(D, 160, 86, 200, LastFilter.PlateFrag, 12);

 DlgAddLabel(D, 16, 112, 'Place no de :');
 If LastFilter.SpotFrom < 0 Then Tmp := ''
 Else Begin Str(LastFilter.SpotFrom + 1:0, Tmp); End;
 ISpotF := DlgAddEdit(D, 160, 110, 60, Tmp, 4);
 DlgAddLabel(D, 230, 112, 'a :');
 If LastFilter.SpotTo < 0 Then Tmp := ''
 Else Begin Str(LastFilter.SpotTo + 1:0, Tmp); End;
 ISpotT := DlgAddEdit(D, 260, 110, 60, Tmp, 4);

 DlgAddLabel(D, 16, 136, 'Montant minimum ($) :');
 Str(LastFilter.MinAmount:0:2, Tmp);
 IMin := DlgAddEdit(D, 200, 134, 80, Tmp, 8);

 DlgAddFrame(D, 16, 162, 480, 70, 'Types de transactions');
 IRes  := DlgAddCheck(D, 30, 184, 100, 'Reservations',
                      (LastFilter.KindMask And 1) <> 0);
 ILib  := DlgAddCheck(D, 140, 184, 100, 'Liberations',
                      (LastFilter.KindMask And 2) <> 0);
 IExt  := DlgAddCheck(D, 260, 184, 100, 'Extensions',
                      (LastFilter.KindMask And 4) <> 0);
 ISubN := DlgAddCheck(D,  30, 208, 100, 'Abonnements',
                      (LastFilter.KindMask And 8) <> 0);
 ISubR := DlgAddCheck(D, 140, 208, 120, 'Renouvellements',
                      (LastFilter.KindMask And 16) <> 0);

 DlgAddButton(D, 140, 290, 90, 'Appliquer', 1, 'A');
 DlgAddButton(D, 240, 290, 90, 'Reset',     2, 'R');
 DlgAddButton(D, 340, 290, 90, 'Annuler',  -1, 'N');

 Repeat R := DlgRun(D); Until R <> 0;

 If R = 2 Then Begin LastFilter := ResetFilter; Exit; End;
 If R <> 1 Then Exit;

 LastFilter.HasDateRange := D.Ctrls[IDate].Checked;
 If LastFilter.HasDateRange Then Begin
  Val(D.Ctrls[IFromY].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.FromDT.Year := Val_;
  Val(D.Ctrls[IFromM].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.FromDT.Month := Val_;
  Val(D.Ctrls[IFromD].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.FromDT.Day := Val_;
  LastFilter.FromDT.Hour := 0; LastFilter.FromDT.Min := 0;
  Val(D.Ctrls[IToY].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.ToDT.Year := Val_;
  Val(D.Ctrls[IToM].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.ToDT.Month := Val_;
  Val(D.Ctrls[IToD].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.ToDT.Day := Val_;
  LastFilter.ToDT.Hour := 23; LastFilter.ToDT.Min := 59;
 End;
 LastFilter.PlateFrag := TrimStr(D.Ctrls[IPlate].Text);
 If TrimStr(D.Ctrls[ISpotF].Text) = '' Then LastFilter.SpotFrom := -1
 Else Begin
  Val(D.Ctrls[ISpotF].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.SpotFrom := Val_ - 1
  Else LastFilter.SpotFrom := -1;
 End;
 If TrimStr(D.Ctrls[ISpotT].Text) = '' Then LastFilter.SpotTo := -1
 Else Begin
  Val(D.Ctrls[ISpotT].Text, Val_, ErrCode);
  If ErrCode = 0 Then LastFilter.SpotTo := Val_ - 1
  Else LastFilter.SpotTo := -1;
 End;
 Val(D.Ctrls[IMin].Text, RVal, ErrCode);
 If ErrCode = 0 Then LastFilter.MinAmount := RVal
 Else LastFilter.MinAmount := 0;
 LastFilter.KindMask := 0;
 If D.Ctrls[IRes].Checked  Then LastFilter.KindMask := LastFilter.KindMask Or 1;
 If D.Ctrls[ILib].Checked  Then LastFilter.KindMask := LastFilter.KindMask Or 2;
 If D.Ctrls[IExt].Checked  Then LastFilter.KindMask := LastFilter.KindMask Or 4;
 If D.Ctrls[ISubN].Checked Then LastFilter.KindMask := LastFilter.KindMask Or 8;
 If D.Ctrls[ISubR].Checked Then LastFilter.KindMask := LastFilter.KindMask Or 16;
End;

Procedure DlgDetailedHistory;
{ Affiche l historique filtre dans un listbox scrollable. }
Var
 D: TDialog;
 IList, ICount: Integer;
 Tot, J, R, K: Integer;
 T: TTransaction;
 Line: String;
 TotMatch: Integer;
 TotAmt: Real;
Begin
 Tot := TransCnt;
 If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;

 DlgInit(D, 'Historique transactionnel detaille', 600, 400);
 DlgAddLabel(D, 12, 4,
   'Date       Heure  Type Plaque       Pl    Montant');
 IList := DlgAddList(D, 12, 18, 576, 280);

 J := 0;
 TotMatch := 0;
 TotAmt := 0;
 For K := 0 To Tot - 1 Do Begin
  If Not GetTransactionAt(K, T) Then Continue;
  If Not MatchFilter(T, LastFilter) Then Continue;
  Inc(TotMatch);
  TotAmt := TotAmt + T.Paid;
  If J >= MAX_LIST Then Continue;
  Line := FormatDate(T.StartDT) + ' ' +
          FormatTime(T.StartDT) + '  ' +
          TxKindLabel(T.Kind) + ' ';
  While Length(Line) < 26 Do Line := Line + ' ';
  Line := Line + T.Plate;
  While Length(Line) < 40 Do Line := Line + ' ';
  If T.SpotIdx >= 0 Then Line := Line + IntToStrW(T.SpotIdx + 1, 4)
  Else Line := Line + '   -';
  While Length(Line) < 48 Do Line := Line + ' ';
  Line := Line + MoneyStr(T.Paid);
  D.Ctrls[IList].ListItems[J] := Copy(Line, 1, 63);
  Inc(J);
 End;
 D.Ctrls[IList].ListCount := J;

 ICount := DlgAddLabel(D, 12, 310,
   IntToStr(TotMatch) + ' transactions / ' + IntToStr(Tot) +
   ' totales - Montant total : ' + MoneyStr(TotAmt));
 ICount := ICount; { silence unused }

 DlgAddButton(D, 130, 350, 110, 'Filtrer',   2, 'F');
 DlgAddButton(D, 250, 350, 110, 'Effacer',   3, 'E');
 DlgAddButton(D, 380, 350, 100, 'Fermer',   -1, 'X');

 R := DlgRun(D);
 Case R Of
  2: Begin DlgFilterHistory; DlgDetailedHistory; End;
  3: Begin
      If ShowConfirmBox('Effacer',
           'Effacer tout l''historique de transactions ?') Then Begin
       TransCnt := 0; TransHead := 0;
      End;
     End;
 End;
End;

{ ============================================================
  MODULE 4 : EXPORT CSV
  ============================================================ }

Function CSVField(S: String): String;
{ Echappe les guillemets, entoure si contient virgule ou retour. }
Var I: Integer; Out_: String; NeedQuote: Boolean;
Begin
 NeedQuote := False;
 For I := 1 To Length(S) Do
  If (S[I] = ',') Or (S[I] = '"') Or (S[I] = #10) Or (S[I] = #13) Then Begin
   NeedQuote := True; Break;
  End;
 If Not NeedQuote Then Begin
  CSVField := S; Exit;
 End;
 Out_ := '"';
 For I := 1 To Length(S) Do Begin
  If S[I] = '"' Then Out_ := Out_ + '""'
  Else Out_ := Out_ + S[I];
 End;
 Out_ := Out_ + '"';
 CSVField := Out_;
End;

Function CSVReal(R: Real): String;
Var S: String;
Begin
 Str(R:0:2, S); CSVReal := S;
End;

Function CSVInt(N: LongInt): String;
Begin CSVInt := IntToStr(N); End;

Function CSVDateTime(Const DT: TDateTime): String;
Begin
 CSVDateTime := IntToStrW(DT.Year, 4) + '-' +
                IntToStrW(DT.Month, 2) + '-' +
                IntToStrW(DT.Day, 2) + ' ' +
                IntToStrW(DT.Hour, 2) + ':' +
                IntToStrW(DT.Min, 2);
End;

Function OpenCSV(Var F: Text; FN: String): Boolean;
Var Code: Integer;
Begin
 Assign(F, FN);
{$I-} Rewrite(F); {$I+}
 Code := IOResult;
 OpenCSV := (Code = 0);
End;

Procedure ExportTransactionsCSV(FN: String);
Var F: Text; I, Tot: Integer; T: TTransaction;
Begin
 If Not OpenCSV(F, FN) Then Begin
  ShowMessageBox('Export', 'Impossible d''ecrire ' + FN); Exit;
 End;
 WriteLn(F, 'Date,Heure,Type,Plaque,Proprietaire,Place,Montant,DebutISO,FinISO');
 Tot := TransCnt; If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;
 For I := 0 To Tot - 1 Do Begin
  If Not GetTransactionAt(I, T) Then Continue;
  WriteLn(F, CSVField(FormatDate(T.StartDT)), ',',
             CSVField(FormatTime(T.StartDT)), ',',
             CSVField(TxKindLabel(T.Kind)), ',',
             CSVField(T.Plate), ',',
             CSVField(T.Owner), ',',
             CSVInt(T.SpotIdx + 1), ',',
             CSVReal(T.Paid), ',',
             CSVField(CSVDateTime(T.StartDT)), ',',
             CSVField(CSVDateTime(T.EndDT)));
 End;
 Close(F);
 ShowMessageBox('Export',
   IntToStr(Tot) + ' transactions exportees vers ' + FN);
End;

Procedure ExportSubscriptionsCSV(FN: String);
Var F: Text; I, N: Integer;
Begin
 If Not OpenCSV(F, FN) Then Begin
  ShowMessageBox('Export', 'Impossible d''ecrire ' + FN); Exit;
 End;
 WriteLn(F, 'ID,Type,Nom,Plaque,Telephone,Courriel,Debut,Fin,Paye,Place,AutoRenew,Renouvellements');
 N := 0;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active Then Begin
   WriteLn(F, CSVInt(Subs[I].ID), ',',
              CSVField(SubTypeLabel(Subs[I].SubType)), ',',
              CSVField(Subs[I].Name), ',',
              CSVField(Subs[I].Plate), ',',
              CSVField(Subs[I].Phone), ',',
              CSVField(Subs[I].Email), ',',
              CSVField(CSVDateTime(Subs[I].StartDT)), ',',
              CSVField(CSVDateTime(Subs[I].EndDT)), ',',
              CSVReal(Subs[I].AmountPaid), ',',
              CSVInt(Subs[I].AssignedSpot + 1), ',',
              CSVField(BoolToStr(Subs[I].AutoRenew)), ',',
              CSVInt(Subs[I].RenewCount));
   Inc(N);
  End;
 Close(F);
 ShowMessageBox('Export',
   IntToStr(N) + ' abonnements exportes vers ' + FN);
End;

Procedure ExportSpotsCSV(FN: String);
Var F: Text; I: Integer; S: TSpot;
Begin
 If Not OpenCSV(F, FN) Then Begin
  ShowMessageBox('Export', 'Impossible d''ecrire ' + FN); Exit;
 End;
 WriteLn(F, 'Place,Etat,Plaque,Proprietaire,Telephone,DebutISO,FinISO,Paye');
 For I := 0 To SpotCount - 1 Do Begin
  S := Spots[I];
  If S.State = ssFree Then
   WriteLn(F, CSVInt(I + 1), ',', 'LIBRE,,,,,,')
  Else
   WriteLn(F, CSVInt(I + 1), ',',
              'OCCUPE,',
              CSVField(S.Plate), ',',
              CSVField(S.Owner), ',',
              CSVField(S.Phone), ',',
              CSVField(CSVDateTime(S.StartDT)), ',',
              CSVField(CSVDateTime(S.EndDT)), ',',
              CSVReal(S.Paid));
 End;
 Close(F);
 ShowMessageBox('Export',
   IntToStr(SpotCount) + ' places exportees vers ' + FN);
End;

Procedure ExportDailyCSV(FN: String);
Var F: Text; I: Integer;
Begin
 If Not OpenCSV(F, FN) Then Begin
  ShowMessageBox('Export', 'Impossible d''ecrire ' + FN); Exit;
 End;
 WriteLn(F, 'Date,Revenu,Reservations,Liberations');
 For I := 0 To DailyStatsCnt - 1 Do
  WriteLn(F, CSVField(FormatDate(DailyStats[I].Date)), ',',
             CSVReal(DailyStats[I].Revenue), ',',
             CSVInt(DailyStats[I].Reservations), ',',
             CSVInt(DailyStats[I].Released));
 { Inclure la journee en cours }
 WriteLn(F, CSVField(FormatDate(DailyDate)), ',',
            CSVReal(DailyRevenue), ',',
            CSVInt(DailyReservations), ',',
            CSVInt(DailyReleases));
 Close(F);
 ShowMessageBox('Export',
   IntToStr(DailyStatsCnt + 1) + ' journees exportees vers ' + FN);
End;

Procedure ExportPricingCSV(FN: String);
Var F: Text; I: Integer;
Begin
 If Not OpenCSV(F, FN) Then Begin
  ShowMessageBox('Export', 'Impossible d''ecrire ' + FN); Exit;
 End;
 WriteLn(F, '# Tarifs horaires');
 WriteLn(F, 'Code,Label,Heures,Prix');
 For I := 0 To MAX_DURATIONS - 1 Do
  WriteLn(F, CSVInt(Pricing[I].Code), ',',
             CSVField(Pricing[I].Label_), ',',
             CSVInt(Pricing[I].Hours), ',',
             CSVReal(Pricing[I].Price));
 WriteLn(F);
 WriteLn(F, '# Tarifs abonnement');
 WriteLn(F, 'Type,Label,Jours,Prix');
 For I := 0 To SUB_TYPES - 1 Do
  WriteLn(F, CSVInt(I), ',',
             CSVField(SubPricing[I].Label_), ',',
             CSVInt(SubPricing[I].Days), ',',
             CSVReal(SubPricing[I].Price));
 WriteLn(F);
 WriteLn(F, '# Zones tarifaires');
 WriteLn(F, 'Zone,Nom,DebutH,FinH,Jours,Multiplicateur,Actif');
 For I := 0 To TariffCount - 1 Do
  WriteLn(F, CSVInt(I), ',',
             CSVField(TariffZones[I].Name), ',',
             CSVInt(TariffZones[I].StartHour), ',',
             CSVInt(TariffZones[I].EndHour), ',',
             CSVField(DayMaskLabel(TariffZones[I].DayMask)), ',',
             CSVReal(TariffZones[I].Multiplier), ',',
             CSVField(BoolToStr(TariffZones[I].Enabled)));
 Close(F);
 ShowMessageBox('Export', 'Tarifs exportes vers ' + FN);
End;

Procedure DlgExportCSV(Kind: Integer);
{ Kind : 0=trans, 1=subs, 2=spots, 3=daily, 4=pricing, 5=all }
Var FN: String; Suffix: String; Base: String;
Begin
 Case Kind Of
  0: Suffix := 'transactions';
  1: Suffix := 'abonnements';
  2: Suffix := 'places';
  3: Suffix := 'journalier';
  4: Suffix := 'tarifs';
  5: Suffix := 'tout';
  Else Suffix := 'export';
 End;
 Base := Suffix + '.csv';
 FN := Base;
 If Not ShowInputBox('Export CSV',
   'Nom du fichier (.csv) :', FN, 60) Then Exit;
 If FN = '' Then Exit;
 Case Kind Of
  0: ExportTransactionsCSV(FN);
  1: ExportSubscriptionsCSV(FN);
  2: ExportSpotsCSV(FN);
  3: ExportDailyCSV(FN);
  4: ExportPricingCSV(FN);
  5: Begin
      ExportTransactionsCSV('transactions.csv');
      ExportSubscriptionsCSV('abonnements.csv');
      ExportSpotsCSV('places.csv');
      ExportDailyCSV('journalier.csv');
      ExportPricingCSV('tarifs.csv');
      ShowMessageBox('Export complet',
        '5 fichiers CSV crees dans le repertoire courant.');
     End;
 End;
End;

{ ============================================================
  MODULE 5 : GRAPHIQUES (barres, lignes, pointes de tarte)
  ============================================================ }

Procedure ChartFitMax(Var Pts: TChartArray; Count: Integer;
                      Var MaxV: Real);
Var I: Integer;
Begin
 MaxV := 0;
 For I := 0 To Count - 1 Do
  If Pts[I].Value > MaxV Then MaxV := Pts[I].Value;
 If MaxV <= 0 Then MaxV := 1;
End;

Procedure DrawBarChart(X1, Y1, X2, Y2: Integer;
                       Var Pts: TChartArray; Count: Integer;
                       Title: String);
Var I, BX, BW, BH, AX1, AX2, AY1, AY2: Integer;
    MaxV, Scale: Real;
    S: String;
Begin
 { Cadre }
 SetColor(CLR_BORDER);
 Rectangle(X1, Y1, X2, Y2);
 SetColor(CLR_LABEL);
 If Title <> '' Then OutTextXY(X1 + 8, Y1 + 4, Title);

 AX1 := X1 + 40; AY1 := Y1 + 20;
 AX2 := X2 - 8;  AY2 := Y2 - 30;
 { Axes }
 SetColor(Black);
 Line(AX1, AY1, AX1, AY2);
 Line(AX1, AY2, AX2, AY2);

 If Count <= 0 Then Exit;
 ChartFitMax(Pts, Count, MaxV);
 Scale := (AY2 - AY1) / MaxV;

 { Grille horizontale + axe Y avec 4 valeurs }
 SetLineStyle(DottedLn, 0, NormWidth);
 SetColor(LightGray);
 For I := 1 To 4 Do Begin
  BH := AY2 - Round((MaxV * I / 4) * Scale);
  Line(AX1 + 1, BH, AX2, BH);
  SetColor(Black);
  Str(MaxV * I / 4:0:0, S);
  OutTextXY(X1 + 4, BH - 4, S);
  SetColor(LightGray);
 End;
 SetLineStyle(SolidLn, 0, NormWidth);

 { Barres }
 BW := (AX2 - AX1) Div Count;
 If BW < 2 Then BW := 2;
 For I := 0 To Count - 1 Do Begin
  BX := AX1 + I * BW;
  BH := Round(Pts[I].Value * Scale);
  If BH > AY2 - AY1 Then BH := AY2 - AY1;
  SetFillStyle(SolidFill, Pts[I].Color);
  Bar(BX + 1, AY2 - BH, BX + BW - 1, AY2 - 1);
  SetColor(Black);
  Rectangle(BX + 1, AY2 - BH, BX + BW - 1, AY2 - 1);
  { Etiquette sous chaque barre (1 char sur 2 si serre) }
  If (BW >= 16) Or ((I Mod 2) = 0) Then Begin
   SetColor(Black);
   OutTextXY(BX + 1, AY2 + 2, Copy(Pts[I].Label_, 1, BW Div CHARW));
  End;
 End;
End;

Procedure DrawLineChart(X1, Y1, X2, Y2: Integer;
                        Var Pts: TChartArray; Count: Integer;
                        Title: String);
Var I, AX1, AY1, AX2, AY2, PX, PY, PPX, PPY, XStep: Integer;
    MaxV, Scale: Real;
    S: String;
Begin
 SetColor(CLR_BORDER);
 Rectangle(X1, Y1, X2, Y2);
 SetColor(CLR_LABEL);
 If Title <> '' Then OutTextXY(X1 + 8, Y1 + 4, Title);
 AX1 := X1 + 40; AY1 := Y1 + 20;
 AX2 := X2 - 8;  AY2 := Y2 - 30;
 SetColor(Black);
 Line(AX1, AY1, AX1, AY2);
 Line(AX1, AY2, AX2, AY2);

 If Count <= 0 Then Exit;
 ChartFitMax(Pts, Count, MaxV);
 Scale := (AY2 - AY1) / MaxV;

 SetLineStyle(DottedLn, 0, NormWidth);
 SetColor(LightGray);
 For I := 1 To 4 Do Begin
  PY := AY2 - Round((MaxV * I / 4) * Scale);
  Line(AX1 + 1, PY, AX2, PY);
  SetColor(Black);
  Str(MaxV * I / 4:0:0, S);
  OutTextXY(X1 + 4, PY - 4, S);
  SetColor(LightGray);
 End;
 SetLineStyle(SolidLn, 0, ThickWidth);
 SetColor(Blue);

 If Count > 1 Then XStep := (AX2 - AX1) Div (Count - 1)
 Else XStep := 0;
 PPX := AX1; PPY := AY2 - Round(Pts[0].Value * Scale);
 For I := 0 To Count - 1 Do Begin
  PX := AX1 + I * XStep;
  PY := AY2 - Round(Pts[I].Value * Scale);
  If I > 0 Then Line(PPX, PPY, PX, PY);
  { Petit cercle au point }
  SetFillStyle(SolidFill, Pts[I].Color);
  Bar(PX - 2, PY - 2, PX + 2, PY + 2);
  PPX := PX; PPY := PY;
 End;
 SetLineStyle(SolidLn, 0, NormWidth);
End;

Procedure DrawPieChart(CX, CY, Radius: Integer;
                       Var Pts: TChartArray; Count: Integer);
{ Pie chart base sur PieSlice. }
Var I: Integer; Tot, Acc, StAng, EndAng: Real;
    LX, LY: Integer; S: String;
Begin
 Tot := 0;
 For I := 0 To Count - 1 Do Tot := Tot + Pts[I].Value;
 If Tot <= 0 Then Begin
  SetColor(Black);
  Circle(CX, CY, Radius);
  OutTextXY(CX - 30, CY - 4, '(aucune donnee)');
  Exit;
 End;
 Acc := 0;
 For I := 0 To Count - 1 Do Begin
  StAng := Acc / Tot * 360;
  Acc := Acc + Pts[I].Value;
  EndAng := Acc / Tot * 360;
  SetFillStyle(SolidFill, Pts[I].Color);
  SetColor(Black);
  PieSlice(CX, CY, Round(StAng), Round(EndAng), Radius);
 End;
 { Legende a droite }
 For I := 0 To Count - 1 Do Begin
  LX := CX + Radius + 16;
  LY := CY - Radius + I * 14;
  SetFillStyle(SolidFill, Pts[I].Color);
  SetColor(Black);
  Bar(LX, LY, LX + 12, LY + 10);
  Rectangle(LX, LY, LX + 12, LY + 10);
  OutTextXY(LX + 18, LY + 1, Pts[I].Label_);
  Str(Pts[I].Value:0:1, S);
  OutTextXY(LX + 18, LY + 1, Pts[I].Label_ + ' (' + S + ')');
 End;
End;

Procedure ShowGraphAndWait;
{ Boucle jusqu a touche ou clic, restaure ensuite l ecran. }
Var Ev: TEvent;
Begin
 SetColor(Black);
 OutTextXY(8, SCREEN_H - 30, 'Touche ou clic pour fermer');
 Repeat
  PollEvents(Ev);
 Until (Ev.Kind = EV_KEY_DOWN) Or (Ev.Kind = EV_KEY_CHAR) Or
       (Ev.Kind = EV_MOUSE_DOWN) Or (Ev.Kind = EV_MOUSE_DBLCLICK);
End;

Procedure DlgGraphDailyRevenue;
{ Bar chart : revenu des 30 derniers jours }
Var Pts: TChartArray; Count, I: Integer;
Begin
 Count := DailyStatsCnt;
 If Count > MAX_CHART_POINTS - 1 Then Count := MAX_CHART_POINTS - 1;
 For I := 0 To Count - 1 Do Begin
  Pts[I].Label_ := IntToStrW(DailyStats[I].Date.Day, 2);
  Pts[I].Value := DailyStats[I].Revenue;
  Pts[I].Color := Cyan;
 End;
 { Jour en cours }
 Pts[Count].Label_ := 'Auj';
 Pts[Count].Value  := DailyRevenue;
 Pts[Count].Color  := LightGreen;
 Inc(Count);

 { Plein ecran }
 ClearViewPort;
 SetColor(White);
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Revenu quotidien (derniers ' + IntToStr(Count) +
                ' jours)');
 DrawBarChart(8, 24, SCREEN_W - 8, SCREEN_H - 40, Pts, Count, '');
 ShowGraphAndWait;
End;

Procedure DlgGraphMonthlyTrend;
{ Line chart : revenu cumule par jour sur la periode connue. }
Var Pts: TChartArray; Count, I: Integer; Acc: Real;
Begin
 Count := DailyStatsCnt;
 If Count > MAX_CHART_POINTS - 1 Then Count := MAX_CHART_POINTS - 1;
 Acc := 0;
 For I := 0 To Count - 1 Do Begin
  Acc := Acc + DailyStats[I].Revenue;
  Pts[I].Label_ := IntToStrW(DailyStats[I].Date.Day, 2);
  Pts[I].Value := Acc;
  Pts[I].Color := Red;
 End;
 Acc := Acc + DailyRevenue;
 Pts[Count].Label_ := 'Auj';
 Pts[Count].Value := Acc;
 Pts[Count].Color := LightRed;
 Inc(Count);

 ClearViewPort;
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Tendance cumulee des revenus');
 DrawLineChart(8, 24, SCREEN_W - 8, SCREEN_H - 40, Pts, Count, '');
 ShowGraphAndWait;
End;

Procedure DlgGraphByDuration;
{ Pie chart : repartition du revenu par code de duree. }
Var Pts: TChartArray; Count, I, K: Integer;
    Sums: Array[0..MAX_DURATIONS - 1] Of Real;
    Cnts: Array[0..MAX_DURATIONS - 1] Of Integer;
    Tot: Integer; T: TTransaction;
    Colors: Array[0..MAX_DURATIONS - 1] Of Byte;
Begin
 For I := 0 To MAX_DURATIONS - 1 Do Begin
  Sums[I] := 0; Cnts[I] := 0;
 End;
 Colors[0] := Cyan;        Colors[1] := LightGreen;
 Colors[2] := Yellow;      Colors[3] := LightRed;
 Colors[4] := Magenta;     Colors[5] := LightBlue;
 Colors[6] := Brown;       Colors[7] := White;
 Colors[8] := LightGray;

 Tot := TransCnt; If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;
 For K := 0 To Tot - 1 Do Begin
  If Not GetTransactionAt(K, T) Then Continue;
  If T.Kind = TXK_RELEASE Then Continue;
  { Retrouver le code via plage de prix : on tente DurCode du spot, sinon on agrege }
  If T.SpotIdx >= 0 Then Begin
   I := Spots[T.SpotIdx].DurCode;
   If (I >= 0) And (I < MAX_DURATIONS) Then Begin
    Sums[I] := Sums[I] + T.Paid;
    Inc(Cnts[I]);
   End;
  End;
 End;

 Count := 0;
 For I := 0 To MAX_DURATIONS - 1 Do
  If Sums[I] > 0 Then Begin
   Pts[Count].Label_ := Pricing[I].Label_;
   Pts[Count].Value  := Sums[I];
   Pts[Count].Color  := Colors[I];
   Inc(Count);
  End;

 ClearViewPort;
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Revenu par type de duree (historique disponible)');
 DrawPieChart(SCREEN_W Div 3, SCREEN_H Div 2 - 10, 120, Pts, Count);
 ShowGraphAndWait;
End;

Procedure DlgGraphOccupancy;
{ Pie : libre / occupee / expirante / expiree }
Var Pts: TChartArray;
Begin
 UpdateCounters;
 Pts[0].Label_ := 'Libres';     Pts[0].Value := CntFree;
 Pts[0].Color  := LightGreen;
 Pts[1].Label_ := 'Occupees';   Pts[1].Value := CntOccupied;
 Pts[1].Color  := LightRed;
 Pts[2].Label_ := 'Expirantes'; Pts[2].Value := CntExpiring;
 Pts[2].Color  := Yellow;
 Pts[3].Label_ := 'Expirees';   Pts[3].Value := CntExpired;
 Pts[3].Color  := Red;

 ClearViewPort;
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Etat d''occupation du parking');
 DrawPieChart(SCREEN_W Div 3, SCREEN_H Div 2 - 10, 120, Pts, 4);
 ShowGraphAndWait;
End;

Procedure DlgGraphSubs;
{ Bar chart : nombre d abonnes par type }
Var Pts: TChartArray; Cnt: Array[0..SUB_TYPES - 1] Of Integer; I: Integer;
Begin
 For I := 0 To SUB_TYPES - 1 Do Cnt[I] := 0;
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active And IsSubActive(Subs[I]) Then
   If Subs[I].SubType < SUB_TYPES Then
    Inc(Cnt[Subs[I].SubType]);
 For I := 0 To SUB_TYPES - 1 Do Begin
  Pts[I].Label_ := SubPricing[I].Label_;
  Pts[I].Value  := Cnt[I];
  Pts[I].Color  := Cyan + I;
 End;
 ClearViewPort;
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Abonnes actifs par type');
 DrawBarChart(60, 40, SCREEN_W - 60, SCREEN_H - 50,
              Pts, SUB_TYPES, '');
 ShowGraphAndWait;
End;

Procedure DlgGraphHourlyActivity;
{ Bar : nb de reservations par heure de la journee (0..23). }
Var Pts: TChartArray; H: Array[0..23] Of Integer; Tot, K, I: Integer;
    T: TTransaction;
Begin
 For I := 0 To 23 Do H[I] := 0;
 Tot := TransCnt; If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;
 For K := 0 To Tot - 1 Do Begin
  If Not GetTransactionAt(K, T) Then Continue;
  If T.Kind = TXK_RESERVE Then
   If T.StartDT.Hour < 24 Then Inc(H[T.StartDT.Hour]);
 End;
 For I := 0 To 23 Do Begin
  Pts[I].Label_ := IntToStrW(I, 2) + 'h';
  Pts[I].Value  := H[I];
  Pts[I].Color  := LightBlue;
 End;
 ClearViewPort;
 SetFillStyle(SolidFill, CLR_BACKGROUND);
 Bar(0, 0, SCREEN_W, SCREEN_H);
 SetColor(Black);
 OutTextXY(8, 4, 'Reservations par heure de la journee');
 DrawBarChart(8, 24, SCREEN_W - 8, SCREEN_H - 40, Pts, 24, '');
 ShowGraphAndWait;
End;

{ ============================================================
  MODULE 6 : RAPPORTS TEXTUELS
  ============================================================ }

Procedure ShowReportDialog(Title: String;
                           Var Lines: TReportArray;
                           Count: Integer);
{ Affiche le rapport dans un listbox avec option de sauvegarde. }
Var D: TDialog; IList, I, R: Integer; FN, Default_: String;
    F: Text; Code: Integer;
Begin
 DlgInit(D, Title, 600, 400);
 IList := DlgAddList(D, 8, 8, 584, 320);
 If Count > MAX_LIST Then Count := MAX_LIST;
 For I := 0 To Count - 1 Do
  D.Ctrls[IList].ListItems[I] := Copy(Lines[I], 1, 63);
 D.Ctrls[IList].ListCount := Count;
 DlgAddButton(D, 180, 350, 140, 'Sauver (.txt)', 2, 'S');
 DlgAddButton(D, 340, 350, 100, 'Fermer',       -1, 'F');
 R := DlgRun(D);
 If R = 2 Then Begin
  Default_ := 'rapport.txt';
  FN := Default_;
  If Not ShowInputBox('Sauver rapport',
                      'Nom de fichier :', FN, 60) Then Exit;
  If FN = '' Then Exit;
  Assign(F, FN);
 {$I-} Rewrite(F); {$I+}
  Code := IOResult;
  If Code <> 0 Then Begin
   ShowMessageBox('Erreur', 'Impossible d''ecrire ' + FN); Exit;
  End;
  For I := 0 To Count - 1 Do WriteLn(F, Lines[I]);
  Close(F);
  ShowMessageBox('Sauve', 'Rapport sauve dans ' + FN);
 End;
End;

Procedure GenerateDailyReport(Var L: TReportArray; Var N: Integer);
Var I, K, Tot, ResCount, RelCount: Integer;
    T: TTransaction; PeakHour, PeakCount: Integer;
    HourC: Array[0..23] Of Integer;
    TotAmount: Real;
Begin
 N := 0;
 L[N] := '=== RAPPORT QUOTIDIEN - ' + FormatDate(DailyDate) + ' ==='; Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'Etat du parking :'; Inc(N);
 UpdateCounters;
 L[N] := '  Total places   : ' + IntToStr(SpotCount); Inc(N);
 L[N] := '  Libres         : ' + IntToStr(CntFree); Inc(N);
 L[N] := '  Occupees       : ' + IntToStr(CntOccupied); Inc(N);
 L[N] := '  Expirantes <30m: ' + IntToStr(CntExpiring); Inc(N);
 L[N] := '  Expirees       : ' + IntToStr(CntExpired); Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'Activite de la journee :'; Inc(N);
 L[N] := '  Reservations   : ' + IntToStr(DailyReservations); Inc(N);
 L[N] := '  Liberations    : ' + IntToStr(DailyReleases); Inc(N);
 L[N] := '  Revenu         : ' + MoneyStr(DailyRevenue); Inc(N);
 L[N] := ''; Inc(N);

 { Pic de frequentation }
 For I := 0 To 23 Do HourC[I] := 0;
 Tot := TransCnt; If Tot > MAX_HISTORY Then Tot := MAX_HISTORY;
 ResCount := 0; RelCount := 0; TotAmount := 0;
 For K := 0 To Tot - 1 Do Begin
  If Not GetTransactionAt(K, T) Then Continue;
  If SameDay(T.StartDT, DailyDate) Then Begin
   If T.Kind = TXK_RESERVE Then Begin
    Inc(ResCount);
    If T.StartDT.Hour < 24 Then Inc(HourC[T.StartDT.Hour]);
   End Else If T.Kind = TXK_RELEASE Then Inc(RelCount);
   TotAmount := TotAmount + T.Paid;
  End;
 End;
 PeakHour := 0; PeakCount := 0;
 For I := 0 To 23 Do If HourC[I] > PeakCount Then Begin
  PeakHour := I; PeakCount := HourC[I];
 End;
 L[N] := 'Statistiques de pointe :'; Inc(N);
 L[N] := '  Heure de pointe        : ' +
         IntToStrW(PeakHour, 2) + 'h  (' +
         IntToStr(PeakCount) + ' reservations)'; Inc(N);
 L[N] := '  Montant tot. historique: ' + MoneyStr(TotAmount); Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'Abonnements :'; Inc(N);
 L[N] := '  Actifs         : ' + IntToStr(CountActiveSubs); Inc(N);
 L[N] := '  Revenu abonn.  : ' + MoneyStr(TotalSubRevenue); Inc(N);
 L[N] := ''; Inc(N);
 L[N] := '=== Fin du rapport ==='; Inc(N);
End;

Procedure GenerateWeeklyReport(Var L: TReportArray; Var N: Integer);
Var I, K: Integer; TotR: Real; TotRes, TotRel: Integer;
    Cnt: Integer;
Begin
 N := 0;
 L[N] := '=== RAPPORT HEBDOMADAIRE ==='; Inc(N);
 L[N] := ''; Inc(N);
 Cnt := 0; TotR := 0; TotRes := 0; TotRel := 0;
 K := DailyStatsCnt - 7;
 If K < 0 Then K := 0;
 L[N] := 'Date         Revenu       Reservations  Liberations'; Inc(N);
 L[N] := '------------------------------------------------------'; Inc(N);
 For I := K To DailyStatsCnt - 1 Do Begin
  L[N] := FormatDate(DailyStats[I].Date) + '   ' +
          MoneyStr(DailyStats[I].Revenue);
  While Length(L[N]) < 30 Do L[N] := L[N] + ' ';
  L[N] := L[N] + IntToStrW(DailyStats[I].Reservations, 4) + '          ' +
                 IntToStrW(DailyStats[I].Released, 4); Inc(N);
  TotR := TotR + DailyStats[I].Revenue;
  TotRes := TotRes + DailyStats[I].Reservations;
  TotRel := TotRel + DailyStats[I].Released;
  Inc(Cnt);
 End;
 L[N] := FormatDate(DailyDate) + '   ' + MoneyStr(DailyRevenue);
 While Length(L[N]) < 30 Do L[N] := L[N] + ' ';
 L[N] := L[N] + IntToStrW(DailyReservations, 4) + '          ' +
                IntToStrW(DailyReleases, 4); Inc(N);
 TotR := TotR + DailyRevenue;
 TotRes := TotRes + DailyReservations;
 TotRel := TotRel + DailyReleases;
 Inc(Cnt);
 L[N] := '------------------------------------------------------'; Inc(N);
 L[N] := 'Total sur ' + IntToStr(Cnt) + ' jours :'; Inc(N);
 L[N] := '  Revenu total    : ' + MoneyStr(TotR); Inc(N);
 L[N] := '  Reservations    : ' + IntToStr(TotRes); Inc(N);
 L[N] := '  Liberations     : ' + IntToStr(TotRel); Inc(N);
 If Cnt > 0 Then Begin
  L[N] := '  Revenu moyen/j  : ' + MoneyStr(TotR / Cnt); Inc(N);
 End;
End;

Procedure GenerateMonthlyReport(Var L: TReportArray; Var N: Integer);
Var I: Integer; TotR: Real; TotRes, TotRel: Integer;
    Mx, Mn: Real;
Begin
 N := 0;
 L[N] := '=== RAPPORT MENSUEL (' + IntToStr(DailyStatsCnt + 1) +
         ' jours) ==='; Inc(N);
 L[N] := ''; Inc(N);
 TotR := DailyRevenue;
 TotRes := DailyReservations; TotRel := DailyReleases;
 Mx := DailyRevenue; Mn := DailyRevenue;
 For I := 0 To DailyStatsCnt - 1 Do Begin
  TotR := TotR + DailyStats[I].Revenue;
  TotRes := TotRes + DailyStats[I].Reservations;
  TotRel := TotRel + DailyStats[I].Released;
  If DailyStats[I].Revenue > Mx Then Mx := DailyStats[I].Revenue;
  If DailyStats[I].Revenue < Mn Then Mn := DailyStats[I].Revenue;
 End;
 L[N] := 'Revenu total       : ' + MoneyStr(TotR); Inc(N);
 L[N] := 'Reservations total : ' + IntToStr(TotRes); Inc(N);
 L[N] := 'Liberations total  : ' + IntToStr(TotRel); Inc(N);
 If DailyStatsCnt + 1 > 0 Then Begin
  L[N] := 'Moyenne /jour      : ' + MoneyStr(TotR / (DailyStatsCnt + 1)); Inc(N);
 End;
 L[N] := 'Meilleur jour      : ' + MoneyStr(Mx); Inc(N);
 L[N] := 'Pire jour          : ' + MoneyStr(Mn); Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'Etat actuel :'; Inc(N);
 UpdateCounters;
 L[N] := '  Occupation : ' + IntToStr(CntOccupied) + '/' +
         IntToStr(SpotCount);
 If SpotCount > 0 Then
  L[N] := L[N] + '  (' +
          IntToStr(Round(CntOccupied * 100.0 / SpotCount)) + ' %)';
 Inc(N);
 L[N] := '  Abonnes    : ' + IntToStr(CountActiveSubs); Inc(N);
End;

Procedure GenerateSubsReport(Var L: TReportArray; Var N: Integer);
Var I: Integer;
Begin
 N := 0;
 L[N] := '=== RAPPORT ABONNEMENTS ==='; Inc(N);
 L[N] := 'Total cree     : ' + IntToStr(SubsCount); Inc(N);
 L[N] := 'Actifs valides : ' + IntToStr(CountActiveSubs); Inc(N);
 L[N] := 'Revenu total   : ' + MoneyStr(TotalSubRevenue); Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'ID    Type        Plaque      Nom              Expire'; Inc(N);
 L[N] := '-----------------------------------------------------------'; Inc(N);
 For I := 0 To SubsCount - 1 Do
  If Subs[I].Active Then Begin
   L[N] := IntToStrW(Subs[I].ID, 5) + '  ';
   L[N] := L[N] + SubTypeLabel(Subs[I].SubType);
   While Length(L[N]) < 19 Do L[N] := L[N] + ' ';
   L[N] := L[N] + Subs[I].Plate;
   While Length(L[N]) < 32 Do L[N] := L[N] + ' ';
   L[N] := L[N] + Subs[I].Name;
   While Length(L[N]) < 49 Do L[N] := L[N] + ' ';
   L[N] := L[N] + FormatDate(Subs[I].EndDT);
   Inc(N);
   If N >= MAX_REPORT_LINES - 2 Then Begin
    L[N] := '... (rapport tronque)'; Inc(N); Exit;
   End;
  End;
End;

Procedure GenerateOccupancyReport(Var L: TReportArray; Var N: Integer);
Var I: Integer; Rem: LongInt;
Begin
 N := 0;
 UpdateCounters;
 L[N] := '=== ETAT D''OCCUPATION DETAILLE ==='; Inc(N);
 L[N] := ''; Inc(N);
 L[N] := 'Place Plaque        Proprietaire     Restant'; Inc(N);
 L[N] := '------------------------------------------------'; Inc(N);
 For I := 0 To SpotCount - 1 Do Begin
  If Spots[I].State <> ssOccupied Then Continue;
  L[N] := IntToStrW(I + 1, 4) + '  ' + Spots[I].Plate;
  While Length(L[N]) < 21 Do L[N] := L[N] + ' ';
  L[N] := L[N] + Copy(Spots[I].Owner, 1, 18);
  While Length(L[N]) < 41 Do L[N] := L[N] + ' ';
  Rem := ComputeRemainingMin(I);
  If Rem < 0 Then L[N] := L[N] + 'EXPIRE'
  Else L[N] := L[N] + IntToStr(Rem) + ' min';
  Inc(N);
  If N >= MAX_REPORT_LINES - 2 Then Begin
   L[N] := '... (rapport tronque)'; Inc(N); Exit;
  End;
 End;
 If N = 4 Then Begin
  L[N] := '(aucune place occupee)'; Inc(N);
 End;
End;

Procedure DlgReportDaily;
Var L: TReportArray; N: Integer;
Begin GenerateDailyReport(L, N); ShowReportDialog('Rapport quotidien', L, N); End;

Procedure DlgReportWeekly;
Var L: TReportArray; N: Integer;
Begin GenerateWeeklyReport(L, N); ShowReportDialog('Rapport hebdomadaire', L, N); End;

Procedure DlgReportMonthly;
Var L: TReportArray; N: Integer;
Begin GenerateMonthlyReport(L, N); ShowReportDialog('Rapport mensuel', L, N); End;

Procedure DlgReportSubs;
Var L: TReportArray; N: Integer;
Begin GenerateSubsReport(L, N); ShowReportDialog('Rapport abonnements', L, N); End;

Procedure DlgReportOccupancy;
Var L: TReportArray; N: Integer;
Begin GenerateOccupancyReport(L, N); ShowReportDialog('Occupation detaillee', L, N); End;

{ ============================================================
  INITIALISATION & BOUCLE PRINCIPALE
  ============================================================ }

Procedure InitState;
Begin
 QuitRequested := False;
 DirtyDisplay := True;
 CurrentFile := '';

 PrevMouseX := -1; PrevMouseY := -1; PrevMouseBtn := 0;
 LastClickX := 0; LastClickY := 0;
 LastClickTime := 0; LastClickBtn := MB_NONE;

 OpenMenuIdx := -1; SelItemIdx := -1; MenuActive := False;
 MenuBgBuf := Nil; MenuBgSaved := False;

 ColCount := 10;
 RowCount := 6;
 ClearAllSpots;

 InitDefaultPricing;
 InitDefaultTariffs;
 InitDefaultSubPricing;
 InitSubscriptions;
 LastFilter := ResetFilter;
 ExportDir := '';

 GetCurrentDT(NowDT);
 DailyDate := NowDT;
 DailyRevenue := 0;
 DailyReservations := 0;
 DailyReleases := 0;
 DailyStatsCnt := 0;

 TransCnt := 0; TransHead := 0;

 HoverSpot := -1;
 TooltipText := '';
 TooltipVisible := False;

 LastClockSec := -1;
End;

Procedure HandleKeyShortcuts(Var Ev: TEvent);
{ Raccourcis globaux (en dehors d un menu/dialogue ouvert) }
Var P: String; I: Integer;
Begin
 P := '';
 If Ev.Kind = EV_KEY_DOWN Then Begin
  Case Ev.KeyCode Of
   60: DlgConfigureGrid;    { F2 }
   61: DlgConfigurePricing; { F3 }
   63: DlgReserve(-1);      { F5 }
   64: DlgFreeSpot;         { F6 }
   65: Begin                { F7 = etendre }
    P := '';
    If ShowInputBox('Etendre', 'Numero de la place :', P, 5) Then Begin
     I := StrToIntDef(P, 0) - 1;
     If (I >= 0) And (I < SpotCount) And
        (Spots[I].State = ssOccupied) Then DlgSpotInfo(I);
    End;
   End;
   66: Begin                { F8 = infos }
    P := '';
    If ShowInputBox('Infos', 'Numero de la place :', P, 5) Then Begin
     I := StrToIntDef(P, 0) - 1;
     If (I >= 0) And (I < SpotCount) Then DlgSpotInfo(I);
    End;
   End;
   67: DlgSearchByPlate;    { F9 }
   46: DlgNewParking;          { Ctrl+N -> N }
   45: Begin                   { Alt+X = Quitter }
    If ShowConfirmBox('Quitter', 'Quitter PARKING ?') Then
     QuitRequested := True;
   End;
  End;
  RedrawAll;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  If Ev.KeyChar = 'q' Then
   If ShowConfirmBox('Quitter', 'Quitter PARKING ?') Then
    QuitRequested := True;
 End;
End;

Procedure HandleGridClick(MX, MY: Integer);
Var Idx: Integer;
Begin
 Idx := HitTestSpot(MX, MY);
 If Idx < 0 Then Exit;
 DlgSpotInfo(Idx);
 RedrawAll;
End;

Procedure HandleHover(MX, MY: Integer);
Var Idx, OldHover: Integer;
Begin
 Idx := HitTestSpot(MX, MY);
 OldHover := HoverSpot;
 If Idx <> OldHover Then Begin
  HoverSpot := Idx;
  If OldHover >= 0 Then DrawSpot(OldHover);
  If Idx >= 0 Then DrawSpot(Idx);
 End;
End;

Procedure MainLoop;
Var Ev: TEvent; LastSec: LongInt; CurSec: LongInt;
Begin
 LastSec := 0;
 Repeat
  PollEvents(Ev);
  If Ev.Kind <> EV_NONE Then Begin
   If MenuActive Then
    HandleMenuEvent(Ev)
   Else Begin
    Case Ev.Kind Of
     EV_MOUSE_DOWN, EV_MOUSE_DBLCLICK: Begin
      If (Ev.MouseY < MENUBAR_HEIGHT) Then
       HandleMenuEvent(Ev)
      Else If (Ev.MouseY >= ScreenHeight - STATUSBAR_HEIGHT) Then
       { Clic sur status bar : ignore }
      Else
       HandleGridClick(Ev.MouseX, Ev.MouseY);
     End;
     EV_MOUSE_MOVE: HandleHover(Ev.MouseX, Ev.MouseY);
     EV_KEY_DOWN, EV_KEY_CHAR: Begin
      { Ouverture menus via Alt+lettre passe par HandleMenuEvent }
      HandleMenuEvent(Ev);
      If Not MenuActive Then HandleKeyShortcuts(Ev);
     End;
    End;
   End;
  End;
  { Refresh d horloge / d expirations chaque seconde }
  CurSec := GetTimestamp Div 1000;
  If CurSec <> LastSec Then Begin
   LastSec := CurSec;
   ResetDailyIfNewDay;
   CheckExpiredSubs;
   UpdateCounters;
   DrawStatusBar;
  End;
 Until QuitRequested;
End;

BEGIN
 InitializeGraphics;
 If MouseDriverFound Then ShowMouse;
 InitState;
 BuildMainMenu;
 RedrawAll;
 MainLoop;
 If MouseDriverFound Then HideMouse;
 CloseGraph;
END.
