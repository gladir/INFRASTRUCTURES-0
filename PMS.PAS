{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/infrastructures-0)
  @abstract(Target: Turbo Pascal 7, Free Pascal 3.2
  @description: Property Management System (PMS) - Gestion Hoteliere
}

Program PMS;

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
 PMS_VERSION      = '1.00';
 PMS_DATE         = '2026-05-31';

 SCREEN_W             = 640;
 SCREEN_H             = 480;
 MENUBAR_HEIGHT       = 20;
 STATUSBAR_HEIGHT     = 36;

 MAX_MENUS            = 16;
 MAX_MENU_ITEMS       = 16;

 MAX_COLS             = 12;
 MAX_ROWS             = 8;
 MAX_FLOORS           = 10;
 MAX_SPOTS            = MAX_COLS * MAX_ROWS * MAX_FLOORS;  { 960 chambres max }
 MAX_ROOMS_PER_FLOOR  = MAX_COLS * MAX_ROWS;
 FLOORTAB_HEIGHT      = 22;

 { Types de chambres }
 RT_STANDARD          = 0;
 RT_DOUBLE            = 1;
 RT_TWIN              = 2;
 RT_SUITE             = 3;
 RT_DELUXE            = 4;
 RT_FAMILY            = 5;
 RT_PENTHOUSE         = 6;
 RT_ACCESSIBLE        = 7;
 RT_TYPES             = 8;

 { Etat de menage / housekeeping }
 HK_CLEAN             = 0;       { propre, prete }
 HK_DIRTY             = 1;       { sale apres depart }
 HK_INSPECTED         = 2;       { inspectee, prete VIP }
 HK_OOO               = 3;       { out of order : maintenance }
 HK_OOS               = 4;       { out of service : non assignable }
 HK_INPROGRESS        = 5;       { menage en cours }
 HK_STATES            = 6;

 { Type de tarif saisonnier }
 SEASON_LOW           = 0;
 SEASON_MID           = 1;
 SEASON_HIGH          = 2;
 SEASON_PEAK          = 3;
 SEASON_CNT           = 4;

 { Categories de service / charges au folio }
 SVC_RESTAURANT       = 0;
 SVC_MINIBAR          = 1;
 SVC_BLANCHISSERIE    = 2;
 SVC_SPA              = 3;
 SVC_TELEPHONE        = 4;
 SVC_INTERNET         = 5;
 SVC_PARKING          = 6;
 SVC_TAXI             = 7;
 SVC_DIVERS           = 8;
 SVC_CATEGORIES       = 9;

 { Sources de reservation (channel manager) }
 CH_DIRECT            = 0;
 CH_WALKIN            = 1;
 CH_PHONE             = 2;
 CH_EMAIL             = 3;
 CH_BOOKING           = 4;
 CH_EXPEDIA           = 5;
 CH_AIRBNB            = 6;
 CH_GDS               = 7;
 CH_AGENCE            = 8;
 CH_CORPORATE         = 9;
 CH_GROUP             = 10;
 CH_COUNT             = 11;

 { Niveaux de fidelite }
 LOY_NONE             = 0;
 LOY_SILVER           = 1;
 LOY_GOLD             = 2;
 LOY_PLATINUM         = 3;
 LOY_DIAMOND          = 4;
 LOY_LEVELS           = 5;

 { Etat d une reservation }
 RES_CONFIRMED        = 0;
 RES_CHECKED_IN       = 1;
 RES_CHECKED_OUT      = 2;
 RES_NOSHOW           = 3;
 RES_CANCELLED        = 4;

 { Tailles diverses }
 MAX_GUESTS           = 400;
 MAX_RESERVATIONS     = 600;
 MAX_CHARGES          = 1500;
 MAX_GROUPS           = 40;
 MAX_RATEPLANS        = 12;
 MAX_MAINTENANCE      = 200;
 MAX_AUDIT_LOG        = 400;
 MAX_GUEST_HISTORY    = 8;

 MAX_DURATIONS        = 9;
 MAX_HISTORY          = 256;
 MAX_DAILY            = 31;

 { Modules etendus }
 MAX_TARIFFS          = 8;        { zones tarifaires }
 MAX_SUBSCRIPTIONS    = 100;      { abonnements clients }
 MAX_CHART_POINTS     = 31;       { points pour graphique }
 MAX_REPORT_LINES     = 96;       { lignes texte pour rapports }
 MAX_HIST_VIEW        = 256;      { entrees affichables dans historique }
 MAX_FILTER_PLATE     = 15;       { longueur filtre folio }

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

 TAG_ROOM_RESERVE     = 310;
 TAG_ROOM_FREE        = 311;
 TAG_ROOM_INFO        = 312;
 TAG_ROOM_SEARCH      = 313;
 TAG_ROOM_EXTEND      = 314;
 TAG_ROOM_FORCE       = 315;

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

 { Menu Etages }
 TAG_FLOOR_CONFIG     = 1610;
 TAG_FLOOR_NEXT       = 1611;
 TAG_FLOOR_PREV       = 1612;
 TAG_FLOOR_FIRST      = 1613;
 TAG_FLOOR_LAST       = 1614;
 TAG_FLOOR_OVERVIEW   = 1615;
 TAG_FLOOR_NAMES      = 1616;

 { Menu Chambres (PMS specific) }
 TAG_ROOM_CHECKIN     = 1710;
 TAG_ROOM_CHECKOUT    = 1711;
 TAG_ROOM_TYPES       = 1712;
 TAG_ROOM_RENAME      = 1713;
 TAG_ROOM_NIGHTAUDIT  = 1714;
 TAG_ROOM_QUICKBOOK   = 1715;

 { Menu Housekeeping }
 TAG_HK_LIST          = 1810;
 TAG_HK_SETSTATE      = 1811;
 TAG_HK_INSPECT       = 1812;
 TAG_HK_OOO           = 1813;
 TAG_HK_REPORT        = 1814;
 TAG_HK_AUTOCLEAN     = 1815;
 TAG_HK_ASSIGN        = 1816;

 { Menu Folio / Services }
 TAG_FOLIO_VIEW       = 1910;
 TAG_FOLIO_ADDCHARGE  = 1911;
 TAG_FOLIO_REMOVE     = 1912;
 TAG_FOLIO_PRINT      = 1913;
 TAG_FOLIO_PAY        = 1914;
 TAG_FOLIO_SUMMARY    = 1915;

 { Menu Clients (guests details) }
 TAG_GUEST_LIST       = 2010;
 TAG_GUEST_ADD        = 2011;
 TAG_GUEST_EDIT       = 2012;
 TAG_GUEST_DELETE     = 2013;
 TAG_GUEST_SEARCH     = 2014;
 TAG_GUEST_HISTORY    = 2015;
 TAG_GUEST_BLACKLIST  = 2016;

 { Menu Groupes }
 TAG_GROUP_LIST       = 2110;
 TAG_GROUP_NEW        = 2111;
 TAG_GROUP_EDIT       = 2112;
 TAG_GROUP_ASSIGN     = 2113;
 TAG_GROUP_CHECKIN    = 2114;
 TAG_GROUP_REPORT     = 2115;

 { Menu Saisons / Plans tarifaires }
 TAG_SEASON_CONFIG    = 2210;
 TAG_SEASON_RATES     = 2211;
 TAG_SEASON_CALENDAR  = 2212;
 TAG_RATEPLAN_LIST    = 2213;
 TAG_RATEPLAN_NEW     = 2214;

 { Menu Maintenance }
 TAG_MAINT_NEW        = 2310;
 TAG_MAINT_LIST       = 2311;
 TAG_MAINT_CLOSE      = 2312;
 TAG_MAINT_REPORT     = 2313;

 { Menu Fidelite }
 TAG_LOY_LIST         = 2410;
 TAG_LOY_AWARD        = 2411;
 TAG_LOY_REDEEM       = 2412;
 TAG_LOY_LEVELS       = 2413;
 TAG_LOY_REPORT       = 2414;

 { Menu Audit }
 TAG_AUDIT_NIGHT      = 2510;
 TAG_AUDIT_LOG        = 2511;
 TAG_AUDIT_ADR        = 2512;
 TAG_AUDIT_REVPAR     = 2513;
 TAG_AUDIT_FORECAST   = 2514;

 { Menu Channels (sources) }
 TAG_CH_LIST          = 2610;
 TAG_CH_REPORT        = 2611;
 TAG_CH_COMMISSION    = 2612;

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
 PMS_FILE_MAGIC       = 'PMSv1____';

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

 { Etat d un reservation }
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

 { Une chambre d hotel (TSpot conserve comme nom interne, mais le sens
   est maintenant Chambre dans le contexte PMS). }
 TSpot = Record
  State    : TSpotState;
  Plate    : TStr15;       { folio (numero de reservation/ID) }
  Owner    : TStr31;       { nom du client principal }
  Phone    : TStr15;       { telephone du client }
  StartDT  : TDateTime;    { check-in }
  EndDT    : TDateTime;    { check-out prevu }
  DurCode  : TDurCode;     { duree codifiee (12h..1 mois) }
  Paid     : Real;         { montant deja paye }
  Floor    : Byte;         { 0..MAX_FLOORS-1 }
  RoomType : Byte;         { RT_STANDARD..RT_ACCESSIBLE }
  HKState  : Byte;         { HK_CLEAN..HK_INPROGRESS }
  GuestID  : LongInt;      { lien vers tableau Guests (0 = inconnu) }
  GroupID  : LongInt;      { lien vers tableau GroupBookings (0 = aucun) }
  ResStatus: Byte;         { RES_CONFIRMED..RES_CANCELLED }
  Source   : Byte;         { CH_DIRECT..CH_GROUP }
  Adults   : Byte;
  Children : Byte;
  NbNights : Word;
  RateRoom : Real;         { tarif chambre par nuit applique }
  RateExtra: Real;         { total des extras factures }
  Notes    : String[63];
  Arrival  : Boolean;
  Departure: Boolean;
  VIP      : Boolean;
 End;

 TRoom = TSpot;

 { Type de chambre }
 TRoomTypeInfo = Record
  Code     : Byte;
  Label_   : String[20];
  ShortLbl : String[8];
  MaxGuests: Byte;
  BaseRate : Real;
  Enabled  : Boolean;
 End;

 { Description d un etage }
 TFloorInfo = Record
  Number   : Byte;
  Name     : String[20];
  Enabled  : Boolean;
 End;

 { Fiche client detaillee }
 TGuest = Record
  ID         : LongInt;
  Active     : Boolean;
  FirstName  : TStr31;
  LastName   : TStr31;
  Email      : String[47];
  Phone      : TStr15;
  Address    : String[63];
  City       : TStr31;
  Country    : TStr15;
  IDDoc      : TStr15;
  DOB        : TDateTime;
  Loyalty    : Byte;
  Points     : LongInt;
  TotalStays : Integer;
  TotalSpent : Real;
  Blacklist  : Boolean;
  Notes      : String[63];
  Language   : String[7];
  Created    : TDateTime;
 End;

 TCharge = Record
  Active     : Boolean;
  ChargeID   : LongInt;
  SpotIdx    : Integer;
  GuestID    : LongInt;
  Category   : Byte;
  Description: String[47];
  Amount     : Real;
  Quantity   : Word;
  AddedDT    : TDateTime;
  Paid       : Boolean;
  PaymentDT  : TDateTime;
  PaymentRef : String[15];
 End;

 TGroupBooking = Record
  Active     : Boolean;
  ID         : LongInt;
  Name       : String[47];
  ContactName: TStr31;
  ContactPhone: TStr15;
  ContactEmail: String[47];
  ArrivalDT  : TDateTime;
  DepartureDT: TDateTime;
  RoomsBooked: Word;
  Adults     : Word;
  Children   : Word;
  Discount   : Real;
  TotalDue   : Real;
  Paid       : Real;
  Notes      : String[63];
 End;

 TSeason = Record
  Code       : Byte;
  Label_     : String[20];
  StartMonth : Byte;
  StartDay   : Byte;
  EndMonth   : Byte;
  EndDay     : Byte;
  Multiplier : Real;
  Enabled    : Boolean;
 End;

 TRatePlan = Record
  Active     : Boolean;
  ID         : LongInt;
  Name       : String[20];
  Description: String[47];
  Discount   : Real;
  IncludeBreakfast : Boolean;
  IncludeDinner    : Boolean;
  IncludeParking   : Boolean;
  MinNights        : Byte;
  CancelPolicy     : String[31];
 End;

 TChannel = Record
  Code       : Byte;
  Label_     : String[20];
  Commission : Real;
  Enabled    : Boolean;
 End;

 TMaintenance = Record
  Active     : Boolean;
  ID         : LongInt;
  SpotIdx    : Integer;
  Priority   : Byte;
  Description: String[63];
  ReportedBy : TStr31;
  AssignedTo : TStr31;
  OpenedDT   : TDateTime;
  ClosedDT   : TDateTime;
  Closed     : Boolean;
  Cost       : Real;
  Notes      : String[63];
 End;

 TAuditLine = Record
  Active     : Boolean;
  AuditDT    : TDateTime;
  Occupancy  : Real;
  ADR        : Real;
  RevPAR     : Real;
  Revenue    : Real;
  Arrivals   : Integer;
  Departures : Integer;
  NoShows    : Integer;
  Cancellations : Integer;
  Notes      : String[47];
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
  AssignedSpot : Integer;     { -1 si pas de chambre attitree }
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

 { hotel }
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

 { Zone hotel (calculee selon ColCount/RowCount) }
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

 { ----- Modules PMS : globales --- }
 FloorCount     : Integer;
 CurrentFloor   : Integer;
 Floors         : Array[0..MAX_FLOORS - 1] Of TFloorInfo;
 FloorTabY      : Integer;       { Y de la barre d onglets etages }

 RoomTypes      : Array[0..RT_TYPES - 1] Of TRoomTypeInfo;

 Guests         : Array[0..MAX_GUESTS - 1] Of TGuest;
 GuestCount     : Integer;
 NextGuestID    : LongInt;

 Charges        : Array[0..MAX_CHARGES - 1] Of TCharge;
 ChargeCount    : Integer;
 NextChargeID   : LongInt;

 GroupBookings  : Array[0..MAX_GROUPS - 1] Of TGroupBooking;
 GroupCount     : Integer;
 NextGroupID    : LongInt;

 Seasons        : Array[0..SEASON_CNT - 1] Of TSeason;
 CurrentSeason  : Byte;

 RatePlans      : Array[0..MAX_RATEPLANS - 1] Of TRatePlan;
 RatePlanCount  : Integer;
 NextRatePlanID : LongInt;

 Channels       : Array[0..CH_COUNT - 1] Of TChannel;

 MaintTickets   : Array[0..MAX_MAINTENANCE - 1] Of TMaintenance;
 MaintCount     : Integer;
 NextMaintID    : LongInt;

 AuditLog       : Array[0..MAX_AUDIT_LOG - 1] Of TAuditLine;
 AuditCount     : Integer;

 { Compteurs/agreges PMS }
 PMSChargesToday   : Real;       { revenus services du jour }
 PMSCheckinsToday  : Integer;
 PMSCheckoutsToday : Integer;
 PMSNoShowsToday   : Integer;

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
Procedure DrawhotelGrid; Forward;
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

{ Forward declarations PMS (modules 1..6) }
Procedure InitPMS; Forward;
Procedure AssignRoomTypeByFloor; Forward;
Procedure GoNextFloor; Forward;
Procedure GoPrevFloor; Forward;
Procedure GoFirstFloor; Forward;
Procedure GoLastFloor; Forward;
Procedure DlgFloorConfig; Forward;
Procedure DlgFloorNames; Forward;
Procedure DlgFloorOverview; Forward;
Procedure DlgRoomCheckin; Forward;
Procedure DlgRoomCheckout; Forward;
Procedure DlgRoomTypes; Forward;
Procedure DlgRoomRename; Forward;
Procedure DlgRoomQuickBook; Forward;
Procedure DlgHKList; Forward;
Procedure DlgHKSetState; Forward;
Procedure DlgHKInspect; Forward;
Procedure DlgHKOOO; Forward;
Procedure DlgHKReport; Forward;
Procedure DlgHKAutoClean; Forward;
Procedure DlgHKAssign; Forward;
Procedure DlgFolioView; Forward;
Procedure DlgFolioAddCharge; Forward;
Procedure DlgFolioRemove; Forward;
Procedure DlgFolioPrint; Forward;
Procedure DlgFolioPay; Forward;
Procedure DlgFolioSummary; Forward;
Procedure DlgGuestList; Forward;
Procedure DlgGuestAdd; Forward;
Procedure DlgGuestEdit; Forward;
Procedure DlgGuestDelete; Forward;
Procedure DlgGuestSearch; Forward;
Procedure DlgGuestHistory; Forward;
Procedure DlgGuestBlacklist; Forward;
Procedure DlgGroupList; Forward;
Procedure DlgGroupNew; Forward;
Procedure DlgGroupEdit; Forward;
Procedure DlgGroupAssign; Forward;
Procedure DlgGroupCheckin; Forward;
Procedure DlgGroupReport; Forward;
Procedure DlgSeasonConfig; Forward;
Procedure DlgSeasonRates; Forward;
Procedure DlgSeasonCalendar; Forward;
Procedure DlgRatePlanList; Forward;
Procedure DlgRatePlanNew; Forward;
Procedure DlgMaintNew; Forward;
Procedure DlgMaintList; Forward;
Procedure DlgMaintClose; Forward;
Procedure DlgMaintReport; Forward;
Procedure DlgLoyList; Forward;
Procedure DlgLoyAward; Forward;
Procedure DlgLoyRedeem; Forward;
Procedure DlgLoyLevels; Forward;
Procedure DlgLoyReport; Forward;
Procedure DlgAuditNight; Forward;
Procedure DlgAuditLog; Forward;
Procedure DlgAuditADR; Forward;
Procedure DlgAuditRevPAR; Forward;
Procedure DlgAuditForecast; Forward;
Procedure DlgChList; Forward;
Procedure DlgChReport; Forward;
Procedure DlgChCommission; Forward;

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
    $19: OpenMenuByIdx(2); { Alt+P : hotel }
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
 AddMenuItem(MainMenuBar.Menus[0], 'Nouveau hotel', 'Ctrl+N', TAG_FILE_NEW);
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

 InitMenu(MainMenuBar.Menus[2], 'hotel');
 AddMenuItem(MainMenuBar.Menus[2], 'Reserver une chambre...',   'F5', TAG_ROOM_RESERVE);
 AddMenuItem(MainMenuBar.Menus[2], 'Liberer une chambre...',    'F6', TAG_ROOM_FREE);
 AddMenuItem(MainMenuBar.Menus[2], 'Etendre reservation...',  'F7', TAG_ROOM_EXTEND);
 AddMenuItem(MainMenuBar.Menus[2], 'Infos sur une chambre...',  'F8', TAG_ROOM_INFO);
 AddMenuSeparator(MainMenuBar.Menus[2]);
 AddMenuItem(MainMenuBar.Menus[2], 'Rechercher (folio)...',  'F9', TAG_ROOM_SEARCH);
 AddMenuItem(MainMenuBar.Menus[2], 'Forcer la liberation...', '',   TAG_ROOM_FORCE);
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
 AddMenuItem(MainMenuBar.Menus[5], 'Rechercher par folio...',  '', TAG_SUB_SEARCH);
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
 AddMenuItem(MainMenuBar.Menus[8], 'CSV : chambres',             '', TAG_CSV_SPOTS);
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

 InitMenu(MainMenuBar.Menus[10], 'Etages');
 AddMenuItem(MainMenuBar.Menus[10], 'Configuration grille...', '', TAG_FLOOR_CONFIG);
 AddMenuItem(MainMenuBar.Menus[10], 'Renommer etages...',     '', TAG_FLOOR_NAMES);
 AddMenuItem(MainMenuBar.Menus[10], 'Vue d''ensemble...',     '', TAG_FLOOR_OVERVIEW);
 AddMenuSeparator(MainMenuBar.Menus[10]);
 AddMenuItem(MainMenuBar.Menus[10], 'Etage suivant',     'PgDn', TAG_FLOOR_NEXT);
 AddMenuItem(MainMenuBar.Menus[10], 'Etage precedent',   'PgUp', TAG_FLOOR_PREV);
 AddMenuItem(MainMenuBar.Menus[10], 'Premier etage',     'Home', TAG_FLOOR_FIRST);
 AddMenuItem(MainMenuBar.Menus[10], 'Dernier etage',     'End',  TAG_FLOOR_LAST);
 MainMenuBar.Menus[10].Width := MenuItemWidth(MainMenuBar.Menus[10]);

 InitMenu(MainMenuBar.Menus[11], 'Chambres');
 AddMenuItem(MainMenuBar.Menus[11], 'Check-in...',          '', TAG_ROOM_CHECKIN);
 AddMenuItem(MainMenuBar.Menus[11], 'Check-out...',         '', TAG_ROOM_CHECKOUT);
 AddMenuItem(MainMenuBar.Menus[11], 'Quick-book walk-in',   '', TAG_ROOM_QUICKBOOK);
 AddMenuSeparator(MainMenuBar.Menus[11]);
 AddMenuItem(MainMenuBar.Menus[11], 'Types de chambres...', '', TAG_ROOM_TYPES);
 AddMenuItem(MainMenuBar.Menus[11], 'Numerotation...',      '', TAG_ROOM_RENAME);
 MainMenuBar.Menus[11].Width := MenuItemWidth(MainMenuBar.Menus[11]);

 InitMenu(MainMenuBar.Menus[12], 'Folio');
 AddMenuItem(MainMenuBar.Menus[12], 'Voir folio...',      '', TAG_FOLIO_VIEW);
 AddMenuItem(MainMenuBar.Menus[12], 'Ajouter charge...',  '', TAG_FOLIO_ADDCHARGE);
 AddMenuItem(MainMenuBar.Menus[12], 'Retirer charge...',  '', TAG_FOLIO_REMOVE);
 AddMenuItem(MainMenuBar.Menus[12], 'Encaisser...',       '', TAG_FOLIO_PAY);
 AddMenuItem(MainMenuBar.Menus[12], 'Imprimer note...',   '', TAG_FOLIO_PRINT);
 AddMenuItem(MainMenuBar.Menus[12], 'Resume par categ.', '', TAG_FOLIO_SUMMARY);
 MainMenuBar.Menus[12].Width := MenuItemWidth(MainMenuBar.Menus[12]);

 InitMenu(MainMenuBar.Menus[13], 'PMS');
 AddMenuItem(MainMenuBar.Menus[13], 'Clients...',           '', TAG_GUEST_LIST);
 AddMenuItem(MainMenuBar.Menus[13], 'Recherche client...',  '', TAG_GUEST_SEARCH);
 AddMenuItem(MainMenuBar.Menus[13], 'Historique client...', '', TAG_GUEST_HISTORY);
 AddMenuSeparator(MainMenuBar.Menus[13]);
 AddMenuItem(MainMenuBar.Menus[13], 'Groupes...',           '', TAG_GROUP_LIST);
 AddMenuItem(MainMenuBar.Menus[13], 'Nouveau groupe...',    '', TAG_GROUP_NEW);
 AddMenuItem(MainMenuBar.Menus[13], 'Affecter groupe...',   '', TAG_GROUP_ASSIGN);
 AddMenuSeparator(MainMenuBar.Menus[13]);
 AddMenuItem(MainMenuBar.Menus[13], 'Saisons...',           '', TAG_SEASON_CONFIG);
 AddMenuItem(MainMenuBar.Menus[13], 'Calendrier saisons',   '', TAG_SEASON_CALENDAR);
 AddMenuItem(MainMenuBar.Menus[13], 'Tarifs type/saison',   '', TAG_SEASON_RATES);
 AddMenuItem(MainMenuBar.Menus[13], 'Plans tarifaires...',  '', TAG_RATEPLAN_LIST);
 AddMenuSeparator(MainMenuBar.Menus[13]);
 AddMenuItem(MainMenuBar.Menus[13], 'Canaux...',            '', TAG_CH_LIST);
 AddMenuItem(MainMenuBar.Menus[13], 'Rapport canaux',       '', TAG_CH_REPORT);
 MainMenuBar.Menus[13].Width := MenuItemWidth(MainMenuBar.Menus[13]);

 InitMenu(MainMenuBar.Menus[14], 'Menage');
 AddMenuItem(MainMenuBar.Menus[14], 'Etat menage...',         '', TAG_HK_LIST);
 AddMenuItem(MainMenuBar.Menus[14], 'Changer etat...',        '', TAG_HK_SETSTATE);
 AddMenuItem(MainMenuBar.Menus[14], 'Inspecter chambre...',   '', TAG_HK_INSPECT);
 AddMenuItem(MainMenuBar.Menus[14], 'Hors service...',        '', TAG_HK_OOO);
 AddMenuSeparator(MainMenuBar.Menus[14]);
 AddMenuItem(MainMenuBar.Menus[14], 'Auto-clean libres',      '', TAG_HK_AUTOCLEAN);
 AddMenuItem(MainMenuBar.Menus[14], 'Affecter equipes',       '', TAG_HK_ASSIGN);
 AddMenuItem(MainMenuBar.Menus[14], 'Rapport menage',         '', TAG_HK_REPORT);
 AddMenuSeparator(MainMenuBar.Menus[14]);
 AddMenuItem(MainMenuBar.Menus[14], 'Nouveau ticket maint.',  '', TAG_MAINT_NEW);
 AddMenuItem(MainMenuBar.Menus[14], 'Tickets maint.',         '', TAG_MAINT_LIST);
 AddMenuItem(MainMenuBar.Menus[14], 'Fermer ticket...',       '', TAG_MAINT_CLOSE);
 AddMenuItem(MainMenuBar.Menus[14], 'Rapport maint.',         '', TAG_MAINT_REPORT);
 MainMenuBar.Menus[14].Width := MenuItemWidth(MainMenuBar.Menus[14]);

 InitMenu(MainMenuBar.Menus[15], 'Audit');
 AddMenuItem(MainMenuBar.Menus[15], 'Audit de nuit...',  '', TAG_AUDIT_NIGHT);
 AddMenuItem(MainMenuBar.Menus[15], 'Log audit',         '', TAG_AUDIT_LOG);
 AddMenuItem(MainMenuBar.Menus[15], 'Analyse ADR',       '', TAG_AUDIT_ADR);
 AddMenuItem(MainMenuBar.Menus[15], 'Analyse RevPAR',    '', TAG_AUDIT_REVPAR);
 AddMenuItem(MainMenuBar.Menus[15], 'Prevision 7 jours', '', TAG_AUDIT_FORECAST);
 AddMenuSeparator(MainMenuBar.Menus[15]);
 AddMenuItem(MainMenuBar.Menus[15], 'Fidelite clients',  '', TAG_LOY_LIST);
 AddMenuItem(MainMenuBar.Menus[15], 'Attribuer points',  '', TAG_LOY_AWARD);
 AddMenuItem(MainMenuBar.Menus[15], 'Echanger points',   '', TAG_LOY_REDEEM);
 AddMenuItem(MainMenuBar.Menus[15], 'Grille niveaux',    '', TAG_LOY_LEVELS);
 AddMenuItem(MainMenuBar.Menus[15], 'Rapport fidelite',  '', TAG_LOY_REPORT);
 MainMenuBar.Menus[15].Width := MenuItemWidth(MainMenuBar.Menus[15]);

 MainMenuBar.MenuCount := 16;
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
  hotel : OPERATIONS DE BASE
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
 S.Floor := 0;
 S.RoomType := RT_STANDARD;
 S.HKState := HK_CLEAN;
 S.GuestID := 0;
 S.GroupID := 0;
 S.ResStatus := RES_CONFIRMED;
 S.Source := CH_DIRECT;
 S.Adults := 1; S.Children := 0;
 S.NbNights := 1;
 S.RateRoom := 0; S.RateExtra := 0;
 S.Notes := '';
 S.Arrival := False; S.Departure := False; S.VIP := False;
