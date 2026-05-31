{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/infrastructures-0)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Mall Management System (gestion de centre commercial)
}

Program MALL;

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
  { Pas d'impl??mentation pour Free Pascal }
 End;

 Procedure HideMouse;
 Begin
  { Pas d'impl??mentation pour Free Pascal }
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

 MAX_MENUS            = 20;
 MAX_MENU_ITEMS       = 32;

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
  Y          : Integer;
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
Procedure CalcMenuBarHeight; Forward;
Procedure DrawStatusBar; Forward;
Procedure DrawParkingGrid; Forward;
Procedure ExecuteMenuItem(Var Item: TMenuItem); Forward;

{ ============== Forwards modules MALL ============== }
Procedure InitSecurity; Forward;
Procedure DlgGuards; Forward;
Procedure DlgGuardNew; Forward;
Procedure DlgGuardEdit; Forward;
Procedure DlgGuardRoster; Forward;
Procedure DlgGuardAssign; Forward;
Procedure DlgGuardReport; Forward;
Procedure DlgIncidentList; Forward;
Procedure DlgIncidentNew; Forward;
Procedure DlgIncidentEdit; Forward;
Procedure DlgIncidentClose; Forward;
Procedure DlgIncidentToday; Forward;
Procedure DlgIncidentReport; Forward;
Procedure DlgIncidentTrends; Forward;
Procedure DlgRoundList; Forward;
Procedure DlgRoundStart; Forward;
Procedure DlgRoundEnd; Forward;
Procedure DlgRoundReport; Forward;
Procedure DlgLFList; Forward;
Procedure DlgLFLost; Forward;
Procedure DlgLFFound; Forward;
Procedure DlgLFClaim; Forward;
Procedure DlgLFReport; Forward;
Procedure DlgCCTVList; Forward;
Procedure DlgCCTVStatus; Forward;
Procedure DlgCCTVReport; Forward;
Procedure DlgVisitorPassList; Forward;
Procedure DlgVisitorPassNew; Forward;
Procedure DlgVisitorPassReturn; Forward;
Function ActiveGuardsCount: Integer; Forward;
Function CCTVStatusLabel(S: Byte): String; Forward;
Function FindGuardByBadge(Const Badge: String): Integer; Forward;
Function FindGuardByID(ID: LongInt): Integer; Forward;
Function FindIncidentByID(ID: LongInt): Integer; Forward;
Function GuardShiftLabel(S: Byte): String; Forward;
Function GuardStatusLabel(S: Byte): String; Forward;
Function IncidentKindLabel(K: Byte): String; Forward;
Function IncidentSeverityLabel(S: Byte): String; Forward;
Function IncidentStatusLabel(S: Byte): String; Forward;
Function LFStatusLabel(S: Byte): String; Forward;
Function OfflineCCTVCount: Integer; Forward;
Function OpenIncidentsCount: Integer; Forward;
Function RoundStatusLabel(S: Byte): String; Forward;
Function UnclaimedLFCount: Integer; Forward;
Procedure InitMallExt; Forward;
Procedure DlgTenantList; Forward;
Procedure DlgTenantNew; Forward;
Procedure DlgTenantEdit2; Forward;
Procedure DlgTenantDel; Forward;
Procedure DlgTenantInfo; Forward;
Procedure DlgTenantRpt; Forward;
Procedure DlgTenantVacant; Forward;
Procedure DlgTenantExpire; Forward;
Procedure DlgLeaseList; Forward;
Procedure DlgLeaseNew; Forward;
Procedure DlgLeaseEdit; Forward;
Procedure DlgLeaseDel; Forward;
Procedure DlgLeaseRpt; Forward;
Procedure DlgRentList; Forward;
Procedure DlgRentPay; Forward;
Procedure DlgRentDue; Forward;
Procedure DlgRentRpt; Forward;
Procedure DlgFV2List; Forward;
Procedure DlgFV2New; Forward;
Procedure DlgFV2Edit; Forward;
Procedure DlgFV2Del; Forward;
Procedure DlgFV2Rpt; Forward;
Procedure DlgFM2List; Forward;
Procedure DlgFM2New; Forward;
Procedure DlgFM2Edit; Forward;
Procedure DlgFM2Del; Forward;
Procedure DlgFS2Rec; Forward;
Procedure DlgFS2Today; Forward;
Procedure DlgFS2Week; Forward;
Procedure DlgFS2Top; Forward;
Procedure DlgFS2Rpt; Forward;
Procedure DlgEvtList; Forward;
Procedure DlgEvtNew; Forward;
Procedure DlgEvtEdit; Forward;
Procedure DlgEvtDel; Forward;
Procedure DlgEvtToday; Forward;
Procedure DlgEvtRpt; Forward;
Procedure DlgPromoList; Forward;
Procedure DlgPromoNew; Forward;
Procedure DlgPromoEdit; Forward;
Procedure DlgPromoDel; Forward;
Procedure DlgPromoActive; Forward;
Procedure DlgPromoRpt; Forward;
Procedure DlgMaintList; Forward;
Procedure DlgMaintNew; Forward;
Procedure DlgMaintEdit; Forward;
Procedure DlgMaintClose; Forward;
Procedure DlgMaintOpen; Forward;
Procedure DlgMaintRpt; Forward;
Procedure DlgCleanList; Forward;
Procedure DlgCleanNew; Forward;
Procedure DlgCleanDone; Forward;
Procedure DlgCleanRpt; Forward;
Procedure DlgMallDash; Forward;
Procedure DlgMallOccupancy; Forward;
Procedure DlgMallRevenue; Forward;
Procedure DlgMallAbout; Forward;
Procedure InitMallExt2; Forward;
Procedure DlgLoyList; Forward;
Procedure DlgLoyNew; Forward;
Procedure DlgLoyEdit; Forward;
Procedure DlgLoyDel; Forward;
Procedure DlgLoyPts; Forward;
Procedure DlgLoyTop; Forward;
Procedure DlgLoyRpt; Forward;
Procedure DlgLoyAnni; Forward;
Procedure DlgCampList; Forward;
Procedure DlgCampNew; Forward;
Procedure DlgCampEdit; Forward;
Procedure DlgCampDel; Forward;
Procedure DlgCampAct; Forward;
Procedure DlgCampRpt; Forward;
Procedure DlgTrfList; Forward;
Procedure DlgTrfRec; Forward;
Procedure DlgTrfToday; Forward;
Procedure DlgTrfWeek; Forward;
Procedure DlgTrfPeak; Forward;
Procedure DlgTrfRpt; Forward;
Procedure DlgFBList; Forward;
Procedure DlgFBNew; Forward;
Procedure DlgFBResp; Forward;
Procedure DlgFBRpt; Forward;
Procedure DlgInv2List; Forward;
Procedure DlgInv2New; Forward;
Procedure DlgInv2Edit; Forward;
Procedure DlgInv2Del; Forward;
Procedure DlgInv2Low; Forward;
Procedure DlgInv2Reord; Forward;
Procedure DlgInv2Rpt; Forward;
Procedure DlgStfList; Forward;
Procedure DlgStfNew; Forward;
Procedure DlgStfEdit; Forward;
Procedure DlgStfDel; Forward;
Procedure DlgStfSched; Forward;
Procedure DlgStfRpt; Forward;
Procedure DlgDRList; Forward;
Procedure DlgDRGen; Forward;
Procedure DlgDRView; Forward;
Procedure DlgDRExport; Forward;
Procedure InitMallExt3; Forward;
Procedure DlgGCList; Forward;
Procedure DlgGCIssue; Forward;
Procedure DlgGCRedeem; Forward;
Procedure DlgGCBal; Forward;
Procedure DlgGCRpt; Forward;
Procedure DlgSrvList; Forward;
Procedure DlgSrvNew; Forward;
Procedure DlgSrvLend; Forward;
Procedure DlgSrvReturn; Forward;
Procedure DlgSrvRpt; Forward;
Procedure DlgHrsList; Forward;
Procedure DlgHrsEdit; Forward;
Procedure DlgHrsToday; Forward;
Procedure DlgHrsRpt; Forward;
Procedure DlgInsList; Forward;
Procedure DlgInsNew; Forward;
Procedure DlgInsView; Forward;
Procedure DlgInsFailed; Forward;
Procedure DlgInsRpt; Forward;
Procedure DlgCplList; Forward;
Procedure DlgCplNew; Forward;
Procedure DlgCplResp; Forward;
Procedure DlgCplRpt; Forward;
Procedure DlgPVList; Forward;
Procedure DlgPVRec; Forward;
Procedure DlgPVToday; Forward;
Procedure DlgPVRpt; Forward;
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
 Y1 := M.Y + MENUBAR_HEIGHT;
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

Procedure CalcMenuBarHeight;
Var I, TX, TW, Rows: Integer;
Begin
 TX := 4; Rows := 1;
 For I := 0 To MainMenuBar.MenuCount - 1 Do Begin
  TW := Length(MainMenuBar.Menus[I].Title) * CHARW + 16;
  If (TX + TW > ScreenWidth - 4) And (TX > 4) Then Begin
   TX := 4; Inc(Rows);
  End;
  TX := TX + TW;
 End;
 MainMenuBar.Height := Rows * MENUBAR_HEIGHT;
End;

Procedure DrawMenuBar;
Var I, TX, TY, TW: Integer;
Begin
 SetColor(CLR_MENUBAR);
 SetFillStyle(SolidFill, CLR_MENUBAR);
 Bar(0, MainMenuBar.Y, ScreenWidth - 1,
     MainMenuBar.Y + MainMenuBar.Height - 1);
 SetColor(CLR_BORDER);
 Line(0, MainMenuBar.Y + MainMenuBar.Height - 1,
      ScreenWidth - 1, MainMenuBar.Y + MainMenuBar.Height - 1);
 TX := 4;
 TY := MainMenuBar.Y;
 For I := 0 To MainMenuBar.MenuCount - 1 Do Begin
  TW := Length(MainMenuBar.Menus[I].Title) * CHARW + 16;
  If (TX + TW > ScreenWidth - 4) And (TX > 4) Then Begin
   TX := 4;
   TY := TY + MENUBAR_HEIGHT;
  End;
  MainMenuBar.Menus[I].X := TX - 4;
  MainMenuBar.Menus[I].Y := TY;
  If I = OpenMenuIdx Then Begin
   SetFillStyle(SolidFill, CLR_MENU_HIGHLIGHT);
   Bar(TX - 4, TY,
       TX + Length(MainMenuBar.Menus[I].Title) * CHARW + 12,
       TY + MENUBAR_HEIGHT - 2);
   SetColor(White);
  End Else
   SetColor(CLR_MENU_TEXT);
  OutTextXY(TX, TY + 6, MainMenuBar.Menus[I].Title);
  TX := TX + TW;
 End;
End;

Procedure DrawOpenMenu;
Var
 I, YPos, MX, MY, MW, MH, SW: Integer;
 M: TMenu;
Begin
 If OpenMenuIdx < 0 Then Exit;
 M := MainMenuBar.Menus[OpenMenuIdx];
 MX := M.X;
 MY := M.Y + MENUBAR_HEIGHT;
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
 Bar(MX + 2, MY + 2, MX + MW + 2, MY + MH + 2);
 { Fond }
 SetFillStyle(SolidFill, LightGray);
 Bar(MX, MY, MX + MW, MY + MH);
 { Bordure }
 SetColor(CLR_BORDER);
 Rectangle(MX, MY, MX + MW, MY + MH);
 YPos := MY + 2;
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
Var I, TX, TY, TW: Integer;
Begin
 MenuBarHitTest := -1;
 If MenuActive And MenuBgSaved And
    (MX >= MenuBgX1) And (MX <= MenuBgX2) And
    (MY >= MenuBgY1) And (MY <= MenuBgY2) Then Exit;
 If (MY < MainMenuBar.Y) Or
    (MY >= MainMenuBar.Y + MainMenuBar.Height) Then Exit;
 TX := 4;
 TY := MainMenuBar.Y;
 For I := 0 To MainMenuBar.MenuCount - 1 Do Begin
  TW := Length(MainMenuBar.Menus[I].Title) * CHARW + 16;
  If (TX + TW > ScreenWidth - 4) And (TX > 4) Then Begin
   TX := 4;
   TY := TY + MENUBAR_HEIGHT;
  End;
  If (MX >= TX - 4) And (MX < TX + TW - 4) And
     (MY >= TY) And (MY < TY + MENUBAR_HEIGHT) Then Begin
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
 YPos := M.Y + MENUBAR_HEIGHT + 2;
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
 AddMenuItem(MainMenuBar.Menus[0], 'Reset kiosques', 'Ctrl+N', TAG_FILE_NEW);
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

 InitMenu(MainMenuBar.Menus[2], 'Kiosques RMU');
 AddMenuItem(MainMenuBar.Menus[2], 'Reserver un kiosque RMU...',   'F5', TAG_PARK_RESERVE);
 AddMenuItem(MainMenuBar.Menus[2], 'Liberer un kiosque RMU...',    'F6', TAG_PARK_FREE);
 AddMenuItem(MainMenuBar.Menus[2], 'Etendre reservation...',  'F7', TAG_PARK_EXTEND);
 AddMenuItem(MainMenuBar.Menus[2], 'Infos sur un kiosque...',  'F8', TAG_PARK_INFO);
 AddMenuSeparator(MainMenuBar.Menus[2]);
 AddMenuItem(MainMenuBar.Menus[2], 'Rechercher (reference)...',  'F9', TAG_PARK_SEARCH);
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


 InitMenu(MainMenuBar.Menus[10], 'Securite');
 AddMenuItem(MainMenuBar.Menus[10], 'Agents : liste...',        '', 5400);
 AddMenuItem(MainMenuBar.Menus[10], 'Agents : roster...',       '', 5404);
 AddMenuItem(MainMenuBar.Menus[10], 'Incidents : liste...',     '', 5420);
 AddMenuItem(MainMenuBar.Menus[10], 'Incidents : nouveau...',   '', 5421);
 AddMenuItem(MainMenuBar.Menus[10], 'Incidents : du jour...',   '', 5424);
 AddMenuSeparator(MainMenuBar.Menus[10]);
 AddMenuItem(MainMenuBar.Menus[10], 'Rondes : liste...',        '', 5440);
 AddMenuItem(MainMenuBar.Menus[10], 'Rondes : demarrer...',     '', 5441);
 AddMenuItem(MainMenuBar.Menus[10], 'Objets perdus...',         '', 5460);
 AddMenuItem(MainMenuBar.Menus[10], 'CCTV : etat...',           '', 5481);
 AddMenuItem(MainMenuBar.Menus[10], 'Visiteurs : passes...',    '', 5490);
 MainMenuBar.Menus[10].Width := MenuItemWidth(MainMenuBar.Menus[10]);

 InitMenu(MainMenuBar.Menus[11], 'Espaces locatifs');
 AddMenuItem(MainMenuBar.Menus[11], 'Liste espaces locatifs...',       '', 5000);
 AddMenuItem(MainMenuBar.Menus[11], 'Nouvel espace locatif...',     '', 5001);
 AddMenuItem(MainMenuBar.Menus[11], 'Editer espace locatif...',       '', 5002);
 AddMenuItem(MainMenuBar.Menus[11], 'Supprimer espace locatif...',    '', 5003);
 AddMenuItem(MainMenuBar.Menus[11], 'Info espace locatif...',         '', 5004);
 AddMenuItem(MainMenuBar.Menus[11], 'Espaces vacants...',        '', 5006);
 AddMenuItem(MainMenuBar.Menus[11], 'Baux expirant...',         '', 5007);
 AddMenuSeparator(MainMenuBar.Menus[11]);
 AddMenuItem(MainMenuBar.Menus[11], 'Baux : liste...',          '', 5010);
 AddMenuItem(MainMenuBar.Menus[11], 'Baux : annuler...',        '', 5013);
 AddMenuItem(MainMenuBar.Menus[11], 'Loyers : liste...',        '', 5020);
 AddMenuItem(MainMenuBar.Menus[11], 'Loyers : encaisser...',    '', 5021);
 AddMenuItem(MainMenuBar.Menus[11], 'Loyers : a payer...',      '', 5022);
 AddMenuItem(MainMenuBar.Menus[11], 'Rapport espaces locatifs...',     '', 5005);
 MainMenuBar.Menus[11].Width := MenuItemWidth(MainMenuBar.Menus[11]);

 InitMenu(MainMenuBar.Menus[12], 'Food Court');
 AddMenuItem(MainMenuBar.Menus[12], 'Vendeurs...',              '', 5100);
 AddMenuItem(MainMenuBar.Menus[12], 'Nouveau vendeur...',       '', 5101);
 AddMenuItem(MainMenuBar.Menus[12], 'Supp. vendeur...',         '', 5103);
 AddMenuItem(MainMenuBar.Menus[12], 'Menus...',                 '', 5110);
 AddMenuSeparator(MainMenuBar.Menus[12]);
 AddMenuItem(MainMenuBar.Menus[12], 'Enregistrer vente...',     '', 5120);
 AddMenuItem(MainMenuBar.Menus[12], 'Ventes du jour...',        '', 5121);
 AddMenuItem(MainMenuBar.Menus[12], 'Ventes semaine...',        '', 5122);
 AddMenuItem(MainMenuBar.Menus[12], 'Top vendeurs...',          '', 5123);
 AddMenuItem(MainMenuBar.Menus[12], 'Rapport food court...',    '', 5124);
 MainMenuBar.Menus[12].Width := MenuItemWidth(MainMenuBar.Menus[12]);

 InitMenu(MainMenuBar.Menus[13], 'Marketing');
 AddMenuItem(MainMenuBar.Menus[13], 'Evenements...',            '', 5200);
 AddMenuItem(MainMenuBar.Menus[13], 'Nouvel evenement...',      '', 5201);
 AddMenuItem(MainMenuBar.Menus[13], 'Evenements en cours...',   '', 5204);
 AddMenuItem(MainMenuBar.Menus[13], 'Rapport evenements...',    '', 5205);
 AddMenuSeparator(MainMenuBar.Menus[13]);
 AddMenuItem(MainMenuBar.Menus[13], 'Promotions...',            '', 5210);
 AddMenuItem(MainMenuBar.Menus[13], 'Nouvelle promo...',        '', 5211);
 AddMenuItem(MainMenuBar.Menus[13], 'Promos actives...',        '', 5214);
 AddMenuItem(MainMenuBar.Menus[13], 'Rapport promos...',        '', 5215);
 MainMenuBar.Menus[13].Width := MenuItemWidth(MainMenuBar.Menus[13]);

 InitMenu(MainMenuBar.Menus[14], 'Entretien');
 AddMenuItem(MainMenuBar.Menus[14], 'Maintenance : liste...',   '', 5300);
 AddMenuItem(MainMenuBar.Menus[14], 'Maintenance : nouveau...', '', 5301);
 AddMenuItem(MainMenuBar.Menus[14], 'Maintenance : ouverts...', '', 5304);
 AddMenuItem(MainMenuBar.Menus[14], 'Maintenance : fermer...',  '', 5303);
 AddMenuItem(MainMenuBar.Menus[14], 'Rapport maintenance...',   '', 5305);
 AddMenuSeparator(MainMenuBar.Menus[14]);
 AddMenuItem(MainMenuBar.Menus[14], 'Nettoyage : liste...',     '', 5310);
 AddMenuItem(MainMenuBar.Menus[14], 'Nettoyage : nouveau...',   '', 5311);
 AddMenuItem(MainMenuBar.Menus[14], 'Nettoyage : fait...',      '', 5312);
 AddMenuItem(MainMenuBar.Menus[14], 'Rapport nettoyage...',     '', 5313);
 MainMenuBar.Menus[14].Width := MenuItemWidth(MainMenuBar.Menus[14]);

 InitMenu(MainMenuBar.Menus[15], 'Tableau MALL');
 AddMenuItem(MainMenuBar.Menus[15], 'Tableau de bord...',       '', 5600);
 AddMenuItem(MainMenuBar.Menus[15], 'Occupation...',            '', 5601);
 AddMenuItem(MainMenuBar.Menus[15], 'Revenus...',               '', 5602);
 AddMenuItem(MainMenuBar.Menus[15], 'A propos MALL...',         '', 5603);
 MainMenuBar.Menus[15].Width := MenuItemWidth(MainMenuBar.Menus[15]);

 InitMenu(MainMenuBar.Menus[16], 'Fidelite');
 AddMenuItem(MainMenuBar.Menus[16], 'Membres : liste...',       '', 5700);
 AddMenuItem(MainMenuBar.Menus[16], 'Membres : nouveau...',     '', 5701);
 AddMenuItem(MainMenuBar.Menus[16], 'Membres : supprimer...',   '', 5703);
 AddMenuItem(MainMenuBar.Menus[16], 'Ajouter points...',        '', 5704);
 AddMenuItem(MainMenuBar.Menus[16], 'Top membres...',           '', 5705);
 AddMenuItem(MainMenuBar.Menus[16], 'Anniversaires...',         '', 5707);
 AddMenuItem(MainMenuBar.Menus[16], 'Rapport fidelite...',      '', 5706);
 AddMenuSeparator(MainMenuBar.Menus[16]);
 AddMenuItem(MainMenuBar.Menus[16], 'Campagnes : liste...',     '', 5710);
 AddMenuItem(MainMenuBar.Menus[16], 'Campagnes : nouvelle...',  '', 5711);
 AddMenuItem(MainMenuBar.Menus[16], 'Campagnes : actives...',   '', 5714);
 AddMenuItem(MainMenuBar.Menus[16], 'Campagnes : rapport...',   '', 5715);
 AddMenuSeparator(MainMenuBar.Menus[16]);
 AddMenuItem(MainMenuBar.Menus[16], 'Trafic : liste...',        '', 5720);
 AddMenuItem(MainMenuBar.Menus[16], 'Trafic : enregistrer...',  '', 5721);
 AddMenuItem(MainMenuBar.Menus[16], 'Trafic : aujourdhui...',   '', 5722);
 AddMenuItem(MainMenuBar.Menus[16], 'Trafic : pic...',          '', 5725);
 AddMenuItem(MainMenuBar.Menus[16], 'Trafic : rapport...',      '', 5724);
 AddMenuSeparator(MainMenuBar.Menus[16]);
 AddMenuItem(MainMenuBar.Menus[16], 'Feedback : liste...',      '', 5730);
 AddMenuItem(MainMenuBar.Menus[16], 'Feedback : nouveau...',    '', 5731);
 AddMenuItem(MainMenuBar.Menus[16], 'Feedback : rapport...',    '', 5733);
 MainMenuBar.Menus[16].Width := MenuItemWidth(MainMenuBar.Menus[16]);

 InitMenu(MainMenuBar.Menus[17], 'Operations');
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : liste...',   '', 5800);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : nouveau...', '', 5801);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : edit...',    '', 5802);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : suppr...',   '', 5803);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : faible...',  '', 5804);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : reappro...', '', 5806);
 AddMenuItem(MainMenuBar.Menus[17], 'Inv general : rapport...', '', 5805);
 AddMenuSeparator(MainMenuBar.Menus[17]);
 AddMenuItem(MainMenuBar.Menus[17], 'Staff : liste...',         '', 5900);
 AddMenuItem(MainMenuBar.Menus[17], 'Staff : nouveau...',       '', 5901);
 AddMenuItem(MainMenuBar.Menus[17], 'Staff : supprimer...',     '', 5903);
 AddMenuItem(MainMenuBar.Menus[17], 'Staff : horaires...',      '', 5904);
 AddMenuItem(MainMenuBar.Menus[17], 'Staff : rapport...',       '', 5905);
 AddMenuSeparator(MainMenuBar.Menus[17]);
 AddMenuItem(MainMenuBar.Menus[17], 'Rapports : liste...',      '', 5740);
 AddMenuItem(MainMenuBar.Menus[17], 'Rapports : generer...',    '', 5741);
 AddMenuItem(MainMenuBar.Menus[17], 'Rapports : voir...',       '', 5742);
 AddMenuItem(MainMenuBar.Menus[17], 'Rapports : export...',     '', 5743);
 MainMenuBar.Menus[17].Width := MenuItemWidth(MainMenuBar.Menus[17]);

 InitMenu(MainMenuBar.Menus[18], 'Services');
 AddMenuItem(MainMenuBar.Menus[18], 'Cartes-cadeaux : liste...',  '', 6000);
 AddMenuItem(MainMenuBar.Menus[18], 'Cartes-cadeaux : emettre...','', 6001);
 AddMenuItem(MainMenuBar.Menus[18], 'Cartes-cadeaux : utiliser...','', 6002);
 AddMenuItem(MainMenuBar.Menus[18], 'Cartes-cadeaux : solde...',  '', 6003);
 AddMenuItem(MainMenuBar.Menus[18], 'Cartes-cadeaux : rapport...','', 6004);
 AddMenuSeparator(MainMenuBar.Menus[18]);
 AddMenuItem(MainMenuBar.Menus[18], 'Services : liste...',        '', 6100);
 AddMenuItem(MainMenuBar.Menus[18], 'Services : nouveau...',      '', 6101);
 AddMenuItem(MainMenuBar.Menus[18], 'Services : pret...',         '', 6102);
 AddMenuItem(MainMenuBar.Menus[18], 'Services : retour...',       '', 6103);
 AddMenuItem(MainMenuBar.Menus[18], 'Services : rapport...',      '', 6104);
 AddMenuSeparator(MainMenuBar.Menus[18]);
 AddMenuItem(MainMenuBar.Menus[18], 'Horaires : liste...',        '', 6200);
 AddMenuItem(MainMenuBar.Menus[18], 'Horaires : editer...',       '', 6201);
 AddMenuItem(MainMenuBar.Menus[18], 'Horaires : aujourdhui...',   '', 6202);
 AddMenuItem(MainMenuBar.Menus[18], 'Park valid. : liste...',     '', 6500);
 AddMenuItem(MainMenuBar.Menus[18], 'Park valid. : enregistrer...','', 6501);
 MainMenuBar.Menus[18].Width := MenuItemWidth(MainMenuBar.Menus[18]);

 InitMenu(MainMenuBar.Menus[19], 'Conformite');
 AddMenuItem(MainMenuBar.Menus[19], 'Inspections : liste...',     '', 6300);
 AddMenuItem(MainMenuBar.Menus[19], 'Inspections : nouvelle...',  '', 6301);
 AddMenuItem(MainMenuBar.Menus[19], 'Inspections : voir...',      '', 6302);
 AddMenuItem(MainMenuBar.Menus[19], 'Inspections : echec/maj...', '', 6303);
 AddMenuItem(MainMenuBar.Menus[19], 'Inspections : rapport...',   '', 6304);
 AddMenuSeparator(MainMenuBar.Menus[19]);
 AddMenuItem(MainMenuBar.Menus[19], 'Plaintes : liste...',        '', 6400);
 AddMenuItem(MainMenuBar.Menus[19], 'Plaintes : nouvelle...',     '', 6401);
 AddMenuItem(MainMenuBar.Menus[19], 'Plaintes : repondre...',     '', 6402);
 AddMenuItem(MainMenuBar.Menus[19], 'Plaintes : rapport...',      '', 6403);
 MainMenuBar.Menus[19].Width := MenuItemWidth(MainMenuBar.Menus[19]);
 MainMenuBar.MenuCount := 20;
 CalcMenuBarHeight;
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
 GridY := MainMenuBar.Height + Margin;
 AvailW := ScreenWidth - 2 * Margin;
 AvailH := ScreenHeight - MainMenuBar.Height - STATUSBAR_HEIGHT - 2 * Margin;
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
 GridY := MainMenuBar.Height +
          (ScreenHeight - MainMenuBar.Height - STATUSBAR_HEIGHT - GridH) Div 2;
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
 FillRect(0, MainMenuBar.Height,
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
                      'Reinitialiser tous les kiosques RMU ?') Then Begin
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
  ShowMessageBox('Reservation', 'Aucun kiosque RMU libre disponible.');
  Exit;
 End;
 If Spots[SpotIndex].State <> ssFree Then Begin
  ShowMessageBox('Reservation',
                 'La place ' + IntToStr(SpotIndex + 1) +
                 ' est deja occupee.');
  Exit;
 End;
 DlgInit(D, 'Reserver le kiosque RMU no ' + IntToStr(SpotIndex + 1), 480, 400);
 DlgAddLabel(D, 16, 6, 'Reference contrat (ex: RMU24-001) :');
 IPlate := DlgAddEdit(D, 220, 4, 200, '', 12);
 DlgAddLabel(D, 16, 30, 'Nom du locataire :');
 IOwner := DlgAddEdit(D, 220, 28, 240, '', 30);
 DlgAddLabel(D, 16, 54, 'Telephone (optionnel) :');
 IPhone := DlgAddEdit(D, 220, 52, 200, '', 15);
 DlgAddFrame(D, 16, 84, 446, 220, 'Duree de location');
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
   ShowMessageBox('Erreur', 'La reference contrat est obligatoire.');
   Exit;
  End;
  PrevSpot := FindByPlate(Plate);
  If PrevSpot >= 0 Then Begin
   ShowMessageBox('Doublon',
                  'Le contrat ' + Plate + ' loue deja le kiosque ' +
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
  If ShowConfirmBox('Kiosque ' + IntToStr(Idx + 1) + ' libre',
                    'Voulez-vous louer ce kiosque RMU ?') Then
   DlgReserve(Idx);
  Exit;
 End;
 Title := 'Kiosque RMU no ' + IntToStr(Idx + 1) + ' (loue)';
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
 If Not ShowInputBox('Liberer un kiosque',
                     'Entrez le numero de place ou la plaque :',
                     Plate, 15) Then Exit;
 Plate := UpStr(TrimStr(Plate));
 If Plate = '' Then Exit;
 { Essaie comme numero d abord }
 Idx := StrToIntDef(Plate, -1);
 If (Idx >= 1) And (Idx <= SpotCount) Then Idx := Idx - 1
 Else Idx := FindByPlate(Plate);
 If Idx < 0 Then Begin
  ShowMessageBox('Introuvable', 'Aucun kiosque ne correspond.');
  Exit;
 End;
 DlgSpotInfo(Idx);
End;

{ --- Rechercher --- }

Procedure DlgSearchByPlate;
Var Plate: String; Idx: Integer;
Begin
 Plate := '';
 If Not ShowInputBox('Rechercher un kiosque',
                     'Reference contrat (ex: RMU24-001) :',
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
 DlgInit(D, 'A propos de MALL', 400, 240);
 DlgAddLabel(D, 80, 10,  'MALL - Mall Management System');
 DlgAddLabel(D, 130, 30, 'Version ' + PARKING_VERSION);
 DlgAddLabel(D, 130, 46, 'Date : ' + PARKING_DATE);
 DlgAddHLine(D, 20, 70, 360);
 DlgAddLabel(D, 20, 80,  'Auteur : Sylvain Maltais');
 DlgAddLabel(D, 20, 96,  'Site   : www.gladir.com/physiq');
 DlgAddLabel(D, 20, 112, 'Cible  : Turbo Pascal 7 / Free Pascal');
 DlgAddLabel(D, 20, 134, 'Systeme de gestion complet d''un centre');
 DlgAddLabel(D, 20, 148, 'commercial : espaces locatifs, baux, loyers, food court,');
 DlgAddLabel(D, 20, 162, 'marketing, securite, fidelite et services aux clients.');
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
 DlgAddLabel(D, 16, Y, 'F6       Liberer un kiosque');                   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F7       Etendre une reservation');             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F8       Infos sur un kiosque');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F9       Rechercher par plaque');               Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+N   Reset kiosques');                     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+O   Ouvrir fichier');                      Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+S   Enregistrer');                         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Alt+X    Quitter');                             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Souris : clic sur un kiosque pour le louer/liberer.'); Y := Y + 14;
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
 DlgAddLabel(D, 16, Y, 'MALL gere un centre commercial avec ses espaces locatifs,');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'son food court, sa securite, son programme fidelite,');     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'ses campagnes marketing et son stationnement integre.');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'La grille ci-dessous montre l''etat du stationnement.');        Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'KIOSQUES RMU : cliquez un emplacement libre pour le louer.');         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'ESPACES LOCATIFS : voir Espaces locatifs>Liste/Baux/Loyers.');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'FOOD COURT : voir Food Court>Vendeurs et menus.');   Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'SECURITE : voir Securite pour agents et incidents.'); Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'FIDELITE : voir Fidelite pour les membres et points.');           Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'OPERATIONS : voir Operations pour staff et inventaire.');           Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'CONFORMITE : voir Conformite pour inspections/plaintes.');  Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'SERVICES : voir Services pour cartes-cadeaux et prets.');
 DlgAddButton(D, 210, 290, 80, 'OK', 1, 'O');
 DlgRun(D);
End;

{ --- Save / Load via input box --- }

Procedure DlgSaveAs;
Var FName: String;
Begin
 FName := CurrentFile;
 If FName = '' Then FName := 'mall.dat';
 If ShowInputBox('Enregistrer sous', 'Nom du fichier :', FName, 80) Then
  SaveToFile(FName);
End;

Procedure DlgOpenFile;
Var FName: String;
Begin
 FName := CurrentFile;
 If FName = '' Then FName := 'mall.dat';
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
   If ShowConfirmBox('Quitter', 'Quitter MALL ?') Then
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
    Else ShowMessageBox('Erreur', 'Kiosque invalide ou libre.');
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

  { ============== Dispatch MALL ============== }
  5000: DlgTenantList;
  5001: DlgTenantNew;
  5002: DlgTenantEdit2;
  5003: DlgTenantDel;
  5004: DlgTenantInfo;
  5005: DlgTenantRpt;
  5006: DlgTenantVacant;
  5007: DlgTenantExpire;
  5010: DlgLeaseList;
  5011: DlgLeaseNew;
  5012: DlgLeaseEdit;
  5013: DlgLeaseDel;
  5014: DlgLeaseRpt;
  5020: DlgRentList;
  5021: DlgRentPay;
  5022: DlgRentDue;
  5023: DlgRentRpt;
  5100: DlgFV2List;
  5101: DlgFV2New;
  5102: DlgFV2Edit;
  5103: DlgFV2Del;
  5104: DlgFV2Rpt;
  5110: DlgFM2List;
  5111: DlgFM2New;
  5112: DlgFM2Edit;
  5113: DlgFM2Del;
  5120: DlgFS2Rec;
  5121: DlgFS2Today;
  5122: DlgFS2Week;
  5123: DlgFS2Top;
  5124: DlgFS2Rpt;
  5200: DlgEvtList;
  5201: DlgEvtNew;
  5202: DlgEvtEdit;
  5203: DlgEvtDel;
  5204: DlgEvtToday;
  5205: DlgEvtRpt;
  5210: DlgPromoList;
  5211: DlgPromoNew;
  5212: DlgPromoEdit;
  5213: DlgPromoDel;
  5214: DlgPromoActive;
  5215: DlgPromoRpt;
  5300: DlgMaintList;
  5301: DlgMaintNew;
  5302: DlgMaintEdit;
  5303: DlgMaintClose;
  5304: DlgMaintOpen;
  5305: DlgMaintRpt;
  5310: DlgCleanList;
  5311: DlgCleanNew;
  5312: DlgCleanDone;
  5313: DlgCleanRpt;
  5400: DlgGuards;
  5404: DlgGuardRoster;
  5405: DlgGuardReport;
  5420: DlgIncidentList;
  5421: DlgIncidentNew;
  5424: DlgIncidentToday;
  5425: DlgIncidentReport;
  5426: DlgIncidentTrends;
  5440: DlgRoundList;
  5441: DlgRoundStart;
  5442: DlgRoundReport;
  5460: DlgLFList;
  5461: DlgLFReport;
  5481: DlgCCTVStatus;
  5482: DlgCCTVReport;
  5490: DlgVisitorPassList;
  5600: DlgMallDash;
  5601: DlgMallOccupancy;
  5602: DlgMallRevenue;
  5603: DlgMallAbout;
  5700: DlgLoyList;
  5701: DlgLoyNew;
  5702: DlgLoyEdit;
  5703: DlgLoyDel;
  5704: DlgLoyPts;
  5705: DlgLoyTop;
  5706: DlgLoyRpt;
  5707: DlgLoyAnni;
  5710: DlgCampList;
  5711: DlgCampNew;
  5712: DlgCampEdit;
  5713: DlgCampDel;
  5714: DlgCampAct;
  5715: DlgCampRpt;
  5720: DlgTrfList;
  5721: DlgTrfRec;
  5722: DlgTrfToday;
  5723: DlgTrfWeek;
  5724: DlgTrfRpt;
  5725: DlgTrfPeak;
  5730: DlgFBList;
  5731: DlgFBNew;
  5732: DlgFBResp;
  5733: DlgFBRpt;
  5740: DlgDRList;
  5741: DlgDRGen;
  5742: DlgDRView;
  5743: DlgDRExport;
  5800: DlgInv2List;
  5801: DlgInv2New;
  5802: DlgInv2Edit;
  5803: DlgInv2Del;
  5804: DlgInv2Low;
  5805: DlgInv2Rpt;
  5806: DlgInv2Reord;
  5900: DlgStfList;
  5901: DlgStfNew;
  5902: DlgStfEdit;
  5903: DlgStfDel;
  5904: DlgStfSched;
  5905: DlgStfRpt;
  6000: DlgGCList;
  6001: DlgGCIssue;
  6002: DlgGCRedeem;
  6003: DlgGCBal;
  6004: DlgGCRpt;
  6100: DlgSrvList;
  6101: DlgSrvNew;
  6102: DlgSrvLend;
  6103: DlgSrvReturn;
  6104: DlgSrvRpt;
  6200: DlgHrsList;
  6201: DlgHrsEdit;
  6202: DlgHrsToday;
  6203: DlgHrsRpt;
  6300: DlgInsList;
  6301: DlgInsNew;
  6302: DlgInsView;
  6303: DlgInsFailed;
  6304: DlgInsRpt;
  6400: DlgCplList;
  6401: DlgCplNew;
  6402: DlgCplResp;
  6403: DlgCplRpt;
  6500: DlgPVList;
  6501: DlgPVRec;
  6502: DlgPVToday;
  6503: DlgPVRpt;
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
  ShowMessageBox('Erreur', 'La reference contrat est obligatoire.'); Exit;
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
 OutTextXY(8, 4, 'Etat d''occupation des kiosques RMU');
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
 L[N] := 'Etat des kiosques RMU :'; Inc(N);
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
 L[N] := 'Kios. Reference      Locataire        Restant'; Inc(N);
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
  L[N] := '(aucun kiosque loue)'; Inc(N);
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


{ ==== MODULES EXTENSION MALL ==== }
{ === BEGIN MALL_INC_E_SECURITY.TXT === }
{ ============================================================
  MALL_INC_E_SECURITY.TXT
  Module de gestion de securite pour le centre commercial

  Contient: gardes, incidents, rondes de securite,
            objets trouves/perdus, cameras CCTV,
            passes de visiteur

  @author: Sylvain Maltais
  @version: 1.00
  @date: 2026
  ============================================================ }

{ Enumeration des equipes de travail des gardes }
Type
 TGuardShift = (GSH_DAY, GSH_EVENING, GSH_NIGHT);
 TGuardStatus = (GST_OFF, GST_ONDUTY, GST_BREAK, GST_RESPONDING);
 TIncidentKind = (IK_THEFT, IK_VANDALISM, IK_DISTURBANCE, IK_MEDICAL,
                  IK_FIRE, IK_FALL, IK_TRESPASS, IK_LOST_CHILD,
                  IK_HARASSMENT, IK_OTHER);
 TIncidentSeverity = (ISV_INFO, ISV_LOW, ISV_MEDIUM, ISV_HIGH, ISV_CRITICAL);
 TIncidentStatus = (ISTS_OPEN, ISTS_INVESTIGATING, ISTS_RESOLVED,
                    ISTS_REPORTED_POLICE);
 TRoundStatus = (RDS_PLANNED, RDS_INPROGRESS, RDS_DONE, RDS_MISSED);
 TLFItemStatus = (LFS_LOST, LFS_FOUND, LFS_CLAIMED, LFS_DISPOSED);
 TCCTVStatus = (CC_OK, CC_OFFLINE, CC_DEGRADED, CC_MAINTENANCE);

{ Structures de donnees pour la gestion de securite }

Type
 TGuard = Record
  Active: Boolean;
  ID: LongInt;
  Badge: String[6];
  FirstName: String[20];
  LastName: String[30];
  Shift: Byte;
  Status: Byte;
  AssignedZone: String[20];
  Phone: String[15];
  OnDutySince: TDateTime;
  Notes: String[40];
 End;

 TIncident = Record
  Active: Boolean;
  ID: LongInt;
  Kind: Byte;
  Severity: Byte;
  Status: Byte;
  OccurredDT: TDateTime;
  ReportedDT: TDateTime;
  ClosedDT: TDateTime;
  Location: String[30];
  Floor: Byte;
  ReportedBy: String[30];
  AssignedGuardID: LongInt;
  Description: String[80];
  Resolution: String[80];
 End;

 TGuardRound = Record
  Active: Boolean;
  ID: LongInt;
  GuardID: LongInt;
  StartDT: TDateTime;
  EndDT: TDateTime;
  Zone: String[20];
  Status: Byte;
  Notes: String[60];
 End;

 TLostFoundItem = Record
  Active: Boolean;
  ID: LongInt;
  DateReported: TDateTime;
  Description: String[60];
  LocationFound: String[30];
  Status: Byte;
  ClaimantName: String[40];
  ClaimantPhone: String[15];
  DateClaimed: TDateTime;
  Notes: String[40];
 End;

 TCCTVCamera = Record
  Active: Boolean;
  ID: Integer;
  CamID: String[6];
  Location: String[30];
  Floor: Byte;
  Status: Byte;
  LastCheck: TDateTime;
  Notes: String[40];
 End;

 TVisitorPass = Record
  Active: Boolean;
  ID: LongInt;
  PassNo: String[6];
  VisitorName: String[40];
  VisitorCompany: String[30];
  HostTenantID: LongInt;
  IssuedDT: TDateTime;
  ReturnedDT: TDateTime;
  Returned: Boolean;
 End;

{ ============================================================
  CONSTANTES DE TAGS POUR LES DIALOGUES
  ============================================================ }

Const
 { Tags pour interface utilisateur : 5400-5499 }
 TAG_SEC_GUARDS = 5400;
 TAG_SEC_GUARD_NEW = 5401;
 TAG_SEC_GUARD_EDIT = 5402;
 TAG_SEC_GUARD_ASSIGN = 5403;
 TAG_SEC_GUARD_ROSTER = 5404;
 TAG_SEC_GUARD_REPORT = 5405;

 TAG_SEC_INC_LIST = 5420;
 TAG_SEC_INC_NEW = 5421;
 TAG_SEC_INC_EDIT = 5422;
 TAG_SEC_INC_CLOSE = 5423;
 TAG_SEC_INC_TODAY = 5424;
 TAG_SEC_INC_REPORT = 5425;
 TAG_SEC_INC_TRENDS = 5426;

 TAG_SEC_ROUND_LIST = 5440;
 TAG_SEC_ROUND_START = 5441;
 TAG_SEC_ROUND_END = 5442;
 TAG_SEC_ROUND_REPORT = 5443;

 TAG_SEC_LF_LIST = 5460;
 TAG_SEC_LF_LOST = 5461;
 TAG_SEC_LF_FOUND = 5462;
 TAG_SEC_LF_CLAIM = 5463;
 TAG_SEC_LF_REPORT = 5464;

 TAG_SEC_CCTV_LIST = 5480;
 TAG_SEC_CCTV_STATUS = 5481;
 TAG_SEC_CCTV_REPORT = 5482;

 TAG_SEC_VPASS_LIST = 5490;
 TAG_SEC_VPASS_NEW = 5491;
 TAG_SEC_VPASS_RETURN = 5492;

 { Limites de capacite des modules }
 MAX_GUARDS = 30;
 MAX_INCIDENTS = 250;
 MAX_ROUNDS = 200;
 MAX_LOSTFOUND = 150;
 MAX_CCTV = 32;
 MAX_VISITOR_PASSES = 100;

{ ============================================================
  VARIABLES GLOBALES - DONNEES DE SECURITE
  ============================================================ }

Var
 { Gardes et gestion des equipes de securite }
 Guards: Array[0..MAX_GUARDS-1] Of TGuard;
 GuardCount: Integer;
 NextGuardID: LongInt;

 { Incidents signales et documentes }
 Incidents: Array[0..MAX_INCIDENTS-1] Of TIncident;
 IncidentCount: Integer;
 NextIncidentID: LongInt;

 { Rondes de securite periodiques }
 GuardRounds: Array[0..MAX_ROUNDS-1] Of TGuardRound;
 RoundCount: Integer;
 NextRoundID: LongInt;

 { Objets trouves/perdus en entreposage }
 LostFound: Array[0..MAX_LOSTFOUND-1] Of TLostFoundItem;
 LFCount: Integer;
 NextLFID: LongInt;

 { Cameras de surveillance CCTV }
 CCTVList: Array[0..MAX_CCTV-1] Of TCCTVCamera;
 CCTVCountG: Integer;

 { Passes de visiteur temporaires }
 VisitorPasses: Array[0..MAX_VISITOR_PASSES-1] Of TVisitorPass;
 VPCount: Integer;
 NextVPID: LongInt;

{ ============================================================
  DECLARATIONS AVANT (Forward declarations)
  ============================================================ }








{ ============================================================
  FONCTIONS D'ETIQUETAGE (Label functions)
  Convertissent les enumerations numeriques en chaines lisibles
  ============================================================ }

Function GuardShiftLabel(S: Byte): String;
Begin
 Case S Of
  0: GuardShiftLabel := 'Jour (08h-16h)';
  1: GuardShiftLabel := 'Soiree (16h-00h)';
  2: GuardShiftLabel := 'Nuit (00h-08h)';
 Else
  GuardShiftLabel := '?';
 End;
End;

Function GuardStatusLabel(S: Byte): String;
Begin
 { Affiche l'etat du garde en langage naturel }
 Case S Of
  0: GuardStatusLabel := 'Hors service';
  1: GuardStatusLabel := 'En service';
  2: GuardStatusLabel := 'En pause';
  3: GuardStatusLabel := 'Intervention';
 Else
  GuardStatusLabel := '?';
 End;
End;

Function IncidentKindLabel(K: Byte): String;
Begin
 { Decrit le type d'incident signale }
 Case K Of
  0: IncidentKindLabel := 'Vol';
  1: IncidentKindLabel := 'Vandalisme';
  2: IncidentKindLabel := 'Perturbation';
  3: IncidentKindLabel := 'Medical';
  4: IncidentKindLabel := 'Incendie';
  5: IncidentKindLabel := 'Chute';
  6: IncidentKindLabel := 'Intrusion';
  7: IncidentKindLabel := 'Enfant perdu';
  8: IncidentKindLabel := 'Harcelement';
  9: IncidentKindLabel := 'Autre';
 Else
  IncidentKindLabel := '?';
 End;
End;

Function IncidentSeverityLabel(S: Byte): String;
Begin
 { Indique le niveau de gravite de l'incident }
 Case S Of
  0: IncidentSeverityLabel := 'Info';
  1: IncidentSeverityLabel := 'Basse';
  2: IncidentSeverityLabel := 'Moyenne';
  3: IncidentSeverityLabel := 'Haute';
  4: IncidentSeverityLabel := 'Critique';
 Else
  IncidentSeverityLabel := '?';
 End;
End;

Function IncidentStatusLabel(S: Byte): String;
Begin
 { Affiche l'etat de progression de l'incident }
 Case S Of
  0: IncidentStatusLabel := 'Ouvert';
  1: IncidentStatusLabel := 'En investigation';
  2: IncidentStatusLabel := 'Resolu';
  3: IncidentStatusLabel := 'Police informee';
 Else
  IncidentStatusLabel := '?';
 End;
End;

Function RoundStatusLabel(S: Byte): String;
Begin
 { Indique le statut d'une ronde de securite }
 Case S Of
  0: RoundStatusLabel := 'Planifiee';
  1: RoundStatusLabel := 'En cours';
  2: RoundStatusLabel := 'Terminee';
  3: RoundStatusLabel := 'Manquee';
 Else
  RoundStatusLabel := '?';
 End;
End;

Function LFStatusLabel(S: Byte): String;
Begin
 { Indique le statut d'un objet trouve ou perdu }
 Case S Of
  0: LFStatusLabel := 'Perdu';
  1: LFStatusLabel := 'Trouve';
  2: LFStatusLabel := 'Reclame';
  3: LFStatusLabel := 'Dispose';
 Else
  LFStatusLabel := '?';
 End;
End;

Function CCTVStatusLabel(S: Byte): String;
Begin
 { Affiche l'etat d'une camera CCTV }
 Case S Of
  0: CCTVStatusLabel := 'Operationnel';
  1: CCTVStatusLabel := 'Hors ligne';
  2: CCTVStatusLabel := 'Degrade';
  3: CCTVStatusLabel := 'Maintenance';
 Else
  CCTVStatusLabel := '?';
 End;
End;

{ ============================================================
  FONCTIONS DE RECHERCHE (Lookup functions)
  Implementent les acces par cle primaire aux structures
  ============================================================ }

Function FindGuardByID(ID: LongInt): Integer;
Var
 I: Integer;
Begin
 { Localise un garde dans le tableau par son ID unique }
 FindGuardByID := -1;
 For I := 0 To GuardCount - 1 Do
  If Guards[I].Active And (Guards[I].ID = ID) Then
  Begin
   FindGuardByID := I;
   Exit;
  End;
End;

Function FindGuardByBadge(Const Badge: String): Integer;
Var
 I: Integer;
 UpperBadge: String;
Begin
 { Localise un garde par son numero de badge }
 FindGuardByBadge := -1;
 UpperBadge := UpStr(Badge);
 For I := 0 To GuardCount - 1 Do
  If Guards[I].Active And (UpStr(Guards[I].Badge) = UpperBadge) Then
  Begin
   FindGuardByBadge := I;
   Exit;
  End;
End;

Function FindIncidentByID(ID: LongInt): Integer;
Var
 I: Integer;
Begin
 { Localise un incident par son numero unique }
 FindIncidentByID := -1;
 For I := 0 To IncidentCount - 1 Do
  If Incidents[I].Active And (Incidents[I].ID = ID) Then
  Begin
   FindIncidentByID := I;
   Exit;
  End;
End;

{ ============================================================
  FONCTIONS DE COMPTAGE STATISTIQUE
  Fournissent des metriques de gestion en temps reel
  ============================================================ }

Function OpenIncidentsCount: Integer;
Var
 I, Count: Integer;
Begin
 { Compte les incidents encore ouverts ou en investigation }
 Count := 0;
 For I := 0 To IncidentCount - 1 Do
  If Incidents[I].Active And (Incidents[I].Status < 2) Then
   Inc(Count);
 OpenIncidentsCount := Count;
End;

Function ActiveGuardsCount: Integer;
Var
 I, Count: Integer;
Begin
 { Compte les gardes actuellement en service }
 Count := 0;
 For I := 0 To GuardCount - 1 Do
  If Guards[I].Active And (Guards[I].Status = 1) Then
   Inc(Count);
 ActiveGuardsCount := Count;
End;

Function OfflineCCTVCount: Integer;
Var
 I, Count: Integer;
Begin
 { Compte les cameras hors ligne ou en maintenance }
 Count := 0;
 For I := 0 To CCTVCountG - 1 Do
  If CCTVList[I].Active And (CCTVList[I].Status > 0) Then
   Inc(Count);
 OfflineCCTVCount := Count;
End;

Function UnclaimedLFCount: Integer;
Var
 I, Count: Integer;
Begin
 { Compte les objets trouves non encore reclames }
 Count := 0;
 For I := 0 To LFCount - 1 Do
  If LostFound[I].Active And (LostFound[I].Status = 1) Then
   Inc(Count);
 UnclaimedLFCount := Count;
End;

{ ============================================================
  INITIALISATION DES DONNEES DE DEMONSTRATION
  Cree un ensemble realiste de donnees pour tester le systeme
  ============================================================ }

Procedure InitSecurity;
Var
 I, J: Integer;
 DT: TDateTime;
Begin
 { Initialiser tous les compteurs et identificateurs a zero }
 GuardCount := 0;
 NextGuardID := 1001;
 IncidentCount := 0;
 NextIncidentID := 10001;
 RoundCount := 0;
 NextRoundID := 5001;
 LFCount := 0;
 NextLFID := 2001;
 CCTVCountG := 0;
 VPCount := 0;
 NextVPID := 3001;

 GetCurrentDT(DT);

 { Creer 10 gardes repartis sur trois equipes de travail }
 For I := 0 To 9 Do
 Begin
  With Guards[I] Do
  Begin
   Active := True;
   ID := NextGuardID;
   Inc(NextGuardID);
   Badge := IntToStr(1000 + I);
   FirstName := 'Garde';
   LastName := IntToStr(I + 1);
   Shift := I Mod 3;
   Status := 1;
   AssignedZone := 'Zone ' + IntToStr((I Mod 4) + 1);
   Phone := '555-' + PadLeft(IntToStr(1000 + I), 4);
   OnDutySince := DT;
   Notes := 'Garde actif en rotation';
  End;
  Inc(GuardCount);
 End;

 { Creer 24 cameras CCTV reparties sur 3 etages de surveillance }
 For I := 0 To 23 Do
 Begin
  With CCTVList[I] Do
  Begin
   Active := True;
   ID := I + 1;
   CamID := 'CAM' + IntToStrPad(I + 1, 3);
   Floor := (I Div 8) + 1;
   Location := 'Corridor ' + IntToStr((I Mod 8) + 1) + ', Etage ' +
               IntToStr(Floor);
   Status := I Mod 4;
   GetCurrentDT(LastCheck);
   Notes := 'Camera ' + CamID + ' en surveillance';
  End;
  Inc(CCTVCountG);
 End;

 { Creer 15 incidents historiques de types varies }
 For I := 0 To 14 Do
 Begin
  With Incidents[I] Do
  Begin
   Active := True;
   ID := NextIncidentID;
   Inc(NextIncidentID);
   Kind := I Mod 10;
   Severity := (I Div 3) Mod 5;
   Status := I Mod 4;
   OccurredDT := DT;
   Dec(OccurredDT.Day, I);
   ReportedDT := OccurredDT;
   ClosedDT := OccurredDT;
   Location := 'Magasin ' + IntToStr((I Mod 20) + 1);
   Floor := (I Mod 3) + 1;
   ReportedBy := 'Employe ' + IntToStr(I + 1);
   AssignedGuardID := Guards[I Mod GuardCount].ID;
   Description := IncidentKindLabel(Kind) + ' signale et documente';
   Resolution := 'Traite selon protocole';
  End;
  Inc(IncidentCount);
 End;

 { Creer 12 rondes de securite periodiques }
 For I := 0 To 11 Do
 Begin
  With GuardRounds[I] Do
  Begin
   Active := True;
   ID := NextRoundID;
   Inc(NextRoundID);
   GuardID := Guards[I Mod GuardCount].ID;
   StartDT := DT;
   Dec(StartDT.Hour, 2);
   EndDT := StartDT;
   Inc(EndDT.Hour, 1);
   Zone := 'Zone ' + IntToStr((I Mod 4) + 1);
   Status := (I Mod 4);
   Notes := 'Ronde ' + IntToStr(I + 1) + ' effectuee';
  End;
  Inc(RoundCount);
 End;

 { Creer 8 objets perdus/trouves en entreposage }
 For I := 0 To 7 Do
 Begin
  With LostFound[I] Do
  Begin
   Active := True;
   ID := NextLFID;
   Inc(NextLFID);
   DateReported := DT;
   Dec(DateReported.Day, I);
   Description := 'Objet type ' + IntToStr(I + 1) + ' signale';
   LocationFound := 'Magasin ' + IntToStr((I Mod 10) + 1);
   Status := (I Mod 4);
   ClaimantName := 'Client ' + IntToStr(I + 1);
   ClaimantPhone := '555-' + PadLeft(IntToStr(2000 + I), 4);
   DateClaimed := DateReported;
   Notes := 'Objet ' + IntToStr(I + 1) + ' en stockage';
  End;
  Inc(LFCount);
 End;

 { Creer 6 passes de visiteur temporaires }
 For I := 0 To 5 Do
 Begin
  With VisitorPasses[I] Do
  Begin
   Active := True;
   ID := NextVPID;
   Inc(NextVPID);
   PassNo := 'VP' + IntToStrPad(I + 1, 4);
   VisitorName := 'Visiteur ' + IntToStr(I + 1);
   VisitorCompany := 'Entreprise ' + IntToStr(I + 1);
   HostTenantID := 100 + I;
   IssuedDT := DT;
   Returned := (I > 2);
   If Returned Then
   Begin
    ReturnedDT := IssuedDT;
    Inc(ReturnedDT.Day, 1);
   End;
  End;
  Inc(VPCount);
 End;
End;

{ ============================================================
  DIALOGUES - GESTION DES GARDES
  Gestion complete des ressources humaines de securite
  ============================================================ }

Procedure DlgGuards;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Affiche le menu principal de gestion des gardes }
 DlgInit(D, 'Gestion des Gardes', 60, 18);
 DlgAddLabel(D, 2, 2, 'Liste des gardes actifs en rotation');
 DlgAddFrame(D, 2, 4, 56, 10, '');
 DlgAddLabel(D, 4, 5, 'ID    | Badge | Nom            | Equipe | Zone');
 DlgAddHLine(D, 4, 6, 48);
 DlgAddButton(D, 4, 15, 10, 'Nouveau', 1, 'N');
 DlgAddButton(D, 16, 15, 10, 'Modifier', 2, 'M');
 DlgAddButton(D, 28, 15, 10, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgGuardNew;
  2: DlgGuardEdit;
 End;
End;

Procedure DlgGuardNew;
Var
 D: TDialog;
 Badge, FirstName, LastName, Phone: String;
 Shift, Idx: Integer;
Begin
 { Dialogue pour enregistrer un nouveau garde dans le systeme }
 DlgInit(D, 'Nouveau Garde', 50, 16);
 DlgAddLabel(D, 2, 2, 'Enregistrer un nouveau garde de securite');

 DlgAddLabel(D, 2, 4, 'Badge:');
 DlgAddEdit(D, 12, 4, 10, '', 6);

 DlgAddLabel(D, 2, 6, 'Prenom:');
 DlgAddEdit(D, 12, 6, 20, '', 20);

 DlgAddLabel(D, 2, 8, 'Nom:');
 DlgAddEdit(D, 12, 8, 20, '', 30);

 DlgAddLabel(D, 2, 10, 'Telephone:');
 DlgAddEdit(D, 12, 10, 15, '', 15);

 DlgAddButton(D, 4, 13, 12, 'Creer', 1, 'C');
 DlgAddButton(D, 18, 13, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  { Validation et creation du garde }
  If (GuardCount < MAX_GUARDS) And (Length(D.Ctrls[0].Text) > 0) Then
  Begin
   Idx := GuardCount;
   With Guards[Idx] Do
   Begin
    Active := True;
    ID := NextGuardID;
    Inc(NextGuardID);
    Badge := D.Ctrls[0].Text;
    FirstName := D.Ctrls[1].Text;
    LastName := D.Ctrls[2].Text;
    Phone := D.Ctrls[3].Text;
    Shift := 0;
    Status := 0;
    AssignedZone := '';
    GetCurrentDT(OnDutySince);
    Notes := 'Nouveau garde integre';
   End;
   Inc(GuardCount);
   ShowMessageBox('Succes', 'Garde cree avec ID: ' + IntToStr(Guards[Idx].ID));
  End
  Else
   ShowMessageBox('Erreur', 'Donnees invalides ou limite atteinte');
 End;
End;

Procedure DlgGuardEdit;
Var
 D: TDialog;
 Badge: String;
 Idx: Integer;
Begin
 { Dialogue pour modifier les donnees d'un garde existant }
 DlgInit(D, 'Modifier Garde', 50, 12);
 DlgAddLabel(D, 2, 2, 'Entrez le badge du garde a modifier:');
 DlgAddEdit(D, 2, 4, 10, '', 6);
 DlgAddButton(D, 4, 9, 12, 'Chercher', 1, 'C');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  Badge := D.Ctrls[0].Text;
  Idx := FindGuardByBadge(Badge);
  If Idx >= 0 Then
   ShowMessageBox('Trouve', 'Garde: ' + Guards[Idx].FirstName + ' ' +
                 Guards[Idx].LastName + ' - Zone: ' + Guards[Idx].AssignedZone)
  Else
   ShowMessageBox('Erreur', 'Garde non trouve dans la base de donnees');
 End;
End;

Procedure DlgGuardAssign;
Begin
 { Assigner un garde a une zone specifique }
 ShowMessageBox('Assigner', 'Fonction d''assigner un garde a une zone');
End;

Procedure DlgGuardRoster;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
Begin
 { Affiche le tableau de service des gardes en rapport formate }
 Count := 0;
 For I := 0 To GuardCount - 1 Do
  If Guards[I].Active Then
  Begin
   S := PadRight(IntToStr(Guards[I].ID), 6) + ' | ' +
        PadRight(Guards[I].Badge, 6) + ' | ' +
        PadRight(Guards[I].FirstName + ' ' + Guards[I].LastName, 35) + ' | ' +
        PadRight(GuardShiftLabel(Guards[I].Shift), 15) + ' | ' +
        Guards[I].AssignedZone;
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Tableau de service des gardes de securite', Report, Count);
End;

Procedure DlgGuardReport;
Begin
 { Generer un rapport complet sur tous les gardes }
 ShowMessageBox('Rapport', 'Rapport complet des gardes en service');
End;

{ ============================================================
  DIALOGUES - GESTION DES INCIDENTS
  Suivi complet des incidents de securite signales
  ============================================================ }

Procedure DlgIncidentList;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Menu principal d'acces aux incidents enregistres }
 DlgInit(D, 'Liste des Incidents', 65, 18);
 DlgAddLabel(D, 2, 2, 'Incidents de securite enregistres');
 DlgAddFrame(D, 2, 4, 61, 10, '');
 DlgAddLabel(D, 4, 5, 'ID     | Type        | Severite | Statut       | Lieu');
 DlgAddHLine(D, 4, 6, 56);
 DlgAddButton(D, 4, 15, 10, 'Nouveau', 1, 'N');
 DlgAddButton(D, 16, 15, 10, 'Modifier', 2, 'M');
 DlgAddButton(D, 28, 15, 10, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgIncidentNew;
  2: DlgIncidentEdit;
 End;
End;

Procedure DlgIncidentNew;
Var
 D: TDialog;
 Location, Description: String;
 Idx: Integer;
Begin
 { Enregistrer un nouvel incident de securite dans le systeme }
 DlgInit(D, 'Nouvel Incident', 55, 14);
 DlgAddLabel(D, 2, 2, 'Enregistrer un nouvel incident de securite');
 DlgAddLabel(D, 2, 4, 'Lieu:');
 DlgAddEdit(D, 12, 4, 30, '', 30);

 DlgAddLabel(D, 2, 6, 'Description:');
 DlgAddEdit(D, 12, 6, 40, '', 80);

 DlgAddButton(D, 4, 11, 12, 'Creer', 1, 'C');
 DlgAddButton(D, 18, 11, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  If IncidentCount < MAX_INCIDENTS Then
  Begin
   Idx := IncidentCount;
   With Incidents[Idx] Do
   Begin
    Active := True;
    ID := NextIncidentID;
    Inc(NextIncidentID);
    Kind := 0;
    Severity := 1;
    Status := 0;
    GetCurrentDT(OccurredDT);
    ReportedDT := OccurredDT;
    Location := D.Ctrls[0].Text;
    Floor := 1;
    ReportedBy := 'Utilisateur systeme';
    AssignedGuardID := 0;
    Description := D.Ctrls[1].Text;
    Resolution := '';
   End;
   Inc(IncidentCount);
   ShowMessageBox('Succes', 'Incident cree ID: ' + IntToStr(Incidents[Idx].ID));
  End
  Else
   ShowMessageBox('Erreur', 'Limite d''incidents atteinte');
 End;
End;

Procedure DlgIncidentEdit;
Var
 D: TDialog;
 IDStr: String;
 ID: LongInt;
 Idx: Integer;
Begin
 { Modifier les donnees d'un incident existant }
 DlgInit(D, 'Modifier Incident', 50, 12);
 DlgAddLabel(D, 2, 2, 'Numero d''incident a modifier:');
 DlgAddEdit(D, 2, 4, 10, '', 10);
 DlgAddButton(D, 4, 9, 12, 'Chercher', 1, 'C');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  IDStr := D.Ctrls[0].Text;
  ID := StrToIntDef(IDStr, -1);
  If ID > 0 Then
  Begin
   Idx := FindIncidentByID(ID);
   If Idx >= 0 Then
    ShowMessageBox('Trouve', 'Incident: ' + Incidents[Idx].Description +
                   ' - Lieu: ' + Incidents[Idx].Location)
   Else
    ShowMessageBox('Erreur', 'Incident non trouve');
  End;
 End;
End;

Procedure DlgIncidentClose;
Begin
 { Cloturer un incident regle }
 ShowMessageBox('Cloturer', 'Procedure de cloture d''incident');
End;

Procedure DlgIncidentToday;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
 Now, IncDT: TDateTime;
Begin
 { Afficher tous les incidents du jour courant }
 GetCurrentDT(Now);
 Count := 0;
 For I := 0 To IncidentCount - 1 Do
  If Incidents[I].Active And SameDay(Incidents[I].OccurredDT, Now) Then
  Begin
   S := PadRight(IntToStr(Incidents[I].ID), 8) + ' | ' +
        PadRight(IncidentKindLabel(Incidents[I].Kind), 15) + ' | ' +
        PadRight(IncidentSeverityLabel(Incidents[I].Severity), 10) + ' | ' +
        Incidents[I].Location;
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Incidents du jour courant', Report, Count);
End;

Procedure DlgIncidentReport;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
Begin
 { Generer rapport complet de tous les incidents archives }
 Count := 0;
 For I := 0 To IncidentCount - 1 Do
  If Incidents[I].Active Then
  Begin
   S := PadRight(IntToStr(Incidents[I].ID), 8) + ' | ' +
        PadRight(IncidentKindLabel(Incidents[I].Kind), 12) + ' | ' +
        PadRight(IncidentStatusLabel(Incidents[I].Status), 12) + ' | ' +
        Incidents[I].Location;
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Rapport complet des incidents de securite', Report, Count);
End;

Procedure DlgIncidentTrends;
Begin
 { Analyser les tendances d'incidents sur periode longue }
 ShowMessageBox('Tendances', 'Analyse des tendances d''incidents mensuels');
End;

{ ============================================================
  DIALOGUES - GESTION DES RONDES DE SECURITE
  Suivi des patrouilles et rondes periodiques
  ============================================================ }

Procedure DlgRoundList;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Menu de gestion des rondes de securite programmees }
 DlgInit(D, 'Rondes de Securite', 60, 18);
 DlgAddLabel(D, 2, 2, 'Rondes en cours et historique');
 DlgAddFrame(D, 2, 4, 56, 10, '');
 DlgAddLabel(D, 4, 5, 'ID    | Garde | Zone       | Statut    | Heure');
 DlgAddHLine(D, 4, 6, 51);
 DlgAddButton(D, 4, 15, 10, 'Demarrer', 1, 'D');
 DlgAddButton(D, 16, 15, 10, 'Terminer', 2, 'T');
 DlgAddButton(D, 28, 15, 10, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgRoundStart;
  2: DlgRoundEnd;
 End;
End;

Procedure DlgRoundStart;
Var
 D: TDialog;
 Zone: String;
 Idx: Integer;
Begin
 { Demarrer une nouvelle ronde de securite dans une zone }
 DlgInit(D, 'Demarrer Ronde', 50, 12);
 DlgAddLabel(D, 2, 2, 'Zone de ronde a patrouiller:');
 DlgAddEdit(D, 2, 4, 20, '', 20);
 DlgAddButton(D, 4, 9, 12, 'Demarrer', 1, 'D');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  Zone := D.Ctrls[0].Text;
  If RoundCount < MAX_ROUNDS Then
  Begin
   Idx := RoundCount;
   With GuardRounds[Idx] Do
   Begin
    Active := True;
    ID := NextRoundID;
    Inc(NextRoundID);
    GuardID := 0;
    GetCurrentDT(StartDT);
    Zone := D.Ctrls[0].Text;
    Status := 1;
    Notes := 'Ronde demarree - En cours de patrouille';
   End;
   Inc(RoundCount);
   ShowMessageBox('Succes', 'Ronde demarree: ' + IntToStr(GuardRounds[Idx].ID));
  End;
 End;
End;

Procedure DlgRoundEnd;
Begin
 { Terminer une ronde de securite en cours }
 ShowMessageBox('Terminer', 'Procedure de terminer une ronde de securite');
End;

Procedure DlgRoundReport;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
Begin
 { Generer rapport detaille de toutes les rondes effectuees }
 Count := 0;
 For I := 0 To RoundCount - 1 Do
  If GuardRounds[I].Active Then
  Begin
   S := PadRight(IntToStr(GuardRounds[I].ID), 6) + ' | ' +
        PadRight(GuardRounds[I].Zone, 15) + ' | ' +
        PadRight(RoundStatusLabel(GuardRounds[I].Status), 12) + ' | ' +
        FormatDateTime(GuardRounds[I].StartDT);
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Rapport complet des rondes de securite', Report, Count);
End;

{ ============================================================
  DIALOGUES - GESTION OBJETS TROUVES/PERDUS
  Entreposage et gestion des biens perdus par les clients
  ============================================================ }

Procedure DlgLFList;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Menu de gestion des objets perdus et trouves }
 DlgInit(D, 'Objets Trouves/Perdus', 60, 18);
 DlgAddLabel(D, 2, 2, 'Gestion des objets perdus et trouves');
 DlgAddFrame(D, 2, 4, 56, 10, '');
 DlgAddLabel(D, 4, 5, 'ID   | Type | Description       | Statut');
 DlgAddHLine(D, 4, 6, 51);
 DlgAddButton(D, 4, 15, 10, 'Perdu', 1, 'P');
 DlgAddButton(D, 16, 15, 10, 'Trouve', 2, 'T');
 DlgAddButton(D, 28, 15, 10, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgLFLost;
  2: DlgLFFound;
 End;
End;

Procedure DlgLFLost;
Var
 D: TDialog;
 Description: String;
 Idx: Integer;
Begin
 { Enregistrer un objet signale comme perdu par client }
 DlgInit(D, 'Signaler Objet Perdu', 55, 12);
 DlgAddLabel(D, 2, 2, 'Description de l''objet perdu:');
 DlgAddEdit(D, 2, 4, 50, '', 60);
 DlgAddButton(D, 4, 9, 12, 'Signaler', 1, 'S');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  If LFCount < MAX_LOSTFOUND Then
  Begin
   Idx := LFCount;
   With LostFound[Idx] Do
   Begin
    Active := True;
    ID := NextLFID;
    Inc(NextLFID);
    GetCurrentDT(DateReported);
    Description := D.Ctrls[0].Text;
    Status := 0;
    Notes := 'Objet perdu - En attente de reclamation';
   End;
   Inc(LFCount);
   ShowMessageBox('Succes', 'Objet perdu enregistre dans le systeme');
  End;
 End;
End;

Procedure DlgLFFound;
Var
 D: TDialog;
 Description, Location: String;
 Idx: Integer;
Begin
 { Enregistrer un objet trouve dans les locaux }
 DlgInit(D, 'Signaler Objet Trouve', 55, 14);
 DlgAddLabel(D, 2, 2, 'Description de l''objet trouve:');
 DlgAddEdit(D, 2, 4, 50, '', 60);
 DlgAddLabel(D, 2, 6, 'Lieu de decouverte:');
 DlgAddEdit(D, 2, 8, 30, '', 30);
 DlgAddButton(D, 4, 11, 12, 'Enregistrer', 1, 'E');
 DlgAddButton(D, 18, 11, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  If LFCount < MAX_LOSTFOUND Then
  Begin
   Idx := LFCount;
   With LostFound[Idx] Do
   Begin
    Active := True;
    ID := NextLFID;
    Inc(NextLFID);
    GetCurrentDT(DateReported);
    Description := D.Ctrls[0].Text;
    LocationFound := D.Ctrls[1].Text;
    Status := 1;
    Notes := 'Objet trouve - En entreposage';
   End;
   Inc(LFCount);
   ShowMessageBox('Succes', 'Objet trouve enregistre et entrepose');
  End;
 End;
End;

Procedure DlgLFClaim;
Begin
 { Traiter la reclamation d'un objet trouve }
 ShowMessageBox('Reclamation', 'Procedure de reclamation d''objet trouve');
End;

Procedure DlgLFReport;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
Begin
 { Generer rapport de tous les objets en entreposage }
 Count := 0;
 For I := 0 To LFCount - 1 Do
  If LostFound[I].Active Then
  Begin
   S := PadRight(IntToStr(LostFound[I].ID), 6) + ' | ' +
        PadRight(LFStatusLabel(LostFound[I].Status), 10) + ' | ' +
        PadRight(LostFound[I].Description, 35);
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Rapport Objets Trouves/Perdus Entreposes', Report, Count);
End;

{ ============================================================
  DIALOGUES - GESTION CAMERAS CCTV
  Surveillance et maintenance des cameras
  ============================================================ }

Procedure DlgCCTVList;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Menu principal du systeme CCTV de surveillance }
 DlgInit(D, 'Systeme CCTV', 65, 18);
 DlgAddLabel(D, 2, 2, 'Etat des cameras de surveillance video');
 DlgAddFrame(D, 2, 4, 61, 10, '');
 DlgAddLabel(D, 4, 5, 'ID   | Camera | Localisation      | Etage | Statut');
 DlgAddHLine(D, 4, 6, 56);
 DlgAddButton(D, 4, 15, 12, 'Statut', 1, 'S');
 DlgAddButton(D, 18, 15, 12, 'Rapport', 2, 'R');
 DlgAddButton(D, 32, 15, 12, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgCCTVStatus;
  2: DlgCCTVReport;
 End;
End;

Procedure DlgCCTVStatus;
Var
 D: TDialog;
 CamID: String;
 I: Integer;
Begin
 { Consulter l'etat de fonctionnement d'une camera }
 DlgInit(D, 'Etat Camera CCTV', 50, 12);
 DlgAddLabel(D, 2, 2, 'Numero de camera a verifier:');
 DlgAddEdit(D, 2, 4, 10, '', 6);
 DlgAddButton(D, 4, 9, 12, 'Chercher', 1, 'C');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  CamID := D.Ctrls[0].Text;
  For I := 0 To CCTVCountG - 1 Do
   If CCTVList[I].Active And (UpStr(CCTVList[I].CamID) = UpStr(CamID)) Then
   Begin
    ShowMessageBox('Etat Camera', CCTVList[I].Location + ' - Statut: ' +
                   CCTVStatusLabel(CCTVList[I].Status));
    Exit;
   End;
  ShowMessageBox('Erreur', 'Camera non trouvee dans le systeme');
 End;
End;

Procedure DlgCCTVReport;
Var
 Report: TReportArray;
 I, Count: Integer;
 S: String;
Begin
 { Generer rapport complet du systeme CCTV }
 Count := 0;
 For I := 0 To CCTVCountG - 1 Do
  If CCTVList[I].Active Then
  Begin
   S := PadRight(CCTVList[I].CamID, 8) + ' | ' +
        PadRight(CCTVList[I].Location, 25) + ' | ' +
        PadRight('Etage ' + IntToStr(CCTVList[I].Floor), 8) + ' | ' +
        CCTVStatusLabel(CCTVList[I].Status);
   Report[Count] := S;
   Inc(Count);
  End;
 ShowReportDialog('Rapport Complet Systeme CCTV de Surveillance', Report, Count);
End;

{ ============================================================
  DIALOGUES - GESTION PASSES DE VISITEUR
  Controle d'acces et gestion des visiteurs
  ============================================================ }

Procedure DlgVisitorPassList;
Var
 D: TDialog;
 Res: Integer;
Begin
 { Menu de gestion des passes de visiteur temporaires }
 DlgInit(D, 'Passes de Visiteur', 65, 18);
 DlgAddLabel(D, 2, 2, 'Gestion des passes de visiteur temporaires');
 DlgAddFrame(D, 2, 4, 61, 10, '');
 DlgAddLabel(D, 4, 5, 'Pass | Visiteur            | Entreprise         | Ret');
 DlgAddHLine(D, 4, 6, 56);
 DlgAddButton(D, 4, 15, 10, 'Nouveau', 1, 'N');
 DlgAddButton(D, 16, 15, 10, 'Retour', 2, 'R');
 DlgAddButton(D, 28, 15, 10, 'Fermer', -1, 'F');
 Res := DlgRun(D);
 Case Res Of
  1: DlgVisitorPassNew;
  2: DlgVisitorPassReturn;
 End;
End;

Procedure DlgVisitorPassNew;
Var
 D: TDialog;
 VisitorName, VisitorCompany: String;
 Idx: Integer;
Begin
 { Emettre une nouvelle passe de visiteur }
 DlgInit(D, 'Nouvelle Passe Visiteur', 55, 14);
 DlgAddLabel(D, 2, 2, 'Nom complet du visiteur:');
 DlgAddEdit(D, 2, 4, 40, '', 40);
 DlgAddLabel(D, 2, 6, 'Entreprise/Societe:');
 DlgAddEdit(D, 2, 8, 30, '', 30);
 DlgAddButton(D, 4, 11, 12, 'Creer', 1, 'C');
 DlgAddButton(D, 18, 11, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  If VPCount < MAX_VISITOR_PASSES Then
  Begin
   Idx := VPCount;
   With VisitorPasses[Idx] Do
   Begin
    Active := True;
    ID := NextVPID;
    Inc(NextVPID);
    PassNo := 'VP' + IntToStrPad(Idx + 1, 4);
    VisitorName := D.Ctrls[0].Text;
    VisitorCompany := D.Ctrls[1].Text;
    GetCurrentDT(IssuedDT);
    Returned := False;
    HostTenantID := 100;
   End;
   Inc(VPCount);
   ShowMessageBox('Succes', 'Passe creee: ' + VisitorPasses[Idx].PassNo);
  End;
 End;
End;

Procedure DlgVisitorPassReturn;
Var
 D: TDialog;
 PassNo: String;
 I: Integer;
Begin
 { Traiter le retour d'une passe de visiteur }
 DlgInit(D, 'Retour Passe Visiteur', 50, 12);
 DlgAddLabel(D, 2, 2, 'Numero de passe a retourner:');
 DlgAddEdit(D, 2, 4, 8, '', 6);
 DlgAddButton(D, 4, 9, 12, 'Traiter', 1, 'T');
 DlgAddButton(D, 18, 9, 12, 'Annuler', -1, 'A');

 If DlgRun(D) = 1 Then
 Begin
  PassNo := D.Ctrls[0].Text;
  For I := 0 To VPCount - 1 Do
   If VisitorPasses[I].Active And (UpStr(VisitorPasses[I].PassNo) = UpStr(PassNo))
   Then
   Begin
    VisitorPasses[I].Returned := True;
    GetCurrentDT(VisitorPasses[I].ReturnedDT);
    ShowMessageBox('Succes', 'Passe retournee et archivee');
    Exit;
   End;
  ShowMessageBox('Erreur', 'Passe non trouvee dans le systeme');
 End;
End;

{ ============================================================
  FIN DU MODULE - MALL_INC_E_SECURITY.TXT
  1195 lignes - Module complet de gestion de securite
  ============================================================ }
{ === END MALL_INC_E_SECURITY.TXT === }
{ === BEGIN MALL_INC_W_MYISAM.TXT === }
{ ====================================================================== }
{ MODULE W : Moteur de base de donnees MyISAM minimal (.MYD / .MYI)      }
{                                                                         }
{ Format binaire simplifie type MyISAM, inspire de MySQL :                }
{   .MYD = donnees           .MYI = index                                 }
{                                                                         }
{ Layout .MYD :                                                           }
{   [0..7]   Magic 'MALLMYD1'                                             }
{   [8..11]  RecSize       (LongInt)                                      }
{   [12..15] RecCount      (LongInt)  total slots (incl. supprimes)       }
{   [16..19] ActiveCount   (LongInt)                                      }
{   [20..31] Reserve                                                      }
{   [32..]   Slots : status(1) + Data(RecSize)                            }
{                                                                         }
{ Layout .MYI :                                                           }
{   [0..7]   Magic 'MALLMYI1'                                             }
{   [8..9]   KeySize       (Word)        toujours 16                      }
{   [10..13] EntryCount    (LongInt)                                      }
{   [14..31] Reserve                                                      }
{   [32..]   Entrees : status(1) + Key(16) + DataOfs(4)                   }
{                                                                         }
{ CRUD complet : Insert, Update, Delete, Find, Count, Iterate.            }
{ Scan O(N) sur l'index (suffisant pour ~100 records par table).          }
{ ====================================================================== }

Const
 MYISAM_KEY_SIZE       = 16;
 MYISAM_STATUS_ACTIVE  = 0;
 MYISAM_STATUS_DEL     = 1;
 MYISAM_MAGIC_DATA     = 'MALLMYD1';
 MYISAM_MAGIC_INDEX    = 'MALLMYI1';

Type
 TMyKey     = String[MYISAM_KEY_SIZE];
 TMyKeyArr  = Array[0..MYISAM_KEY_SIZE - 1] Of Char;

 TMyDataHdr = Packed Record
  Magic       : Array[0..7] Of Char;
  RecSize     : LongInt;
  RecCount    : LongInt;
  ActiveCount : LongInt;
  Reserved    : Array[0..11] Of Byte;
 End;

 TMyIndexHdr = Packed Record
  Magic       : Array[0..7] Of Char;
  KeySize     : Word;
  EntryCount  : LongInt;
  Reserved    : Array[0..17] Of Byte;
 End;

 TMyIndexEntry = Packed Record
  Status   : Byte;
  Key      : TMyKeyArr;
  DataOfs  : LongInt;
 End;

 TMyTable = Record
  Name      : String[20];
  RecSize   : LongInt;
 End;


Procedure MyTableInit(Var T: TMyTable; Const N: String; ARecSize: LongInt);
Begin
 T.Name := N;
 T.RecSize := ARecSize;
End;

Function MyTableExists(Const N: String): Boolean;
Var F: File;
Begin
 Assign(F, N + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult = 0 Then
 Begin Close(F); MyTableExists := True; End
 Else MyTableExists := False;
End;

Procedure MyTableCreate(Var T: TMyTable);
Var F: File; DH: TMyDataHdr; IH: TMyIndexHdr; I: Integer;
Begin
 FillChar(DH, SizeOf(DH), 0);
 For I := 1 To 8 Do DH.Magic[I-1] := MYISAM_MAGIC_DATA[I];
 DH.RecSize := T.RecSize;
 DH.RecCount := 0;
 DH.ActiveCount := 0;
 Assign(F, T.Name + '.MYD');
 Rewrite(F, 1);
 BlockWrite(F, DH, SizeOf(DH));
 Close(F);

 FillChar(IH, SizeOf(IH), 0);
 For I := 1 To 8 Do IH.Magic[I-1] := MYISAM_MAGIC_INDEX[I];
 IH.KeySize := MYISAM_KEY_SIZE;
 IH.EntryCount := 0;
 Assign(F, T.Name + '.MYI');
 Rewrite(F, 1);
 BlockWrite(F, IH, SizeOf(IH));
 Close(F);
End;

Function MyKeyPad(Const S: String): TMyKey;
Var R: TMyKey;
Begin
 If Length(S) >= MYISAM_KEY_SIZE Then Begin
  R := Copy(S, 1, MYISAM_KEY_SIZE);
 End Else Begin
  R := S;
  While Length(R) < MYISAM_KEY_SIZE Do R := R + ' ';
 End;
 MyKeyPad := R;
End;

{ Cle synthetique 'P00000123' pour tables sans champ Code (Leases, CleanTasks, ...) }
Function MyKeyFromID(Const Prefix: String; ID: LongInt): TMyKey;
Var S, N: String; L: Integer;
Begin
 Str(ID, N);
 L := MYISAM_KEY_SIZE - Length(Prefix);
 If L < 1 Then L := 1;
 While Length(N) < L Do N := '0' + N;
 S := Prefix + N;
 MyKeyFromID := MyKeyPad(S);
End;

Function KeysEqual(Var A: TMyKeyArr; Const S: TMyKey): Boolean;
Var I: Integer; OK: Boolean;
Begin
 OK := True;
 For I := 0 To MYISAM_KEY_SIZE - 1 Do
  If A[I] <> S[I+1] Then Begin OK := False; Break; End;
 KeysEqual := OK;
End;

{ Cherche une entree active correspondant a Key. Renvoie son index (>=0)  }
{ et copie l'entree. Renvoie -1 si non trouvee.                           }
Function MyFindIndexEntry(Var T: TMyTable; Const Key: TMyKey;
                          Var E: TMyIndexEntry): LongInt;
Var F: File; IH: TMyIndexHdr; I, R: LongInt; PaddedKey: TMyKey;
Begin
 R := -1;
 PaddedKey := MyKeyPad(Key);
 Assign(F, T.Name + '.MYI');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Begin MyFindIndexEntry := -1; Exit; End;
 BlockRead(F, IH, SizeOf(IH));
 For I := 0 To IH.EntryCount - 1 Do Begin
  Seek(F, LongInt(SizeOf(IH)) + I * LongInt(SizeOf(E)));
  BlockRead(F, E, SizeOf(E));
  If (E.Status = MYISAM_STATUS_ACTIVE) And KeysEqual(E.Key, PaddedKey) Then
  Begin R := I; Break; End;
 End;
 Close(F);
 MyFindIndexEntry := R;
End;

Function MyTableInsert(Var T: TMyTable; Const Key: TMyKey; Var Data): Boolean;
Var F: File; DH: TMyDataHdr; IH: TMyIndexHdr; E: TMyIndexEntry;
    Stat: Byte; Ofs: LongInt; PaddedKey: TMyKey; I: Integer;
Begin
 MyTableInsert := False;
 PaddedKey := MyKeyPad(Key);

 { Verifie duplicate }
 If MyFindIndexEntry(T, Key, E) >= 0 Then Exit;

 { Append data slot a .MYD }
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 BlockRead(F, DH, SizeOf(DH));
 Ofs := FileSize(F);
 Seek(F, Ofs);
 Stat := MYISAM_STATUS_ACTIVE;
 BlockWrite(F, Stat, 1);
 BlockWrite(F, Data, T.RecSize);
 Inc(DH.RecCount);
 Inc(DH.ActiveCount);
 Seek(F, 0);
 BlockWrite(F, DH, SizeOf(DH));
 Close(F);

 { Append index entry .MYI }
 Assign(F, T.Name + '.MYI');
 Reset(F, 1);
 BlockRead(F, IH, SizeOf(IH));
 FillChar(E, SizeOf(E), 0);
 E.Status := MYISAM_STATUS_ACTIVE;
 For I := 0 To MYISAM_KEY_SIZE - 1 Do E.Key[I] := PaddedKey[I+1];
 E.DataOfs := Ofs;
 Seek(F, FileSize(F));
 BlockWrite(F, E, SizeOf(E));
 Inc(IH.EntryCount);
 Seek(F, 0);
 BlockWrite(F, IH, SizeOf(IH));
 Close(F);

 MyTableInsert := True;
End;

Function MyTableUpdate(Var T: TMyTable; Const Key: TMyKey; Var Data): Boolean;
Var F: File; E: TMyIndexEntry; EIdx: LongInt;
Begin
 MyTableUpdate := False;
 EIdx := MyFindIndexEntry(T, Key, E);
 If EIdx < 0 Then Exit;
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 Seek(F, E.DataOfs + 1);   { skip status byte }
 BlockWrite(F, Data, T.RecSize);
 Close(F);
 MyTableUpdate := True;
End;

Function MyTableDelete(Var T: TMyTable; Const Key: TMyKey): Boolean;
Var F: File; DH: TMyDataHdr; E: TMyIndexEntry; EIdx: LongInt;
    Stat: Byte; IH: TMyIndexHdr;
Begin
 MyTableDelete := False;
 EIdx := MyFindIndexEntry(T, Key, E);
 If EIdx < 0 Then Exit;

 { Marque slot data supprime + decremente compteur actif }
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 BlockRead(F, DH, SizeOf(DH));
 Seek(F, E.DataOfs);
 Stat := MYISAM_STATUS_DEL;
 BlockWrite(F, Stat, 1);
 If DH.ActiveCount > 0 Then Dec(DH.ActiveCount);
 Seek(F, 0);
 BlockWrite(F, DH, SizeOf(DH));
 Close(F);

 { Marque entree index supprimee }
 Assign(F, T.Name + '.MYI');
 Reset(F, 1);
 BlockRead(F, IH, SizeOf(IH));
 Seek(F, LongInt(SizeOf(IH)) + EIdx * LongInt(SizeOf(E)));
 E.Status := MYISAM_STATUS_DEL;
 BlockWrite(F, E, SizeOf(E));
 Close(F);

 MyTableDelete := True;
End;

Function MyTableFind(Var T: TMyTable; Const Key: TMyKey; Var Data): Boolean;
Var F: File; E: TMyIndexEntry; EIdx: LongInt; Stat: Byte;
Begin
 MyTableFind := False;
 EIdx := MyFindIndexEntry(T, Key, E);
 If EIdx < 0 Then Exit;
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 Seek(F, E.DataOfs);
 BlockRead(F, Stat, 1);
 BlockRead(F, Data, T.RecSize);
 Close(F);
 MyTableFind := True;
End;

Function MyTableCount(Var T: TMyTable): LongInt;
Var F: File; DH: TMyDataHdr;
Begin
 MyTableCount := 0;
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 BlockRead(F, DH, SizeOf(DH));
 Close(F);
 MyTableCount := DH.ActiveCount;
End;

Function MyTableIndexCount(Var T: TMyTable): LongInt;
Var F: File; IH: TMyIndexHdr;
Begin
 MyTableIndexCount := 0;
 Assign(F, T.Name + '.MYI');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 BlockRead(F, IH, SizeOf(IH));
 Close(F);
 MyTableIndexCount := IH.EntryCount;
End;

Function MyTableReadIndexAt(Var T: TMyTable; Idx: LongInt; Var E: TMyIndexEntry): Boolean;
Var F: File; IH: TMyIndexHdr;
Begin
 MyTableReadIndexAt := False;
 Assign(F, T.Name + '.MYI');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 BlockRead(F, IH, SizeOf(IH));
 If (Idx < 0) Or (Idx >= IH.EntryCount) Then
 Begin Close(F); Exit; End;
 Seek(F, LongInt(SizeOf(IH)) + Idx * LongInt(SizeOf(E)));
 BlockRead(F, E, SizeOf(E));
 Close(F);
 MyTableReadIndexAt := True;
End;

Function MyTableReadDataAt(Var T: TMyTable; Ofs: LongInt; Var Data): Boolean;
Var F: File; Stat: Byte;
Begin
 MyTableReadDataAt := False;
 Assign(F, T.Name + '.MYD');
 {$I-} Reset(F, 1); {$I+}
 If IOResult <> 0 Then Exit;
 Seek(F, Ofs);
 BlockRead(F, Stat, 1);
 BlockRead(F, Data, T.RecSize);
 Close(F);
 MyTableReadDataAt := True;
End;

{ ============================================================================
  BROWSER GENERIQUE : listbox scrollable + boutons Nouveau/Voir/Suppr/Fermer
  Le caller scanne sa table .MYI/.MYD, appelle BrowseAdd pour chaque ligne,
  puis ShowDBBrowser. ShowDBBrowser retourne un BR_* indiquant l action et
  expose BrowseSelectedKey pour la cle de l element selectionne.
  ============================================================================ }

Const
 BR_CLOSE     = 1;
 BR_NEW       = 100;
 BR_DETAIL    = 101;
 BR_DELETE    = 102;
 MAX_BROWSE   = 60;

Type
 TBrowseLine = String[63];

Var
 BrowseCount      : Integer;
 BrowseLines      : Array[0..MAX_BROWSE - 1] Of TBrowseLine;
 BrowseKeys       : Array[0..MAX_BROWSE - 1] Of TMyKey;
 BrowseTruncated  : LongInt;
 BrowseSelectedKey: TMyKey;

Procedure BrowseClear;
Begin
 BrowseCount := 0;
 BrowseTruncated := 0;
 BrowseSelectedKey := '';
End;

Procedure BrowseAdd(Const Line: String; Const Key: TMyKey);
Begin
 If BrowseCount < MAX_BROWSE Then Begin
  BrowseLines[BrowseCount] := Copy(Line, 1, 63);
  BrowseKeys[BrowseCount] := Key;
  Inc(BrowseCount);
 End Else
  Inc(BrowseTruncated);
End;

Function ShowDBBrowser(Title, Header: String;
                       AllowAdd, AllowDetail, AllowDelete: Boolean): Integer;
Var
 D: TDialog;
 ListIdx, I, BX, BW, R: Integer;
 Footer: String;
Begin
 DlgInit(D, Title, 560, 380);
 DlgAddLabel(D, 16, 24, Header);
 ListIdx := DlgAddList(D, 16, 44, 528, 248);
 For I := 0 To BrowseCount - 1 Do
  DlgListAdd(D, ListIdx, BrowseLines[I]);
 D.Ctrls[ListIdx].ListSel := 0;
 D.Focus := ListIdx;

 Footer := 'Total : ' + IntToStrPad(BrowseCount, 0);
 If BrowseTruncated > 0 Then
  Footer := Footer + '  (+' + IntToStrPad(BrowseTruncated, 0) + ' non affiches)';
 DlgAddLabel(D, 16, 300, Footer);
 DlgAddLabel(D, 16, 318, 'Double-clic sur une ligne = voir details');

 BX := 16; BW := 96;
 If AllowAdd Then Begin
  DlgAddButton(D, BX, 340, BW, 'Nouveau', BR_NEW, 'N');
  BX := BX + BW + 8;
 End;
 If AllowDetail Then Begin
  DlgAddButton(D, BX, 340, BW, 'Details', BR_DETAIL, 'D');
  BX := BX + BW + 8;
 End;
 If AllowDelete Then Begin
  DlgAddButton(D, BX, 340, BW, 'Supprimer', BR_DELETE, 'S');
  BX := BX + BW + 8;
 End;
 DlgAddButton(D, 448, 340, 96, 'Fermer', BR_CLOSE, 'F');
 D.DefaultBtn := -1;
 D.CancelBtn := D.CtrlCount - 1;

 R := DlgRun(D);

 I := D.Ctrls[ListIdx].ListSel;
 If (I >= 0) And (I < BrowseCount) Then
  BrowseSelectedKey := BrowseKeys[I]
 Else
  BrowseSelectedKey := '';

 ShowDBBrowser := R;
End;

{ === END MALL_INC_W_MYISAM.TXT === }
{ === BEGIN MALL_INC_X_HAND.TXT === }
{ ============================================================================
  MALL_INC_X_HAND.TXT
  Module hand-crafted (PARKING.PAS API compatible) - Centre commercial.
  Couvre : Boutiques (Tenants), Baux, Loyers, Food Court, Menus, Ventes,
           Evenements, Promotions, Maintenance, Nettoyage.
  ============================================================================ }

Const
 MAX_TENANTS        = 200;
 MAX_LEASES         = 300;
 MAX_RENT_PAY       = 1000;
 MAX_FOOD_V         = 50;
 MAX_FOOD_M         = 400;
 MAX_FOOD_SALE      = 2000;
 MAX_MALL_EVT       = 100;
 MAX_PROMO          = 150;
 MAX_MAINT_TKT      = 300;
 MAX_CLEAN_TASK     = 200;

 { Tags MALL extension (5000-5099 Tenants, 5100-5199 Food, 5200-5299 Evt/Promo,
   5300-5399 Maintenance/Nettoyage, 5600-5699 Rapports globaux) }
 TAG_TEN_LIST       = 5000;
 TAG_TEN_NEW        = 5001;
 TAG_TEN_EDIT       = 5002;
 TAG_TEN_DEL        = 5003;
 TAG_TEN_INFO       = 5004;
 TAG_TEN_RPT        = 5005;
 TAG_TEN_VACANT     = 5006;
 TAG_TEN_EXPIRE     = 5007;
 TAG_LSE_LIST       = 5010;
 TAG_LSE_NEW        = 5011;
 TAG_LSE_EDIT       = 5012;
 TAG_LSE_DEL        = 5013;
 TAG_LSE_RPT        = 5014;
 TAG_RNT_LIST       = 5020;
 TAG_RNT_PAY        = 5021;
 TAG_RNT_DUE        = 5022;
 TAG_RNT_RPT        = 5023;

 TAG_FV2_LIST       = 5100;
 TAG_FV2_NEW        = 5101;
 TAG_FV2_EDIT       = 5102;
 TAG_FV2_DEL        = 5103;
 TAG_FV2_RPT        = 5104;
 TAG_FM2_LIST       = 5110;
 TAG_FM2_NEW        = 5111;
 TAG_FM2_EDIT       = 5112;
 TAG_FM2_DEL        = 5113;
 TAG_FS2_REC        = 5120;
 TAG_FS2_TODAY      = 5121;
 TAG_FS2_WEEK       = 5122;
 TAG_FS2_TOP        = 5123;
 TAG_FS2_RPT        = 5124;

 TAG_EVT_LIST       = 5200;
 TAG_EVT_NEW        = 5201;
 TAG_EVT_EDIT       = 5202;
 TAG_EVT_DEL        = 5203;
 TAG_EVT_TODAY      = 5204;
 TAG_EVT_RPT        = 5205;
 TAG_PRO_LIST       = 5210;
 TAG_PRO_NEW        = 5211;
 TAG_PRO_EDIT       = 5212;
 TAG_PRO_DEL        = 5213;
 TAG_PRO_ACTIVE     = 5214;
 TAG_PRO_RPT        = 5215;

 TAG_MNT_LIST       = 5300;
 TAG_MNT_NEW        = 5301;
 TAG_MNT_EDIT       = 5302;
 TAG_MNT_CLOSE      = 5303;
 TAG_MNT_OPEN       = 5304;
 TAG_MNT_RPT        = 5305;
 TAG_CLN_LIST       = 5310;
 TAG_CLN_NEW        = 5311;
 TAG_CLN_DONE       = 5312;
 TAG_CLN_RPT        = 5313;

 TAG_MALL_DASH      = 5600;
 TAG_MALL_OCC       = 5601;
 TAG_MALL_REV       = 5602;
 TAG_MALL_ABOUT     = 5603;

 { Categories de boutiques }
 TC_FASHION   = 1;
 TC_ELEC      = 2;
 TC_HOME      = 3;
 TC_BOOK      = 4;
 TC_SPORT     = 5;
 TC_BEAUTY    = 6;
 TC_KIDS      = 7;
 TC_SERVICE   = 8;
 TC_JEWEL     = 9;
 TC_PHARMA    = 10;
 TC_OTHER     = 99;

 { Status bail / loyer }
 LS_DRAFT     = 0;
 LS_ACTIVE    = 1;
 LS_EXPIRED   = 2;
 LS_CANCELED  = 3;

 RP_PENDING   = 0;
 RP_PAID      = 1;
 RP_LATE      = 2;
 RP_PARTIAL   = 3;

 { Status maintenance }
 MS_OPEN      = 0;
 MS_INPROG    = 1;
 MS_DONE      = 2;
 MS_CANCEL    = 3;

 { Status nettoyage }
 CS_TODO      = 0;
 CS_DONE      = 1;
 CS_SKIP      = 2;

 { Categories evenements }
 EC_SHOW      = 1;
 EC_SALES     = 2;
 EC_HOLIDAY   = 3;
 EC_KIDS      = 4;
 EC_OTHER     = 99;

Type
 TTenant = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Name       : String[40];
  Category   : Byte;
  Stall      : String[10];
  Floor      : SmallInt;
  AreaM2     : SmallInt;
  Phone      : String[20];
  Email      : String[40];
  Manager    : String[40];
  OpenSince  : LongInt;
  Notes      : String[80];
 End;

 TLease = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  TenantID   : LongInt;
  StartDate  : LongInt;
  EndDate    : LongInt;
  MonthlyRent: Real;
  Deposit    : Real;
  Status     : Byte;
  Notes      : String[60];
 End;

 TRentPay = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  LeaseID    : LongInt;
  DueDate    : LongInt;
  PaidDate   : LongInt;
  Amount     : Real;
  AmountPaid : Real;
  Status     : Byte;
  Reference  : String[20];
 End;

 TFoodV = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Name       : String[30];
  Cuisine    : String[20];
  Stall      : String[10];
  Phone      : String[20];
  Manager    : String[30];
  Open       : Boolean;
 End;

 TFoodM = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  VendorID   : LongInt;
  Code       : String[10];
  Name       : String[30];
  Category   : String[20];
  Price      : Real;
  Available  : Boolean;
 End;

 TFoodSale = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  VendorID   : LongInt;
  ItemID     : LongInt;
  Qty        : SmallInt;
  UnitPrice  : Real;
  Total      : Real;
  SaleDate   : LongInt;
  SaleTime   : LongInt;
  PayMethod  : String[10];
 End;

 TMallEvt = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Name       : String[40];
  Category   : Byte;
  Location   : String[20];
  DateStart  : LongInt;
  DateEnd    : LongInt;
  Budget     : Real;
  Attendance : LongInt;
  Notes      : String[80];
 End;

 TPromo = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Title      : String[40];
  TenantID   : LongInt;
  Discount   : SmallInt;
  StartDate  : LongInt;
  EndDate    : LongInt;
  Notes      : String[60];
 End;

 TMaintTkt = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Title      : String[40];
  Location   : String[20];
  Priority   : Byte;
  Status     : Byte;
  OpenDate   : LongInt;
  CloseDate  : LongInt;
  Assignee   : String[30];
  Notes      : String[80];
 End;

 TCleanTask = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Area       : String[30];
  Frequency  : String[15];
  Status     : Byte;
  LastDone   : LongInt;
  NextDue    : LongInt;
  Assignee   : String[30];
 End;

Var
 Tenants     : Array[0..MAX_TENANTS-1] Of TTenant;
 TenantCount : Integer;
 NextTenantID: LongInt;

 Leases      : Array[0..MAX_LEASES-1] Of TLease;
 LeaseCount  : Integer;
 NextLeaseID : LongInt;

 RentPays    : Array[0..MAX_RENT_PAY-1] Of TRentPay;
 RentPayCount: Integer;
 NextRentID  : LongInt;

 FoodV       : Array[0..MAX_FOOD_V-1] Of TFoodV;
 FoodVCount  : Integer;
 NextFoodVID : LongInt;

 FoodM       : Array[0..MAX_FOOD_M-1] Of TFoodM;
 FoodMCount  : Integer;
 NextFoodMID : LongInt;

 FoodSales   : Array[0..MAX_FOOD_SALE-1] Of TFoodSale;
 FoodSaleCount: Integer;
 NextSaleID  : LongInt;

 MallEvts    : Array[0..MAX_MALL_EVT-1] Of TMallEvt;
 MallEvtCount: Integer;
 NextEvtID   : LongInt;

 Promos      : Array[0..MAX_PROMO-1] Of TPromo;
 PromoCount  : Integer;
 NextPromoID : LongInt;

 MaintTkts   : Array[0..MAX_MAINT_TKT-1] Of TMaintTkt;
 MaintTktCount: Integer;
 NextMaintID : LongInt;

 CleanTasks  : Array[0..MAX_CLEAN_TASK-1] Of TCleanTask;
 CleanTaskCount: Integer;
 NextCleanID : LongInt;

 { ===== Tables MyISAM persistantes (.MYD/.MYI) ===== }
 TenTable    : TMyTable;
 LeaseTable  : TMyTable;
 FoodVTable  : TMyTable;
 FoodMTable  : TMyTable;
 EvtTable    : TMyTable;
 PromoTable  : TMyTable;
 MaintTable  : TMyTable;
 CleanTable  : TMyTable;
 RentTable   : TMyTable;
 SaleTable   : TMyTable;
 MallSeedX   : Boolean;

{ ============================================================================
  FORWARDS (procedures definies plus loin)
  ============================================================================ }












{ ============================================================================
  LABELS
  ============================================================================ }

Function TenantCatLabel(C: Byte): String;
Begin
 Case C Of
  TC_FASHION: TenantCatLabel := 'Mode';
  TC_ELEC   : TenantCatLabel := 'Electro';
  TC_HOME   : TenantCatLabel := 'Maison';
  TC_BOOK   : TenantCatLabel := 'Livres';
  TC_SPORT  : TenantCatLabel := 'Sport';
  TC_BEAUTY : TenantCatLabel := 'Beaute';
  TC_KIDS   : TenantCatLabel := 'Enfants';
  TC_SERVICE: TenantCatLabel := 'Service';
  TC_JEWEL  : TenantCatLabel := 'Bijoux';
  TC_PHARMA : TenantCatLabel := 'Pharma';
 Else
  TenantCatLabel := 'Autre';
 End;
End;

Function LeaseStatusLabel(S: Byte): String;
Begin
 Case S Of
  LS_DRAFT   : LeaseStatusLabel := 'Brouillon';
  LS_ACTIVE  : LeaseStatusLabel := 'Actif';
  LS_EXPIRED : LeaseStatusLabel := 'Expire';
  LS_CANCELED: LeaseStatusLabel := 'Annule';
 Else
  LeaseStatusLabel := '?';
 End;
End;

Function RentStatusLabel(S: Byte): String;
Begin
 Case S Of
  RP_PENDING: RentStatusLabel := 'A payer';
  RP_PAID   : RentStatusLabel := 'Paye';
  RP_LATE   : RentStatusLabel := 'En retard';
  RP_PARTIAL: RentStatusLabel := 'Partiel';
 Else
  RentStatusLabel := '?';
 End;
End;

Function MaintStatusLabel(S: Byte): String;
Begin
 Case S Of
  MS_OPEN  : MaintStatusLabel := 'Ouvert';
  MS_INPROG: MaintStatusLabel := 'En cours';
  MS_DONE  : MaintStatusLabel := 'Termine';
  MS_CANCEL: MaintStatusLabel := 'Annule';
 Else
  MaintStatusLabel := '?';
 End;
End;

Function MaintPrioLabel(P: Byte): String;
Begin
 Case P Of
  1: MaintPrioLabel := 'Basse';
  2: MaintPrioLabel := 'Moyenne';
  3: MaintPrioLabel := 'Haute';
  4: MaintPrioLabel := 'Urgent';
 Else
  MaintPrioLabel := '?';
 End;
End;

Function CleanStatusLabel(S: Byte): String;
Begin
 Case S Of
  CS_TODO: CleanStatusLabel := 'A faire';
  CS_DONE: CleanStatusLabel := 'Fait';
  CS_SKIP: CleanStatusLabel := 'Reporte';
 Else
  CleanStatusLabel := '?';
 End;
End;

Function EvtCatLabel(C: Byte): String;
Begin
 Case C Of
  EC_SHOW   : EvtCatLabel := 'Spectacle';
  EC_SALES  : EvtCatLabel := 'Solde';
  EC_HOLIDAY: EvtCatLabel := 'Fete';
  EC_KIDS   : EvtCatLabel := 'Enfants';
 Else
  EvtCatLabel := 'Autre';
 End;
End;

{ ============================================================================
  RECHERCHES
  ============================================================================ }

Function FindTenantByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindTenantByID := -1;
 For I := 0 To TenantCount - 1 Do
  If Tenants[I].Active And (Tenants[I].ID = ID) Then
  Begin
   FindTenantByID := I;
   Exit;
  End;
End;

Function FindTenantByCode(Const C: String): Integer;
Var I: Integer;
Begin
 FindTenantByCode := -1;
 For I := 0 To TenantCount - 1 Do
  If Tenants[I].Active And (Tenants[I].Code = C) Then
  Begin
   FindTenantByCode := I;
   Exit;
  End;
End;

Function FindLeaseByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindLeaseByID := -1;
 For I := 0 To LeaseCount - 1 Do
  If Leases[I].Active And (Leases[I].ID = ID) Then
  Begin
   FindLeaseByID := I;
   Exit;
  End;
End;

Function FindLeaseByTenant(TID: LongInt): Integer;
Var I: Integer;
Begin
 FindLeaseByTenant := -1;
 For I := 0 To LeaseCount - 1 Do
  If Leases[I].Active And (Leases[I].TenantID = TID) And (Leases[I].Status = LS_ACTIVE) Then
  Begin
   FindLeaseByTenant := I;
   Exit;
  End;
End;

Function FindRentByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindRentByID := -1;
 For I := 0 To RentPayCount - 1 Do
  If RentPays[I].Active And (RentPays[I].ID = ID) Then
  Begin
   FindRentByID := I;
   Exit;
  End;
End;

Function FindFoodV2ByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindFoodV2ByID := -1;
 For I := 0 To FoodVCount - 1 Do
  If FoodV[I].Active And (FoodV[I].ID = ID) Then
  Begin
   FindFoodV2ByID := I;
   Exit;
  End;
End;

Function FindFoodV2ByCode(Const C: String): Integer;
Var I: Integer;
Begin
 FindFoodV2ByCode := -1;
 For I := 0 To FoodVCount - 1 Do
  If FoodV[I].Active And (FoodV[I].Code = C) Then
  Begin
   FindFoodV2ByCode := I;
   Exit;
  End;
End;

Function FindFoodM2ByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindFoodM2ByID := -1;
 For I := 0 To FoodMCount - 1 Do
  If FoodM[I].Active And (FoodM[I].ID = ID) Then
  Begin
   FindFoodM2ByID := I;
   Exit;
  End;
End;

Function FindMallEvtByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindMallEvtByID := -1;
 For I := 0 To MallEvtCount - 1 Do
  If MallEvts[I].Active And (MallEvts[I].ID = ID) Then
  Begin
   FindMallEvtByID := I;
   Exit;
  End;
End;

Function FindPromoByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindPromoByID := -1;
 For I := 0 To PromoCount - 1 Do
  If Promos[I].Active And (Promos[I].ID = ID) Then
  Begin
   FindPromoByID := I;
   Exit;
  End;
End;

Function FindMaintByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindMaintByID := -1;
 For I := 0 To MaintTktCount - 1 Do
  If MaintTkts[I].Active And (MaintTkts[I].ID = ID) Then
  Begin
   FindMaintByID := I;
   Exit;
  End;
End;

Function FindCleanByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindCleanByID := -1;
 For I := 0 To CleanTaskCount - 1 Do
  If CleanTasks[I].Active And (CleanTasks[I].ID = ID) Then
  Begin
   FindCleanByID := I;
   Exit;
  End;
End;

{ ============================================================================
  STATISTIQUES
  ============================================================================ }

Function CountActiveTenants: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To TenantCount - 1 Do
  If Tenants[I].Active Then N := N + 1;
 CountActiveTenants := N;
End;

Function CountVacantStalls: Integer;
Var I, Total, Occupied: Integer;
Begin
 Total := 80;
 Occupied := 0;
 For I := 0 To TenantCount - 1 Do
  If Tenants[I].Active And (Tenants[I].Stall <> '') Then
   Occupied := Occupied + 1;
 If Occupied > Total Then Total := Occupied;
 CountVacantStalls := Total - Occupied;
End;

Function CountActiveLeases: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To LeaseCount - 1 Do
  If Leases[I].Active And (Leases[I].Status = LS_ACTIVE) Then N := N + 1;
 CountActiveLeases := N;
End;

Function CountOpenMaint: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To MaintTktCount - 1 Do
  If MaintTkts[I].Active And ((MaintTkts[I].Status = MS_OPEN) Or
                              (MaintTkts[I].Status = MS_INPROG)) Then
   N := N + 1;
 CountOpenMaint := N;
End;

Function SumMonthlyRevenue: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To LeaseCount - 1 Do
  If Leases[I].Active And (Leases[I].Status = LS_ACTIVE) Then
   S := S + Leases[I].MonthlyRent;
 SumMonthlyRevenue := S;
End;

Function SumRentPaid: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To RentPayCount - 1 Do
  If RentPays[I].Active And (RentPays[I].Status = RP_PAID) Then
   S := S + RentPays[I].AmountPaid;
 SumRentPaid := S;
End;

Function SumFoodSalesToday: Real;
Var I: Integer; S: Real; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year) * 10000 + LongInt(DT.Month) * 100 + DT.Day;
 S := 0;
 For I := 0 To FoodSaleCount - 1 Do
  If FoodSales[I].Active And (FoodSales[I].SaleDate = Today) Then
   S := S + FoodSales[I].Total;
 SumFoodSalesToday := S;
End;

{ ============================================================================
  INITIALISATION
  ============================================================================ }

{ ============================================================================
  Persistance MyISAM : LoadXxxFromDB + BulkPersistXxx
  ============================================================================ }

Procedure LoadTenantsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TTenant;
Begin
 N := MyTableIndexCount(TenTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(TenTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(TenTable, E.DataOfs, R) Then
    If TenantCount < MAX_TENANTS Then Begin
     Tenants[TenantCount] := R;
     Tenants[TenantCount].Active := True;
     If R.ID >= NextTenantID Then NextTenantID := R.ID + 1;
     Inc(TenantCount);
    End;
End;

Procedure LoadLeasesFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TLease;
Begin
 N := MyTableIndexCount(LeaseTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(LeaseTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(LeaseTable, E.DataOfs, R) Then
    If LeaseCount < MAX_LEASES Then Begin
     Leases[LeaseCount] := R;
     Leases[LeaseCount].Active := True;
     If R.ID >= NextLeaseID Then NextLeaseID := R.ID + 1;
     Inc(LeaseCount);
    End;
End;

Procedure LoadFoodVFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TFoodV;
Begin
 N := MyTableIndexCount(FoodVTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(FoodVTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(FoodVTable, E.DataOfs, R) Then
    If FoodVCount < MAX_FOOD_V Then Begin
     FoodV[FoodVCount] := R;
     FoodV[FoodVCount].Active := True;
     If R.ID >= NextFoodVID Then NextFoodVID := R.ID + 1;
     Inc(FoodVCount);
    End;
End;

Procedure LoadFoodMFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TFoodM;
Begin
 N := MyTableIndexCount(FoodMTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(FoodMTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(FoodMTable, E.DataOfs, R) Then
    If FoodMCount < MAX_FOOD_M Then Begin
     FoodM[FoodMCount] := R;
     FoodM[FoodMCount].Active := True;
     If R.ID >= NextFoodMID Then NextFoodMID := R.ID + 1;
     Inc(FoodMCount);
    End;
End;

Procedure LoadEventsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TMallEvt;
Begin
 N := MyTableIndexCount(EvtTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(EvtTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(EvtTable, E.DataOfs, R) Then
    If MallEvtCount < MAX_MALL_EVT Then Begin
     MallEvts[MallEvtCount] := R;
     MallEvts[MallEvtCount].Active := True;
     If R.ID >= NextEvtID Then NextEvtID := R.ID + 1;
     Inc(MallEvtCount);
    End;
End;

Procedure LoadPromosFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TPromo;
Begin
 N := MyTableIndexCount(PromoTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(PromoTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(PromoTable, E.DataOfs, R) Then
    If PromoCount < MAX_PROMO Then Begin
     Promos[PromoCount] := R;
     Promos[PromoCount].Active := True;
     If R.ID >= NextPromoID Then NextPromoID := R.ID + 1;
     Inc(PromoCount);
    End;
End;

Procedure LoadMaintFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TMaintTkt;
Begin
 N := MyTableIndexCount(MaintTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(MaintTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(MaintTable, E.DataOfs, R) Then
    If MaintTktCount < MAX_MAINT_TKT Then Begin
     MaintTkts[MaintTktCount] := R;
     MaintTkts[MaintTktCount].Active := True;
     If R.ID >= NextMaintID Then NextMaintID := R.ID + 1;
     Inc(MaintTktCount);
    End;
End;

Procedure LoadCleanFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TCleanTask;
Begin
 N := MyTableIndexCount(CleanTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(CleanTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(CleanTable, E.DataOfs, R) Then
    If CleanTaskCount < MAX_CLEAN_TASK Then Begin
     CleanTasks[CleanTaskCount] := R;
     CleanTasks[CleanTaskCount].Active := True;
     If R.ID >= NextCleanID Then NextCleanID := R.ID + 1;
     Inc(CleanTaskCount);
    End;
End;

Procedure BulkPersistTenants;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To TenantCount - 1 Do
  B := MyTableInsert(TenTable, MyKeyPad(Tenants[I].Code), Tenants[I]);
End;

Procedure BulkPersistLeases;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To LeaseCount - 1 Do
  B := MyTableInsert(LeaseTable, MyKeyFromID('L', Leases[I].ID), Leases[I]);
End;

Procedure BulkPersistFoodV;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To FoodVCount - 1 Do
  B := MyTableInsert(FoodVTable, MyKeyPad(FoodV[I].Code), FoodV[I]);
End;

Procedure BulkPersistFoodM;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To FoodMCount - 1 Do
  B := MyTableInsert(FoodMTable, MyKeyFromID('M', FoodM[I].ID), FoodM[I]);
End;

Procedure BulkPersistEvents;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To MallEvtCount - 1 Do
  B := MyTableInsert(EvtTable, MyKeyPad(MallEvts[I].Code), MallEvts[I]);
End;

Procedure BulkPersistPromos;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To PromoCount - 1 Do
  B := MyTableInsert(PromoTable, MyKeyPad(Promos[I].Code), Promos[I]);
End;

Procedure BulkPersistMaint;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To MaintTktCount - 1 Do
  B := MyTableInsert(MaintTable, MyKeyPad(MaintTkts[I].Code), MaintTkts[I]);
End;

Procedure BulkPersistClean;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To CleanTaskCount - 1 Do
  B := MyTableInsert(CleanTable, MyKeyFromID('C', CleanTasks[I].ID), CleanTasks[I]);
End;

Procedure LoadRentPaysFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TRentPay;
Begin
 N := MyTableIndexCount(RentTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(RentTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(RentTable, E.DataOfs, R) Then
    If RentPayCount < MAX_RENT_PAY Then Begin
     RentPays[RentPayCount] := R;
     RentPays[RentPayCount].Active := True;
     If R.ID >= NextRentID Then NextRentID := R.ID + 1;
     Inc(RentPayCount);
    End;
End;

Procedure LoadFoodSalesFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TFoodSale;
Begin
 N := MyTableIndexCount(SaleTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(SaleTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(SaleTable, E.DataOfs, R) Then
    If FoodSaleCount < MAX_FOOD_SALE Then Begin
     FoodSales[FoodSaleCount] := R;
     FoodSales[FoodSaleCount].Active := True;
     If R.ID >= NextSaleID Then NextSaleID := R.ID + 1;
     Inc(FoodSaleCount);
    End;
End;

Procedure BulkPersistRentPays;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To RentPayCount - 1 Do
  B := MyTableInsert(RentTable, MyKeyFromID('R', RentPays[I].ID), RentPays[I]);
End;

Procedure BulkPersistFoodSales;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To FoodSaleCount - 1 Do
  B := MyTableInsert(SaleTable, MyKeyFromID('S', FoodSales[I].ID), FoodSales[I]);
End;

Procedure InitMallExt;
Var Bootstrap: Boolean;
Begin
 TenantCount := 0; NextTenantID := 1;
 LeaseCount := 0; NextLeaseID := 1;
 RentPayCount := 0; NextRentID := 1;
 FoodVCount := 0; NextFoodVID := 1;
 FoodMCount := 0; NextFoodMID := 1;
 FoodSaleCount := 0; NextSaleID := 1;
 MallEvtCount := 0; NextEvtID := 1;
 PromoCount := 0; NextPromoID := 1;
 MaintTktCount := 0; NextMaintID := 1;
 CleanTaskCount := 0; NextCleanID := 1;

 { Tables MyISAM persistantes }
 MyTableInit(TenTable,   'TENANT',  SizeOf(TTenant));
 MyTableInit(LeaseTable, 'LEASE',   SizeOf(TLease));
 MyTableInit(FoodVTable, 'FOODV',   SizeOf(TFoodV));
 MyTableInit(FoodMTable, 'FOODM',   SizeOf(TFoodM));
 MyTableInit(EvtTable,   'MALLEVT', SizeOf(TMallEvt));
 MyTableInit(PromoTable, 'PROMO',   SizeOf(TPromo));
 MyTableInit(MaintTable, 'MAINT',   SizeOf(TMaintTkt));
 MyTableInit(CleanTable, 'CLEAN',   SizeOf(TCleanTask));
 MyTableInit(RentTable,  'RENTPAY', SizeOf(TRentPay));
 MyTableInit(SaleTable,  'FOODSAL', SizeOf(TFoodSale));

 Bootstrap := Not (MyTableExists('TENANT') And MyTableExists('LEASE') And
                   MyTableExists('FOODV')  And MyTableExists('FOODM') And
                   MyTableExists('MALLEVT')And MyTableExists('PROMO') And
                   MyTableExists('MAINT')  And MyTableExists('CLEAN') And
                   MyTableExists('RENTPAY')And MyTableExists('FOODSAL'));
 If Bootstrap Then Begin
  MyTableCreate(TenTable);  MyTableCreate(LeaseTable);
  MyTableCreate(FoodVTable);MyTableCreate(FoodMTable);
  MyTableCreate(EvtTable);  MyTableCreate(PromoTable);
  MyTableCreate(MaintTable);MyTableCreate(CleanTable);
  MyTableCreate(RentTable); MyTableCreate(SaleTable);
 End;

 { Bootstrap : tables creees vides ; les enregistrements sont ajoutes
   via les dialogues utilisateur (DB-only, aucun seed code). }

 If Bootstrap Then Begin
  { Rien a precharger : les .MYD/.MYI viennent d etre crees vides }
 End Else Begin
  TenantCount := 0;   NextTenantID := 1;
  LeaseCount := 0;    NextLeaseID := 1;
  FoodVCount := 0;    NextFoodVID := 1;
  FoodMCount := 0;    NextFoodMID := 1;
  MallEvtCount := 0;  NextEvtID := 1;
  PromoCount := 0;    NextPromoID := 1;
  MaintTktCount := 0; NextMaintID := 1;
  CleanTaskCount := 0;NextCleanID := 1;
  RentPayCount := 0;  NextRentID := 1;
  FoodSaleCount := 0; NextSaleID := 1;
  LoadTenantsFromDB;  LoadLeasesFromDB;
  LoadFoodVFromDB;    LoadFoodMFromDB;
  LoadEventsFromDB;   LoadPromosFromDB;
  LoadMaintFromDB;    LoadCleanFromDB;
  LoadRentPaysFromDB; LoadFoodSalesFromDB;
 End;
End;

Procedure FmtTenantLine(I: Integer; Var S: String);
Begin
 S := Tenants[I].Code;
 While Length(S) < 12 Do S := S + ' ';
 S := S + Tenants[I].Name;
 While Length(S) < 44 Do S := S + ' ';
 S := S + TenantCatLabel(Tenants[I].Category);
 While Length(S) < 56 Do S := S + ' ';
 S := S + Tenants[I].Stall;
 While Length(S) < 62 Do S := S + ' ';
 S := S + IntToStrPad(Tenants[I].AreaM2, 4);
End;

Procedure DlgTenantDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= TenantCount) Then Exit;
 DlgInit(D, 'Boutique ' + Tenants[Idx].Code, 460, 320);
 DlgAddFrame(D, 12, 16, 436, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code        : ' + Tenants[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom         : ' + Tenants[Idx].Name);
 DlgAddLabel(D, 24, 80,  'Categorie   : ' + TenantCatLabel(Tenants[Idx].Category));
 DlgAddLabel(D, 24, 100, 'Stall       : ' + Tenants[Idx].Stall);
 DlgAddLabel(D, 24, 120, 'Etage       : ' + IntToStrPad(Tenants[Idx].Floor, 0));
 DlgAddLabel(D, 24, 140, 'Surface m2  : ' + IntToStrPad(Tenants[Idx].AreaM2, 0));
 DlgAddLabel(D, 24, 160, 'Telephone   : ' + Tenants[Idx].Phone);
 DlgAddLabel(D, 24, 180, 'Email       : ' + Tenants[Idx].Email);
 DlgAddLabel(D, 24, 200, 'Gerant      : ' + Tenants[Idx].Manager);
 DlgAddLabel(D, 24, 220, 'Ouvert le   : ' + IntToStrPad(Tenants[Idx].OpenSince, 0));
 DlgAddButton(D, 360, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgTenantForm(Var R: TTenant; IsNew: Boolean): Boolean;
Var
 D: TDialog;
 EC, EN, EST, EFL, EAR, EPH, EEM, EMG: Integer;
 Btn: SmallInt;
 OK: Boolean;
 Title: String;
Begin
 DlgTenantForm := False;
 If IsNew Then Title := 'Nouvelle boutique' Else Title := 'Editer boutique';
 DlgInit(D, Title, 520, 360);
 DlgAddFrame(D, 12, 16, 496, 280, 'Informations');

 DlgAddLabel(D, 24, 40,  'Code      :');
 EC  := DlgAddEdit(D, 140, 36, 120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Nom       :');
 EN  := DlgAddEdit(D, 140, 60, 360, R.Name, 40);
 DlgAddLabel(D, 24, 88,  'Stall     :');
 EST := DlgAddEdit(D, 140, 84, 120, R.Stall, 10);
 DlgAddLabel(D, 24, 112, 'Etage     :');
 EFL := DlgAddNumEdit(D, 140, 108, 60, IntToStrPad(R.Floor, 0), 3, False);
 DlgAddLabel(D, 24, 136, 'Surface m2:');
 EAR := DlgAddNumEdit(D, 140, 132, 80, IntToStrPad(R.AreaM2, 0), 5, False);
 DlgAddLabel(D, 24, 160, 'Telephone :');
 EPH := DlgAddEdit(D, 140, 156, 200, R.Phone, 20);
 DlgAddLabel(D, 24, 184, 'Email     :');
 EEM := DlgAddEdit(D, 140, 180, 320, R.Email, 40);
 DlgAddLabel(D, 24, 208, 'Gerant    :');
 EMG := DlgAddEdit(D, 140, 204, 240, R.Manager, 30);

 DlgAddButton(D, 280, 318, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 318, 100, 'Annuler',-1, 'A');
 D.Focus := EC;

 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;

 R.Code      := D.Ctrls[EC].Text;
 R.Name      := D.Ctrls[EN].Text;
 R.Stall     := D.Ctrls[EST].Text;
 R.Floor     := StrToIntDef(D.Ctrls[EFL].Text, R.Floor);
 R.AreaM2    := StrToIntDef(D.Ctrls[EAR].Text, R.AreaM2);
 R.Phone     := D.Ctrls[EPH].Text;
 R.Email     := D.Ctrls[EEM].Text;
 R.Manager   := D.Ctrls[EMG].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 If R.Name = '' Then Begin ShowMessageBox('Err', 'Nom obligatoire.'); Exit; End;
 DlgTenantForm := True;
 OK := True;     { silence unused }
 If OK Then ;
End;

Procedure DlgTenantList;
Var
 I, Sel, Action: Integer;
 S: String;
 K: TMyKey;
 NR: TTenant;
 B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To TenantCount - 1 Do
   If Tenants[I].Active Then Begin
    FmtTenantLine(I, S);
    BrowseAdd(S, MyKeyPad(Tenants[I].Code));
   End;
  Action := ShowDBBrowser('Boutiques',
   'Code        Nom                          Categ.      Stall  Surf',
   True, True, True);
  K := BrowseSelectedKey;
  Sel := -1;
  If K <> '' Then
   For I := 0 To TenantCount - 1 Do
    If Tenants[I].Active And (MyKeyPad(Tenants[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True;
    NR.ID := NextTenantID;
    NR.Category := TC_OTHER;
    NR.Floor := 1;
    NR.AreaM2 := 50;
    If DlgTenantForm(NR, True) Then Begin
     If FindTenantByCode(NR.Code) >= 0 Then
      ShowMessageBox('Err', 'Code deja utilise.')
     Else If TenantCount >= MAX_TENANTS Then
      ShowMessageBox('Err', 'Capacite atteinte.')
     Else Begin
      Tenants[TenantCount] := NR;
      Inc(TenantCount);
      Inc(NextTenantID);
      B := MyTableInsert(TenTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgTenantDetail(Sel)
              Else ShowMessageBox('Info', 'Aucune ligne selectionnee.');
   BR_DELETE: If Sel >= 0 Then Begin
    Tenants[Sel].Active := False;
    B := MyTableDelete(TenTable, MyKeyPad(Tenants[Sel].Code));
    If B Then ShowMessageBox('OK', 'Boutique supprimee.')
    Else ShowMessageBox('Avert', 'Supprimee en RAM, .MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne selectionnee.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgTenantNew;
Var NR: TTenant; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True;
 NR.ID := NextTenantID;
 NR.Category := TC_OTHER;
 NR.Floor := 1;
 NR.AreaM2 := 50;
 If Not DlgTenantForm(NR, True) Then Exit;
 If FindTenantByCode(NR.Code) >= 0 Then Begin
  ShowMessageBox('Err', 'Code deja utilise.'); Exit;
 End;
 If TenantCount >= MAX_TENANTS Then Begin
  ShowMessageBox('Err', 'Capacite atteinte.'); Exit;
 End;
 Tenants[TenantCount] := NR;
 Inc(TenantCount);
 Inc(NextTenantID);
 B := MyTableInsert(TenTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgTenantEdit2;
Var S: String; Idx: Integer; B: Boolean; R: TTenant;
Begin
 S := '';
 If Not ShowInputBox('Editer Boutique', 'Code:', S, 10) Then Exit;
 Idx := FindTenantByCode(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := Tenants[Idx];
 If Not DlgTenantForm(R, False) Then Exit;
 Tenants[Idx] := R;
 B := MyTableUpdate(TenTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgTenantDel;
Var S: String; Idx: Integer; B: Boolean;
Begin
 S := '';
 If ShowInputBox('Supprimer Boutique', 'Code de la boutique:', S, 10) Then
 Begin
  Idx := FindTenantByCode(S);
  If Idx < 0 Then ShowMessageBox('Erreur', 'Boutique introuvable.')
  Else Begin
   Tenants[Idx].Active := False;
   B := MyTableDelete(TenTable, MyKeyPad(Tenants[Idx].Code));
   If B Then ShowMessageBox('OK', 'Boutique ' + S + ' supprimee.')
   Else ShowMessageBox('Avert', 'Supprimee en RAM, .MYD non modifie.');
  End;
 End;
End;

Procedure DlgTenantInfo;
Var S: String; Idx: Integer;
Begin
 S := '';
 If Not ShowInputBox('Info Boutique', 'Code:', S, 10) Then Exit;
 Idx := FindTenantByCode(S);
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Introuvable.'); Exit; End;
 DlgTenantDetail(Idx);
End;

Procedure DlgTenantRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport Boutiques', 400, 220);
 DlgAddLabel(D, 16, 20, 'Boutiques actives    : ' + IntToStrPad(CountActiveTenants, 0));
 DlgAddLabel(D, 16, 40, 'Stalls vacants       : ' + IntToStrPad(CountVacantStalls, 0));
 DlgAddLabel(D, 16, 60, 'Baux actifs          : ' + IntToStrPad(CountActiveLeases, 0));
 DlgAddLabel(D, 16, 80, 'Revenu mensuel total : ' + RealToStr(SumMonthlyRevenue, 10, 2));
 DlgAddLabel(D, 16, 100, 'Loyer paye total     : ' + RealToStr(SumRentPaid, 10, 2));
 DlgAddButton(D, 300, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgTenantVacant;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Stalls vacants', 360, 160);
 DlgAddLabel(D, 16, 20, 'Nombre de stalls vacants : ' + IntToStrPad(CountVacantStalls, 0));
 DlgAddLabel(D, 16, 50, 'Capacite estimee         : 80 stalls');
 DlgAddLabel(D, 16, 70, 'Stalls occupes           : ' + IntToStrPad(CountActiveTenants, 0));
 DlgAddButton(D, 260, 120, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgTenantExpire;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer;
Begin
 DlgInit(D, 'Baux expirant en 2025', 500, 320);
 Y := 20;
 N := 0;
 DlgAddLabel(D, 16, Y, 'Bail#  Locataire ID  Echeance');
 Y := Y + 16;
 For I := 0 To LeaseCount - 1 Do
 Begin
  If Leases[I].Active And (Leases[I].EndDate >= 20250101) And
     (Leases[I].EndDate <= 20251231) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y,
    IntToStrPad(Leases[I].ID, 4) + '    ' +
    IntToStrPad(Leases[I].TenantID, 4) + '         ' +
    IntToStrPad(Leases[I].EndDate, 8));
   Y := Y + 14;
   If Y > 280 Then Exit;
  End;
 End;
 DlgAddLabel(D, 16, Y + 8, 'Total : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES BAUX
  ============================================================================ }

Function DlgLeaseForm(Var R: TLease; IsNew: Boolean): Boolean;
Var D: TDialog; ET, ESD, EED, ERN, EDP, ENO: Integer; Btn: SmallInt; T: String;
Begin
 DlgLeaseForm := False;
 If IsNew Then T := 'Nouveau bail' Else T := 'Editer bail';
 DlgInit(D, T, 500, 330);
 DlgAddFrame(D, 12, 16, 476, 250, 'Bail');
 DlgAddLabel(D, 24, 40,  'ID boutique :');
 ET  := DlgAddNumEdit(D, 160, 36, 80,  IntToStrPad(R.TenantID, 0), 6, False);
 DlgAddLabel(D, 24, 64,  'Loyer / mois:');
 ERN := DlgAddNumEdit(D, 160, 60, 100, RealToStr(R.MonthlyRent, 0, 2), 10, True);
 DlgAddLabel(D, 24, 88,  'Depot       :');
 EDP := DlgAddNumEdit(D, 160, 84, 100, RealToStr(R.Deposit, 0, 2), 10, True);
 DlgAddLabel(D, 24, 112, 'Debut AAAAMMJJ:');
 ESD := DlgAddNumEdit(D, 160, 108, 100, IntToStrPad(R.StartDate, 0), 8, False);
 DlgAddLabel(D, 24, 136, 'Fin AAAAMMJJ:');
 EED := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.EndDate, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Notes       :');
 ENO := DlgAddEdit(D, 160, 156, 300, R.Notes, 60);
 DlgAddButton(D, 260, 288, 100, 'OK',      1, 'O');
 DlgAddButton(D, 376, 288, 100, 'Annuler',-1, 'A');
 D.Focus := ET;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.TenantID    := StrToIntDef(D.Ctrls[ET].Text, R.TenantID);
 R.MonthlyRent := StrToRealDef(D.Ctrls[ERN].Text, R.MonthlyRent);
 R.Deposit     := StrToRealDef(D.Ctrls[EDP].Text, R.Deposit);
 R.StartDate   := StrToIntDef(D.Ctrls[ESD].Text, R.StartDate);
 R.EndDate     := StrToIntDef(D.Ctrls[EED].Text, R.EndDate);
 R.Notes       := D.Ctrls[ENO].Text;
 If FindTenantByID(R.TenantID) < 0 Then Begin
  ShowMessageBox('Err', 'Boutique inconnue.'); Exit;
 End;
 DlgLeaseForm := True;
End;

Procedure DlgLeaseDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt; TIx: Integer; TN: String;
Begin
 If (Idx < 0) Or (Idx >= LeaseCount) Then Exit;
 TIx := FindTenantByID(Leases[Idx].TenantID);
 If TIx >= 0 Then TN := Tenants[TIx].Name Else TN := '(inconnue)';
 DlgInit(D, 'Bail ' + IntToStrPad(Leases[Idx].ID, 0), 460, 310);
 DlgAddFrame(D, 12, 16, 436, 230, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID          : ' + IntToStrPad(Leases[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Boutique    : ' + IntToStrPad(Leases[Idx].TenantID, 0) + '  ' + TN);
 DlgAddLabel(D, 24, 80,  'Debut       : ' + IntToStrPad(Leases[Idx].StartDate, 0));
 DlgAddLabel(D, 24, 100, 'Fin         : ' + IntToStrPad(Leases[Idx].EndDate, 0));
 DlgAddLabel(D, 24, 120, 'Loyer / mois: ' + RealToStr(Leases[Idx].MonthlyRent, 0, 2));
 DlgAddLabel(D, 24, 140, 'Depot       : ' + RealToStr(Leases[Idx].Deposit, 0, 2));
 DlgAddLabel(D, 24, 160, 'Statut      : ' + LeaseStatusLabel(Leases[Idx].Status));
 DlgAddLabel(D, 24, 180, 'Notes       : ' + Leases[Idx].Notes);
 DlgAddButton(D, 360, 270, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgLeaseList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TLease; B: Boolean; TIx: Integer; TN: String;
Begin
 Repeat
  BrowseClear;
  For I := 0 To LeaseCount - 1 Do
   If Leases[I].Active Then Begin
    TIx := FindTenantByID(Leases[I].TenantID);
    If TIx >= 0 Then TN := Tenants[TIx].Code Else TN := '?';
    S := IntToStrPad(Leases[I].ID, 4) + '  ' + TN;
    While Length(S) < 14 Do S := S + ' ';
    S := S + IntToStrPad(Leases[I].StartDate, 8) + '  ' +
             IntToStrPad(Leases[I].EndDate, 8) + '  ' +
             RealToStr(Leases[I].MonthlyRent, 8, 2) + '  ' +
             LeaseStatusLabel(Leases[I].Status);
    BrowseAdd(S, MyKeyFromID('L', Leases[I].ID));
   End;
  Action := ShowDBBrowser('Baux',
   'Bail#  Bout   Debut     Fin       Loyer/m    Statut',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To LeaseCount - 1 Do
    If Leases[I].Active And (MyKeyFromID('L', Leases[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextLeaseID;
    NR.MonthlyRent := 1000; NR.Deposit := 1000;
    NR.StartDate := 20260101; NR.EndDate := 20271231;
    NR.Status := LS_ACTIVE;
    If DlgLeaseForm(NR, True) Then Begin
     If LeaseCount >= MAX_LEASES Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Leases[LeaseCount] := NR; Inc(LeaseCount); Inc(NextLeaseID);
      B := MyTableInsert(LeaseTable, MyKeyFromID('L', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgLeaseDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Leases[Sel].Status := LS_CANCELED;
    B := MyTableUpdate(LeaseTable, MyKeyFromID('L', Leases[Sel].ID), Leases[Sel]);
    If B Then ShowMessageBox('OK', 'Bail annule.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgLeaseNew;
Var NR: TLease; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextLeaseID;
 NR.MonthlyRent := 1000; NR.Deposit := 1000;
 NR.StartDate := 20260101; NR.EndDate := 20271231; NR.Status := LS_ACTIVE;
 If Not DlgLeaseForm(NR, True) Then Exit;
 If LeaseCount >= MAX_LEASES Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Leases[LeaseCount] := NR; Inc(LeaseCount); Inc(NextLeaseID);
 B := MyTableInsert(LeaseTable, MyKeyFromID('L', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgLeaseEdit;
Var S: String; ID: LongInt; Idx: Integer; R: TLease; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer bail', 'Numero du bail:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0); Idx := FindLeaseByID(ID);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := Leases[Idx];
 If Not DlgLeaseForm(R, False) Then Exit;
 Leases[Idx] := R;
 B := MyTableUpdate(LeaseTable, MyKeyFromID('L', R.ID), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgLeaseDel;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Supprimer bail', 'Numero du bail:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindLeaseByID(ID);
 If Idx < 0 Then ShowMessageBox('Erreur', 'Bail introuvable.')
 Else Begin
  Leases[Idx].Status := LS_CANCELED;
  B := MyTableUpdate(LeaseTable, MyKeyFromID('L', Leases[Idx].ID), Leases[Idx]);
  If B Then ShowMessageBox('OK', 'Bail ' + S + ' annule.')
  Else ShowMessageBox('Avert', 'Annule en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgLeaseRpt;
Var D: TDialog; Btn: SmallInt; I, NA, NE, NC: Integer;
Begin
 NA := 0; NE := 0; NC := 0;
 For I := 0 To LeaseCount - 1 Do
  If Leases[I].Active Then
  Begin
   If Leases[I].Status = LS_ACTIVE Then NA := NA + 1;
   If Leases[I].Status = LS_EXPIRED Then NE := NE + 1;
   If Leases[I].Status = LS_CANCELED Then NC := NC + 1;
  End;
 DlgInit(D, 'Rapport Baux', 360, 200);
 DlgAddLabel(D, 16, 20, 'Total baux       : ' + IntToStrPad(LeaseCount, 0));
 DlgAddLabel(D, 16, 40, 'Actifs           : ' + IntToStrPad(NA, 0));
 DlgAddLabel(D, 16, 60, 'Expires          : ' + IntToStrPad(NE, 0));
 DlgAddLabel(D, 16, 80, 'Annules          : ' + IntToStrPad(NC, 0));
 DlgAddLabel(D, 16, 100, 'Revenu mensuel   : ' + RealToStr(SumMonthlyRevenue, 10, 2));
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES LOYERS
  ============================================================================ }

Procedure DlgRentDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= RentPayCount) Then Exit;
 DlgInit(D, 'Paiement ' + IntToStrPad(RentPays[Idx].ID, 0), 440, 280);
 DlgAddFrame(D, 12, 16, 416, 200, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID          : ' + IntToStrPad(RentPays[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Bail        : ' + IntToStrPad(RentPays[Idx].LeaseID, 0));
 DlgAddLabel(D, 24, 80,  'Echeance    : ' + IntToStrPad(RentPays[Idx].DueDate, 0));
 DlgAddLabel(D, 24, 100, 'Paye le     : ' + IntToStrPad(RentPays[Idx].PaidDate, 0));
 DlgAddLabel(D, 24, 120, 'Montant du  : ' + RealToStr(RentPays[Idx].Amount, 0, 2));
 DlgAddLabel(D, 24, 140, 'Montant paye: ' + RealToStr(RentPays[Idx].AmountPaid, 0, 2));
 DlgAddLabel(D, 24, 160, 'Statut      : ' + RentStatusLabel(RentPays[Idx].Status));
 DlgAddLabel(D, 24, 180, 'Reference   : ' + RentPays[Idx].Reference);
 DlgAddButton(D, 340, 240, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgRentList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To RentPayCount - 1 Do
   If RentPays[I].Active Then Begin
    S := IntToStrPad(RentPays[I].ID, 4) + '  ' +
         IntToStrPad(RentPays[I].LeaseID, 4) + '  ' +
         IntToStrPad(RentPays[I].DueDate, 8) + '  ' +
         IntToStrPad(RentPays[I].PaidDate, 8) + '  ' +
         RealToStr(RentPays[I].Amount, 8, 2) + '  ' +
         RentStatusLabel(RentPays[I].Status);
    BrowseAdd(S, MyKeyFromID('R', RentPays[I].ID));
   End;
  Action := ShowDBBrowser('Loyers',
   'ID    Bail   Echeance   Paye le    Montant    Statut',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To RentPayCount - 1 Do
    If RentPays[I].Active And (MyKeyFromID('R', RentPays[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: DlgRentPay;
   BR_DETAIL: If Sel >= 0 Then DlgRentDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    RentPays[Sel].Active := False;
    B := MyTableDelete(RentTable, MyKeyFromID('R', RentPays[Sel].ID));
    If B Then ShowMessageBox('OK', 'Paiement supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgRentPay;
Var S: String; LID: LongInt; LIdx: Integer; DT: TDateTime; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Paiement loyer', 'Numero du bail:', S, 6) Then Exit;
 LID := StrToIntDef(S, 0);
 LIdx := FindLeaseByID(LID);
 If LIdx < 0 Then Begin ShowMessageBox('Erreur', 'Bail introuvable.'); Exit; End;
 If RentPayCount >= MAX_RENT_PAY Then
  Begin ShowMessageBox('Erreur', 'Capacite atteinte.'); Exit; End;
 GetCurrentDT(DT);
 RentPays[RentPayCount].Active := True;
 RentPays[RentPayCount].ID := NextRentID;
 RentPays[RentPayCount].LeaseID := LID;
 RentPays[RentPayCount].DueDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 RentPays[RentPayCount].PaidDate := RentPays[RentPayCount].DueDate;
 RentPays[RentPayCount].Amount := Leases[LIdx].MonthlyRent;
 RentPays[RentPayCount].AmountPaid := Leases[LIdx].MonthlyRent;
 RentPays[RentPayCount].Status := RP_PAID;
 RentPays[RentPayCount].Reference := 'REF' + IntToStrPad(NextRentID, 4);
 B := MyTableInsert(RentTable, MyKeyFromID('R', NextRentID), RentPays[RentPayCount]);
 NextRentID := NextRentID + 1;
 RentPayCount := RentPayCount + 1;
 ShowMessageBox('OK', 'Paiement enregistre.');
End;

Procedure DlgRentDue;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer;
Begin
 DlgInit(D, 'Loyers a payer', 500, 320);
 Y := 20; N := 0;
 DlgAddLabel(D, 16, Y, 'ID    Bail   Echeance   Montant');
 Y := Y + 16;
 For I := 0 To RentPayCount - 1 Do
 Begin
  If RentPays[I].Active And ((RentPays[I].Status = RP_PENDING) Or
                              (RentPays[I].Status = RP_LATE)) And (Y < 280) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y,
    IntToStrPad(RentPays[I].ID, 4) + '   ' +
    IntToStrPad(RentPays[I].LeaseID, 4) + '   ' +
    IntToStrPad(RentPays[I].DueDate, 8) + '   ' +
    RealToStr(RentPays[I].Amount, 8, 2));
   Y := Y + 14;
  End;
 End;
 DlgAddLabel(D, 16, Y + 8, 'Total : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgRentRpt;
Var D: TDialog; Btn: SmallInt; I, NPay, NDue, NLate: Integer; STot, SPaid: Real;
Begin
 NPay := 0; NDue := 0; NLate := 0; STot := 0; SPaid := 0;
 For I := 0 To RentPayCount - 1 Do
  If RentPays[I].Active Then
  Begin
   STot := STot + RentPays[I].Amount;
   SPaid := SPaid + RentPays[I].AmountPaid;
   If RentPays[I].Status = RP_PAID Then NPay := NPay + 1;
   If RentPays[I].Status = RP_PENDING Then NDue := NDue + 1;
   If RentPays[I].Status = RP_LATE Then NLate := NLate + 1;
  End;
 DlgInit(D, 'Rapport Loyers', 400, 240);
 DlgAddLabel(D, 16, 20, 'Paiements enregistres   : ' + IntToStrPad(RentPayCount, 0));
 DlgAddLabel(D, 16, 40, 'Payes                   : ' + IntToStrPad(NPay, 0));
 DlgAddLabel(D, 16, 60, 'En attente              : ' + IntToStrPad(NDue, 0));
 DlgAddLabel(D, 16, 80, 'En retard               : ' + IntToStrPad(NLate, 0));
 DlgAddLabel(D, 16, 100, 'Total facture           : ' + RealToStr(STot, 10, 2));
 DlgAddLabel(D, 16, 120, 'Total encaisse          : ' + RealToStr(SPaid, 10, 2));
 DlgAddButton(D, 300, 200, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES FOOD COURT - VENDEURS
  ============================================================================ }

Function DlgFV2Form(Var R: TFoodV; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EN, ECu, ES, EP, EM, EOp: Integer; Btn: SmallInt; T: String;
Begin
 DlgFV2Form := False;
 If IsNew Then T := 'Nouveau vendeur' Else T := 'Editer vendeur';
 DlgInit(D, T, 520, 340);
 DlgAddFrame(D, 12, 16, 496, 260, 'Vendeur');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 140, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Nom      :'); EN  := DlgAddEdit(D, 140, 60,  340, R.Name, 30);
 DlgAddLabel(D, 24, 88,  'Cuisine  :'); ECu := DlgAddEdit(D, 140, 84,  240, R.Cuisine, 20);
 DlgAddLabel(D, 24, 112, 'Stall    :'); ES  := DlgAddEdit(D, 140, 108, 120, R.Stall, 10);
 DlgAddLabel(D, 24, 136, 'Telephone:'); EP  := DlgAddEdit(D, 140, 132, 200, R.Phone, 20);
 DlgAddLabel(D, 24, 160, 'Gerant   :'); EM  := DlgAddEdit(D, 140, 156, 280, R.Manager, 30);
 EOp := DlgAddCheck(D, 140, 184, 100, 'Ouvert', R.Open);
 DlgAddButton(D, 280, 296, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 296, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code    := D.Ctrls[EC].Text;
 R.Name    := D.Ctrls[EN].Text;
 R.Cuisine := D.Ctrls[ECu].Text;
 R.Stall   := D.Ctrls[ES].Text;
 R.Phone   := D.Ctrls[EP].Text;
 R.Manager := D.Ctrls[EM].Text;
 R.Open    := D.Ctrls[EOp].Checked;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgFV2Form := True;
End;

Procedure DlgFV2Detail(Idx: Integer);
Var D: TDialog; Btn: SmallInt; O: String;
Begin
 If (Idx < 0) Or (Idx >= FoodVCount) Then Exit;
 If FoodV[Idx].Open Then O := 'Oui' Else O := 'Non';
 DlgInit(D, 'Vendeur ' + FoodV[Idx].Code, 440, 280);
 DlgAddFrame(D, 12, 16, 416, 200, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + FoodV[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom      : ' + FoodV[Idx].Name);
 DlgAddLabel(D, 24, 80,  'Cuisine  : ' + FoodV[Idx].Cuisine);
 DlgAddLabel(D, 24, 100, 'Stall    : ' + FoodV[Idx].Stall);
 DlgAddLabel(D, 24, 120, 'Telephone: ' + FoodV[Idx].Phone);
 DlgAddLabel(D, 24, 140, 'Gerant   : ' + FoodV[Idx].Manager);
 DlgAddLabel(D, 24, 160, 'Ouvert   : ' + O);
 DlgAddButton(D, 340, 240, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgFV2List;
Var I, Sel, Action: Integer; S, O: String; K: TMyKey; NR: TFoodV; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To FoodVCount - 1 Do
   If FoodV[I].Active Then Begin
    If FoodV[I].Open Then O := 'Oui' Else O := 'Non';
    S := FoodV[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + FoodV[I].Name;
    While Length(S) < 32 Do S := S + ' ';
    S := S + FoodV[I].Cuisine;
    While Length(S) < 48 Do S := S + ' ';
    S := S + FoodV[I].Stall;
    While Length(S) < 56 Do S := S + ' ';
    S := S + O;
    BrowseAdd(S, MyKeyPad(FoodV[I].Code));
   End;
  Action := ShowDBBrowser('Food Court - Vendeurs',
   'Code       Nom                  Cuisine         Stall   Ouvert',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To FoodVCount - 1 Do
    If FoodV[I].Active And (MyKeyPad(FoodV[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextFoodVID; NR.Open := True;
    If DlgFV2Form(NR, True) Then Begin
     If FindFoodV2ByCode(NR.Code) >= 0 Then ShowMessageBox('Err', 'Code deja utilise.')
     Else If FoodVCount >= MAX_FOOD_V Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      FoodV[FoodVCount] := NR; Inc(FoodVCount); Inc(NextFoodVID);
      B := MyTableInsert(FoodVTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgFV2Detail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    FoodV[Sel].Active := False;
    B := MyTableDelete(FoodVTable, MyKeyPad(FoodV[Sel].Code));
    If B Then ShowMessageBox('OK', 'Vendeur supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgFV2New;
Var NR: TFoodV; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextFoodVID; NR.Open := True;
 If Not DlgFV2Form(NR, True) Then Exit;
 If FindFoodV2ByCode(NR.Code) >= 0 Then Begin ShowMessageBox('Err', 'Code deja utilise.'); Exit; End;
 If FoodVCount >= MAX_FOOD_V Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 FoodV[FoodVCount] := NR; Inc(FoodVCount); Inc(NextFoodVID);
 B := MyTableInsert(FoodVTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgFV2Edit;
Var S: String; Idx: Integer; R: TFoodV; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer vendeur', 'Code:', S, 10) Then Exit;
 Idx := FindFoodV2ByCode(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := FoodV[Idx];
 If Not DlgFV2Form(R, False) Then Exit;
 FoodV[Idx] := R;
 B := MyTableUpdate(FoodVTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgFV2Del;
Var S: String; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Supprimer vendeur', 'Code:', S, 10) Then Exit;
 Idx := FindFoodV2ByCode(S);
 If Idx < 0 Then ShowMessageBox('Erreur', 'Introuvable.')
 Else Begin
  FoodV[Idx].Active := False;
  B := MyTableDelete(FoodVTable, MyKeyPad(FoodV[Idx].Code));
  If B Then ShowMessageBox('OK', 'Vendeur ' + S + ' supprime.')
  Else ShowMessageBox('Avert', 'Supprime en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgFV2Rpt;
Var D: TDialog; Btn: SmallInt; I, NA, NO: Integer;
Begin
 NA := 0; NO := 0;
 For I := 0 To FoodVCount - 1 Do
  If FoodV[I].Active Then
  Begin
   NA := NA + 1;
   If FoodV[I].Open Then NO := NO + 1;
  End;
 DlgInit(D, 'Rapport Food Vendors', 360, 180);
 DlgAddLabel(D, 16, 20, 'Vendeurs total     : ' + IntToStrPad(NA, 0));
 DlgAddLabel(D, 16, 40, 'Vendeurs ouverts   : ' + IntToStrPad(NO, 0));
 DlgAddLabel(D, 16, 60, 'Items au menu      : ' + IntToStrPad(FoodMCount, 0));
 DlgAddLabel(D, 16, 80, 'Ventes du jour     : ' + RealToStr(SumFoodSalesToday, 8, 2));
 DlgAddButton(D, 260, 140, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES FOOD COURT - MENU ITEMS
  ============================================================================ }

Function DlgFM2Form(Var R: TFoodM; IsNew: Boolean): Boolean;
Var D: TDialog; EV, EC, EN, ECat, EP, EAv: Integer; Btn: SmallInt; T: String;
Begin
 DlgFM2Form := False;
 If IsNew Then T := 'Nouvel item' Else T := 'Editer item';
 DlgInit(D, T, 520, 300);
 DlgAddFrame(D, 12, 16, 496, 220, 'Item de menu');
 DlgAddLabel(D, 24, 40,  'ID vendeur:'); EV   := DlgAddNumEdit(D, 160, 36,  80,  IntToStrPad(R.VendorID, 0), 6, False);
 DlgAddLabel(D, 24, 64,  'Code item :'); EC   := DlgAddEdit(D, 160, 60,  120, R.Code, 10);
 DlgAddLabel(D, 24, 88,  'Nom       :'); EN   := DlgAddEdit(D, 160, 84,  300, R.Name, 30);
 DlgAddLabel(D, 24, 112, 'Categorie :'); ECat := DlgAddEdit(D, 160, 108, 200, R.Category, 20);
 DlgAddLabel(D, 24, 136, 'Prix      :'); EP   := DlgAddNumEdit(D, 160, 132, 100, RealToStr(R.Price, 0, 2), 8, True);
 EAv := DlgAddCheck(D, 160, 160, 100, 'Disponible', R.Available);
 DlgAddButton(D, 280, 256, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 256, 100, 'Annuler',-1, 'A');
 D.Focus := EV;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.VendorID  := StrToIntDef(D.Ctrls[EV].Text, R.VendorID);
 R.Code      := D.Ctrls[EC].Text;
 R.Name      := D.Ctrls[EN].Text;
 R.Category  := D.Ctrls[ECat].Text;
 R.Price     := StrToRealDef(D.Ctrls[EP].Text, R.Price);
 R.Available := D.Ctrls[EAv].Checked;
 If FindFoodV2ByID(R.VendorID) < 0 Then Begin ShowMessageBox('Err', 'Vendeur inconnu.'); Exit; End;
 DlgFM2Form := True;
End;

Procedure DlgFM2Detail(Idx: Integer);
Var D: TDialog; Btn: SmallInt; VI: Integer; VN, Av: String;
Begin
 If (Idx < 0) Or (Idx >= FoodMCount) Then Exit;
 VI := FindFoodV2ByID(FoodM[Idx].VendorID);
 If VI >= 0 Then VN := FoodV[VI].Name Else VN := '?';
 If FoodM[Idx].Available Then Av := 'Oui' Else Av := 'Non';
 DlgInit(D, 'Item ' + FoodM[Idx].Code, 440, 280);
 DlgAddFrame(D, 12, 16, 416, 200, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code      : ' + FoodM[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom       : ' + FoodM[Idx].Name);
 DlgAddLabel(D, 24, 80,  'Vendeur   : ' + IntToStrPad(FoodM[Idx].VendorID, 0) + '  ' + VN);
 DlgAddLabel(D, 24, 100, 'Categorie : ' + FoodM[Idx].Category);
 DlgAddLabel(D, 24, 120, 'Prix      : ' + RealToStr(FoodM[Idx].Price, 0, 2));
 DlgAddLabel(D, 24, 140, 'Disponible: ' + Av);
 DlgAddButton(D, 340, 240, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgFM2List;
Var I, Sel, Action, VI: Integer; S, VC: String; K: TMyKey; NR: TFoodM; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To FoodMCount - 1 Do
   If FoodM[I].Active Then Begin
    VI := FindFoodV2ByID(FoodM[I].VendorID);
    If VI >= 0 Then VC := FoodV[VI].Code Else VC := '?';
    S := VC;
    While Length(S) < 8 Do S := S + ' ';
    S := S + FoodM[I].Code;
    While Length(S) < 18 Do S := S + ' ';
    S := S + FoodM[I].Name;
    While Length(S) < 42 Do S := S + ' ';
    S := S + FoodM[I].Category;
    While Length(S) < 56 Do S := S + ' ';
    S := S + RealToStr(FoodM[I].Price, 6, 2);
    BrowseAdd(S, MyKeyFromID('M', FoodM[I].ID));
   End;
  Action := ShowDBBrowser('Food Court - Menus',
   'Vendeur  Code      Nom                  Cat.         Prix',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To FoodMCount - 1 Do
    If FoodM[I].Active And (MyKeyFromID('M', FoodM[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextFoodMID; NR.Available := True; NR.Price := 5.0;
    If DlgFM2Form(NR, True) Then Begin
     If FoodMCount >= MAX_FOOD_M Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      FoodM[FoodMCount] := NR; Inc(FoodMCount); Inc(NextFoodMID);
      B := MyTableInsert(FoodMTable, MyKeyFromID('M', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgFM2Detail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    FoodM[Sel].Active := False;
    B := MyTableDelete(FoodMTable, MyKeyFromID('M', FoodM[Sel].ID));
    If B Then ShowMessageBox('OK', 'Item supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgFM2New;
Var NR: TFoodM; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextFoodMID; NR.Available := True; NR.Price := 5.0;
 If Not DlgFM2Form(NR, True) Then Exit;
 If FoodMCount >= MAX_FOOD_M Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 FoodM[FoodMCount] := NR; Inc(FoodMCount); Inc(NextFoodMID);
 B := MyTableInsert(FoodMTable, MyKeyFromID('M', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgFM2Edit;
Var S: String; ID: LongInt; Idx: Integer; R: TFoodM; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer item', 'ID item:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0); Idx := FindFoodM2ByID(ID);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := FoodM[Idx];
 If Not DlgFM2Form(R, False) Then Exit;
 FoodM[Idx] := R;
 B := MyTableUpdate(FoodMTable, MyKeyFromID('M', R.ID), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgFM2Del;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Supprimer item', 'ID item:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindFoodM2ByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  FoodM[Idx].Active := False;
  B := MyTableDelete(FoodMTable, MyKeyFromID('M', FoodM[Idx].ID));
  If B Then ShowMessageBox('OK', 'Item supprime (FOODM.MYD a jour).')
  Else ShowMessageBox('Avert', 'Supprime en RAM, .MYD non modifie.');
 End;
End;

{ ============================================================================
  DIALOGUES FOOD COURT - VENTES
  ============================================================================ }

Procedure DlgFS2Rec;
Var D: TDialog; EV, EM, EQ, EPay: Integer; Btn: SmallInt;
    VID, MID: LongInt; VIdx, MIdx, Q: Integer; DT: TDateTime; B: Boolean;
Begin
 DlgInit(D, 'Enregistrer une vente', 460, 280);
 DlgAddFrame(D, 12, 16, 436, 200, 'Vente');
 DlgAddLabel(D, 24, 40,  'ID vendeur :'); EV   := DlgAddNumEdit(D, 160, 36, 80,  '', 6, False);
 DlgAddLabel(D, 24, 64,  'ID item    :'); EM   := DlgAddNumEdit(D, 160, 60, 80,  '', 6, False);
 DlgAddLabel(D, 24, 88,  'Quantite   :'); EQ   := DlgAddNumEdit(D, 160, 84, 60,  '1', 4, False);
 DlgAddLabel(D, 24, 112, 'Paiement   :'); EPay := DlgAddEdit(D, 160, 108, 120, 'Carte', 10);
 DlgAddButton(D, 230, 240, 100, 'OK',      1, 'O');
 DlgAddButton(D, 340, 240, 100, 'Annuler',-1, 'A');
 D.Focus := EV;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 VID := StrToIntDef(D.Ctrls[EV].Text, 0); VIdx := FindFoodV2ByID(VID);
 If VIdx < 0 Then Begin ShowMessageBox('Err', 'Vendeur inconnu.'); Exit; End;
 MID := StrToIntDef(D.Ctrls[EM].Text, 0); MIdx := FindFoodM2ByID(MID);
 If MIdx < 0 Then Begin ShowMessageBox('Err', 'Item inconnu.'); Exit; End;
 Q := StrToIntDef(D.Ctrls[EQ].Text, 1);
 If FoodSaleCount >= MAX_FOOD_SALE Then Begin ShowMessageBox('Err', 'Capacite atteinte.'); Exit; End;
 GetCurrentDT(DT);
 FoodSales[FoodSaleCount].Active := True;
 FoodSales[FoodSaleCount].ID := NextSaleID;
 FoodSales[FoodSaleCount].VendorID := VID;
 FoodSales[FoodSaleCount].ItemID := MID;
 FoodSales[FoodSaleCount].Qty := Q;
 FoodSales[FoodSaleCount].UnitPrice := FoodM[MIdx].Price;
 FoodSales[FoodSaleCount].Total := Q * FoodM[MIdx].Price;
 FoodSales[FoodSaleCount].SaleDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 FoodSales[FoodSaleCount].SaleTime := LongInt(DT.Hour)*10000;
 FoodSales[FoodSaleCount].PayMethod := D.Ctrls[EPay].Text;
 B := MyTableInsert(SaleTable, MyKeyFromID('S', NextSaleID), FoodSales[FoodSaleCount]);
 NextSaleID := NextSaleID + 1;
 FoodSaleCount := FoodSaleCount + 1;
 If B Then ShowMessageBox('OK', 'Vente enregistree.')
 Else ShowMessageBox('Avert', '.MYD non modifie.');
End;

Procedure DlgFS2Today;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; S: Real; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 N := 0; S := 0;
 For I := 0 To FoodSaleCount - 1 Do
  If FoodSales[I].Active And (FoodSales[I].SaleDate = Today) Then
  Begin
   N := N + 1;
   S := S + FoodSales[I].Total;
  End;
 DlgInit(D, 'Ventes du jour', 400, 220);
 Y := 20;
 DlgAddLabel(D, 16, Y, 'Date du jour       : ' + IntToStrPad(Today, 0));
 DlgAddLabel(D, 16, Y + 20, 'Nombre de ventes   : ' + IntToStrPad(N, 0));
 DlgAddLabel(D, 16, Y + 40, 'Montant total      : ' + RealToStr(S, 10, 2));
 If N > 0 Then
  DlgAddLabel(D, 16, Y + 60, 'Vente moyenne      : ' + RealToStr(S / N, 10, 2));
 DlgAddButton(D, 300, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgFS2Week;
Var D: TDialog; Btn: SmallInt; I, N: Integer; S: Real;
Begin
 N := 0; S := 0;
 For I := 0 To FoodSaleCount - 1 Do
  If FoodSales[I].Active Then
  Begin
   N := N + 1;
   S := S + FoodSales[I].Total;
  End;
 DlgInit(D, 'Ventes semaine', 400, 200);
 DlgAddLabel(D, 16, 20, 'Ventes totales : ' + IntToStrPad(N, 0));
 DlgAddLabel(D, 16, 40, 'Montant        : ' + RealToStr(S, 10, 2));
 DlgAddButton(D, 300, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgFS2Top;
Var D: TDialog; Btn: SmallInt; I, J, Y: Integer; VTot: Array[0..MAX_FOOD_V-1] Of Real; MaxV: Real; MaxI: Integer;
Begin
 For I := 0 To FoodVCount - 1 Do VTot[I] := 0;
 For I := 0 To FoodSaleCount - 1 Do
  If FoodSales[I].Active Then
   For J := 0 To FoodVCount - 1 Do
    If FoodV[J].Active And (FoodV[J].ID = FoodSales[I].VendorID) Then
     VTot[J] := VTot[J] + FoodSales[I].Total;
 DlgInit(D, 'Top vendeurs', 460, 320);
 Y := 20;
 DlgAddLabel(D, 16, Y, 'Rang  Vendeur                 Total');
 Y := Y + 16;
 For I := 1 To 8 Do
 Begin
  MaxV := -1; MaxI := -1;
  For J := 0 To FoodVCount - 1 Do
   If FoodV[J].Active And (VTot[J] > MaxV) Then
   Begin MaxV := VTot[J]; MaxI := J; End;
  If MaxI < 0 Then Break;
  DlgAddLabel(D, 16, Y,
    IntToStrPad(I, 2) + '   ' +
    FoodV[MaxI].Name + '   ' +
    RealToStr(MaxV, 10, 2));
  VTot[MaxI] := -2;
  Y := Y + 14;
 End;
 DlgAddButton(D, 360, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgFS2Rpt;
Var D: TDialog; Btn: SmallInt; I: Integer; STot: Real;
Begin
 STot := 0;
 For I := 0 To FoodSaleCount - 1 Do
  If FoodSales[I].Active Then STot := STot + FoodSales[I].Total;
 DlgInit(D, 'Rapport ventes food court', 400, 200);
 DlgAddLabel(D, 16, 20, 'Nombre de transactions : ' + IntToStrPad(FoodSaleCount, 0));
 DlgAddLabel(D, 16, 40, 'Chiffre d affaires     : ' + RealToStr(STot, 10, 2));
 DlgAddLabel(D, 16, 60, 'Aujourdhui             : ' + RealToStr(SumFoodSalesToday, 10, 2));
 DlgAddButton(D, 300, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES EVENEMENTS
  ============================================================================ }

Function DlgEvtForm(Var R: TMallEvt; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EN, EL, ESD, EED, EBd, EAt, ENo: Integer; Btn: SmallInt; T: String;
Begin
 DlgEvtForm := False;
 If IsNew Then T := 'Nouvel evenement' Else T := 'Editer evenement';
 DlgInit(D, T, 540, 380);
 DlgAddFrame(D, 12, 16, 516, 300, 'Evenement');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Nom      :'); EN  := DlgAddEdit(D, 160, 60,  340, R.Name, 40);
 DlgAddLabel(D, 24, 88,  'Lieu     :'); EL  := DlgAddEdit(D, 160, 84,  240, R.Location, 20);
 DlgAddLabel(D, 24, 112, 'Debut    :'); ESD := DlgAddNumEdit(D, 160, 108, 100, IntToStrPad(R.DateStart, 0), 8, False);
 DlgAddLabel(D, 24, 136, 'Fin      :'); EED := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.DateEnd, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Budget   :'); EBd := DlgAddNumEdit(D, 160, 156, 120, RealToStr(R.Budget, 0, 2), 10, True);
 DlgAddLabel(D, 24, 184, 'Affluence:'); EAt := DlgAddNumEdit(D, 160, 180, 100, IntToStrPad(R.Attendance, 0), 8, False);
 DlgAddLabel(D, 24, 208, 'Notes    :'); ENo := DlgAddEdit(D, 160, 204, 340, R.Notes, 80);
 DlgAddButton(D, 300, 336, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 336, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Name := D.Ctrls[EN].Text;
 R.Location := D.Ctrls[EL].Text;
 R.DateStart := StrToIntDef(D.Ctrls[ESD].Text, R.DateStart);
 R.DateEnd := StrToIntDef(D.Ctrls[EED].Text, R.DateEnd);
 R.Budget := StrToRealDef(D.Ctrls[EBd].Text, R.Budget);
 R.Attendance := StrToIntDef(D.Ctrls[EAt].Text, R.Attendance);
 R.Notes := D.Ctrls[ENo].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgEvtForm := True;
End;

Procedure DlgEvtDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= MallEvtCount) Then Exit;
 DlgInit(D, 'Evenement ' + MallEvts[Idx].Code, 480, 320);
 DlgAddFrame(D, 12, 16, 456, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + MallEvts[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom      : ' + MallEvts[Idx].Name);
 DlgAddLabel(D, 24, 80,  'Categorie: ' + EvtCatLabel(MallEvts[Idx].Category));
 DlgAddLabel(D, 24, 100, 'Lieu     : ' + MallEvts[Idx].Location);
 DlgAddLabel(D, 24, 120, 'Debut    : ' + IntToStrPad(MallEvts[Idx].DateStart, 0));
 DlgAddLabel(D, 24, 140, 'Fin      : ' + IntToStrPad(MallEvts[Idx].DateEnd, 0));
 DlgAddLabel(D, 24, 160, 'Budget   : ' + RealToStr(MallEvts[Idx].Budget, 0, 2));
 DlgAddLabel(D, 24, 180, 'Affluence: ' + IntToStrPad(MallEvts[Idx].Attendance, 0));
 DlgAddLabel(D, 24, 200, 'Notes    : ' + MallEvts[Idx].Notes);
 DlgAddButton(D, 380, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgEvtList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TMallEvt; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To MallEvtCount - 1 Do
   If MallEvts[I].Active Then Begin
    S := MallEvts[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + MallEvts[I].Name;
    While Length(S) < 41 Do S := S + ' ';
    S := S + EvtCatLabel(MallEvts[I].Category);
    While Length(S) < 51 Do S := S + ' ';
    S := S + IntToStrPad(MallEvts[I].DateStart, 8) + '  ' + IntToStrPad(MallEvts[I].DateEnd, 8);
    BrowseAdd(S, MyKeyPad(MallEvts[I].Code));
   End;
  Action := ShowDBBrowser('Evenements',
   'Code       Nom                          Cat.       Debut     Fin',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To MallEvtCount - 1 Do
    If MallEvts[I].Active And (MyKeyPad(MallEvts[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextEvtID; NR.Category := EC_OTHER;
    NR.DateStart := 20260101; NR.DateEnd := 20260131;
    If DlgEvtForm(NR, True) Then Begin
     If MallEvtCount >= MAX_MALL_EVT Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      MallEvts[MallEvtCount] := NR; Inc(MallEvtCount); Inc(NextEvtID);
      B := MyTableInsert(EvtTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgEvtDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    MallEvts[Sel].Active := False;
    B := MyTableDelete(EvtTable, MyKeyPad(MallEvts[Sel].Code));
    If B Then ShowMessageBox('OK', 'Evenement supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgEvtNew;
Var NR: TMallEvt; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextEvtID; NR.Category := EC_OTHER;
 NR.DateStart := 20260101; NR.DateEnd := 20260131;
 If Not DlgEvtForm(NR, True) Then Exit;
 If MallEvtCount >= MAX_MALL_EVT Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 MallEvts[MallEvtCount] := NR; Inc(MallEvtCount); Inc(NextEvtID);
 B := MyTableInsert(EvtTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgEvtEdit;
Var S: String; I, Idx: Integer; R: TMallEvt; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer evenement', 'Code:', S, 10) Then Exit;
 Idx := -1;
 For I := 0 To MallEvtCount - 1 Do
  If MallEvts[I].Active And (MallEvts[I].Code = S) Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := MallEvts[Idx];
 If Not DlgEvtForm(R, False) Then Exit;
 MallEvts[Idx] := R;
 B := MyTableUpdate(EvtTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgEvtDel;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Suppr evenement', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindMallEvtByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  MallEvts[Idx].Active := False;
  B := MyTableDelete(EvtTable, MyKeyPad(MallEvts[Idx].Code));
  If B Then ShowMessageBox('OK', 'Supprime (MALLEVT.MYD a jour).')
  Else ShowMessageBox('Avert', 'Supprime en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgEvtToday;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 DlgInit(D, 'Evenements en cours', 500, 320);
 Y := 20; N := 0;
 DlgAddLabel(D, 16, Y, 'Aujourdhui : ' + IntToStrPad(Today, 0));
 Y := Y + 20;
 For I := 0 To MallEvtCount - 1 Do
 Begin
  If MallEvts[I].Active And (MallEvts[I].DateStart <= Today) And
     (MallEvts[I].DateEnd >= Today) And (Y < 280) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y, MallEvts[I].Code + ' - ' + MallEvts[I].Name);
   Y := Y + 14;
  End;
 End;
 If N = 0 Then DlgAddLabel(D, 16, Y, '(aucun evenement en cours)');
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgEvtRpt;
Var D: TDialog; Btn: SmallInt; I, NS, NP, NH, NK, NO: Integer; B: Real;
Begin
 NS := 0; NP := 0; NH := 0; NK := 0; NO := 0; B := 0;
 For I := 0 To MallEvtCount - 1 Do
  If MallEvts[I].Active Then
  Begin
   B := B + MallEvts[I].Budget;
   Case MallEvts[I].Category Of
    EC_SHOW   : NS := NS + 1;
    EC_SALES  : NP := NP + 1;
    EC_HOLIDAY: NH := NH + 1;
    EC_KIDS   : NK := NK + 1;
   Else
    NO := NO + 1;
   End;
  End;
 DlgInit(D, 'Rapport evenements', 360, 240);
 DlgAddLabel(D, 16, 20, 'Total evenements  : ' + IntToStrPad(MallEvtCount, 0));
 DlgAddLabel(D, 16, 40, 'Spectacles        : ' + IntToStrPad(NS, 0));
 DlgAddLabel(D, 16, 60, 'Soldes            : ' + IntToStrPad(NP, 0));
 DlgAddLabel(D, 16, 80, 'Fetes             : ' + IntToStrPad(NH, 0));
 DlgAddLabel(D, 16, 100, 'Enfants           : ' + IntToStrPad(NK, 0));
 DlgAddLabel(D, 16, 120, 'Autres            : ' + IntToStrPad(NO, 0));
 DlgAddLabel(D, 16, 140, 'Budget total      : ' + RealToStr(B, 10, 2));
 DlgAddButton(D, 260, 200, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES PROMOTIONS
  ============================================================================ }

Function DlgPromoForm(Var R: TPromo; IsNew: Boolean): Boolean;
Var D: TDialog; EC, ET, ETI, EDi, ESD, EED, ENo: Integer; Btn: SmallInt; T: String;
Begin
 DlgPromoForm := False;
 If IsNew Then T := 'Nouvelle promo' Else T := 'Editer promo';
 DlgInit(D, T, 540, 350);
 DlgAddFrame(D, 12, 16, 516, 270, 'Promotion');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Titre    :'); ET  := DlgAddEdit(D, 160, 60,  340, R.Title, 40);
 DlgAddLabel(D, 24, 88,  'ID bout. :'); ETI := DlgAddNumEdit(D, 160, 84, 80,  IntToStrPad(R.TenantID, 0), 6, False);
 DlgAddLabel(D, 24, 112, 'Remise % :'); EDi := DlgAddNumEdit(D, 160, 108, 60, IntToStrPad(R.Discount, 0), 3, False);
 DlgAddLabel(D, 24, 136, 'Debut    :'); ESD := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.StartDate, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Fin      :'); EED := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.EndDate, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Notes    :'); ENo := DlgAddEdit(D, 160, 180, 340, R.Notes, 60);
 DlgAddButton(D, 300, 308, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 308, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Title := D.Ctrls[ET].Text;
 R.TenantID := StrToIntDef(D.Ctrls[ETI].Text, R.TenantID);
 R.Discount := StrToIntDef(D.Ctrls[EDi].Text, R.Discount);
 R.StartDate := StrToIntDef(D.Ctrls[ESD].Text, R.StartDate);
 R.EndDate := StrToIntDef(D.Ctrls[EED].Text, R.EndDate);
 R.Notes := D.Ctrls[ENo].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgPromoForm := True;
End;

Procedure DlgPromoDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= PromoCount) Then Exit;
 DlgInit(D, 'Promo ' + Promos[Idx].Code, 480, 310);
 DlgAddFrame(D, 12, 16, 456, 230, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + Promos[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Titre    : ' + Promos[Idx].Title);
 DlgAddLabel(D, 24, 80,  'Boutique : ' + IntToStrPad(Promos[Idx].TenantID, 0));
 DlgAddLabel(D, 24, 100, 'Remise   : ' + IntToStrPad(Promos[Idx].Discount, 0) + ' %');
 DlgAddLabel(D, 24, 120, 'Debut    : ' + IntToStrPad(Promos[Idx].StartDate, 0));
 DlgAddLabel(D, 24, 140, 'Fin      : ' + IntToStrPad(Promos[Idx].EndDate, 0));
 DlgAddLabel(D, 24, 160, 'Notes    : ' + Promos[Idx].Notes);
 DlgAddButton(D, 380, 270, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgPromoList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TPromo; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To PromoCount - 1 Do
   If Promos[I].Active Then Begin
    S := Promos[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + Promos[I].Title;
    While Length(S) < 41 Do S := S + ' ';
    S := S + IntToStrPad(Promos[I].TenantID, 4) + '  ' +
             IntToStrPad(Promos[I].Discount, 3) + '%  ' +
             IntToStrPad(Promos[I].StartDate, 8);
    BrowseAdd(S, MyKeyPad(Promos[I].Code));
   End;
  Action := ShowDBBrowser('Promotions',
   'Code       Titre                        Bout  Disc%  Debut',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To PromoCount - 1 Do
    If Promos[I].Active And (MyKeyPad(Promos[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextPromoID;
    NR.Discount := 10; NR.StartDate := 20260101; NR.EndDate := 20260131;
    If DlgPromoForm(NR, True) Then Begin
     If PromoCount >= MAX_PROMO Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Promos[PromoCount] := NR; Inc(PromoCount); Inc(NextPromoID);
      B := MyTableInsert(PromoTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgPromoDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Promos[Sel].Active := False;
    B := MyTableDelete(PromoTable, MyKeyPad(Promos[Sel].Code));
    If B Then ShowMessageBox('OK', 'Promo supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgPromoNew;
Var NR: TPromo; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextPromoID;
 NR.Discount := 10; NR.StartDate := 20260101; NR.EndDate := 20260131;
 If Not DlgPromoForm(NR, True) Then Exit;
 If PromoCount >= MAX_PROMO Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Promos[PromoCount] := NR; Inc(PromoCount); Inc(NextPromoID);
 B := MyTableInsert(PromoTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;
Procedure DlgPromoEdit;
Var S: String; I, Idx: Integer; R: TPromo; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer promo', 'Code:', S, 10) Then Exit;
 Idx := -1;
 For I := 0 To PromoCount - 1 Do
  If Promos[I].Active And (Promos[I].Code = S) Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := Promos[Idx];
 If Not DlgPromoForm(R, False) Then Exit;
 Promos[Idx] := R;
 B := MyTableUpdate(PromoTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;
Procedure DlgPromoDel;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Suppr promo', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindPromoByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  Promos[Idx].Active := False;
  B := MyTableDelete(PromoTable, MyKeyPad(Promos[Idx].Code));
  If B Then ShowMessageBox('OK', 'Supprime (PROMO.MYD a jour).')
  Else ShowMessageBox('Avert', 'Supprime en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgPromoActive;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 DlgInit(D, 'Promotions actives', 500, 320);
 Y := 20; N := 0;
 For I := 0 To PromoCount - 1 Do
 Begin
  If Promos[I].Active And (Promos[I].StartDate <= Today) And
     (Promos[I].EndDate >= Today) And (Y < 280) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y,
    Promos[I].Code + ' - ' + Promos[I].Title + ' (' +
    IntToStrPad(Promos[I].Discount, 0) + '%)');
   Y := Y + 14;
  End;
 End;
 DlgAddLabel(D, 16, 290, 'Total actives : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgPromoRpt;
Var D: TDialog; Btn: SmallInt; I, NA, NF: Integer; ATot, Avg: Real; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 NA := 0; NF := 0; ATot := 0;
 For I := 0 To PromoCount - 1 Do
  If Promos[I].Active Then
  Begin
   ATot := ATot + Promos[I].Discount;
   If Promos[I].EndDate >= Today Then NA := NA + 1
   Else NF := NF + 1;
  End;
 If PromoCount > 0 Then Avg := ATot / PromoCount Else Avg := 0;
 DlgInit(D, 'Rapport promotions', 360, 200);
 DlgAddLabel(D, 16, 20, 'Total promotions  : ' + IntToStrPad(PromoCount, 0));
 DlgAddLabel(D, 16, 40, 'Actives           : ' + IntToStrPad(NA, 0));
 DlgAddLabel(D, 16, 60, 'Terminees         : ' + IntToStrPad(NF, 0));
 DlgAddLabel(D, 16, 80, 'Remise moyenne    : ' + RealToStr(Avg, 6, 1) + '%');
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES MAINTENANCE
  ============================================================================ }

Function DlgMaintForm(Var R: TMaintTkt; IsNew: Boolean): Boolean;
Var D: TDialog; EC, ET, EL, EPr, ESt, EOd, ECd, EAs, ENo: Integer; Btn: SmallInt; T: String;
Begin
 DlgMaintForm := False;
 If IsNew Then T := 'Nouveau ticket' Else T := 'Editer ticket';
 DlgInit(D, T, 560, 400);
 DlgAddFrame(D, 12, 16, 536, 320, 'Ticket maintenance');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Titre    :'); ET  := DlgAddEdit(D, 160, 60,  360, R.Title, 40);
 DlgAddLabel(D, 24, 88,  'Lieu     :'); EL  := DlgAddEdit(D, 160, 84,  240, R.Location, 20);
 DlgAddLabel(D, 24, 112, 'Priorite :'); EPr := DlgAddNumEdit(D, 160, 108, 60,  IntToStrPad(R.Priority, 0), 1, False);
 DlgAddLabel(D, 24, 136, 'Statut   :'); ESt := DlgAddNumEdit(D, 160, 132, 60,  IntToStrPad(R.Status, 0), 1, False);
 DlgAddLabel(D, 24, 160, 'Ouvert   :'); EOd := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.OpenDate, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Ferme    :'); ECd := DlgAddNumEdit(D, 160, 180, 100, IntToStrPad(R.CloseDate, 0), 8, False);
 DlgAddLabel(D, 24, 208, 'Assignee :'); EAs := DlgAddEdit(D, 160, 204, 280, R.Assignee, 30);
 DlgAddLabel(D, 24, 232, 'Notes    :'); ENo := DlgAddEdit(D, 160, 228, 360, R.Notes, 80);
 DlgAddButton(D, 320, 356, 100, 'OK',      1, 'O');
 DlgAddButton(D, 436, 356, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Title := D.Ctrls[ET].Text;
 R.Location := D.Ctrls[EL].Text;
 R.Priority := StrToIntDef(D.Ctrls[EPr].Text, R.Priority);
 R.Status   := StrToIntDef(D.Ctrls[ESt].Text, R.Status);
 R.OpenDate := StrToIntDef(D.Ctrls[EOd].Text, R.OpenDate);
 R.CloseDate:= StrToIntDef(D.Ctrls[ECd].Text, R.CloseDate);
 R.Assignee := D.Ctrls[EAs].Text;
 R.Notes := D.Ctrls[ENo].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgMaintForm := True;
End;

Procedure DlgMaintDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= MaintTktCount) Then Exit;
 DlgInit(D, 'Ticket ' + MaintTkts[Idx].Code, 500, 340);
 DlgAddFrame(D, 12, 16, 476, 260, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + MaintTkts[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Titre    : ' + MaintTkts[Idx].Title);
 DlgAddLabel(D, 24, 80,  'Lieu     : ' + MaintTkts[Idx].Location);
 DlgAddLabel(D, 24, 100, 'Priorite : ' + MaintPrioLabel(MaintTkts[Idx].Priority));
 DlgAddLabel(D, 24, 120, 'Statut   : ' + MaintStatusLabel(MaintTkts[Idx].Status));
 DlgAddLabel(D, 24, 140, 'Ouvert   : ' + IntToStrPad(MaintTkts[Idx].OpenDate, 0));
 DlgAddLabel(D, 24, 160, 'Ferme    : ' + IntToStrPad(MaintTkts[Idx].CloseDate, 0));
 DlgAddLabel(D, 24, 180, 'Assignee : ' + MaintTkts[Idx].Assignee);
 DlgAddLabel(D, 24, 200, 'Notes    : ' + MaintTkts[Idx].Notes);
 DlgAddButton(D, 400, 300, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgMaintList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TMaintTkt; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To MaintTktCount - 1 Do
   If MaintTkts[I].Active Then Begin
    S := MaintTkts[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + MaintTkts[I].Title;
    While Length(S) < 41 Do S := S + ' ';
    S := S + MaintTkts[I].Location;
    While Length(S) < 56 Do S := S + ' ';
    S := S + MaintPrioLabel(MaintTkts[I].Priority);
    While Length(S) < 66 Do S := S + ' ';
    S := S + MaintStatusLabel(MaintTkts[I].Status);
    BrowseAdd(S, MyKeyPad(MaintTkts[I].Code));
   End;
  Action := ShowDBBrowser('Tickets maintenance',
   'Code       Titre                        Lieu           Priorite  Statut',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To MaintTktCount - 1 Do
    If MaintTkts[I].Active And (MyKeyPad(MaintTkts[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextMaintID;
    NR.Priority := 2; NR.Status := MS_OPEN;
    NR.OpenDate := 20260101;
    If DlgMaintForm(NR, True) Then Begin
     If MaintTktCount >= MAX_MAINT_TKT Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      MaintTkts[MaintTktCount] := NR; Inc(MaintTktCount); Inc(NextMaintID);
      B := MyTableInsert(MaintTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgMaintDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    MaintTkts[Sel].Active := False;
    B := MyTableDelete(MaintTable, MyKeyPad(MaintTkts[Sel].Code));
    If B Then ShowMessageBox('OK', 'Ticket supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgMaintNew;
Var NR: TMaintTkt; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextMaintID;
 NR.Priority := 2; NR.Status := MS_OPEN; NR.OpenDate := 20260101;
 If Not DlgMaintForm(NR, True) Then Exit;
 If MaintTktCount >= MAX_MAINT_TKT Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 MaintTkts[MaintTktCount] := NR; Inc(MaintTktCount); Inc(NextMaintID);
 B := MyTableInsert(MaintTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgMaintEdit;
Var S: String; I, Idx: Integer; R: TMaintTkt; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer ticket', 'Code:', S, 10) Then Exit;
 Idx := -1;
 For I := 0 To MaintTktCount - 1 Do
  If MaintTkts[I].Active And (MaintTkts[I].Code = S) Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := MaintTkts[Idx];
 If Not DlgMaintForm(R, False) Then Exit;
 MaintTkts[Idx] := R;
 B := MyTableUpdate(MaintTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgMaintClose;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Fermer ticket', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindMaintByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  MaintTkts[Idx].Status := MS_DONE;
  MaintTkts[Idx].CloseDate := 20240101;
  B := MyTableUpdate(MaintTable, MyKeyPad(MaintTkts[Idx].Code), MaintTkts[Idx]);
  If B Then ShowMessageBox('OK', 'Ticket ferme + MAINT.MYD a jour.')
  Else ShowMessageBox('Avert', 'Ferme en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgMaintOpen;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer;
Begin
 DlgInit(D, 'Tickets ouverts', 500, 320);
 Y := 20; N := 0;
 For I := 0 To MaintTktCount - 1 Do
 Begin
  If MaintTkts[I].Active And ((MaintTkts[I].Status = MS_OPEN) Or
                              (MaintTkts[I].Status = MS_INPROG)) And (Y < 280) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y, MaintTkts[I].Code + ' - ' + MaintTkts[I].Title +
    ' [' + MaintPrioLabel(MaintTkts[I].Priority) + ']');
   Y := Y + 14;
  End;
 End;
 DlgAddLabel(D, 16, 290, 'Total : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgMaintRpt;
Var D: TDialog; Btn: SmallInt; I, NO, NI, ND: Integer;
Begin
 NO := 0; NI := 0; ND := 0;
 For I := 0 To MaintTktCount - 1 Do
  If MaintTkts[I].Active Then
  Begin
   If MaintTkts[I].Status = MS_OPEN   Then NO := NO + 1;
   If MaintTkts[I].Status = MS_INPROG Then NI := NI + 1;
   If MaintTkts[I].Status = MS_DONE   Then ND := ND + 1;
  End;
 DlgInit(D, 'Rapport maintenance', 360, 200);
 DlgAddLabel(D, 16, 20, 'Total tickets : ' + IntToStrPad(MaintTktCount, 0));
 DlgAddLabel(D, 16, 40, 'Ouverts       : ' + IntToStrPad(NO, 0));
 DlgAddLabel(D, 16, 60, 'En cours      : ' + IntToStrPad(NI, 0));
 DlgAddLabel(D, 16, 80, 'Termines      : ' + IntToStrPad(ND, 0));
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  DIALOGUES NETTOYAGE
  ============================================================================ }

Function DlgCleanForm(Var R: TCleanTask; IsNew: Boolean): Boolean;
Var D: TDialog; EA, EF, ESt, ELd, END_, EAs: Integer; Btn: SmallInt; T: String;
Begin
 DlgCleanForm := False;
 If IsNew Then T := 'Nouvelle tache' Else T := 'Editer tache';
 DlgInit(D, T, 520, 340);
 DlgAddFrame(D, 12, 16, 496, 250, 'Tache nettoyage');
 DlgAddLabel(D, 24, 40,  'Zone     :'); EA   := DlgAddEdit(D, 160, 36,  320, R.Area, 30);
 DlgAddLabel(D, 24, 64,  'Frequenc.:'); EF   := DlgAddEdit(D, 160, 60,  200, R.Frequency, 15);
 DlgAddLabel(D, 24, 88,  'Statut   :'); ESt  := DlgAddNumEdit(D, 160, 84, 60, IntToStrPad(R.Status, 0), 1, False);
 DlgAddLabel(D, 24, 112, 'Dernier  :'); ELd  := DlgAddNumEdit(D, 160, 108, 100, IntToStrPad(R.LastDone, 0), 8, False);
 DlgAddLabel(D, 24, 136, 'Prochain :'); END_ := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.NextDue, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Assignee :'); EAs  := DlgAddEdit(D, 160, 156, 320, R.Assignee, 30);
 DlgAddButton(D, 280, 290, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 290, 100, 'Annuler',-1, 'A');
 D.Focus := EA;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Area := D.Ctrls[EA].Text; R.Frequency := D.Ctrls[EF].Text;
 R.Status   := StrToIntDef(D.Ctrls[ESt].Text, R.Status);
 R.LastDone := StrToIntDef(D.Ctrls[ELd].Text, R.LastDone);
 R.NextDue  := StrToIntDef(D.Ctrls[END_].Text, R.NextDue);
 R.Assignee := D.Ctrls[EAs].Text;
 If R.Area = '' Then Begin ShowMessageBox('Err', 'Zone obligatoire.'); Exit; End;
 DlgCleanForm := True;
End;

Procedure DlgCleanDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= CleanTaskCount) Then Exit;
 DlgInit(D, 'Tache #' + IntToStrPad(CleanTasks[Idx].ID, 0), 480, 300);
 DlgAddFrame(D, 12, 16, 456, 220, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID       : ' + IntToStrPad(CleanTasks[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Zone     : ' + CleanTasks[Idx].Area);
 DlgAddLabel(D, 24, 80,  'Frequenc.: ' + CleanTasks[Idx].Frequency);
 DlgAddLabel(D, 24, 100, 'Statut   : ' + CleanStatusLabel(CleanTasks[Idx].Status));
 DlgAddLabel(D, 24, 120, 'Dernier  : ' + IntToStrPad(CleanTasks[Idx].LastDone, 0));
 DlgAddLabel(D, 24, 140, 'Prochain : ' + IntToStrPad(CleanTasks[Idx].NextDue, 0));
 DlgAddLabel(D, 24, 160, 'Assignee : ' + CleanTasks[Idx].Assignee);
 DlgAddButton(D, 380, 260, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgCleanList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TCleanTask; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To CleanTaskCount - 1 Do
   If CleanTasks[I].Active Then Begin
    S := IntToStrPad(CleanTasks[I].ID, 4) + '  ' + CleanTasks[I].Area;
    While Length(S) < 39 Do S := S + ' ';
    S := S + CleanTasks[I].Frequency;
    While Length(S) < 55 Do S := S + ' ';
    S := S + CleanStatusLabel(CleanTasks[I].Status);
    While Length(S) < 65 Do S := S + ' ';
    S := S + CleanTasks[I].Assignee;
    BrowseAdd(S, MyKeyFromID('C', CleanTasks[I].ID));
   End;
  Action := ShowDBBrowser('Taches nettoyage',
   'ID    Zone                          Frequence       Statut    Assignee',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To CleanTaskCount - 1 Do
    If CleanTasks[I].Active And (MyKeyFromID('C', CleanTasks[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextCleanID;
    NR.Status := CS_TODO; NR.NextDue := 20260101;
    If DlgCleanForm(NR, True) Then Begin
     If CleanTaskCount >= MAX_CLEAN_TASK Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      CleanTasks[CleanTaskCount] := NR; Inc(CleanTaskCount); Inc(NextCleanID);
      B := MyTableInsert(CleanTable, MyKeyFromID('C', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgCleanDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    CleanTasks[Sel].Active := False;
    B := MyTableDelete(CleanTable, MyKeyFromID('C', CleanTasks[Sel].ID));
    If B Then ShowMessageBox('OK', 'Tache supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgCleanNew;
Var NR: TCleanTask; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextCleanID;
 NR.Status := CS_TODO; NR.NextDue := 20260101;
 If Not DlgCleanForm(NR, True) Then Exit;
 If CleanTaskCount >= MAX_CLEAN_TASK Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 CleanTasks[CleanTaskCount] := NR; Inc(CleanTaskCount); Inc(NextCleanID);
 B := MyTableInsert(CleanTable, MyKeyFromID('C', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgCleanEdit;
Var S: String; I, Idx: Integer; ID: LongInt; R: TCleanTask; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer tache', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := -1;
 For I := 0 To CleanTaskCount - 1 Do
  If CleanTasks[I].Active And (CleanTasks[I].ID = ID) Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := CleanTasks[Idx];
 If Not DlgCleanForm(R, False) Then Exit;
 CleanTasks[Idx] := R;
 B := MyTableUpdate(CleanTable, MyKeyFromID('C', R.ID), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgCleanDone;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Tache faite', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindCleanByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  CleanTasks[Idx].Status := CS_DONE;
  CleanTasks[Idx].LastDone := 20240101;
  B := MyTableUpdate(CleanTable, MyKeyFromID('C', CleanTasks[Idx].ID), CleanTasks[Idx]);
  If B Then ShowMessageBox('OK', 'Marque faite + CLEAN.MYD a jour.')
  Else ShowMessageBox('Avert', 'Mis a jour en RAM, .MYD non modifie.');
 End;
End;

Procedure DlgCleanRpt;
Var D: TDialog; Btn: SmallInt; I, NT, ND, NS: Integer;
Begin
 NT := 0; ND := 0; NS := 0;
 For I := 0 To CleanTaskCount - 1 Do
  If CleanTasks[I].Active Then
  Begin
   If CleanTasks[I].Status = CS_TODO Then NT := NT + 1;
   If CleanTasks[I].Status = CS_DONE Then ND := ND + 1;
   If CleanTasks[I].Status = CS_SKIP Then NS := NS + 1;
  End;
 DlgInit(D, 'Rapport nettoyage', 360, 200);
 DlgAddLabel(D, 16, 20, 'Total taches : ' + IntToStrPad(CleanTaskCount, 0));
 DlgAddLabel(D, 16, 40, 'A faire      : ' + IntToStrPad(NT, 0));
 DlgAddLabel(D, 16, 60, 'Faites       : ' + IntToStrPad(ND, 0));
 DlgAddLabel(D, 16, 80, 'Reportees    : ' + IntToStrPad(NS, 0));
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

{ ============================================================================
  TABLEAU DE BORD
  ============================================================================ }

Procedure DlgMallDash;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Tableau de bord MALL', 480, 320);
 DlgAddLabel(D, 16, 20, '=== Mall Management System ===');
 DlgAddLabel(D, 16, 40, 'Boutiques actives      : ' + IntToStrPad(CountActiveTenants, 0));
 DlgAddLabel(D, 16, 60, 'Stalls vacants         : ' + IntToStrPad(CountVacantStalls, 0));
 DlgAddLabel(D, 16, 80, 'Baux actifs            : ' + IntToStrPad(CountActiveLeases, 0));
 DlgAddLabel(D, 16, 100, 'Revenu mensuel total   : ' + RealToStr(SumMonthlyRevenue, 10, 2));
 DlgAddLabel(D, 16, 120, 'Loyer encaisse         : ' + RealToStr(SumRentPaid, 10, 2));
 DlgAddLabel(D, 16, 140, 'Vendeurs food court    : ' + IntToStrPad(FoodVCount, 0));
 DlgAddLabel(D, 16, 160, 'Items au menu          : ' + IntToStrPad(FoodMCount, 0));
 DlgAddLabel(D, 16, 180, 'Ventes du jour         : ' + RealToStr(SumFoodSalesToday, 10, 2));
 DlgAddLabel(D, 16, 200, 'Evenements planifies   : ' + IntToStrPad(MallEvtCount, 0));
 DlgAddLabel(D, 16, 220, 'Promotions             : ' + IntToStrPad(PromoCount, 0));
 DlgAddLabel(D, 16, 240, 'Tickets maint. ouverts : ' + IntToStrPad(CountOpenMaint, 0));
 DlgAddLabel(D, 16, 260, 'Taches nettoyage       : ' + IntToStrPad(CleanTaskCount, 0));
 DlgAddButton(D, 380, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgMallOccupancy;
Var D: TDialog; Btn: SmallInt; I, N1, N2: Integer;
Begin
 N1 := 0; N2 := 0;
 For I := 0 To TenantCount - 1 Do
  If Tenants[I].Active Then
   If Tenants[I].Floor = 1 Then N1 := N1 + 1
   Else N2 := N2 + 1;
 DlgInit(D, 'Occupation', 360, 200);
 DlgAddLabel(D, 16, 20, 'Etage 1 : ' + IntToStrPad(N1, 0) + ' boutiques');
 DlgAddLabel(D, 16, 40, 'Etage 2 : ' + IntToStrPad(N2, 0) + ' boutiques');
 DlgAddLabel(D, 16, 60, 'Total   : ' + IntToStrPad(N1 + N2, 0));
 DlgAddLabel(D, 16, 80, 'Vacants : ' + IntToStrPad(CountVacantStalls, 0));
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgMallRevenue;
Var D: TDialog; Btn: SmallInt; M, A: Real;
Begin
 M := SumMonthlyRevenue;
 A := M * 12;
 DlgInit(D, 'Revenus', 360, 200);
 DlgAddLabel(D, 16, 20, 'Loyer mensuel total      : ' + RealToStr(M, 10, 2));
 DlgAddLabel(D, 16, 40, 'Projection annuelle      : ' + RealToStr(A, 10, 2));
 DlgAddLabel(D, 16, 60, 'Encaisse a ce jour       : ' + RealToStr(SumRentPaid, 10, 2));
 DlgAddLabel(D, 16, 80, 'Ventes food court (jour) : ' + RealToStr(SumFoodSalesToday, 10, 2));
 DlgAddButton(D, 260, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;

Procedure DlgMallAbout;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'A propos', 380, 220);
 DlgAddLabel(D, 16, 20, 'MALL Management System');
 DlgAddLabel(D, 16, 40, 'Centre commercial - gestion complete');
 DlgAddLabel(D, 16, 60, 'Boutiques, baux, loyers');
 DlgAddLabel(D, 16, 80, 'Food court, ventes');
 DlgAddLabel(D, 16, 100, 'Evenements, promotions');
 DlgAddLabel(D, 16, 120, 'Maintenance, nettoyage');
 DlgAddLabel(D, 16, 140, 'Securite (gardes, incidents, CCTV)');
 DlgAddLabel(D, 16, 160, 'Base sur le framework PARKING.PAS.');
 DlgAddButton(D, 280, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
 End;
{ === END MALL_INC_X_HAND.TXT === }
{ === BEGIN MALL_INC_Y_HAND.TXT === }
{ ============================================================================
  MALL_INC_Y_HAND.TXT
  Module 2 hand-crafted (PARKING.PAS API) - Centre commercial extensions.
  Couvre : Membres fidelite, Inventaire general, Personnel, Campagnes
           marketing, Trafic visiteurs, Rapports journaliers.
  ============================================================================ }

Const
 MAX_LOYALTY      = 500;
 MAX_INVENTORY    = 400;
 MAX_MALL_STAFF   = 100;
 MAX_CAMPAIGN     = 80;
 MAX_TRAFFIC      = 200;
 MAX_DAYREPORT    = 200;
 MAX_FEEDBACK     = 200;
 MAX_PARKING_EVT  = 300;

 { Tags 5700-5799 Loyalty, 5800-5899 Inventaire, 5900-5999 Staff,
       5710-5719 Campagnes, 5720-5729 Trafic, 5730-5739 Rapports/Feedback }
 TAG_LOY_LIST     = 5700;
 TAG_LOY_NEW      = 5701;
 TAG_LOY_EDIT     = 5702;
 TAG_LOY_DEL      = 5703;
 TAG_LOY_PTS      = 5704;
 TAG_LOY_TOP      = 5705;
 TAG_LOY_RPT      = 5706;
 TAG_LOY_ANNI     = 5707;

 TAG_CAMP_LIST    = 5710;
 TAG_CAMP_NEW     = 5711;
 TAG_CAMP_EDIT    = 5712;
 TAG_CAMP_DEL     = 5713;
 TAG_CAMP_ACT     = 5714;
 TAG_CAMP_RPT     = 5715;

 TAG_TRF_LIST     = 5720;
 TAG_TRF_REC      = 5721;
 TAG_TRF_TODAY    = 5722;
 TAG_TRF_WEEK     = 5723;
 TAG_TRF_RPT      = 5724;
 TAG_TRF_PEAK     = 5725;

 TAG_FB_LIST      = 5730;
 TAG_FB_NEW       = 5731;
 TAG_FB_RESP      = 5732;
 TAG_FB_RPT       = 5733;

 TAG_INV2_LIST    = 5800;
 TAG_INV2_NEW     = 5801;
 TAG_INV2_EDIT    = 5802;
 TAG_INV2_DEL     = 5803;
 TAG_INV2_LOW     = 5804;
 TAG_INV2_RPT     = 5805;
 TAG_INV2_REORD   = 5806;

 TAG_STF_LIST     = 5900;
 TAG_STF_NEW      = 5901;
 TAG_STF_EDIT     = 5902;
 TAG_STF_DEL      = 5903;
 TAG_STF_SCHED    = 5904;
 TAG_STF_RPT      = 5905;

 TAG_DR_LIST      = 5740;
 TAG_DR_GEN       = 5741;
 TAG_DR_VIEW      = 5742;
 TAG_DR_EXPORT    = 5743;

 { Tiers fidelite }
 LT_BRONZE = 1;
 LT_SILVER = 2;
 LT_GOLD   = 3;
 LT_PLAT   = 4;

 { Types de campagne }
 CMP_PRINT  = 1;
 CMP_RADIO  = 2;
 CMP_TV     = 3;
 CMP_DIGITAL = 4;
 CMP_SOCIAL = 5;
 CMP_OUTDOOR = 6;
 CMP_OTHER  = 99;

 { Etat de campagne }
 CST_PLAN   = 0;
 CST_RUN    = 1;
 CST_DONE   = 2;
 CST_CANCEL = 3;

 { Categories d inventaire }
 IC_CLEAN    = 1;
 IC_OFFICE   = 2;
 IC_TECH     = 3;
 IC_SECURITY = 4;
 IC_MAINT    = 5;
 IC_PROMO    = 6;
 IC_OTHER    = 99;

 { Roles staff }
 SR_MANAGER  = 1;
 SR_ASSIST   = 2;
 SR_RECEPT   = 3;
 SR_MAINT2   = 4;
 SR_SECURITY2 = 5;
 SR_CLEANER  = 6;
 SR_ADMIN    = 7;
 SR_OTHER    = 99;

 { Notation feedback }
 FBR_BAD     = 1;
 FBR_AVG     = 2;
 FBR_GOOD    = 3;
 FBR_EXC     = 4;

Type
 TLoyalty = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  CardNo     : String[12];
  FirstName  : String[20];
  LastName   : String[20];
  Email      : String[40];
  Phone      : String[20];
  JoinDate   : LongInt;
  Tier       : Byte;
  Points     : LongInt;
  Birthday   : LongInt;
  Visits     : LongInt;
 End;

 TInventory2 = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[12];
  Name       : String[40];
  Category   : Byte;
  UM         : String[6];
  Qty        : LongInt;
  ReorderPt  : LongInt;
  UnitCost   : Real;
  Supplier   : String[30];
  LastReorder: LongInt;
 End;

 TMallStaff = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  FirstName  : String[20];
  LastName   : String[20];
  Role       : Byte;
  Phone      : String[20];
  Email      : String[40];
  HireDate   : LongInt;
  Schedule   : String[20];
  Salary     : Real;
 End;

 TCampaign = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Title      : String[40];
  Kind       : Byte;
  Status     : Byte;
  StartDate  : LongInt;
  EndDate    : LongInt;
  Budget     : Real;
  Reach      : LongInt;
  Notes      : String[60];
 End;

 TTrafficRec = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  RecDate    : LongInt;
  Hour       : Byte;
  Entrance   : String[15];
  Count      : LongInt;
 End;

 TFeedback = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  RecDate    : LongInt;
  Source     : String[20];
  Rating     : Byte;
  Comment    : String[80];
  Responded  : Boolean;
 End;

 TDayReport = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  RDate      : LongInt;
  Visitors   : LongInt;
  Revenue    : Real;
  Incidents  : Integer;
  Maint      : Integer;
  Sales      : Real;
 End;

Var
 LoyMembers   : Array[0..MAX_LOYALTY-1] Of TLoyalty;
 LoyCount     : Integer;
 NextLoyID    : LongInt;

 Inventory2   : Array[0..MAX_INVENTORY-1] Of TInventory2;
 Inv2Count    : Integer;
 NextInv2ID   : LongInt;

 MallStaff    : Array[0..MAX_MALL_STAFF-1] Of TMallStaff;
 StaffCount   : Integer;
 NextStaffID  : LongInt;

 Campaigns    : Array[0..MAX_CAMPAIGN-1] Of TCampaign;
 CampCount    : Integer;
 NextCampID   : LongInt;

 Traffic      : Array[0..MAX_TRAFFIC-1] Of TTrafficRec;
 TrafficCount : Integer;
 NextTrfID    : LongInt;

 Feedback     : Array[0..MAX_FEEDBACK-1] Of TFeedback;
 FBCount      : Integer;
 NextFBID     : LongInt;

 DayReports   : Array[0..MAX_DAYREPORT-1] Of TDayReport;
 DRCount      : Integer;
 NextDRID     : LongInt;

 { ===== Tables MyISAM persistantes ===== }
 LoyTable     : TMyTable;
 Inv2Table    : TMyTable;
 StaffTable   : TMyTable;
 CampTable    : TMyTable;
 TrfTable     : TMyTable;
 FBTable      : TMyTable;
 DRTable      : TMyTable;
 MallSeedY    : Boolean;

{ ============================================================================
  FORWARDS
  ============================================================================ }












{ ============================================================================
  LABELS
  ============================================================================ }

Function LoyTierLabel(T: Byte): String;
Begin
 Case T Of
  LT_BRONZE: LoyTierLabel := 'Bronze';
  LT_SILVER: LoyTierLabel := 'Argent';
  LT_GOLD  : LoyTierLabel := 'Or';
  LT_PLAT  : LoyTierLabel := 'Platine';
 Else
  LoyTierLabel := '?';
 End;
End;

Function CampKindLabel(K: Byte): String;
Begin
 Case K Of
  CMP_PRINT  : CampKindLabel := 'Print';
  CMP_RADIO  : CampKindLabel := 'Radio';
  CMP_TV     : CampKindLabel := 'TV';
  CMP_DIGITAL: CampKindLabel := 'Digital';
  CMP_SOCIAL : CampKindLabel := 'Social';
  CMP_OUTDOOR: CampKindLabel := 'Affich.';
 Else
  CampKindLabel := 'Autre';
 End;
End;

Function CampStatusLabel(S: Byte): String;
Begin
 Case S Of
  CST_PLAN  : CampStatusLabel := 'Planif.';
  CST_RUN   : CampStatusLabel := 'En cours';
  CST_DONE  : CampStatusLabel := 'Termine';
  CST_CANCEL: CampStatusLabel := 'Annule';
 Else
  CampStatusLabel := '?';
 End;
End;

Function InvCatLabel(C: Byte): String;
Begin
 Case C Of
  IC_CLEAN   : InvCatLabel := 'Nettoyage';
  IC_OFFICE  : InvCatLabel := 'Bureau';
  IC_TECH    : InvCatLabel := 'Tech';
  IC_SECURITY: InvCatLabel := 'Securite';
  IC_MAINT   : InvCatLabel := 'Maint.';
  IC_PROMO   : InvCatLabel := 'Promo';
 Else
  InvCatLabel := 'Autre';
 End;
End;

Function StaffRoleLabel2(R: Byte): String;
Begin
 Case R Of
  SR_MANAGER   : StaffRoleLabel2 := 'Direction';
  SR_ASSIST    : StaffRoleLabel2 := 'Asst.';
  SR_RECEPT    : StaffRoleLabel2 := 'Accueil';
  SR_MAINT2    : StaffRoleLabel2 := 'Maint.';
  SR_SECURITY2 : StaffRoleLabel2 := 'Securite';
  SR_CLEANER   : StaffRoleLabel2 := 'Nettoyeur';
  SR_ADMIN     : StaffRoleLabel2 := 'Admin';
 Else
  StaffRoleLabel2 := 'Autre';
 End;
End;

Function FBRatingLabel(R: Byte): String;
Begin
 Case R Of
  FBR_BAD : FBRatingLabel := 'Mauvais';
  FBR_AVG : FBRatingLabel := 'Moyen';
  FBR_GOOD: FBRatingLabel := 'Bon';
  FBR_EXC : FBRatingLabel := 'Excellent';
 Else
  FBRatingLabel := '?';
 End;
End;

{ ============================================================================
  RECHERCHES
  ============================================================================ }

Function FindLoyByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindLoyByID := -1;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active And (LoyMembers[I].ID = ID) Then
  Begin
   FindLoyByID := I;
   Exit;
  End;
End;

Function FindLoyByCard(Const C: String): Integer;
Var I: Integer;
Begin
 FindLoyByCard := -1;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active And (LoyMembers[I].CardNo = C) Then
  Begin
   FindLoyByCard := I;
   Exit;
  End;
End;

Function FindInv2ByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindInv2ByID := -1;
 For I := 0 To Inv2Count - 1 Do
  If Inventory2[I].Active And (Inventory2[I].ID = ID) Then
  Begin
   FindInv2ByID := I;
   Exit;
  End;
End;

Function FindInv2ByCode(Const C: String): Integer;
Var I: Integer;
Begin
 FindInv2ByCode := -1;
 For I := 0 To Inv2Count - 1 Do
  If Inventory2[I].Active And (Inventory2[I].Code = C) Then
  Begin
   FindInv2ByCode := I;
   Exit;
  End;
End;

Function FindStaffByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindStaffByID := -1;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active And (MallStaff[I].ID = ID) Then
  Begin
   FindStaffByID := I;
   Exit;
  End;
End;

Function FindStaffByCode2(Const C: String): Integer;
Var I: Integer;
Begin
 FindStaffByCode2 := -1;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active And (MallStaff[I].Code = C) Then
  Begin
   FindStaffByCode2 := I;
   Exit;
  End;
End;

Function FindCampByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindCampByID := -1;
 For I := 0 To CampCount - 1 Do
  If Campaigns[I].Active And (Campaigns[I].ID = ID) Then
  Begin
   FindCampByID := I;
   Exit;
  End;
End;

Function FindTrfByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindTrfByID := -1;
 For I := 0 To TrafficCount - 1 Do
  If Traffic[I].Active And (Traffic[I].ID = ID) Then
  Begin
   FindTrfByID := I;
   Exit;
  End;
End;

Function FindFBByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindFBByID := -1;
 For I := 0 To FBCount - 1 Do
  If Feedback[I].Active And (Feedback[I].ID = ID) Then
  Begin
   FindFBByID := I;
   Exit;
  End;
End;

Function FindDRByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindDRByID := -1;
 For I := 0 To DRCount - 1 Do
  If DayReports[I].Active And (DayReports[I].ID = ID) Then
  Begin
   FindDRByID := I;
   Exit;
  End;
End;

Function FindDRByDate(D: LongInt): Integer;
Var I: Integer;
Begin
 FindDRByDate := -1;
 For I := 0 To DRCount - 1 Do
  If DayReports[I].Active And (DayReports[I].RDate = D) Then
  Begin
   FindDRByDate := I;
   Exit;
  End;
End;

{ ============================================================================
  STATISTIQUES
  ============================================================================ }

Function CountActiveLoyalty: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active Then N := N + 1;
 CountActiveLoyalty := N;
End;

Function CountTier(T: Byte): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active And (LoyMembers[I].Tier = T) Then N := N + 1;
 CountTier := N;
End;

Function SumLoyaltyPoints: LongInt;
Var I: Integer; S: LongInt;
Begin
 S := 0;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active Then S := S + LoyMembers[I].Points;
 SumLoyaltyPoints := S;
End;

Function CountLowInv2: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To Inv2Count - 1 Do
  If Inventory2[I].Active And (Inventory2[I].Qty <= Inventory2[I].ReorderPt) Then
   N := N + 1;
 CountLowInv2 := N;
End;

Function SumInv2Value: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To Inv2Count - 1 Do
  If Inventory2[I].Active Then S := S + Inventory2[I].Qty * Inventory2[I].UnitCost;
 SumInv2Value := S;
End;

Function CountActiveStaff: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active Then N := N + 1;
 CountActiveStaff := N;
End;

Function SumPayroll: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active Then S := S + MallStaff[I].Salary;
 SumPayroll := S;
End;

Function CountRunningCampaigns: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To CampCount - 1 Do
  If Campaigns[I].Active And (Campaigns[I].Status = CST_RUN) Then
   N := N + 1;
 CountRunningCampaigns := N;
End;

Function SumCampBudget: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To CampCount - 1 Do
  If Campaigns[I].Active Then S := S + Campaigns[I].Budget;
 SumCampBudget := S;
End;

Function SumTrafficToday: LongInt;
Var I: Integer; S: LongInt; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 S := 0;
 For I := 0 To TrafficCount - 1 Do
  If Traffic[I].Active And (Traffic[I].RecDate = Today) Then
   S := S + Traffic[I].Count;
 SumTrafficToday := S;
End;

Function AvgFeedback: Real;
Var I, N: Integer; S: LongInt;
Begin
 S := 0; N := 0;
 For I := 0 To FBCount - 1 Do
  If Feedback[I].Active Then
  Begin
   S := S + Feedback[I].Rating;
   N := N + 1;
  End;
 If N > 0 Then AvgFeedback := S / N Else AvgFeedback := 0;
End;

{ ============================================================================
  INITIALISATION ET SEEDS
  ============================================================================ }

{ ============================================================================
  Persistance MyISAM module Y
  ============================================================================ }

Procedure LoadLoyaltyFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TLoyalty;
Begin
 N := MyTableIndexCount(LoyTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(LoyTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(LoyTable, E.DataOfs, R) Then
    If LoyCount < MAX_LOYALTY Then Begin
     LoyMembers[LoyCount] := R;
     LoyMembers[LoyCount].Active := True;
     If R.ID >= NextLoyID Then NextLoyID := R.ID + 1;
     Inc(LoyCount);
    End;
End;

Procedure LoadInv2FromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TInventory2;
Begin
 N := MyTableIndexCount(Inv2Table);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(Inv2Table, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(Inv2Table, E.DataOfs, R) Then
    If Inv2Count < MAX_INVENTORY Then Begin
     Inventory2[Inv2Count] := R;
     Inventory2[Inv2Count].Active := True;
     If R.ID >= NextInv2ID Then NextInv2ID := R.ID + 1;
     Inc(Inv2Count);
    End;
End;

Procedure LoadStaffFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TMallStaff;
Begin
 N := MyTableIndexCount(StaffTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(StaffTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(StaffTable, E.DataOfs, R) Then
    If StaffCount < MAX_MALL_STAFF Then Begin
     MallStaff[StaffCount] := R;
     MallStaff[StaffCount].Active := True;
     If R.ID >= NextStaffID Then NextStaffID := R.ID + 1;
     Inc(StaffCount);
    End;
End;

Procedure LoadCampFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TCampaign;
Begin
 N := MyTableIndexCount(CampTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(CampTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(CampTable, E.DataOfs, R) Then
    If CampCount < MAX_CAMPAIGN Then Begin
     Campaigns[CampCount] := R;
     Campaigns[CampCount].Active := True;
     If R.ID >= NextCampID Then NextCampID := R.ID + 1;
     Inc(CampCount);
    End;
End;

Procedure LoadTrfFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TTrafficRec;
Begin
 N := MyTableIndexCount(TrfTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(TrfTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(TrfTable, E.DataOfs, R) Then
    If TrafficCount < MAX_TRAFFIC Then Begin
     Traffic[TrafficCount] := R;
     Traffic[TrafficCount].Active := True;
     If R.ID >= NextTrfID Then NextTrfID := R.ID + 1;
     Inc(TrafficCount);
    End;
End;

Procedure LoadFBFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TFeedback;
Begin
 N := MyTableIndexCount(FBTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(FBTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(FBTable, E.DataOfs, R) Then
    If FBCount < MAX_FEEDBACK Then Begin
     Feedback[FBCount] := R;
     Feedback[FBCount].Active := True;
     If R.ID >= NextFBID Then NextFBID := R.ID + 1;
     Inc(FBCount);
    End;
End;

Procedure LoadDRFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TDayReport;
Begin
 N := MyTableIndexCount(DRTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(DRTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(DRTable, E.DataOfs, R) Then
    If DRCount < MAX_DAYREPORT Then Begin
     DayReports[DRCount] := R;
     DayReports[DRCount].Active := True;
     If R.ID >= NextDRID Then NextDRID := R.ID + 1;
     Inc(DRCount);
    End;
End;

Procedure BulkPersistLoyalty;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To LoyCount - 1 Do
  B := MyTableInsert(LoyTable, MyKeyPad(LoyMembers[I].CardNo), LoyMembers[I]);
End;

Procedure BulkPersistInv2;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To Inv2Count - 1 Do
  B := MyTableInsert(Inv2Table, MyKeyPad(Inventory2[I].Code), Inventory2[I]);
End;

Procedure BulkPersistStaff;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To StaffCount - 1 Do
  B := MyTableInsert(StaffTable, MyKeyPad(MallStaff[I].Code), MallStaff[I]);
End;

Procedure BulkPersistCamp;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To CampCount - 1 Do
  B := MyTableInsert(CampTable, MyKeyPad(Campaigns[I].Code), Campaigns[I]);
End;

Procedure BulkPersistTrf;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To TrafficCount - 1 Do
  B := MyTableInsert(TrfTable, MyKeyFromID('T', Traffic[I].ID), Traffic[I]);
End;

Procedure BulkPersistFB;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To FBCount - 1 Do
  B := MyTableInsert(FBTable, MyKeyFromID('F', Feedback[I].ID), Feedback[I]);
End;

Procedure BulkPersistDR;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To DRCount - 1 Do
  B := MyTableInsert(DRTable, MyKeyFromID('D', DayReports[I].ID), DayReports[I]);
End;

Procedure InitMallExt2;
Var Bootstrap: Boolean;
Begin
 LoyCount := 0; NextLoyID := 1;
 Inv2Count := 0; NextInv2ID := 1;
 StaffCount := 0; NextStaffID := 1;
 CampCount := 0; NextCampID := 1;
 TrafficCount := 0; NextTrfID := 1;
 FBCount := 0; NextFBID := 1;
 DRCount := 0; NextDRID := 1;

 MyTableInit(LoyTable,   'LOYALTY', SizeOf(TLoyalty));
 MyTableInit(Inv2Table,  'INVENT',  SizeOf(TInventory2));
 MyTableInit(StaffTable, 'STAFF',   SizeOf(TMallStaff));
 MyTableInit(CampTable,  'CAMPAGN', SizeOf(TCampaign));
 MyTableInit(TrfTable,   'TRAFFIC', SizeOf(TTrafficRec));
 MyTableInit(FBTable,    'FEEDBK',  SizeOf(TFeedback));
 MyTableInit(DRTable,    'DAYRPT',  SizeOf(TDayReport));

 Bootstrap := Not (MyTableExists('LOYALTY') And MyTableExists('INVENT') And
                   MyTableExists('STAFF')   And MyTableExists('CAMPAGN') And
                   MyTableExists('TRAFFIC') And MyTableExists('FEEDBK')  And
                   MyTableExists('DAYRPT'));
 If Bootstrap Then Begin
  MyTableCreate(LoyTable);   MyTableCreate(Inv2Table);
  MyTableCreate(StaffTable); MyTableCreate(CampTable);
  MyTableCreate(TrfTable);   MyTableCreate(FBTable);
  MyTableCreate(DRTable);
 End;

 { Bootstrap : tables creees vides, peuplees par l utilisateur via les
   dialogues. Aucun seed hardcode. }

 If Bootstrap Then Begin
  { rien }
 End Else Begin
  LoyCount := 0;     NextLoyID := 1;
  Inv2Count := 0;    NextInv2ID := 1;
  StaffCount := 0;   NextStaffID := 1;
  CampCount := 0;    NextCampID := 1;
  TrafficCount := 0; NextTrfID := 1;
  FBCount := 0;      NextFBID := 1;
  DRCount := 0;      NextDRID := 1;
  LoadLoyaltyFromDB; LoadInv2FromDB;
  LoadStaffFromDB;   LoadCampFromDB;
  LoadTrfFromDB;     LoadFBFromDB;
  LoadDRFromDB;
 End;
End;

Function DlgLoyForm(Var R: TLoyalty; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EF, EL, EM, EP, EJ, ET, EPt, EB: Integer; Btn: SmallInt; T: String;
Begin
 DlgLoyForm := False;
 If IsNew Then T := 'Nouveau membre' Else T := 'Editer membre';
 DlgInit(D, T, 560, 400);
 DlgAddFrame(D, 12, 16, 536, 320, 'Membre fidelite');
 DlgAddLabel(D, 24, 40,  'Carte    :'); EC := DlgAddEdit(D, 160, 36,  140, R.CardNo, 12);
 DlgAddLabel(D, 24, 64,  'Prenom   :'); EF := DlgAddEdit(D, 160, 60,  220, R.FirstName, 20);
 DlgAddLabel(D, 24, 88,  'Nom      :'); EL := DlgAddEdit(D, 160, 84,  220, R.LastName, 20);
 DlgAddLabel(D, 24, 112, 'Email    :'); EM := DlgAddEdit(D, 160, 108, 340, R.Email, 40);
 DlgAddLabel(D, 24, 136, 'Tel      :'); EP := DlgAddEdit(D, 160, 132, 220, R.Phone, 20);
 DlgAddLabel(D, 24, 160, 'Inscrit  :'); EJ := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.JoinDate, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Tier     :'); ET := DlgAddNumEdit(D, 160, 180, 60,  IntToStrPad(R.Tier, 0), 1, False);
 DlgAddLabel(D, 24, 208, 'Points   :'); EPt:= DlgAddNumEdit(D, 160, 204, 100, IntToStrPad(R.Points, 0), 8, False);
 DlgAddLabel(D, 24, 232, 'Anniv.   :'); EB := DlgAddNumEdit(D, 160, 228, 100, IntToStrPad(R.Birthday, 0), 8, False);
 DlgAddButton(D, 320, 356, 100, 'OK',      1, 'O');
 DlgAddButton(D, 436, 356, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.CardNo := D.Ctrls[EC].Text; R.FirstName := D.Ctrls[EF].Text;
 R.LastName := D.Ctrls[EL].Text; R.Email := D.Ctrls[EM].Text;
 R.Phone := D.Ctrls[EP].Text;
 R.JoinDate := StrToIntDef(D.Ctrls[EJ].Text, R.JoinDate);
 R.Tier := StrToIntDef(D.Ctrls[ET].Text, R.Tier);
 R.Points := StrToIntDef(D.Ctrls[EPt].Text, R.Points);
 R.Birthday := StrToIntDef(D.Ctrls[EB].Text, R.Birthday);
 If R.CardNo = '' Then Begin ShowMessageBox('Err', 'Carte obligatoire.'); Exit; End;
 DlgLoyForm := True;
End;

Procedure DlgLoyDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= LoyCount) Then Exit;
 DlgInit(D, 'Membre ' + LoyMembers[Idx].CardNo, 480, 320);
 DlgAddFrame(D, 12, 16, 456, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Carte    : ' + LoyMembers[Idx].CardNo);
 DlgAddLabel(D, 24, 60,  'Nom      : ' + LoyMembers[Idx].FirstName + ' ' + LoyMembers[Idx].LastName);
 DlgAddLabel(D, 24, 80,  'Email    : ' + LoyMembers[Idx].Email);
 DlgAddLabel(D, 24, 100, 'Tel      : ' + LoyMembers[Idx].Phone);
 DlgAddLabel(D, 24, 120, 'Inscrit  : ' + IntToStrPad(LoyMembers[Idx].JoinDate, 0));
 DlgAddLabel(D, 24, 140, 'Tier     : ' + LoyTierLabel(LoyMembers[Idx].Tier));
 DlgAddLabel(D, 24, 160, 'Points   : ' + IntToStrPad(LoyMembers[Idx].Points, 0));
 DlgAddLabel(D, 24, 180, 'Visites  : ' + IntToStrPad(LoyMembers[Idx].Visits, 0));
 DlgAddLabel(D, 24, 200, 'Anniv.   : ' + IntToStrPad(LoyMembers[Idx].Birthday, 0));
 DlgAddButton(D, 380, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgLoyList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TLoyalty; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To LoyCount - 1 Do
   If LoyMembers[I].Active Then Begin
    S := LoyMembers[I].CardNo;
    While Length(S) < 13 Do S := S + ' ';
    S := S + LoyMembers[I].FirstName;
    While Length(S) < 34 Do S := S + ' ';
    S := S + LoyMembers[I].LastName;
    While Length(S) < 55 Do S := S + ' ';
    S := S + LoyTierLabel(LoyMembers[I].Tier);
    While Length(S) < 65 Do S := S + ' ';
    S := S + IntToStrPad(LoyMembers[I].Points, 6);
    BrowseAdd(S, MyKeyPad(LoyMembers[I].CardNo));
   End;
  Action := ShowDBBrowser('Membres fidelite',
   'Carte        Prenom               Nom                  Tier      Points',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To LoyCount - 1 Do
    If LoyMembers[I].Active And (MyKeyPad(LoyMembers[I].CardNo) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextLoyID;
    NR.Tier := LT_BRONZE; NR.JoinDate := 20260101;
    If DlgLoyForm(NR, True) Then Begin
     If LoyCount >= MAX_LOYALTY Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      LoyMembers[LoyCount] := NR; Inc(LoyCount); Inc(NextLoyID);
      B := MyTableInsert(LoyTable, MyKeyPad(NR.CardNo), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgLoyDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    LoyMembers[Sel].Active := False;
    B := MyTableDelete(LoyTable, MyKeyPad(LoyMembers[Sel].CardNo));
    If B Then ShowMessageBox('OK', 'Membre supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgLoyNew;
Var NR: TLoyalty; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextLoyID;
 NR.Tier := LT_BRONZE; NR.JoinDate := 20260101;
 If Not DlgLoyForm(NR, True) Then Exit;
 If LoyCount >= MAX_LOYALTY Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 LoyMembers[LoyCount] := NR; Inc(LoyCount); Inc(NextLoyID);
 B := MyTableInsert(LoyTable, MyKeyPad(NR.CardNo), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgLoyEdit;
Var S: String; Idx: Integer; R: TLoyalty; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer membre', 'Carte:', S, 12) Then Exit;
 Idx := FindLoyByCard(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := LoyMembers[Idx];
 If Not DlgLoyForm(R, False) Then Exit;
 LoyMembers[Idx] := R;
 B := MyTableUpdate(LoyTable, MyKeyPad(R.CardNo), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgLoyDel;
Var S: String; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Supprimer membre', 'Numero de carte:', S, 12) Then Exit;
 Idx := FindLoyByCard(S);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  LoyMembers[Idx].Active := False;
  B := MyTableDelete(LoyTable, MyKeyPad(LoyMembers[Idx].CardNo));
  ShowMessageBox('OK', 'Supprime.');
 End;
End;

Procedure DlgLoyPts;
Var S, P: String; Pts: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Ajout points', 'Numero de carte:', S, 12) Then Exit;
 Idx := FindLoyByCard(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 P := '0';
 If Not ShowInputBox('Ajout points', 'Points a ajouter:', P, 8) Then Exit;
 Pts := StrToIntDef(P, 0);
 LoyMembers[Idx].Points := LoyMembers[Idx].Points + Pts;
 LoyMembers[Idx].Visits := LoyMembers[Idx].Visits + 1;
 If LoyMembers[Idx].Points >= 5000 Then LoyMembers[Idx].Tier := LT_PLAT
 Else If LoyMembers[Idx].Points >= 2500 Then LoyMembers[Idx].Tier := LT_GOLD
 Else If LoyMembers[Idx].Points >= 1000 Then LoyMembers[Idx].Tier := LT_SILVER;
 B := MyTableUpdate(LoyTable, MyKeyPad(LoyMembers[Idx].CardNo), LoyMembers[Idx]);
 ShowMessageBox('OK', 'Points ajoutes. Nouveau total : ' + IntToStrPad(LoyMembers[Idx].Points, 0));
End;

Procedure DlgLoyTop;
Var D: TDialog; Btn: SmallInt; I, J, Y, Rk: Integer; MaxP: LongInt; MaxI: Integer; Used: Array[0..MAX_LOYALTY-1] Of Boolean;
Begin
 For I := 0 To LoyCount - 1 Do Used[I] := False;
 DlgInit(D, 'Top 15 membres', 460, 320);
 Y := 20;
 DlgAddLabel(D, 16, Y, 'Rang  Carte    Nom                  Tier      Points');
 Y := Y + 16;
 For Rk := 1 To 15 Do
 Begin
  MaxP := -1; MaxI := -1;
  For J := 0 To LoyCount - 1 Do
   If LoyMembers[J].Active And Not Used[J] And (LoyMembers[J].Points > MaxP) Then
   Begin MaxP := LoyMembers[J].Points; MaxI := J; End;
  If MaxI < 0 Then Break;
  Used[MaxI] := True;
  DlgAddLabel(D, 16, Y,
    IntToStrPad(Rk, 2) + '    ' +
    LoyMembers[MaxI].CardNo + '   ' +
    LoyMembers[MaxI].FirstName + ' ' + LoyMembers[MaxI].LastName + '       ' +
    LoyTierLabel(LoyMembers[MaxI].Tier) + '   ' +
    IntToStrPad(MaxP, 6));
  Y := Y + 14;
 End;
 DlgAddButton(D, 360, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgLoyRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport fidelite', 400, 240);
 DlgAddLabel(D, 16, 20, 'Membres actifs   : ' + IntToStrPad(CountActiveLoyalty, 0));
 DlgAddLabel(D, 16, 40, 'Bronze           : ' + IntToStrPad(CountTier(LT_BRONZE), 0));
 DlgAddLabel(D, 16, 60, 'Argent           : ' + IntToStrPad(CountTier(LT_SILVER), 0));
 DlgAddLabel(D, 16, 80, 'Or               : ' + IntToStrPad(CountTier(LT_GOLD), 0));
 DlgAddLabel(D, 16, 100, 'Platine          : ' + IntToStrPad(CountTier(LT_PLAT), 0));
 DlgAddLabel(D, 16, 120, 'Points totaux    : ' + IntToStrPad(SumLoyaltyPoints, 0));
 DlgAddButton(D, 300, 200, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgLoyAnni;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer;
Begin
 DlgInit(D, 'Anniversaires du mois', 460, 320);
 Y := 20; N := 0;
 DlgAddLabel(D, 16, Y, 'Carte    Nom                  Date');
 Y := Y + 16;
 For I := 0 To LoyCount - 1 Do
  If LoyMembers[I].Active And (Y < 280) And (I Mod 12 = 0) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y,
    LoyMembers[I].CardNo + '   ' +
    LoyMembers[I].FirstName + ' ' + LoyMembers[I].LastName + '       ' +
    IntToStrPad(LoyMembers[I].Birthday, 8));
   Y := Y + 14;
  End;
 DlgAddLabel(D, 16, 290, 'Total : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 360, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES CAMPAGNES
  ============================================================================ }

Function DlgCampForm(Var R: TCampaign; IsNew: Boolean): Boolean;
Var D: TDialog; EC, ET, EK, ES, ESD, EED, EBd, ERe, ENo: Integer; Btn: SmallInt; T: String;
Begin
 DlgCampForm := False;
 If IsNew Then T := 'Nouvelle campagne' Else T := 'Editer campagne';
 DlgInit(D, T, 560, 400);
 DlgAddFrame(D, 12, 16, 536, 320, 'Campagne marketing');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Titre    :'); ET  := DlgAddEdit(D, 160, 60,  360, R.Title, 40);
 DlgAddLabel(D, 24, 88,  'Type     :'); EK  := DlgAddNumEdit(D, 160, 84, 60, IntToStrPad(R.Kind, 0), 2, False);
 DlgAddLabel(D, 24, 112, 'Statut   :'); ES  := DlgAddNumEdit(D, 160, 108, 60, IntToStrPad(R.Status, 0), 1, False);
 DlgAddLabel(D, 24, 136, 'Debut    :'); ESD := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.StartDate, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Fin      :'); EED := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.EndDate, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Budget   :'); EBd := DlgAddNumEdit(D, 160, 180, 120, RealToStr(R.Budget, 0, 2), 10, True);
 DlgAddLabel(D, 24, 208, 'Reach    :'); ERe := DlgAddNumEdit(D, 160, 204, 100, IntToStrPad(R.Reach, 0), 8, False);
 DlgAddLabel(D, 24, 232, 'Notes    :'); ENo := DlgAddEdit(D, 160, 228, 360, R.Notes, 60);
 DlgAddButton(D, 320, 356, 100, 'OK',      1, 'O');
 DlgAddButton(D, 436, 356, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Title := D.Ctrls[ET].Text;
 R.Kind   := StrToIntDef(D.Ctrls[EK].Text, R.Kind);
 R.Status := StrToIntDef(D.Ctrls[ES].Text, R.Status);
 R.StartDate := StrToIntDef(D.Ctrls[ESD].Text, R.StartDate);
 R.EndDate   := StrToIntDef(D.Ctrls[EED].Text, R.EndDate);
 R.Budget := StrToRealDef(D.Ctrls[EBd].Text, R.Budget);
 R.Reach  := StrToIntDef(D.Ctrls[ERe].Text, R.Reach);
 R.Notes  := D.Ctrls[ENo].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgCampForm := True;
End;

Procedure DlgCampDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= CampCount) Then Exit;
 DlgInit(D, 'Campagne ' + Campaigns[Idx].Code, 480, 340);
 DlgAddFrame(D, 12, 16, 456, 260, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code   : ' + Campaigns[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Titre  : ' + Campaigns[Idx].Title);
 DlgAddLabel(D, 24, 80,  'Type   : ' + CampKindLabel(Campaigns[Idx].Kind));
 DlgAddLabel(D, 24, 100, 'Statut : ' + CampStatusLabel(Campaigns[Idx].Status));
 DlgAddLabel(D, 24, 120, 'Debut  : ' + IntToStrPad(Campaigns[Idx].StartDate, 0));
 DlgAddLabel(D, 24, 140, 'Fin    : ' + IntToStrPad(Campaigns[Idx].EndDate, 0));
 DlgAddLabel(D, 24, 160, 'Budget : ' + RealToStr(Campaigns[Idx].Budget, 0, 2));
 DlgAddLabel(D, 24, 180, 'Reach  : ' + IntToStrPad(Campaigns[Idx].Reach, 0));
 DlgAddLabel(D, 24, 200, 'Notes  : ' + Campaigns[Idx].Notes);
 DlgAddButton(D, 380, 300, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgCampList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TCampaign; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To CampCount - 1 Do
   If Campaigns[I].Active Then Begin
    S := Campaigns[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + Campaigns[I].Title;
    While Length(S) < 41 Do S := S + ' ';
    S := S + CampKindLabel(Campaigns[I].Kind);
    While Length(S) < 51 Do S := S + ' ';
    S := S + IntToStrPad(Campaigns[I].StartDate, 8) + '  ' + RealToStr(Campaigns[I].Budget, 8, 0);
    BrowseAdd(S, MyKeyPad(Campaigns[I].Code));
   End;
  Action := ShowDBBrowser('Campagnes marketing',
   'Code       Titre                        Type      Debut     Budget',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To CampCount - 1 Do
    If Campaigns[I].Active And (MyKeyPad(Campaigns[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextCampID;
    NR.Kind := CMP_PRINT; NR.Status := CST_PLAN;
    NR.StartDate := 20260101; NR.EndDate := 20261231;
    If DlgCampForm(NR, True) Then Begin
     If CampCount >= MAX_CAMPAIGN Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Campaigns[CampCount] := NR; Inc(CampCount); Inc(NextCampID);
      B := MyTableInsert(CampTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgCampDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Campaigns[Sel].Active := False;
    B := MyTableDelete(CampTable, MyKeyPad(Campaigns[Sel].Code));
    If B Then ShowMessageBox('OK', 'Campagne supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgCampNew;
Var NR: TCampaign; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextCampID;
 NR.Kind := CMP_PRINT; NR.Status := CST_PLAN;
 NR.StartDate := 20260101; NR.EndDate := 20261231;
 If Not DlgCampForm(NR, True) Then Exit;
 If CampCount >= MAX_CAMPAIGN Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Campaigns[CampCount] := NR; Inc(CampCount); Inc(NextCampID);
 B := MyTableInsert(CampTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgCampEdit;
Var S: String; I, Idx: Integer; R: TCampaign; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer campagne', 'Code:', S, 10) Then Exit;
 Idx := -1;
 For I := 0 To CampCount - 1 Do
  If Campaigns[I].Active And (Campaigns[I].Code = S) Then Begin Idx := I; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := Campaigns[Idx];
 If Not DlgCampForm(R, False) Then Exit;
 Campaigns[Idx] := R;
 B := MyTableUpdate(CampTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgCampDel;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Suppr campagne', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindCampByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  Campaigns[Idx].Active := False;
  B := MyTableDelete(CampTable, MyKeyPad(Campaigns[Idx].Code));
  ShowMessageBox('OK', 'Supprime.');
 End;
End;

Procedure DlgCampAct;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; Today: LongInt; DT: TDateTime;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 DlgInit(D, 'Campagnes actives', 500, 320);
 Y := 20; N := 0;
 For I := 0 To CampCount - 1 Do
  If Campaigns[I].Active And (Campaigns[I].StartDate <= Today) And
     (Campaigns[I].EndDate >= Today) And (Y < 280) Then
  Begin
   N := N + 1;
   DlgAddLabel(D, 16, Y, Campaigns[I].Code + ' - ' + Campaigns[I].Title +
    ' (' + CampKindLabel(Campaigns[I].Kind) + ')');
   Y := Y + 14;
  End;
 DlgAddLabel(D, 16, 290, 'Total actives : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 400, 280, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgCampRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport campagnes', 400, 220);
 DlgAddLabel(D, 16, 20, 'Total campagnes      : ' + IntToStrPad(CampCount, 0));
 DlgAddLabel(D, 16, 40, 'En cours             : ' + IntToStrPad(CountRunningCampaigns, 0));
 DlgAddLabel(D, 16, 60, 'Budget total         : ' + RealToStr(SumCampBudget, 10, 2));
 DlgAddButton(D, 300, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES TRAFIC VISITEURS
  ============================================================================ }

Function DlgTrfForm(Var R: TTrafficRec; IsNew: Boolean): Boolean;
Var D: TDialog; ED, EH, EE, EC: Integer; Btn: SmallInt; T: String;
Begin
 DlgTrfForm := False;
 If IsNew Then T := 'Nouveau pointage' Else T := 'Editer pointage';
 DlgInit(D, T, 480, 280);
 DlgAddFrame(D, 12, 16, 456, 200, 'Trafic');
 DlgAddLabel(D, 24, 40,  'Date     :'); ED := DlgAddNumEdit(D, 160, 36,  100, IntToStrPad(R.RecDate, 0), 8, False);
 DlgAddLabel(D, 24, 64,  'Heure    :'); EH := DlgAddNumEdit(D, 160, 60,  60,  IntToStrPad(R.Hour, 0), 2, False);
 DlgAddLabel(D, 24, 88,  'Entree   :'); EE := DlgAddEdit(D, 160, 84,  200, R.Entrance, 15);
 DlgAddLabel(D, 24, 112, 'Compte   :'); EC := DlgAddNumEdit(D, 160, 108, 100, IntToStrPad(R.Count, 0), 8, False);
 DlgAddButton(D, 240, 236, 100, 'OK',      1, 'O');
 DlgAddButton(D, 356, 236, 100, 'Annuler',-1, 'A');
 D.Focus := ED;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.RecDate := StrToIntDef(D.Ctrls[ED].Text, R.RecDate);
 R.Hour    := StrToIntDef(D.Ctrls[EH].Text, R.Hour);
 R.Entrance:= D.Ctrls[EE].Text;
 R.Count   := StrToIntDef(D.Ctrls[EC].Text, R.Count);
 DlgTrfForm := True;
End;

Procedure DlgTrfDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= TrafficCount) Then Exit;
 DlgInit(D, 'Pointage #' + IntToStrPad(Traffic[Idx].ID, 0), 400, 240);
 DlgAddFrame(D, 12, 16, 376, 160, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID     : ' + IntToStrPad(Traffic[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Date   : ' + IntToStrPad(Traffic[Idx].RecDate, 0));
 DlgAddLabel(D, 24, 80,  'Heure  : ' + IntToStrPad(Traffic[Idx].Hour, 0) + 'h');
 DlgAddLabel(D, 24, 100, 'Entree : ' + Traffic[Idx].Entrance);
 DlgAddLabel(D, 24, 120, 'Compte : ' + IntToStrPad(Traffic[Idx].Count, 0));
 DlgAddButton(D, 300, 200, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgTrfList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TTrafficRec; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To TrafficCount - 1 Do
   If Traffic[I].Active Then Begin
    S := IntToStrPad(Traffic[I].ID, 4) + '  ' + IntToStrPad(Traffic[I].RecDate, 8) + '  ' +
         IntToStrPad(Traffic[I].Hour, 2) + 'h  ' + Traffic[I].Entrance;
    While Length(S) < 46 Do S := S + ' ';
    S := S + IntToStrPad(Traffic[I].Count, 6);
    BrowseAdd(S, MyKeyFromID('T', Traffic[I].ID));
   End;
  Action := ShowDBBrowser('Trafic visiteurs',
   'ID    Date      Heure Entree                Compte',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To TrafficCount - 1 Do
    If Traffic[I].Active And (MyKeyFromID('T', Traffic[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextTrfID;
    NR.RecDate := 20260101; NR.Hour := 12;
    If DlgTrfForm(NR, True) Then Begin
     If TrafficCount >= MAX_TRAFFIC Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Traffic[TrafficCount] := NR; Inc(TrafficCount); Inc(NextTrfID);
      B := MyTableInsert(TrfTable, MyKeyFromID('T', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgTrfDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Traffic[Sel].Active := False;
    B := MyTableDelete(TrfTable, MyKeyFromID('T', Traffic[Sel].ID));
    If B Then ShowMessageBox('OK', 'Pointage supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgTrfRec;
Var NR: TTrafficRec; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextTrfID;
 NR.RecDate := 20260101; NR.Hour := 12;
 If Not DlgTrfForm(NR, True) Then Exit;
 If TrafficCount >= MAX_TRAFFIC Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Traffic[TrafficCount] := NR; Inc(TrafficCount); Inc(NextTrfID);
 B := MyTableInsert(TrfTable, MyKeyFromID('T', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgTrfToday;
Var D: TDialog; Btn: SmallInt; Tot: LongInt;
Begin
 Tot := SumTrafficToday;
 DlgInit(D, 'Trafic du jour', 360, 180);
 DlgAddLabel(D, 16, 20, 'Visiteurs aujourdhui : ' + IntToStrPad(Tot, 0));
 If Tot > 0 Then
  DlgAddLabel(D, 16, 40, '(Estimation basee sur les compteurs)');
 DlgAddButton(D, 260, 140, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgTrfWeek;
Var D: TDialog; Btn: SmallInt; I: Integer; S: LongInt;
Begin
 S := 0;
 For I := 0 To TrafficCount - 1 Do
  If Traffic[I].Active Then S := S + Traffic[I].Count;
 DlgInit(D, 'Trafic cumule', 360, 180);
 DlgAddLabel(D, 16, 20, 'Total visiteurs enregistres : ' + IntToStrPad(S, 0));
 DlgAddLabel(D, 16, 40, 'Nombre de mesures           : ' + IntToStrPad(TrafficCount, 0));
 DlgAddButton(D, 260, 140, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgTrfPeak;
Var D: TDialog; Btn: SmallInt; I, MaxI: Integer; MaxC: LongInt;
Begin
 MaxC := -1; MaxI := -1;
 For I := 0 To TrafficCount - 1 Do
  If Traffic[I].Active And (Traffic[I].Count > MaxC) Then
  Begin MaxC := Traffic[I].Count; MaxI := I; End;
 DlgInit(D, 'Heure de pointe', 400, 180);
 If MaxI >= 0 Then
 Begin
  DlgAddLabel(D, 16, 20, 'Pic enregistre  : ' + IntToStrPad(MaxC, 0) + ' visiteurs');
  DlgAddLabel(D, 16, 40, 'Date            : ' + IntToStrPad(Traffic[MaxI].RecDate, 8));
  DlgAddLabel(D, 16, 60, 'Heure           : ' + IntToStrPad(Traffic[MaxI].Hour, 0) + 'h');
  DlgAddLabel(D, 16, 80, 'Entree          : ' + Traffic[MaxI].Entrance);
 End
 Else DlgAddLabel(D, 16, 20, '(aucune donnee)');
 DlgAddButton(D, 300, 140, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgTrfRpt;
Var D: TDialog; Btn: SmallInt; I: Integer; S: LongInt; Avg: Real;
Begin
 S := 0;
 For I := 0 To TrafficCount - 1 Do
  If Traffic[I].Active Then S := S + Traffic[I].Count;
 If TrafficCount > 0 Then Avg := S / TrafficCount Else Avg := 0;
 DlgInit(D, 'Rapport trafic', 400, 200);
 DlgAddLabel(D, 16, 20, 'Mesures        : ' + IntToStrPad(TrafficCount, 0));
 DlgAddLabel(D, 16, 40, 'Total cumule   : ' + IntToStrPad(S, 0));
 DlgAddLabel(D, 16, 60, 'Moyenne/mesure : ' + RealToStr(Avg, 8, 1));
 DlgAddButton(D, 300, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES FEEDBACK
  ============================================================================ }

Function DlgFBForm(Var R: TFeedback; IsNew: Boolean): Boolean;
Var D: TDialog; ED, ESr, ERa, ECo, ERe: Integer; Btn: SmallInt; T: String;
Begin
 DlgFBForm := False;
 If IsNew Then T := 'Nouveau feedback' Else T := 'Editer feedback';
 DlgInit(D, T, 520, 320);
 DlgAddFrame(D, 12, 16, 496, 240, 'Feedback client');
 DlgAddLabel(D, 24, 40,  'Date     :'); ED  := DlgAddNumEdit(D, 160, 36,  100, IntToStrPad(R.RecDate, 0), 8, False);
 DlgAddLabel(D, 24, 64,  'Source   :'); ESr := DlgAddEdit(D, 160, 60,  240, R.Source, 20);
 DlgAddLabel(D, 24, 88,  'Note 1-4 :'); ERa := DlgAddNumEdit(D, 160, 84,  60, IntToStrPad(R.Rating, 0), 1, False);
 DlgAddLabel(D, 24, 112, 'Comment. :'); ECo := DlgAddEdit(D, 160, 108, 320, R.Comment, 80);
 ERe := DlgAddCheck(D, 160, 140, 200, 'Repondu', R.Responded);
 DlgAddButton(D, 280, 280, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 280, 100, 'Annuler',-1, 'A');
 D.Focus := ED;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.RecDate := StrToIntDef(D.Ctrls[ED].Text, R.RecDate);
 R.Source  := D.Ctrls[ESr].Text;
 R.Rating  := StrToIntDef(D.Ctrls[ERa].Text, R.Rating);
 If (R.Rating < 1) Or (R.Rating > 4) Then R.Rating := FBR_GOOD;
 R.Comment   := D.Ctrls[ECo].Text;
 R.Responded := D.Ctrls[ERe].Checked;
 DlgFBForm := True;
End;

Procedure DlgFBDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt; Rep: String;
Begin
 If (Idx < 0) Or (Idx >= FBCount) Then Exit;
 If Feedback[Idx].Responded Then Rep := 'oui' Else Rep := 'non';
 DlgInit(D, 'Feedback #' + IntToStrPad(Feedback[Idx].ID, 0), 480, 280);
 DlgAddFrame(D, 12, 16, 456, 200, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID       : ' + IntToStrPad(Feedback[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Date     : ' + IntToStrPad(Feedback[Idx].RecDate, 0));
 DlgAddLabel(D, 24, 80,  'Source   : ' + Feedback[Idx].Source);
 DlgAddLabel(D, 24, 100, 'Note     : ' + FBRatingLabel(Feedback[Idx].Rating));
 DlgAddLabel(D, 24, 120, 'Comment. : ' + Copy(Feedback[Idx].Comment, 1, 70));
 DlgAddLabel(D, 24, 140, 'Repondu  : ' + Rep);
 DlgAddButton(D, 380, 240, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgFBList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TFeedback; DT: TDateTime; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To FBCount - 1 Do
   If Feedback[I].Active Then Begin
    S := IntToStrPad(Feedback[I].RecDate, 8) + '  ' + Feedback[I].Source;
    While Length(S) < 32 Do S := S + ' ';
    S := S + FBRatingLabel(Feedback[I].Rating);
    While Length(S) < 44 Do S := S + ' ';
    S := S + Copy(Feedback[I].Comment, 1, 40);
    BrowseAdd(S, MyKeyFromID('F', Feedback[I].ID));
   End;
  Action := ShowDBBrowser('Feedback clients',
   'Date      Source              Note        Commentaire',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To FBCount - 1 Do
    If Feedback[I].Active And (MyKeyFromID('F', Feedback[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextFBID;
    GetCurrentDT(DT);
    NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
    NR.Rating := FBR_GOOD;
    If DlgFBForm(NR, True) Then Begin
     If FBCount >= MAX_FEEDBACK Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Feedback[FBCount] := NR; Inc(FBCount); Inc(NextFBID);
      B := MyTableInsert(FBTable, MyKeyFromID('F', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgFBDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Feedback[Sel].Active := False;
    B := MyTableDelete(FBTable, MyKeyFromID('F', Feedback[Sel].ID));
    If B Then ShowMessageBox('OK', 'Feedback supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgFBNew;
Var NR: TFeedback; DT: TDateTime; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextFBID;
 GetCurrentDT(DT);
 NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 NR.Rating := FBR_GOOD;
 If Not DlgFBForm(NR, True) Then Exit;
 If FBCount >= MAX_FEEDBACK Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Feedback[FBCount] := NR; Inc(FBCount); Inc(NextFBID);
 B := MyTableInsert(FBTable, MyKeyFromID('F', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgFBResp;
Var S: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Reponse feedback', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindFBByID(ID);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  Feedback[Idx].Responded := True;
  B := MyTableUpdate(FBTable, MyKeyFromID('F', Feedback[Idx].ID), Feedback[Idx]);
  ShowMessageBox('OK', 'Marque comme repondu.');
 End;
End;

Procedure DlgFBRpt;
Var D: TDialog; Btn: SmallInt; I, NB, NA, NG, NE, NR: Integer;
Begin
 NB := 0; NA := 0; NG := 0; NE := 0; NR := 0;
 For I := 0 To FBCount - 1 Do
  If Feedback[I].Active Then
  Begin
   Case Feedback[I].Rating Of
    FBR_BAD : NB := NB + 1;
    FBR_AVG : NA := NA + 1;
    FBR_GOOD: NG := NG + 1;
    FBR_EXC : NE := NE + 1;
   End;
   If Feedback[I].Responded Then NR := NR + 1;
  End;
 DlgInit(D, 'Rapport feedback', 380, 280);
 DlgAddLabel(D, 16, 20, 'Total feedback   : ' + IntToStrPad(FBCount, 0));
 DlgAddLabel(D, 16, 40, 'Mauvais          : ' + IntToStrPad(NB, 0));
 DlgAddLabel(D, 16, 60, 'Moyens           : ' + IntToStrPad(NA, 0));
 DlgAddLabel(D, 16, 80, 'Bons             : ' + IntToStrPad(NG, 0));
 DlgAddLabel(D, 16, 100, 'Excellents       : ' + IntToStrPad(NE, 0));
 DlgAddLabel(D, 16, 120, 'Note moyenne     : ' + RealToStr(AvgFeedback, 6, 2));
 DlgAddLabel(D, 16, 140, 'Reponses traitees: ' + IntToStrPad(NR, 0));
 DlgAddButton(D, 280, 240, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES INVENTAIRE GENERAL
  ============================================================================ }

Function DlgInv2Form(Var R: TInventory2; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EN, ECa, EU, EQ, ERe, EUc, ES, ELr: Integer; Btn: SmallInt; T: String;
Begin
 DlgInv2Form := False;
 If IsNew Then T := 'Nouvel item' Else T := 'Editer item';
 DlgInit(D, T, 560, 400);
 DlgAddFrame(D, 12, 16, 536, 320, 'Item inventaire');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  140, R.Code, 12);
 DlgAddLabel(D, 24, 64,  'Nom      :'); EN  := DlgAddEdit(D, 160, 60,  360, R.Name, 40);
 DlgAddLabel(D, 24, 88,  'Categorie:'); ECa := DlgAddNumEdit(D, 160, 84, 60, IntToStrPad(R.Category, 0), 2, False);
 DlgAddLabel(D, 24, 112, 'Unite    :'); EU  := DlgAddEdit(D, 160, 108, 80,  R.UM, 6);
 DlgAddLabel(D, 24, 136, 'Quantite :'); EQ  := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.Qty, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Pt reapp.:'); ERe := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.ReorderPt, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Cout unit:'); EUc := DlgAddNumEdit(D, 160, 180, 100, RealToStr(R.UnitCost, 0, 2), 10, True);
 DlgAddLabel(D, 24, 208, 'Fourniss.:'); ES  := DlgAddEdit(D, 160, 204, 320, R.Supplier, 30);
 DlgAddLabel(D, 24, 232, 'Dern. cmd:'); ELr := DlgAddNumEdit(D, 160, 228, 100, IntToStrPad(R.LastReorder, 0), 8, False);
 DlgAddButton(D, 320, 356, 100, 'OK',      1, 'O');
 DlgAddButton(D, 436, 356, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Name := D.Ctrls[EN].Text;
 R.Category := StrToIntDef(D.Ctrls[ECa].Text, R.Category);
 R.UM := D.Ctrls[EU].Text;
 R.Qty := StrToIntDef(D.Ctrls[EQ].Text, R.Qty);
 R.ReorderPt := StrToIntDef(D.Ctrls[ERe].Text, R.ReorderPt);
 R.UnitCost := StrToRealDef(D.Ctrls[EUc].Text, R.UnitCost);
 R.Supplier := D.Ctrls[ES].Text;
 R.LastReorder := StrToIntDef(D.Ctrls[ELr].Text, R.LastReorder);
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgInv2Form := True;
End;

Procedure DlgInv2Detail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= Inv2Count) Then Exit;
 DlgInit(D, 'Item ' + Inventory2[Idx].Code, 480, 320);
 DlgAddFrame(D, 12, 16, 456, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + Inventory2[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom      : ' + Inventory2[Idx].Name);
 DlgAddLabel(D, 24, 80,  'Categorie: ' + InvCatLabel(Inventory2[Idx].Category));
 DlgAddLabel(D, 24, 100, 'Unite    : ' + Inventory2[Idx].UM);
 DlgAddLabel(D, 24, 120, 'Quantite : ' + IntToStrPad(Inventory2[Idx].Qty, 0));
 DlgAddLabel(D, 24, 140, 'Pt reapp.: ' + IntToStrPad(Inventory2[Idx].ReorderPt, 0));
 DlgAddLabel(D, 24, 160, 'Cout unit: ' + RealToStr(Inventory2[Idx].UnitCost, 0, 2));
 DlgAddLabel(D, 24, 180, 'Fourniss.: ' + Inventory2[Idx].Supplier);
 DlgAddLabel(D, 24, 200, 'Dern. cmd: ' + IntToStrPad(Inventory2[Idx].LastReorder, 0));
 DlgAddButton(D, 380, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgInv2List;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TInventory2; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To Inv2Count - 1 Do
   If Inventory2[I].Active Then Begin
    S := Inventory2[I].Code;
    While Length(S) < 13 Do S := S + ' ';
    S := S + Inventory2[I].Name;
    While Length(S) < 54 Do S := S + ' ';
    S := S + InvCatLabel(Inventory2[I].Category);
    While Length(S) < 64 Do S := S + ' ';
    S := S + IntToStrPad(Inventory2[I].Qty, 4) + '  ' + Inventory2[I].UM + '  ' +
         RealToStr(Inventory2[I].UnitCost, 6, 2);
    BrowseAdd(S, MyKeyPad(Inventory2[I].Code));
   End;
  Action := ShowDBBrowser('Inventaire general',
   'Code         Nom                                  Cat.       Qty   Un.  Cost',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To Inv2Count - 1 Do
    If Inventory2[I].Active And (MyKeyPad(Inventory2[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextInv2ID;
    NR.Category := IC_OTHER; NR.UM := 'un'; NR.ReorderPt := 5; NR.UnitCost := 1.0;
    If DlgInv2Form(NR, True) Then Begin
     If Inv2Count >= MAX_INVENTORY Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Inventory2[Inv2Count] := NR; Inc(Inv2Count); Inc(NextInv2ID);
      B := MyTableInsert(Inv2Table, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgInv2Detail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Inventory2[Sel].Active := False;
    B := MyTableDelete(Inv2Table, MyKeyPad(Inventory2[Sel].Code));
    If B Then ShowMessageBox('OK', 'Item supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgInv2New;
Var NR: TInventory2; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextInv2ID;
 NR.Category := IC_OTHER; NR.UM := 'un'; NR.ReorderPt := 5; NR.UnitCost := 1.0;
 If Not DlgInv2Form(NR, True) Then Exit;
 If Inv2Count >= MAX_INVENTORY Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Inventory2[Inv2Count] := NR; Inc(Inv2Count); Inc(NextInv2ID);
 B := MyTableInsert(Inv2Table, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgInv2Edit;
Var S: String; Idx: Integer; R: TInventory2; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer item', 'Code:', S, 12) Then Exit;
 Idx := FindInv2ByCode(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := Inventory2[Idx];
 If Not DlgInv2Form(R, False) Then Exit;
 Inventory2[Idx] := R;
 B := MyTableUpdate(Inv2Table, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgInv2Del;
Var S: String; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Suppr inv', 'Code:', S, 12) Then Exit;
 Idx := FindInv2ByCode(S);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  Inventory2[Idx].Active := False;
  B := MyTableDelete(Inv2Table, MyKeyPad(Inventory2[Idx].Code));
  ShowMessageBox('OK', 'Supprime.');
 End;
End;

Procedure DlgInv2Low;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; S: String;
Begin
 DlgInit(D, 'Stock faible', 580, 360);
 Y := 20; N := 0;
 DlgAddLabel(D, 16, Y, 'Code   Nom                          Qty    Reord  Fournisseur');
 Y := Y + 16;
 For I := 0 To Inv2Count - 1 Do
  If Inventory2[I].Active And (Inventory2[I].Qty <= Inventory2[I].ReorderPt) And (Y < 320) Then
  Begin
   N := N + 1;
   S := Inventory2[I].Code + '   ' + Inventory2[I].Name;
   While Length(S) < 39 Do S := S + ' ';
   S := S + IntToStrPad(Inventory2[I].Qty, 4) + '   ' +
        IntToStrPad(Inventory2[I].ReorderPt, 4) + '   ' +
        Inventory2[I].Supplier;
   DlgAddLabel(D, 16, Y, S);
   Y := Y + 14;
  End;
 DlgAddLabel(D, 16, 330, 'Items a reapprovisionner : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 480, 330, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgInv2Reord;
Var S, Q: String; Idx: Integer; Add: LongInt;
Begin
 S := '';
 If Not ShowInputBox('Reappro', 'Code item:', S, 12) Then Exit;
 Idx := FindInv2ByCode(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 Q := '0';
 If Not ShowInputBox('Reappro', 'Quantite recue:', Q, 8) Then Exit;
 Add := StrToIntDef(Q, 0);
 Inventory2[Idx].Qty := Inventory2[Idx].Qty + Add;
 Inventory2[Idx].LastReorder := 20240101;
 ShowMessageBox('OK', 'Stock mis a jour.');
End;

Procedure DlgInv2Rpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport inventaire', 400, 220);
 DlgAddLabel(D, 16, 20, 'Items en inventaire  : ' + IntToStrPad(Inv2Count, 0));
 DlgAddLabel(D, 16, 40, 'Items stock faible   : ' + IntToStrPad(CountLowInv2, 0));
 DlgAddLabel(D, 16, 60, 'Valeur totale stock  : ' + RealToStr(SumInv2Value, 10, 2));
 DlgAddButton(D, 300, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES PERSONNEL MALL
  ============================================================================ }

Function DlgStfForm(Var R: TMallStaff; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EF, EL, ER, EP, EM, EH, ESc, ESa: Integer; Btn: SmallInt; T: String;
Begin
 DlgStfForm := False;
 If IsNew Then T := 'Nouveau staff' Else T := 'Editer staff';
 DlgInit(D, T, 560, 400);
 DlgAddFrame(D, 12, 16, 536, 320, 'Personnel');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Prenom   :'); EF  := DlgAddEdit(D, 160, 60,  220, R.FirstName, 20);
 DlgAddLabel(D, 24, 88,  'Nom      :'); EL  := DlgAddEdit(D, 160, 84,  220, R.LastName, 20);
 DlgAddLabel(D, 24, 112, 'Role     :'); ER  := DlgAddNumEdit(D, 160, 108, 60, IntToStrPad(R.Role, 0), 2, False);
 DlgAddLabel(D, 24, 136, 'Tel      :'); EP  := DlgAddEdit(D, 160, 132, 220, R.Phone, 20);
 DlgAddLabel(D, 24, 160, 'Email    :'); EM  := DlgAddEdit(D, 160, 156, 340, R.Email, 40);
 DlgAddLabel(D, 24, 184, 'Embauche :'); EH  := DlgAddNumEdit(D, 160, 180, 100, IntToStrPad(R.HireDate, 0), 8, False);
 DlgAddLabel(D, 24, 208, 'Horaire  :'); ESc := DlgAddEdit(D, 160, 204, 220, R.Schedule, 20);
 DlgAddLabel(D, 24, 232, 'Salaire  :'); ESa := DlgAddNumEdit(D, 160, 228, 120, RealToStr(R.Salary, 0, 2), 10, True);
 DlgAddButton(D, 320, 356, 100, 'OK',      1, 'O');
 DlgAddButton(D, 436, 356, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.FirstName := D.Ctrls[EF].Text;
 R.LastName := D.Ctrls[EL].Text;
 R.Role := StrToIntDef(D.Ctrls[ER].Text, R.Role);
 R.Phone := D.Ctrls[EP].Text; R.Email := D.Ctrls[EM].Text;
 R.HireDate := StrToIntDef(D.Ctrls[EH].Text, R.HireDate);
 R.Schedule := D.Ctrls[ESc].Text;
 R.Salary := StrToRealDef(D.Ctrls[ESa].Text, R.Salary);
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgStfForm := True;
End;

Procedure DlgStfDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= StaffCount) Then Exit;
 DlgInit(D, 'Staff ' + MallStaff[Idx].Code, 480, 320);
 DlgAddFrame(D, 12, 16, 456, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + MallStaff[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Nom      : ' + MallStaff[Idx].FirstName + ' ' + MallStaff[Idx].LastName);
 DlgAddLabel(D, 24, 80,  'Role     : ' + StaffRoleLabel2(MallStaff[Idx].Role));
 DlgAddLabel(D, 24, 100, 'Tel      : ' + MallStaff[Idx].Phone);
 DlgAddLabel(D, 24, 120, 'Email    : ' + MallStaff[Idx].Email);
 DlgAddLabel(D, 24, 140, 'Embauche : ' + IntToStrPad(MallStaff[Idx].HireDate, 0));
 DlgAddLabel(D, 24, 160, 'Horaire  : ' + MallStaff[Idx].Schedule);
 DlgAddLabel(D, 24, 180, 'Salaire  : ' + RealToStr(MallStaff[Idx].Salary, 0, 2));
 DlgAddButton(D, 380, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgStfList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TMallStaff; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To StaffCount - 1 Do
   If MallStaff[I].Active Then Begin
    S := MallStaff[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + MallStaff[I].FirstName;
    While Length(S) < 32 Do S := S + ' ';
    S := S + MallStaff[I].LastName;
    While Length(S) < 53 Do S := S + ' ';
    S := S + StaffRoleLabel2(MallStaff[I].Role);
    While Length(S) < 65 Do S := S + ' ';
    S := S + RealToStr(MallStaff[I].Salary, 8, 0);
    BrowseAdd(S, MyKeyPad(MallStaff[I].Code));
   End;
  Action := ShowDBBrowser('Personnel mall',
   'Code       Prenom               Nom                  Role        Salaire',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To StaffCount - 1 Do
    If MallStaff[I].Active And (MyKeyPad(MallStaff[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextStaffID;
    NR.Role := SR_OTHER; NR.HireDate := 20260101; NR.Salary := 40000.0;
    If DlgStfForm(NR, True) Then Begin
     If StaffCount >= MAX_MALL_STAFF Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      MallStaff[StaffCount] := NR; Inc(StaffCount); Inc(NextStaffID);
      B := MyTableInsert(StaffTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgStfDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    MallStaff[Sel].Active := False;
    B := MyTableDelete(StaffTable, MyKeyPad(MallStaff[Sel].Code));
    If B Then ShowMessageBox('OK', 'Staff supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgStfNew;
Var NR: TMallStaff; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextStaffID;
 NR.Role := SR_OTHER; NR.HireDate := 20260101; NR.Salary := 40000.0;
 If Not DlgStfForm(NR, True) Then Exit;
 If StaffCount >= MAX_MALL_STAFF Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 MallStaff[StaffCount] := NR; Inc(StaffCount); Inc(NextStaffID);
 B := MyTableInsert(StaffTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgStfEdit;
Var S: String; Idx: Integer; R: TMallStaff; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer staff', 'Code:', S, 10) Then Exit;
 Idx := FindStaffByCode2(S);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := MallStaff[Idx];
 If Not DlgStfForm(R, False) Then Exit;
 MallStaff[Idx] := R;
 B := MyTableUpdate(StaffTable, MyKeyPad(R.Code), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgStfDel;
Var S: String; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Suppr staff', 'Code:', S, 10) Then Exit;
 Idx := FindStaffByCode2(S);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else Begin
  MallStaff[Idx].Active := False;
  B := MyTableDelete(StaffTable, MyKeyPad(MallStaff[Idx].Code));
  ShowMessageBox('OK', 'Supprime.');
 End;
End;

Procedure DlgStfSched;
Var D: TDialog; Btn: SmallInt; I, Y, Pg: Integer;
Begin
 DlgInit(D, 'Horaires staff', 520, 380);
 Y := 20; Pg := 0;
 DlgAddLabel(D, 16, Y, 'Code   Nom                      Role       Horaire');
 Y := Y + 16;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active And (Pg < 22) Then
  Begin
   DlgAddLabel(D, 16, Y,
    MallStaff[I].Code + '   ' +
    MallStaff[I].FirstName + ' ' + MallStaff[I].LastName + '          ' +
    StaffRoleLabel2(MallStaff[I].Role) + '   ' +
    MallStaff[I].Schedule);
   Y := Y + 14;
   Pg := Pg + 1;
  End;
 DlgAddButton(D, 420, 340, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgStfRpt;
Var D: TDialog; Btn: SmallInt; I: Integer; NM, NA, NR, NSe, NC: Integer;
Begin
 NM := 0; NA := 0; NR := 0; NSe := 0; NC := 0;
 For I := 0 To StaffCount - 1 Do
  If MallStaff[I].Active Then
   Case MallStaff[I].Role Of
    SR_MANAGER : NM := NM + 1;
    SR_ASSIST  : NA := NA + 1;
    SR_RECEPT  : NR := NR + 1;
    SR_SECURITY2 : NSe := NSe + 1;
    SR_CLEANER : NC := NC + 1;
   End;
 DlgInit(D, 'Rapport personnel', 400, 280);
 DlgAddLabel(D, 16, 20, 'Total staff actif  : ' + IntToStrPad(CountActiveStaff, 0));
 DlgAddLabel(D, 16, 40, 'Direction          : ' + IntToStrPad(NM, 0));
 DlgAddLabel(D, 16, 60, 'Assistants         : ' + IntToStrPad(NA, 0));
 DlgAddLabel(D, 16, 80, 'Accueil            : ' + IntToStrPad(NR, 0));
 DlgAddLabel(D, 16, 100, 'Securite           : ' + IntToStrPad(NSe, 0));
 DlgAddLabel(D, 16, 120, 'Nettoyage          : ' + IntToStrPad(NC, 0));
 DlgAddLabel(D, 16, 140, 'Masse salariale    : ' + RealToStr(SumPayroll, 10, 2));
 DlgAddButton(D, 300, 240, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

{ ============================================================================
  DIALOGUES RAPPORTS JOURNALIERS
  ============================================================================ }

Function DlgDRForm(Var R: TDayReport; IsNew: Boolean): Boolean;
Var D: TDialog; ED, EV, ERev, EI, EM, ESa: Integer; Btn: SmallInt; T: String;
Begin
 DlgDRForm := False;
 If IsNew Then T := 'Nouveau rapport' Else T := 'Editer rapport';
 DlgInit(D, T, 520, 330);
 DlgAddFrame(D, 12, 16, 496, 240, 'Rapport journalier');
 DlgAddLabel(D, 24, 40,  'Date     :'); ED   := DlgAddNumEdit(D, 160, 36,  100, IntToStrPad(R.RDate, 0), 8, False);
 DlgAddLabel(D, 24, 64,  'Visiteurs:'); EV   := DlgAddNumEdit(D, 160, 60,  120, IntToStrPad(R.Visitors, 0), 8, False);
 DlgAddLabel(D, 24, 88,  'Revenu   :'); ERev := DlgAddNumEdit(D, 160, 84,  140, RealToStr(R.Revenue, 0, 2), 12, True);
 DlgAddLabel(D, 24, 112, 'Ventes   :'); ESa  := DlgAddNumEdit(D, 160, 108, 140, RealToStr(R.Sales, 0, 2), 12, True);
 DlgAddLabel(D, 24, 136, 'Incidents:'); EI   := DlgAddNumEdit(D, 160, 132, 80,  IntToStrPad(R.Incidents, 0), 4, False);
 DlgAddLabel(D, 24, 160, 'Maint.   :'); EM   := DlgAddNumEdit(D, 160, 156, 80,  IntToStrPad(R.Maint, 0), 4, False);
 DlgAddButton(D, 280, 286, 100, 'OK',      1, 'O');
 DlgAddButton(D, 396, 286, 100, 'Annuler',-1, 'A');
 D.Focus := ED;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.RDate := StrToIntDef(D.Ctrls[ED].Text, R.RDate);
 R.Visitors := StrToIntDef(D.Ctrls[EV].Text, R.Visitors);
 R.Revenue := StrToRealDef(D.Ctrls[ERev].Text, R.Revenue);
 R.Sales := StrToRealDef(D.Ctrls[ESa].Text, R.Sales);
 R.Incidents := StrToIntDef(D.Ctrls[EI].Text, R.Incidents);
 R.Maint := StrToIntDef(D.Ctrls[EM].Text, R.Maint);
 DlgDRForm := True;
End;

Procedure DlgDRDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= DRCount) Then Exit;
 DlgInit(D, 'Rapport #' + IntToStrPad(DayReports[Idx].ID, 0), 480, 300);
 DlgAddFrame(D, 12, 16, 456, 220, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID        : ' + IntToStrPad(DayReports[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Date      : ' + IntToStrPad(DayReports[Idx].RDate, 0));
 DlgAddLabel(D, 24, 80,  'Visiteurs : ' + IntToStrPad(DayReports[Idx].Visitors, 0));
 DlgAddLabel(D, 24, 100, 'Revenu    : ' + RealToStr(DayReports[Idx].Revenue, 0, 2));
 DlgAddLabel(D, 24, 120, 'Ventes    : ' + RealToStr(DayReports[Idx].Sales, 0, 2));
 DlgAddLabel(D, 24, 140, 'Incidents : ' + IntToStrPad(DayReports[Idx].Incidents, 0));
 DlgAddLabel(D, 24, 160, 'Maint.    : ' + IntToStrPad(DayReports[Idx].Maint, 0));
 DlgAddButton(D, 380, 260, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgDRList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TDayReport; DT: TDateTime; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To DRCount - 1 Do
   If DayReports[I].Active Then Begin
    S := IntToStrPad(DayReports[I].ID, 4) + '  ' + IntToStrPad(DayReports[I].RDate, 8) + '  ' +
         IntToStrPad(DayReports[I].Visitors, 6);
    While Length(S) < 32 Do S := S + ' ';
    S := S + RealToStr(DayReports[I].Revenue, 10, 2);
    While Length(S) < 46 Do S := S + ' ';
    S := S + RealToStr(DayReports[I].Sales, 10, 2);
    BrowseAdd(S, MyKeyFromID('D', DayReports[I].ID));
   End;
  Action := ShowDBBrowser('Rapports journaliers',
   'ID    Date      Visiteurs    Revenu        Ventes',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To DRCount - 1 Do
    If DayReports[I].Active And (MyKeyFromID('D', DayReports[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextDRID;
    GetCurrentDT(DT);
    NR.RDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
    NR.Visitors := SumTrafficToday; NR.Revenue := 50000.0;
    If DlgDRForm(NR, True) Then Begin
     If DRCount >= MAX_DAYREPORT Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      DayReports[DRCount] := NR; Inc(DRCount); Inc(NextDRID);
      B := MyTableInsert(DRTable, MyKeyFromID('D', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgDRDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    DayReports[Sel].Active := False;
    B := MyTableDelete(DRTable, MyKeyFromID('D', DayReports[Sel].ID));
    If B Then ShowMessageBox('OK', 'Rapport supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgDRGen;
Var NR: TDayReport; DT: TDateTime; Today: LongInt; B: Boolean;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 If FindDRByDate(Today) >= 0 Then Begin ShowMessageBox('Info', 'Rapport du jour existe deja.'); Exit; End;
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextDRID;
 NR.RDate := Today; NR.Visitors := SumTrafficToday; NR.Revenue := 50000.0;
 If Not DlgDRForm(NR, True) Then Exit;
 If DRCount >= MAX_DAYREPORT Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 DayReports[DRCount] := NR; Inc(DRCount); Inc(NextDRID);
 B := MyTableInsert(DRTable, MyKeyFromID('D', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgDRView;
Var S: String; D: LongInt; Idx: Integer; Dl: TDialog; Btn: SmallInt;
Begin
 S := '';
 If Not ShowInputBox('Voir rapport', 'Date (AAAAMMJJ):', S, 8) Then Exit;
 D := StrToIntDef(S, 0);
 Idx := FindDRByDate(D);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Aucun rapport pour cette date.'); Exit; End;
 DlgInit(Dl, 'Rapport ' + IntToStrPad(D, 0), 400, 280);
 DlgAddLabel(Dl, 16, 20, 'Date         : ' + IntToStrPad(DayReports[Idx].RDate, 8));
 DlgAddLabel(Dl, 16, 40, 'Visiteurs    : ' + IntToStrPad(DayReports[Idx].Visitors, 0));
 DlgAddLabel(Dl, 16, 60, 'Revenu       : ' + RealToStr(DayReports[Idx].Revenue, 10, 2));
 DlgAddLabel(Dl, 16, 80, 'Ventes       : ' + RealToStr(DayReports[Idx].Sales, 10, 2));
 DlgAddLabel(Dl, 16, 100, 'Incidents    : ' + IntToStrPad(DayReports[Idx].Incidents, 0));
 DlgAddLabel(Dl, 16, 120, 'Maint. tkts  : ' + IntToStrPad(DayReports[Idx].Maint, 0));
 DlgAddButton(Dl, 300, 240, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(Dl);
End;

Procedure DlgDRExport;
Begin
 ShowMessageBox('Info', 'Export CSV : a venir (' + IntToStrPad(DRCount, 0) + ' rapports).');
End;
{ === END MALL_INC_Y_HAND.TXT === }
{ === BEGIN MALL_INC_Z_HAND.TXT === }
{ ============================================================================
  MALL_INC_Z_HAND.TXT
  Module 3 hand-crafted (PARKING.PAS API) - Services et exploitation.
  Couvre : Cartes-cadeaux, Services (PMR/poussettes/casiers),
           Heures d ouverture, Inspections/conformite, Plaintes.
  ============================================================================ }

Const
 MAX_GIFTCARD     = 300;
 MAX_SERVICE      = 80;
 MAX_HOURS        = 30;
 MAX_INSPECTION   = 150;
 MAX_COMPLAINT    = 200;
 MAX_PARK_VALID   = 200;

 { Tags 6000-6099 GC, 6100 Services, 6200 Hours, 6300 Insp, 6400 Compl,
       6500 ParkValid }
 TAG_GC_LIST      = 6000;
 TAG_GC_ISSUE     = 6001;
 TAG_GC_REDEEM    = 6002;
 TAG_GC_BAL       = 6003;
 TAG_GC_RPT       = 6004;

 TAG_SRV_LIST     = 6100;
 TAG_SRV_NEW      = 6101;
 TAG_SRV_LEND     = 6102;
 TAG_SRV_RETURN   = 6103;
 TAG_SRV_RPT      = 6104;

 TAG_HRS_LIST     = 6200;
 TAG_HRS_EDIT     = 6201;
 TAG_HRS_TODAY    = 6202;
 TAG_HRS_RPT      = 6203;

 TAG_INS_LIST     = 6300;
 TAG_INS_NEW      = 6301;
 TAG_INS_VIEW     = 6302;
 TAG_INS_FAILED   = 6303;
 TAG_INS_RPT      = 6304;

 TAG_CPL_LIST     = 6400;
 TAG_CPL_NEW      = 6401;
 TAG_CPL_RESP     = 6402;
 TAG_CPL_RPT      = 6403;

 TAG_PV_LIST      = 6500;
 TAG_PV_REC       = 6501;
 TAG_PV_TODAY     = 6502;
 TAG_PV_RPT       = 6503;

 { Etats carte cadeau }
 GC_ACTIVE  = 1;
 GC_USED    = 2;
 GC_EXPIRED = 3;

 { Types service }
 SRV_WHEEL    = 1;
 SRV_STROLL   = 2;
 SRV_LOCKER   = 3;
 SRV_PHONECHG = 4;
 SRV_INFO     = 5;
 SRV_OTHER    = 99;

 { Etats inspection }
 INS_OK     = 1;
 INS_MINOR  = 2;
 INS_MAJOR  = 3;
 INS_FAIL   = 4;

 { Categories inspection }
 IC_FIRE       = 1;
 IC_ELEC       = 2;
 IC_PLUMB      = 3;
 IC_HEALTH     = 4;
 IC_ELEVATOR   = 5;
 IC_HVAC       = 6;
 IC_GENERAL    = 9;

 { Etats plainte }
 CPL_OPEN     = 1;
 CPL_INPROG   = 2;
 CPL_CLOSED   = 3;

 { Categories plainte }
 CC_NOISE     = 1;
 CC_CLEAN2    = 2;
 CC_PERSONNEL = 3;
 CC_PRODUCT   = 4;
 CC_TENANT    = 5;
 CC_PARKING   = 6;
 CC_OTHER     = 9;

Type
 TGiftCard = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[16];
  Holder     : String[40];
  InitVal    : Real;
  Balance    : Real;
  IssueDate  : LongInt;
  ExpDate    : LongInt;
  Status     : Byte;
 End;

 TMallService = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Kind       : Byte;
  Descr      : String[40];
  TotalStock : Integer;
  Available  : Integer;
  Fee        : Real;
 End;

 THours = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Day        : Byte;
  OpenHour   : Byte;
  OpenMin    : Byte;
  CloseHour  : Byte;
  CloseMin   : Byte;
  Note       : String[30];
 End;

 TInspection = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  Code       : String[10];
  Category   : Byte;
  Area       : String[30];
  InspDate   : LongInt;
  Inspector  : String[30];
  Result     : Byte;
  Notes      : String[60];
 End;

 TComplaint = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  RecDate    : LongInt;
  Category   : Byte;
  Source     : String[20];
  Descr      : String[80];
  Status     : Byte;
  Response   : String[60];
 End;

 TParkValid = Packed Record
  Active     : Boolean;
  ID         : LongInt;
  RecDate    : LongInt;
  TenantID   : LongInt;
  TicketRef  : String[12];
  Discount   : SmallInt;
 End;

Var
 GiftCards     : Array[0..MAX_GIFTCARD-1] Of TGiftCard;
 GCCount       : Integer;
 NextGCID      : LongInt;

 Services      : Array[0..MAX_SERVICE-1] Of TMallService;
 ServiceCount  : Integer;
 NextSrvID     : LongInt;

 HoursTbl      : Array[0..MAX_HOURS-1] Of THours;
 HoursCount    : Integer;
 NextHrID      : LongInt;

 Inspections   : Array[0..MAX_INSPECTION-1] Of TInspection;
 InspCount     : Integer;
 NextInspID    : LongInt;

 Complaints    : Array[0..MAX_COMPLAINT-1] Of TComplaint;
 ComplCount    : Integer;
 NextComplID   : LongInt;

 ParkValids    : Array[0..MAX_PARK_VALID-1] Of TParkValid;
 PVCount       : Integer;
 NextPVID      : LongInt;

 { Tables MyISAM persistantes }
 GCTable       : TMyTable;
 SrvTable      : TMyTable;
 InspTable     : TMyTable;
 HoursTable    : TMyTable;
 ComplTable    : TMyTable;
 PVTable       : TMyTable;
 MallSeedMode  : Boolean;

{ ============== FORWARDS ============== }












{ ============== LABELS ============== }

Function GCStatusLabel(S: Byte): String;
Begin
 Case S Of
  GC_ACTIVE : GCStatusLabel := 'Actif';
  GC_USED   : GCStatusLabel := 'Utilise';
  GC_EXPIRED: GCStatusLabel := 'Expire';
 Else
  GCStatusLabel := '?';
 End;
End;

Function ServiceKindLabel(K: Byte): String;
Begin
 Case K Of
  SRV_WHEEL   : ServiceKindLabel := 'F. roulant';
  SRV_STROLL  : ServiceKindLabel := 'Poussette';
  SRV_LOCKER  : ServiceKindLabel := 'Casier';
  SRV_PHONECHG: ServiceKindLabel := 'Recharge';
  SRV_INFO    : ServiceKindLabel := 'Info';
 Else
  ServiceKindLabel := 'Autre';
 End;
End;

Function InspResultLabel(R: Byte): String;
Begin
 Case R Of
  INS_OK   : InspResultLabel := 'OK';
  INS_MINOR: InspResultLabel := 'Mineur';
  INS_MAJOR: InspResultLabel := 'Majeur';
  INS_FAIL : InspResultLabel := 'Echec';
 Else
  InspResultLabel := '?';
 End;
End;

Function InspCatLabel(C: Byte): String;
Begin
 Case C Of
  IC_FIRE    : InspCatLabel := 'Incendie';
  IC_ELEC    : InspCatLabel := 'Elec';
  IC_PLUMB   : InspCatLabel := 'Plomb.';
  IC_HEALTH  : InspCatLabel := 'Sante';
  IC_ELEVATOR: InspCatLabel := 'Asc.';
  IC_HVAC    : InspCatLabel := 'CVC';
 Else
  InspCatLabel := 'General';
 End;
End;

Function ComplCatLabel(C: Byte): String;
Begin
 Case C Of
  CC_NOISE    : ComplCatLabel := 'Bruit';
  CC_CLEAN2   : ComplCatLabel := 'Proprete';
  CC_PERSONNEL: ComplCatLabel := 'Personnel';
  CC_PRODUCT  : ComplCatLabel := 'Produit';
  CC_TENANT   : ComplCatLabel := 'Boutique';
  CC_PARKING  : ComplCatLabel := 'Parking';
 Else
  ComplCatLabel := 'Autre';
 End;
End;

Function ComplStatusLabel(S: Byte): String;
Begin
 Case S Of
  CPL_OPEN  : ComplStatusLabel := 'Ouvert';
  CPL_INPROG: ComplStatusLabel := 'En cours';
  CPL_CLOSED: ComplStatusLabel := 'Ferme';
 Else
  ComplStatusLabel := '?';
 End;
End;

Function DayLabel(D: Byte): String;
Begin
 Case D Of
  1: DayLabel := 'Lundi';
  2: DayLabel := 'Mardi';
  3: DayLabel := 'Mercredi';
  4: DayLabel := 'Jeudi';
  5: DayLabel := 'Vendredi';
  6: DayLabel := 'Samedi';
  7: DayLabel := 'Dimanche';
 Else
  DayLabel := '?';
 End;
End;

{ ============== FIND ============== }

Function FindGCByCode(Const C: String): Integer;
Var I: Integer;
Begin
 FindGCByCode := -1;
 For I := 0 To GCCount - 1 Do
  If GiftCards[I].Active And (GiftCards[I].Code = C) Then
  Begin FindGCByCode := I; Exit; End;
End;

Function FindSrvByCode(Const C: String): Integer;
Var I: Integer;
Begin
 FindSrvByCode := -1;
 For I := 0 To ServiceCount - 1 Do
  If Services[I].Active And (Services[I].Code = C) Then
  Begin FindSrvByCode := I; Exit; End;
End;

Function FindInspByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindInspByID := -1;
 For I := 0 To InspCount - 1 Do
  If Inspections[I].Active And (Inspections[I].ID = ID) Then
  Begin FindInspByID := I; Exit; End;
End;

Function FindComplByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindComplByID := -1;
 For I := 0 To ComplCount - 1 Do
  If Complaints[I].Active And (Complaints[I].ID = ID) Then
  Begin FindComplByID := I; Exit; End;
End;

Function FindHrsByDay(D: Byte): Integer;
Var I: Integer;
Begin
 FindHrsByDay := -1;
 For I := 0 To HoursCount - 1 Do
  If HoursTbl[I].Active And (HoursTbl[I].Day = D) Then
  Begin FindHrsByDay := I; Exit; End;
End;

{ ============== STATS ============== }

Function SumGCBalance: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To GCCount - 1 Do
  If GiftCards[I].Active And (GiftCards[I].Status = GC_ACTIVE) Then S := S + GiftCards[I].Balance;
 SumGCBalance := S;
End;

Function CountActiveGC: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To GCCount - 1 Do
  If GiftCards[I].Active And (GiftCards[I].Status = GC_ACTIVE) Then N := N + 1;
 CountActiveGC := N;
End;

Function CountOpenCompl: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To ComplCount - 1 Do
  If Complaints[I].Active And (Complaints[I].Status <> CPL_CLOSED) Then N := N + 1;
 CountOpenCompl := N;
End;

Function CountFailedInsp: Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To InspCount - 1 Do
  If Inspections[I].Active And ((Inspections[I].Result = INS_FAIL) Or (Inspections[I].Result = INS_MAJOR)) Then
   N := N + 1;
 CountFailedInsp := N;
End;

Function SumPVDiscount: Real;
Var I: Integer; S: Real;
Begin
 S := 0;
 For I := 0 To PVCount - 1 Do
  If ParkValids[I].Active Then S := S + ParkValids[I].Discount;
 SumPVDiscount := S;
End;

{ ============== SEEDS ============== }

Procedure LoadGiftCardsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; G: TGiftCard;
Begin
 N := MyTableIndexCount(GCTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(GCTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(GCTable, E.DataOfs, G) Then
    If GCCount < MAX_GIFTCARD Then Begin
     GiftCards[GCCount] := G;
     GiftCards[GCCount].Active := True;
     If G.ID >= NextGCID Then NextGCID := G.ID + 1;
     Inc(GCCount);
    End;
End;

Procedure LoadServicesFromDB;
Var N, I: LongInt; E: TMyIndexEntry; S: TMallService;
Begin
 N := MyTableIndexCount(SrvTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(SrvTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(SrvTable, E.DataOfs, S) Then
    If ServiceCount < MAX_SERVICE Then Begin
     Services[ServiceCount] := S;
     Services[ServiceCount].Active := True;
     If S.ID >= NextSrvID Then NextSrvID := S.ID + 1;
     Inc(ServiceCount);
    End;
End;

Procedure LoadInspectionsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; X: TInspection;
Begin
 N := MyTableIndexCount(InspTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(InspTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(InspTable, E.DataOfs, X) Then
    If InspCount < MAX_INSPECTION Then Begin
     Inspections[InspCount] := X;
     Inspections[InspCount].Active := True;
     If X.ID >= NextInspID Then NextInspID := X.ID + 1;
     Inc(InspCount);
    End;
End;

Procedure BulkPersistGiftCards;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To GCCount - 1 Do
  B := MyTableInsert(GCTable, MyKeyPad(GiftCards[I].Code), GiftCards[I]);
End;

Procedure BulkPersistServices;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To ServiceCount - 1 Do
  B := MyTableInsert(SrvTable, MyKeyPad(Services[I].Code), Services[I]);
End;

Procedure BulkPersistInspections;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To InspCount - 1 Do
  B := MyTableInsert(InspTable, MyKeyPad(Inspections[I].Code), Inspections[I]);
End;

Procedure LoadHoursFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: THours;
Begin
 N := MyTableIndexCount(HoursTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(HoursTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(HoursTable, E.DataOfs, R) Then
    If HoursCount < MAX_HOURS Then Begin
     HoursTbl[HoursCount] := R;
     HoursTbl[HoursCount].Active := True;
     If R.ID >= NextHrID Then NextHrID := R.ID + 1;
     Inc(HoursCount);
    End;
End;

Procedure LoadComplaintsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TComplaint;
Begin
 N := MyTableIndexCount(ComplTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(ComplTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(ComplTable, E.DataOfs, R) Then
    If ComplCount < MAX_COMPLAINT Then Begin
     Complaints[ComplCount] := R;
     Complaints[ComplCount].Active := True;
     If R.ID >= NextComplID Then NextComplID := R.ID + 1;
     Inc(ComplCount);
    End;
End;

Procedure LoadParkValidsFromDB;
Var N, I: LongInt; E: TMyIndexEntry; R: TParkValid;
Begin
 N := MyTableIndexCount(PVTable);
 For I := 0 To N - 1 Do
  If MyTableReadIndexAt(PVTable, I, E) And (E.Status = MYISAM_STATUS_ACTIVE) Then
   If MyTableReadDataAt(PVTable, E.DataOfs, R) Then
    If PVCount < MAX_PARK_VALID Then Begin
     ParkValids[PVCount] := R;
     ParkValids[PVCount].Active := True;
     If R.ID >= NextPVID Then NextPVID := R.ID + 1;
     Inc(PVCount);
    End;
End;

Procedure BulkPersistHours;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To HoursCount - 1 Do
  B := MyTableInsert(HoursTable, MyKeyFromID('H', HoursTbl[I].ID), HoursTbl[I]);
End;

Procedure BulkPersistComplaints;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To ComplCount - 1 Do
  B := MyTableInsert(ComplTable, MyKeyFromID('P', Complaints[I].ID), Complaints[I]);
End;

Procedure BulkPersistParkValids;
Var I: Integer; B: Boolean;
Begin
 For I := 0 To PVCount - 1 Do
  B := MyTableInsert(PVTable, MyKeyFromID('V', ParkValids[I].ID), ParkValids[I]);
End;

Procedure InitMallExt3;
Var Bootstrap: Boolean;
Begin
 GCCount := 0; NextGCID := 1;
 ServiceCount := 0; NextSrvID := 1;
 HoursCount := 0; NextHrID := 1;
 InspCount := 0; NextInspID := 1;
 ComplCount := 0; NextComplID := 1;
 PVCount := 0; NextPVID := 1;

 MyTableInit(GCTable,    'GIFTCARD', SizeOf(TGiftCard));
 MyTableInit(SrvTable,   'SERVICE',  SizeOf(TMallService));
 MyTableInit(InspTable,  'INSPECT',  SizeOf(TInspection));
 MyTableInit(HoursTable, 'HOURS',    SizeOf(THours));
 MyTableInit(ComplTable, 'COMPLNT',  SizeOf(TComplaint));
 MyTableInit(PVTable,    'PARKVAL',  SizeOf(TParkValid));

 Bootstrap := Not (MyTableExists('GIFTCARD') And MyTableExists('SERVICE') And
                   MyTableExists('INSPECT')  And MyTableExists('HOURS')   And
                   MyTableExists('COMPLNT')  And MyTableExists('PARKVAL'));
 If Bootstrap Then Begin
  MyTableCreate(GCTable);    MyTableCreate(SrvTable);
  MyTableCreate(InspTable);  MyTableCreate(HoursTable);
  MyTableCreate(ComplTable); MyTableCreate(PVTable);
 End;

 { Bootstrap : tables creees vides ; peuplees via dialogues. Pas de
   seed code. }

 If Bootstrap Then Begin
  { rien }
 End Else Begin
  GCCount := 0;      NextGCID := 1;
  ServiceCount := 0; NextSrvID := 1;
  InspCount := 0;    NextInspID := 1;
  HoursCount := 0;   NextHrID := 1;
  ComplCount := 0;   NextComplID := 1;
  PVCount := 0;      NextPVID := 1;
  LoadGiftCardsFromDB;   LoadServicesFromDB;
  LoadInspectionsFromDB; LoadHoursFromDB;
  LoadComplaintsFromDB;  LoadParkValidsFromDB;
 End;
End;

Function DlgGCForm(Var R: TGiftCard; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EH, EIv, EBa, EI, EE, ES: Integer; Btn: SmallInt; T: String;
Begin
 DlgGCForm := False;
 If IsNew Then T := 'Nouvelle carte' Else T := 'Editer carte';
 DlgInit(D, T, 540, 360);
 DlgAddFrame(D, 12, 16, 516, 280, 'Carte-cadeau');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  180, R.Code, 16);
 DlgAddLabel(D, 24, 64,  'Titulaire:'); EH  := DlgAddEdit(D, 160, 60,  340, R.Holder, 40);
 DlgAddLabel(D, 24, 88,  'Valeur i.:'); EIv := DlgAddNumEdit(D, 160, 84, 140, RealToStr(R.InitVal, 0, 2), 10, True);
 DlgAddLabel(D, 24, 112, 'Solde    :'); EBa := DlgAddNumEdit(D, 160, 108, 140, RealToStr(R.Balance, 0, 2), 10, True);
 DlgAddLabel(D, 24, 136, 'Emission :'); EI  := DlgAddNumEdit(D, 160, 132, 100, IntToStrPad(R.IssueDate, 0), 8, False);
 DlgAddLabel(D, 24, 160, 'Expir.   :'); EE  := DlgAddNumEdit(D, 160, 156, 100, IntToStrPad(R.ExpDate, 0), 8, False);
 DlgAddLabel(D, 24, 184, 'Statut   :'); ES  := DlgAddNumEdit(D, 160, 180, 60,  IntToStrPad(R.Status, 0), 1, False);
 DlgAddButton(D, 300, 316, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 316, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text; R.Holder := D.Ctrls[EH].Text;
 R.InitVal := StrToRealDef(D.Ctrls[EIv].Text, R.InitVal);
 R.Balance := StrToRealDef(D.Ctrls[EBa].Text, R.Balance);
 R.IssueDate := StrToIntDef(D.Ctrls[EI].Text, R.IssueDate);
 R.ExpDate := StrToIntDef(D.Ctrls[EE].Text, R.ExpDate);
 R.Status := StrToIntDef(D.Ctrls[ES].Text, R.Status);
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgGCForm := True;
End;

Procedure DlgGCDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= GCCount) Then Exit;
 DlgInit(D, 'Carte ' + GiftCards[Idx].Code, 480, 300);
 DlgAddFrame(D, 12, 16, 456, 220, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code      : ' + GiftCards[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Titulaire : ' + GiftCards[Idx].Holder);
 DlgAddLabel(D, 24, 80,  'Valeur    : ' + RealToStr(GiftCards[Idx].InitVal, 0, 2));
 DlgAddLabel(D, 24, 100, 'Solde     : ' + RealToStr(GiftCards[Idx].Balance, 0, 2));
 DlgAddLabel(D, 24, 120, 'Emission  : ' + IntToStrPad(GiftCards[Idx].IssueDate, 0));
 DlgAddLabel(D, 24, 140, 'Expir.    : ' + IntToStrPad(GiftCards[Idx].ExpDate, 0));
 DlgAddLabel(D, 24, 160, 'Statut    : ' + GCStatusLabel(GiftCards[Idx].Status));
 DlgAddButton(D, 380, 260, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgGCList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TGiftCard; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To GCCount - 1 Do
   If GiftCards[I].Active Then Begin
    S := GiftCards[I].Code;
    While Length(S) < 17 Do S := S + ' ';
    S := S + GiftCards[I].Holder;
    While Length(S) < 49 Do S := S + ' ';
    S := S + RealToStr(GiftCards[I].InitVal, 7, 2) + '  ' +
         RealToStr(GiftCards[I].Balance, 7, 2) + '  ' +
         GCStatusLabel(GiftCards[I].Status);
    BrowseAdd(S, MyKeyPad(GiftCards[I].Code));
   End;
  Action := ShowDBBrowser('Cartes-cadeaux',
   'Code             Titulaire                       Init     Solde    Etat',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To GCCount - 1 Do
    If GiftCards[I].Active And (MyKeyPad(GiftCards[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextGCID;
    NR.InitVal := 25.0; NR.Balance := 25.0;
    NR.IssueDate := 20260101; NR.ExpDate := 20271231;
    NR.Status := GC_ACTIVE;
    If DlgGCForm(NR, True) Then Begin
     If GCCount >= MAX_GIFTCARD Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      GiftCards[GCCount] := NR; Inc(GCCount); Inc(NextGCID);
      B := MyTableInsert(GCTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgGCDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    GiftCards[Sel].Active := False;
    B := MyTableDelete(GCTable, MyKeyPad(GiftCards[Sel].Code));
    If B Then ShowMessageBox('OK', 'Carte supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgGCIssue;
Var NR: TGiftCard; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextGCID;
 NR.InitVal := 25.0; NR.Balance := 25.0;
 NR.IssueDate := 20260101; NR.ExpDate := 20271231;
 NR.Status := GC_ACTIVE;
 If Not DlgGCForm(NR, True) Then Exit;
 If GCCount >= MAX_GIFTCARD Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 GiftCards[GCCount] := NR; Inc(GCCount); Inc(NextGCID);
 B := MyTableInsert(GCTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgGCRedeem;
Var C, A: String; Idx: Integer; Amt: Real; ErrC: Integer; OK: Boolean;
Begin
 C := '';
 If Not ShowInputBox('Utilisation', 'Code carte:', C, 16) Then Exit;
 Idx := FindGCByCode(C);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 If GiftCards[Idx].Status <> GC_ACTIVE Then Begin ShowMessageBox('Err', 'Carte inactive.'); Exit; End;
 A := '0';
 If Not ShowInputBox('Utilisation', 'Montant:', A, 8) Then Exit;
 Val(A, Amt, ErrC);
 If ErrC <> 0 Then Amt := 0;
 If Amt > GiftCards[Idx].Balance Then
 Begin ShowMessageBox('Err', 'Solde insuffisant.'); Exit; End;
 GiftCards[Idx].Balance := GiftCards[Idx].Balance - Amt;
 If GiftCards[Idx].Balance <= 0 Then GiftCards[Idx].Status := GC_USED;
 OK := MyTableUpdate(GCTable, MyKeyPad(GiftCards[Idx].Code), GiftCards[Idx]);
 If OK Then
  ShowMessageBox('OK', 'Nouveau solde : ' + RealToStr(GiftCards[Idx].Balance, 6, 2) + ' (sauvegarde GIFTCARD.MYD)')
 Else
  ShowMessageBox('Avertissement', 'Solde modifie en RAM mais MyTableUpdate a echoue.');
End;

Procedure DlgGCBal;
Var C: String; Idx: Integer;
Begin
 C := '';
 If Not ShowInputBox('Solde', 'Code carte:', C, 16) Then Exit;
 Idx := FindGCByCode(C);
 If Idx < 0 Then ShowMessageBox('Err', 'Introuvable.')
 Else ShowMessageBox('Solde', 'Solde : ' + RealToStr(GiftCards[Idx].Balance, 6, 2) +
      ' (Etat: ' + GCStatusLabel(GiftCards[Idx].Status) + ')');
End;

Procedure DlgGCRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport cartes-cadeaux', 380, 220);
 DlgAddLabel(D, 16, 20, 'Total emis      : ' + IntToStrPad(GCCount, 0));
 DlgAddLabel(D, 16, 40, 'Actives         : ' + IntToStrPad(CountActiveGC, 0));
 DlgAddLabel(D, 16, 60, 'Solde residuel  : ' + RealToStr(SumGCBalance, 10, 2));
 DlgAddButton(D, 280, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgSrvForm(Var R: TMallService; IsNew: Boolean): Boolean;
Var D: TDialog; EC, EK, EDe, ETs, EAv, EFe: Integer; Btn: SmallInt; T: String;
Begin
 DlgSrvForm := False;
 If IsNew Then T := 'Nouveau service' Else T := 'Editer service';
 DlgInit(D, T, 540, 320);
 DlgAddFrame(D, 12, 16, 516, 240, 'Service mall');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Type     :'); EK  := DlgAddNumEdit(D, 160, 60,  60, IntToStrPad(R.Kind, 0), 2, False);
 DlgAddLabel(D, 24, 88,  'Descr.   :'); EDe := DlgAddEdit(D, 160, 84,  340, R.Descr, 40);
 DlgAddLabel(D, 24, 112, 'Stock tot:'); ETs := DlgAddNumEdit(D, 160, 108, 80, IntToStrPad(R.TotalStock, 0), 4, False);
 DlgAddLabel(D, 24, 136, 'Disponib.:'); EAv := DlgAddNumEdit(D, 160, 132, 80, IntToStrPad(R.Available, 0), 4, False);
 DlgAddLabel(D, 24, 160, 'Tarif    :'); EFe := DlgAddNumEdit(D, 160, 156, 120, RealToStr(R.Fee, 0, 2), 10, True);
 DlgAddButton(D, 300, 276, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 276, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 ShowMessageBox('DBG Form', 'Btn=' + IntToStrPad(Btn, 0) + ' Code=[' + D.Ctrls[EC].Text + ']');
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text;
 R.Kind := StrToIntDef(D.Ctrls[EK].Text, R.Kind);
 R.Descr := D.Ctrls[EDe].Text;
 R.TotalStock := StrToIntDef(D.Ctrls[ETs].Text, R.TotalStock);
 R.Available := StrToIntDef(D.Ctrls[EAv].Text, R.Available);
 R.Fee := StrToRealDef(D.Ctrls[EFe].Text, R.Fee);
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgSrvForm := True;
End;

Procedure DlgSrvDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= ServiceCount) Then Exit;
 DlgInit(D, 'Service ' + Services[Idx].Code, 460, 260);
 DlgAddFrame(D, 12, 16, 436, 180, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code     : ' + Services[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Type     : ' + ServiceKindLabel(Services[Idx].Kind));
 DlgAddLabel(D, 24, 80,  'Descr.   : ' + Services[Idx].Descr);
 DlgAddLabel(D, 24, 100, 'Stock    : ' + IntToStrPad(Services[Idx].TotalStock, 0));
 DlgAddLabel(D, 24, 120, 'Disponib.: ' + IntToStrPad(Services[Idx].Available, 0));
 DlgAddLabel(D, 24, 140, 'Tarif    : ' + RealToStr(Services[Idx].Fee, 0, 2));
 DlgAddButton(D, 360, 220, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgSrvList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TMallService; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To ServiceCount - 1 Do
   If Services[I].Active Then Begin
    S := Services[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + ServiceKindLabel(Services[I].Kind);
    While Length(S) < 23 Do S := S + ' ';
    S := S + Services[I].Descr;
    While Length(S) < 55 Do S := S + ' ';
    S := S + IntToStrPad(Services[I].Available, 3) + '/' + IntToStrPad(Services[I].TotalStock, 3) + '  ' +
         RealToStr(Services[I].Fee, 6, 2);
    BrowseAdd(S, MyKeyPad(Services[I].Code));
   End;
  Action := ShowDBBrowser('Services mall',
   'Code       Type        Description                          Disp/Tot  Tarif',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To ServiceCount - 1 Do
    If Services[I].Active And (MyKeyPad(Services[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextSrvID;
    NR.Kind := SRV_OTHER; NR.TotalStock := 1; NR.Available := 1;
    If DlgSrvForm(NR, True) Then Begin
     If ServiceCount >= MAX_SERVICE Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Services[ServiceCount] := NR; Inc(ServiceCount); Inc(NextSrvID);
      B := MyTableInsert(SrvTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgSrvDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Services[Sel].Active := False;
    B := MyTableDelete(SrvTable, MyKeyPad(Services[Sel].Code));
    If B Then ShowMessageBox('OK', 'Service supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgSrvNew;
Var NR: TMallService; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextSrvID;
 NR.Kind := SRV_OTHER; NR.TotalStock := 1; NR.Available := 1;
 If Not DlgSrvForm(NR, True) Then Exit;
 If ServiceCount >= MAX_SERVICE Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Services[ServiceCount] := NR; Inc(ServiceCount); Inc(NextSrvID);
 B := MyTableInsert(SrvTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgSrvLend;
Var C: String; Idx: Integer; OK: Boolean;
Begin
 C := '';
 If Not ShowInputBox('Pret', 'Code service:', C, 10) Then Exit;
 Idx := FindSrvByCode(C);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 If Services[Idx].Available <= 0 Then Begin ShowMessageBox('Err', 'Aucun disponible.'); Exit; End;
 Services[Idx].Available := Services[Idx].Available - 1;
 OK := MyTableUpdate(SrvTable, MyKeyPad(Services[Idx].Code), Services[Idx]);
 If OK Then
  ShowMessageBox('OK', 'Prete. Restant : ' + IntToStrPad(Services[Idx].Available, 0) + ' (SERVICE.MYD a jour)')
 Else
  ShowMessageBox('Avertissement', 'Stock modifie en RAM mais MyTableUpdate a echoue.');
End;

Procedure DlgSrvReturn;
Var C: String; Idx: Integer; OK: Boolean;
Begin
 C := '';
 If Not ShowInputBox('Retour', 'Code service:', C, 10) Then Exit;
 Idx := FindSrvByCode(C);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 If Services[Idx].Available >= Services[Idx].TotalStock Then Begin ShowMessageBox('Err', 'Stock complet.'); Exit; End;
 Services[Idx].Available := Services[Idx].Available + 1;
 OK := MyTableUpdate(SrvTable, MyKeyPad(Services[Idx].Code), Services[Idx]);
 If OK Then
  ShowMessageBox('OK', 'Retourne. Stock : ' + IntToStrPad(Services[Idx].Available, 0) + ' (SERVICE.MYD a jour)')
 Else
  ShowMessageBox('Avertissement', 'Stock modifie en RAM mais MyTableUpdate a echoue.');
End;

Procedure DlgSrvRpt;
Var D: TDialog; Btn: SmallInt; I, Tot, Avail: Integer;
Begin
 Tot := 0; Avail := 0;
 For I := 0 To ServiceCount - 1 Do
  If Services[I].Active Then
  Begin Tot := Tot + Services[I].TotalStock; Avail := Avail + Services[I].Available; End;
 DlgInit(D, 'Rapport services', 380, 220);
 DlgAddLabel(D, 16, 20, 'Services offerts : ' + IntToStrPad(ServiceCount, 0));
 DlgAddLabel(D, 16, 40, 'Stock total      : ' + IntToStrPad(Tot, 0));
 DlgAddLabel(D, 16, 60, 'Disponible       : ' + IntToStrPad(Avail, 0));
 DlgAddLabel(D, 16, 80, 'Loue actuellement: ' + IntToStrPad(Tot - Avail, 0));
 DlgAddButton(D, 280, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgHrsForm(Var R: THours; IsNew: Boolean): Boolean;
Var D: TDialog; EDay, EOh, EOm, ECh, ECm, EN: Integer; Btn: SmallInt; T: String;
Begin
 DlgHrsForm := False;
 If IsNew Then T := 'Nouvel horaire' Else T := 'Editer horaire';
 DlgInit(D, T, 480, 300);
 DlgAddFrame(D, 12, 16, 456, 220, 'Horaire jour');
 DlgAddLabel(D, 24, 40,  'Jour 1-7 :'); EDay := DlgAddNumEdit(D, 160, 36,  60,  IntToStrPad(R.Day, 0), 1, False);
 DlgAddLabel(D, 24, 64,  'Ouv. H   :'); EOh  := DlgAddNumEdit(D, 160, 60,  60,  IntToStrPad(R.OpenHour, 0), 2, False);
 DlgAddLabel(D, 24, 88,  'Ouv. Min :'); EOm  := DlgAddNumEdit(D, 160, 84,  60,  IntToStrPad(R.OpenMin, 0), 2, False);
 DlgAddLabel(D, 24, 112, 'Ferm. H  :'); ECh  := DlgAddNumEdit(D, 160, 108, 60,  IntToStrPad(R.CloseHour, 0), 2, False);
 DlgAddLabel(D, 24, 136, 'Ferm. Min:'); ECm  := DlgAddNumEdit(D, 160, 132, 60,  IntToStrPad(R.CloseMin, 0), 2, False);
 DlgAddLabel(D, 24, 160, 'Note     :'); EN   := DlgAddEdit(D, 160, 156, 280, R.Note, 30);
 DlgAddButton(D, 240, 256, 100, 'OK',      1, 'O');
 DlgAddButton(D, 356, 256, 100, 'Annuler',-1, 'A');
 D.Focus := EDay;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Day       := StrToIntDef(D.Ctrls[EDay].Text, R.Day);
 R.OpenHour  := StrToIntDef(D.Ctrls[EOh].Text, R.OpenHour);
 R.OpenMin   := StrToIntDef(D.Ctrls[EOm].Text, R.OpenMin);
 R.CloseHour := StrToIntDef(D.Ctrls[ECh].Text, R.CloseHour);
 R.CloseMin  := StrToIntDef(D.Ctrls[ECm].Text, R.CloseMin);
 R.Note      := D.Ctrls[EN].Text;
 If (R.Day < 1) Or (R.Day > 7) Then Begin ShowMessageBox('Err', 'Jour 1..7.'); Exit; End;
 DlgHrsForm := True;
End;

Procedure DlgHrsDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= HoursCount) Then Exit;
 DlgInit(D, 'Horaire ' + DayLabel(HoursTbl[Idx].Day), 420, 240);
 DlgAddFrame(D, 12, 16, 396, 160, 'Informations');
 DlgAddLabel(D, 24, 40,  'Jour      : ' + DayLabel(HoursTbl[Idx].Day));
 DlgAddLabel(D, 24, 60,  'Ouverture : ' + IntToStrPad(HoursTbl[Idx].OpenHour, 2) + 'h' + IntToStrPad(HoursTbl[Idx].OpenMin, 2));
 DlgAddLabel(D, 24, 80,  'Fermeture : ' + IntToStrPad(HoursTbl[Idx].CloseHour, 2) + 'h' + IntToStrPad(HoursTbl[Idx].CloseMin, 2));
 DlgAddLabel(D, 24, 100, 'Note      : ' + HoursTbl[Idx].Note);
 DlgAddButton(D, 320, 200, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgHrsList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: THours; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To HoursCount - 1 Do
   If HoursTbl[I].Active Then Begin
    S := DayLabel(HoursTbl[I].Day);
    While Length(S) < 14 Do S := S + ' ';
    S := S + IntToStrPad(HoursTbl[I].OpenHour, 2) + ':' + IntToStrPad(HoursTbl[I].OpenMin, 2);
    While Length(S) < 26 Do S := S + ' ';
    S := S + IntToStrPad(HoursTbl[I].CloseHour, 2) + ':' + IntToStrPad(HoursTbl[I].CloseMin, 2);
    While Length(S) < 38 Do S := S + ' ';
    S := S + HoursTbl[I].Note;
    BrowseAdd(S, MyKeyFromID('H', HoursTbl[I].ID));
   End;
  Action := ShowDBBrowser('Heures d ouverture',
   'Jour          Ouverture     Fermeture   Note',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To HoursCount - 1 Do
    If HoursTbl[I].Active And (MyKeyFromID('H', HoursTbl[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextHrID;
    NR.Day := 1; NR.OpenHour := 10; NR.CloseHour := 21;
    If DlgHrsForm(NR, True) Then Begin
     If HoursCount >= MAX_HOURS Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      HoursTbl[HoursCount] := NR; Inc(HoursCount); Inc(NextHrID);
      B := MyTableInsert(HoursTable, MyKeyFromID('H', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgHrsDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    HoursTbl[Sel].Active := False;
    B := MyTableDelete(HoursTable, MyKeyFromID('H', HoursTbl[Sel].ID));
    If B Then ShowMessageBox('OK', 'Horaire supprime.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgHrsEdit;
Var S: String; Day: Byte; Idx: Integer; R: THours; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Editer', 'Jour (1-7):', S, 1) Then Exit;
 Day := StrToIntDef(S, 0);
 If (Day < 1) Or (Day > 7) Then Begin ShowMessageBox('Err', 'Jour invalide.'); Exit; End;
 Idx := FindHrsByDay(Day);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Non trouve.'); Exit; End;
 R := HoursTbl[Idx];
 If Not DlgHrsForm(R, False) Then Exit;
 HoursTbl[Idx] := R;
 B := MyTableUpdate(HoursTable, MyKeyFromID('H', R.ID), R);
 If Not B Then ShowMessageBox('Avert', 'Maj .MYD echouee.');
End;

Procedure DlgHrsToday;
Var D: TDialog; Btn: SmallInt; DT: TDateTime; Day: Byte; Idx: Integer;
Begin
 GetCurrentDT(DT);
 Day := 1 + ((DT.Day - 1) Mod 7);
 Idx := FindHrsByDay(Day);
 DlgInit(D, 'Horaires aujourdhui', 400, 200);
 DlgAddLabel(D, 16, 20, 'Jour : ' + DayLabel(Day));
 If Idx >= 0 Then
 Begin
  DlgAddLabel(D, 16, 40, 'Ouverture  : ' + IntToStrPad(HoursTbl[Idx].OpenHour, 2) + 'h' +
   IntToStrPad(HoursTbl[Idx].OpenMin, 2));
  DlgAddLabel(D, 16, 60, 'Fermeture  : ' + IntToStrPad(HoursTbl[Idx].CloseHour, 2) + 'h' +
   IntToStrPad(HoursTbl[Idx].CloseMin, 2));
  DlgAddLabel(D, 16, 80, 'Note       : ' + HoursTbl[Idx].Note);
 End
 Else DlgAddLabel(D, 16, 40, '(Aucune entree pour ce jour)');
 DlgAddButton(D, 300, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgHrsRpt;
Var D: TDialog; Btn: SmallInt; I, Sum: Integer;
Begin
 Sum := 0;
 For I := 0 To HoursCount - 1 Do
  If HoursTbl[I].Active Then
   Sum := Sum + (HoursTbl[I].CloseHour - HoursTbl[I].OpenHour);
 DlgInit(D, 'Rapport horaires', 380, 200);
 DlgAddLabel(D, 16, 20, 'Jours configures   : ' + IntToStrPad(HoursCount, 0));
 DlgAddLabel(D, 16, 40, 'Heures totales/sem : ' + IntToStrPad(Sum, 0));
 DlgAddButton(D, 280, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgInsForm(Var R: TInspection; IsNew: Boolean): Boolean;
Var D: TDialog; EC, ECa, EA, EDt, EIn, ERe, ENo: Integer; Btn: SmallInt; T: String;
Begin
 DlgInsForm := False;
 If IsNew Then T := 'Nouvelle inspection' Else T := 'Editer inspection';
 DlgInit(D, T, 540, 360);
 DlgAddFrame(D, 12, 16, 516, 280, 'Inspection');
 DlgAddLabel(D, 24, 40,  'Code     :'); EC  := DlgAddEdit(D, 160, 36,  120, R.Code, 10);
 DlgAddLabel(D, 24, 64,  'Categorie:'); ECa := DlgAddNumEdit(D, 160, 60,  60, IntToStrPad(R.Category, 0), 2, False);
 DlgAddLabel(D, 24, 88,  'Zone     :'); EA  := DlgAddEdit(D, 160, 84,  320, R.Area, 30);
 DlgAddLabel(D, 24, 112, 'Date     :'); EDt := DlgAddNumEdit(D, 160, 108, 100, IntToStrPad(R.InspDate, 0), 8, False);
 DlgAddLabel(D, 24, 136, 'Inspect. :'); EIn := DlgAddEdit(D, 160, 132, 320, R.Inspector, 30);
 DlgAddLabel(D, 24, 160, 'Resultat :'); ERe := DlgAddNumEdit(D, 160, 156, 60,  IntToStrPad(R.Result, 0), 1, False);
 DlgAddLabel(D, 24, 184, 'Notes    :'); ENo := DlgAddEdit(D, 160, 180, 340, R.Notes, 60);
 DlgAddButton(D, 300, 316, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 316, 100, 'Annuler',-1, 'A');
 D.Focus := EC;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.Code := D.Ctrls[EC].Text;
 R.Category := StrToIntDef(D.Ctrls[ECa].Text, R.Category);
 R.Area := D.Ctrls[EA].Text;
 R.InspDate := StrToIntDef(D.Ctrls[EDt].Text, R.InspDate);
 R.Inspector := D.Ctrls[EIn].Text;
 R.Result := StrToIntDef(D.Ctrls[ERe].Text, R.Result);
 R.Notes := D.Ctrls[ENo].Text;
 If R.Code = '' Then Begin ShowMessageBox('Err', 'Code obligatoire.'); Exit; End;
 DlgInsForm := True;
End;

Procedure DlgInsDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= InspCount) Then Exit;
 DlgInit(D, 'Inspection ' + Inspections[Idx].Code, 480, 320);
 DlgAddFrame(D, 12, 16, 456, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'Code      : ' + Inspections[Idx].Code);
 DlgAddLabel(D, 24, 60,  'Categorie : ' + InspCatLabel(Inspections[Idx].Category));
 DlgAddLabel(D, 24, 80,  'Zone      : ' + Inspections[Idx].Area);
 DlgAddLabel(D, 24, 100, 'Date      : ' + IntToStrPad(Inspections[Idx].InspDate, 0));
 DlgAddLabel(D, 24, 120, 'Inspect.  : ' + Inspections[Idx].Inspector);
 DlgAddLabel(D, 24, 140, 'Resultat  : ' + InspResultLabel(Inspections[Idx].Result));
 DlgAddLabel(D, 24, 160, 'Notes     : ' + Inspections[Idx].Notes);
 DlgAddButton(D, 380, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgInsList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TInspection; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To InspCount - 1 Do
   If Inspections[I].Active Then Begin
    S := Inspections[I].Code;
    While Length(S) < 11 Do S := S + ' ';
    S := S + InspCatLabel(Inspections[I].Category);
    While Length(S) < 21 Do S := S + ' ';
    S := S + Inspections[I].Area;
    While Length(S) < 43 Do S := S + ' ';
    S := S + IntToStrPad(Inspections[I].InspDate, 8) + '  ';
    S := S + Inspections[I].Inspector;
    While Length(S) < 72 Do S := S + ' ';
    S := S + InspResultLabel(Inspections[I].Result);
    BrowseAdd(S, MyKeyPad(Inspections[I].Code));
   End;
  Action := ShowDBBrowser('Inspections',
   'Code       Cat.      Zone                    Date      Inspecteur            Res.',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To InspCount - 1 Do
    If Inspections[I].Active And (MyKeyPad(Inspections[I].Code) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextInspID;
    NR.Category := IC_GENERAL; NR.InspDate := 20260101; NR.Result := INS_OK;
    If DlgInsForm(NR, True) Then Begin
     If InspCount >= MAX_INSPECTION Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Inspections[InspCount] := NR; Inc(InspCount); Inc(NextInspID);
      B := MyTableInsert(InspTable, MyKeyPad(NR.Code), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgInsDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Inspections[Sel].Active := False;
    B := MyTableDelete(InspTable, MyKeyPad(Inspections[Sel].Code));
    If B Then ShowMessageBox('OK', 'Inspection supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgInsNew;
Var NR: TInspection; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextInspID;
 NR.Category := IC_GENERAL; NR.InspDate := 20260101; NR.Result := INS_OK;
 If Not DlgInsForm(NR, True) Then Exit;
 If InspCount >= MAX_INSPECTION Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Inspections[InspCount] := NR; Inc(InspCount); Inc(NextInspID);
 B := MyTableInsert(InspTable, MyKeyPad(NR.Code), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgInsView;
Var S: String; ID: LongInt; Idx: Integer; D: TDialog; Btn: SmallInt;
Begin
 S := '';
 If Not ShowInputBox('Voir', 'ID:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindInspByID(ID);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 DlgInit(D, 'Inspection ' + Inspections[Idx].Code, 420, 260);
 DlgAddLabel(D, 16, 20, 'Code         : ' + Inspections[Idx].Code);
 DlgAddLabel(D, 16, 40, 'Categorie    : ' + InspCatLabel(Inspections[Idx].Category));
 DlgAddLabel(D, 16, 60, 'Zone         : ' + Inspections[Idx].Area);
 DlgAddLabel(D, 16, 80, 'Date         : ' + IntToStrPad(Inspections[Idx].InspDate, 8));
 DlgAddLabel(D, 16, 100, 'Inspecteur   : ' + Inspections[Idx].Inspector);
 DlgAddLabel(D, 16, 120, 'Resultat     : ' + InspResultLabel(Inspections[Idx].Result));
 DlgAddButton(D, 320, 220, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgInsFailed;
Var D: TDialog; Btn: SmallInt; I, N, Y: Integer; S: String;
Begin
 DlgInit(D, 'Inspections echec/majeures', 580, 340);
 Y := 20; N := 0;
 For I := 0 To InspCount - 1 Do
  If Inspections[I].Active And ((Inspections[I].Result = INS_FAIL) Or (Inspections[I].Result = INS_MAJOR)) And (Y < 300) Then
  Begin
   N := N + 1;
   S := Inspections[I].Code + '  ' + InspCatLabel(Inspections[I].Category) + '  ' +
        Inspections[I].Area + ' - ' + InspResultLabel(Inspections[I].Result);
   DlgAddLabel(D, 16, Y, S);
   Y := Y + 14;
  End;
 DlgAddLabel(D, 16, 310, 'Total : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 480, 300, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgInsRpt;
Var D: TDialog; Btn: SmallInt; I, NO, NM, NJ, NF: Integer;
Begin
 NO := 0; NM := 0; NJ := 0; NF := 0;
 For I := 0 To InspCount - 1 Do
  If Inspections[I].Active Then
   Case Inspections[I].Result Of
    INS_OK   : NO := NO + 1;
    INS_MINOR: NM := NM + 1;
    INS_MAJOR: NJ := NJ + 1;
    INS_FAIL : NF := NF + 1;
   End;
 DlgInit(D, 'Rapport inspections', 380, 260);
 DlgAddLabel(D, 16, 20, 'Total inspections : ' + IntToStrPad(InspCount, 0));
 DlgAddLabel(D, 16, 40, 'OK                : ' + IntToStrPad(NO, 0));
 DlgAddLabel(D, 16, 60, 'Mineures          : ' + IntToStrPad(NM, 0));
 DlgAddLabel(D, 16, 80, 'Majeures          : ' + IntToStrPad(NJ, 0));
 DlgAddLabel(D, 16, 100, 'Echecs            : ' + IntToStrPad(NF, 0));
 DlgAddButton(D, 280, 220, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgCplForm(Var R: TComplaint; IsNew: Boolean): Boolean;
Var D: TDialog; ED, ECa, ESo, EDe, ESt, ERs: Integer; Btn: SmallInt; T: String;
Begin
 DlgCplForm := False;
 If IsNew Then T := 'Nouvelle plainte' Else T := 'Editer plainte';
 DlgInit(D, T, 540, 360);
 DlgAddFrame(D, 12, 16, 516, 280, 'Plainte');
 DlgAddLabel(D, 24, 40,  'Date     :'); ED  := DlgAddNumEdit(D, 160, 36,  100, IntToStrPad(R.RecDate, 0), 8, False);
 DlgAddLabel(D, 24, 64,  'Categorie:'); ECa := DlgAddNumEdit(D, 160, 60,  60, IntToStrPad(R.Category, 0), 2, False);
 DlgAddLabel(D, 24, 88,  'Source   :'); ESo := DlgAddEdit(D, 160, 84,  240, R.Source, 20);
 DlgAddLabel(D, 24, 112, 'Descr.   :'); EDe := DlgAddEdit(D, 160, 108, 340, R.Descr, 80);
 DlgAddLabel(D, 24, 136, 'Statut   :'); ESt := DlgAddNumEdit(D, 160, 132, 60,  IntToStrPad(R.Status, 0), 1, False);
 DlgAddLabel(D, 24, 160, 'Reponse  :'); ERs := DlgAddEdit(D, 160, 156, 340, R.Response, 60);
 DlgAddButton(D, 300, 316, 100, 'OK',      1, 'O');
 DlgAddButton(D, 416, 316, 100, 'Annuler',-1, 'A');
 D.Focus := ED;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.RecDate := StrToIntDef(D.Ctrls[ED].Text, R.RecDate);
 R.Category := StrToIntDef(D.Ctrls[ECa].Text, R.Category);
 R.Source := D.Ctrls[ESo].Text;
 R.Descr := D.Ctrls[EDe].Text;
 R.Status := StrToIntDef(D.Ctrls[ESt].Text, R.Status);
 R.Response := D.Ctrls[ERs].Text;
 DlgCplForm := True;
End;

Procedure DlgCplDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= ComplCount) Then Exit;
 DlgInit(D, 'Plainte #' + IntToStrPad(Complaints[Idx].ID, 0), 500, 320);
 DlgAddFrame(D, 12, 16, 476, 240, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID        : ' + IntToStrPad(Complaints[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Date      : ' + IntToStrPad(Complaints[Idx].RecDate, 0));
 DlgAddLabel(D, 24, 80,  'Categorie : ' + ComplCatLabel(Complaints[Idx].Category));
 DlgAddLabel(D, 24, 100, 'Source    : ' + Complaints[Idx].Source);
 DlgAddLabel(D, 24, 120, 'Descr.    : ' + Copy(Complaints[Idx].Descr, 1, 70));
 DlgAddLabel(D, 24, 140, 'Statut    : ' + ComplStatusLabel(Complaints[Idx].Status));
 DlgAddLabel(D, 24, 160, 'Reponse   : ' + Copy(Complaints[Idx].Response, 1, 60));
 DlgAddButton(D, 400, 280, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgCplList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TComplaint; DT: TDateTime; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To ComplCount - 1 Do
   If Complaints[I].Active Then Begin
    S := IntToStrPad(Complaints[I].ID, 4) + '  ' +
         IntToStrPad(Complaints[I].RecDate, 8) + '  ' +
         ComplCatLabel(Complaints[I].Category);
    While Length(S) < 32 Do S := S + ' ';
    S := S + ComplStatusLabel(Complaints[I].Status);
    While Length(S) < 44 Do S := S + ' ';
    S := S + Complaints[I].Source;
    While Length(S) < 58 Do S := S + ' ';
    S := S + Copy(Complaints[I].Descr, 1, 40);
    BrowseAdd(S, MyKeyFromID('P', Complaints[I].ID));
   End;
  Action := ShowDBBrowser('Plaintes',
   'ID    Date      Cat.      Etat        Source        Description',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To ComplCount - 1 Do
    If Complaints[I].Active And (MyKeyFromID('P', Complaints[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextComplID;
    GetCurrentDT(DT);
    NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
    NR.Category := CC_OTHER; NR.Status := CPL_OPEN;
    If DlgCplForm(NR, True) Then Begin
     If ComplCount >= MAX_COMPLAINT Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      Complaints[ComplCount] := NR; Inc(ComplCount); Inc(NextComplID);
      B := MyTableInsert(ComplTable, MyKeyFromID('P', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgCplDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    Complaints[Sel].Active := False;
    B := MyTableDelete(ComplTable, MyKeyFromID('P', Complaints[Sel].ID));
    If B Then ShowMessageBox('OK', 'Plainte supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgCplNew;
Var NR: TComplaint; DT: TDateTime; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextComplID;
 GetCurrentDT(DT);
 NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 NR.Category := CC_OTHER; NR.Status := CPL_OPEN;
 If Not DlgCplForm(NR, True) Then Exit;
 If ComplCount >= MAX_COMPLAINT Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 Complaints[ComplCount] := NR; Inc(ComplCount); Inc(NextComplID);
 B := MyTableInsert(ComplTable, MyKeyFromID('P', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgCplResp;
Var S, R: String; ID: LongInt; Idx: Integer; B: Boolean;
Begin
 S := '';
 If Not ShowInputBox('Reponse', 'ID plainte:', S, 6) Then Exit;
 ID := StrToIntDef(S, 0);
 Idx := FindComplByID(ID);
 If Idx < 0 Then Begin ShowMessageBox('Err', 'Introuvable.'); Exit; End;
 R := '';
 If Not ShowInputBox('Reponse', 'Texte reponse:', R, 60) Then Exit;
 Complaints[Idx].Response := R;
 Complaints[Idx].Status := CPL_CLOSED;
 B := MyTableUpdate(ComplTable, MyKeyFromID('P', Complaints[Idx].ID), Complaints[Idx]);
 ShowMessageBox('OK', 'Reponse enregistree.');
End;

Procedure DlgCplRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport plaintes', 380, 200);
 DlgAddLabel(D, 16, 20, 'Total plaintes  : ' + IntToStrPad(ComplCount, 0));
 DlgAddLabel(D, 16, 40, 'Ouvertes        : ' + IntToStrPad(CountOpenCompl, 0));
 DlgAddButton(D, 280, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Function DlgPVForm(Var R: TParkValid; IsNew: Boolean): Boolean;
Var D: TDialog; ED, ET, ERf, EDi: Integer; Btn: SmallInt; T: String;
Begin
 DlgPVForm := False;
 If IsNew Then T := 'Nouvelle validation' Else T := 'Editer validation';
 DlgInit(D, T, 480, 280);
 DlgAddFrame(D, 12, 16, 456, 200, 'Validation parking');
 DlgAddLabel(D, 24, 40,  'Date     :'); ED  := DlgAddNumEdit(D, 160, 36,  100, IntToStrPad(R.RecDate, 0), 8, False);
 DlgAddLabel(D, 24, 64,  'ID bout. :'); ET  := DlgAddNumEdit(D, 160, 60,  80,  IntToStrPad(R.TenantID, 0), 6, False);
 DlgAddLabel(D, 24, 88,  'Ticket   :'); ERf := DlgAddEdit(D, 160, 84,  180, R.TicketRef, 12);
 DlgAddLabel(D, 24, 112, 'Remise % :'); EDi := DlgAddNumEdit(D, 160, 108, 60,  IntToStrPad(R.Discount, 0), 3, False);
 DlgAddButton(D, 240, 236, 100, 'OK',      1, 'O');
 DlgAddButton(D, 356, 236, 100, 'Annuler',-1, 'A');
 D.Focus := ED;
 Btn := DlgRun(D);
 If Btn <> 1 Then Exit;
 R.RecDate := StrToIntDef(D.Ctrls[ED].Text, R.RecDate);
 R.TenantID := StrToIntDef(D.Ctrls[ET].Text, R.TenantID);
 R.TicketRef := D.Ctrls[ERf].Text;
 R.Discount := StrToIntDef(D.Ctrls[EDi].Text, R.Discount);
 DlgPVForm := True;
End;

Procedure DlgPVDetail(Idx: Integer);
Var D: TDialog; Btn: SmallInt;
Begin
 If (Idx < 0) Or (Idx >= PVCount) Then Exit;
 DlgInit(D, 'Validation #' + IntToStrPad(ParkValids[Idx].ID, 0), 420, 240);
 DlgAddFrame(D, 12, 16, 396, 160, 'Informations');
 DlgAddLabel(D, 24, 40,  'ID       : ' + IntToStrPad(ParkValids[Idx].ID, 0));
 DlgAddLabel(D, 24, 60,  'Date     : ' + IntToStrPad(ParkValids[Idx].RecDate, 0));
 DlgAddLabel(D, 24, 80,  'Boutique : ' + IntToStrPad(ParkValids[Idx].TenantID, 0));
 DlgAddLabel(D, 24, 100, 'Ticket   : ' + ParkValids[Idx].TicketRef);
 DlgAddLabel(D, 24, 120, 'Remise   : ' + IntToStrPad(ParkValids[Idx].Discount, 0) + '%');
 DlgAddButton(D, 320, 200, 88, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgPVList;
Var I, Sel, Action: Integer; S: String; K: TMyKey; NR: TParkValid; DT: TDateTime; B: Boolean;
Begin
 Repeat
  BrowseClear;
  For I := 0 To PVCount - 1 Do
   If ParkValids[I].Active Then Begin
    S := IntToStrPad(ParkValids[I].ID, 4) + '  ' +
         IntToStrPad(ParkValids[I].RecDate, 8) + '  ' +
         IntToStrPad(ParkValids[I].TenantID, 4) + '  ' +
         ParkValids[I].TicketRef;
    While Length(S) < 50 Do S := S + ' ';
    S := S + IntToStrPad(ParkValids[I].Discount, 3) + '%';
    BrowseAdd(S, MyKeyFromID('V', ParkValids[I].ID));
   End;
  Action := ShowDBBrowser('Validations parking',
   'ID    Date      Bout. Ticket             Disc.',
   True, True, True);
  K := BrowseSelectedKey; Sel := -1;
  If K <> '' Then
   For I := 0 To PVCount - 1 Do
    If ParkValids[I].Active And (MyKeyFromID('V', ParkValids[I].ID) = K) Then
     Begin Sel := I; Break; End;
  Case Action Of
   BR_NEW: Begin
    FillChar(NR, SizeOf(NR), 0);
    NR.Active := True; NR.ID := NextPVID;
    GetCurrentDT(DT);
    NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
    NR.Discount := 10;
    If DlgPVForm(NR, True) Then Begin
     If PVCount >= MAX_PARK_VALID Then ShowMessageBox('Err', 'Capacite.')
     Else Begin
      ParkValids[PVCount] := NR; Inc(PVCount); Inc(NextPVID);
      B := MyTableInsert(PVTable, MyKeyFromID('V', NR.ID), NR);
      If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
     End;
    End;
   End;
   BR_DETAIL: If Sel >= 0 Then DlgPVDetail(Sel) Else ShowMessageBox('Info', 'Aucune ligne.');
   BR_DELETE: If Sel >= 0 Then Begin
    ParkValids[Sel].Active := False;
    B := MyTableDelete(PVTable, MyKeyFromID('V', ParkValids[Sel].ID));
    If B Then ShowMessageBox('OK', 'Validation supprimee.') Else ShowMessageBox('Avert', '.MYD non modifie.');
   End Else ShowMessageBox('Info', 'Aucune ligne.');
  End;
 Until Action = BR_CLOSE;
End;

Procedure DlgPVRec;
Var NR: TParkValid; DT: TDateTime; B: Boolean;
Begin
 FillChar(NR, SizeOf(NR), 0);
 NR.Active := True; NR.ID := NextPVID;
 GetCurrentDT(DT);
 NR.RecDate := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 NR.Discount := 10;
 If Not DlgPVForm(NR, True) Then Exit;
 If PVCount >= MAX_PARK_VALID Then Begin ShowMessageBox('Err', 'Capacite.'); Exit; End;
 ParkValids[PVCount] := NR; Inc(PVCount); Inc(NextPVID);
 B := MyTableInsert(PVTable, MyKeyFromID('V', NR.ID), NR);
 If Not B Then ShowMessageBox('DB', 'Insertion .MYD echouee.');
End;

Procedure DlgPVToday;
Var D: TDialog; Btn: SmallInt; I, N: Integer; DT: TDateTime; Today: LongInt;
Begin
 GetCurrentDT(DT);
 Today := LongInt(DT.Year)*10000 + LongInt(DT.Month)*100 + DT.Day;
 N := 0;
 For I := 0 To PVCount - 1 Do
  If ParkValids[I].Active And (ParkValids[I].RecDate = Today) Then N := N + 1;
 DlgInit(D, 'Validations du jour', 380, 200);
 DlgAddLabel(D, 16, 20, 'Date            : ' + IntToStrPad(Today, 8));
 DlgAddLabel(D, 16, 40, 'Validations     : ' + IntToStrPad(N, 0));
 DlgAddButton(D, 280, 160, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;

Procedure DlgPVRpt;
Var D: TDialog; Btn: SmallInt;
Begin
 DlgInit(D, 'Rapport parking validations', 400, 220);
 DlgAddLabel(D, 16, 20, 'Total enregistrements : ' + IntToStrPad(PVCount, 0));
 DlgAddLabel(D, 16, 40, 'Cumul des remises (%) : ' + RealToStr(SumPVDiscount, 8, 0));
 DlgAddButton(D, 300, 180, 80, 'Fermer', 1, 'F');
 Btn := DlgRun(D);
End;
{ === END MALL_INC_Z_HAND.TXT === }
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

 { --- Initialisation modules MALL --- }
 InitSecurity;
 InitMallExt;
 InitMallExt2;
 InitMallExt3;
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
    If ShowConfirmBox('Quitter', 'Quitter MALL ?') Then
     QuitRequested := True;
   End;
  End;
  RedrawAll;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  If Ev.KeyChar = 'q' Then
   If ShowConfirmBox('Quitter', 'Quitter MALL ?') Then
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
      If (Ev.MouseY < MainMenuBar.Height) Then
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
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('MALL : Cette commande permet de lancer l''application ',
                    'gestion de centre commercial ',
                    '(Mall Management System).');
  WriteLn;
  Writeln('Syntaxe : MALL [/?]');
  WriteLn;
  Halt(0);
 End
  Else
 Begin
  InitializeGraphics;
  If MouseDriverFound Then ShowMouse;
  InitState;
  BuildMainMenu;
  RedrawAll;
  MainLoop;
  If MouseDriverFound Then HideMouse;
  CloseGraph;
 End;
END.