End;

Procedure ClearAllSpots;
Var I: Integer; F, Idx: Integer;
Begin
 For I := 0 To MAX_SPOTS - 1 Do ClearSpot(Spots[I]);
 { Affecte le numero d etage en fonction de l index logique : chaque etage
   occupe MAX_ROOMS_PER_FLOOR entrees dans Spots[]. }
 For F := 0 To MAX_FLOORS - 1 Do
  For Idx := 0 To MAX_ROOMS_PER_FLOOR - 1 Do
   Spots[F * MAX_ROOMS_PER_FLOOR + Idx].Floor := F;
End;

Function SpotCount: Integer;
{ Nombre total de chambres (tous etages confondus). }
Begin SpotCount := ColCount * RowCount * FloorCount; End;

Function RoomsPerFloor: Integer;
Begin RoomsPerFloor := ColCount * RowCount; End;

Function VisibleBase: Integer;
{ Index dans Spots[] de la premiere chambre de l etage courant. }
Begin VisibleBase := CurrentFloor * MAX_ROOMS_PER_FLOOR; End;

Function SpotIdx(Col, Row: Integer): Integer;
{ Renvoie l index absolu de la chambre (Col,Row) de l etage courant. }
Begin
 SpotIdx := CurrentFloor * MAX_ROOMS_PER_FLOOR + Row * ColCount + Col;
End;

Function SpotIdxAt(Floor, Col, Row: Integer): Integer;
Begin
 SpotIdxAt := Floor * MAX_ROOMS_PER_FLOOR + Row * ColCount + Col;
End;

Function GlobalSpotCount: Integer;
Begin GlobalSpotCount := ColCount * RowCount * FloorCount; End;

Function SpotFloor(Idx: Integer): Integer;
Begin SpotFloor := Idx Div MAX_ROOMS_PER_FLOOR; End;

Function SpotCol(Idx: Integer): Integer;
Begin SpotCol := (Idx Mod MAX_ROOMS_PER_FLOOR) Mod ColCount; End;

Function SpotRow(Idx: Integer): Integer;
Begin SpotRow := (Idx Mod MAX_ROOMS_PER_FLOOR) Div ColCount; End;

Function RoomNumber(Idx: Integer): Integer;
{ Numero affiche style hotel : etage*100 + position (1-based) sur l etage. }
Var F, Pos: Integer;
Begin
 F := SpotFloor(Idx);
 Pos := (Idx Mod MAX_ROOMS_PER_FLOOR) Mod RoomsPerFloor + 1;
 RoomNumber := (Floors[F].Number) * 100 + Pos;
End;

Function RoomNumberStr(Idx: Integer): String;
Begin RoomNumberStr := IntToStr(RoomNumber(Idx)); End;

Function CountByState(State: TSpotState): Integer;
Var F, R, C, I, N: Integer;
Begin
 N := 0;
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    I := SpotIdxAt(F, C, R);
    If Spots[I].State = State Then Inc(N);
   End;
 CountByState := N;
End;

Function CountByStateOnFloor(State: TSpotState; F: Integer): Integer;
Var R, C, I, N: Integer;
Begin
 N := 0;
 For R := 0 To RowCount - 1 Do
  For C := 0 To ColCount - 1 Do Begin
   I := SpotIdxAt(F, C, R);
   If Spots[I].State = State Then Inc(N);
  End;
 CountByStateOnFloor := N;
End;

Function FindFreeSpot: Integer;
{ Cherche d abord sur l etage courant puis dans les autres. }
Var F, R, C, I: Integer;
Begin
 For R := 0 To RowCount - 1 Do
  For C := 0 To ColCount - 1 Do Begin
   I := SpotIdxAt(CurrentFloor, C, R);
   If (Spots[I].State = ssFree) And
      (Spots[I].HKState <> HK_OOO) And
      (Spots[I].HKState <> HK_OOS) Then Begin
    FindFreeSpot := I; Exit;
   End;
  End;
 For F := 0 To FloorCount - 1 Do
  If F <> CurrentFloor Then
   For R := 0 To RowCount - 1 Do
    For C := 0 To ColCount - 1 Do Begin
     I := SpotIdxAt(F, C, R);
     If (Spots[I].State = ssFree) And
        (Spots[I].HKState <> HK_OOO) And
        (Spots[I].HKState <> HK_OOS) Then Begin
      FindFreeSpot := I; Exit;
     End;
    End;
 FindFreeSpot := -1;
End;

Function FindByPlate(Plate: TStr15): Integer;
Var F, R, C, I: Integer;
Begin
 FindByPlate := -1;
 If Plate = '' Then Exit;
 Plate := UpStr(TrimStr(Plate));
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    I := SpotIdxAt(F, C, R);
    If (Spots[I].State = ssOccupied) And
       (UpStr(Spots[I].Plate) = Plate) Then Begin
     FindByPlate := I; Exit;
    End;
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
  RENDU DE LA GRILLE DE reservation
  ============================================================ }

Procedure ComputeGridLayout;
Var Margin, AvailW, AvailH: Integer;
Begin
 Margin := 8;
 FloorTabY := MENUBAR_HEIGHT + 2;
 GridX := Margin;
 GridY := FloorTabY + FLOORTAB_HEIGHT + Margin;
 AvailW := ScreenWidth - 2 * Margin;
 AvailH := ScreenHeight - GridY - STATUSBAR_HEIGHT - Margin;
 SpotW := AvailW Div ColCount;
 SpotH := AvailH Div RowCount;
 If SpotW < 24 Then SpotW := 24;
 If SpotH < 18 Then SpotH := 18;
 If SpotW > 70 Then SpotW := 70;
 If SpotH > 55 Then SpotH := 55;
 GridW := SpotW * ColCount;
 GridH := SpotH * RowCount;
 { Centre dans l espace disponible }
 GridX := (ScreenWidth - GridW) Div 2;
 GridY := FloorTabY + FLOORTAB_HEIGHT +
          (ScreenHeight - FloorTabY - FLOORTAB_HEIGHT -
           STATUSBAR_HEIGHT - GridH) Div 2;
End;

Procedure DrawCarIcon(X1, Y1, X2, Y2: Integer; Color: Integer);
Var
 CX, CY, BW, BH: Integer;
Begin
 BW := X2 - X1 - 4;
 BH := Y2 - Y1 - 4;
 CX := (X1 + X2) Div 2;
 CY := (Y1 + Y2) Div 2;
 { Corps de la chambre }
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

Procedure DrawRoomIcon(X1, Y1, X2, Y2: Integer; Color, RType: Integer);
{ Petite icone representant une chambre (lit) au lieu d une voiture. }
Var CX, CY, BW, BH: Integer;
Begin
 BW := X2 - X1 - 4; BH := Y2 - Y1 - 4;
 CX := (X1 + X2) Div 2; CY := (Y1 + Y2) Div 2;
 SetFillStyle(SolidFill, Color);
 Bar(X1 + 3, CY - BH Div 3, X2 - 3, CY + BH Div 3);
 { Oreiller(s) selon type de chambre }
 SetFillStyle(SolidFill, White);
 Case RType Of
  RT_STANDARD, RT_DOUBLE, RT_SUITE, RT_DELUXE, RT_PENTHOUSE, RT_ACCESSIBLE:
   Bar(X1 + 5, CY - BH Div 4, CX - 1, CY - BH Div 5 + 2);
  RT_TWIN, RT_FAMILY: Begin
   Bar(X1 + 5, CY - BH Div 4, CX - 2, CY - BH Div 5 + 2);
   Bar(CX + 2, CY - BH Div 4, X2 - 5, CY - BH Div 5 + 2);
  End;
 End;
 { Couverture / pied de lit }
 SetColor(DarkGray);
 Line(X1 + 3, CY + BH Div 6, X2 - 3, CY + BH Div 6);
End;

Procedure DrawSpot(Idx: Integer);
Var
 Col, Row: Integer;
 X1, Y1, X2, Y2: Integer;
 BG: Integer;
 NumStr: String;
 TX: Integer;
 LocalIdx: Integer;
Begin
 { On n affiche que l etage courant. }
 If SpotFloor(Idx) <> CurrentFloor Then Exit;
 LocalIdx := Idx Mod MAX_ROOMS_PER_FLOOR;
 Col := LocalIdx Mod ColCount;
 Row := LocalIdx Div ColCount;
 If (Col >= ColCount) Or (Row >= RowCount) Then Exit;
 X1 := GridX + Col * SpotW;
 Y1 := GridY + Row * SpotH;
 X2 := X1 + SpotW - 2;
 Y2 := Y1 + SpotH - 2;
 BG := GetSpotColor(Idx);
 { Couleur OOO/OOS prioritaire }
 Case Spots[Idx].HKState Of
  HK_OOO:    BG := DarkGray;
  HK_OOS:    BG := Brown;
  HK_DIRTY:  If Spots[Idx].State = ssFree Then BG := Brown;
  HK_INPROGRESS: If Spots[Idx].State = ssFree Then BG := LightMagenta;
 End;
 FillRect(X1, Y1, X2, Y2, BG);
 SetColor(White);
 Rectangle(X1, Y1, X2, Y2);
 NumStr := RoomNumberStr(Idx);
 SetColor(CLR_SPOT_BORDER);
 OutTextXY(X1 + 2, Y1 + 2, NumStr);
 { Marqueur VIP en haut a droite }
 If Spots[Idx].VIP Then Begin
  SetColor(Yellow); SetFillStyle(SolidFill, Yellow);
  Bar(X2 - 8, Y1 + 2, X2 - 2, Y1 + 6);
 End;
 { Marqueur type chambre en bas a gauche }
 If SpotH >= 28 Then Begin
  SetColor(Black);
  OutTextXY(X1 + 2, Y2 - 9, RoomTypes[Spots[Idx].RoomType].ShortLbl);
 End;
 If Spots[Idx].State = ssOccupied Then Begin
  DrawRoomIcon(X1, Y1 + 10, X2, Y2 - 12, CLR_CAR,
               Spots[Idx].RoomType);
  If SpotH >= 30 Then Begin
   TX := X1 + ((SpotW - Length(Spots[Idx].Owner) * 6) Div 2);
   If TX < X1 + 2 Then TX := X1 + 2;
   SetColor(White);
   OutTextXY(TX, Y2 - 10, Copy(Spots[Idx].Owner, 1, SpotW Div 6));
  End;
 End
 Else If Spots[Idx].HKState = HK_DIRTY Then Begin
  SetColor(White); OutTextXY(X1 + (SpotW Div 2) - 12, (Y1+Y2) Div 2 - 4, 'SALE');
 End;
 If Idx = HoverSpot Then Begin
  SetColor(Yellow);
  Rectangle(X1 - 1, Y1 - 1, X2 + 1, Y2 + 1);
 End;
End;

Procedure DrawFloorTabs;
Var I, X, W, TY: Integer; Lbl: String; Active: Boolean;
Begin
 FillRect(0, FloorTabY, ScreenWidth - 1,
          FloorTabY + FLOORTAB_HEIGHT - 1, DarkGray);
 SetColor(White);
 Line(0, FloorTabY + FLOORTAB_HEIGHT - 1,
      ScreenWidth - 1, FloorTabY + FLOORTAB_HEIGHT - 1);
 W := 60;
 X := 8;
 TY := FloorTabY + 5;
 SetColor(White);
 OutTextXY(X, TY, 'Etages:');
 X := X + 60;
 For I := 0 To FloorCount - 1 Do Begin
  Active := (I = CurrentFloor);
  If Active Then Begin
   FillRect(X, FloorTabY + 2, X + W - 2,
            FloorTabY + FLOORTAB_HEIGHT - 1, Blue);
   SetColor(Yellow);
  End Else Begin
   FillRect(X, FloorTabY + 2, X + W - 2,
            FloorTabY + FLOORTAB_HEIGHT - 2, LightGray);
   SetColor(Black);
  End;
  Lbl := 'Et.' + IntToStr(Floors[I].Number);
  OutTextXY(X + (W - Length(Lbl) * 8) Div 2, TY, Lbl);
  X := X + W;
  If X > ScreenWidth - W Then Break;
 End;
End;

Function HitFloorTab(MX, MY: Integer): Integer;
Var I, X, W: Integer;
Begin
 HitFloorTab := -1;
 If (MY < FloorTabY) Or (MY >= FloorTabY + FLOORTAB_HEIGHT) Then Exit;
 W := 60; X := 8 + 60;
 For I := 0 To FloorCount - 1 Do Begin
  If (MX >= X) And (MX < X + W - 2) Then Begin
   HitFloorTab := I; Exit;
  End;
  X := X + W;
 End;
End;

Procedure DrawhotelGrid;
Var F, R, C, I: Integer;
Begin
 { Efface la zone hotel sous les onglets }
 FillRect(0, FloorTabY + FLOORTAB_HEIGHT,
          ScreenWidth - 1, ScreenHeight - STATUSBAR_HEIGHT - 1,
          CLR_BACKGROUND);
 DrawFloorTabs;
 { Cadre du hotel (couloir) }
 SetFillStyle(SolidFill, DarkGray);
 Bar(GridX - 4, GridY - 4, GridX + GridW + 4, GridY + GridH + 4);
 F := CurrentFloor;
 For R := 0 To RowCount - 1 Do
  For C := 0 To ColCount - 1 Do Begin
   I := SpotIdxAt(F, C, R);
   DrawSpot(I);
  End;
End;

Function CY(Y1, Y2: Integer): Integer;
Begin CY := (Y1 + Y2) Div 2; End;

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
 HitTestSpot := SpotIdxAt(CurrentFloor, Col, Row);
End;

Procedure SwitchFloor(NewFloor: Integer);
Begin
 If NewFloor < 0 Then NewFloor := FloorCount - 1;
 If NewFloor >= FloorCount Then NewFloor := 0;
 If NewFloor = CurrentFloor Then Exit;
 CurrentFloor := NewFloor;
 HoverSpot := -1;
 DrawhotelGrid;
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
 DrawhotelGrid;
 UpdateCounters;
 DrawStatusBar;
End;

{ ============================================================
  SAUVEGARDE / CHARGEMENT
  ============================================================
  Format texte ligne-orientee, lisible:
    hotelv1
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
 Writeln(F, PMS_FILE_MAGIC);
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
 If Magic <> PMS_FILE_MAGIC Then Begin
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
  DIALOGUES SPECIFIQUES AU hotel
  ============================================================ }

{ --- Configurer la grille --- }

Procedure DlgConfigureGrid;
Var
 D: TDialog;
 IC, IR: Integer;
 R, NC, NR: Integer;
 Done: Boolean;
Begin
 DlgInit(D, 'Configurer la grille de reservation', 360, 180);
 DlgAddLabel(D, 16, 8, 'Nombre de colonnes (1..' + IntToStr(MAX_COLS) + ') :');
 IC := DlgAddNumEdit(D, 240, 6, 80, IntToStr(ColCount), 3, False);
 DlgAddLabel(D, 16, 36, 'Nombre de rangees (1..' + IntToStr(MAX_ROWS) + ') :');
 IR := DlgAddNumEdit(D, 240, 34, 80, IntToStr(RowCount), 3, False);
 DlgAddHLine(D, 16, 70, 328);
 DlgAddLabel(D, 16, 80, 'Total : ' + IntToStr(ColCount * RowCount) +
             ' reservations actuellement.');
 DlgAddLabel(D, 16, 96, 'Attention : changer la taille reinitialise les chambres.');
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
                      'Reinitialiser tout le hotel ?') Then Begin
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
 DlgInit(D, 'Tarification des reservations', 360, 290);
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
  ShowMessageBox('Reservation', 'Aucune chambre libre disponible.');
  Exit;
 End;
 If Spots[SpotIndex].State <> ssFree Then Begin
  ShowMessageBox('Reservation',
                 'La chambre ' + IntToStr(SpotIndex + 1) +
                 ' est deja occupee.');
  Exit;
 End;
 DlgInit(D, 'Reserver la chambre no ' + IntToStr(SpotIndex + 1), 480, 400);
 DlgAddLabel(D, 16, 6, 'folio d''immatriculation :');
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
   ShowMessageBox('Erreur', 'La folio est obligatoire.');
   Exit;
  End;
  PrevSpot := FindByPlate(Plate);
  If PrevSpot >= 0 Then Begin
   ShowMessageBox('Doublon',
                  'Le chambre ' + Plate + ' est deja a la chambre ' +
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

{ --- Infos d une chambre + actions --- }

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
  If ShowConfirmBox('chambre ' + IntToStr(Idx + 1) + ' libre',
                    'Voulez-vous reserver cette chambre ?') Then
   DlgReserve(Idx);
  Exit;
 End;
 Title := 'chambre no ' + IntToStr(Idx + 1) + ' (occupee)';
 DlgInit(D, Title, 440, 280);
 Y := 10;
 DlgAddLabel(D, 16, Y, 'folio :   ' + Spots[Idx].Plate);    Y := Y + 18;
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
                    'Liberer la chambre ' + IntToStr(Idx + 1) + ' ?') Then
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

{ --- Liberer (choix de la chambre) --- }

Procedure DlgFreeSpot;
Var Plate: String; Idx: Integer;
Begin
 Plate := '';
 If Not ShowInputBox('Liberer une chambre',
                     'Entrez le numero de chambre ou la folio :',
                     Plate, 15) Then Exit;
 Plate := UpStr(TrimStr(Plate));
 If Plate = '' Then Exit;
 { Essaie comme numero d abord }
 Idx := StrToIntDef(Plate, -1);
 If (Idx >= 1) And (Idx <= SpotCount) Then Idx := Idx - 1
 Else Idx := FindByPlate(Plate);
 If Idx < 0 Then Begin
  ShowMessageBox('Introuvable', 'Aucune chambre ne correspond.');
  Exit;
 End;
 DlgSpotInfo(Idx);
End;

{ --- Rechercher --- }

Procedure DlgSearchByPlate;
Var Plate: String; Idx: Integer;
Begin
 Plate := '';
 If Not ShowInputBox('Rechercher un chambre',
                     'folio d''immatriculation :',
                     Plate, 12) Then Exit;
 Plate := UpStr(TrimStr(Plate));
 If Plate = '' Then Exit;
 Idx := FindByPlate(Plate);
 If Idx < 0 Then
  ShowMessageBox('Resultat', 'folio ' + Plate + ' non trouvee.')
 Else Begin
  HoverSpot := Idx;
  DrawhotelGrid;
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
             ' chambres');                                       Y := Y + 18;
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
             'Date              Type   folio        chambre   Montant');
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
 DlgInit(D, 'A propos de hotel', 400, 240);
 DlgAddLabel(D, 80, 10,  'Property Management System (PMS) - Gestion Hoteliere');
 DlgAddLabel(D, 130, 30, 'Version ' + PMS_VERSION);
 DlgAddLabel(D, 130, 46, 'Date : ' + PMS_DATE);
 DlgAddHLine(D, 20, 70, 360);
 DlgAddLabel(D, 20, 80,  'Auteur : Sylvain Maltais');
 DlgAddLabel(D, 20, 96,  'Site   : www.gladir.com/physiq');
 DlgAddLabel(D, 20, 112, 'Cible  : Turbo Pascal 7 / Free Pascal');
 DlgAddLabel(D, 20, 134, 'Programme de gestion complete d''un parc');
 DlgAddLabel(D, 20, 148, 'de reservations automobile avec sauvegarde,');
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
 DlgAddLabel(D, 16, Y, 'F6       Liberer une chambre');                   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F7       Etendre une reservation');             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F8       Infos sur une chambre');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'F9       Rechercher par folio');               Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+N   Nouveau hotel');                     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+O   Ouvrir fichier');                      Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Ctrl+S   Enregistrer');                         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Alt+X    Quitter');                             Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Souris : clic sur une chambre pour ses infos.'); Y := Y + 14;
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
 DlgAddLabel(D, 16, Y, 'hotel gere un parc de reservations.');                 Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'Chaque chambre est verte (libre) ou rouge (occupee),');     Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'jaune si la reservation expire dans moins de 30 min,');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'rouge fonce si la reservation est deja expiree.');        Y := Y + 14;
 Y := Y + 8;
 DlgAddLabel(D, 16, Y, 'POUR RESERVER : cliquez une chambre libre ou F5.');         Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'POUR LIBERER : cliquez une chambre occupee, "Liberer".');   Y := Y + 14;
 DlgAddLabel(D, 16, Y, 'POUR ETENDRE : cliquez une chambre occupee, "Etendre".');   Y := Y + 14;
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
 If FName = '' Then FName := 'hotel.dat';
 If ShowInputBox('Enregistrer sous', 'Nom du fichier :', FName, 80) Then
  SaveToFile(FName);
End;

Procedure DlgOpenFile;
Var FName: String;
Begin
 FName := CurrentFile;
 If FName = '' Then FName := 'hotel.dat';
 If ShowInputBox('Ouvrir fichier', 'Nom du fichier :', FName, 80) Then Begin
  LoadFromFile(FName);
  RedrawAll;
 End;
End;

Procedure DlgNewhotel;
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
  TAG_FILE_NEW:     DlgNewhotel;
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
   If ShowConfirmBox('Quitter', 'Quitter hotel ?') Then
    QuitRequested := True;
  End;
  TAG_EDIT_CONFIG:  DlgConfigureGrid;
  TAG_EDIT_PRICING: DlgConfigurePricing;
  TAG_EDIT_FREEALL: Begin
   If ShowConfirmBox('Confirmation',
                     'Liberer toutes les chambres ?') Then
    ClearAllSpots;
  End;
  TAG_ROOM_RESERVE: DlgReserve(-1);
  TAG_ROOM_FREE:    DlgFreeSpot;
  TAG_ROOM_INFO:    Begin
   P := '';
   If ShowInputBox('chambre', 'Numero de la chambre :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) Then DlgSpotInfo(I)
    Else ShowMessageBox('Erreur', 'Numero invalide.');
   End;
  End;
  TAG_ROOM_EXTEND:  Begin
   P := '';
   If ShowInputBox('Etendre', 'Numero de la chambre :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) And
       (Spots[I].State = ssOccupied) Then DlgSpotInfo(I)
    Else ShowMessageBox('Erreur', 'chambre invalide ou libre.');
   End;
  End;
  TAG_ROOM_SEARCH:  DlgSearchByPlate;
  TAG_ROOM_FORCE:   Begin
   P := '';
   If ShowInputBox('Forcer la liberation',
                   'Numero de la chambre :', P, 5) Then Begin
    I := StrToIntDef(P, 0) - 1;
    If (I >= 0) And (I < SpotCount) Then Begin
     If ShowConfirmBox('Forcer',
                       'Liberer la chambre ' + IntToStr(I + 1) +
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

  { --- PMS : Etages --- }
  TAG_FLOOR_CONFIG:   DlgFloorConfig;
  TAG_FLOOR_NEXT:     Begin GoNextFloor; RedrawAll; End;
  TAG_FLOOR_PREV:     Begin GoPrevFloor; RedrawAll; End;
  TAG_FLOOR_FIRST:    Begin GoFirstFloor; RedrawAll; End;
  TAG_FLOOR_LAST:     Begin GoLastFloor; RedrawAll; End;
  TAG_FLOOR_OVERVIEW: DlgFloorOverview;
  TAG_FLOOR_NAMES:    DlgFloorNames;

  { --- PMS : Chambres --- }
  TAG_ROOM_CHECKIN:   DlgRoomCheckin;
  TAG_ROOM_CHECKOUT:  DlgRoomCheckout;
  TAG_ROOM_TYPES:     DlgRoomTypes;
  TAG_ROOM_RENAME:    DlgRoomRename;
  TAG_ROOM_QUICKBOOK: DlgRoomQuickBook;

  { --- PMS : Housekeeping --- }
  TAG_HK_LIST:      DlgHKList;
  TAG_HK_SETSTATE:  DlgHKSetState;
  TAG_HK_INSPECT:   DlgHKInspect;
  TAG_HK_OOO:       DlgHKOOO;
  TAG_HK_REPORT:    DlgHKReport;
  TAG_HK_AUTOCLEAN: DlgHKAutoClean;
  TAG_HK_ASSIGN:    DlgHKAssign;

  { --- PMS : Folio --- }
  TAG_FOLIO_VIEW:      DlgFolioView;
  TAG_FOLIO_ADDCHARGE: DlgFolioAddCharge;
  TAG_FOLIO_REMOVE:    DlgFolioRemove;
  TAG_FOLIO_PRINT:     DlgFolioPrint;
  TAG_FOLIO_PAY:       DlgFolioPay;
  TAG_FOLIO_SUMMARY:   DlgFolioSummary;

  { --- PMS : Guests --- }
  TAG_GUEST_LIST:      DlgGuestList;
  TAG_GUEST_ADD:       DlgGuestAdd;
  TAG_GUEST_EDIT:      DlgGuestEdit;
  TAG_GUEST_DELETE:    DlgGuestDelete;
  TAG_GUEST_SEARCH:    DlgGuestSearch;
  TAG_GUEST_HISTORY:   DlgGuestHistory;
  TAG_GUEST_BLACKLIST: DlgGuestBlacklist;

  { --- PMS : Groupes --- }
  TAG_GROUP_LIST:    DlgGroupList;
  TAG_GROUP_NEW:     DlgGroupNew;
  TAG_GROUP_EDIT:    DlgGroupEdit;
  TAG_GROUP_ASSIGN:  DlgGroupAssign;
  TAG_GROUP_CHECKIN: DlgGroupCheckin;
  TAG_GROUP_REPORT:  DlgGroupReport;

  { --- PMS : Saisons et tarifs --- }
  TAG_SEASON_CONFIG:   DlgSeasonConfig;
  TAG_SEASON_RATES:    DlgSeasonRates;
  TAG_SEASON_CALENDAR: DlgSeasonCalendar;
  TAG_RATEPLAN_LIST:   DlgRatePlanList;
  TAG_RATEPLAN_NEW:    DlgRatePlanNew;

  { --- PMS : Maintenance --- }
  TAG_MAINT_NEW:    DlgMaintNew;
  TAG_MAINT_LIST:   DlgMaintList;
  TAG_MAINT_CLOSE:  DlgMaintClose;
  TAG_MAINT_REPORT: DlgMaintReport;

  { --- PMS : Fidelite --- }
  TAG_LOY_LIST:   DlgLoyList;
  TAG_LOY_AWARD:  DlgLoyAward;
  TAG_LOY_REDEEM: DlgLoyRedeem;
  TAG_LOY_LEVELS: DlgLoyLevels;
  TAG_LOY_REPORT: DlgLoyReport;

  { --- PMS : Audit nocturne --- }
  TAG_AUDIT_NIGHT:    DlgAuditNight;
  TAG_AUDIT_LOG:      DlgAuditLog;
  TAG_AUDIT_ADR:      DlgAuditADR;
  TAG_AUDIT_REVPAR:   DlgAuditRevPAR;
  TAG_AUDIT_FORECAST: DlgAuditForecast;

  { --- PMS : Canaux de distribution --- }
  TAG_CH_LIST:       DlgChList;
  TAG_CH_REPORT:     DlgChReport;
  TAG_CH_COMMISSION: DlgChCommission;
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

 DlgAddLabel(D, 16, 30, 'folio :');
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

 DlgAddLabel(D, 16, 230, 'chambre attitree (0=aucune) :');
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
  ShowMessageBox('Erreur', 'La folio est obligatoire.'); Exit;
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
 DlgAddLabel(D, 12, 4, 'ID    Type        folio   Nom              Expire le');
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
                     'folio a rechercher :', P, 12) Then Exit;
 I := FindActiveSubByPlate(P);
 If I < 0 Then Begin
  ShowMessageBox('Recherche',
                 'Aucun abonnement actif pour cette folio.');
  Exit;
 End;
 S := Subs[I];
 ShowMessageBox('Abonnement #' + IntToStr(S.ID),
   'Client : ' + S.Name + #13#10 +
   'folio : ' + S.Plate + #13#10 +
   'Type   : ' + SubTypeLabel(S.SubType) + #13#10 +
   'Debut  : ' + FormatDateTime(S.StartDT) + #13#10 +
   'Fin    : ' + FormatDateTime(S.EndDT) + #13#10 +
   'Paye   : ' + MoneyStr(S.AmountPaid) + #13#10 +
   'chambre  : ' +
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

 DlgAddLabel(D, 16, 88, 'folio contient :');
 IPlate := DlgAddEdit(D, 160, 86, 200, LastFilter.PlateFrag, 12);

 DlgAddLabel(D, 16, 112, 'chambre no de :');
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
   'Date       Heure  Type folio       Pl    Montant');
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
 WriteLn(F, 'Date,Heure,Type,folio,Proprietaire,chambre,Montant,DebutISO,FinISO');
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
 WriteLn(F, 'ID,Type,Nom,folio,Telephone,Courriel,Debut,Fin,Paye,chambre,AutoRenew,Renouvellements');
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
 WriteLn(F, 'chambre,Etat,folio,Proprietaire,Telephone,DebutISO,FinISO,Paye');
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
   IntToStr(SpotCount) + ' chambres exportees vers ' + FN);
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
  2: Suffix := 'chambres';
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
      ExportSpotsCSV('chambres.csv');
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
 OutTextXY(8, 4, 'Etat d''occupation du hotel');
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
 L[N] := 'Etat du hotel :'; Inc(N);
 UpdateCounters;
 L[N] := '  Total chambres   : ' + IntToStr(SpotCount); Inc(N);
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
 L[N] := 'ID    Type        folio      Nom              Expire'; Inc(N);
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
 L[N] := 'chambre folio        Proprietaire     Restant'; Inc(N);
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
  L[N] := '(aucune chambre occupee)'; Inc(N);
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

{ ============================================================
  PMS - WRAPPERS COMPATIBILITE DIALOGS (vers DlgAddXxx)
  ============================================================ }

Const
 BTN_DEFAULT = 1;
 BTN_CANCEL  = -1;
 BTN_NORMAL  = 0;

Procedure AddLabel(Var D: TDialog; AX, AY: Integer; S: String);
Begin DlgAddLabel(D, AX, AY, S); End;

Function AddEdit(Var D: TDialog; AX, AY, AW, MaxLen: Integer): Integer;
Begin AddEdit := DlgAddEdit(D, AX, AY, AW, '', MaxLen); End;

Function AddButton(Var D: TDialog; AX, AY, AW: Integer;
                   ACaption: String; Kind: Integer): Integer;
Var Tag: Integer;
Begin
 Case Kind Of
  BTN_DEFAULT: Tag := 1;
  BTN_CANCEL : Tag := -1;
 Else          Tag := 1;
 End;
 AddButton := DlgAddButton(D, AX, AY, AW, ACaption, Tag, ' ');
End;

Function AddCheck(Var D: TDialog; AX, AY: Integer;
                  ACaption: String; AChecked: Boolean): Integer;
Begin AddCheck := DlgAddCheck(D, AX, AY, 200, ACaption, AChecked); End;

Function AddCombo(Var D: TDialog; AX, AY, AW: Integer;
                  Var LblP: Array Of PChar; N: Integer): Integer;
Var I, ILst, H: Integer;
Begin
 H := N * 14 + 6; If H > 70 Then H := 70; If H < 28 Then H := 28;
 ILst := DlgAddList(D, AX, AY, AW, H);
 For I := 0 To N - 1 Do DlgListAdd(D, ILst, StrPas(LblP[I]));
 AddCombo := ILst;
End;

Function AddListbox(Var D: TDialog; AX, AY, AW, AH: Integer;
                    Var LblP: Array Of PChar; N: Integer): Integer;
Var I, ILst: Integer;
Begin
 ILst := DlgAddList(D, AX, AY, AW, AH);
 For I := 0 To N - 1 Do DlgListAdd(D, ILst, StrPas(LblP[I]));
 AddListbox := ILst;
End;

Function AddRadio(Var D: TDialog; AX, AY, AW: Integer;
                  ACaption: String; AGroup: Integer;
                  AChecked: Boolean): Integer;
Begin AddRadio := DlgAddRadio(D, AX, AY, AW, ACaption, AGroup, AChecked); End;

{ ============================================================
  PMS - MODULE 1 : ETAGES, TYPES DE CHAMBRES, INITIALISATIONS
  ============================================================ }

Procedure InitDefaultFloors;
Var I: Integer;
Begin
 FloorCount := 4;
 For I := 0 To MAX_FLOORS - 1 Do Begin
  Floors[I].Number := I;
  Case I Of
   0: Floors[I].Name := 'Rez-de-chaussee';
   1: Floors[I].Name := 'Premier etage';
   2: Floors[I].Name := 'Deuxieme etage';
   3: Floors[I].Name := 'Troisieme etage';
   4: Floors[I].Name := 'Quatrieme etage';
   5: Floors[I].Name := 'Cinquieme etage';
   6: Floors[I].Name := 'Sixieme etage';
   7: Floors[I].Name := 'Septieme etage';
   8: Floors[I].Name := 'Huitieme etage';
   9: Floors[I].Name := 'Penthouse';
  End;
  Floors[I].Enabled := True;
 End;
 CurrentFloor := 0;
End;

Procedure InitDefaultRoomTypes;
Begin
 RoomTypes[RT_STANDARD].Code := RT_STANDARD;
 RoomTypes[RT_STANDARD].Label_ := 'Standard';
 RoomTypes[RT_STANDARD].ShortLbl := 'STD';
 RoomTypes[RT_STANDARD].MaxGuests := 2;
 RoomTypes[RT_STANDARD].BaseRate := 89.00;
 RoomTypes[RT_STANDARD].Enabled := True;

 RoomTypes[RT_DOUBLE].Code := RT_DOUBLE;
 RoomTypes[RT_DOUBLE].Label_ := 'Double';
 RoomTypes[RT_DOUBLE].ShortLbl := 'DBL';
 RoomTypes[RT_DOUBLE].MaxGuests := 2;
 RoomTypes[RT_DOUBLE].BaseRate := 109.00;
 RoomTypes[RT_DOUBLE].Enabled := True;

 RoomTypes[RT_TWIN].Code := RT_TWIN;
 RoomTypes[RT_TWIN].Label_ := 'Twin (2 lits)';
 RoomTypes[RT_TWIN].ShortLbl := 'TWN';
 RoomTypes[RT_TWIN].MaxGuests := 2;
 RoomTypes[RT_TWIN].BaseRate := 119.00;
 RoomTypes[RT_TWIN].Enabled := True;

 RoomTypes[RT_SUITE].Code := RT_SUITE;
 RoomTypes[RT_SUITE].Label_ := 'Suite';
 RoomTypes[RT_SUITE].ShortLbl := 'STE';
 RoomTypes[RT_SUITE].MaxGuests := 3;
 RoomTypes[RT_SUITE].BaseRate := 189.00;
 RoomTypes[RT_SUITE].Enabled := True;

 RoomTypes[RT_DELUXE].Code := RT_DELUXE;
 RoomTypes[RT_DELUXE].Label_ := 'Deluxe';
 RoomTypes[RT_DELUXE].ShortLbl := 'DLX';
 RoomTypes[RT_DELUXE].MaxGuests := 2;
 RoomTypes[RT_DELUXE].BaseRate := 159.00;
 RoomTypes[RT_DELUXE].Enabled := True;

 RoomTypes[RT_FAMILY].Code := RT_FAMILY;
 RoomTypes[RT_FAMILY].Label_ := 'Familiale';
 RoomTypes[RT_FAMILY].ShortLbl := 'FAM';
 RoomTypes[RT_FAMILY].MaxGuests := 5;
 RoomTypes[RT_FAMILY].BaseRate := 179.00;
 RoomTypes[RT_FAMILY].Enabled := True;

 RoomTypes[RT_PENTHOUSE].Code := RT_PENTHOUSE;
 RoomTypes[RT_PENTHOUSE].Label_ := 'Penthouse';
 RoomTypes[RT_PENTHOUSE].ShortLbl := 'PEN';
 RoomTypes[RT_PENTHOUSE].MaxGuests := 4;
 RoomTypes[RT_PENTHOUSE].BaseRate := 349.00;
 RoomTypes[RT_PENTHOUSE].Enabled := True;

 RoomTypes[RT_ACCESSIBLE].Code := RT_ACCESSIBLE;
 RoomTypes[RT_ACCESSIBLE].Label_ := 'Accessible';
 RoomTypes[RT_ACCESSIBLE].ShortLbl := 'ACC';
 RoomTypes[RT_ACCESSIBLE].MaxGuests := 2;
 RoomTypes[RT_ACCESSIBLE].BaseRate := 99.00;
 RoomTypes[RT_ACCESSIBLE].Enabled := True;
End;

Procedure InitDefaultSeasons;
Begin
 Seasons[SEASON_LOW].Code := SEASON_LOW;
 Seasons[SEASON_LOW].Label_ := 'Basse saison';
 Seasons[SEASON_LOW].StartMonth := 1;  Seasons[SEASON_LOW].StartDay := 15;
 Seasons[SEASON_LOW].EndMonth := 4;    Seasons[SEASON_LOW].EndDay := 30;
 Seasons[SEASON_LOW].Multiplier := 0.85;
 Seasons[SEASON_LOW].Enabled := True;

 Seasons[SEASON_MID].Code := SEASON_MID;
 Seasons[SEASON_MID].Label_ := 'Demi saison';
 Seasons[SEASON_MID].StartMonth := 5;  Seasons[SEASON_MID].StartDay := 1;
 Seasons[SEASON_MID].EndMonth := 6;    Seasons[SEASON_MID].EndDay := 14;
 Seasons[SEASON_MID].Multiplier := 1.00;
 Seasons[SEASON_MID].Enabled := True;

 Seasons[SEASON_HIGH].Code := SEASON_HIGH;
 Seasons[SEASON_HIGH].Label_ := 'Haute saison';
 Seasons[SEASON_HIGH].StartMonth := 6;  Seasons[SEASON_HIGH].StartDay := 15;
 Seasons[SEASON_HIGH].EndMonth := 9;    Seasons[SEASON_HIGH].EndDay := 15;
 Seasons[SEASON_HIGH].Multiplier := 1.25;
 Seasons[SEASON_HIGH].Enabled := True;

 Seasons[SEASON_PEAK].Code := SEASON_PEAK;
 Seasons[SEASON_PEAK].Label_ := 'Pointe (fetes)';
 Seasons[SEASON_PEAK].StartMonth := 12;  Seasons[SEASON_PEAK].StartDay := 20;
 Seasons[SEASON_PEAK].EndMonth := 1;     Seasons[SEASON_PEAK].EndDay := 5;
 Seasons[SEASON_PEAK].Multiplier := 1.50;
 Seasons[SEASON_PEAK].Enabled := True;

 CurrentSeason := SEASON_MID;
End;

Procedure InitDefaultChannels;
Begin
 Channels[CH_DIRECT].Code := CH_DIRECT;
 Channels[CH_DIRECT].Label_ := 'Direct (site web)';
 Channels[CH_DIRECT].Commission := 0.0;
 Channels[CH_DIRECT].Enabled := True;

 Channels[CH_WALKIN].Code := CH_WALKIN;
 Channels[CH_WALKIN].Label_ := 'Walk-in';
 Channels[CH_WALKIN].Commission := 0.0;
 Channels[CH_WALKIN].Enabled := True;

 Channels[CH_PHONE].Code := CH_PHONE;
 Channels[CH_PHONE].Label_ := 'Telephone';
 Channels[CH_PHONE].Commission := 0.0;
 Channels[CH_PHONE].Enabled := True;

 Channels[CH_EMAIL].Code := CH_EMAIL;
 Channels[CH_EMAIL].Label_ := 'Email';
 Channels[CH_EMAIL].Commission := 0.0;
 Channels[CH_EMAIL].Enabled := True;

 Channels[CH_BOOKING].Code := CH_BOOKING;
 Channels[CH_BOOKING].Label_ := 'Booking.com';
 Channels[CH_BOOKING].Commission := 15.0;
 Channels[CH_BOOKING].Enabled := True;

 Channels[CH_EXPEDIA].Code := CH_EXPEDIA;
 Channels[CH_EXPEDIA].Label_ := 'Expedia';
 Channels[CH_EXPEDIA].Commission := 18.0;
 Channels[CH_EXPEDIA].Enabled := True;

 Channels[CH_AIRBNB].Code := CH_AIRBNB;
 Channels[CH_AIRBNB].Label_ := 'Airbnb';
 Channels[CH_AIRBNB].Commission := 14.0;
 Channels[CH_AIRBNB].Enabled := True;

 Channels[CH_GDS].Code := CH_GDS;
 Channels[CH_GDS].Label_ := 'GDS (Amadeus)';
 Channels[CH_GDS].Commission := 10.0;
 Channels[CH_GDS].Enabled := True;

 Channels[CH_AGENCE].Code := CH_AGENCE;
 Channels[CH_AGENCE].Label_ := 'Agence voyage';
 Channels[CH_AGENCE].Commission := 12.0;
 Channels[CH_AGENCE].Enabled := True;

 Channels[CH_CORPORATE].Code := CH_CORPORATE;
 Channels[CH_CORPORATE].Label_ := 'Corporate';
 Channels[CH_CORPORATE].Commission := 5.0;
 Channels[CH_CORPORATE].Enabled := True;

 Channels[CH_GROUP].Code := CH_GROUP;
 Channels[CH_GROUP].Label_ := 'Groupe / event';
 Channels[CH_GROUP].Commission := 8.0;
 Channels[CH_GROUP].Enabled := True;
End;

Procedure InitGuests;
Var I: Integer;
Begin
 For I := 0 To MAX_GUESTS - 1 Do Begin
  Guests[I].Active := False;
  Guests[I].ID := 0;
  Guests[I].FirstName := '';
  Guests[I].LastName := '';
  Guests[I].Email := '';
  Guests[I].Phone := '';
  Guests[I].Address := '';
  Guests[I].City := '';
  Guests[I].Country := '';
  Guests[I].IDDoc := '';
  Guests[I].DOB.Year := 1970; Guests[I].DOB.Month := 1; Guests[I].DOB.Day := 1;
  Guests[I].DOB.Hour := 0; Guests[I].DOB.Min := 0;
  Guests[I].Loyalty := LOY_NONE;
  Guests[I].Points := 0;
  Guests[I].TotalStays := 0;
  Guests[I].TotalSpent := 0;
  Guests[I].Blacklist := False;
  Guests[I].Notes := '';
  Guests[I].Language := 'FR';
  Guests[I].Created := Guests[I].DOB;
 End;
 GuestCount := 0;
 NextGuestID := 1000;
End;

Procedure InitCharges;
Var I: Integer;
Begin
 For I := 0 To MAX_CHARGES - 1 Do Begin
  Charges[I].Active := False;
  Charges[I].ChargeID := 0;
  Charges[I].SpotIdx := -1;
  Charges[I].GuestID := 0;
  Charges[I].Category := SVC_DIVERS;
  Charges[I].Description := '';
  Charges[I].Amount := 0;
  Charges[I].Quantity := 1;
  Charges[I].Paid := False;
  Charges[I].PaymentRef := '';
 End;
 ChargeCount := 0;
 NextChargeID := 50000;
End;

Procedure InitGroups;
Var I: Integer;
Begin
 For I := 0 To MAX_GROUPS - 1 Do Begin
  GroupBookings[I].Active := False;
  GroupBookings[I].ID := 0;
  GroupBookings[I].Name := '';
  GroupBookings[I].ContactName := '';
  GroupBookings[I].ContactPhone := '';
  GroupBookings[I].ContactEmail := '';
  GroupBookings[I].RoomsBooked := 0;
  GroupBookings[I].Adults := 0;
  GroupBookings[I].Children := 0;
  GroupBookings[I].Discount := 0;
  GroupBookings[I].TotalDue := 0;
  GroupBookings[I].Paid := 0;
  GroupBookings[I].Notes := '';
 End;
 GroupCount := 0;
 NextGroupID := 7000;
End;

Procedure InitRatePlans;
Var I: Integer;
Begin
 For I := 0 To MAX_RATEPLANS - 1 Do Begin
  RatePlans[I].Active := False;
  RatePlans[I].ID := 0;
  RatePlans[I].Name := '';
  RatePlans[I].Description := '';
  RatePlans[I].Discount := 0;
  RatePlans[I].IncludeBreakfast := False;
  RatePlans[I].IncludeDinner := False;
  RatePlans[I].IncludeParking := False;
  RatePlans[I].MinNights := 1;
  RatePlans[I].CancelPolicy := '';
 End;
 RatePlanCount := 0;
 NextRatePlanID := 3000;

 { Plans par defaut }
 RatePlans[0].Active := True;
 RatePlans[0].ID := 3001;
 RatePlans[0].Name := 'Standard';
 RatePlans[0].Description := 'Tarif normal, sans extras';
 RatePlans[0].Discount := 0;
 RatePlans[0].MinNights := 1;
 RatePlans[0].CancelPolicy := 'Annulation 24h avant';

 RatePlans[1].Active := True;
 RatePlans[1].ID := 3002;
 RatePlans[1].Name := 'Petit dejeuner';
 RatePlans[1].Description := 'Avec petit dejeuner inclus';
 RatePlans[1].IncludeBreakfast := True;
 RatePlans[1].MinNights := 1;
 RatePlans[1].CancelPolicy := 'Annulation 24h avant';

 RatePlans[2].Active := True;
 RatePlans[2].ID := 3003;
 RatePlans[2].Name := 'Demi pension';
 RatePlans[2].Description := 'P-dej + diner';
 RatePlans[2].IncludeBreakfast := True;
 RatePlans[2].IncludeDinner := True;
 RatePlans[2].MinNights := 2;
 RatePlans[2].CancelPolicy := 'Annulation 48h avant';

 RatePlans[3].Active := True;
 RatePlans[3].ID := 3004;
 RatePlans[3].Name := 'Long sejour';
 RatePlans[3].Description := 'Sejour 7+ nuits';
 RatePlans[3].Discount := 15;
 RatePlans[3].MinNights := 7;
 RatePlans[3].CancelPolicy := 'Non remboursable';

 RatePlans[4].Active := True;
 RatePlans[4].ID := 3005;
 RatePlans[4].Name := 'Promo flash';
 RatePlans[4].Description := 'Reservation 30j avant';
 RatePlans[4].Discount := 25;
 RatePlans[4].MinNights := 1;
 RatePlans[4].CancelPolicy := 'Non remboursable';

 RatePlanCount := 5;
 NextRatePlanID := 3006;
End;

Procedure InitMaintenance;
Var I: Integer;
Begin
 For I := 0 To MAX_MAINTENANCE - 1 Do Begin
  MaintTickets[I].Active := False;
  MaintTickets[I].ID := 0;
  MaintTickets[I].SpotIdx := -1;
  MaintTickets[I].Priority := 1;
  MaintTickets[I].Description := '';
  MaintTickets[I].ReportedBy := '';
  MaintTickets[I].AssignedTo := '';
  MaintTickets[I].Closed := False;
  MaintTickets[I].Cost := 0;
  MaintTickets[I].Notes := '';
 End;
 MaintCount := 0;
 NextMaintID := 9000;
End;

Procedure InitAuditLog;
Var I: Integer;
Begin
 For I := 0 To MAX_AUDIT_LOG - 1 Do Begin
  AuditLog[I].Active := False;
  AuditLog[I].Occupancy := 0;
  AuditLog[I].ADR := 0;
  AuditLog[I].RevPAR := 0;
  AuditLog[I].Revenue := 0;
  AuditLog[I].Arrivals := 0;
  AuditLog[I].Departures := 0;
  AuditLog[I].NoShows := 0;
  AuditLog[I].Cancellations := 0;
  AuditLog[I].Notes := '';
 End;
 AuditCount := 0;
End;

Procedure InitPMS;
Begin
 InitDefaultFloors;
 InitDefaultRoomTypes;
 InitDefaultSeasons;
 InitDefaultChannels;
 InitGuests;
 InitCharges;
 InitGroups;
 InitRatePlans;
 InitMaintenance;
 InitAuditLog;
 PMSChargesToday := 0;
 PMSCheckinsToday := 0;
 PMSCheckoutsToday := 0;
 PMSNoShowsToday := 0;
End;

{ ----- Helpers chambres ----- }

Function RoomTypeLabel(T: Byte): String;
Begin
 If T >= RT_TYPES Then RoomTypeLabel := '?'
 Else RoomTypeLabel := RoomTypes[T].Label_;
End;

Function RoomTypeShort(T: Byte): String;
Begin
 If T >= RT_TYPES Then RoomTypeShort := '?'
 Else RoomTypeShort := RoomTypes[T].ShortLbl;
End;

Function HKStateLabel(H: Byte): String;
Begin
 Case H Of
  HK_CLEAN:      HKStateLabel := 'Propre';
  HK_DIRTY:      HKStateLabel := 'Sale';
  HK_INSPECTED:  HKStateLabel := 'Inspectee';
  HK_OOO:        HKStateLabel := 'Hors service (maint)';
  HK_OOS:        HKStateLabel := 'Hors usage';
  HK_INPROGRESS: HKStateLabel := 'Menage en cours';
  Else HKStateLabel := '?';
 End;
End;

Function HKStateShort(H: Byte): String;
Begin
 Case H Of
  HK_CLEAN:      HKStateShort := 'CLN';
  HK_DIRTY:      HKStateShort := 'DRT';
  HK_INSPECTED:  HKStateShort := 'INS';
  HK_OOO:        HKStateShort := 'OOO';
  HK_OOS:        HKStateShort := 'OOS';
  HK_INPROGRESS: HKStateShort := 'PRG';
  Else HKStateShort := '?';
 End;
End;

Function ChannelLabel(C: Byte): String;
Begin
 If C >= CH_COUNT Then ChannelLabel := '?'
 Else ChannelLabel := Channels[C].Label_;
End;

Function LoyaltyLabel(L: Byte): String;
Begin
 Case L Of
  LOY_NONE:     LoyaltyLabel := 'Aucun';
  LOY_SILVER:   LoyaltyLabel := 'Argent';
  LOY_GOLD:     LoyaltyLabel := 'Or';
  LOY_PLATINUM: LoyaltyLabel := 'Platine';
  LOY_DIAMOND:  LoyaltyLabel := 'Diamant';
  Else LoyaltyLabel := '?';
 End;
End;

Function ResStatusLabel(S: Byte): String;
Begin
 Case S Of
  RES_CONFIRMED:   ResStatusLabel := 'Confirmee';
  RES_CHECKED_IN:  ResStatusLabel := 'Enregistree';
  RES_CHECKED_OUT: ResStatusLabel := 'Departie';
  RES_NOSHOW:      ResStatusLabel := 'No-show';
  RES_CANCELLED:   ResStatusLabel := 'Annulee';
  Else ResStatusLabel := '?';
 End;
End;

Function SvcLabel(C: Byte): String;
Begin
 Case C Of
  SVC_RESTAURANT:    SvcLabel := 'Restaurant';
  SVC_MINIBAR:       SvcLabel := 'Mini-bar';
  SVC_BLANCHISSERIE: SvcLabel := 'Blanchisserie';
  SVC_SPA:           SvcLabel := 'Spa / Massage';
  SVC_TELEPHONE:     SvcLabel := 'Telephone';
  SVC_INTERNET:      SvcLabel := 'Internet / WiFi';
  SVC_PARKING:       SvcLabel := 'Stationnement';
  SVC_TAXI:          SvcLabel := 'Taxi / Transport';
  SVC_DIVERS:        SvcLabel := 'Divers';
  Else SvcLabel := '?';
 End;
End;

Function PriorityLabel(P: Byte): String;
Begin
 Case P Of
  0: PriorityLabel := 'Basse';
  1: PriorityLabel := 'Normale';
  2: PriorityLabel := 'Haute';
  3: PriorityLabel := 'Urgente';
  Else PriorityLabel := '?';
 End;
End;

Function SeasonForDate(Const DT: TDateTime): Byte;
Var I: Byte; M, D: Word;
    InRange: Boolean;
Begin
 SeasonForDate := SEASON_MID;
 M := DT.Month; D := DT.Day;
 For I := 0 To SEASON_CNT - 1 Do Begin
  If Not Seasons[I].Enabled Then Continue;
  { Cas standard : meme mois ou intervalle direct }
  If Seasons[I].StartMonth <= Seasons[I].EndMonth Then Begin
   InRange := ((M > Seasons[I].StartMonth) Or
               ((M = Seasons[I].StartMonth) And (D >= Seasons[I].StartDay))) And
              ((M < Seasons[I].EndMonth) Or
               ((M = Seasons[I].EndMonth) And (D <= Seasons[I].EndDay)));
  End Else Begin
   { Saison chevauchant l annee (Dec-Jan) }
   InRange := ((M > Seasons[I].StartMonth) Or
               ((M = Seasons[I].StartMonth) And (D >= Seasons[I].StartDay))) Or
              ((M < Seasons[I].EndMonth) Or
               ((M = Seasons[I].EndMonth) And (D <= Seasons[I].EndDay)));
  End;
  If InRange Then Begin SeasonForDate := I; Exit; End;
 End;
End;

Function ComputeRoomRate(SpotIdxV: Integer): Real;
Var Base, Mult: Real; Season: Byte;
Begin
 If (SpotIdxV < 0) Or (SpotIdxV >= MAX_SPOTS) Then Begin
  ComputeRoomRate := 0; Exit;
 End;
 Base := RoomTypes[Spots[SpotIdxV].RoomType].BaseRate;
 Season := SeasonForDate(NowDT);
 Mult := Seasons[Season].Multiplier;
 ComputeRoomRate := Base * Mult;
End;

Function ComputeChannelCommission(Source: Byte; Amount: Real): Real;
Begin
 If Source >= CH_COUNT Then ComputeChannelCommission := 0
 Else ComputeChannelCommission := Amount * Channels[Source].Commission / 100.0;
End;

{ ----- Operations chambres / etages ----- }

Procedure SetFloorCount(N: Integer);
Begin
 If N < 1 Then N := 1;
 If N > MAX_FLOORS Then N := MAX_FLOORS;
 FloorCount := N;
 If CurrentFloor >= FloorCount Then CurrentFloor := 0;
End;

Procedure GoNextFloor;
Begin SwitchFloor(CurrentFloor + 1); End;

Procedure GoPrevFloor;
Begin SwitchFloor(CurrentFloor - 1); End;

Procedure GoFirstFloor;
Begin SwitchFloor(0); End;

Procedure GoLastFloor;
Begin SwitchFloor(FloorCount - 1); End;

Function TotalFreeRooms: Integer;
Begin TotalFreeRooms := CountByState(ssFree); End;

Function TotalOccupiedRooms: Integer;
Begin TotalOccupiedRooms := CountByState(ssOccupied); End;

Function OccupancyRate: Real;
Var Total: Integer;
Begin
 Total := SpotCount;
 If Total = 0 Then OccupancyRate := 0
 Else OccupancyRate := (TotalOccupiedRooms * 100.0) / Total;
End;

Function OccupancyRateOnFloor(F: Integer): Real;
Var Total: Integer;
Begin
 Total := RoomsPerFloor;
 If Total = 0 Then OccupancyRateOnFloor := 0
 Else OccupancyRateOnFloor :=
   (CountByStateOnFloor(ssOccupied, F) * 100.0) / Total;
End;

Function CountHKState(H: Byte): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     ((I Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
     (Spots[I].HKState = H) Then Inc(N);
 CountHKState := N;
End;

Function CountRoomType(T: Byte): Integer;
Var I, N, F, C, R: Integer;
Begin
 N := 0;
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    I := SpotIdxAt(F, C, R);
    If Spots[I].RoomType = T Then Inc(N);
   End;
 CountRoomType := N;
End;

Procedure SetRoomHKState(Idx: Integer; NewState: Byte);
Begin
 If (Idx < 0) Or (Idx >= MAX_SPOTS) Then Exit;
 Spots[Idx].HKState := NewState;
End;

Procedure SetAllFloorHKState(F: Integer; NewState: Byte);
Var R, C: Integer;
Begin
 For R := 0 To RowCount - 1 Do
  For C := 0 To ColCount - 1 Do
   Spots[SpotIdxAt(F, C, R)].HKState := NewState;
End;

Procedure AutoCleanAfterCheckout(Idx: Integer);
{ Apres un check-out, la chambre passe automatiquement Sale. }
Begin
 If (Idx < 0) Or (Idx >= MAX_SPOTS) Then Exit;
 Spots[Idx].HKState := HK_DIRTY;
End;

Procedure AssignRoomTypeByFloor;
{ Attribue automatiquement des types selon l etage (par defaut). }
Var F, C, R, I: Integer; T: Byte;
Begin
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    I := SpotIdxAt(F, C, R);
    Case F Of
     0: T := RT_STANDARD;
     1: T := RT_DOUBLE;
     2: T := RT_TWIN;
     3: T := RT_FAMILY;
     4: T := RT_DELUXE;
     5: T := RT_SUITE;
     6: T := RT_SUITE;
     7: T := RT_DELUXE;
     8: T := RT_PENTHOUSE;
     9: T := RT_PENTHOUSE;
     Else T := RT_STANDARD;
    End;
    Spots[I].RoomType := T;
    Spots[I].RateRoom := RoomTypes[T].BaseRate;
   End;
End;


{ ============================================================
  PMS - MODULE 2 : GESTION DES CLIENTS (GUESTS)
  ============================================================ }

Function FindGuestIdxByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindGuestIdxByID := -1;
 If ID <= 0 Then Exit;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And (Guests[I].ID = ID) Then Begin
   FindGuestIdxByID := I; Exit;
  End;
End;

Function FindGuestIdxByName(Const LName, FName: String): Integer;
Var I: Integer; ULN, UFN: String;
Begin
 FindGuestIdxByName := -1;
 ULN := UpStr(TrimStr(LName));
 UFN := UpStr(TrimStr(FName));
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And
     (UpStr(Guests[I].LastName) = ULN) And
     (UpStr(Guests[I].FirstName) = UFN) Then Begin
   FindGuestIdxByName := I; Exit;
  End;
End;

Function FindGuestIdxByEmail(Const Em: String): Integer;
Var I: Integer; UE: String;
Begin
 FindGuestIdxByEmail := -1;
 UE := UpStr(TrimStr(Em));
 If UE = '' Then Exit;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And (UpStr(Guests[I].Email) = UE) Then Begin
   FindGuestIdxByEmail := I; Exit;
  End;
End;

Function FindGuestIdxByPhone(Const Ph: String): Integer;
Var I: Integer; UP: String;
Begin
 FindGuestIdxByPhone := -1;
 UP := TrimStr(Ph);
 If UP = '' Then Exit;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And (Guests[I].Phone = UP) Then Begin
   FindGuestIdxByPhone := I; Exit;
  End;
End;

Function FindFreeGuestSlot: Integer;
Var I: Integer;
Begin
 FindFreeGuestSlot := -1;
 For I := 0 To MAX_GUESTS - 1 Do
  If Not Guests[I].Active Then Begin
   FindFreeGuestSlot := I; Exit;
  End;
End;

Function AddGuestFull(Const FName, LName, Em, Ph, Addr,
                      Cty, Ctry, Doc: String;
                      DOB: TDateTime;
                      Loy: Byte;
                      Const Lang: String): Integer;
Var Idx: Integer;
Begin
 AddGuestFull := -1;
 Idx := FindFreeGuestSlot;
 If Idx < 0 Then Exit;
 Guests[Idx].Active := True;
 Guests[Idx].ID := NextGuestID;
 Inc(NextGuestID);
 Guests[Idx].FirstName := TrimStr(FName);
 Guests[Idx].LastName := TrimStr(LName);
 Guests[Idx].Email := TrimStr(Em);
 Guests[Idx].Phone := TrimStr(Ph);
 Guests[Idx].Address := TrimStr(Addr);
 Guests[Idx].City := TrimStr(Cty);
 Guests[Idx].Country := TrimStr(Ctry);
 Guests[Idx].IDDoc := TrimStr(Doc);
 Guests[Idx].DOB := DOB;
 Guests[Idx].Loyalty := Loy;
 Guests[Idx].Points := 0;
 Guests[Idx].TotalStays := 0;
 Guests[Idx].TotalSpent := 0;
 Guests[Idx].Blacklist := False;
 Guests[Idx].Notes := '';
 Guests[Idx].Language := Lang;
 GetCurrentDT(Guests[Idx].Created);
 Inc(GuestCount);
 AddGuestFull := Idx;
End;

Procedure DeleteGuestByIdx(Idx: Integer);
Begin
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Exit;
 If Not Guests[Idx].Active Then Exit;
 Guests[Idx].Active := False;
 If GuestCount > 0 Then Dec(GuestCount);
End;

Procedure UpgradeLoyaltyByPoints(Idx: Integer);
Begin
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Exit;
 If Not Guests[Idx].Active Then Exit;
 If Guests[Idx].Points >= 20000 Then Guests[Idx].Loyalty := LOY_DIAMOND
 Else If Guests[Idx].Points >= 10000 Then Guests[Idx].Loyalty := LOY_PLATINUM
 Else If Guests[Idx].Points >= 5000  Then Guests[Idx].Loyalty := LOY_GOLD
 Else If Guests[Idx].Points >= 1000  Then Guests[Idx].Loyalty := LOY_SILVER
 Else Guests[Idx].Loyalty := LOY_NONE;
End;

Procedure AwardGuestPoints(Idx: Integer; Pts: LongInt);
Begin
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Exit;
 If Not Guests[Idx].Active Then Exit;
 Guests[Idx].Points := Guests[Idx].Points + Pts;
 UpgradeLoyaltyByPoints(Idx);
End;

Function RedeemGuestPoints(Idx: Integer; Pts: LongInt): Boolean;
Begin
 RedeemGuestPoints := False;
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Exit;
 If Not Guests[Idx].Active Then Exit;
 If Guests[Idx].Points < Pts Then Exit;
 Guests[Idx].Points := Guests[Idx].Points - Pts;
 UpgradeLoyaltyByPoints(Idx);
 RedeemGuestPoints := True;
End;

Procedure UpdateGuestAfterStay(Idx: Integer; Spent: Real);
Begin
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Exit;
 If Not Guests[Idx].Active Then Exit;
 Inc(Guests[Idx].TotalStays);
 Guests[Idx].TotalSpent := Guests[Idx].TotalSpent + Spent;
 AwardGuestPoints(Idx, Trunc(Spent));
End;

Function GuestDisplayName(Idx: Integer): String;
Begin
 If (Idx < 0) Or (Idx >= MAX_GUESTS) Then Begin
  GuestDisplayName := '(inconnu)'; Exit;
 End;
 If Not Guests[Idx].Active Then Begin
  GuestDisplayName := '(supprime)'; Exit;
 End;
 GuestDisplayName := Guests[Idx].LastName + ', ' + Guests[Idx].FirstName;
End;

Function GuestDisplayNameByID(ID: LongInt): String;
Var I: Integer;
Begin
 I := FindGuestIdxByID(ID);
 If I < 0 Then GuestDisplayNameByID := '(inconnu)'
 Else GuestDisplayNameByID := GuestDisplayName(I);
End;

{ ----- Dialogue : ajouter / editer un client ----- }

Procedure DlgGuestAddEdit(EditIdx: Integer; IsEdit: Boolean);
Const
 LblX = 18; FldX = 130;
 IFName = 0; IFLast = 1; IFEmail = 2; IFPhone = 3;
 IFAddr = 4; IFCity = 5; IFCntry = 6; IFDoc = 7;
 IFDOBY = 8; IFDOBM = 9; IFDOBD = 10;
 IFLoy = 11; IFLang = 12; IFNotes = 13;
 ICBlack = 14;
 IBOK = 15; IBCancel = 16;
Var
 D: TDialog;
 Title: String;
 LoyOpts: Array[0..LOY_LEVELS - 1] Of String[15];
 LoyLbl: Array[0..LOY_LEVELS - 1] Of PChar;
 K: Integer;
 G: TGuest;
 LoySel: Integer;
 DOBStr: String;
 V: LongInt; ErrCode: Integer;
 DOB: TDateTime;
 NewIdx: Integer;
Begin
 If IsEdit Then Title := 'Modifier client'
 Else Title := 'Nouveau client';
 DlgInit(D, Title, 560, 380);
 AddLabel(D,  LblX,  35, 'Prenom:');
 AddEdit(D,   FldX,  32, 240, 31);            { IFName }
 AddLabel(D,  LblX,  60, 'Nom:');
 AddEdit(D,   FldX,  57, 240, 31);            { IFLast }
 AddLabel(D,  LblX,  85, 'Courriel:');
 AddEdit(D,   FldX,  82, 320, 47);            { IFEmail }
 AddLabel(D,  LblX, 110, 'Telephone:');
 AddEdit(D,   FldX, 107, 180, 15);            { IFPhone }
 AddLabel(D,  LblX, 135, 'Adresse:');
 AddEdit(D,   FldX, 132, 380, 63);            { IFAddr }
 AddLabel(D,  LblX, 160, 'Ville:');
 AddEdit(D,   FldX, 157, 240, 31);            { IFCity }
 AddLabel(D,  LblX, 185, 'Pays:');
 AddEdit(D,   FldX, 182, 100, 15);            { IFCntry }
 AddLabel(D,  LblX, 210, 'Piece ID:');
 AddEdit(D,   FldX, 207, 180, 15);            { IFDoc }
 AddLabel(D,  LblX, 235, 'Naiss. AAAA/MM/JJ:');
 AddEdit(D,   FldX, 232,  60,  4);            { IFDOBY }
 AddEdit(D,   FldX +  65, 232,  40, 2);       { IFDOBM }
 AddEdit(D,   FldX + 110, 232,  40, 2);       { IFDOBD }

 AddLabel(D,  LblX, 260, 'Fidelite:');
 LoyOpts[0]:='Aucun'; LoyOpts[1]:='Argent'; LoyOpts[2]:='Or';
 LoyOpts[3]:='Platine'; LoyOpts[4]:='Diamant';
 For K := 0 To LOY_LEVELS - 1 Do LoyLbl[K] := @LoyOpts[K][1];
 AddCombo(D, FldX, 257, 120, LoyLbl, LOY_LEVELS);

 AddLabel(D,  LblX, 285, 'Langue:');
 AddEdit(D,   FldX, 282,  60,  7);            { IFLang }
 AddLabel(D,  LblX, 310, 'Notes:');
 AddEdit(D,   FldX, 307, 380, 63);            { IFNotes }
 AddCheck(D,  LblX, 335, 'Blackliste', False);

 AddButton(D, 360, 335, 90, 'OK', BTN_DEFAULT);
 AddButton(D, 460, 335, 90, 'Annuler', BTN_CANCEL);

 If IsEdit And (EditIdx >= 0) Then Begin
  G := Guests[EditIdx];
  D.Ctrls[IFName].Text  := G.FirstName;
  D.Ctrls[IFLast].Text  := G.LastName;
  D.Ctrls[IFEmail].Text := G.Email;
  D.Ctrls[IFPhone].Text := G.Phone;
  D.Ctrls[IFAddr].Text  := G.Address;
  D.Ctrls[IFCity].Text  := G.City;
  D.Ctrls[IFCntry].Text := G.Country;
  D.Ctrls[IFDoc].Text   := G.IDDoc;
  D.Ctrls[IFDOBY].Text  := IntToStr(G.DOB.Year);
  D.Ctrls[IFDOBM].Text  := IntToStr(G.DOB.Month);
  D.Ctrls[IFDOBD].Text  := IntToStr(G.DOB.Day);
  D.Ctrls[IFLoy].ListSel := G.Loyalty;
  D.Ctrls[IFLang].Text  := G.Language;
  D.Ctrls[IFNotes].Text := G.Notes;
  D.Ctrls[ICBlack].Checked := G.Blacklist;
 End Else Begin
  D.Ctrls[IFDOBY].Text := '1980';
  D.Ctrls[IFDOBM].Text := '1';
  D.Ctrls[IFDOBD].Text := '1';
  D.Ctrls[IFLang].Text := 'FR';
 End;

 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IFDOBY].Text, V, ErrCode); DOB.Year := V;
  Val(D.Ctrls[IFDOBM].Text, V, ErrCode); DOB.Month := V;
  Val(D.Ctrls[IFDOBD].Text, V, ErrCode); DOB.Day := V;
  DOB.Hour := 0; DOB.Min := 0;
  LoySel := D.Ctrls[IFLoy].ListSel;
  If LoySel < 0 Then LoySel := 0;

  If IsEdit And (EditIdx >= 0) Then Begin
   Guests[EditIdx].FirstName := D.Ctrls[IFName].Text;
   Guests[EditIdx].LastName  := D.Ctrls[IFLast].Text;
   Guests[EditIdx].Email     := D.Ctrls[IFEmail].Text;
   Guests[EditIdx].Phone     := D.Ctrls[IFPhone].Text;
   Guests[EditIdx].Address   := D.Ctrls[IFAddr].Text;
   Guests[EditIdx].City      := D.Ctrls[IFCity].Text;
   Guests[EditIdx].Country   := D.Ctrls[IFCntry].Text;
   Guests[EditIdx].IDDoc     := D.Ctrls[IFDoc].Text;
   Guests[EditIdx].DOB       := DOB;
   Guests[EditIdx].Loyalty   := LoySel;
   Guests[EditIdx].Language  := D.Ctrls[IFLang].Text;
   Guests[EditIdx].Notes     := D.Ctrls[IFNotes].Text;
   Guests[EditIdx].Blacklist := D.Ctrls[ICBlack].Checked;
   ShowMessageBox('Client', 'Client modifie.');
  End Else Begin
   NewIdx := AddGuestFull(
    D.Ctrls[IFName].Text, D.Ctrls[IFLast].Text,
    D.Ctrls[IFEmail].Text, D.Ctrls[IFPhone].Text,
    D.Ctrls[IFAddr].Text, D.Ctrls[IFCity].Text,
    D.Ctrls[IFCntry].Text, D.Ctrls[IFDoc].Text,
    DOB, LoySel, D.Ctrls[IFLang].Text);
   If NewIdx < 0 Then
    ShowMessageBox('Erreur', 'Fichier client plein.')
   Else Begin
    Guests[NewIdx].Notes := D.Ctrls[IFNotes].Text;
    Guests[NewIdx].Blacklist := D.Ctrls[ICBlack].Checked;
    ShowMessageBox('Client',
     'Client cree (ID ' + IntToStr(Guests[NewIdx].ID) + ').');
   End;
  End;
 End;
End;

Procedure DlgGuestAdd;
Begin DlgGuestAddEdit(-1, False); End;

Procedure DlgGuestEdit;
Const IL = 0; IBPick = 1; IBClose = 2;
Var D: TDialog; I, Cnt: Integer;
    Items: Array[0..MAX_GUESTS - 1] Of String[60];
    ItemsP: Array[0..MAX_GUESTS - 1] Of PChar;
    Sel: Integer;
Begin
 Cnt := 0;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active Then Begin
   Items[Cnt] := IntToStr(Guests[I].ID) + ' - ' +
                 Guests[I].LastName + ', ' + Guests[I].FirstName +
                 ' [' + LoyaltyLabel(Guests[I].Loyalty) + ']';
   ItemsP[Cnt] := @Items[Cnt][1];
   Inc(Cnt);
  End;
 If Cnt = 0 Then Begin
  ShowMessageBox('Clients', 'Aucun client enregistre.');
  Exit;
 End;
 DlgInit(D, 'Choisir le client a modifier', 460, 320);
 AddListbox(D, 14, 30, 432, 220, ItemsP, Cnt);
 AddButton(D, 250, 260, 90, 'Modifier', BTN_DEFAULT);
 AddButton(D, 350, 260, 90, 'Fermer', BTN_CANCEL);
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[IL].ListSel;
  If Sel >= 0 Then Begin
   { Retrouver l index reel a partir de la position dans la liste }
   Cnt := 0;
   For I := 0 To MAX_GUESTS - 1 Do
    If Guests[I].Active Then Begin
     If Cnt = Sel Then Begin DlgGuestAddEdit(I, True); Exit; End;
     Inc(Cnt);
    End;
  End;
 End;
End;

Procedure DlgGuestDelete;
Const IL = 0; IBDel = 1; IBClose = 2;
Var D: TDialog; I, Cnt, Sel: Integer;
    Items: Array[0..MAX_GUESTS - 1] Of String[60];
    ItemsP: Array[0..MAX_GUESTS - 1] Of PChar;
Begin
 Cnt := 0;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active Then Begin
   Items[Cnt] := IntToStr(Guests[I].ID) + ' - ' +
                 Guests[I].LastName + ', ' + Guests[I].FirstName;
   ItemsP[Cnt] := @Items[Cnt][1];
   Inc(Cnt);
  End;
 If Cnt = 0 Then Begin
  ShowMessageBox('Clients', 'Aucun client a supprimer.');
  Exit;
 End;
 DlgInit(D, 'Supprimer un client', 420, 300);
 AddListbox(D, 14, 30, 392, 200, ItemsP, Cnt);
 AddButton(D, 220, 240, 90, 'Supprimer', BTN_DEFAULT);
 AddButton(D, 320, 240, 90, 'Annuler', BTN_CANCEL);
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[IL].ListSel;
  If Sel >= 0 Then Begin
   Cnt := 0;
   For I := 0 To MAX_GUESTS - 1 Do
    If Guests[I].Active Then Begin
     If Cnt = Sel Then Begin
      If ShowConfirmBox('Supprimer',
         'Supprimer ' + GuestDisplayName(I) + ' ?') Then Begin
       DeleteGuestByIdx(I);
       ShowMessageBox('Clients', 'Client supprime.');
      End;
      Exit;
     End;
     Inc(Cnt);
    End;
  End;
 End;
End;

Procedure DlgGuestList;
Const IL = 0; IBClose = 1; IBPrint = 2;
Var D: TDialog;
    I, Cnt: Integer;
    Items: Array[0..MAX_GUESTS - 1] Of String[78];
    ItemsP: Array[0..MAX_GUESTS - 1] Of PChar;
    G: TGuest;
    BlackMarker: Char;
Begin
 Cnt := 0;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active Then Begin
   G := Guests[I];
   If G.Blacklist Then BlackMarker := 'X' Else BlackMarker := ' ';
   Items[Cnt] := BlackMarker + ' ' + IntToStrW(G.ID, 5) + ' ' +
                 PadRight(G.LastName + ', ' + G.FirstName, 28) +
                 PadRight(LoyaltyLabel(G.Loyalty), 10) +
                 PadLeft(IntToStr(G.TotalStays), 4) + ' ' +
                 PadLeft(RealToStr(G.TotalSpent, 0, 2), 10);
   ItemsP[Cnt] := @Items[Cnt][1];
   Inc(Cnt);
  End;
 If Cnt = 0 Then Begin
  ShowMessageBox('Clients', 'Aucun client enregistre.');
  Exit;
 End;
 DlgInit(D, 'Liste des clients (' + IntToStr(Cnt) + ')', 580, 360);
 AddListbox(D, 12, 30, 556, 280, ItemsP, Cnt);
 AddButton(D, 380, 320, 90, 'Fermer', BTN_DEFAULT);
 AddButton(D, 480, 320, 90, 'Imprimer', BTN_NORMAL);
 DlgRun(D);
End;

Procedure DlgGuestSearch;
Var Q: String; I, Found: Integer; UQ: String;
    Lines: TReportArray; Cnt: Integer;
Begin
 Q := '';
 If Not ShowInputBox('Rechercher client',
       'Nom, prenom, courriel, telephone ou ID:', Q, 47) Then Exit;
 UQ := UpStr(TrimStr(Q));
 If UQ = '' Then Exit;
 Cnt := 0;
 Lines[0] := 'Resultats pour : ' + Q;
 Lines[1] := '';
 Cnt := 2;
 Found := 0;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And (Cnt < MAX_REPORT_LINES - 2) Then Begin
   If (Pos(UQ, UpStr(Guests[I].LastName)) > 0) Or
      (Pos(UQ, UpStr(Guests[I].FirstName)) > 0) Or
      (Pos(UQ, UpStr(Guests[I].Email)) > 0) Or
      (Pos(UQ, UpStr(Guests[I].Phone)) > 0) Or
      (UpStr(IntToStr(Guests[I].ID)) = UQ) Then Begin
    Inc(Found);
    Lines[Cnt] := 'ID ' + IntToStrW(Guests[I].ID, 5) + '  ' +
                  Guests[I].LastName + ', ' + Guests[I].FirstName +
                  '  Tel:' + Guests[I].Phone;
    Inc(Cnt);
    If Length(Guests[I].Email) > 0 Then Begin
     Lines[Cnt] := '       Email: ' + Guests[I].Email;
     Inc(Cnt);
    End;
    If Length(Guests[I].City) > 0 Then Begin
     Lines[Cnt] := '       Ville: ' + Guests[I].City + ' / Pays: ' +
                   Guests[I].Country;
     Inc(Cnt);
    End;
    Lines[Cnt] := '       Sejours: ' + IntToStr(Guests[I].TotalStays) +
                  '  Total depense: ' + RealToStr(Guests[I].TotalSpent, 0, 2) +
                  '  Pts: ' + IntToStr(Guests[I].Points);
    Inc(Cnt);
    Lines[Cnt] := '       Fidelite: ' + LoyaltyLabel(Guests[I].Loyalty);
    If Guests[I].Blacklist Then
     Lines[Cnt] := Lines[Cnt] + '  *** BLACKLISTE ***';
    Inc(Cnt);
    Lines[Cnt] := '';
    Inc(Cnt);
   End;
  End;
 If Found = 0 Then Begin
  Lines[Cnt] := '(aucun resultat)';
  Inc(Cnt);
 End Else Begin
  Lines[Cnt] := 'Total : ' + IntToStr(Found) + ' client(s) trouve(s).';
  Inc(Cnt);
 End;
 ShowReportDialog('Recherche client', Lines, Cnt);
End;

Procedure DlgGuestHistory;
Const IL = 0; IBClose = 1;
Var D: TDialog; ID: LongInt; IDStr: String; ErrCode: Integer;
    IdxG, I, Cnt: Integer;
    Items: Array[0..MAX_HISTORY - 1] Of String[78];
    ItemsP: Array[0..MAX_HISTORY - 1] Of PChar;
    T: TTransaction;
Begin
 IDStr := '';
 If Not ShowInputBox('Historique', 'ID du client:', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin
  ShowMessageBox('Erreur', 'ID invalide.'); Exit;
 End;
 IdxG := FindGuestIdxByID(ID);
 If IdxG < 0 Then Begin
  ShowMessageBox('Erreur', 'Client introuvable.'); Exit;
 End;
 Cnt := 0;
 For I := 0 To MAX_HISTORY - 1 Do Begin
  If Not GetTransactionAt(I, T) Then Continue;
  If T.Plate = '' Then Continue;
  { On considere correspondance par nom car les transactions ne
    portent pas l ID guest. }
  If UpStr(T.Owner) = UpStr(GuestDisplayName(IdxG)) Then Begin
   Items[Cnt] := FormatDateTime(T.StartDT) + ' -> ' +
                 FormatDateTime(T.EndDT) + '  $' +
                 RealToStr(T.Paid, 0, 2) + '  Ch.' +
                 IntToStr(T.SpotIdx + 1);
   ItemsP[Cnt] := @Items[Cnt][1];
   Inc(Cnt);
   If Cnt >= MAX_HISTORY Then Break;
  End;
 End;
 If Cnt = 0 Then Begin
  Items[0] := '(aucune transaction trouvee pour ce client)';
  ItemsP[0] := @Items[0][1];
  Cnt := 1;
 End;
 DlgInit(D, 'Historique ' + GuestDisplayName(IdxG), 560, 360);
 AddListbox(D, 12, 30, 536, 280, ItemsP, Cnt);
 AddButton(D, 450, 320, 90, 'Fermer', BTN_DEFAULT);
 DlgRun(D);
End;

Procedure DlgGuestBlacklist;
Var Q: String; ID: LongInt; ErrCode: Integer; IdxG: Integer;
Begin
 Q := '';
 If Not ShowInputBox('Blackliste', 'ID du client a (de)blacklister:',
                     Q, 6) Then Exit;
 Val(TrimStr(Q), ID, ErrCode);
 If ErrCode <> 0 Then Begin
  ShowMessageBox('Erreur', 'ID invalide.'); Exit;
 End;
 IdxG := FindGuestIdxByID(ID);
 If IdxG < 0 Then Begin
  ShowMessageBox('Erreur', 'Client introuvable.'); Exit;
 End;
 Guests[IdxG].Blacklist := Not Guests[IdxG].Blacklist;
 If Guests[IdxG].Blacklist Then
  ShowMessageBox('Client', GuestDisplayName(IdxG) + ' : ajoute a la blackliste.')
 Else
  ShowMessageBox('Client', GuestDisplayName(IdxG) + ' : retire de la blackliste.');
End;


{ ============================================================
  PMS - MODULE 3 : FOLIO / CHARGES / SERVICES
  ============================================================ }

Function FindFreeChargeSlot: Integer;
Var I: Integer;
Begin
 FindFreeChargeSlot := -1;
 For I := 0 To MAX_CHARGES - 1 Do
  If Not Charges[I].Active Then Begin
   FindFreeChargeSlot := I; Exit;
  End;
End;

Function AddCharge(SpotIdxV: Integer; GuestID: LongInt; Cat: Byte;
                   Const Desc: String; Amount: Real; Qty: Word): Integer;
Var Idx: Integer;
Begin
 AddCharge := -1;
 Idx := FindFreeChargeSlot;
 If Idx < 0 Then Exit;
 Charges[Idx].Active := True;
 Charges[Idx].ChargeID := NextChargeID;
 Inc(NextChargeID);
 Charges[Idx].SpotIdx := SpotIdxV;
 Charges[Idx].GuestID := GuestID;
 Charges[Idx].Category := Cat;
 Charges[Idx].Description := Desc;
 Charges[Idx].Amount := Amount;
 Charges[Idx].Quantity := Qty;
 GetCurrentDT(Charges[Idx].AddedDT);
 Charges[Idx].Paid := False;
 Charges[Idx].PaymentRef := '';
 Inc(ChargeCount);
 If (SpotIdxV >= 0) And (SpotIdxV < MAX_SPOTS) Then
  Spots[SpotIdxV].RateExtra := Spots[SpotIdxV].RateExtra + Amount * Qty;
 PMSChargesToday := PMSChargesToday + Amount * Qty;
 AddCharge := Idx;
End;

Procedure RemoveCharge(Idx: Integer);
Var SpotIdxV: Integer; Amt: Real;
Begin
 If (Idx < 0) Or (Idx >= MAX_CHARGES) Then Exit;
 If Not Charges[Idx].Active Then Exit;
 SpotIdxV := Charges[Idx].SpotIdx;
 Amt := Charges[Idx].Amount * Charges[Idx].Quantity;
 If (SpotIdxV >= 0) And (SpotIdxV < MAX_SPOTS) Then
  Spots[SpotIdxV].RateExtra := Spots[SpotIdxV].RateExtra - Amt;
 PMSChargesToday := PMSChargesToday - Amt;
 If PMSChargesToday < 0 Then PMSChargesToday := 0;
 Charges[Idx].Active := False;
 If ChargeCount > 0 Then Dec(ChargeCount);
End;

Function CountSpotCharges(SpotIdxV: Integer): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = SpotIdxV) Then Inc(N);
 CountSpotCharges := N;
End;

Function TotalSpotCharges(SpotIdxV: Integer): Real;
Var I: Integer; T: Real;
Begin
 T := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = SpotIdxV) Then
   T := T + Charges[I].Amount * Charges[I].Quantity;
 TotalSpotCharges := T;
End;

Function TotalSpotChargesUnpaid(SpotIdxV: Integer): Real;
Var I: Integer; T: Real;
Begin
 T := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = SpotIdxV) And
     (Not Charges[I].Paid) Then
   T := T + Charges[I].Amount * Charges[I].Quantity;
 TotalSpotChargesUnpaid := T;
End;

Function CountChargesByCategory(Cat: Byte): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].Category = Cat) Then Inc(N);
 CountChargesByCategory := N;
End;

Function TotalChargesByCategory(Cat: Byte): Real;
Var I: Integer; T: Real;
Begin
 T := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].Category = Cat) Then
   T := T + Charges[I].Amount * Charges[I].Quantity;
 TotalChargesByCategory := T;
End;

Procedure MarkSpotChargesPaid(SpotIdxV: Integer; Const Ref: String);
Var I: Integer;
Begin
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = SpotIdxV) And
     (Not Charges[I].Paid) Then Begin
   Charges[I].Paid := True;
   GetCurrentDT(Charges[I].PaymentDT);
   Charges[I].PaymentRef := Ref;
  End;
End;

{ ----- Dialogues folio ----- }

Procedure DlgFolioView;
Const IL = 0; IBClose = 1; IBPrint = 2; IBAdd = 3; IBPay = 4;
Var
 D: TDialog;
 NumStr: String;
 Idx, I, Cnt, K: Integer;
 ErrCode: Integer;
 Items: Array[0..127] Of String[78];
 ItemsP: Array[0..127] Of PChar;
 SubTotal, Total: Real;
 R: TRoom;
Begin
 NumStr := '';
 If Not ShowInputBox('Folio', 'Numero de chambre :', NumStr, 5) Then Exit;
 Val(TrimStr(NumStr), I, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Numero invalide.'); Exit; End;
 { Recherche par numero affiche (RoomNumber). }
 Idx := -1;
 For K := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(K) < FloorCount) And
     ((K Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
     (RoomNumber(K) = I) Then Begin Idx := K; Break; End;
 If Idx < 0 Then Begin
  ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit;
 End;
 R := Spots[Idx];
 Cnt := 0;
 Items[Cnt] := 'Chambre ' + IntToStr(I) + ' (' +
               RoomTypeLabel(R.RoomType) + ')';
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 If R.State = ssOccupied Then Begin
  Items[Cnt] := 'Client: ' + R.Owner + ' (Folio ' + R.Plate + ')';
  ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
  Items[Cnt] := 'Sejour: ' + FormatDateTime(R.StartDT) + ' -> ' +
                FormatDateTime(R.EndDT);
  ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 End Else Begin
  Items[Cnt] := '*** Chambre libre, mais on peut voir un folio passe ***';
  ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 End;
 Items[Cnt] := '----------------------------------------';
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 SubTotal := 0; Total := 0;
 Items[Cnt] := 'Tarif chambre paye: ' + RealToStr(R.Paid, 0, 2);
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 Total := Total + R.Paid;
 Items[Cnt] := '----- Charges et services -----';
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = Idx) And
     (Cnt < 120) Then Begin
   Items[Cnt] := PadRight(SvcLabel(Charges[I].Category), 16) +
                 PadRight(Charges[I].Description, 30) +
                 'x' + IntToStr(Charges[I].Quantity) + ' ' +
                 PadLeft(RealToStr(Charges[I].Amount, 0, 2), 8);
   If Charges[I].Paid Then
    Items[Cnt] := Items[Cnt] + ' PAYE'
   Else
    Items[Cnt] := Items[Cnt] + ' du';
   ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
   SubTotal := SubTotal + Charges[I].Amount * Charges[I].Quantity;
  End;
 Items[Cnt] := '----------------------------------------';
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 Items[Cnt] := 'Sous-total services : ' + RealToStr(SubTotal, 0, 2);
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 Total := Total + SubTotal;
 Items[Cnt] := 'TOTAL FACTURE       : ' + RealToStr(Total, 0, 2);
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);
 Items[Cnt] := 'Du encore           : ' +
               RealToStr(TotalSpotChargesUnpaid(Idx), 0, 2);
 ItemsP[Cnt] := @Items[Cnt][1]; Inc(Cnt);

 DlgInit(D, 'Folio chambre', 600, 380);
 AddListbox(D, 12, 30, 576, 280, ItemsP, Cnt);
 AddButton(D, 250, 320, 90, 'Fermer', BTN_DEFAULT);
 AddButton(D, 350, 320, 90, 'Imprimer', BTN_NORMAL);
 AddButton(D, 450, 320, 90, 'Ajouter', BTN_NORMAL);
 AddButton(D, 550, 320, 40, 'Pay', BTN_NORMAL);
 DlgRun(D);
End;

Procedure DlgFolioAddCharge;
Const
 IRoom = 0; ICat = 1; IDesc = 2; IAmt = 3; IQty = 4;
 IBOK = 5; IBCancel = 6;
Var
 D: TDialog;
 CatOpts: Array[0..SVC_CATEGORIES - 1] Of String[20];
 CatLbl: Array[0..SVC_CATEGORIES - 1] Of PChar;
 K: Integer; RoomNumStr: String; RoomNumI: LongInt; ErrCode: Integer;
 Idx, J: Integer; Amt: Real; Qty: LongInt;
Begin
 DlgInit(D, 'Ajouter une charge au folio', 460, 240);
 AddLabel(D, 18, 35, 'Chambre :');
 AddEdit(D, 110, 32, 80, 5);
 For K := 0 To SVC_CATEGORIES - 1 Do Begin
  CatOpts[K] := SvcLabel(K); CatLbl[K] := @CatOpts[K][1];
 End;
 AddLabel(D, 18, 60, 'Categorie :');
 AddCombo(D, 110, 57, 200, CatLbl, SVC_CATEGORIES);
 AddLabel(D, 18, 85, 'Description :');
 AddEdit(D, 110, 82, 320, 47);
 AddLabel(D, 18, 110, 'Montant :');
 AddEdit(D, 110, 107, 100, 10);
 AddLabel(D, 18, 135, 'Quantite :');
 AddEdit(D, 110, 132, 60, 4);
 D.Ctrls[IQty].Text := '1';
 AddButton(D, 250, 180, 90, 'Ajouter', BTN_DEFAULT);
 AddButton(D, 350, 180, 90, 'Annuler', BTN_CANCEL);
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IRoom].Text, RoomNumI, ErrCode);
  If ErrCode <> 0 Then Begin
   ShowMessageBox('Erreur', 'Numero invalide.'); Exit;
  End;
  Idx := -1;
  For J := 0 To MAX_SPOTS - 1 Do
   If (SpotFloor(J) < FloorCount) And
      ((J Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
      (RoomNumber(J) = RoomNumI) Then Begin Idx := J; Break; End;
  If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
  Val(D.Ctrls[IAmt].Text, Amt, ErrCode);
  If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Montant invalide.'); Exit; End;
  Val(D.Ctrls[IQty].Text, Qty, ErrCode);
  If (ErrCode <> 0) Or (Qty < 1) Then Qty := 1;
  If AddCharge(Idx, Spots[Idx].GuestID,
               D.Ctrls[ICat].ListSel,
               D.Ctrls[IDesc].Text, Amt, Qty) < 0 Then
   ShowMessageBox('Erreur', 'Plus de place dans le folio.')
  Else
   ShowMessageBox('Folio',
    'Charge ajoutee a la chambre ' + IntToStr(RoomNumber(Idx)) +
    ' pour ' + RealToStr(Amt * Qty, 0, 2) + '.');
 End;
End;

Procedure DlgFolioRemove;
Var IDStr: String; ID: LongInt; ErrCode: Integer; I, Found: Integer;
Begin
 IDStr := '';
 If Not ShowInputBox('Retirer charge', 'ID de la charge :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 Found := -1;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].ChargeID = ID) Then Begin
   Found := I; Break;
  End;
 If Found < 0 Then Begin ShowMessageBox('Erreur', 'Charge introuvable.'); Exit; End;
 If ShowConfirmBox('Retirer',
    'Retirer ' + Charges[Found].Description + ' (' +
    RealToStr(Charges[Found].Amount, 0, 2) + ') ?') Then Begin
  RemoveCharge(Found);
  ShowMessageBox('Folio', 'Charge retiree.');
 End;
End;

Procedure DlgFolioPrint;
Var RNStr: String; RN, I, Idx, J, Cnt: Integer; ErrCode: Integer;
    Lines: TReportArray; SubTotal, Total: Real;
Begin
 RNStr := '';
 If Not ShowInputBox('Imprimer folio', 'Numero de chambre :', RNStr, 5) Then Exit;
 Val(TrimStr(RNStr), RN, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Numero invalide.'); Exit; End;
 Idx := -1;
 For J := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(J) < FloorCount) And
     ((J Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
     (RoomNumber(J) = RN) Then Begin Idx := J; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
 Cnt := 0;
 Lines[Cnt] := '          FACTURE / FOLIO  -  GLADIR PMS';
 Inc(Cnt);
 Lines[Cnt] := '          ============================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Chambre        : ' + IntToStr(RN) +
               '  (' + RoomTypeLabel(Spots[Idx].RoomType) + ')';
 Inc(Cnt);
 Lines[Cnt] := 'Client         : ' + Spots[Idx].Owner;
 Inc(Cnt);
 Lines[Cnt] := 'Folio          : ' + Spots[Idx].Plate;
 Inc(Cnt);
 Lines[Cnt] := 'Check-in       : ' + FormatDateTime(Spots[Idx].StartDT);
 Inc(Cnt);
 Lines[Cnt] := 'Check-out prevu: ' + FormatDateTime(Spots[Idx].EndDT);
 Inc(Cnt);
 Lines[Cnt] := 'Nb adultes / enf: ' + IntToStr(Spots[Idx].Adults) +
               ' / ' + IntToStr(Spots[Idx].Children);
 Inc(Cnt);
 Lines[Cnt] := 'Source         : ' + ChannelLabel(Spots[Idx].Source);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := '--- DETAIL ---';
 Inc(Cnt);
 Lines[Cnt] := 'Chambre x ' + IntToStr(Spots[Idx].NbNights) +
               ' nuits : ' + RealToStr(Spots[Idx].Paid, 0, 2);
 Inc(Cnt);
 SubTotal := 0;
 For I := 0 To MAX_CHARGES - 1 Do
  If Charges[I].Active And (Charges[I].SpotIdx = Idx) And
     (Cnt < MAX_REPORT_LINES - 8) Then Begin
   Lines[Cnt] := PadRight(SvcLabel(Charges[I].Category) + ' ' +
                          Charges[I].Description, 50) +
                 'x' + IntToStrW(Charges[I].Quantity, 2) + ' ' +
                 PadLeft(RealToStr(Charges[I].Amount * Charges[I].Quantity, 0, 2), 10);
   Inc(Cnt);
   SubTotal := SubTotal + Charges[I].Amount * Charges[I].Quantity;
  End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Total := Spots[Idx].Paid + SubTotal;
 Lines[Cnt] := PadRight('Sous-total services :', 50) +
               PadLeft(RealToStr(SubTotal, 0, 2), 10);
 Inc(Cnt);
 Lines[Cnt] := PadRight('TOTAL :', 50) +
               PadLeft(RealToStr(Total, 0, 2), 10);
 Inc(Cnt);
 Lines[Cnt] := PadRight('Du encore :', 50) +
               PadLeft(RealToStr(TotalSpotChargesUnpaid(Idx), 0, 2), 10);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Merci de votre sejour - Gladir Hotel';
 Inc(Cnt);
 ShowReportDialog('Folio chambre ' + IntToStr(RN), Lines, Cnt);
End;

Procedure DlgFolioPay;
Var RNStr, Ref: String; RN, J, Idx: Integer; ErrCode: Integer;
    Due: Real;
Begin
 RNStr := '';
 If Not ShowInputBox('Encaisser', 'Numero de chambre :', RNStr, 5) Then Exit;
 Val(TrimStr(RNStr), RN, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Numero invalide.'); Exit; End;
 Idx := -1;
 For J := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(J) < FloorCount) And
     ((J Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
     (RoomNumber(J) = RN) Then Begin Idx := J; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
 Due := TotalSpotChargesUnpaid(Idx);
 If Due <= 0 Then Begin
  ShowMessageBox('Encaisser', 'Aucun montant du.'); Exit;
 End;
 Ref := '';
 If Not ShowInputBox('Encaisser',
       'Reference paiement (a payer ' + RealToStr(Due, 0, 2) + ') :',
       Ref, 15) Then Exit;
 MarkSpotChargesPaid(Idx, Ref);
 ShowMessageBox('Encaisser',
  RealToStr(Due, 0, 2) + ' encaisse pour la chambre ' + IntToStr(RN) + '.');
End;

Procedure DlgFolioSummary;
Var Lines: TReportArray; Cnt, C: Integer; T: Real; Grand: Real;
Begin
 Cnt := 0;
 Lines[Cnt] := 'RESUME DES CHARGES PAR CATEGORIE';
 Inc(Cnt);
 Lines[Cnt] := '=================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Categorie', 24) +
               PadLeft('Nombre', 10) + PadLeft('Total $', 14);
 Inc(Cnt);
 Lines[Cnt] := '----------------------------------------------';
 Inc(Cnt);
 Grand := 0;
 For C := 0 To SVC_CATEGORIES - 1 Do Begin
  T := TotalChargesByCategory(C);
  Grand := Grand + T;
  Lines[Cnt] := PadRight(SvcLabel(C), 24) +
                PadLeft(IntToStr(CountChargesByCategory(C)), 10) +
                PadLeft(RealToStr(T, 0, 2), 14);
  Inc(Cnt);
 End;
 Lines[Cnt] := '----------------------------------------------';
 Inc(Cnt);
 Lines[Cnt] := PadRight('TOTAL', 24) +
               PadLeft(IntToStr(ChargeCount), 10) +
               PadLeft(RealToStr(Grand, 0, 2), 14);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Charges du jour (compteur) : ' +
               RealToStr(PMSChargesToday, 0, 2);
 Inc(Cnt);
 ShowReportDialog('Resume folio', Lines, Cnt);
End;


{ ============================================================
  PMS - MODULE 4 : GROUPES / SAISONS / PLANS TARIFAIRES / CHANNELS
  ============================================================ }

Function FindFreeGroupSlot: Integer;
Var I: Integer;
Begin
 FindFreeGroupSlot := -1;
 For I := 0 To MAX_GROUPS - 1 Do
  If Not GroupBookings[I].Active Then Begin FindFreeGroupSlot := I; Exit; End;
End;

Function FindGroupIdxByID(ID: LongInt): Integer;
Var I: Integer;
Begin
 FindGroupIdxByID := -1;
 If ID <= 0 Then Exit;
 For I := 0 To MAX_GROUPS - 1 Do
  If GroupBookings[I].Active And (GroupBookings[I].ID = ID) Then Begin
   FindGroupIdxByID := I; Exit;
  End;
End;

Function AddGroupBooking(Const Name, CName, CPhone, CEmail: String;
                         Arr, Dep: TDateTime;
                         Rooms, Adults, Children: Word;
                         Disc: Real): Integer;
Var Idx: Integer;
Begin
 AddGroupBooking := -1;
 Idx := FindFreeGroupSlot;
 If Idx < 0 Then Exit;
 GroupBookings[Idx].Active := True;
 GroupBookings[Idx].ID := NextGroupID;
 Inc(NextGroupID);
 GroupBookings[Idx].Name := TrimStr(Name);
 GroupBookings[Idx].ContactName := TrimStr(CName);
 GroupBookings[Idx].ContactPhone := TrimStr(CPhone);
 GroupBookings[Idx].ContactEmail := TrimStr(CEmail);
 GroupBookings[Idx].ArrivalDT := Arr;
 GroupBookings[Idx].DepartureDT := Dep;
 GroupBookings[Idx].RoomsBooked := Rooms;
 GroupBookings[Idx].Adults := Adults;
 GroupBookings[Idx].Children := Children;
 GroupBookings[Idx].Discount := Disc;
 GroupBookings[Idx].TotalDue := 0;
 GroupBookings[Idx].Paid := 0;
 GroupBookings[Idx].Notes := '';
 Inc(GroupCount);
 AddGroupBooking := Idx;
End;

Procedure DeleteGroup(Idx: Integer);
Begin
 If (Idx < 0) Or (Idx >= MAX_GROUPS) Then Exit;
 If Not GroupBookings[Idx].Active Then Exit;
 GroupBookings[Idx].Active := False;
 If GroupCount > 0 Then Dec(GroupCount);
End;

Function CountRoomsInGroup(GroupID: LongInt): Integer;
Var I, N: Integer;
Begin
 N := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If Spots[I].GroupID = GroupID Then Inc(N);
 CountRoomsInGroup := N;
End;

Procedure DlgGroupNew;
Const
 IName=0; ICN=1; ICP=2; ICE=3;
 IAY=4; IAM=5; IAD=6;
 IDY=7; IDM=8; IDD=9;
 IRoom=10; IAdt=11; IChi=12; IDisc=13;
 INotes=14; IBOK=15; IBCancel=16;
Var
 D: TDialog;
 V: LongInt; ErrCode: Integer;
 Arr, Dep: TDateTime;
 R, A, C: LongInt;
 Disc: Real;
 NewIdx: Integer;
Begin
 DlgInit(D, 'Nouvelle reservation de groupe', 560, 380);
 AddLabel(D, 18, 35, 'Nom du groupe :');
 AddEdit(D, 160, 32, 360, 47);
 AddLabel(D, 18, 60, 'Contact (nom) :');
 AddEdit(D, 160, 57, 240, 31);
 AddLabel(D, 18, 85, 'Telephone :');
 AddEdit(D, 160, 82, 180, 15);
 AddLabel(D, 18, 110, 'Courriel :');
 AddEdit(D, 160, 107, 320, 47);
 AddLabel(D, 18, 135, 'Arrivee  AAAA/MM/JJ :');
 AddEdit(D, 200, 132, 60, 4);
 AddEdit(D, 265, 132, 40, 2);
 AddEdit(D, 310, 132, 40, 2);
 AddLabel(D, 18, 160, 'Depart   AAAA/MM/JJ :');
 AddEdit(D, 200, 157, 60, 4);
 AddEdit(D, 265, 157, 40, 2);
 AddEdit(D, 310, 157, 40, 2);
 AddLabel(D, 18, 185, 'Nb chambres / adultes / enfants :');
 AddEdit(D, 240, 182, 60, 4);
 AddEdit(D, 305, 182, 60, 4);
 AddEdit(D, 370, 182, 60, 4);
 AddLabel(D, 18, 210, 'Remise (%) :');
 AddEdit(D, 160, 207, 60, 5);
 AddLabel(D, 18, 235, 'Notes :');
 AddEdit(D, 160, 232, 380, 63);
 AddButton(D, 350, 320, 90, 'OK', BTN_DEFAULT);
 AddButton(D, 450, 320, 90, 'Annuler', BTN_CANCEL);
 GetCurrentDT(Arr);
 D.Ctrls[IAY].Text := IntToStr(Arr.Year);
 D.Ctrls[IAM].Text := IntToStr(Arr.Month);
 D.Ctrls[IAD].Text := IntToStr(Arr.Day);
 D.Ctrls[IDY].Text := IntToStr(Arr.Year);
 D.Ctrls[IDM].Text := IntToStr(Arr.Month);
 D.Ctrls[IDD].Text := IntToStr(Arr.Day + 1);
 D.Ctrls[IRoom].Text := '5';
 D.Ctrls[IAdt].Text  := '10';
 D.Ctrls[IChi].Text  := '0';
 D.Ctrls[IDisc].Text := '10';
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IAY].Text, V, ErrCode); Arr.Year := V;
  Val(D.Ctrls[IAM].Text, V, ErrCode); Arr.Month := V;
  Val(D.Ctrls[IAD].Text, V, ErrCode); Arr.Day := V;
  Arr.Hour := 14; Arr.Min := 0;
  Val(D.Ctrls[IDY].Text, V, ErrCode); Dep.Year := V;
  Val(D.Ctrls[IDM].Text, V, ErrCode); Dep.Month := V;
  Val(D.Ctrls[IDD].Text, V, ErrCode); Dep.Day := V;
  Dep.Hour := 12; Dep.Min := 0;
  Val(D.Ctrls[IRoom].Text, R, ErrCode); If ErrCode <> 0 Then R := 1;
  Val(D.Ctrls[IAdt].Text, A, ErrCode);  If ErrCode <> 0 Then A := 1;
  Val(D.Ctrls[IChi].Text, C, ErrCode);  If ErrCode <> 0 Then C := 0;
  Val(D.Ctrls[IDisc].Text, Disc, ErrCode); If ErrCode <> 0 Then Disc := 0;
  NewIdx := AddGroupBooking(D.Ctrls[IName].Text,
                            D.Ctrls[ICN].Text,
                            D.Ctrls[ICP].Text,
                            D.Ctrls[ICE].Text,
                            Arr, Dep, R, A, C, Disc);
  If NewIdx < 0 Then
   ShowMessageBox('Erreur', 'Plus de place pour groupes.')
  Else Begin
   GroupBookings[NewIdx].Notes := D.Ctrls[INotes].Text;
   ShowMessageBox('Groupes',
    'Groupe cree (ID ' + IntToStr(GroupBookings[NewIdx].ID) + ').');
  End;
 End;
End;

Procedure DlgGroupList;
Const IL=0; IBClose=1; IBDetails=2; IBDelete=3;
Var D: TDialog; I, Cnt, Sel: Integer;
    Items: Array[0..MAX_GROUPS - 1] Of String[78];
    ItemsP: Array[0..MAX_GROUPS - 1] Of PChar;
Begin
 Cnt := 0;
 For I := 0 To MAX_GROUPS - 1 Do
  If GroupBookings[I].Active Then Begin
   Items[Cnt] := IntToStrW(GroupBookings[I].ID, 5) + ' ' +
                 PadRight(GroupBookings[I].Name, 28) +
                 PadLeft(IntToStr(GroupBookings[I].RoomsBooked), 4) + 'ch ' +
                 FormatDateTime(GroupBookings[I].ArrivalDT);
   ItemsP[Cnt] := @Items[Cnt][1];
   Inc(Cnt);
  End;
 If Cnt = 0 Then Begin
  ShowMessageBox('Groupes', 'Aucun groupe reserve.'); Exit;
 End;
 DlgInit(D, 'Liste des groupes (' + IntToStr(Cnt) + ')', 580, 360);
 AddListbox(D, 12, 30, 556, 260, ItemsP, Cnt);
 AddButton(D, 300, 300, 90, 'Fermer', BTN_DEFAULT);
 AddButton(D, 400, 300, 90, 'Details', BTN_NORMAL);
 AddButton(D, 500, 300, 80, 'Suppr', BTN_NORMAL);
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[IL].ListSel;
  If Sel >= 0 Then Begin
   Cnt := 0;
   For I := 0 To MAX_GROUPS - 1 Do
    If GroupBookings[I].Active Then Begin
     If Cnt = Sel Then Begin
      If ShowConfirmBox('Supprimer',
         'Supprimer le groupe ' + GroupBookings[I].Name + ' ?') Then
       DeleteGroup(I);
      Exit;
     End;
     Inc(Cnt);
    End;
  End;
 End;
End;

Procedure DlgGroupAssign;
Var IDStr: String; ID: LongInt; ErrCode: Integer;
    IdxG, I, F, C, R, Idx, Assigned, Need: Integer;
    G: TGroupBooking;
Begin
 IDStr := '';
 If Not ShowInputBox('Assigner groupe',
       'ID du groupe :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 IdxG := FindGroupIdxByID(ID);
 If IdxG < 0 Then Begin ShowMessageBox('Erreur', 'Groupe introuvable.'); Exit; End;
 G := GroupBookings[IdxG];
 Need := G.RoomsBooked - CountRoomsInGroup(G.ID);
 If Need <= 0 Then Begin
  ShowMessageBox('Groupes', 'Toutes les chambres deja assignees.'); Exit;
 End;
 Assigned := 0;
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    Idx := SpotIdxAt(F, C, R);
    If (Spots[Idx].State = ssFree) And
       (Spots[Idx].HKState <> HK_OOO) And
       (Spots[Idx].HKState <> HK_OOS) And
       (Spots[Idx].GroupID = 0) And
       (Assigned < Need) Then Begin
     Spots[Idx].GroupID := G.ID;
     Spots[Idx].Source := CH_GROUP;
     Inc(Assigned);
    End;
   End;
 ShowMessageBox('Groupes',
  IntToStr(Assigned) + ' chambre(s) assignee(s) au groupe ' + G.Name + '.');
End;

Procedure DlgGroupCheckin;
Var IDStr: String; ID: LongInt; ErrCode: Integer;
    IdxG, I, Cnt: Integer; G: TGroupBooking;
Begin
 IDStr := '';
 If Not ShowInputBox('Check-in groupe',
       'ID du groupe :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 IdxG := FindGroupIdxByID(ID);
 If IdxG < 0 Then Begin ShowMessageBox('Erreur', 'Groupe introuvable.'); Exit; End;
 G := GroupBookings[IdxG];
 Cnt := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (Spots[I].GroupID = G.ID) And (Spots[I].State = ssFree) Then Begin
   Spots[I].State := ssOccupied;
   Spots[I].Plate := 'GR' + IntToStr(G.ID) + '-' + IntToStr(I);
   Spots[I].Owner := G.ContactName;
   Spots[I].Phone := G.ContactPhone;
   Spots[I].StartDT := G.ArrivalDT;
   Spots[I].EndDT := G.DepartureDT;
   Spots[I].DurCode := DUR_24H;
   Spots[I].Paid := 0;
   Spots[I].ResStatus := RES_CHECKED_IN;
   Spots[I].Source := CH_GROUP;
   Spots[I].HKState := HK_INPROGRESS;
   Inc(Cnt);
   Inc(PMSCheckinsToday);
  End;
 ShowMessageBox('Groupes',
  IntToStr(Cnt) + ' chambre(s) enregistree(s).');
End;

Procedure DlgGroupReport;
Var Lines: TReportArray; Cnt, I: Integer;
    G: TGroupBooking; TotRooms, TotAdults, TotChildren: LongInt;
Begin
 Cnt := 0;
 Lines[Cnt] := 'RAPPORT DES GROUPES';
 Inc(Cnt);
 Lines[Cnt] := '===================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 TotRooms := 0; TotAdults := 0; TotChildren := 0;
 For I := 0 To MAX_GROUPS - 1 Do
  If GroupBookings[I].Active And (Cnt < MAX_REPORT_LINES - 8) Then Begin
   G := GroupBookings[I];
   Lines[Cnt] := 'Groupe ' + IntToStr(G.ID) + ' : ' + G.Name;
   Inc(Cnt);
   Lines[Cnt] := '  Contact : ' + G.ContactName + ' (' + G.ContactPhone + ')';
   Inc(Cnt);
   Lines[Cnt] := '  Du ' + FormatDateTime(G.ArrivalDT) +
                 ' au ' + FormatDateTime(G.DepartureDT);
   Inc(Cnt);
   Lines[Cnt] := '  Chambres : ' + IntToStr(G.RoomsBooked) +
                 '  Assignees : ' + IntToStr(CountRoomsInGroup(G.ID)) +
                 '  Pax : ' + IntToStr(G.Adults) + 'A/' +
                 IntToStr(G.Children) + 'E  Remise: ' +
                 RealToStr(G.Discount, 0, 1) + '%';
   Inc(Cnt);
   Lines[Cnt] := '';
   Inc(Cnt);
   TotRooms := TotRooms + G.RoomsBooked;
   TotAdults := TotAdults + G.Adults;
   TotChildren := TotChildren + G.Children;
  End;
 Lines[Cnt] := '---------------------------------------------';
 Inc(Cnt);
 Lines[Cnt] := 'Total chambres : ' + IntToStr(TotRooms) +
               '   Adultes : ' + IntToStr(TotAdults) +
               '   Enfants : ' + IntToStr(TotChildren);
 Inc(Cnt);
 ShowReportDialog('Rapport groupes', Lines, Cnt);
End;

Procedure DlgGroupEdit;
Begin
 ShowMessageBox('Groupes',
  'Edition d un groupe : utilisez "Supprimer" puis "Nouveau".');
End;

{ ----- Saisons ----- }

Procedure DlgSeasonConfig;
Const
 ISel=0; INam=1; ISM=2; ISD=3; IEM=4; IED=5; IMul=6;
 IBSave=7; IBClose=8; ICEna=9;
Var D: TDialog;
    LblA: Array[0..SEASON_CNT - 1] Of String[20];
    LblP: Array[0..SEASON_CNT - 1] Of PChar;
    K: Integer; Sel: Integer; V: LongInt; ErrCode: Integer; M: Real;
Begin
 For K := 0 To SEASON_CNT - 1 Do Begin
  LblA[K] := Seasons[K].Label_;
  LblP[K] := @LblA[K][1];
 End;
 DlgInit(D, 'Configurer les saisons', 460, 280);
 AddLabel(D, 18, 35, 'Saison :');
 AddCombo(D, 110, 32, 220, LblP, SEASON_CNT);
 AddLabel(D, 18, 60, 'Nom :');
 AddEdit(D, 110, 57, 220, 20);
 AddLabel(D, 18, 85, 'Debut MM/JJ :');
 AddEdit(D, 130, 82, 40, 2);
 AddEdit(D, 175, 82, 40, 2);
 AddLabel(D, 18, 110, 'Fin MM/JJ :');
 AddEdit(D, 130, 107, 40, 2);
 AddEdit(D, 175, 107, 40, 2);
 AddLabel(D, 18, 135, 'Multiplicateur :');
 AddEdit(D, 130, 132, 60, 6);
 AddCheck(D, 18, 160, 'Active', True);
 AddButton(D, 220, 220, 100, 'Enregistrer', BTN_DEFAULT);
 AddButton(D, 330, 220, 100, 'Fermer', BTN_CANCEL);
 D.Ctrls[ISel].ListSel := 0;
 Sel := 0;
 D.Ctrls[INam].Text := Seasons[Sel].Label_;
 D.Ctrls[ISM].Text := IntToStr(Seasons[Sel].StartMonth);
 D.Ctrls[ISD].Text := IntToStr(Seasons[Sel].StartDay);
 D.Ctrls[IEM].Text := IntToStr(Seasons[Sel].EndMonth);
 D.Ctrls[IED].Text := IntToStr(Seasons[Sel].EndDay);
 D.Ctrls[IMul].Text := RealToStr(Seasons[Sel].Multiplier, 0, 2);
 D.Ctrls[ICEna].Checked := Seasons[Sel].Enabled;
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[ISel].ListSel;
  If Sel < 0 Then Sel := 0;
  Seasons[Sel].Label_ := D.Ctrls[INam].Text;
  Val(D.Ctrls[ISM].Text, V, ErrCode); Seasons[Sel].StartMonth := V;
  Val(D.Ctrls[ISD].Text, V, ErrCode); Seasons[Sel].StartDay := V;
  Val(D.Ctrls[IEM].Text, V, ErrCode); Seasons[Sel].EndMonth := V;
  Val(D.Ctrls[IED].Text, V, ErrCode); Seasons[Sel].EndDay := V;
  Val(D.Ctrls[IMul].Text, M, ErrCode); If ErrCode = 0 Then Seasons[Sel].Multiplier := M;
  Seasons[Sel].Enabled := D.Ctrls[ICEna].Checked;
  ShowMessageBox('Saisons', 'Saison enregistree.');
 End;
End;

Procedure DlgSeasonCalendar;
Var Lines: TReportArray; Cnt: Integer; M, D: Byte; DT: TDateTime; S: Byte;
Begin
 Cnt := 0;
 Lines[Cnt] := 'CALENDRIER DES SAISONS (jour median par mois)';
 Inc(Cnt);
 Lines[Cnt] := '=============================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 DT.Year := NowDT.Year; DT.Hour := 0; DT.Min := 0;
 For M := 1 To 12 Do Begin
  D := 15;
  DT.Month := M; DT.Day := D;
  S := SeasonForDate(DT);
  Lines[Cnt] := 'Mois ' + IntToStrW(M, 2) + ' jour ' + IntToStr(D) +
                ' -> ' + PadRight(Seasons[S].Label_, 16) +
                ' (x' + RealToStr(Seasons[S].Multiplier, 0, 2) + ')';
  Inc(Cnt);
 End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Saison detectee aujourd hui : ' +
               Seasons[SeasonForDate(NowDT)].Label_;
 Inc(Cnt);
 ShowReportDialog('Calendrier saisons', Lines, Cnt);
End;

Procedure DlgSeasonRates;
Var Lines: TReportArray; Cnt, T: Integer; S: Byte; Base, Adj: Real;
Begin
 Cnt := 0;
 Lines[Cnt] := 'TARIFS PAR TYPE x SAISON';
 Inc(Cnt);
 Lines[Cnt] := '========================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Type', 14) +
               PadRight('Base', 10) +
               PadRight('Basse', 10) + PadRight('Mid', 10) +
               PadRight('Haute', 10) + PadRight('Pointe', 10);
 Inc(Cnt);
 Lines[Cnt] := '-----------------------------------------------------------';
 Inc(Cnt);
 For T := 0 To RT_TYPES - 1 Do Begin
  Base := RoomTypes[T].BaseRate;
  Lines[Cnt] := PadRight(RoomTypes[T].Label_, 14) +
                PadRight(RealToStr(Base, 0, 2), 10);
  For S := 0 To SEASON_CNT - 1 Do Begin
   Adj := Base * Seasons[S].Multiplier;
   Lines[Cnt] := Lines[Cnt] + PadRight(RealToStr(Adj, 0, 2), 10);
  End;
  Inc(Cnt);
 End;
 ShowReportDialog('Tarifs x saisons', Lines, Cnt);
End;

{ ----- Plans tarifaires ----- }

Procedure DlgRatePlanList;
Var Lines: TReportArray; Cnt, I: Integer; R: TRatePlan;
Begin
 Cnt := 0;
 Lines[Cnt] := 'PLANS TARIFAIRES';
 Inc(Cnt);
 Lines[Cnt] := '================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For I := 0 To MAX_RATEPLANS - 1 Do
  If RatePlans[I].Active And (Cnt < MAX_REPORT_LINES - 5) Then Begin
   R := RatePlans[I];
   Lines[Cnt] := 'ID ' + IntToStrW(R.ID, 5) + ' ' + R.Name +
                 ' (' + RealToStr(R.Discount, 0, 1) + '% off)';
   Inc(Cnt);
   Lines[Cnt] := '  ' + R.Description;
   Inc(Cnt);
   Lines[Cnt] := '  Inclus : ';
   If R.IncludeBreakfast Then Lines[Cnt] := Lines[Cnt] + 'Pdej ';
   If R.IncludeDinner    Then Lines[Cnt] := Lines[Cnt] + 'Diner ';
   If R.IncludeParking   Then Lines[Cnt] := Lines[Cnt] + 'Hotel ';
   Lines[Cnt] := Lines[Cnt] + ' / Min nuits : ' + IntToStr(R.MinNights) +
                 ' / Annul : ' + R.CancelPolicy;
   Inc(Cnt);
   Lines[Cnt] := '';
   Inc(Cnt);
  End;
 ShowReportDialog('Plans tarifaires', Lines, Cnt);
End;

Procedure DlgRatePlanNew;
Const INam=0; IDesc=1; IDisc=2; IMin=3;
      ICBkf=4; ICDin=5; ICPark=6;
      IPol=7; IBOK=8; IBC=9;
Var D: TDialog; Idx: Integer; Disc: Real; Min: LongInt; ErrCode: Integer;
Begin
 If RatePlanCount >= MAX_RATEPLANS Then Begin
  ShowMessageBox('Erreur', 'Plus de place pour plans tarifaires.'); Exit;
 End;
 DlgInit(D, 'Nouveau plan tarifaire', 460, 320);
 AddLabel(D, 18, 35, 'Nom :');
 AddEdit(D, 110, 32, 240, 20);
 AddLabel(D, 18, 60, 'Description :');
 AddEdit(D, 110, 57, 320, 47);
 AddLabel(D, 18, 85, 'Remise (%) :');
 AddEdit(D, 110, 82, 80, 5);
 AddLabel(D, 18, 110, 'Min nuits :');
 AddEdit(D, 110, 107, 80, 3);
 AddCheck(D, 18, 135, 'Petit dejeuner inclus', False);
 AddCheck(D, 18, 155, 'Diner inclus', False);
 AddCheck(D, 18, 175, 'Hotel inclus', False);
 AddLabel(D, 18, 200, 'Annulation :');
 AddEdit(D, 110, 197, 320, 31);
 AddButton(D, 250, 260, 90, 'OK', BTN_DEFAULT);
 AddButton(D, 350, 260, 90, 'Annuler', BTN_CANCEL);
 D.Ctrls[IDisc].Text := '0';
 D.Ctrls[IMin].Text := '1';
 D.Ctrls[IPol].Text := 'Annulation 24h avant';
 If DlgRun(D) = 1 Then Begin
  Idx := -1;
  Idx := RatePlanCount;
  RatePlans[Idx].Active := True;
  RatePlans[Idx].ID := NextRatePlanID; Inc(NextRatePlanID);
  RatePlans[Idx].Name := D.Ctrls[INam].Text;
  RatePlans[Idx].Description := D.Ctrls[IDesc].Text;
  Val(D.Ctrls[IDisc].Text, Disc, ErrCode);
  RatePlans[Idx].Discount := Disc;
  Val(D.Ctrls[IMin].Text, Min, ErrCode);
  If Min < 1 Then Min := 1;
  RatePlans[Idx].MinNights := Min;
  RatePlans[Idx].IncludeBreakfast := D.Ctrls[ICBkf].Checked;
  RatePlans[Idx].IncludeDinner := D.Ctrls[ICDin].Checked;
  RatePlans[Idx].IncludeParking := D.Ctrls[ICPark].Checked;
  RatePlans[Idx].CancelPolicy := D.Ctrls[IPol].Text;
  Inc(RatePlanCount);
  ShowMessageBox('Plans', 'Plan tarifaire cree.');
 End;
End;

{ ----- Channels ----- }

Procedure DlgChList;
Var Lines: TReportArray; Cnt: Integer; I: Byte;
Begin
 Cnt := 0;
 Lines[Cnt] := 'CANAUX DE RESERVATION';
 Inc(Cnt);
 Lines[Cnt] := '=====================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Code', 6) + PadRight('Libelle', 24) +
               PadLeft('Comm.%', 10) + '   Etat';
 Inc(Cnt);
 Lines[Cnt] := '------------------------------------------------';
 Inc(Cnt);
 For I := 0 To CH_COUNT - 1 Do Begin
  Lines[Cnt] := PadRight(IntToStr(I), 6) +
                PadRight(Channels[I].Label_, 24) +
                PadLeft(RealToStr(Channels[I].Commission, 0, 1), 10) +
                '   ';
  If Channels[I].Enabled Then
   Lines[Cnt] := Lines[Cnt] + 'Actif'
  Else
   Lines[Cnt] := Lines[Cnt] + 'Inactif';
  Inc(Cnt);
 End;
 ShowReportDialog('Canaux de reservation', Lines, Cnt);
End;

Procedure DlgChReport;
Var Lines: TReportArray; Cnt: Integer; I: Byte;
    Cnts: Array[0..CH_COUNT - 1] Of LongInt;
    Sums: Array[0..CH_COUNT - 1] Of Real;
    S, T: Integer; C: Byte; TotalCnt: LongInt; TotalRev: Real;
Begin
 For I := 0 To CH_COUNT - 1 Do Begin Cnts[I] := 0; Sums[I] := 0; End;
 For S := 0 To MAX_SPOTS - 1 Do
  If Spots[S].State = ssOccupied Then Begin
   C := Spots[S].Source;
   If C < CH_COUNT Then Begin
    Inc(Cnts[C]);
    Sums[C] := Sums[C] + Spots[S].Paid;
   End;
  End;
 Cnt := 0;
 Lines[Cnt] := 'CHIFFRE D AFFAIRE PAR CANAL';
 Inc(Cnt);
 Lines[Cnt] := '===========================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Canal', 22) +
               PadLeft('Nb res.', 10) +
               PadLeft('CA brut', 12) +
               PadLeft('Commiss.', 12) +
               PadLeft('CA net', 12);
 Inc(Cnt);
 Lines[Cnt] := '-----------------------------------------------------------------';
 Inc(Cnt);
 TotalCnt := 0; TotalRev := 0;
 For I := 0 To CH_COUNT - 1 Do Begin
  Lines[Cnt] := PadRight(Channels[I].Label_, 22) +
                PadLeft(IntToStr(Cnts[I]), 10) +
                PadLeft(RealToStr(Sums[I], 0, 2), 12) +
                PadLeft(RealToStr(ComputeChannelCommission(I, Sums[I]), 0, 2), 12) +
                PadLeft(RealToStr(Sums[I] - ComputeChannelCommission(I, Sums[I]), 0, 2), 12);
  Inc(Cnt);
  TotalCnt := TotalCnt + Cnts[I];
  TotalRev := TotalRev + Sums[I];
 End;
 Lines[Cnt] := '-----------------------------------------------------------------';
 Inc(Cnt);
 Lines[Cnt] := PadRight('TOTAL', 22) +
               PadLeft(IntToStr(TotalCnt), 10) +
               PadLeft(RealToStr(TotalRev, 0, 2), 12);
 Inc(Cnt);
 ShowReportDialog('Rapport canaux', Lines, Cnt);
End;

Procedure DlgChCommission;
Const ISel=0; IComm=1; ICEna=2; IBSave=3; IBC=4;
Var D: TDialog;
    LblA: Array[0..CH_COUNT - 1] Of String[24];
    LblP: Array[0..CH_COUNT - 1] Of PChar;
    K: Integer; Sel: Integer; V: Real; ErrCode: Integer;
Begin
 For K := 0 To CH_COUNT - 1 Do Begin
  LblA[K] := Channels[K].Label_; LblP[K] := @LblA[K][1];
 End;
 DlgInit(D, 'Commissions canaux', 440, 220);
 AddLabel(D, 18, 35, 'Canal :');
 AddCombo(D, 110, 32, 240, LblP, CH_COUNT);
 AddLabel(D, 18, 60, 'Commission % :');
 AddEdit(D, 140, 57, 80, 6);
 AddCheck(D, 18, 85, 'Active', True);
 AddButton(D, 230, 160, 90, 'Enregistrer', BTN_DEFAULT);
 AddButton(D, 330, 160, 90, 'Fermer', BTN_CANCEL);
 D.Ctrls[ISel].ListSel := 0;
 D.Ctrls[IComm].Text := RealToStr(Channels[0].Commission, 0, 1);
 D.Ctrls[ICEna].Checked := Channels[0].Enabled;
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[ISel].ListSel;
  If Sel < 0 Then Sel := 0;
  Val(D.Ctrls[IComm].Text, V, ErrCode);
  If ErrCode = 0 Then Channels[Sel].Commission := V;
  Channels[Sel].Enabled := D.Ctrls[ICEna].Checked;
  ShowMessageBox('Canaux', 'Canal mis a jour.');
 End;
End;


{ ============================================================
  PMS - MODULE 5 : HOUSEKEEPING / MAINTENANCE / FLOORS / CHECK-IN/OUT
  ============================================================ }

{ ----- Housekeeping ----- }

Procedure DlgHKList;
Var Lines: TReportArray; Cnt: Integer;
    F, R, C, I: Integer;
Begin
 Cnt := 0;
 Lines[Cnt] := 'ETAT MENAGE / HOUSEKEEPING (par etage)';
 Inc(Cnt);
 Lines[Cnt] := '======================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For F := 0 To FloorCount - 1 Do
  If Cnt < MAX_REPORT_LINES - RowCount - 4 Then Begin
   Lines[Cnt] := '* ' + Floors[F].Name + ' (' +
                 IntToStr(F) + ') :';
   Inc(Cnt);
   For R := 0 To RowCount - 1 Do Begin
    Lines[Cnt] := '   ';
    For C := 0 To ColCount - 1 Do Begin
     I := SpotIdxAt(F, C, R);
     Lines[Cnt] := Lines[Cnt] + ' ' + HKStateShort(Spots[I].HKState);
    End;
    Inc(Cnt);
   End;
   Lines[Cnt] := '';
   Inc(Cnt);
  End;
 Lines[Cnt] := 'Legende : CLN=propre DRT=sale INS=inspectee';
 Inc(Cnt);
 Lines[Cnt] := '          OOO=hors service OOS=hors usage PRG=en cours';
 Inc(Cnt);
 ShowReportDialog('Etat menage', Lines, Cnt);
End;

Procedure DlgHKSetState;
Const IRoom=0; IState=1; IBOK=2; IBC=3;
Var D: TDialog;
    StateOpts: Array[0..HK_STATES - 1] Of String[24];
    StateLbl: Array[0..HK_STATES - 1] Of PChar;
    K, Sel, RN, J, Idx: Integer; RNStr: String; ErrCode: Integer;
Begin
 For K := 0 To HK_STATES - 1 Do Begin
  StateOpts[K] := HKStateLabel(K); StateLbl[K] := @StateOpts[K][1];
 End;
 DlgInit(D, 'Changer etat menage', 440, 200);
 AddLabel(D, 18, 35, 'Chambre :');
 AddEdit(D, 110, 32, 80, 5);
 AddLabel(D, 18, 60, 'Nouvel etat :');
 AddCombo(D, 130, 57, 240, StateLbl, HK_STATES);
 AddButton(D, 230, 140, 90, 'OK', BTN_DEFAULT);
 AddButton(D, 330, 140, 90, 'Annuler', BTN_CANCEL);
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IRoom].Text, RN, ErrCode);
  If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Numero invalide.'); Exit; End;
  Idx := -1;
  For J := 0 To MAX_SPOTS - 1 Do
   If (SpotFloor(J) < FloorCount) And
      ((J Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
      (RoomNumber(J) = RN) Then Begin Idx := J; Break; End;
  If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
  Sel := D.Ctrls[IState].ListSel;
  If Sel < 0 Then Sel := HK_CLEAN;
  Spots[Idx].HKState := Sel;
  ShowMessageBox('Menage',
   'Chambre ' + IntToStr(RN) + ' -> ' + HKStateLabel(Sel));
 End;
End;

Procedure DlgHKInspect;
Var RNStr: String; RN, J, Idx: Integer; ErrCode: Integer;
Begin
 RNStr := '';
 If Not ShowInputBox('Inspecter', 'Numero de chambre :', RNStr, 5) Then Exit;
 Val(TrimStr(RNStr), RN, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Invalide.'); Exit; End;
 Idx := -1;
 For J := 0 To MAX_SPOTS - 1 Do
  If RoomNumber(J) = RN Then Begin Idx := J; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
 Spots[Idx].HKState := HK_INSPECTED;
 ShowMessageBox('Menage',
  'Chambre ' + IntToStr(RN) + ' marquee INSPECTEE (prete VIP).');
End;

Procedure DlgHKOOO;
Var RNStr, Reason: String; RN, J, Idx: Integer; ErrCode: Integer;
Begin
 RNStr := '';
 If Not ShowInputBox('Hors service', 'Numero de chambre :',
                     RNStr, 5) Then Exit;
 Val(TrimStr(RNStr), RN, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Invalide.'); Exit; End;
 Idx := -1;
 For J := 0 To MAX_SPOTS - 1 Do
  If RoomNumber(J) = RN Then Begin Idx := J; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
 If Spots[Idx].State = ssOccupied Then Begin
  ShowMessageBox('Erreur', 'Chambre occupee, impossible.'); Exit;
 End;
 Reason := '';
 If Not ShowInputBox('Hors service', 'Raison (notes) :',
                     Reason, 63) Then Exit;
 Spots[Idx].HKState := HK_OOO;
 Spots[Idx].Notes := Reason;
 ShowMessageBox('Menage',
  'Chambre ' + IntToStr(RN) + ' marquee HORS SERVICE.');
End;

Procedure DlgHKReport;
Var Lines: TReportArray; Cnt: Integer; S: Byte;
Begin
 Cnt := 0;
 Lines[Cnt] := 'STATISTIQUES MENAGE';
 Inc(Cnt);
 Lines[Cnt] := '===================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For S := 0 To HK_STATES - 1 Do Begin
  Lines[Cnt] := PadRight(HKStateLabel(S), 24) +
                PadLeft(IntToStr(CountHKState(S)), 6) + ' chambres';
  Inc(Cnt);
 End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Total etages actifs : ' + IntToStr(FloorCount);
 Inc(Cnt);
 Lines[Cnt] := 'Total chambres     : ' + IntToStr(SpotCount);
 Inc(Cnt);
 ShowReportDialog('Rapport menage', Lines, Cnt);
End;

Procedure DlgHKAutoClean;
Var I, N: Integer;
Begin
 If Not ShowConfirmBox('Auto-clean',
    'Marquer toutes les chambres LIBRES comme PROPRES ?') Then Exit;
 N := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     ((I Mod MAX_ROOMS_PER_FLOOR) < RoomsPerFloor) And
     (Spots[I].State = ssFree) And
     (Spots[I].HKState <> HK_OOO) And
     (Spots[I].HKState <> HK_OOS) Then Begin
   Spots[I].HKState := HK_CLEAN;
   Inc(N);
  End;
 ShowMessageBox('Menage', IntToStr(N) + ' chambres marquees propres.');
End;

Procedure DlgHKAssign;
Var Lines: TReportArray; Cnt: Integer; F, R, C, I, Cleaners: Integer;
    RoomsToClean: Integer; Per: Integer; ThisCount: Integer;
    Assignee: Integer;
Begin
 Cleaners := 3;
 RoomsToClean := CountHKState(HK_DIRTY) + CountHKState(HK_INPROGRESS);
 If RoomsToClean = 0 Then Begin
  ShowMessageBox('Menage', 'Aucune chambre a nettoyer.'); Exit;
 End;
 Per := (RoomsToClean + Cleaners - 1) Div Cleaners;
 Cnt := 0;
 Lines[Cnt] := 'AFFECTATION MENAGE (' + IntToStr(Cleaners) + ' equipes)';
 Inc(Cnt);
 Lines[Cnt] := '==========================';
 Inc(Cnt);
 Lines[Cnt] := IntToStr(RoomsToClean) + ' chambre(s) a nettoyer, ' +
               IntToStr(Per) + ' par equipe.';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 ThisCount := 0; Assignee := 1;
 Lines[Cnt] := 'Equipe ' + IntToStr(Assignee) + ' :';
 Inc(Cnt);
 For F := 0 To FloorCount - 1 Do
  For R := 0 To RowCount - 1 Do
   For C := 0 To ColCount - 1 Do Begin
    I := SpotIdxAt(F, C, R);
    If (Spots[I].HKState = HK_DIRTY) Or
       (Spots[I].HKState = HK_INPROGRESS) Then Begin
     If ThisCount >= Per Then Begin
      Inc(Assignee);
      If Cnt < MAX_REPORT_LINES - 4 Then Begin
       Lines[Cnt] := '';
       Inc(Cnt);
       Lines[Cnt] := 'Equipe ' + IntToStr(Assignee) + ' :';
       Inc(Cnt);
      End;
      ThisCount := 0;
     End;
     If Cnt < MAX_REPORT_LINES - 2 Then Begin
      Lines[Cnt] := '   Chambre ' + IntToStr(RoomNumber(I)) +
                    ' (' + Floors[F].Name + ') ' +
                    HKStateLabel(Spots[I].HKState);
      Inc(Cnt);
     End;
     Inc(ThisCount);
    End;
   End;
 ShowReportDialog('Affectation menage', Lines, Cnt);
End;

{ ----- Maintenance ----- }

Function FindFreeMaintSlot: Integer;
Var I: Integer;
Begin
 FindFreeMaintSlot := -1;
 For I := 0 To MAX_MAINTENANCE - 1 Do
  If Not MaintTickets[I].Active Then Begin FindFreeMaintSlot := I; Exit; End;
End;

Function AddMaintTicket(SpotIdxV: Integer; Pri: Byte;
                        Const Desc, Rep, Asg: String): Integer;
Var Idx: Integer;
Begin
 AddMaintTicket := -1;
 Idx := FindFreeMaintSlot;
 If Idx < 0 Then Exit;
 MaintTickets[Idx].Active := True;
 MaintTickets[Idx].ID := NextMaintID;
 Inc(NextMaintID);
 MaintTickets[Idx].SpotIdx := SpotIdxV;
 MaintTickets[Idx].Priority := Pri;
 MaintTickets[Idx].Description := Desc;
 MaintTickets[Idx].ReportedBy := Rep;
 MaintTickets[Idx].AssignedTo := Asg;
 GetCurrentDT(MaintTickets[Idx].OpenedDT);
 MaintTickets[Idx].Closed := False;
 MaintTickets[Idx].Cost := 0;
 Inc(MaintCount);
 AddMaintTicket := Idx;
End;

Procedure CloseMaintTicket(Idx: Integer; Cost: Real);
Begin
 If (Idx < 0) Or (Idx >= MAX_MAINTENANCE) Then Exit;
 If Not MaintTickets[Idx].Active Then Exit;
 MaintTickets[Idx].Closed := True;
 GetCurrentDT(MaintTickets[Idx].ClosedDT);
 MaintTickets[Idx].Cost := Cost;
End;

Procedure DlgMaintNew;
Const IRoom=0; IPri=1; IDesc=2; IRep=3; IAsg=4; IBOK=5; IBC=6;
Var D: TDialog;
    PriOpts: Array[0..3] Of String[12];
    PriLbl: Array[0..3] Of PChar;
    K, RN, J, Idx, Pri: Integer; ErrCode: Integer;
Begin
 PriOpts[0] := 'Basse'; PriOpts[1] := 'Normale';
 PriOpts[2] := 'Haute'; PriOpts[3] := 'Urgente';
 For K := 0 To 3 Do PriLbl[K] := @PriOpts[K][1];
 DlgInit(D, 'Nouveau ticket maintenance', 480, 280);
 AddLabel(D, 18, 35, 'Chambre :');
 AddEdit(D, 110, 32, 80, 5);
 AddLabel(D, 18, 60, 'Priorite :');
 AddCombo(D, 110, 57, 120, PriLbl, 4);
 AddLabel(D, 18, 85, 'Description :');
 AddEdit(D, 110, 82, 340, 63);
 AddLabel(D, 18, 110, 'Signale par :');
 AddEdit(D, 110, 107, 240, 31);
 AddLabel(D, 18, 135, 'Assigne a :');
 AddEdit(D, 110, 132, 240, 31);
 AddButton(D, 250, 220, 90, 'Creer', BTN_DEFAULT);
 AddButton(D, 350, 220, 90, 'Annuler', BTN_CANCEL);
 D.Ctrls[IPri].ListSel := 1;
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IRoom].Text, RN, ErrCode);
  Idx := -1;
  If ErrCode = 0 Then
   For J := 0 To MAX_SPOTS - 1 Do
    If RoomNumber(J) = RN Then Begin Idx := J; Break; End;
  Pri := D.Ctrls[IPri].ListSel;
  If Pri < 0 Then Pri := 1;
  If AddMaintTicket(Idx, Pri, D.Ctrls[IDesc].Text,
                    D.Ctrls[IRep].Text, D.Ctrls[IAsg].Text) < 0 Then
   ShowMessageBox('Erreur', 'Plus de place pour tickets.')
  Else Begin
   If (Idx >= 0) And (Pri >= 2) Then Spots[Idx].HKState := HK_OOO;
   ShowMessageBox('Maintenance', 'Ticket cree.');
  End;
 End;
End;

Procedure DlgMaintList;
Var Lines: TReportArray; Cnt, I: Integer; T: TMaintenance;
    OpenN, ClosedN: Integer;
Begin
 OpenN := 0; ClosedN := 0;
 For I := 0 To MAX_MAINTENANCE - 1 Do
  If MaintTickets[I].Active Then Begin
   If MaintTickets[I].Closed Then Inc(ClosedN) Else Inc(OpenN);
  End;
 Cnt := 0;
 Lines[Cnt] := 'TICKETS MAINTENANCE - Ouverts:' + IntToStr(OpenN) +
               '  Fermes:' + IntToStr(ClosedN);
 Inc(Cnt);
 Lines[Cnt] := '====================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For I := 0 To MAX_MAINTENANCE - 1 Do
  If MaintTickets[I].Active And (Cnt < MAX_REPORT_LINES - 4) Then Begin
   T := MaintTickets[I];
   Lines[Cnt] := IntToStrW(T.ID, 5) + ' [' +
                 PadRight(PriorityLabel(T.Priority), 8) + '] ';
   If T.SpotIdx >= 0 Then
    Lines[Cnt] := Lines[Cnt] + 'Ch.' + IntToStr(RoomNumber(T.SpotIdx)) + ' '
   Else
    Lines[Cnt] := Lines[Cnt] + 'Gen.  ';
   Lines[Cnt] := Lines[Cnt] + Copy(T.Description, 1, 40);
   If T.Closed Then Lines[Cnt] := Lines[Cnt] + ' FERME';
   Inc(Cnt);
   Lines[Cnt] := '       Ouvert: ' + FormatDateTime(T.OpenedDT) +
                 ' / Assigne: ' + T.AssignedTo;
   Inc(Cnt);
   If T.Closed Then Begin
    Lines[Cnt] := '       Ferme : ' + FormatDateTime(T.ClosedDT) +
                  ' Cout: ' + RealToStr(T.Cost, 0, 2);
    Inc(Cnt);
   End;
   Lines[Cnt] := '';
   Inc(Cnt);
  End;
 ShowReportDialog('Tickets maintenance', Lines, Cnt);
End;

Procedure DlgMaintClose;
Var IDStr, CostStr: String; ID: LongInt; ErrCode: Integer;
    I, Found: Integer; Cost: Real;
Begin
 IDStr := '';
 If Not ShowInputBox('Fermer ticket', 'ID du ticket :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 Found := -1;
 For I := 0 To MAX_MAINTENANCE - 1 Do
  If MaintTickets[I].Active And (MaintTickets[I].ID = ID) Then Begin
   Found := I; Break;
  End;
 If Found < 0 Then Begin ShowMessageBox('Erreur', 'Ticket introuvable.'); Exit; End;
 CostStr := '0';
 If Not ShowInputBox('Fermer ticket', 'Cout final ($) :', CostStr, 10) Then Exit;
 Val(CostStr, Cost, ErrCode); If ErrCode <> 0 Then Cost := 0;
 CloseMaintTicket(Found, Cost);
 If MaintTickets[Found].SpotIdx >= 0 Then
  Spots[MaintTickets[Found].SpotIdx].HKState := HK_DIRTY;
 ShowMessageBox('Maintenance', 'Ticket ferme.');
End;

Procedure DlgMaintReport;
Var Lines: TReportArray; Cnt, I, P: Integer;
    OpenByPri: Array[0..3] Of Integer;
    ClosedByPri: Array[0..3] Of Integer;
    CostByPri: Array[0..3] Of Real;
    TotalCost: Real;
Begin
 For I := 0 To 3 Do Begin OpenByPri[I]:=0; ClosedByPri[I]:=0; CostByPri[I]:=0; End;
 TotalCost := 0;
 For I := 0 To MAX_MAINTENANCE - 1 Do
  If MaintTickets[I].Active Then Begin
   P := MaintTickets[I].Priority;
   If P > 3 Then P := 3;
   If MaintTickets[I].Closed Then Begin
    Inc(ClosedByPri[P]);
    CostByPri[P] := CostByPri[P] + MaintTickets[I].Cost;
    TotalCost := TotalCost + MaintTickets[I].Cost;
   End Else
    Inc(OpenByPri[P]);
  End;
 Cnt := 0;
 Lines[Cnt] := 'RAPPORT MAINTENANCE';
 Inc(Cnt);
 Lines[Cnt] := '===================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Priorite', 12) +
               PadLeft('Ouverts', 10) +
               PadLeft('Fermes', 10) +
               PadLeft('Cout total', 14);
 Inc(Cnt);
 Lines[Cnt] := '----------------------------------------------';
 Inc(Cnt);
 For P := 0 To 3 Do Begin
  Lines[Cnt] := PadRight(PriorityLabel(P), 12) +
                PadLeft(IntToStr(OpenByPri[P]), 10) +
                PadLeft(IntToStr(ClosedByPri[P]), 10) +
                PadLeft(RealToStr(CostByPri[P], 0, 2), 14);
  Inc(Cnt);
 End;
 Lines[Cnt] := '----------------------------------------------';
 Inc(Cnt);
 Lines[Cnt] := 'Cout total maintenance : ' + RealToStr(TotalCost, 0, 2);
 Inc(Cnt);
 ShowReportDialog('Rapport maintenance', Lines, Cnt);
End;

{ ----- Floor dialogs ----- }

Procedure DlgFloorConfig;
Const ICols=0; IRows=1; IFlrs=2; IBOK=3; IBC=4;
Var D: TDialog; NC, NR, NF: LongInt; ErrCode: Integer;
Begin
 DlgInit(D, 'Configurer la grille hotel', 420, 220);
 AddLabel(D, 18, 35, 'Chambres par rangee :');
 AddEdit(D, 220, 32, 60, 3);
 AddLabel(D, 18, 60, 'Rangees par etage :');
 AddEdit(D, 220, 57, 60, 3);
 AddLabel(D, 18, 85, 'Nombre d etages :');
 AddEdit(D, 220, 82, 60, 3);
 AddLabel(D, 18, 120, 'Max : ' + IntToStr(MAX_COLS) + ' x ' +
                       IntToStr(MAX_ROWS) + ' x ' + IntToStr(MAX_FLOORS));
 AddButton(D, 200, 160, 100, 'Appliquer', BTN_DEFAULT);
 AddButton(D, 310, 160, 100, 'Annuler', BTN_CANCEL);
 D.Ctrls[ICols].Text := IntToStr(ColCount);
 D.Ctrls[IRows].Text := IntToStr(RowCount);
 D.Ctrls[IFlrs].Text := IntToStr(FloorCount);
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[ICols].Text, NC, ErrCode);
  Val(D.Ctrls[IRows].Text, NR, ErrCode);
  Val(D.Ctrls[IFlrs].Text, NF, ErrCode);
  If NC < 1 Then NC := 1; If NC > MAX_COLS Then NC := MAX_COLS;
  If NR < 1 Then NR := 1; If NR > MAX_ROWS Then NR := MAX_ROWS;
  If NF < 1 Then NF := 1; If NF > MAX_FLOORS Then NF := MAX_FLOORS;
  ColCount := NC; RowCount := NR; FloorCount := NF;
  If CurrentFloor >= FloorCount Then CurrentFloor := 0;
  ComputeGridLayout;
  ShowMessageBox('Hotel',
   'Grille : ' + IntToStr(NC) + ' x ' + IntToStr(NR) +
   ' x ' + IntToStr(NF) + ' etages (' +
   IntToStr(NC * NR * NF) + ' chambres total).');
 End;
End;

Procedure DlgFloorNames;
Const ISel=0; INam=1; INum=2; ICEna=3; IBSave=4; IBC=5;
Var D: TDialog;
    LblA: Array[0..MAX_FLOORS - 1] Of String[24];
    LblP: Array[0..MAX_FLOORS - 1] Of PChar;
    K, Sel: Integer; V: LongInt; ErrCode: Integer;
Begin
 For K := 0 To FloorCount - 1 Do Begin
  LblA[K] := 'Etage ' + IntToStr(K) + ' - ' + Floors[K].Name;
  LblP[K] := @LblA[K][1];
 End;
 DlgInit(D, 'Renommer les etages', 460, 240);
 AddLabel(D, 18, 35, 'Etage :');
 AddCombo(D, 110, 32, 320, LblP, FloorCount);
 AddLabel(D, 18, 60, 'Nom :');
 AddEdit(D, 110, 57, 320, 20);
 AddLabel(D, 18, 85, 'Numero affiche :');
 AddEdit(D, 140, 82, 60, 3);
 AddCheck(D, 18, 110, 'Active', True);
 AddButton(D, 250, 180, 90, 'Enregistrer', BTN_DEFAULT);
 AddButton(D, 350, 180, 90, 'Fermer', BTN_CANCEL);
 D.Ctrls[ISel].ListSel := 0;
 D.Ctrls[INam].Text := Floors[0].Name;
 D.Ctrls[INum].Text := IntToStr(Floors[0].Number);
 D.Ctrls[ICEna].Checked := Floors[0].Enabled;
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[ISel].ListSel;
  If Sel < 0 Then Sel := 0;
  Floors[Sel].Name := D.Ctrls[INam].Text;
  Val(D.Ctrls[INum].Text, V, ErrCode); If ErrCode = 0 Then Floors[Sel].Number := V;
  Floors[Sel].Enabled := D.Ctrls[ICEna].Checked;
  ShowMessageBox('Etages', 'Etage enregistre.');
 End;
End;

Procedure DlgFloorOverview;
Var Lines: TReportArray; Cnt, F, Occ, Fr, Oo, Hk: Integer;
Begin
 Cnt := 0;
 Lines[Cnt] := 'VUE D ENSEMBLE PAR ETAGE';
 Inc(Cnt);
 Lines[Cnt] := '========================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Etage', 8) + PadRight('Nom', 22) +
               PadLeft('Libres', 8) + PadLeft('Occup', 8) +
               PadLeft('OOO', 6) + PadLeft('Occ%', 8);
 Inc(Cnt);
 Lines[Cnt] := '---------------------------------------------------------';
 Inc(Cnt);
 For F := 0 To FloorCount - 1 Do Begin
  Fr := CountByStateOnFloor(ssFree, F);
  Occ := CountByStateOnFloor(ssOccupied, F);
  Oo := 0; Hk := 0;
  { Comptage OOO sur l etage }
  For Hk := 0 To RoomsPerFloor - 1 Do
   If Spots[F * MAX_ROOMS_PER_FLOOR + Hk].HKState = HK_OOO Then Inc(Oo);
  Lines[Cnt] := PadRight(IntToStr(Floors[F].Number), 8) +
                PadRight(Floors[F].Name, 22) +
                PadLeft(IntToStr(Fr), 8) +
                PadLeft(IntToStr(Occ), 8) +
                PadLeft(IntToStr(Oo), 6) +
                PadLeft(RealToStr(OccupancyRateOnFloor(F), 0, 1) + '%', 8);
  Inc(Cnt);
 End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Total general : ' + IntToStr(SpotCount) +
               ' chambres, occupation ' +
               RealToStr(OccupancyRate, 0, 1) + '%';
 Inc(Cnt);
 ShowReportDialog('Vue d ensemble etages', Lines, Cnt);
End;

{ ----- Check-in / Check-out / quick book ----- }

Procedure DoCheckin(Idx: Integer; Const GuestName, GuestPhone: String;
                    Adt, Chi: Byte; Source: Byte; ResStat: Byte);
Var NbN: Word;
Begin
 If (Idx < 0) Or (Idx >= MAX_SPOTS) Then Exit;
 If Spots[Idx].State = ssOccupied Then Exit;
 GetCurrentDT(NowDT);
 NbN := 1;
 Case Spots[Idx].DurCode Of
  DUR_12H: NbN := 1;
  DUR_24H: NbN := 1;
  DUR_2D:  NbN := 2;
  DUR_7D:  NbN := 7;
  DUR_1M:  NbN := 30;
 End;
 Spots[Idx].State := ssOccupied;
 Spots[Idx].Owner := TrimStr(GuestName);
 Spots[Idx].Phone := TrimStr(GuestPhone);
 Spots[Idx].StartDT := NowDT;
 Spots[Idx].EndDT := NowDT;
 AddHours(Spots[Idx].EndDT, NbN * 24);
 Spots[Idx].NbNights := NbN;
 Spots[Idx].Adults := Adt;
 Spots[Idx].Children := Chi;
 Spots[Idx].Source := Source;
 Spots[Idx].ResStatus := ResStat;
 Spots[Idx].RateRoom := ComputeRoomRate(Idx);
 Spots[Idx].RateExtra := 0;
 Spots[Idx].Paid := Spots[Idx].RateRoom * NbN;
 Spots[Idx].HKState := HK_INPROGRESS;
 Spots[Idx].Plate := 'F' + IntToStr(NextChargeID);
 DailyRevenue := DailyRevenue + Spots[Idx].Paid;
 Inc(DailyReservations);
 Inc(PMSCheckinsToday);
 RecordTransaction(Spots[Idx].Plate, Spots[Idx].Owner,
                   Spots[Idx].StartDT, Spots[Idx].EndDT,
                   Spots[Idx].Paid, Idx, TXK_RESERVE);
End;

Procedure DoCheckout(Idx: Integer);
Var FinalAmt: Real; IdxG: Integer;
Begin
 If (Idx < 0) Or (Idx >= MAX_SPOTS) Then Exit;
 If Spots[Idx].State = ssFree Then Exit;
 FinalAmt := Spots[Idx].Paid + Spots[Idx].RateExtra;
 IdxG := FindGuestIdxByID(Spots[Idx].GuestID);
 If IdxG >= 0 Then UpdateGuestAfterStay(IdxG, FinalAmt);
 RecordTransaction(Spots[Idx].Plate, Spots[Idx].Owner,
                   Spots[Idx].StartDT, NowDT, FinalAmt, Idx, TXK_RELEASE);
 Inc(DailyReleases);
 Inc(PMSCheckoutsToday);
 AutoCleanAfterCheckout(Idx);
 ClearSpot(Spots[Idx]);
 Spots[Idx].HKState := HK_DIRTY;
End;

Procedure DlgRoomCheckin;
Const IRoom=0; IGN=1; IGP=2; IAdt=3; IChi=4; ISrc=5; IBOK=6; IBC=7;
Var D: TDialog;
    SrcOpts: Array[0..CH_COUNT - 1] Of String[20];
    SrcLbl: Array[0..CH_COUNT - 1] Of PChar;
    K, RN, J, Idx: Integer; ErrCode: Integer;
    Adt, Chi: LongInt;
Begin
 For K := 0 To CH_COUNT - 1 Do Begin
  SrcOpts[K] := Channels[K].Label_; SrcLbl[K] := @SrcOpts[K][1];
 End;
 DlgInit(D, 'Check-in', 460, 280);
 AddLabel(D, 18, 35, 'Chambre :');
 AddEdit(D, 110, 32, 80, 5);
 AddLabel(D, 18, 60, 'Nom client :');
 AddEdit(D, 110, 57, 240, 31);
 AddLabel(D, 18, 85, 'Telephone :');
 AddEdit(D, 110, 82, 180, 15);
 AddLabel(D, 18, 110, 'Adultes / Enfants :');
 AddEdit(D, 180, 107, 60, 3);
 AddEdit(D, 245, 107, 60, 3);
 AddLabel(D, 18, 135, 'Source :');
 AddCombo(D, 110, 132, 240, SrcLbl, CH_COUNT);
 AddButton(D, 240, 220, 100, 'Check-in', BTN_DEFAULT);
 AddButton(D, 350, 220, 90, 'Annuler', BTN_CANCEL);
 D.Ctrls[IAdt].Text := '1';
 D.Ctrls[IChi].Text := '0';
 D.Ctrls[ISrc].ListSel := CH_WALKIN;
 If DlgRun(D) = 1 Then Begin
  Val(D.Ctrls[IRoom].Text, RN, ErrCode);
  Idx := -1;
  If ErrCode = 0 Then
   For J := 0 To MAX_SPOTS - 1 Do
    If RoomNumber(J) = RN Then Begin Idx := J; Break; End;
  If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
  If Spots[Idx].State = ssOccupied Then Begin
   ShowMessageBox('Erreur', 'Chambre deja occupee.'); Exit;
  End;
  Val(D.Ctrls[IAdt].Text, Adt, ErrCode); If Adt < 1 Then Adt := 1;
  Val(D.Ctrls[IChi].Text, Chi, ErrCode); If Chi < 0 Then Chi := 0;
  DoCheckin(Idx, D.Ctrls[IGN].Text, D.Ctrls[IGP].Text,
            Adt, Chi, D.Ctrls[ISrc].ListSel, RES_CHECKED_IN);
  ShowMessageBox('Check-in', 'Client enregistre en chambre ' + IntToStr(RN) + '.');
 End;
End;

Procedure DlgRoomCheckout;
Var RNStr: String; RN, J, Idx: Integer; ErrCode: Integer;
    Due: Real;
Begin
 RNStr := '';
 If Not ShowInputBox('Check-out', 'Numero de chambre :', RNStr, 5) Then Exit;
 Val(TrimStr(RNStr), RN, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Invalide.'); Exit; End;
 Idx := -1;
 For J := 0 To MAX_SPOTS - 1 Do
  If RoomNumber(J) = RN Then Begin Idx := J; Break; End;
 If Idx < 0 Then Begin ShowMessageBox('Erreur', 'Chambre introuvable.'); Exit; End;
 If Spots[Idx].State = ssFree Then Begin
  ShowMessageBox('Erreur', 'Chambre deja libre.'); Exit;
 End;
 Due := TotalSpotChargesUnpaid(Idx);
 If Due > 0 Then Begin
  If Not ShowConfirmBox('Check-out',
     'Il reste ' + RealToStr(Due, 0, 2) + ' du. Continuer quand meme ?') Then Exit;
 End;
 DoCheckout(Idx);
 ShowMessageBox('Check-out', 'Chambre ' + IntToStr(RN) + ' liberee.');
End;

Procedure DlgRoomTypes;
Const ISel=0; INam=1; IShort=2; IMax=3; IRate=4; ICEna=5;
      IBSave=6; IBClose=7;
Var D: TDialog;
    LblA: Array[0..RT_TYPES - 1] Of String[20];
    LblP: Array[0..RT_TYPES - 1] Of PChar;
    K, Sel: Integer; V: LongInt; R: Real; ErrCode: Integer;
Begin
 For K := 0 To RT_TYPES - 1 Do Begin
  LblA[K] := RoomTypes[K].Label_; LblP[K] := @LblA[K][1];
 End;
 DlgInit(D, 'Types de chambres', 460, 260);
 AddLabel(D, 18, 35, 'Type :');
 AddCombo(D, 110, 32, 220, LblP, RT_TYPES);
 AddLabel(D, 18, 60, 'Nom :');
 AddEdit(D, 110, 57, 220, 20);
 AddLabel(D, 18, 85, 'Abrege :');
 AddEdit(D, 110, 82, 80, 8);
 AddLabel(D, 18, 110, 'Capacite max :');
 AddEdit(D, 140, 107, 60, 3);
 AddLabel(D, 18, 135, 'Tarif de base :');
 AddEdit(D, 140, 132, 80, 8);
 AddCheck(D, 18, 160, 'Type actif', True);
 AddButton(D, 240, 210, 100, 'Enregistrer', BTN_DEFAULT);
 AddButton(D, 350, 210, 90, 'Fermer', BTN_CANCEL);
 D.Ctrls[ISel].ListSel := 0;
 D.Ctrls[INam].Text := RoomTypes[0].Label_;
 D.Ctrls[IShort].Text := RoomTypes[0].ShortLbl;
 D.Ctrls[IMax].Text := IntToStr(RoomTypes[0].MaxGuests);
 D.Ctrls[IRate].Text := RealToStr(RoomTypes[0].BaseRate, 0, 2);
 D.Ctrls[ICEna].Checked := RoomTypes[0].Enabled;
 If DlgRun(D) = 1 Then Begin
  Sel := D.Ctrls[ISel].ListSel;
  If Sel < 0 Then Sel := 0;
  RoomTypes[Sel].Label_ := D.Ctrls[INam].Text;
  RoomTypes[Sel].ShortLbl := D.Ctrls[IShort].Text;
  Val(D.Ctrls[IMax].Text, V, ErrCode); If ErrCode = 0 Then RoomTypes[Sel].MaxGuests := V;
  Val(D.Ctrls[IRate].Text, R, ErrCode); If ErrCode = 0 Then RoomTypes[Sel].BaseRate := R;
  RoomTypes[Sel].Enabled := D.Ctrls[ICEna].Checked;
  ShowMessageBox('Types', 'Type mis a jour.');
 End;
End;

Procedure DlgRoomRename;
Var Lines: TReportArray; Cnt, F: Integer;
Begin
 Cnt := 0;
 Lines[Cnt] := 'NUMEROTATION CHAMBRES (numero = etage*100 + position)';
 Inc(Cnt);
 Lines[Cnt] := '=====================================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For F := 0 To FloorCount - 1 Do Begin
  Lines[Cnt] := 'Etage ' + IntToStr(Floors[F].Number) +
                ' (' + Floors[F].Name + ') : ' +
                IntToStr(Floors[F].Number * 100 + 1) +
                ' a ' + IntToStr(Floors[F].Number * 100 + RoomsPerFloor);
  Inc(Cnt);
 End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Pour changer la numerotation, ajustez le numero de l etage';
 Inc(Cnt);
 Lines[Cnt] := 'via "Etages > Renommer".';
 Inc(Cnt);
 ShowReportDialog('Numerotation', Lines, Cnt);
End;

Procedure DlgRoomQuickBook;
Var Idx: Integer; Name: String;
Begin
 Idx := FindFreeSpot;
 If Idx < 0 Then Begin
  ShowMessageBox('Quick-book', 'Plus de chambre disponible.'); Exit;
 End;
 Name := 'Walk-in';
 If Not ShowInputBox('Quick-book',
       'Nom client (chambre ' + IntToStr(RoomNumber(Idx)) + ') :',
       Name, 31) Then Exit;
 Spots[Idx].DurCode := DUR_24H;
 DoCheckin(Idx, Name, '', 1, 0, CH_WALKIN, RES_CHECKED_IN);
 SwitchFloor(SpotFloor(Idx));
 ShowMessageBox('Quick-book',
  'Chambre ' + IntToStr(RoomNumber(Idx)) +
  ' attribuee a ' + Name + '.');
End;


{ ============================================================
  PMS - MODULE 6 : AUDIT NOCTURNE / ADR/REVPAR / LOYALTY
  ============================================================ }

{ ----- Calculs ADR / RevPAR ----- }

Function ComputeADR: Real;
{ ADR = revenu chambre total / nb chambres vendues }
Var Total: Real; Sold: LongInt; I: Integer;
Begin
 Total := 0; Sold := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     (Spots[I].State = ssOccupied) Then Begin
   Total := Total + Spots[I].Paid;
   Inc(Sold);
  End;
 If Sold = 0 Then ComputeADR := 0
 Else ComputeADR := Total / Sold;
End;

Function ComputeRevPAR: Real;
{ RevPAR = revenu chambre total / nb chambres disponibles }
Var Total: Real; Avail: LongInt; I: Integer;
Begin
 Total := 0; Avail := SpotCount;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     (Spots[I].State = ssOccupied) Then
   Total := Total + Spots[I].Paid;
 If Avail = 0 Then ComputeRevPAR := 0
 Else ComputeRevPAR := Total / Avail;
End;

Function ComputeRevenue: Real;
Var I: Integer; T: Real;
Begin
 T := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     (Spots[I].State = ssOccupied) Then
   T := T + Spots[I].Paid + Spots[I].RateExtra;
 ComputeRevenue := T;
End;

Procedure RecordAuditEntry;
Var Idx: Integer;
Begin
 Idx := AuditCount Mod MAX_AUDIT_LOG;
 AuditLog[Idx].Active := True;
 GetCurrentDT(AuditLog[Idx].AuditDT);
 AuditLog[Idx].Occupancy := OccupancyRate;
 AuditLog[Idx].ADR := ComputeADR;
 AuditLog[Idx].RevPAR := ComputeRevPAR;
 AuditLog[Idx].Revenue := ComputeRevenue;
 AuditLog[Idx].Arrivals := PMSCheckinsToday;
 AuditLog[Idx].Departures := PMSCheckoutsToday;
 AuditLog[Idx].NoShows := PMSNoShowsToday;
 AuditLog[Idx].Cancellations := 0;
 AuditLog[Idx].Notes := '';
 Inc(AuditCount);
End;

Procedure DlgAuditNight;
Var Lines: TReportArray; Cnt: Integer;
    Arr, Dep, OccN, ExpN, I: Integer;
    Rev, RoomRev, ServRev: Real;
Begin
 Arr := 0; Dep := 0; OccN := 0; ExpN := 0;
 Rev := 0; RoomRev := 0; ServRev := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If SpotFloor(I) < FloorCount Then Begin
   If Spots[I].State = ssOccupied Then Begin
    Inc(OccN);
    RoomRev := RoomRev + Spots[I].Paid;
    ServRev := ServRev + Spots[I].RateExtra;
    If Spots[I].Arrival Then Inc(Arr);
    If Spots[I].Departure Then Inc(Dep);
    If MinutesBetween(NowDT, Spots[I].EndDT) < 0 Then Inc(ExpN);
   End;
  End;
 Rev := RoomRev + ServRev;
 Cnt := 0;
 Lines[Cnt] := 'AUDIT DE NUIT - ' + FormatDateTime(NowDT);
 Inc(Cnt);
 Lines[Cnt] := '==========================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Chambres disponibles      : ' + IntToStr(SpotCount);
 Inc(Cnt);
 Lines[Cnt] := 'Chambres occupees         : ' + IntToStr(OccN);
 Inc(Cnt);
 Lines[Cnt] := 'Taux d occupation         : ' +
               RealToStr(OccupancyRate, 0, 1) + ' %';
 Inc(Cnt);
 Lines[Cnt] := 'Arrivees prevues          : ' + IntToStr(Arr);
 Inc(Cnt);
 Lines[Cnt] := 'Departs prevus            : ' + IntToStr(Dep);
 Inc(Cnt);
 Lines[Cnt] := 'Chambres expirees         : ' + IntToStr(ExpN);
 Inc(Cnt);
 Lines[Cnt] := 'Revenu chambres (jour)    : ' + RealToStr(RoomRev, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'Revenu services (jour)    : ' + RealToStr(ServRev, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'TOTAL revenu              : ' + RealToStr(Rev, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'ADR (revenu/ch.vendue)    : ' + RealToStr(ComputeADR, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'RevPAR (revenu/ch.dispo)  : ' + RealToStr(ComputeRevPAR, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Check-ins du jour         : ' + IntToStr(PMSCheckinsToday);
 Inc(Cnt);
 Lines[Cnt] := 'Check-outs du jour        : ' + IntToStr(PMSCheckoutsToday);
 Inc(Cnt);
 Lines[Cnt] := 'No-shows du jour          : ' + IntToStr(PMSNoShowsToday);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Etat menage :';
 Inc(Cnt);
 Lines[Cnt] := '   Propres        : ' + IntToStr(CountHKState(HK_CLEAN));
 Inc(Cnt);
 Lines[Cnt] := '   Sales          : ' + IntToStr(CountHKState(HK_DIRTY));
 Inc(Cnt);
 Lines[Cnt] := '   Inspectees     : ' + IntToStr(CountHKState(HK_INSPECTED));
 Inc(Cnt);
 Lines[Cnt] := '   Hors service   : ' + IntToStr(CountHKState(HK_OOO));
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Audit enregistre dans la log.';
 Inc(Cnt);
 RecordAuditEntry;
 ShowReportDialog('Audit de nuit', Lines, Cnt);
End;

Procedure DlgAuditLog;
Var Lines: TReportArray; Cnt, I: Integer;
    A: TAuditLine;
Begin
 Cnt := 0;
 Lines[Cnt] := 'LOG AUDIT NOCTURNE (' + IntToStr(AuditCount) + ' entrees)';
 Inc(Cnt);
 Lines[Cnt] := '===================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Date', 18) +
               PadLeft('Occ%', 8) +
               PadLeft('ADR', 10) +
               PadLeft('RevPAR', 10) +
               PadLeft('Revenu', 12);
 Inc(Cnt);
 Lines[Cnt] := '------------------------------------------------------';
 Inc(Cnt);
 For I := 0 To MAX_AUDIT_LOG - 1 Do
  If AuditLog[I].Active And (Cnt < MAX_REPORT_LINES - 2) Then Begin
   A := AuditLog[I];
   Lines[Cnt] := PadRight(FormatDateTime(A.AuditDT), 18) +
                 PadLeft(RealToStr(A.Occupancy, 0, 1), 8) +
                 PadLeft(RealToStr(A.ADR, 0, 2), 10) +
                 PadLeft(RealToStr(A.RevPAR, 0, 2), 10) +
                 PadLeft(RealToStr(A.Revenue, 0, 2), 12);
   Inc(Cnt);
  End;
 ShowReportDialog('Log audit', Lines, Cnt);
End;

Procedure DlgAuditADR;
Var Lines: TReportArray; Cnt, I, T: Integer;
    Total: Real; Sold: LongInt;
    PerType: Array[0..RT_TYPES - 1] Of Real;
    CntType: Array[0..RT_TYPES - 1] Of LongInt;
Begin
 For I := 0 To RT_TYPES - 1 Do Begin PerType[I] := 0; CntType[I] := 0; End;
 Total := 0; Sold := 0;
 For I := 0 To MAX_SPOTS - 1 Do
  If (SpotFloor(I) < FloorCount) And
     (Spots[I].State = ssOccupied) Then Begin
   Total := Total + Spots[I].Paid;
   Inc(Sold);
   T := Spots[I].RoomType;
   If T < RT_TYPES Then Begin
    PerType[T] := PerType[T] + Spots[I].Paid;
    Inc(CntType[T]);
   End;
  End;
 Cnt := 0;
 Lines[Cnt] := 'ANALYSE ADR (Average Daily Rate)';
 Inc(Cnt);
 Lines[Cnt] := '================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'ADR global : ';
 If Sold = 0 Then Lines[Cnt] := Lines[Cnt] + 'N/A'
 Else Lines[Cnt] := Lines[Cnt] + RealToStr(Total / Sold, 0, 2) +
                    ' (sur ' + IntToStr(Sold) + ' chambres vendues)';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'ADR par type :';
 Inc(Cnt);
 For T := 0 To RT_TYPES - 1 Do
  If CntType[T] > 0 Then Begin
   Lines[Cnt] := '  ' + PadRight(RoomTypes[T].Label_, 16) +
                 ' = ' + RealToStr(PerType[T] / CntType[T], 0, 2) +
                 ' (' + IntToStr(CntType[T]) + ' ch.)';
   Inc(Cnt);
  End;
 ShowReportDialog('Analyse ADR', Lines, Cnt);
End;

Procedure DlgAuditRevPAR;
Var Lines: TReportArray; Cnt, F: Integer;
    Total: Real;
Begin
 Cnt := 0;
 Lines[Cnt] := 'ANALYSE RevPAR (Revenue Per Available Room)';
 Inc(Cnt);
 Lines[Cnt] := '===========================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'RevPAR global       : ' + RealToStr(ComputeRevPAR, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'ADR                 : ' + RealToStr(ComputeADR, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := 'Taux d occupation   : ' + RealToStr(OccupancyRate, 0, 1) + '%';
 Inc(Cnt);
 Lines[Cnt] := 'Revenu total chambres : ' + RealToStr(ComputeRevenue, 0, 2);
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'RevPAR par etage :';
 Inc(Cnt);
 For F := 0 To FloorCount - 1 Do Begin
  Total := 0;
  Lines[Cnt] := '  ' + PadRight(Floors[F].Name, 22) +
                ' Occ% ' + PadLeft(RealToStr(OccupancyRateOnFloor(F), 0, 1), 6);
  Inc(Cnt);
 End;
 ShowReportDialog('Analyse RevPAR', Lines, Cnt);
End;

Procedure DlgAuditForecast;
Var Lines: TReportArray; Cnt, D: Integer; Pct: Real;
    DT: TDateTime;
Begin
 Cnt := 0;
 Lines[Cnt] := 'PREVISION D OCCUPATION (7 jours, estimation)';
 Inc(Cnt);
 Lines[Cnt] := '============================================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Date', 14) + PadLeft('Occ% prev', 10) +
               PadLeft('Saison', 16);
 Inc(Cnt);
 Lines[Cnt] := '-------------------------------------------';
 Inc(Cnt);
 For D := 0 To 6 Do Begin
  DT := NowDT;
  AddHours(DT, D * 24);
  Pct := OccupancyRate;
  { Simulation simple : ajuste +/- selon saison }
  Pct := Pct + (Seasons[SeasonForDate(DT)].Multiplier - 1.0) * 30.0;
  If Pct > 100 Then Pct := 100;
  If Pct < 0 Then Pct := 0;
  Lines[Cnt] := PadRight(IntToStr(DT.Year) + '-' +
                         IntToStrW(DT.Month, 2) + '-' +
                         IntToStrW(DT.Day, 2), 14) +
                PadLeft(RealToStr(Pct, 0, 1), 10) +
                '  ' + Seasons[SeasonForDate(DT)].Label_;
  Inc(Cnt);
 End;
 ShowReportDialog('Prevision', Lines, Cnt);
End;

{ ----- Loyalty / Fidelite ----- }

Procedure DlgLoyList;
Var Lines: TReportArray; Cnt, I: Integer; G: TGuest;
    ByLevel: Array[0..LOY_LEVELS - 1] Of LongInt;
    L: Integer;
Begin
 For L := 0 To LOY_LEVELS - 1 Do ByLevel[L] := 0;
 Cnt := 0;
 Lines[Cnt] := 'CLIENTS FIDELITE';
 Inc(Cnt);
 Lines[Cnt] := '================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active And (Guests[I].Loyalty > LOY_NONE) And
     (Cnt < MAX_REPORT_LINES - 8) Then Begin
   G := Guests[I];
   Inc(ByLevel[G.Loyalty]);
   Lines[Cnt] := IntToStrW(G.ID, 5) + ' ' +
                 PadRight(G.LastName + ', ' + G.FirstName, 28) +
                 PadRight(LoyaltyLabel(G.Loyalty), 10) +
                 PadLeft(IntToStr(G.Points), 8) + ' pts ' +
                 PadLeft(IntToStr(G.TotalStays), 4) + ' sej.';
   Inc(Cnt);
  End;
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Repartition :';
 Inc(Cnt);
 For L := LOY_NONE + 1 To LOY_LEVELS - 1 Do Begin
  Lines[Cnt] := '   ' + PadRight(LoyaltyLabel(L), 12) +
                IntToStr(ByLevel[L]) + ' clients';
  Inc(Cnt);
 End;
 ShowReportDialog('Programme fidelite', Lines, Cnt);
End;

Procedure DlgLoyAward;
Var IDStr, PtsStr: String; ID, Pts: LongInt; ErrCode: Integer; IdxG: Integer;
Begin
 IDStr := '';
 If Not ShowInputBox('Attribuer points', 'ID client :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 IdxG := FindGuestIdxByID(ID);
 If IdxG < 0 Then Begin ShowMessageBox('Erreur', 'Client introuvable.'); Exit; End;
 PtsStr := '100';
 If Not ShowInputBox('Attribuer points',
       'Nombre de points :', PtsStr, 6) Then Exit;
 Val(TrimStr(PtsStr), Pts, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Invalide.'); Exit; End;
 AwardGuestPoints(IdxG, Pts);
 ShowMessageBox('Fidelite',
  IntToStr(Pts) + ' points attribues a ' + GuestDisplayName(IdxG) +
  ' (total : ' + IntToStr(Guests[IdxG].Points) +
  ', niveau : ' + LoyaltyLabel(Guests[IdxG].Loyalty) + ').');
End;

Procedure DlgLoyRedeem;
Var IDStr, PtsStr: String; ID, Pts: LongInt; ErrCode: Integer; IdxG: Integer;
Begin
 IDStr := '';
 If Not ShowInputBox('Echanger points', 'ID client :', IDStr, 6) Then Exit;
 Val(TrimStr(IDStr), ID, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'ID invalide.'); Exit; End;
 IdxG := FindGuestIdxByID(ID);
 If IdxG < 0 Then Begin ShowMessageBox('Erreur', 'Client introuvable.'); Exit; End;
 PtsStr := '500';
 If Not ShowInputBox('Echanger',
       'Points a echanger (solde : ' +
       IntToStr(Guests[IdxG].Points) + ') :', PtsStr, 6) Then Exit;
 Val(TrimStr(PtsStr), Pts, ErrCode);
 If ErrCode <> 0 Then Begin ShowMessageBox('Erreur', 'Invalide.'); Exit; End;
 If RedeemGuestPoints(IdxG, Pts) Then
  ShowMessageBox('Fidelite',
   'Echange OK. Solde restant : ' + IntToStr(Guests[IdxG].Points))
 Else
  ShowMessageBox('Fidelite', 'Solde insuffisant.');
End;

Procedure DlgLoyLevels;
Var Lines: TReportArray; Cnt: Integer;
Begin
 Cnt := 0;
 Lines[Cnt] := 'GRILLE DES NIVEAUX FIDELITE';
 Inc(Cnt);
 Lines[Cnt] := '===========================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Aucun (defaut)    : 0 a 999 points';
 Inc(Cnt);
 Lines[Cnt] := 'Argent            : 1 000 points';
 Inc(Cnt);
 Lines[Cnt] := '   -> bienvenue en chambre, late check-out gratuit';
 Inc(Cnt);
 Lines[Cnt] := 'Or                : 5 000 points';
 Inc(Cnt);
 Lines[Cnt] := '   -> sur-classement gratuit selon dispo, p-dej offert';
 Inc(Cnt);
 Lines[Cnt] := 'Platine           : 10 000 points';
 Inc(Cnt);
 Lines[Cnt] := '   -> garantie sur-classement, acces lounge VIP';
 Inc(Cnt);
 Lines[Cnt] := 'Diamant           : 20 000 points';
 Inc(Cnt);
 Lines[Cnt] := '   -> tous avantages, transport prive, conciergerie 24/7';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := 'Bareme : 1 point par dollar depense.';
 Inc(Cnt);
 ShowReportDialog('Niveaux fidelite', Lines, Cnt);
End;

Procedure DlgLoyReport;
Var Lines: TReportArray; Cnt, I, L: Integer;
    ByLvl: Array[0..LOY_LEVELS - 1] Of LongInt;
    PtsLvl: Array[0..LOY_LEVELS - 1] Of LongInt;
    SpentLvl: Array[0..LOY_LEVELS - 1] Of Real;
    StaysLvl: Array[0..LOY_LEVELS - 1] Of LongInt;
    TotG, TotP: LongInt; TotS: Real;
Begin
 For L := 0 To LOY_LEVELS - 1 Do Begin
  ByLvl[L]:=0; PtsLvl[L]:=0; SpentLvl[L]:=0; StaysLvl[L]:=0;
 End;
 TotG := 0; TotP := 0; TotS := 0;
 For I := 0 To MAX_GUESTS - 1 Do
  If Guests[I].Active Then Begin
   L := Guests[I].Loyalty;
   If L < LOY_LEVELS Then Begin
    Inc(ByLvl[L]);
    PtsLvl[L] := PtsLvl[L] + Guests[I].Points;
    SpentLvl[L] := SpentLvl[L] + Guests[I].TotalSpent;
    StaysLvl[L] := StaysLvl[L] + Guests[I].TotalStays;
   End;
   Inc(TotG); TotP := TotP + Guests[I].Points;
   TotS := TotS + Guests[I].TotalSpent;
  End;
 Cnt := 0;
 Lines[Cnt] := 'RAPPORT PROGRAMME FIDELITE';
 Inc(Cnt);
 Lines[Cnt] := '==========================';
 Inc(Cnt);
 Lines[Cnt] := '';
 Inc(Cnt);
 Lines[Cnt] := PadRight('Niveau', 12) + PadLeft('Clients', 10) +
               PadLeft('Points', 12) + PadLeft('Sejours', 10) +
               PadLeft('Depense', 14);
 Inc(Cnt);
 Lines[Cnt] := '----------------------------------------------------------';
 Inc(Cnt);
 For L := 0 To LOY_LEVELS - 1 Do Begin
  Lines[Cnt] := PadRight(LoyaltyLabel(L), 12) +
                PadLeft(IntToStr(ByLvl[L]), 10) +
                PadLeft(IntToStr(PtsLvl[L]), 12) +
                PadLeft(IntToStr(StaysLvl[L]), 10) +
                PadLeft(RealToStr(SpentLvl[L], 0, 2), 14);
  Inc(Cnt);
 End;
 Lines[Cnt] := '----------------------------------------------------------';
 Inc(Cnt);
 Lines[Cnt] := PadRight('TOTAL', 12) +
               PadLeft(IntToStr(TotG), 10) +
               PadLeft(IntToStr(TotP), 12) +
               PadLeft('', 10) +
               PadLeft(RealToStr(TotS, 0, 2), 14);
 Inc(Cnt);
 ShowReportDialog('Rapport fidelite', Lines, Cnt);
End;

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

 ColCount := 8;
 RowCount := 6;
 FloorCount := 4;
 CurrentFloor := 0;
 ClearAllSpots;

 InitDefaultPricing;
 InitDefaultTariffs;
 InitDefaultSubPricing;
 InitSubscriptions;
 InitPMS;
 AssignRoomTypeByFloor;
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
    If ShowInputBox('Etendre', 'Numero de la chambre :', P, 5) Then Begin
     I := StrToIntDef(P, 0) - 1;
     If (I >= 0) And (I < SpotCount) And
        (Spots[I].State = ssOccupied) Then DlgSpotInfo(I);
    End;
   End;
   66: Begin                { F8 = infos }
    P := '';
    If ShowInputBox('Infos', 'Numero de la chambre :', P, 5) Then Begin
     I := StrToIntDef(P, 0) - 1;
     If (I >= 0) And (I < SpotCount) Then DlgSpotInfo(I);
    End;
   End;
   67: DlgSearchByPlate;    { F9 }
   73: GoPrevFloor;         { PageUp }
   81: GoNextFloor;         { PageDown }
   71: GoFirstFloor;        { Home }
   79: GoLastFloor;         { End }
   46: DlgNewhotel;          { Ctrl+N -> N }
   45: Begin                   { Alt+X = Quitter }
    If ShowConfirmBox('Quitter', 'Quitter hotel ?') Then
     QuitRequested := True;
   End;
  End;
  RedrawAll;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  If Ev.KeyChar = 'q' Then
   If ShowConfirmBox('Quitter', 'Quitter hotel ?') Then
    QuitRequested := True;
 End;
End;

Procedure HandleGridClick(MX, MY: Integer);
Var Idx, FI: Integer;
Begin
 If (MY >= FloorTabY) And (MY < FloorTabY + FLOORTAB_HEIGHT) Then Begin
  FI := HitFloorTab(MX, MY);
  If FI >= 0 Then Begin SwitchFloor(FI); RedrawAll; End;
  Exit;
 End;
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
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('PMS : Cette commande permet de lancer l''application ',
                'gestion hoteliere ',
                '(Property Management System).');
  WriteLn;
  Writeln('Syntaxe : PMS [/?]');
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
