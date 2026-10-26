{ @author: Sylvain Maltais (support@gladir.com)
  @created: 2026
  @version: 1.00
  @website(https://www.gladir.com/infrastructure-0)
  @abstract(Target: Turbo Pascal 7, Free Pascal
  @description: Clone de l'application TIGRE
}

{$IFDEF FPC}{$MODE OBJFPC}{$ENDIF}

Program TIGRE;

Uses {$IFDEF FPC}
      DOS,Crt,PtcGraph,PtcCrt,PtcMouse
     {$ELSE}
      DOS,Crt,Graph
     {$ENDIF};

Procedure InitializeGraphics;
Var
 {$IFDEF FPC}
 Driver, Mode: SmallInt;
 ErrCode: SmallInt;
 {$ELSE}
 Driver, Mode: Integer;
 ErrCode: Integer;
 {$ENDIF}
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
 TIGRE_VERSION        = '1.00';

 SCREEN_W             = 640;
 SCREEN_H             = 480;
 CHARW                = 8;
 CHARH                = 8;

 MENUBAR_HEIGHT       = 20;
 TOOLBAR_Y            = 20;
 TOOLBAR_H            = 24;
 MAP_X1               = 0;
 MAP_Y1               = 44;
 MAP_X2               = 485;
 MAP_Y2               = 447;
 MAP_W                = 486;
 MAP_H                = 404;
 PANEL_X1             = 488;
 PANEL_X2             = 639;
 STATUS_Y             = 448;

 MAX_MENUS            = 8;
 MAX_MENU_ITEMS       = 14;

 { Bornes des tableaux dynamiques (sur le tas, extensibles a la demande).
   Free Pascal : limite theorique seulement, la memoire disponible decide.
   Turbo Pascal 7 : segment de 64 Ko, donc bornes reduites. }
{$IFDEF FPC}
 MAX_NODES            = 3000000;
 MAX_PIPES            = 3000000;
 MAX_ESTAB            = 100000;
 MAX_EVENTS           = 100000;
 MAX_INTERV           = 100000;
 MAX_BG               = 20000;
 MAX_BGPTS            = 2000000;
{$ELSE}
 MAX_NODES            = 400;
 MAX_PIPES            = 500;
 MAX_ESTAB            = 200;
 MAX_EVENTS           = 100;
 MAX_INTERV           = 150;
 MAX_BG               = 80;
 MAX_BGPTS            = 2500;
{$ENDIF}
 MAX_SECTORS          = 24;
 MAX_LISTITEMS        = 400;
 MAX_MEAS             = 24;

 { Types d'ouvrages (noeuds) }
 NK_REGARD            = 0;
 NK_VANNE             = 1;
 NK_BASSIN            = 2;
 NK_POMPAGE           = 3;
 NK_DEVERSOIR         = 4;
 NK_EXUTOIRE          = 5;
 NK_COUNT             = 6;

 { Classes de canalisations }
 PC_UNITAIRE          = 0;
 PC_EAUX_USEES        = 1;
 PC_PLUVIAL           = 2;
 PC_COLLECTEUR        = 3;

 { Selection }
 SEL_NONE             = 0;
 SEL_NODE             = 1;
 SEL_PIPE             = 2;
 SEL_ESTAB            = 3;
 SEL_EVENT            = 4;
 SEL_INTERV           = 5;

 { Outils }
 TL_SELECT            = 0;
 TL_PAN               = 1;
 TL_ZOOMWIN           = 2;
 TL_MEASURE           = 3;
 TL_ADDNODE           = 4;
 TL_ADDPIPE           = 5;
 TL_WINSEL            = 6;

 { Couches }
 NLAYERS              = 26;
 L_REGARD             = 0;
 L_UNIT               = 1;
 L_EU                 = 2;
 L_EP                 = 3;
 L_COLL               = 4;
 L_VANNE              = 5;
 L_POMP               = 6;
 L_BASSIN             = 7;
 L_DEVERS             = 8;
 L_EXUT               = 9;
 L_CHANTIER           = 10;
 L_PLANIFIE           = 11;
 L_EV_OUVERT          = 12;
 L_EV_CLOS            = 13;
 L_IV_FINI            = 14;
 L_VISITABLE          = 15;
 L_DEGRADE            = 16;
 L_REMPLI             = 17;
 L_PENTE              = 18;
 L_DIAM               = 19;
 L_VOIES              = 20;
 L_NOMS               = 21;
 L_FLEUVE             = 22;
 L_PARCS              = 23;
 L_ETAB               = 24;
 L_GRILLE             = 25;

 NSECTIONS            = 7;

 { Couleurs }
 CLR_BACKGROUND       = LightGray;
 CLR_MENUBAR          = LightGray;
 CLR_MENU_HIGHLIGHT   = Blue;
 CLR_MENU_TEXT        = Black;
 CLR_BORDER           = DarkGray;
 CLR_BORDER_LIGHT     = White;
 CLR_SHADOW           = DarkGray;
 CLR_MAP_BG           = White;
 CLR_STATUS_BG        = DarkGray;
 CLR_STATUS_TEXT      = White;
 CLR_SECTION          = Brown;
 CLR_SECTION_OPEN     = Yellow;
 CLR_SELECT           = LightMagenta;
 CLR_TRACE            = Green;

 FILE_MAGIC           = 'TIGRE';

{ ============================================================
  TYPES
  ============================================================ }

Type
 TStr7   = String[15];   { identifiants jusqu'a 15 caracteres }
 TStr15  = String[15];
 TStr23  = String[23];
 TStr31  = String[31];
 TStr47  = String[47];
 TStr79  = String[79];

 TNode = Record
  Id       : TStr7;
  Name     : TStr23;
  X, Y     : Real;       { coordonnees (m) }
  Cote     : Real;       { cote du terrain naturel (m) }
  Radier   : Real;       { cote radier (m) }
  Load     : Real;       { debit sanitaire local (L/s) }
  Area     : Real;       { bassin versant local (ha) }
  Flow     : Real;       { debit total transitant (L/s), calcule }
  Kind     : Byte;
  Sector   : Byte;
  State    : Byte;       { 0=bon, 1=moyen, 2=degrade, 3=critique }
  Year     : Integer;
  Sel      : Boolean;
 End;

 TPipe = Record
  Id       : TStr7;
  N1, N2   : Integer;    { amont -> aval }
  Diam     : Integer;    { hauteur (mm) }
  Width    : Integer;    { largeur (mm) }
  Shape    : Byte;       { 0=circulaire 1=ovoide 2=dalot 3=voute }
  Mat      : Byte;
  Cls      : Byte;
  State    : Byte;
  Year     : Integer;
  Visit    : Boolean;
  Street   : Integer;    { indice voie ou -1 }
  Sel      : Boolean;
  Len      : Real;       { longueur (m) }
  Slope    : Real;       { pente (m/m) }
  QFull    : Real;       { capacite pleine section (L/s) }
  Flow     : Real;       { debit (L/s) }
  Fill     : Real;       { taux de remplissage 0..1 (>1 = en charge) }
  Vel      : Real;       { vitesse (m/s) }
 End;

 TEstab = Record
  Name     : String[39];
  Sap      : String[5];
  Naf      : String[7];
  Commune  : TStr23;
  Post     : String[9];
  Node     : Integer;
  Flow     : Real;       { rejet m3/jour }
 End;

 TEvent = Record
  Id       : TStr7;
  Kind     : Byte;
  Status   : Byte;       { 0=ouvert 1=en traitement 2=clos }
  Date     : String[10];
  Desc     : TStr47;
  TKind    : Byte;       { 0=aucun 1=noeud 2=conduite }
  TIdx     : Integer;
 End;

 TInterv = Record
  Id       : TStr7;
  Kind     : Byte;
  Status   : Byte;       { 0=planifiee 1=en cours 2=terminee }
  Date     : String[10];
  Team     : TStr15;
  Cost     : Real;
  TKind    : Byte;
  TIdx     : Integer;
 End;

 TBgLine = Record
  Kind     : Byte;       { 0=voie 1=fleuve 2=parc }
  Name     : TStr31;
  First    : Integer;
  Count    : Integer;
  Width    : Integer;
 End;

 TPt = Record
  X, Y     : LongInt;
 End;

 TLayer = Record
  Name     : String[13];
  Sec      : Byte;
  A, R, T  : Boolean;    { affiche, reperable, texte }
 End;

{$IFDEF FPC}
 PIntArr    = ^TIntArr;
 TIntArr    = Array[0..33554431] Of LongInt;
 PBoolArr   = ^TBoolArr;
 TBoolArr   = Array[0..33554431] Of Boolean;
{$ELSE}
 PIntArr    = ^TIntArr;
 TIntArr    = Array[0..MAX_NODES + MAX_PIPES] Of LongInt;
 PBoolArr   = ^TBoolArr;
 TBoolArr   = Array[0..MAX_NODES + MAX_PIPES] Of Boolean;
{$ENDIF}
 PNodeArr   = ^TNodeArr;
 TNodeArr   = Array[0..MAX_NODES - 1] Of TNode;
 PPipeArr   = ^TPipeArr;
 TPipeArr   = Array[0..MAX_PIPES - 1] Of TPipe;
 PEstArr    = ^TEstArr;
 TEstArr    = Array[0..MAX_ESTAB - 1] Of TEstab;
 PEvArr     = ^TEvArr;
 TEvArr     = Array[0..MAX_EVENTS - 1] Of TEvent;
 PIvArr     = ^TIvArr;
 TIvArr     = Array[0..MAX_INTERV - 1] Of TInterv;
 PBgArr     = ^TBgArr;
 TBgArr     = Array[0..MAX_BG - 1] Of TBgLine;
 PPtArr     = ^TPtArr;
 TPtArr     = Array[0..MAX_BGPTS - 1] Of TPt;
 PListArr   = ^TListArr;
 TListArr   = Array[0..MAX_LISTITEMS - 1] Of TStr79;

 { Evenements }
 TEventKind = (EV_NONE, EV_MOUSE_MOVE, EV_MOUSE_DOWN, EV_MOUSE_UP,
               EV_MOUSE_DBLCLICK, EV_KEY_DOWN, EV_KEY_CHAR);

 TMouseButton = (MB_NONE, MB_LEFT, MB_RIGHT, MB_MIDDLE);

 TUIEvent = Record
  Kind       : TEventKind;
  MouseX     : Integer;
  MouseY     : Integer;
  MouseBtn   : TMouseButton;
  KeyCode    : Word;
  KeyChar    : Char;
  Timestamp  : LongInt;
 End;

 { Menus }
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

{ ============================================================
  TABLES DE LIBELLES
  ============================================================ }

Const
 NodeKindName : Array[0..NK_COUNT - 1] Of String[12] =
  ('Regard', 'Vanne', 'Bassin', 'Pompage', 'Deversoir', 'Exutoire');
 PipeClsName  : Array[0..3] Of String[12] =
  ('Unitaire', 'Eaux usees', 'Pluvial', 'Collecteur');
 ShapeName    : Array[0..3] Of String[12] =
  ('Circulaire', 'Ovoide', 'Dalot', 'Voute');
 MatName      : Array[0..5] Of String[12] =
  ('Beton', 'Gres', 'Fonte', 'PVC', 'Maconnerie', 'PEHD');
 MatManning   : Array[0..5] Of Real =
  (0.013, 0.012, 0.012, 0.010, 0.017, 0.010);
 StateName    : Array[0..3] Of String[10] =
  ('Bon', 'Moyen', 'Degrade', 'Critique');
 EvKindName   : Array[0..5] Of String[12] =
  ('Obstruction', 'Inondation', 'Affaissement', 'Odeur', 'Pollution', 'Infiltration');
 EvStatName   : Array[0..2] Of String[13] =
  ('Ouvert', 'En traitement', 'Clos');
 IvKindName   : Array[0..5] Of String[16] =
  ('Curage', 'Inspection TV', 'Reparation', 'Rehabilitation', 'Controle branch.', 'Mesure debit');
 IvStatName   : Array[0..2] Of String[12] =
  ('Planifiee', 'En cours', 'Terminee');
 SectionName  : Array[0..NSECTIONS - 1] Of String[20] =
  ('Ouvrages', 'Ouvr. Temporaires', 'Evenements', 'Interventions',
   'Galerie technique', 'Occupation', 'Fond de plan');

{ ============================================================
  VARIABLES GLOBALES
  ============================================================ }

Var
 QuitRequested  : Boolean;

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

 { Donnees du reseau (sur le tas) }
 Nodes          : PNodeArr;
 NodeCnt        : Integer;
 Pipes          : PPipeArr;
 PipeCnt        : Integer;
 Estabs         : PEstArr;
 EstCnt         : Integer;
 Events         : PEvArr;
 EvCnt          : Integer;
 Intervs        : PIvArr;
 IvCnt          : Integer;
 Bgs            : PBgArr;
 BgCnt          : Integer;
 BgPts          : PPtArr;
 BgPtCnt        : Integer;
 SectorName     : Array[0..MAX_SECTORS - 1] Of TStr23;
 SectorCnt      : Integer;
 PlanTitle      : String[79];
 PlanOrg        : String[31];
 PlanFile       : String[79];
 PlanDirty      : Boolean;
 LoadTrunc      : Boolean;   { plan tronque : memoire insuffisante }

 { Topologie (listes d'adjacence) }
 FirstOut       : PIntArr;
 FirstIn        : PIntArr;
 NextOut        : PIntArr;
 NextIn         : PIntArr;
 TraceNode      : PBoolArr;
 TracePipe      : PBoolArr;

 { Capacites allouees (tas) et index de recherche par identifiant }
 NodeCap, PipeCap, EstCap, EvCap, IvCap, BgCap, BgPtCap : LongInt;
 WorkNodeCap, WorkPipeCap : LongInt;
 HNode          : PIntArr;
 HNodeSize      : LongInt;
 HNodeCnt       : LongInt;
 HNodeOk        : Boolean;
 HPipe          : PIntArr;
 HPipeSize      : LongInt;
 HPipeCnt       : LongInt;
 HPipeOk        : Boolean;
 TraceActive    : Boolean;

 { Vue }
 ViewCX, ViewCY : Real;
 ViewScale      : Real;        { metres par pixel }
 ExtMinX, ExtMinY, ExtMaxX, ExtMaxY : Real;

 { Selection et outils }
 SelKind        : Integer;
 SelIdx         : Integer;
 Tool           : Integer;
 Layers         : Array[0..NLAYERS - 1] Of TLayer;
 OpenSection    : Integer;
 ShowHeader     : Boolean;
 RainI          : Real;        { intensite de pluie de projet (mm/h) }
 StatusMsg      : String[79];
 PendingNode    : Integer;     { premier noeud pour l'outil troncon }
 MeasPts        : Array[0..MAX_MEAS - 1] Of TPt;
 MeasCnt        : Integer;
 MeasLen        : Real;
 CurMapX, CurMapY : Real;      { coordonnees monde du curseur }
 CurOnMap       : Boolean;

 { Boite de dialogue : tampon de liste }
 ListBuf        : PListArr;
 ListCnt        : Integer;

{ ============================================================
  UTILITAIRES DE BASE
  ============================================================ }

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

Function RAbs(A: Real): Real;
Begin If A < 0 Then RAbs := -A Else RAbs := A; End;

Function RPow(X, Y: Real): Real;
Begin
 If X <= 0 Then RPow := 0 Else RPow := Exp(Y * Ln(X));
End;

Function RoundInt(R: Real): Integer;
Begin
 If R > 30000.0 Then RoundInt := 30000
 Else If R < -30000.0 Then RoundInt := -30000
 Else RoundInt := Round(R);
End;

Function IntToStr(N: LongInt): String;
Var S: String;
Begin
 Str(N, S);
 IntToStr := S;
End;

Function RealToStr(R: Real; Width, Prec: Integer): String;
Var S: String;
Begin
 Str(R:Width:Prec, S);
 RealToStr := S;
End;

Function PadRight(S: String; W: Integer): String;
Begin
 While Length(S) < W Do S := S + ' ';
 If Length(S) > W Then S := Copy(S, 1, W);
 PadRight := S;
End;

Function PadLeft(S: String; W: Integer): String;
Begin
 While Length(S) < W Do S := ' ' + S;
 If Length(S) > W Then S := Copy(S, Length(S) - W + 1, W);
 PadLeft := S;
End;

Function UpStr(S: String): String;
Var I: Integer;
Begin
 For I := 1 To Length(S) Do S[I] := UpCase(S[I]);
 UpStr := S;
End;

Function TrimStr(S: String): String;
Begin
 While (Length(S) > 0) And (S[1] <= ' ') Do Delete(S, 1, 1);
 While (Length(S) > 0) And (S[Length(S)] <= ' ') Do Delete(S, Length(S), 1);
 TrimStr := S;
End;

Function StrToIntDef(S: String; Def: LongInt): LongInt;
Var V: LongInt; Code: Integer;
Begin
 S := TrimStr(S);
 Val(S, V, Code);
 If Code <> 0 Then StrToIntDef := Def Else StrToIntDef := V;
End;

Function StrToRealDef(S: String; Def: Real): Real;
Var V: Real; Code: Integer;
Begin
 S := TrimStr(S);
 If S = '' Then Begin StrToRealDef := Def; Exit; End;
 Val(S, V, Code);
 If Code <> 0 Then StrToRealDef := Def Else StrToRealDef := V;
End;

Function ContainsText(Const S, Sub: String): Boolean;
Begin
 If Sub = '' Then ContainsText := True
 Else ContainsText := Pos(UpStr(Sub), UpStr(S)) > 0;
End;

Function GetTimestamp: LongInt;
Var H, M, S, S100: Word;
Begin
 GetTime(H, M, S, S100);
 GetTimestamp := (LongInt(H) * 3600000) + (LongInt(M) * 60000) +
                 (LongInt(S) * 1000) + (LongInt(S100) * 10);
End;

Function TodayStr: String;
Var Y, M, D, DW: Word;
Begin
 GetDate(Y, M, D, DW);
 TodayStr := IntToStr(Y) + '-' + Copy('0' + IntToStr(M), Length(IntToStr(M)), 2) +
             '-' + Copy('0' + IntToStr(D), Length(IntToStr(D)), 2);
End;

Function FmtThousands(N: LongInt): String;
Var S, R: String; I, C: Integer;
Begin
 S := IntToStr(N);
 R := '';
 C := 0;
 For I := Length(S) Downto 1 Do Begin
  R := S[I] + R;
  Inc(C);
  If (C = 3) And (I > 1) Then Begin R := ' ' + R; C := 0; End;
 End;
 FmtThousands := R;
End;

{ Longueur d'un segment }
Function Dist2(X1, Y1, X2, Y2: Real): Real;
Begin
 Dist2 := Sqrt((X2 - X1) * (X2 - X1) + (Y2 - Y1) * (Y2 - Y1));
End;

Function SepChar: Char;
Begin
 {$IFDEF FPC}
  SepChar := DirectorySeparator;
 {$ELSE}
  SepChar := '\';
 {$ENDIF}
End;

Function SamplesDir: String;
Begin
 SamplesDir := 'SAMPLES' + SepChar + 'TIGRE' + SepChar;
End;

{ ============================================================
  DECLARATIONS ANTICIPEES
  ============================================================ }

Procedure RedrawAll; Forward;
Procedure DrawMenuBar; Forward;
Procedure ExecuteMenuItem(Var Item: TMenuItem); Forward;

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

Procedure DrawCenteredText(X1, Y, X2: Integer; Color: Integer; S: String);
Var TX: Integer;
Begin
 TX := X1 + ((X2 - X1) - Length(S) * CHARW) Div 2;
 SetColor(Color);
 OutTextXY(TX, Y, S);
End;

Procedure DrawTextLeft(X, Y, Color: Integer; S: String);
Begin SetColor(Color); OutTextXY(X, Y, S); End;

{ ============================================================
  EVENEMENTS (clavier + souris)
  ============================================================ }

Procedure ClearEvent(Var Ev: TUIEvent);
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

Function IsDoubleClick(X, Y: Integer; Btn: TMouseButton; Now: LongInt): Boolean;
Var DX, DY: Integer;
Begin
 IsDoubleClick := False;
 If (Btn = LastClickBtn) And (LastClickBtn <> MB_NONE) Then Begin
  DX := X - LastClickX; If DX < 0 Then DX := -DX;
  DY := Y - LastClickY; If DY < 0 Then DY := -DY;
  If (DX <= 5) And (DY <= 5) And ((Now - LastClickTime) <= 350) And
     (Now >= LastClickTime) Then
   IsDoubleClick := True;
 End;
End;

Procedure PollEvents(Var Ev: TUIEvent);
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
 Else If (Integer(MX) <> PrevMouseX) Or (Integer(MY) <> PrevMouseY) Then Begin
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
  MENUS DEROULANTS (meme systeme que PARKING.PAS / AIRPORT.PAS)
  ============================================================ }

Procedure InitMenuItem(Var MI: TMenuItem; ACaption: String;
                       AShortCut: String; ATag: LongInt; ASep: Boolean);
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
Var MW, MH, I, SW: Integer;
Begin
 X1 := MainMenuBar.Menus[Idx].X;
 Y1 := MainMenuBar.Height;
 MW := MainMenuBar.Menus[Idx].Width;
 If MW < 160 Then MW := 160;
 MH := 4;
 For I := 0 To MainMenuBar.Menus[Idx].ItemCount - 1 Do
  If MainMenuBar.Menus[Idx].Items[I].Separator Then MH := MH + 8
  Else MH := MH + 16;
 SW := GetMaxX + 1;
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
 Bar(0, MainMenuBar.Y, GetMaxX, MainMenuBar.Y + MainMenuBar.Height - 1);
 SetColor(CLR_BORDER);
 Line(0, MainMenuBar.Y + MainMenuBar.Height - 1,
      GetMaxX, MainMenuBar.Y + MainMenuBar.Height - 1);
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
Begin
 If OpenMenuIdx < 0 Then Exit;
 MX := MainMenuBar.Menus[OpenMenuIdx].X;
 MW := MainMenuBar.Menus[OpenMenuIdx].Width;
 If MW < 160 Then MW := 160;
 MH := 4;
 For I := 0 To MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1 Do
  If MainMenuBar.Menus[OpenMenuIdx].Items[I].Separator Then MH := MH + 8
  Else MH := MH + 16;
 SW := GetMaxX + 1;
 If MX + MW + 2 > SW - 1 Then MX := SW - 1 - MW - 2;
 If MX < 0 Then MX := 0;
 SetFillStyle(SolidFill, CLR_SHADOW);
 Bar(MX + 2, MainMenuBar.Height + 2, MX + MW + 2, MainMenuBar.Height + MH + 2);
 SetFillStyle(SolidFill, LightGray);
 Bar(MX, MainMenuBar.Height, MX + MW, MainMenuBar.Height + MH);
 SetColor(CLR_BORDER);
 Rectangle(MX, MainMenuBar.Height, MX + MW, MainMenuBar.Height + MH);
 YPos := MainMenuBar.Height + 2;
 For I := 0 To MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1 Do Begin
  If MainMenuBar.Menus[OpenMenuIdx].Items[I].Separator Then Begin
   SetColor(CLR_BORDER);
   Line(MX + 2, YPos + 3, MX + MW - 2, YPos + 3);
   YPos := YPos + 8;
  End Else Begin
   If I = SelItemIdx Then Begin
    SetFillStyle(SolidFill, CLR_MENU_HIGHLIGHT);
    Bar(MX + 1, YPos, MX + MW - 1, YPos + 15);
    SetColor(White);
   End Else Begin
    If Not MainMenuBar.Menus[OpenMenuIdx].Items[I].Enabled Then
     SetColor(CLR_BORDER)
    Else SetColor(CLR_MENU_TEXT);
   End;
   If MainMenuBar.Menus[OpenMenuIdx].Items[I].Checked Then
    OutTextXY(MX + 4, YPos + 4, #251);
   OutTextXY(MX + 16, YPos + 4, MainMenuBar.Menus[OpenMenuIdx].Items[I].Caption);
   If Length(MainMenuBar.Menus[OpenMenuIdx].Items[I].ShortCut) > 0 Then Begin
    If I = SelItemIdx Then SetColor(White) Else SetColor(CLR_BORDER);
    OutTextXY(MX + MW - Length(MainMenuBar.Menus[OpenMenuIdx].Items[I].ShortCut) * CHARW - 8,
              YPos + 4, MainMenuBar.Menus[OpenMenuIdx].Items[I].ShortCut);
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
 If (MY < MainMenuBar.Y) Or (MY >= MainMenuBar.Y + MainMenuBar.Height) Then Exit;
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
Begin
 MenuItemHitTest := -1;
 If OpenMenuIdx < 0 Then Exit;
 MW := MainMenuBar.Menus[OpenMenuIdx].Width;
 If MW < 160 Then MW := 160;
 MXOrig := MainMenuBar.Menus[OpenMenuIdx].X;
 SW := GetMaxX + 1;
 If MXOrig + MW + 2 > SW - 1 Then MXOrig := SW - 1 - MW - 2;
 If MXOrig < 0 Then MXOrig := 0;
 If (MX < MXOrig) Or (MX > MXOrig + MW) Then Exit;
 YPos := MainMenuBar.Height + 2;
 For I := 0 To MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1 Do Begin
  If MainMenuBar.Menus[OpenMenuIdx].Items[I].Separator Then YPos := YPos + 8
  Else Begin
   If (MY >= YPos) And (MY < YPos + 16) Then Begin
    If MainMenuBar.Menus[OpenMenuIdx].Items[I].Enabled Then MenuItemHitTest := I;
    Exit;
   End;
   YPos := YPos + 16;
  End;
 End;
End;

Procedure HandleMenuEvent(Var Ev: TUIEvent);
Var Hit, ItemHit: Integer; MI: TMenuItem;
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
    Hit := OpenMenuIdx;
    MI := MainMenuBar.Menus[Hit].Items[ItemHit];
    CloseMenuBar;
    ExecuteMenuItem(MI);
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
      While (SelItemIdx > 0) And
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
      While (SelItemIdx < MainMenuBar.Menus[OpenMenuIdx].ItemCount - 1) And
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
   { Alt+lettre : ouvrir un menu (codes de balayage BIOS) }
   Case Ev.KeyCode Of
    $21: OpenMenuByIdx(0); { Alt+F : Fichier }
    $2F: OpenMenuByIdx(1); { Alt+V : Vue }
    $18: OpenMenuByIdx(2); { Alt+O : Ouvrages }
    $12: OpenMenuByIdx(3); { Alt+E : Evenements }
    $17: OpenMenuByIdx(4); { Alt+I : Interventions }
    $1E: OpenMenuByIdx(5); { Alt+A : Analyse }
    $2E: OpenMenuByIdx(6); { Alt+C : Carine }
    $23: OpenMenuByIdx(7); { Alt+H : Aide }
   End;
  End;
 End
 Else If Ev.Kind = EV_KEY_CHAR Then Begin
  If MenuActive Then Begin
   Case Ev.KeyChar Of
    #13: Begin
     If (SelItemIdx >= 0) And (OpenMenuIdx >= 0) Then Begin
      Hit := OpenMenuIdx; ItemHit := SelItemIdx;
      MI := MainMenuBar.Menus[Hit].Items[ItemHit];
      CloseMenuBar;
      If MI.Enabled Then ExecuteMenuItem(MI);
     End;
    End;
    #27: CloseMenuBar;
   End;
  End;
 End;
End;

{ ============================================================
  FRAMEWORK DE DIALOGUES MODALES
  Etiquettes, champs, boutons, cases, listes. Tab = champ suivant,
  Entree = bouton par defaut (Tag=1), Echap = annuler (Tag=-1).
  ============================================================ }

Const
 CT_LABEL    = 1;
 CT_EDIT     = 2;
 CT_BUTTON   = 3;
 CT_CHECK    = 4;
 CT_RADIO    = 5;
 CT_LIST     = 6;
 CT_FRAME    = 7;
 CT_HLINE    = 8;

 MAX_CTRLS   = 36;
 DLG_TITLE_H = 18;

Type
 TControl = Record
  Kind     : Byte;
  X, Y     : Integer;
  W, H     : Integer;
  Caption  : TStr79;
  Text     : TStr47;
  MaxLen   : Integer;
  Checked  : Boolean;
  Group    : Integer;
  Tag      : Integer;
  Focusable: Boolean;
  CursorPos: Integer;
  Numeric  : Boolean;
  HotKey   : Char;
  ListSel  : Integer;
  ListTop  : Integer;
 End;

 TDialog = Record
  Title    : TStr47;
  X1, Y1, X2, Y2 : Integer;
  CtrlCount: Integer;
  Ctrls    : Array[0..MAX_CTRLS - 1] Of TControl;
  Focus    : Integer;
  Result   : Integer;
  DefaultBtn : Integer;
  CancelBtn  : Integer;
 End;

Var
 Dlg : TDialog;

Procedure DlgInit(Var D: TDialog; ATitle: String; W, H: Integer);
Begin
 D.Title := ATitle;
 If W > SCREEN_W - 8 Then W := SCREEN_W - 8;
 If H > SCREEN_H - 8 Then H := SCREEN_H - 8;
 D.X1 := (SCREEN_W - W) Div 2;
 D.Y1 := (SCREEN_H - H) Div 2;
 D.X2 := D.X1 + W;
 D.Y2 := D.Y1 + H;
 D.CtrlCount := 0;
 D.Focus := -1;
 D.Result := 0;
 D.DefaultBtn := -1;
 D.CancelBtn := -1;
End;

Function DlgAdd(Var D: TDialog): Integer;
Begin
 If D.CtrlCount >= MAX_CTRLS Then Begin
  DlgAdd := MAX_CTRLS - 1; Exit;
 End;
 DlgAdd := D.CtrlCount;
 With D.Ctrls[D.CtrlCount] Do Begin
  Kind := CT_LABEL;
  X := 0; Y := 0; W := 0; H := 0;
  Caption := ''; Text := '';
  MaxLen := 0; Checked := False; Group := 0; Tag := 0;
  Focusable := False;
  CursorPos := 0; Numeric := False;
  HotKey := #0; ListSel := 0; ListTop := 0;
 End;
 Inc(D.CtrlCount);
End;

Function DlgAddLabel(Var D: TDialog; AX, AY: Integer; ACaption: String): Integer;
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

Function DlgAddFrame(Var D: TDialog; AX, AY, AW, AH: Integer; ACaption: String): Integer;
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

Function DlgAddEdit(Var D: TDialog; AX, AY, AW: Integer; AText: String;
                    AMaxLen: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_EDIT;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 14;
 D.Ctrls[I].Text := AText;
 D.Ctrls[I].MaxLen := AMaxLen;
 D.Ctrls[I].Focusable := True;
 D.Ctrls[I].CursorPos := Length(D.Ctrls[I].Text);
 DlgAddEdit := I;
End;

Function DlgAddNumEdit(Var D: TDialog; AX, AY, AW: Integer; AText: String;
                       AMaxLen: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAddEdit(D, AX, AY, AW, AText, AMaxLen);
 D.Ctrls[I].Numeric := True;
 DlgAddNumEdit := I;
End;

Function DlgAddButton(Var D: TDialog; AX, AY, AW: Integer; ACaption: String;
                      ATag: Integer; AHotKey: Char): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_BUTTON;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 20;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Tag := ATag;
 D.Ctrls[I].Focusable := True;
 D.Ctrls[I].HotKey := UpCase(AHotKey);
 If ATag = 1 Then D.DefaultBtn := I;
 If ATag = -1 Then D.CancelBtn := I;
 DlgAddButton := I;
End;

Function DlgAddCheck(Var D: TDialog; AX, AY, AW: Integer; ACaption: String;
                     AChecked: Boolean): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_CHECK;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 12;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Checked := AChecked;
 D.Ctrls[I].Focusable := True;
 DlgAddCheck := I;
End;

Function DlgAddRadio(Var D: TDialog; AX, AY, AW: Integer; ACaption: String;
                     AGroup: Integer; AChecked: Boolean): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_RADIO;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := 12;
 D.Ctrls[I].Caption := ACaption;
 D.Ctrls[I].Group := AGroup;
 D.Ctrls[I].Checked := AChecked;
 D.Ctrls[I].Focusable := True;
 DlgAddRadio := I;
End;

{ Liste : le contenu se trouve dans ListBuf^[0..ListCnt-1] }
Function DlgAddList(Var D: TDialog; AX, AY, AW, AH: Integer): Integer;
Var I: Integer;
Begin
 I := DlgAdd(D);
 D.Ctrls[I].Kind := CT_LIST;
 D.Ctrls[I].X := AX; D.Ctrls[I].Y := AY;
 D.Ctrls[I].W := AW; D.Ctrls[I].H := AH;
 D.Ctrls[I].ListSel := 0;
 D.Ctrls[I].ListTop := 0;
 D.Ctrls[I].Focusable := True;
 DlgAddList := I;
End;

Procedure ListClear;
Begin
 ListCnt := 0;
End;

Procedure ListAdd(S: String);
Begin
 If ListCnt < MAX_LISTITEMS Then Begin
  ListBuf^[ListCnt] := S;
  Inc(ListCnt);
 End;
End;

Function DlgRadioValue(Var D: TDialog; First, Count: Integer): Integer;
Var I: Integer;
Begin
 DlgRadioValue := 0;
 For I := 0 To Count - 1 Do
  If D.Ctrls[First + I].Checked Then DlgRadioValue := I;
End;

Procedure DlgSelectRadio(Var D: TDialog; Idx: Integer);
Var I: Integer;
Begin
 For I := 0 To D.CtrlCount - 1 Do
  If (D.Ctrls[I].Kind = CT_RADIO) And (D.Ctrls[I].Group = D.Ctrls[Idx].Group) Then
   D.Ctrls[I].Checked := (I = Idx);
End;

Function ListRows(Var C: TControl): Integer;
Begin
 ListRows := (C.H - 4) Div 10;
End;

Procedure DlgDraw(Var D: TDialog);
Var
 I, X, Y, W, H, Off, Vis, R, SX, TH, TY: Integer;
 S: String;
Begin
 DrawShadow(D.X1, D.Y1, D.X2, D.Y2);
 DrawBox3D(D.X1, D.Y1, D.X2, D.Y2, True, LightGray);
 FillRect(D.X1 + 3, D.Y1 + 3, D.X2 - 3, D.Y1 + DLG_TITLE_H - 2, Blue);
 SetColor(White);
 OutTextXY(D.X1 + 8, D.Y1 + 6, D.Title);
 For I := 0 To D.CtrlCount - 1 Do Begin
  X := D.X1 + D.Ctrls[I].X;
  Y := D.Y1 + DLG_TITLE_H + D.Ctrls[I].Y;
  W := D.Ctrls[I].W;
  H := D.Ctrls[I].H;
  Case D.Ctrls[I].Kind Of
   CT_LABEL: Begin
    SetColor(Black);
    OutTextXY(X, Y, D.Ctrls[I].Caption);
   End;
   CT_FRAME: Begin
    DrawRect(X, Y + 4, X + W, Y + H, CLR_BORDER);
    DrawRect(X + 1, Y + 5, X + W + 1, Y + H + 1, White);
    If D.Ctrls[I].Caption <> '' Then Begin
     FillRect(X + 6, Y, X + 12 + Length(D.Ctrls[I].Caption) * CHARW, Y + 8, LightGray);
     SetColor(Black);
     OutTextXY(X + 9, Y, D.Ctrls[I].Caption);
    End;
   End;
   CT_HLINE: Begin
    DrawHLine(X, X + W, Y, CLR_BORDER);
    DrawHLine(X, X + W, Y + 1, White);
   End;
   CT_EDIT: Begin
    DrawBox3D(X, Y, X + W, Y + H, False, White);
    Vis := (W - 8) Div CHARW;
    Off := 0;
    If D.Ctrls[I].CursorPos > (W - 6) Div CHARW Then Off := D.Ctrls[I].CursorPos - (W - 6) Div CHARW;
    S := Copy(D.Ctrls[I].Text, Off + 1, Vis);
    SetColor(Black);
    OutTextXY(X + 4, Y + 4, S);
    If I = D.Focus Then Begin
     SX := X + 4 + (D.Ctrls[I].CursorPos - Off) * CHARW;
     DrawVLine(SX, Y + 2, Y + H - 2, Black);
    End;
   End;
   CT_BUTTON: Begin
    DrawBox3D(X, Y, X + W, Y + H, True, LightGray);
    If I = D.DefaultBtn Then DrawRect(X - 1, Y - 1, X + W + 1, Y + H + 1, Black);
    DrawCenteredText(X, Y + 6, X + W, Black, D.Ctrls[I].Caption);
    If I = D.Focus Then DrawRect(X + 3, Y + 3, X + W - 3, Y + H - 3, Blue);
   End;
   CT_CHECK: Begin
    DrawBox3D(X, Y, X + 11, Y + 11, False, White);
    If D.Ctrls[I].Checked Then Begin
     SetColor(Black);
     Line(X + 2, Y + 2, X + 9, Y + 9);
     Line(X + 2, Y + 9, X + 9, Y + 2);
    End;
    SetColor(Black);
    OutTextXY(X + 16, Y + 2, D.Ctrls[I].Caption);
    If I = D.Focus Then
     DrawRect(X + 13, Y - 1, X + 17 + Length(D.Ctrls[I].Caption) * CHARW, Y + 12, Blue);
   End;
   CT_RADIO: Begin
    SetColor(CLR_BORDER);
    Circle(X + 5, Y + 5, 5);
    SetFillStyle(SolidFill, White);
    FloodFill(X + 5, Y + 5, CLR_BORDER);
    If D.Ctrls[I].Checked Then Begin
     SetFillStyle(SolidFill, Black);
     FillEllipse(X + 5, Y + 5, 2, 2);
    End;
    SetColor(Black);
    OutTextXY(X + 16, Y + 2, D.Ctrls[I].Caption);
    If I = D.Focus Then
     DrawRect(X + 13, Y - 1, X + 17 + Length(D.Ctrls[I].Caption) * CHARW, Y + 12, Blue);
   End;
   CT_LIST: Begin
    DrawBox3D(X, Y, X + W, Y + H, False, White);
    Vis := ListRows(D.Ctrls[I]);
    For R := 0 To Vis - 1 Do Begin
     If D.Ctrls[I].ListTop + R < ListCnt Then Begin
      TY := Y + 3 + R * 10;
      If D.Ctrls[I].ListTop + R = D.Ctrls[I].ListSel Then Begin
       FillRect(X + 2, TY - 1, X + W - 12, TY + 8, Blue);
       SetColor(White);
      End Else SetColor(Black);
      OutTextXY(X + 4, TY, Copy(ListBuf^[D.Ctrls[I].ListTop + R], 1, (W - 18) Div CHARW));
     End;
    End;
    { ascenseur }
    FillRect(X + W - 10, Y + 2, X + W - 2, Y + H - 2, LightGray);
    If ListCnt > Vis Then Begin
     TH := ((H - 8) * Vis) Div ListCnt;
     If TH < 6 Then TH := 6;
     TY := Y + 4 + ((H - 8 - TH) * D.Ctrls[I].ListTop) Div (ListCnt - Vis);
     DrawBox3D(X + W - 10, TY, X + W - 2, TY + TH, True, LightGray);
    End;
    If I = D.Focus Then DrawRect(X - 1, Y - 1, X + W + 1, Y + H + 1, Blue);
   End;
  End;
 End;
End;

Function DlgFirstFocus(Var D: TDialog): Integer;
Var I: Integer;
Begin
 DlgFirstFocus := -1;
 For I := 0 To D.CtrlCount - 1 Do
  If D.Ctrls[I].Focusable And (D.Ctrls[I].Kind <> CT_BUTTON) Then Begin
   DlgFirstFocus := I;
   Exit;
  End;
 DlgFirstFocus := D.DefaultBtn;
End;

Procedure DlgMoveFocus(Var D: TDialog; Dir: Integer);
Var I, N: Integer;
Begin
 If D.CtrlCount = 0 Then Exit;
 I := D.Focus;
 For N := 1 To D.CtrlCount Do Begin
  I := I + Dir;
  If I >= D.CtrlCount Then I := 0;
  If I < 0 Then I := D.CtrlCount - 1;
  If D.Ctrls[I].Focusable Then Begin
   D.Focus := I;
   Exit;
  End;
 End;
End;

Function DlgHitTest(Var D: TDialog; MX, MY: Integer): Integer;
Var I, X, Y: Integer;
Begin
 DlgHitTest := -1;
 For I := D.CtrlCount - 1 Downto 0 Do Begin
  If D.Ctrls[I].Focusable Then Begin
   X := D.X1 + D.Ctrls[I].X;
   Y := D.Y1 + DLG_TITLE_H + D.Ctrls[I].Y;
   If (MX >= X) And (MX <= X + D.Ctrls[I].W) And
      (MY >= Y) And (MY <= Y + D.Ctrls[I].H) Then Begin
    DlgHitTest := I;
    Exit;
   End;
  End;
 End;
End;

Procedure DlgListEnsureVisible(Var C: TControl);
Var Vis: Integer;
Begin
 Vis := ListRows(C);
 If C.ListSel < 0 Then C.ListSel := 0;
 If C.ListSel > ListCnt - 1 Then C.ListSel := ListCnt - 1;
 If C.ListSel < 0 Then C.ListSel := 0;
 If C.ListSel < C.ListTop Then C.ListTop := C.ListSel;
 If C.ListSel >= C.ListTop + Vis Then C.ListTop := C.ListSel - Vis + 1;
 If C.ListTop < 0 Then C.ListTop := 0;
End;

Procedure DlgEditChar(Var C: TControl; Ch: Char);
Begin
 If C.Numeric Then Begin
  If Ch = ',' Then Ch := '.';
  If Not (Ch In ['0'..'9', '-', '.']) Then Exit;
 End;
 If (Ch >= ' ') And (Length(C.Text) < C.MaxLen) Then Begin
  Insert(Ch, C.Text, C.CursorPos + 1);
  Inc(C.CursorPos);
 End;
End;

Function DlgRun(Var D: TDialog): Integer;
Var
 Ev: TUIEvent;
 Done: Boolean;
 Hit, I, RY: Integer;
Begin
 If D.Focus < 0 Then D.Focus := DlgFirstFocus(D);
 DlgDraw(D);
 Done := False;
 Repeat
  PollEvents(Ev);
  If Ev.Kind = EV_NONE Then Delay(8)
  Else Begin
   If Ev.Kind = EV_KEY_CHAR Then Begin
    Case Ev.KeyChar Of
     #13: Begin
      If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_BUTTON) Then Begin
       D.Result := D.Ctrls[D.Focus].Tag; Done := True;
      End Else If D.DefaultBtn >= 0 Then Begin
       D.Result := D.Ctrls[D.DefaultBtn].Tag; Done := True;
      End;
     End;
     #27: Begin
      If D.CancelBtn >= 0 Then D.Result := D.Ctrls[D.CancelBtn].Tag
      Else D.Result := -1;
      Done := True;
     End;
     #9: DlgMoveFocus(D, 1);
     #8: Begin
      If (D.Focus >= 0) And (D.Ctrls[D.Focus].Kind = CT_EDIT) And
         (D.Ctrls[D.Focus].CursorPos > 0) Then Begin
       Delete(D.Ctrls[D.Focus].Text, D.Ctrls[D.Focus].CursorPos, 1);
       Dec(D.Ctrls[D.Focus].CursorPos);
      End;
     End;
    Else Begin
     If D.Focus >= 0 Then Begin
      Case D.Ctrls[D.Focus].Kind Of
       CT_EDIT: DlgEditChar(D.Ctrls[D.Focus], Ev.KeyChar);
       CT_CHECK: If Ev.KeyChar = ' ' Then
                  D.Ctrls[D.Focus].Checked := Not D.Ctrls[D.Focus].Checked;
       CT_RADIO: If Ev.KeyChar = ' ' Then DlgSelectRadio(D, D.Focus);
       CT_BUTTON: If Ev.KeyChar = ' ' Then Begin
                   D.Result := D.Ctrls[D.Focus].Tag; Done := True;
                  End;
      End;
      If D.Ctrls[D.Focus].Kind <> CT_EDIT Then Begin
       For I := 0 To D.CtrlCount - 1 Do
        If (D.Ctrls[I].Kind = CT_BUTTON) And (D.Ctrls[I].HotKey <> #0) And
           (D.Ctrls[I].HotKey = UpCase(Ev.KeyChar)) Then Begin
         D.Result := D.Ctrls[I].Tag;
         Done := True;
        End;
      End;
     End;
    End;
    End;
   End
   Else If Ev.Kind = EV_KEY_DOWN Then Begin
    If D.Focus >= 0 Then Begin
     Case Ev.KeyCode Of
      15: DlgMoveFocus(D, -1);
      72: Begin
       Case D.Ctrls[D.Focus].Kind Of
        CT_LIST: Begin Dec(D.Ctrls[D.Focus].ListSel); DlgListEnsureVisible(D.Ctrls[D.Focus]); End;
        CT_RADIO: Begin
         DlgMoveFocus(D, -1);
         If D.Ctrls[D.Focus].Kind = CT_RADIO Then DlgSelectRadio(D, D.Focus);
        End;
       Else DlgMoveFocus(D, -1);
       End;
      End;
      80: Begin
       Case D.Ctrls[D.Focus].Kind Of
        CT_LIST: Begin Inc(D.Ctrls[D.Focus].ListSel); DlgListEnsureVisible(D.Ctrls[D.Focus]); End;
        CT_RADIO: Begin
         DlgMoveFocus(D, 1);
         If D.Ctrls[D.Focus].Kind = CT_RADIO Then DlgSelectRadio(D, D.Focus);
        End;
       Else DlgMoveFocus(D, 1);
       End;
      End;
      73: If D.Ctrls[D.Focus].Kind = CT_LIST Then Begin
           Dec(D.Ctrls[D.Focus].ListSel, ListRows(D.Ctrls[D.Focus]));
           DlgListEnsureVisible(D.Ctrls[D.Focus]);
          End;
      81: If D.Ctrls[D.Focus].Kind = CT_LIST Then Begin
           Inc(D.Ctrls[D.Focus].ListSel, ListRows(D.Ctrls[D.Focus]));
           DlgListEnsureVisible(D.Ctrls[D.Focus]);
          End;
      71: Begin
       If D.Ctrls[D.Focus].Kind = CT_EDIT Then D.Ctrls[D.Focus].CursorPos := 0
       Else If D.Ctrls[D.Focus].Kind = CT_LIST Then Begin
        D.Ctrls[D.Focus].ListSel := 0; DlgListEnsureVisible(D.Ctrls[D.Focus]);
       End;
      End;
      79: Begin
       If D.Ctrls[D.Focus].Kind = CT_EDIT Then
        D.Ctrls[D.Focus].CursorPos := Length(D.Ctrls[D.Focus].Text)
       Else If D.Ctrls[D.Focus].Kind = CT_LIST Then Begin
        D.Ctrls[D.Focus].ListSel := ListCnt - 1; DlgListEnsureVisible(D.Ctrls[D.Focus]);
       End;
      End;
      75: Begin
       If D.Ctrls[D.Focus].Kind = CT_EDIT Then Begin
        If D.Ctrls[D.Focus].CursorPos > 0 Then Dec(D.Ctrls[D.Focus].CursorPos);
       End Else If D.Ctrls[D.Focus].Kind = CT_RADIO Then Begin
        DlgMoveFocus(D, -1);
        If D.Ctrls[D.Focus].Kind = CT_RADIO Then DlgSelectRadio(D, D.Focus);
       End;
      End;
      77: Begin
       If D.Ctrls[D.Focus].Kind = CT_EDIT Then Begin
        If D.Ctrls[D.Focus].CursorPos < Length(D.Ctrls[D.Focus].Text) Then
         Inc(D.Ctrls[D.Focus].CursorPos);
       End Else If D.Ctrls[D.Focus].Kind = CT_RADIO Then Begin
        DlgMoveFocus(D, 1);
        If D.Ctrls[D.Focus].Kind = CT_RADIO Then DlgSelectRadio(D, D.Focus);
       End;
      End;
      83: If D.Ctrls[D.Focus].Kind = CT_EDIT Then
           If D.Ctrls[D.Focus].CursorPos < Length(D.Ctrls[D.Focus].Text) Then
            Delete(D.Ctrls[D.Focus].Text, D.Ctrls[D.Focus].CursorPos + 1, 1);
     End;
    End;
   End
   Else If (Ev.Kind = EV_MOUSE_DOWN) Or (Ev.Kind = EV_MOUSE_DBLCLICK) Then Begin
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
      CT_LIST: Begin
       RY := (Ev.MouseY - (D.Y1 + DLG_TITLE_H + D.Ctrls[Hit].Y) - 3) Div 10;
       If (RY >= 0) And (D.Ctrls[Hit].ListTop + RY < ListCnt) Then
        D.Ctrls[Hit].ListSel := D.Ctrls[Hit].ListTop + RY;
       If (Ev.Kind = EV_MOUSE_DBLCLICK) And (D.DefaultBtn >= 0) Then Begin
        D.Result := D.Ctrls[D.DefaultBtn].Tag;
        Done := True;
       End;
      End;
      CT_EDIT: Begin
       I := (Ev.MouseX - (D.X1 + D.Ctrls[Hit].X) - 4) Div CHARW;
       D.Ctrls[Hit].CursorPos := IClamp(I, 0, Length(D.Ctrls[Hit].Text));
      End;
     End;
    End;
   End;
   If Not Done Then DlgDraw(D);
  End;
 Until Done;
 DlgRun := D.Result;
 RedrawAll;
End;

{ ============================================================
  DIALOGUES STANDARD : message, confirmation, saisie, liste
  ============================================================ }

Type
 TLines = Array[0..15] Of TStr79;

Procedure WrapMessage(Msg: String; MaxChars: Integer; Var Lines: TLines;
                      Var Count: Integer);
Var I, K, LastSpace: Integer; Cur: String; Ch: Char;
Begin
 Count := 0;
 Cur := '';
 I := 1;
 While I <= Length(Msg) Do Begin
  Ch := Msg[I];
  If (Ch = #10) Or (Ch = #13) Then Begin
   If Count <= 15 Then Begin Lines[Count] := Cur; Inc(Count); End;
   Cur := '';
   If (Ch = #13) And (I < Length(Msg)) And (Msg[I + 1] = #10) Then Inc(I);
  End Else Begin
   Cur := Cur + Ch;
   If Length(Cur) >= MaxChars Then Begin
    LastSpace := 0;
    For K := Length(Cur) Downto 1 Do
     If Cur[K] = ' ' Then Begin LastSpace := K; Break; End;
    If LastSpace > 0 Then Begin
     If Count <= 15 Then Begin Lines[Count] := Copy(Cur, 1, LastSpace - 1); Inc(Count); End;
     Cur := Copy(Cur, LastSpace + 1, Length(Cur) - LastSpace);
    End Else Begin
     If Count <= 15 Then Begin Lines[Count] := Cur; Inc(Count); End;
     Cur := '';
    End;
   End;
  End;
  Inc(I);
 End;
 If (Cur <> '') And (Count <= 15) Then Begin
  Lines[Count] := Cur; Inc(Count);
 End;
 If Count = 0 Then Begin Lines[0] := ''; Count := 1; End;
End;

Procedure ShowMessageBox(Title, Msg: String);
Var W, H, I, MaxLine: Integer; Lines: TLines; LineCount: Integer;
Begin
 WrapMessage(Msg, 54, Lines, LineCount);
 MaxLine := 0;
 For I := 0 To LineCount - 1 Do
  If Length(Lines[I]) > MaxLine Then MaxLine := Length(Lines[I]);
 W := IMax(260, MaxLine * CHARW + 40);
 H := DLG_TITLE_H + 20 + LineCount * (CHARH + 4) + 40;
 DlgInit(Dlg, Title, W, H);
 For I := 0 To LineCount - 1 Do
  DlgAddLabel(Dlg, 16, 10 + I * (CHARH + 4), Lines[I]);
 DlgAddButton(Dlg, (W - 70) Div 2, H - DLG_TITLE_H - 32, 70, 'OK', 1, 'O');
 DlgRun(Dlg);
End;

Function ShowConfirmBox(Title, Msg: String): Boolean;
Var W, H, I, MaxLine, R: Integer; Lines: TLines; LineCount: Integer;
Begin
 WrapMessage(Msg, 54, Lines, LineCount);
 MaxLine := 0;
 For I := 0 To LineCount - 1 Do
  If Length(Lines[I]) > MaxLine Then MaxLine := Length(Lines[I]);
 W := IMax(280, MaxLine * CHARW + 40);
 H := DLG_TITLE_H + 20 + LineCount * (CHARH + 4) + 40;
 DlgInit(Dlg, Title, W, H);
 For I := 0 To LineCount - 1 Do
  DlgAddLabel(Dlg, 16, 10 + I * (CHARH + 4), Lines[I]);
 DlgAddButton(Dlg, (W Div 2) - 80, H - DLG_TITLE_H - 32, 70, 'Oui', 1, 'O');
 DlgAddButton(Dlg, (W Div 2) + 10, H - DLG_TITLE_H - 32, 70, 'Non', -1, 'N');
 R := DlgRun(Dlg);
 ShowConfirmBox := (R = 1);
End;

Function ShowInputBox(Title, Prompt: String; Var Value: String;
                      MaxLen: Integer): Boolean;
Var R, IE: Integer;
Begin
 DlgInit(Dlg, Title, 360, 120);
 DlgAddLabel(Dlg, 14, 8, Prompt);
 IE := DlgAddEdit(Dlg, 14, 26, 330, Value, MaxLen);
 DlgAddButton(Dlg, 100, 58, 70, 'OK', 1, 'O');
 DlgAddButton(Dlg, 190, 58, 70, 'Annuler', -1, 'A');
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  Value := Dlg.Ctrls[IE].Text;
  ShowInputBox := True;
 End Else ShowInputBox := False;
End;

{ Selection dans une liste (ListBuf doit etre rempli).
  Retourne True si OK, Sel recoit l'indice choisi. }
Function DlgPickList(Title, Prompt: String; W, H: Integer; Var Sel: Integer;
                     OkCap, CancelCap: String): Boolean;
Var R, L, BY: Integer;
Begin
 DlgInit(Dlg, Title, W, H);
 BY := H - DLG_TITLE_H - 30;
 If Prompt <> '' Then DlgAddLabel(Dlg, 10, 6, Prompt);
 L := DlgAddList(Dlg, 10, 20, W - 20, BY - 28);
 Dlg.Ctrls[L].ListSel := IClamp(Sel, 0, IMax(ListCnt - 1, 0));
 DlgListEnsureVisible(Dlg.Ctrls[L]);
 DlgAddButton(Dlg, (W Div 2) - 100, BY, 90, OkCap, 1, #0);
 If CancelCap <> '' Then DlgAddButton(Dlg, (W Div 2) + 10, BY, 90, CancelCap, -1, #0);
 Dlg.Focus := L;
 R := DlgRun(Dlg);
 Sel := Dlg.Ctrls[L].ListSel;
 DlgPickList := (R = 1) And (ListCnt > 0);
End;

{ Affichage d'un rapport texte (lecture seule) }
Procedure ShowReport(Title: String);
Var Sel: Integer;
Begin
 Sel := 0;
 DlgPickList(Title, '', 600, 340, Sel, 'Fermer', '');
End;

{ ============================================================
  DONNEES : allocation, hydraulique, lecture / ecriture
  ============================================================ }

{ Agrandit un tableau du tas pour contenir au moins Need elements.
  Renvoie False si la borne MaxCnt est depassee ou si la memoire manque
  (le tableau reste alors inchange). Turbo Pascal 7 : allocation fixe. }
Type
 PPtrRef = ^Pointer;

Function GrowBuf(Var P; Var Cap: LongInt; Need, ElemSize, MaxCnt: LongInt): Boolean;
Var
 NewCap: LongInt;
 Q: Pointer;
Begin
 GrowBuf := False;
 If Need > MaxCnt Then Exit;
 If Need <= Cap Then Begin GrowBuf := True; Exit; End;
 {$IFDEF FPC}
 NewCap := Cap + Cap Div 2;
 If NewCap < 1024 Then NewCap := 1024;
 If NewCap < Need Then NewCap := Need;
 If NewCap > MaxCnt Then NewCap := MaxCnt;
 If Int64(NewCap) * ElemSize > 1900000000 Then Exit;
 Q := PPtrRef(@P)^;
 ReAllocMem(Q, NewCap * ElemSize);
 If Q = Nil Then Exit;
 PPtrRef(@P)^ := Q;
 {$ELSE}
 NewCap := MaxCnt;
 If NewCap * ElemSize > 65000 Then Exit;
 GetMem(Q, NewCap * ElemSize);
 PPtrRef(@P)^ := Q;
 {$ENDIF}
 Cap := NewCap;
 GrowBuf := True;
End;

{ Tableaux de travail (adjacence, traces) : suivent la capacite des ouvrages }
Procedure EnsureWork;
Var Old: LongInt; Ok: Boolean;
Begin
 Old := WorkNodeCap;
 Ok := GrowBuf(FirstOut, WorkNodeCap, NodeCap, SizeOf(LongInt), MAX_NODES);
 WorkNodeCap := Old;
 Ok := Ok And GrowBuf(FirstIn, WorkNodeCap, NodeCap, SizeOf(LongInt), MAX_NODES);
 WorkNodeCap := Old;
 Ok := Ok And GrowBuf(TraceNode, WorkNodeCap, NodeCap, SizeOf(Boolean), MAX_NODES);
 If Ok And (WorkNodeCap > Old) Then FillChar(TraceNode^[Old], WorkNodeCap - Old, 0);
 Old := WorkPipeCap;
 Ok := GrowBuf(NextOut, WorkPipeCap, PipeCap, SizeOf(LongInt), MAX_PIPES);
 WorkPipeCap := Old;
 Ok := Ok And GrowBuf(NextIn, WorkPipeCap, PipeCap, SizeOf(LongInt), MAX_PIPES);
 WorkPipeCap := Old;
 Ok := Ok And GrowBuf(TracePipe, WorkPipeCap, PipeCap, SizeOf(Boolean), MAX_PIPES);
 If Ok And (WorkPipeCap > Old) Then FillChar(TracePipe^[Old], WorkPipeCap - Old, 0);
End;

Function GrowNodes(Need: LongInt): Boolean;
Begin
 GrowNodes := GrowBuf(Nodes, NodeCap, Need, SizeOf(TNode), MAX_NODES);
 If GrowNodes Then EnsureWork;
End;

Function GrowPipes(Need: LongInt): Boolean;
Begin
 GrowPipes := GrowBuf(Pipes, PipeCap, Need, SizeOf(TPipe), MAX_PIPES);
 If GrowPipes Then EnsureWork;
End;

Function GrowEstabs(Need: LongInt): Boolean;
Begin
 GrowEstabs := GrowBuf(Estabs, EstCap, Need, SizeOf(TEstab), MAX_ESTAB);
End;

Function GrowEvents(Need: LongInt): Boolean;
Begin
 GrowEvents := GrowBuf(Events, EvCap, Need, SizeOf(TEvent), MAX_EVENTS);
End;

Function GrowIntervs(Need: LongInt): Boolean;
Begin
 GrowIntervs := GrowBuf(Intervs, IvCap, Need, SizeOf(TInterv), MAX_INTERV);
End;

Function GrowBgs(Need: LongInt): Boolean;
Begin
 GrowBgs := GrowBuf(Bgs, BgCap, Need, SizeOf(TBgLine), MAX_BG);
End;

Function GrowBgPts(Need: LongInt): Boolean;
Begin
 GrowBgPts := GrowBuf(BgPts, BgPtCap, Need, SizeOf(TPt), MAX_BGPTS);
End;

Procedure AllocData;
Begin
 Nodes := Nil; Pipes := Nil; Estabs := Nil; Events := Nil;
 Intervs := Nil; Bgs := Nil; BgPts := Nil;
 FirstOut := Nil; FirstIn := Nil; NextOut := Nil; NextIn := Nil;
 TraceNode := Nil; TracePipe := Nil;
 NodeCap := 0; PipeCap := 0; EstCap := 0; EvCap := 0; IvCap := 0;
 BgCap := 0; BgPtCap := 0; WorkNodeCap := 0; WorkPipeCap := 0;
 HNode := Nil; HNodeSize := 0; HNodeCnt := 0; HNodeOk := False;
 HPipe := Nil; HPipeSize := 0; HPipeCnt := 0; HPipeOk := False;
 If Not (GrowNodes(1) And GrowPipes(1) And GrowEstabs(1) And GrowEvents(1) And
         GrowIntervs(1) And GrowBgs(1) And GrowBgPts(1)) Then Begin
  WriteLn('Memoire insuffisante.');
  Halt(1);
 End;
 New(ListBuf);
End;

Procedure ClearTrace;
Begin
 If WorkNodeCap > 0 Then FillChar(TraceNode^[0], WorkNodeCap, 0);
 If WorkPipeCap > 0 Then FillChar(TracePipe^[0], WorkPipeCap, 0);
 TraceActive := False;
End;

Procedure ClearSelection;
Var I: Integer;
Begin
 For I := 0 To NodeCnt - 1 Do Nodes^[I].Sel := False;
 For I := 0 To PipeCnt - 1 Do Pipes^[I].Sel := False;
 SelKind := SEL_NONE;
 SelIdx := -1;
End;

Procedure ClearData;
Var I: Integer;
Begin
 NodeCnt := 0; PipeCnt := 0; EstCnt := 0; EvCnt := 0; IvCnt := 0;
 BgCnt := 0; BgPtCnt := 0; SectorCnt := 0;
 HNodeOk := False; HPipeOk := False;
 For I := 0 To MAX_SECTORS - 1 Do SectorName[I] := '';
 PlanTitle := ''; PlanOrg := 'TIGRE';
 ClearTrace;
 SelKind := SEL_NONE; SelIdx := -1;
 PendingNode := -1;
 MeasCnt := 0; MeasLen := 0;
 PlanDirty := False;
End;

Function PadZero(N: LongInt; W: Integer): String;
Var S: String;
Begin
 S := IntToStr(N);
 While Length(S) < W Do S := '0' + S;
 PadZero := S;
End;

{$IFDEF FPC}
Function HashId(Const U: String): LongInt;
Var I: Integer; H: Int64;
Begin
 H := 2166136261;
 For I := 1 To Length(U) Do H := ((H Xor Ord(U[I])) * 16777619) And $FFFFFFFF;
 HashId := LongInt(H And $7FFFFFFF);
End;

{ Index de hachage (adressage ouvert) des identifiants, reconstruit a la
  demande des que le plan a change. Une entree vaut indice + 1, 0 = vide. }
Procedure RebuildNodeIndex;
Var I, Slot: LongInt; U: String; Dup: Boolean;
Begin
 If HNode <> Nil Then FreeMem(HNode);
 HNodeSize := 1024;
 While HNodeSize < 2 * NodeCnt + 16 Do HNodeSize := HNodeSize * 2;
 GetMem(HNode, HNodeSize * SizeOf(LongInt));
 FillChar(HNode^, HNodeSize * SizeOf(LongInt), 0);
 For I := 0 To NodeCnt - 1 Do Begin
  U := UpStr(TrimStr(Nodes^[I].Id));
  Slot := HashId(U) And (HNodeSize - 1);
  Dup := False;
  While HNode^[Slot] <> 0 Do Begin
   If UpStr(Nodes^[HNode^[Slot] - 1].Id) = U Then Begin Dup := True; Break; End;
   Slot := (Slot + 1) And (HNodeSize - 1);
  End;
  If Not Dup Then HNode^[Slot] := I + 1;
 End;
 HNodeCnt := NodeCnt;
 HNodeOk := True;
End;

Procedure RebuildPipeIndex;
Var I, Slot: LongInt; U: String; Dup: Boolean;
Begin
 If HPipe <> Nil Then FreeMem(HPipe);
 HPipeSize := 1024;
 While HPipeSize < 2 * PipeCnt + 16 Do HPipeSize := HPipeSize * 2;
 GetMem(HPipe, HPipeSize * SizeOf(LongInt));
 FillChar(HPipe^, HPipeSize * SizeOf(LongInt), 0);
 For I := 0 To PipeCnt - 1 Do Begin
  U := UpStr(TrimStr(Pipes^[I].Id));
  Slot := HashId(U) And (HPipeSize - 1);
  Dup := False;
  While HPipe^[Slot] <> 0 Do Begin
   If UpStr(Pipes^[HPipe^[Slot] - 1].Id) = U Then Begin Dup := True; Break; End;
   Slot := (Slot + 1) And (HPipeSize - 1);
  End;
  If Not Dup Then HPipe^[Slot] := I + 1;
 End;
 HPipeCnt := PipeCnt;
 HPipeOk := True;
End;
{$ENDIF}

Function FindNodeById(Const Id: String): Integer;
Var I: Integer; U: String;
Begin
 FindNodeById := -1;
 U := UpStr(TrimStr(Id));
 {$IFDEF FPC}
 If (Not HNodeOk) Or (HNodeCnt <> NodeCnt) Then RebuildNodeIndex;
 I := HashId(U) And (HNodeSize - 1);
 While HNode^[I] <> 0 Do Begin
  If UpStr(Nodes^[HNode^[I] - 1].Id) = U Then Begin
   FindNodeById := HNode^[I] - 1;
   Exit;
  End;
  I := (I + 1) And (HNodeSize - 1);
 End;
 {$ELSE}
 For I := 0 To NodeCnt - 1 Do
  If UpStr(Nodes^[I].Id) = U Then Begin
   FindNodeById := I;
   Exit;
  End;
 {$ENDIF}
End;

Function FindPipeById(Const Id: String): Integer;
Var I: Integer; U: String;
Begin
 FindPipeById := -1;
 U := UpStr(TrimStr(Id));
 {$IFDEF FPC}
 If (Not HPipeOk) Or (HPipeCnt <> PipeCnt) Then RebuildPipeIndex;
 I := HashId(U) And (HPipeSize - 1);
 While HPipe^[I] <> 0 Do Begin
  If UpStr(Pipes^[HPipe^[I] - 1].Id) = U Then Begin
   FindPipeById := HPipe^[I] - 1;
   Exit;
  End;
  I := (I + 1) And (HPipeSize - 1);
 End;
 {$ELSE}
 For I := 0 To PipeCnt - 1 Do
  If UpStr(Pipes^[I].Id) = U Then Begin
   FindPipeById := I;
   Exit;
  End;
 {$ENDIF}
End;

Function ValidNode(I: Integer): Boolean;
Begin
 ValidNode := (I >= 0) And (I < NodeCnt);
End;

Function ValidPipe(I: Integer): Boolean;
Begin
 ValidPipe := (I >= 0) And (I < PipeCnt);
End;

{ Position d'un objet cible (evenements / interventions) }
Procedure ObjPos(TKind: Integer; TIdx: Integer; Var X, Y: Real);
Begin
 X := 0; Y := 0;
 If (TKind = 1) And ValidNode(TIdx) Then Begin
  X := Nodes^[TIdx].X; Y := Nodes^[TIdx].Y;
 End Else If (TKind = 2) And ValidPipe(TIdx) Then Begin
  If ValidNode(Pipes^[TIdx].N1) And ValidNode(Pipes^[TIdx].N2) Then Begin
   X := (Nodes^[Pipes^[TIdx].N1].X + Nodes^[Pipes^[TIdx].N2].X) / 2;
   Y := (Nodes^[Pipes^[TIdx].N1].Y + Nodes^[Pipes^[TIdx].N2].Y) / 2;
  End;
 End;
End;

Function ObjLabel(TKind: Integer; TIdx: Integer): String;
Begin
 ObjLabel := '-';
 If (TKind = 1) And ValidNode(TIdx) Then ObjLabel := Nodes^[TIdx].Id
 Else If (TKind = 2) And ValidPipe(TIdx) Then ObjLabel := Pipes^[TIdx].Id;
End;

Procedure BuildAdjacency;
Var I: Integer;
Begin
 For I := 0 To NodeCnt - 1 Do Begin
  FirstOut^[I] := -1;
  FirstIn^[I] := -1;
 End;
 For I := 0 To PipeCnt - 1 Do Begin
  NextOut^[I] := -1;
  NextIn^[I] := -1;
  If ValidNode(Pipes^[I].N1) And ValidNode(Pipes^[I].N2) Then Begin
   NextOut^[I] := FirstOut^[Pipes^[I].N1];
   FirstOut^[Pipes^[I].N1] := I;
   NextIn^[I] := FirstIn^[Pipes^[I].N2];
   FirstIn^[Pipes^[I].N2] := I;
  End;
 End;
End;

{ ============================================================
  HYDRAULIQUE (Manning)
  ============================================================ }

Procedure SectionProps(Shape: Byte; HMm, WMm: Real; Var A, R: Real);
Var H, W: Real;
Begin
 H := HMm / 1000.0;
 W := WMm / 1000.0;
 If W <= 0 Then W := H;
 Case Shape Of
  0: Begin A := Pi * H * H / 4.0; R := H / 4.0; End;
  1: Begin A := 1.1486 * W * W; R := 0.2877 * W; End;
  2: Begin A := W * H; R := W * H / (2.0 * (W + H)); End;
 Else Begin
  A := 0.85 * W * H;
  R := A / (1.8 * H + W);
 End;
 End;
End;

{ Debit a pleine section (L/s) }
Function PipeQFull(Var P: TPipe): Real;
Var A, R, S: Real;
Begin
 SectionProps(P.Shape, P.Diam, P.Width, A, R);
 S := P.Slope;
 If S < 0.0002 Then S := 0.0002;
 PipeQFull := 1000.0 * A * RPow(R, 2.0 / 3.0) * Sqrt(S) / MatManning[P.Mat Mod 6];
End;

{ Rapport de debit -> hauteur relative (section circulaire equivalente) }
Procedure FillFromRatio(QR: Real; Var Fill, Phi: Real);
Const ThMax = 5.285;
Var Lo, Hi, Mid, Q: Real; I: Integer;
Begin
 If QR <= 0 Then Begin Fill := 0; Phi := 0; Exit; End;
 If QR >= 1.075 Then Begin Fill := QR; Phi := 1.0; Exit; End;
 Lo := 0.01; Hi := ThMax;
 For I := 1 To 28 Do Begin
  Mid := (Lo + Hi) / 2.0;
  Q := RPow(Mid - Sin(Mid), 5.0 / 3.0) / (RPow(Mid, 2.0 / 3.0) * 2.0 * Pi);
  If Q < QR Then Lo := Mid Else Hi := Mid;
 End;
 Mid := (Lo + Hi) / 2.0;
 Fill := (1.0 - Cos(Mid / 2.0)) / 2.0;
 Phi := (Mid - Sin(Mid)) / (2.0 * Pi);
End;

Procedure ComputeHydraulics;
Var
 I, K, Head, Tail, OutCnt, D: Integer;
 Queue: PIntArr;
 InDeg: PIntArr;
 Tot, Share, A, R, Phi, QR: Real;
Begin
 BuildAdjacency;
 GetMem(Queue, (NodeCnt + 1) * SizeOf(LongInt));
 GetMem(InDeg, (NodeCnt + 1) * SizeOf(LongInt));
 For I := 0 To PipeCnt - 1 Do Begin
  Pipes^[I].Flow := 0;
  Pipes^[I].Fill := 0;
  Pipes^[I].Vel := 0;
  Pipes^[I].Len := 0;
  Pipes^[I].Slope := 0;
  Pipes^[I].QFull := 0;
  If ValidNode(Pipes^[I].N1) And ValidNode(Pipes^[I].N2) Then Begin
   Pipes^[I].Len := Dist2(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y,
                          Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y);
   If Pipes^[I].Len < 1.0 Then Pipes^[I].Len := 1.0;
   Pipes^[I].Slope := (Nodes^[Pipes^[I].N1].Radier - Nodes^[Pipes^[I].N2].Radier) /
                      Pipes^[I].Len;
   Pipes^[I].QFull := PipeQFull(Pipes^[I]);
  End;
 End;
 For I := 0 To NodeCnt - 1 Do Begin
  Nodes^[I].Flow := Nodes^[I].Load + 2.78 * 0.6 * RainI * Nodes^[I].Area;
  InDeg^[I] := 0;
 End;
 For I := 0 To EstCnt - 1 Do
  If ValidNode(Estabs^[I].Node) Then
   Nodes^[Estabs^[I].Node].Flow := Nodes^[Estabs^[I].Node].Flow + Estabs^[I].Flow / 86.4;
 For I := 0 To PipeCnt - 1 Do
  If ValidNode(Pipes^[I].N1) And ValidNode(Pipes^[I].N2) Then
   Inc(InDeg^[Pipes^[I].N2]);
 Head := 0; Tail := 0;
 For I := 0 To NodeCnt - 1 Do
  If InDeg^[I] = 0 Then Begin Queue^[Tail] := I; Inc(Tail); End;
 While Head < Tail Do Begin
  I := Queue^[Head]; Inc(Head);
  OutCnt := 0;
  K := FirstOut^[I];
  While K >= 0 Do Begin Inc(OutCnt); K := NextOut^[K]; End;
  If OutCnt > 0 Then Begin
   Tot := Nodes^[I].Flow;
   Share := Tot / OutCnt;
   K := FirstOut^[I];
   While K >= 0 Do Begin
    Pipes^[K].Flow := Share;
    D := Pipes^[K].N2;
    Nodes^[D].Flow := Nodes^[D].Flow + Share;
    Dec(InDeg^[D]);
    If InDeg^[D] = 0 Then Begin Queue^[Tail] := D; Inc(Tail); End;
    K := NextOut^[K];
   End;
  End;
 End;
 For I := 0 To PipeCnt - 1 Do Begin
  If Pipes^[I].QFull > 0 Then Begin
   QR := Pipes^[I].Flow / Pipes^[I].QFull;
   If Pipes^[I].Slope <= 0 Then QR := 1.5;
   FillFromRatio(QR, Pipes^[I].Fill, Phi);
   SectionProps(Pipes^[I].Shape, Pipes^[I].Diam, Pipes^[I].Width, A, R);
   If Phi > 0.001 Then Pipes^[I].Vel := (Pipes^[I].Flow / 1000.0) / (Phi * A)
   Else Pipes^[I].Vel := 0;
  End;
 End;
 FreeMem(Queue);
 FreeMem(InDeg);
End;

{ ============================================================
  VUE : emprise, cadrage, transformations
  ============================================================ }

Procedure ComputeExtent;
Var I: Integer;
Begin
 If NodeCnt = 0 Then Begin
  ExtMinX := -500; ExtMaxX := 500; ExtMinY := -400; ExtMaxY := 400;
  Exit;
 End;
 ExtMinX := Nodes^[0].X; ExtMaxX := ExtMinX;
 ExtMinY := Nodes^[0].Y; ExtMaxY := ExtMinY;
 For I := 1 To NodeCnt - 1 Do Begin
  If Nodes^[I].X < ExtMinX Then ExtMinX := Nodes^[I].X;
  If Nodes^[I].X > ExtMaxX Then ExtMaxX := Nodes^[I].X;
  If Nodes^[I].Y < ExtMinY Then ExtMinY := Nodes^[I].Y;
  If Nodes^[I].Y > ExtMaxY Then ExtMaxY := Nodes^[I].Y;
 End;
End;

Procedure FitRect(MinX, MinY, MaxX, MaxY: Real);
Var SX, SY: Real;
Begin
 ViewCX := (MinX + MaxX) / 2.0;
 ViewCY := (MinY + MaxY) / 2.0;
 SX := (MaxX - MinX) / (MAP_W - 24);
 SY := (MaxY - MinY) / (MAP_H - 24);
 ViewScale := RMax(SX, SY);
 If ViewScale < 0.25 Then ViewScale := 0.25;
End;

Procedure FitExtent;
Begin
 ComputeExtent;
 FitRect(ExtMinX, ExtMinY, ExtMaxX, ExtMaxY);
End;

Procedure W2S(WX, WY: Real; Var SX, SY: Real);
Begin
 SX := (WX - ViewCX) / ViewScale + MAP_W / 2.0;
 SY := MAP_H / 2.0 - (WY - ViewCY) / ViewScale;
End;

Procedure S2W(SX, SY: Real; Var WX, WY: Real);
Begin
 WX := (SX - MAP_W / 2.0) * ViewScale + ViewCX;
 WY := (MAP_H / 2.0 - SY) * ViewScale + ViewCY;
End;

Function ScaleDenominator: LongInt;
Var V: Real;
Begin
 V := ViewScale / 0.0002646;
 If V > 2000000000.0 Then V := 2000000000.0;
 ScaleDenominator := Round(V);
End;

{ ============================================================
  LECTURE / ECRITURE DES PLANS (.TGR)
  Format texte, champs separes par des points-virgules.
  ============================================================ }

Function NextField(Var S: String): String;
Var P: Integer;
Begin
 P := Pos(';', S);
 If P = 0 Then Begin
  NextField := S;
  S := '';
 End Else Begin
  NextField := Copy(S, 1, P - 1);
  Delete(S, 1, P);
 End;
End;

Function StripEol(S: String): String;
Var I: Integer;
Begin
 I := Length(S);
 While (I > 0) And ((S[I] = #13) Or (S[I] = #10) Or (S[I] = #26)) Do Dec(I);
 Delete(S, I + 1, 255);
 StripEol := S;
End;

{$IFDEF FPC}
Var
 LoadBuf: Array[0..65535] Of Byte;
{$ENDIF}

Function LoadPlan(FName: String): Boolean;
Var
 F: Text;
 L, T, S1, S2: String;
 N: Integer;
 Done: Boolean;
Begin
 LoadPlan := False;
 {$I-}
 Assign(F, FName);
 {$IFDEF FPC}
 SetTextBuf(F, LoadBuf);
 {$ENDIF}
 Reset(F);
 {$I+}
 If IOResult <> 0 Then Exit;
 ClearData;
 LoadTrunc := False;
 PlanFile := FName;
 Done := False;
 While (Not Eof(F)) And (Not Done) Do Begin
  ReadLn(F, L);
  L := StripEol(L);
  If L <> '' Then Begin
   T := NextField(L);
   If T = 'END' Then Done := True
   Else If T = 'TIGRE' Then Begin
    S1 := NextField(L);
    PlanTitle := TrimStr(L);
   End
   Else If T = 'O' Then PlanOrg := L
   Else If T = 'A' Then Begin
    N := StrToIntDef(NextField(L), -1);
    If (N >= 0) And (N < MAX_SECTORS) Then Begin
     SectorName[N] := L;
     If N + 1 > SectorCnt Then SectorCnt := N + 1;
    End;
   End
   Else If (T = 'N') And (Not GrowNodes(NodeCnt + 1)) Then LoadTrunc := True
   Else If T = 'N' Then Begin
    With Nodes^[NodeCnt] Do Begin
     Id := NextField(L);
     X := StrToRealDef(NextField(L), 0);
     Y := StrToRealDef(NextField(L), 0);
     Cote := StrToRealDef(NextField(L), 0);
     Radier := StrToRealDef(NextField(L), 0);
     Kind := IClamp(StrToIntDef(NextField(L), 0), 0, NK_COUNT - 1);
     Sector := IClamp(StrToIntDef(NextField(L), 0), 0, MAX_SECTORS - 1);
     Year := StrToIntDef(NextField(L), 0);
     State := IClamp(StrToIntDef(NextField(L), 0), 0, 3);
     Load := StrToRealDef(NextField(L), 0);
     Area := StrToRealDef(NextField(L), 0);
     Name := L;
     Flow := 0;
     Sel := False;
    End;
    Inc(NodeCnt);
   End
   Else If (T = 'P') And (Not GrowPipes(PipeCnt + 1)) Then LoadTrunc := True
   Else If T = 'P' Then Begin
    With Pipes^[PipeCnt] Do Begin
     Id := NextField(L);
     S1 := NextField(L);
     S2 := NextField(L);
     N1 := FindNodeById(S1);
     N2 := FindNodeById(S2);
     Diam := StrToIntDef(NextField(L), 300);
     Width := StrToIntDef(NextField(L), Diam);
     Shape := IClamp(StrToIntDef(NextField(L), 0), 0, 3);
     Mat := IClamp(StrToIntDef(NextField(L), 0), 0, 5);
     Cls := IClamp(StrToIntDef(NextField(L), 0), 0, 3);
     Year := StrToIntDef(NextField(L), 0);
     State := IClamp(StrToIntDef(NextField(L), 0), 0, 3);
     Visit := StrToIntDef(NextField(L), 0) <> 0;
     Street := StrToIntDef(NextField(L), -1);
     Sel := False;
     Len := 0; Slope := 0; QFull := 0; Flow := 0; Fill := 0; Vel := 0;
    End;
    If ValidNode(Pipes^[PipeCnt].N1) And ValidNode(Pipes^[PipeCnt].N2) Then
     Inc(PipeCnt);
   End
   Else If (T = 'S') And (Not GrowBgs(BgCnt + 1)) Then LoadTrunc := True
   Else If T = 'S' Then Begin
    With Bgs^[BgCnt] Do Begin
     Kind := IClamp(StrToIntDef(NextField(L), 0), 0, 2);
     Width := StrToIntDef(NextField(L), 0);
     Name := NextField(L);
     First := BgPtCnt;
     Count := 0;
    End;
    Inc(BgCnt);
   End
   Else If (T = 'Q') And (BgCnt > 0) And (Not GrowBgPts(BgPtCnt + 1)) Then LoadTrunc := True
   Else If (T = 'Q') And (BgCnt > 0) Then Begin
    BgPts^[BgPtCnt].X := Round(StrToRealDef(NextField(L), 0));
    BgPts^[BgPtCnt].Y := Round(StrToRealDef(NextField(L), 0));
    Inc(BgPtCnt);
    Inc(Bgs^[BgCnt - 1].Count);
   End
   Else If (T = 'E') And (Not GrowEstabs(EstCnt + 1)) Then LoadTrunc := True
   Else If T = 'E' Then Begin
    With Estabs^[EstCnt] Do Begin
     Name := NextField(L);
     Sap := NextField(L);
     Naf := NextField(L);
     Commune := NextField(L);
     Post := NextField(L);
     Node := FindNodeById(NextField(L));
     Flow := StrToRealDef(NextField(L), 0);
    End;
    Inc(EstCnt);
   End
   Else If (T = 'V') And (Not GrowEvents(EvCnt + 1)) Then LoadTrunc := True
   Else If T = 'V' Then Begin
    With Events^[EvCnt] Do Begin
     Id := NextField(L);
     Kind := IClamp(StrToIntDef(NextField(L), 0), 0, 5);
     Date := NextField(L);
     Status := IClamp(StrToIntDef(NextField(L), 0), 0, 2);
     Desc := NextField(L);
     S1 := NextField(L);
     S2 := NextField(L);
     TKind := 0; TIdx := -1;
     If S1 = 'N' Then Begin TKind := 1; TIdx := FindNodeById(S2); End
     Else If S1 = 'P' Then Begin TKind := 2; TIdx := FindPipeById(S2); End;
     If TIdx < 0 Then TKind := 0;
    End;
    Inc(EvCnt);
   End
   Else If (T = 'I') And (Not GrowIntervs(IvCnt + 1)) Then LoadTrunc := True
   Else If T = 'I' Then Begin
    With Intervs^[IvCnt] Do Begin
     Id := NextField(L);
     Kind := IClamp(StrToIntDef(NextField(L), 0), 0, 5);
     Date := NextField(L);
     Status := IClamp(StrToIntDef(NextField(L), 0), 0, 2);
     Team := NextField(L);
     Cost := StrToRealDef(NextField(L), 0);
     S1 := NextField(L);
     S2 := NextField(L);
     TKind := 0; TIdx := -1;
     If S1 = 'N' Then Begin TKind := 1; TIdx := FindNodeById(S2); End
     Else If S1 = 'P' Then Begin TKind := 2; TIdx := FindPipeById(S2); End;
     If TIdx < 0 Then TKind := 0;
    End;
    Inc(IvCnt);
   End;
  End;
 End;
 Close(F);
 LoadPlan := True;
End;

Function SavePlan(FName: String): Boolean;
Var
 F: Text;
 I, J: Integer;
 S: String;
 Function R2(R: Real): String;
 Var T: String;
 Begin
  Str(R:0:2, T);
  R2 := T;
 End;
 Function Tgt(TKind, TIdx: Integer): String;
 Begin
  If (TKind = 1) And ValidNode(TIdx) Then Tgt := 'N;' + Nodes^[TIdx].Id
  Else If (TKind = 2) And ValidPipe(TIdx) Then Tgt := 'P;' + Pipes^[TIdx].Id
  Else Tgt := 'X;-';
 End;
Begin
 SavePlan := False;
 {$I-}
 Assign(F, FName);
 Rewrite(F);
 {$I+}
 If IOResult <> 0 Then Exit;
 WriteLn(F, 'TIGRE;1;', PlanTitle);
 WriteLn(F, 'O;', PlanOrg);
 For I := 0 To SectorCnt - 1 Do
  WriteLn(F, 'A;', I, ';', SectorName[I]);
 For I := 0 To NodeCnt - 1 Do
  With Nodes^[I] Do
   WriteLn(F, 'N;', Id, ';', R2(X), ';', R2(Y), ';', R2(Cote), ';', R2(Radier), ';',
           Kind, ';', Sector, ';', Year, ';', State, ';', R2(Load), ';', R2(Area), ';',
           Name);
 For I := 0 To PipeCnt - 1 Do
  With Pipes^[I] Do Begin
   S := 'P;' + Id + ';' + Nodes^[N1].Id + ';' + Nodes^[N2].Id + ';' + IntToStr(Diam) + ';' +
        IntToStr(Width) + ';' + IntToStr(Shape) + ';' + IntToStr(Mat) + ';' +
        IntToStr(Cls) + ';' + IntToStr(Year) + ';' + IntToStr(State) + ';';
   If Visit Then S := S + '1;' Else S := S + '0;';
   S := S + IntToStr(Street);
   WriteLn(F, S);
  End;
 For I := 0 To BgCnt - 1 Do Begin
  WriteLn(F, 'S;', Bgs^[I].Kind, ';', Bgs^[I].Width, ';', Bgs^[I].Name, ';',
          Bgs^[I].Count);
  For J := 0 To Bgs^[I].Count - 1 Do
   WriteLn(F, 'Q;', BgPts^[Bgs^[I].First + J].X, ';', BgPts^[Bgs^[I].First + J].Y);
 End;
 For I := 0 To EstCnt - 1 Do
  With Estabs^[I] Do Begin
   If ValidNode(Node) Then S := Nodes^[Node].Id Else S := '-';
   WriteLn(F, 'E;', Name, ';', Sap, ';', Naf, ';', Commune, ';', Post, ';', S, ';',
           R2(Flow), ';0');
  End;
 For I := 0 To EvCnt - 1 Do
  With Events^[I] Do
   WriteLn(F, 'V;', Id, ';', Kind, ';', Date, ';', Status, ';', Desc, ';',
           Tgt(TKind, TIdx));
 For I := 0 To IvCnt - 1 Do
  With Intervs^[I] Do
   WriteLn(F, 'I;', Id, ';', Kind, ';', Date, ';', Status, ';', Team, ';', R2(Cost), ';',
           Tgt(TKind, TIdx));
 WriteLn(F, 'END');
 Close(F);
 PlanDirty := False;
 SavePlan := True;
End;

{ ============================================================
  RESEAU DE DEMONSTRATION (si aucun fichier n'est disponible)
  ============================================================ }

Procedure GenerateDemo;
Var
 I, J, Idx: Integer;
 Cnt: Integer;
Begin
 ClearData;
 PlanTitle := 'Reseau de demonstration';
 PlanOrg := 'TIGRE';
 PlanFile := 'DEMO.TGR';
 SectorName[0] := 'Secteur Nord'; SectorName[1] := 'Secteur Sud';
 SectorCnt := 2;
 RandSeed := 1234;
 Cnt := 0;
 For J := 0 To 5 Do
  For I := 0 To 7 Do Begin
   With Nodes^[Cnt] Do Begin
    Id := 'R' + PadZero(Cnt + 1, 4);
    Name := '';
    X := (I - 3.5) * 160.0 + (Random(40) - 20);
    Y := (J - 2.5) * 140.0 + (Random(40) - 20);
    Cote := 30.0 + J * 1.8 + I * 0.2;
    Radier := Cote - 2.5;
    Load := 0.4 + Random(10) / 10.0;
    Area := 0.5 + Random(8) / 10.0;
    Kind := NK_REGARD;
    Sector := Ord(J >= 3);
    State := Random(3);
    Year := 1900 + Random(100);
    Sel := False;
   End;
   Inc(Cnt);
  End;
 NodeCnt := Cnt;
 { collecteur en bas : noeuds de la rangee J=0 }
 For I := 0 To 7 Do Nodes^[I].Radier := 22.0 - I * 0.15;
 Nodes^[7].Kind := NK_EXUTOIRE;
 Nodes^[7].Name := 'Exutoire demo';
 Nodes^[7].Id := 'X0008';
 Nodes^[3].Kind := NK_VANNE;
 Nodes^[3].Id := 'V0004';
 Nodes^[20].Kind := NK_BASSIN;
 Nodes^[20].Id := 'B0021';
 Nodes^[20].Name := 'Bassin demo';
 HNodeOk := False;
 PipeCnt := 0;
 For J := 0 To 5 Do
  For I := 0 To 7 Do Begin
   Idx := J * 8 + I;
   If (I < 7) And (PipeCnt < MAX_PIPES) Then Begin
    With Pipes^[PipeCnt] Do Begin
     Id := 'T' + PadZero(PipeCnt + 1, 4);
     If J = 0 Then Begin N1 := Idx; N2 := Idx + 1; End
     Else If Nodes^[Idx].Radier >= Nodes^[Idx + 1].Radier Then Begin N1 := Idx; N2 := Idx + 1; End
     Else Begin N1 := Idx + 1; N2 := Idx; End;
     If J = 0 Then Begin Cls := PC_COLLECTEUR; Diam := 1800; Shape := 1; Width := 1200; End
     Else Begin Cls := PC_UNITAIRE; Diam := 600; Shape := 0; Width := 600; End;
     Mat := 0; State := 0; Year := 1950; Visit := (J = 0); Street := -1; Sel := False;
    End;
    Inc(PipeCnt);
   End;
   If (J < 5) And (PipeCnt < MAX_PIPES) Then Begin
    With Pipes^[PipeCnt] Do Begin
     Id := 'T' + PadZero(PipeCnt + 1, 4);
     N1 := Idx + 8; N2 := Idx;
     Cls := PC_UNITAIRE; Diam := 500; Shape := 0; Width := 500;
     Mat := 1; State := 1; Year := 1930; Visit := False; Street := -1; Sel := False;
    End;
    Inc(PipeCnt);
   End;
  End;
 { fond de plan : fleuve et voies }
 BgCnt := 0; BgPtCnt := 0;
 Bgs^[0].Kind := 1; Bgs^[0].Name := 'Le Fleuve'; Bgs^[0].Width := 120;
 Bgs^[0].First := 0; Bgs^[0].Count := 3;
 BgPts^[0].X := -800; BgPts^[0].Y := -450;
 BgPts^[1].X := 0;    BgPts^[1].Y := -400;
 BgPts^[2].X := 800;  BgPts^[2].Y := -480;
 BgCnt := 1; BgPtCnt := 3;
 For J := 0 To 5 Do Begin
  Bgs^[BgCnt].Kind := 0;
  Bgs^[BgCnt].Name := 'Rue ' + IntToStr(J + 1);
  Bgs^[BgCnt].Width := 0;
  Bgs^[BgCnt].First := BgPtCnt;
  Bgs^[BgCnt].Count := 2;
  BgPts^[BgPtCnt].X := Round(Nodes^[J * 8].X); BgPts^[BgPtCnt].Y := Round(Nodes^[J * 8].Y);
  BgPts^[BgPtCnt + 1].X := Round(Nodes^[J * 8 + 7].X); BgPts^[BgPtCnt + 1].Y := Round(Nodes^[J * 8 + 7].Y);
  Inc(BgCnt); Inc(BgPtCnt, 2);
 End;
 EstCnt := 3;
 Estabs^[0].Name := 'PRESSING DEMO'; Estabs^[0].Sap := '930D'; Estabs^[0].Naf := '9601B';
 Estabs^[0].Commune := 'DEMO'; Estabs^[0].Post := '00001'; Estabs^[0].Node := 10; Estabs^[0].Flow := 4;
 Estabs^[1].Name := 'RESTAURANT DEMO'; Estabs^[1].Sap := '553A'; Estabs^[1].Naf := '5610A';
 Estabs^[1].Commune := 'DEMO'; Estabs^[1].Post := '00001'; Estabs^[1].Node := 18; Estabs^[1].Flow := 9;
 Estabs^[2].Name := 'GARAGE DEMO'; Estabs^[2].Sap := '502Z'; Estabs^[2].Naf := '4520A';
 Estabs^[2].Commune := 'DEMO'; Estabs^[2].Post := '00002'; Estabs^[2].Node := 30; Estabs^[2].Flow := 12;
 EvCnt := 0; IvCnt := 0;
 PlanDirty := False;
End;

{ Fin d'une (re)lecture : recalcul des donnees derivees }
Procedure FinishLoad;
Begin
 ClearSelection;
 ClearTrace;
 MeasCnt := 0;
 MeasLen := 0;
 PendingNode := -1;
 BuildAdjacency;
 ComputeHydraulics;
 FitExtent;
End;

{ ============================================================
  EDITION : ajout / suppression
  ============================================================ }

Function NewNodeId(Kind: Integer): String;
Const Pref: String[6] = 'RVBPDX';
Var N: Integer; S: String;
Begin
 N := NodeCnt + 1;
 Repeat
  S := Pref[Kind + 1] + PadZero(N, 4);
  Inc(N);
 Until FindNodeById(S) < 0;
 NewNodeId := S;
End;

Function NewPipeId: String;
Var N: Integer; S: String;
Begin
 N := PipeCnt + 1;
 Repeat
  S := 'T' + PadZero(N, 4);
  Inc(N);
 Until FindPipeById(S) < 0;
 NewPipeId := S;
End;


Function CurrentYear: Integer;
Begin
 CurrentYear := StrToIntDef(Copy(TodayStr, 1, 4), 2026);
End;

Function NearestNode(PX, PY: Real): Integer;
Var I, Best: Integer; BD, D: Real;
Begin
 Best := -1; BD := 1E30;
 For I := 0 To NodeCnt - 1 Do Begin
  D := Dist2(PX, PY, Nodes^[I].X, Nodes^[I].Y);
  If D < BD Then Begin BD := D; Best := I; End;
 End;
 NearestNode := Best;
End;

Function AddNodeAt(PX, PY: Real; Kind: Integer): Integer;
Var Best: Integer;
Begin
 AddNodeAt := -1;
 If Not GrowNodes(NodeCnt + 1) Then Exit;
 Best := NearestNode(PX, PY);
 With Nodes^[NodeCnt] Do Begin
  Id := NewNodeId(Kind);
  Name := '';
  X := PX; Y := PY;
  If Best >= 0 Then Begin
   Cote := Nodes^[Best].Cote;
   Sector := Nodes^[Best].Sector;
  End Else Begin
   Cote := 30.0; Sector := 0;
  End;
  Radier := Cote - 2.8;
  Load := 0.5; Area := 0.5; Flow := 0;
  State := 0;
  Year := CurrentYear;
  Sel := False;
 End;
 Nodes^[NodeCnt].Kind := Kind;
 AddNodeAt := NodeCnt;
 Inc(NodeCnt);
 PlanDirty := True;
End;

Function PipeExists(A, B: Integer): Boolean;
Var I: Integer;
Begin
 PipeExists := False;
 For I := 0 To PipeCnt - 1 Do
  If ((Pipes^[I].N1 = A) And (Pipes^[I].N2 = B)) Or
     ((Pipes^[I].N1 = B) And (Pipes^[I].N2 = A)) Then PipeExists := True;
End;

Function AddPipeBetween(A, B: Integer): Integer;
Var T: Integer;
Begin
 AddPipeBetween := -1;
 If (A = B) Or (Not ValidNode(A)) Or (Not ValidNode(B)) Then Exit;
 If Not GrowPipes(PipeCnt + 1) Then Exit;
 If PipeExists(A, B) Then Exit;
 If Nodes^[A].Radier < Nodes^[B].Radier Then Begin T := A; A := B; B := T; End;
 With Pipes^[PipeCnt] Do Begin
  Id := NewPipeId;
  N1 := A; N2 := B;
  Diam := 600; Width := 600; Shape := 0; Mat := 0; Cls := PC_UNITAIRE;
  State := 0; Year := CurrentYear; Visit := False; Street := -1; Sel := False;
  Len := 0; Slope := 0; QFull := 0; Flow := 0; Fill := 0; Vel := 0;
 End;
 AddPipeBetween := PipeCnt;
 Inc(PipeCnt);
 PlanDirty := True;
End;

Procedure DeletePipe(I: Integer);
Var J: Integer;
Begin
 If Not ValidPipe(I) Then Exit;
 For J := I To PipeCnt - 2 Do Pipes^[J] := Pipes^[J + 1];
 Dec(PipeCnt);
 HPipeOk := False;
 For J := 0 To EvCnt - 1 Do
  If Events^[J].TKind = 2 Then Begin
   If Events^[J].TIdx = I Then Begin Events^[J].TKind := 0; Events^[J].TIdx := -1; End
   Else If Events^[J].TIdx > I Then Dec(Events^[J].TIdx);
  End;
 For J := 0 To IvCnt - 1 Do
  If Intervs^[J].TKind = 2 Then Begin
   If Intervs^[J].TIdx = I Then Begin Intervs^[J].TKind := 0; Intervs^[J].TIdx := -1; End
   Else If Intervs^[J].TIdx > I Then Dec(Intervs^[J].TIdx);
  End;
 ClearTrace;
 PlanDirty := True;
End;

Procedure DeleteNode(I: Integer);
Var J: Integer;
Begin
 If Not ValidNode(I) Then Exit;
 For J := PipeCnt - 1 Downto 0 Do
  If (Pipes^[J].N1 = I) Or (Pipes^[J].N2 = I) Then DeletePipe(J);
 For J := I To NodeCnt - 2 Do Nodes^[J] := Nodes^[J + 1];
 Dec(NodeCnt);
 HNodeOk := False;
 For J := 0 To PipeCnt - 1 Do Begin
  If Pipes^[J].N1 > I Then Dec(Pipes^[J].N1);
  If Pipes^[J].N2 > I Then Dec(Pipes^[J].N2);
 End;
 For J := 0 To EstCnt - 1 Do Begin
  If Estabs^[J].Node = I Then Estabs^[J].Node := -1
  Else If Estabs^[J].Node > I Then Dec(Estabs^[J].Node);
 End;
 For J := 0 To EvCnt - 1 Do
  If Events^[J].TKind = 1 Then Begin
   If Events^[J].TIdx = I Then Begin Events^[J].TKind := 0; Events^[J].TIdx := -1; End
   Else If Events^[J].TIdx > I Then Dec(Events^[J].TIdx);
  End;
 For J := 0 To IvCnt - 1 Do
  If Intervs^[J].TKind = 1 Then Begin
   If Intervs^[J].TIdx = I Then Begin Intervs^[J].TKind := 0; Intervs^[J].TIdx := -1; End
   Else If Intervs^[J].TIdx > I Then Dec(Intervs^[J].TIdx);
  End;
 ClearTrace;
 PlanDirty := True;
End;

Procedure DeleteEstab(I: Integer);
Var J: Integer;
Begin
 If (I < 0) Or (I >= EstCnt) Then Exit;
 For J := I To EstCnt - 2 Do Estabs^[J] := Estabs^[J + 1];
 Dec(EstCnt);
 PlanDirty := True;
End;

Procedure DeleteEvent(I: Integer);
Var J: Integer;
Begin
 If (I < 0) Or (I >= EvCnt) Then Exit;
 For J := I To EvCnt - 2 Do Events^[J] := Events^[J + 1];
 Dec(EvCnt);
 PlanDirty := True;
End;

Procedure DeleteInterv(I: Integer);
Var J: Integer;
Begin
 If (I < 0) Or (I >= IvCnt) Then Exit;
 For J := I To IvCnt - 2 Do Intervs^[J] := Intervs^[J + 1];
 Dec(IvCnt);
 PlanDirty := True;
End;

{ ============================================================
  TRACES LOGIQUES (amont / aval / connexe)
  ============================================================ }

Procedure TraceFrom(Start, Dir: Integer; Var NN, NP: Integer; Var Len: Real);
Var
 Queue: PIntArr;
 Head, Tail, N, K, M: Integer;
Begin
 NN := 0; NP := 0; Len := 0;
 If Not ValidNode(Start) Then Exit;
 GetMem(Queue, (NodeCnt + 1) * SizeOf(LongInt));
 Head := 0; Tail := 0;
 Queue^[Tail] := Start; Inc(Tail);
 TraceNode^[Start] := True;
 NN := 1;
 While Head < Tail Do Begin
  N := Queue^[Head]; Inc(Head);
  If Dir >= 0 Then Begin
   K := FirstOut^[N];
   While K >= 0 Do Begin
    If Not TracePipe^[K] Then Begin
     TracePipe^[K] := True; Inc(NP); Len := Len + Pipes^[K].Len;
    End;
    M := Pipes^[K].N2;
    If Not TraceNode^[M] Then Begin
     TraceNode^[M] := True; Inc(NN); Queue^[Tail] := M; Inc(Tail);
    End;
    K := NextOut^[K];
   End;
  End;
  If Dir <= 0 Then Begin
   K := FirstIn^[N];
   While K >= 0 Do Begin
    If Not TracePipe^[K] Then Begin
     TracePipe^[K] := True; Inc(NP); Len := Len + Pipes^[K].Len;
    End;
    M := Pipes^[K].N1;
    If Not TraceNode^[M] Then Begin
     TraceNode^[M] := True; Inc(NN); Queue^[Tail] := M; Inc(Tail);
    End;
    K := NextIn^[K];
   End;
  End;
 End;
 FreeMem(Queue);
 TraceActive := True;
End;

{ Noeud de depart pour une trace : noeud selectionne, ou noeud amont de la conduite }
Function TraceStartNode(Dir: Integer): Integer;
Begin
 TraceStartNode := -1;
 If (SelKind = SEL_NODE) And ValidNode(SelIdx) Then TraceStartNode := SelIdx
 Else If (SelKind = SEL_PIPE) And ValidPipe(SelIdx) Then Begin
  If Dir > 0 Then TraceStartNode := Pipes^[SelIdx].N2
  Else TraceStartNode := Pipes^[SelIdx].N1;
 End Else If (SelKind = SEL_ESTAB) And (SelIdx >= 0) And (SelIdx < EstCnt) Then
  TraceStartNode := Estabs^[SelIdx].Node;
End;

Procedure SelectFromTrace;
Var I: Integer;
Begin
 For I := 0 To NodeCnt - 1 Do Nodes^[I].Sel := TraceNode^[I];
 For I := 0 To PipeCnt - 1 Do Pipes^[I].Sel := TracePipe^[I];
End;

Function SelCount: Integer;
Var I, C: Integer;
Begin
 C := 0;
 For I := 0 To NodeCnt - 1 Do If Nodes^[I].Sel Then Inc(C);
 For I := 0 To PipeCnt - 1 Do If Pipes^[I].Sel Then Inc(C);
 SelCount := C;
End;

{ ============================================================
  RENDU CARTOGRAPHIQUE
  ============================================================ }

Const
 CLIP_XMIN = -4.0;
 CLIP_YMIN = -4.0;
 CLIP_XMAX = 490.0;
 CLIP_YMAX = 408.0;

Function ClipSeg(Var X1, Y1, X2, Y2: Real): Boolean;
Var T0, T1, DX, DY: Real;

 Function Chk(P, Q: Real): Boolean;
 Var R: Real;
 Begin
  Chk := True;
  If P = 0 Then Begin
   If Q < 0 Then Chk := False;
   Exit;
  End;
  R := Q / P;
  If P < 0 Then Begin
   If R > T1 Then Chk := False Else If R > T0 Then T0 := R;
  End Else Begin
   If R < T0 Then Chk := False Else If R < T1 Then T1 := R;
  End;
 End;

Begin
 T0 := 0; T1 := 1;
 DX := X2 - X1; DY := Y2 - Y1;
 ClipSeg := False;
 If Chk(-DX, X1 - CLIP_XMIN) Then
  If Chk(DX, CLIP_XMAX - X1) Then
   If Chk(-DY, Y1 - CLIP_YMIN) Then
    If Chk(DY, CLIP_YMAX - Y1) Then Begin
     If T1 < 1 Then Begin X2 := X1 + T1 * DX; Y2 := Y1 + T1 * DY; End;
     If T0 > 0 Then Begin X1 := X1 + T0 * DX; Y1 := Y1 + T0 * DY; End;
     ClipSeg := True;
    End;
End;

{ Segment en coordonnees ecran (reels) }
Procedure ScreenLine(X1, Y1, X2, Y2: Real);
Begin
 If ClipSeg(X1, Y1, X2, Y2) Then
  Line(RoundInt(X1), RoundInt(Y1), RoundInt(X2), RoundInt(Y2));
End;

Procedure WorldLine(WX1, WY1, WX2, WY2: Real);
Var X1, Y1, X2, Y2: Real;
Begin
 W2S(WX1, WY1, X1, Y1);
 W2S(WX2, WY2, X2, Y2);
 ScreenLine(X1, Y1, X2, Y2);
End;

Function NodeLayer(Kind: Integer): Integer;
Begin
 Case Kind Of
  NK_REGARD: NodeLayer := L_REGARD;
  NK_VANNE: NodeLayer := L_VANNE;
  NK_BASSIN: NodeLayer := L_BASSIN;
  NK_POMPAGE: NodeLayer := L_POMP;
  NK_DEVERSOIR: NodeLayer := L_DEVERS;
 Else NodeLayer := L_EXUT;
 End;
End;

Function PipeLayer(Cls: Integer): Integer;
Begin
 Case Cls Of
  PC_UNITAIRE: PipeLayer := L_UNIT;
  PC_EAUX_USEES: PipeLayer := L_EU;
  PC_PLUVIAL: PipeLayer := L_EP;
 Else PipeLayer := L_COLL;
 End;
End;

Function PipeColor(Var P: TPipe): Integer;
Begin
 If Layers[L_REMPLI].A Then Begin
  If P.Fill > 1.0 Then PipeColor := Magenta
  Else If P.Fill > 0.8 Then PipeColor := LightRed
  Else If P.Fill > 0.5 Then PipeColor := Brown
  Else PipeColor := Green;
 End Else If Layers[L_PENTE].A Then Begin
  If P.Slope < 0.0005 Then PipeColor := Magenta
  Else If P.Slope < 0.002 Then PipeColor := Blue
  Else If P.Slope < 0.01 Then PipeColor := Green
  Else PipeColor := Brown;
 End Else Begin
  Case P.Cls Of
   PC_UNITAIRE: PipeColor := Black;
   PC_EAUX_USEES: PipeColor := Brown;
   PC_PLUVIAL: PipeColor := Blue;
  Else PipeColor := Red;
  End;
 End;
End;

Function PipeVisible(Var P: TPipe): Boolean;
Begin
 PipeVisible := Layers[PipeLayer(P.Cls)].A;
End;

Procedure DrawGrid;
Var
 Step, X, Y, MinX, MaxX, MinY, MaxY: Real;
 Steps: Array[0..8] Of Real;
 I: Integer;
 SX, SY: Real;
Begin
 Steps[0] := 50; Steps[1] := 100; Steps[2] := 200; Steps[3] := 500;
 Steps[4] := 1000; Steps[5] := 2000; Steps[6] := 5000; Steps[7] := 10000;
 Steps[8] := 20000;
 Step := Steps[8];
 For I := 0 To 8 Do
  If Steps[I] / ViewScale >= 60 Then Begin Step := Steps[I]; Break; End;
 S2W(0, MAP_H, MinX, MinY);
 S2W(MAP_W, 0, MaxX, MaxY);
 SetColor(LightGray);
 SetLineStyle(DottedLn, 0, NormWidth);
 X := Int(MinX / Step) * Step;
 While X <= MaxX Do Begin
  W2S(X, 0, SX, SY);
  If (SX >= 0) And (SX < MAP_W) Then Begin
   Line(RoundInt(SX), 0, RoundInt(SX), MAP_H);
  End;
  X := X + Step;
 End;
 Y := Int(MinY / Step) * Step;
 While Y <= MaxY Do Begin
  W2S(0, Y, SX, SY);
  If (SY >= 0) And (SY < MAP_H) Then Begin
   Line(0, RoundInt(SY), MAP_W, RoundInt(SY));
  End;
  Y := Y + Step;
 End;
 SetLineStyle(SolidLn, 0, NormWidth);
End;

Procedure DrawRiver(B: Integer);
Var
 K: Integer;
 AX, AY, BX, BY, DX, DY, L, NX, NY, HW: Real;
 Pt: Array[0..3] Of PointType;
 SX, SY: Real;
Begin
 HW := Bgs^[B].Width / 2.0;
 If HW < ViewScale Then HW := ViewScale;
 SetFillStyle(SolidFill, LightCyan);
 SetColor(LightCyan);
 For K := 0 To Bgs^[B].Count - 2 Do Begin
  AX := BgPts^[Bgs^[B].First + K].X; AY := BgPts^[Bgs^[B].First + K].Y;
  BX := BgPts^[Bgs^[B].First + K + 1].X; BY := BgPts^[Bgs^[B].First + K + 1].Y;
  DX := BX - AX; DY := BY - AY;
  L := Sqrt(DX * DX + DY * DY);
  If L > 0 Then Begin
   DX := DX / L; DY := DY / L;
   NX := -DY * HW; NY := DX * HW;
   { prolonge les extremites pour fermer les coudes }
   AX := AX - DX * HW * 0.6; AY := AY - DY * HW * 0.6;
   BX := BX + DX * HW * 0.6; BY := BY + DY * HW * 0.6;
   W2S(AX + NX, AY + NY, SX, SY); Pt[0].X := RoundInt(SX); Pt[0].Y := RoundInt(SY);
   W2S(BX + NX, BY + NY, SX, SY); Pt[1].X := RoundInt(SX); Pt[1].Y := RoundInt(SY);
   W2S(BX - NX, BY - NY, SX, SY); Pt[2].X := RoundInt(SX); Pt[2].Y := RoundInt(SY);
   W2S(AX - NX, AY - NY, SX, SY); Pt[3].X := RoundInt(SX); Pt[3].Y := RoundInt(SY);
   FillPoly(4, Pt);
  End;
 End;
End;

Procedure DrawPark(B: Integer);
Var
 K, N: Integer;
 Pt: Array[0..15] Of PointType;
 SX, SY: Real;
Begin
 N := Bgs^[B].Count;
 If (N < 3) Or (N > 16) Then Exit;
 For K := 0 To N - 1 Do Begin
  W2S(BgPts^[Bgs^[B].First + K].X, BgPts^[Bgs^[B].First + K].Y, SX, SY);
  Pt[K].X := RoundInt(SX);
  Pt[K].Y := RoundInt(SY);
 End;
 SetFillStyle(SolidFill, LightGreen);
 SetColor(Green);
 FillPoly(N, Pt);
End;

Procedure DrawBackground;
Var B, K: Integer; SX, SY: Real; S: String;
Begin
 For B := 0 To BgCnt - 1 Do
  If (Bgs^[B].Kind = 1) And Layers[L_FLEUVE].A Then DrawRiver(B);
 For B := 0 To BgCnt - 1 Do
  If (Bgs^[B].Kind = 2) And Layers[L_PARCS].A Then DrawPark(B);
 If Layers[L_VOIES].A Then Begin
  SetColor(LightGray);
  For B := 0 To BgCnt - 1 Do
   If Bgs^[B].Kind = 0 Then
    For K := 0 To Bgs^[B].Count - 2 Do
     WorldLine(BgPts^[Bgs^[B].First + K].X, BgPts^[Bgs^[B].First + K].Y,
               BgPts^[Bgs^[B].First + K + 1].X, BgPts^[Bgs^[B].First + K + 1].Y);
 End;
 If Layers[L_NOMS].A And (ViewScale < 14) Then Begin
  SetColor(DarkGray);
  For B := 0 To BgCnt - 1 Do
   If (Bgs^[B].Kind <> 2) And (Bgs^[B].Count >= 2) Then Begin
    K := (Bgs^[B].Count - 1) Div 2;
    W2S((BgPts^[Bgs^[B].First + K].X + BgPts^[Bgs^[B].First + K + 1].X) / 2.0,
        (BgPts^[Bgs^[B].First + K].Y + BgPts^[Bgs^[B].First + K + 1].Y) / 2.0, SX, SY);
    S := Bgs^[B].Name;
    SX := SX - Length(S) * 4;
    If (SX > 0) And (SX < MAP_W - Length(S) * 8) And (SY > 4) And (SY < MAP_H - 10) Then
     OutTextXY(RoundInt(SX), RoundInt(SY) - 3, S);
   End;
 End;
End;

Procedure DrawFlowArrow(SX1, SY1, SX2, SY2: Real);
Var MX, MY, DX, DY, L, UX, UY: Real;
Begin
 DX := SX2 - SX1; DY := SY2 - SY1;
 L := Sqrt(DX * DX + DY * DY);
 If L < 26 Then Exit;
 UX := DX / L; UY := DY / L;
 MX := (SX1 + SX2) / 2.0; MY := (SY1 + SY2) / 2.0;
 If (MX < 6) Or (MX > MAP_W - 6) Or (MY < 6) Or (MY > MAP_H - 6) Then Exit;
 Line(RoundInt(MX + UX * 4), RoundInt(MY + UY * 4),
      RoundInt(MX - UX * 4 - UY * 3), RoundInt(MY - UY * 4 + UX * 3));
 Line(RoundInt(MX + UX * 4), RoundInt(MY + UY * 4),
      RoundInt(MX - UX * 4 + UY * 3), RoundInt(MY - UY * 4 - UX * 3));
End;

Procedure DrawPipes;
Var
 I, Pass, Col: Integer;
 X1, Y1, X2, Y2: Real;
 Thick: Boolean;
 S: String;
Begin
 For Pass := 0 To 1 Do
  For I := 0 To PipeCnt - 1 Do Begin
   If PipeVisible(Pipes^[I]) And
      ((Pass = 1) = (Pipes^[I].Cls = PC_COLLECTEUR)) Then Begin
    W2S(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y, X1, Y1);
    W2S(Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y, X2, Y2);
    { sous-couches : galerie visitable, etat degrade }
    If Layers[L_VISITABLE].A And Pipes^[I].Visit Then Begin
     SetColor(LightCyan);
     SetLineStyle(SolidLn, 0, ThickWidth);
     ScreenLine(X1, Y1, X2, Y2);
    End;
    If Layers[L_DEGRADE].A And (Pipes^[I].State >= 2) Then Begin
     If Pipes^[I].State = 3 Then SetColor(Magenta) Else SetColor(Brown);
     SetLineStyle(SolidLn, 0, ThickWidth);
     ScreenLine(X1, Y1 - 1, X2, Y2 - 1);
    End;
    Col := PipeColor(Pipes^[I]);
    Thick := (Pipes^[I].Cls = PC_COLLECTEUR) Or
             (Layers[L_DIAM].A And (Pipes^[I].Diam >= 1000));
    SetColor(Col);
    If Thick Then SetLineStyle(SolidLn, 0, ThickWidth)
    Else SetLineStyle(SolidLn, 0, NormWidth);
    ScreenLine(X1, Y1, X2, Y2);
    SetLineStyle(SolidLn, 0, NormWidth);
    If ViewScale < 3.5 Then DrawFlowArrow(X1, Y1, X2, Y2);
    If Layers[PipeLayer(Pipes^[I].Cls)].T And (ViewScale < 6) Then Begin
     S := 'D' + IntToStr(Pipes^[I].Diam);
     If ((X1 + X2) / 2 > 0) And ((X1 + X2) / 2 < MAP_W - 40) And
        ((Y1 + Y2) / 2 > 4) And ((Y1 + Y2) / 2 < MAP_H - 10) Then Begin
      SetColor(Col);
      OutTextXY(RoundInt((X1 + X2) / 2) + 3, RoundInt((Y1 + Y2) / 2) + 3, S);
     End;
    End;
   End;
  End;
 { traces et selection (par dessus) }
 For I := 0 To PipeCnt - 1 Do Begin
  If TraceActive And TracePipe^[I] Then Begin
   W2S(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y, X1, Y1);
   W2S(Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y, X2, Y2);
   SetColor(CLR_TRACE);
   SetLineStyle(SolidLn, 0, ThickWidth);
   ScreenLine(X1, Y1, X2, Y2);
   SetLineStyle(SolidLn, 0, NormWidth);
  End;
  If Pipes^[I].Sel Then Begin
   W2S(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y, X1, Y1);
   W2S(Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y, X2, Y2);
   SetColor(CLR_SELECT);
   SetLineStyle(SolidLn, 0, ThickWidth);
   ScreenLine(X1, Y1, X2, Y2);
   SetLineStyle(SolidLn, 0, NormWidth);
  End;
 End;
End;

Procedure DrawNodeSymbol(SX, SY: Integer; Kind: Integer);
Begin
 Case Kind Of
  NK_REGARD: Begin
   SetFillStyle(SolidFill, Black);
   If ViewScale < 3 Then Bar(SX - 2, SY - 2, SX + 2, SY + 2)
   Else Bar(SX - 1, SY - 1, SX + 1, SY + 1);
  End;
  NK_VANNE: Begin
   SetColor(Red);
   Line(SX - 4, SY - 3, SX + 4, SY + 3);
   Line(SX + 4, SY + 3, SX + 4, SY - 3);
   Line(SX + 4, SY - 3, SX - 4, SY + 3);
   Line(SX - 4, SY + 3, SX - 4, SY - 3);
  End;
  NK_BASSIN: Begin
   SetFillStyle(SolidFill, LightBlue);
   Bar(SX - 5, SY - 5, SX + 5, SY + 5);
   SetColor(Blue);
   Rectangle(SX - 5, SY - 5, SX + 5, SY + 5);
  End;
  NK_POMPAGE: Begin
   SetFillStyle(SolidFill, LightMagenta);
   SetColor(Magenta);
   FillEllipse(SX, SY, 5, 5);
   SetColor(White);
   OutTextXY(SX - 3, SY - 3, 'P');
  End;
  NK_DEVERSOIR: Begin
   SetColor(Brown);
   Line(SX - 5, SY + 4, SX + 5, SY + 4);
   Line(SX + 5, SY + 4, SX, SY - 5);
   Line(SX, SY - 5, SX - 5, SY + 4);
  End;
 Else Begin
  SetFillStyle(SolidFill, Green);
  SetColor(Black);
  FillEllipse(SX, SY, 5, 5);
 End;
 End;
End;

Procedure DrawNodes;
Var
 I, L: Integer;
 SX, SY: Real;
 X, Y: Integer;
 S: String;
Begin
 For I := 0 To NodeCnt - 1 Do Begin
  L := NodeLayer(Nodes^[I].Kind);
  W2S(Nodes^[I].X, Nodes^[I].Y, SX, SY);
  If (SX > -10) And (SX < MAP_W + 10) And (SY > -10) And (SY < MAP_H + 10) Then Begin
   X := RoundInt(SX); Y := RoundInt(SY);
   If Layers[L].A And ((Nodes^[I].Kind <> NK_REGARD) Or (ViewScale < 14)) Then Begin
    DrawNodeSymbol(X, Y, Nodes^[I].Kind);
    If Layers[L].T And (ViewScale < 8) Then Begin
     If Nodes^[I].Name <> '' Then S := Nodes^[I].Name Else S := Nodes^[I].Id;
     SetColor(Black);
     OutTextXY(X + 6, Y - 4, S);
    End;
   End;
   If TraceActive And TraceNode^[I] Then Begin
    SetColor(CLR_TRACE);
    Circle(X, Y, 4);
   End;
   If Nodes^[I].Sel Then Begin
    SetColor(CLR_SELECT);
    If (SelKind = SEL_NODE) And (SelIdx = I) Then Begin
     SetLineStyle(SolidLn, 0, ThickWidth);
     Circle(X, Y, 7);
     SetLineStyle(SolidLn, 0, NormWidth);
    End Else Circle(X, Y, 4);
   End;
  End;
 End;
End;

Procedure MarkerPos(TKind, TIdx: Integer; DX, DY: Integer; Var X, Y: Integer; Var Ok: Boolean);
Var WX, WY, SX, SY: Real;
Begin
 Ok := False;
 X := 0; Y := 0;
 If ((TKind = 1) And ValidNode(TIdx)) Or ((TKind = 2) And ValidPipe(TIdx)) Then Begin
  ObjPos(TKind, TIdx, WX, WY);
  W2S(WX, WY, SX, SY);
  If (SX > -10) And (SX < MAP_W + 10) And (SY > -10) And (SY < MAP_H + 10) Then Begin
   X := RoundInt(SX) + DX; Y := RoundInt(SY) + DY;
   Ok := True;
  End;
 End;
End;

Procedure DrawMarkers;
Var I, X, Y: Integer; Ok: Boolean; SX, SY: Real;
Begin
 { etablissements (CARINE) }
 If Layers[L_ETAB].A And (ViewScale < 12) Then
  For I := 0 To EstCnt - 1 Do Begin
   If ValidNode(Estabs^[I].Node) Then Begin
    W2S(Nodes^[Estabs^[I].Node].X, Nodes^[Estabs^[I].Node].Y, SX, SY);
    If (SX > -10) And (SX < MAP_W + 10) And (SY > -10) And (SY < MAP_H + 10) Then Begin
     X := RoundInt(SX) + 5; Y := RoundInt(SY) - 5;
     SetColor(Black);
     SetFillStyle(SolidFill, Yellow);
     Bar(X - 3, Y - 3, X + 3, Y + 3);
     Rectangle(X - 3, Y - 3, X + 3, Y + 3);
     If Layers[L_ETAB].T And (ViewScale < 4) Then OutTextXY(X + 5, Y - 3, Copy(Estabs^[I].Name, 1, 14));
     If (SelKind = SEL_ESTAB) And (SelIdx = I) Then Begin
      SetColor(CLR_SELECT); Circle(X, Y, 8);
     End;
    End;
   End;
  End;
 { evenements }
 For I := 0 To EvCnt - 1 Do Begin
  If ((Events^[I].Status < 2) And Layers[L_EV_OUVERT].A) Or
     ((Events^[I].Status = 2) And Layers[L_EV_CLOS].A) Then Begin
   MarkerPos(Events^[I].TKind, Events^[I].TIdx, 6, 6, X, Y, Ok);
   If Ok Then Begin
    If Events^[I].Status = 2 Then SetFillStyle(SolidFill, DarkGray)
    Else SetFillStyle(SolidFill, LightRed);
    SetColor(Black);
    FillEllipse(X, Y, 5, 5);
    SetColor(White);
    OutTextXY(X - 3, Y - 3, '!');
    If (SelKind = SEL_EVENT) And (SelIdx = I) Then Begin
     SetColor(CLR_SELECT); Circle(X, Y, 9);
    End;
   End;
  End;
 End;
 { interventions }
 For I := 0 To IvCnt - 1 Do Begin
  If ((Intervs^[I].Status = 1) And Layers[L_CHANTIER].A) Or
     ((Intervs^[I].Status = 0) And Layers[L_PLANIFIE].A) Or
     ((Intervs^[I].Status = 2) And Layers[L_IV_FINI].A) Then Begin
   MarkerPos(Intervs^[I].TKind, Intervs^[I].TIdx, -6, 6, X, Y, Ok);
   If Ok Then Begin
    Case Intervs^[I].Status Of
     0: SetFillStyle(SolidFill, LightBlue);
     1: SetFillStyle(SolidFill, Brown);
    Else SetFillStyle(SolidFill, LightGreen);
    End;
    SetColor(Black);
    Bar(X - 4, Y - 4, X + 4, Y + 4);
    Rectangle(X - 4, Y - 4, X + 4, Y + 4);
    If Intervs^[I].Status = 1 Then Begin
     SetColor(Yellow);
     Line(X - 3, Y - 3, X + 3, Y + 3);
     Line(X - 3, Y + 3, X + 3, Y - 3);
    End;
    If (SelKind = SEL_INTERV) And (SelIdx = I) Then Begin
     SetColor(CLR_SELECT); Circle(X, Y, 9);
    End;
   End;
  End;
 End;
End;

Procedure DrawScaleBar;
Var
 Cand: Array[0..8] Of Real;
 I: Integer;
 L, PX: Real;
 X0, Y0, W, K: Integer;
 S: String;
Begin
 Cand[0] := 10; Cand[1] := 20; Cand[2] := 50; Cand[3] := 100; Cand[4] := 200;
 Cand[5] := 500; Cand[6] := 1000; Cand[7] := 2000; Cand[8] := 5000;
 L := 5000;
 For I := 0 To 8 Do
  If Cand[I] / ViewScale >= 50 Then Begin L := Cand[I]; Break; End;
 PX := L / ViewScale;
 If PX > 200 Then Exit;
 W := RoundInt(PX);
 X0 := 10; Y0 := MAP_H - 14;
 SetFillStyle(SolidFill, White);
 Bar(X0 - 4, Y0 - 12, X0 + W + 34, Y0 + 10);
 SetColor(Black);
 Rectangle(X0, Y0, X0 + W, Y0 + 4);
 SetFillStyle(SolidFill, Black);
 For K := 0 To 3 Do
  If K Mod 2 = 0 Then Bar(X0 + (W * K) Div 4, Y0, X0 + (W * (K + 1)) Div 4, Y0 + 4);
 If L >= 1000 Then S := IntToStr(Round(L / 1000)) + ' km' Else S := IntToStr(Round(L)) + ' m';
 OutTextXY(X0, Y0 - 10, S);
End;

Procedure DrawNorth;
Var X, Y: Integer;
Begin
 X := MAP_W - 20; Y := 26;
 SetColor(Black);
 SetFillStyle(SolidFill, White);
 Bar(X - 12, Y - 20, X + 12, Y + 10);
 Rectangle(X - 12, Y - 20, X + 12, Y + 10);
 Line(X, Y + 6, X, Y - 10);
 Line(X, Y - 10, X - 4, Y - 4);
 Line(X, Y - 10, X + 4, Y - 4);
 OutTextXY(X - 3, Y - 19, 'N');
End;

Procedure DrawLegend;
Const
 Labs : Array[0..3] Of String[8] = ('<50%', '50-80%', '80-100%', '>100%');
 Cols : Array[0..3] Of Integer = (Green, Brown, LightRed, Magenta);
 LabsP: Array[0..3] Of String[8] = ('<0.05%', '<0.2%', '<1%', '>1%');
 ColsP: Array[0..3] Of Integer = (Magenta, Blue, Green, Brown);
Var I, X, Y: Integer;
Begin
 If Not (Layers[L_REMPLI].A Or Layers[L_PENTE].A) Then Exit;
 X := MAP_W - 100; Y := MAP_H - 62;
 SetFillStyle(SolidFill, White);
 Bar(X - 4, Y - 14, X + 94, Y + 50);
 SetColor(Black);
 Rectangle(X - 4, Y - 14, X + 94, Y + 50);
 If Layers[L_REMPLI].A Then OutTextXY(X, Y - 10, 'Remplissage')
 Else OutTextXY(X, Y - 10, 'Pente');
 For I := 0 To 3 Do Begin
  If Layers[L_REMPLI].A Then SetFillStyle(SolidFill, Cols[I])
  Else SetFillStyle(SolidFill, ColsP[I]);
  Bar(X, Y + I * 11, X + 12, Y + I * 11 + 7);
  SetColor(Black);
  If Layers[L_REMPLI].A Then OutTextXY(X + 16, Y + I * 11, Labs[I])
  Else OutTextXY(X + 16, Y + I * 11, LabsP[I]);
 End;
End;

Procedure DrawCartouche;
Var S: String;
Begin
 SetFillStyle(SolidFill, White);
 Bar(6, 6, 232, 52);
 SetColor(Black);
 Rectangle(6, 6, 232, 52);
 Rectangle(8, 8, 230, 50);
 SetColor(Blue);
 OutTextXY(14, 12, Copy(PlanOrg, 1, 26));
 SetColor(Black);
 OutTextXY(14, 24, Copy(PlanTitle, 1, 26));
 S := 'Echelle 1 : ' + FmtThousands(ScaleDenominator);
 OutTextXY(14, 36, S);
End;

Procedure DrawMeasure;
Var I: Integer; SX, SY, PX, PY: Real;
Begin
 If MeasCnt = 0 Then Exit;
 SetColor(Blue);
 SetLineStyle(SolidLn, 0, NormWidth);
 PX := 0; PY := 0;
 For I := 0 To MeasCnt - 1 Do Begin
  W2S(MeasPts[I].X, MeasPts[I].Y, SX, SY);
  If (SX > -10) And (SX < MAP_W + 10) And (SY > -10) And (SY < MAP_H + 10) Then Begin
   Line(RoundInt(SX) - 3, RoundInt(SY) - 3, RoundInt(SX) + 3, RoundInt(SY) + 3);
   Line(RoundInt(SX) - 3, RoundInt(SY) + 3, RoundInt(SX) + 3, RoundInt(SY) - 3);
  End;
  If I > 0 Then ScreenLine(PX, PY, SX, SY);
  PX := SX; PY := SY;
 End;
 If PX > 0 Then Begin
  SetFillStyle(SolidFill, White);
  Bar(RoundInt(PX) + 6, RoundInt(PY) - 12, RoundInt(PX) + 10 + 8 * 11, RoundInt(PY) - 2);
  SetColor(Blue);
  OutTextXY(RoundInt(PX) + 8, RoundInt(PY) - 10, RealToStr(MeasLen, 0, 1) + ' m');
 End;
End;

Procedure DrawMap;
Begin
 SetViewPort(MAP_X1, MAP_Y1, MAP_X2, MAP_Y2, True);
 SetFillStyle(SolidFill, CLR_MAP_BG);
 Bar(0, 0, MAP_W, MAP_H);
 SetLineStyle(SolidLn, 0, NormWidth);
 If Layers[L_GRILLE].A Then DrawGrid;
 DrawBackground;
 DrawPipes;
 DrawNodes;
 DrawMarkers;
 DrawMeasure;
 DrawLegend;
 DrawScaleBar;
 DrawNorth;
 If ShowHeader Then DrawCartouche;
 SetViewPort(0, 0, GetMaxX, GetMaxY, False);
 SetLineStyle(SolidLn, 0, NormWidth);
 DrawRect(MAP_X1, MAP_Y1 - 1, MAP_X2 + 1, MAP_Y2 + 1, CLR_BORDER);
End;

{ ============================================================
  BARRE D'OUTILS
  ============================================================ }

Const
 NTOOLBTN = 9;
 ToolCaption : Array[0..NTOOLBTN - 1] Of String[8] =
  ('Select', 'Pan', 'Fenetre', 'Zoom+', 'Zoom-', 'Emprise', 'Mesure', '+Regard', '+Troncon');

Function ToolBtnX1(I: Integer): Integer;
Var K, X: Integer;
Begin
 X := 4;
 For K := 0 To I - 1 Do X := X + Length(ToolCaption[K]) * CHARW + 12;
 ToolBtnX1 := X;
End;

Function ToolBtnX2(I: Integer): Integer;
Begin
 ToolBtnX2 := ToolBtnX1(I) + Length(ToolCaption[I]) * CHARW + 10;
End;

Function ToolOfButton(I: Integer): Integer;
Begin
 Case I Of
  0: ToolOfButton := TL_SELECT;
  1: ToolOfButton := TL_PAN;
  2: ToolOfButton := TL_ZOOMWIN;
  6: ToolOfButton := TL_MEASURE;
  7: ToolOfButton := TL_ADDNODE;
  8: ToolOfButton := TL_ADDPIPE;
 Else ToolOfButton := -1;
 End;
End;

Procedure DrawToolbar;
Var I, X1, X2: Integer; Active: Boolean;
Begin
 FillRect(0, TOOLBAR_Y, SCREEN_W - 1, TOOLBAR_Y + TOOLBAR_H - 1, CLR_BACKGROUND);
 DrawHLine(0, SCREEN_W - 1, TOOLBAR_Y + TOOLBAR_H - 1, CLR_BORDER);
 For I := 0 To NTOOLBTN - 1 Do Begin
  X1 := ToolBtnX1(I);
  X2 := ToolBtnX2(I);
  Active := (ToolOfButton(I) = Tool) And (ToolOfButton(I) >= 0);
  DrawBox3D(X1, TOOLBAR_Y + 2, X2, TOOLBAR_Y + TOOLBAR_H - 3, Not Active,
            LightGray);
  If Active Then Begin
   FillRect(X1 + 1, TOOLBAR_Y + 3, X2 - 1, TOOLBAR_Y + TOOLBAR_H - 4, White);
  End;
  DrawCenteredText(X1, TOOLBAR_Y + 8, X2, Black, ToolCaption[I]);
 End;
 SetColor(Blue);
 OutTextXY(SCREEN_W - 108, TOOLBAR_Y + 4, 'TIGRE');
 SetColor(DarkGray);
 OutTextXY(SCREEN_W - 108, TOOLBAR_Y + 13, 'Reseau egouts');
End;

{ ============================================================
  PANNEAU DE DROITE (sections, couches, boutons)
  ============================================================ }

Const
 PNL_SEC_Y0    = 47;
 PNL_SEC_H     = 15;
 PNL_COLH_Y    = 153;
 PNL_LAYER_Y0  = 165;
 PNL_ROW_H     = 11;
 PNL_BTN_Y0    = 284;
 PNL_BTN_H     = 14;
 PNL_INFO_Y0   = 380;
 PNL_SEARCH_Y  = 418;
 PNL_LOGO_Y    = 434;
 COL_A_X       = 584;
 COL_R_X       = 600;
 COL_T_X       = 616;
 NPANBTN       = 12;
 PanCaption : Array[0..NPANBTN - 1] Of String[8] =
  ('Select.', 'Cadrer', 'Spatial', 'Emprise', 'Logique', 'Lister',
   'Specif.', 'Sauver', 'Entete', 'Macro', 'Tout', 'Reinit.');

Function LayerOfRow(Sec, Row: Integer): Integer;
Var I, C: Integer;
Begin
 LayerOfRow := -1;
 C := 0;
 For I := 0 To NLAYERS - 1 Do
  If Layers[I].Sec = Sec Then Begin
   If C = Row Then Begin LayerOfRow := I; Exit; End;
   Inc(C);
  End;
End;

Procedure DrawCheckBox(X, Y: Integer; Checked: Boolean);
Begin
 DrawBox3D(X, Y, X + 9, Y + 9, False, White);
 If Checked Then Begin
  SetColor(Black);
  Line(X + 2, Y + 2, X + 7, Y + 7);
  Line(X + 2, Y + 7, X + 7, Y + 2);
 End;
End;

Procedure SelInfoLines(Var L: Array Of TStr23);
Var N: Integer; S: String;
Begin
 L[0] := ''; L[1] := ''; L[2] := ''; L[3] := '';
 N := SelCount;
 If N > 1 Then Begin
  L[0] := IntToStr(N) + ' objets';
  L[1] := 'selectionnes';
  Exit;
 End;
 Case SelKind Of
  SEL_NODE: If ValidNode(SelIdx) Then Begin
   L[0] := NodeKindName[Nodes^[SelIdx].Kind] + ' ' + Nodes^[SelIdx].Id;
   L[1] := 'Z ' + RealToStr(Nodes^[SelIdx].Cote, 0, 2) + ' R ' + RealToStr(Nodes^[SelIdx].Radier, 0, 2);
   L[2] := SectorName[Nodes^[SelIdx].Sector];
   L[3] := 'Q ' + RealToStr(Nodes^[SelIdx].Flow, 0, 1) + ' L/s';
  End;
  SEL_PIPE: If ValidPipe(SelIdx) Then Begin
   L[0] := 'Troncon ' + Pipes^[SelIdx].Id;
   L[1] := 'D' + IntToStr(Pipes^[SelIdx].Diam) + ' ' + PipeClsName[Pipes^[SelIdx].Cls];
   L[2] := RealToStr(Pipes^[SelIdx].Len, 0, 0) + 'm p=' + RealToStr(Pipes^[SelIdx].Slope * 1000, 0, 1) + 'pm';
   If Pipes^[SelIdx].Fill > 1 Then S := 'en charge'
   Else S := RealToStr(Pipes^[SelIdx].Fill * 100, 0, 0) + '%';
   L[3] := 'Rempl. ' + S;
  End;
  SEL_ESTAB: If (SelIdx >= 0) And (SelIdx < EstCnt) Then Begin
   L[0] := 'Etablissement';
   L[1] := Copy(Estabs^[SelIdx].Name, 1, 18);
   L[2] := 'NAF ' + Estabs^[SelIdx].Naf;
   L[3] := RealToStr(Estabs^[SelIdx].Flow, 0, 1) + ' m3/j';
  End;
  SEL_EVENT: If (SelIdx >= 0) And (SelIdx < EvCnt) Then Begin
   L[0] := 'Evenement ' + Events^[SelIdx].Id;
   L[1] := EvKindName[Events^[SelIdx].Kind];
   L[2] := EvStatName[Events^[SelIdx].Status];
   L[3] := Events^[SelIdx].Date;
  End;
  SEL_INTERV: If (SelIdx >= 0) And (SelIdx < IvCnt) Then Begin
   L[0] := 'Interv. ' + Intervs^[SelIdx].Id;
   L[1] := IvKindName[Intervs^[SelIdx].Kind];
   L[2] := IvStatName[Intervs^[SelIdx].Status];
   L[3] := Intervs^[SelIdx].Date;
  End;
 Else Begin
  L[0] := 'Aucun objet';
  L[1] := 'selectionne.';
 End;
 End;
End;

Procedure DrawPanel;
Var
 I, Y, X1, X2, Row, Li: Integer;
 Info: Array[0..3] Of TStr23;
 Col: Integer;
Begin
 FillRect(PANEL_X1 - 1, MAP_Y1 - 1, PANEL_X2, MAP_Y2 + 1, CLR_BACKGROUND);
 { sections }
 For I := 0 To NSECTIONS - 1 Do Begin
  Y := PNL_SEC_Y0 + I * PNL_SEC_H;
  If I = OpenSection Then Col := CLR_SECTION_OPEN Else Col := CLR_SECTION;
  DrawBox3D(PANEL_X1 + 2, Y, PANEL_X2 - 2, Y + PNL_SEC_H - 2, I <> OpenSection, Col);
  If I = OpenSection Then SetColor(Black) Else SetColor(White);
  OutTextXY(PANEL_X1 + 6, Y + 4, SectionName[I]);
 End;
 { couches de la section ouverte }
 SetColor(Black);
 OutTextXY(COL_A_X, PNL_COLH_Y, 'A');
 OutTextXY(COL_R_X, PNL_COLH_Y, 'R');
 OutTextXY(COL_T_X, PNL_COLH_Y, 'T');
 DrawHLine(PANEL_X1 + 2, PANEL_X2 - 2, PNL_COLH_Y + 10, CLR_BORDER);
 Row := 0;
 Repeat
  Li := LayerOfRow(OpenSection, Row);
  If Li >= 0 Then Begin
   Y := PNL_LAYER_Y0 + Row * PNL_ROW_H;
   SetColor(Black);
   OutTextXY(PANEL_X1 + 6, Y + 1, Copy(Layers[Li].Name, 1, 11));
   DrawCheckBox(COL_A_X, Y, Layers[Li].A);
   DrawCheckBox(COL_R_X, Y, Layers[Li].R);
   DrawCheckBox(COL_T_X, Y, Layers[Li].T);
  End;
  Inc(Row);
 Until Li < 0;
 { boutons d'action }
 For I := 0 To NPANBTN - 1 Do Begin
  X1 := PANEL_X1 + 2 + (I Mod 2) * 74;
  X2 := X1 + 72;
  Y := PNL_BTN_Y0 + (I Div 2) * (PNL_BTN_H + 1);
  Col := LightGray;
  DrawBox3D(X1, Y, X2, Y + PNL_BTN_H - 1, Not ((I = 0) And (Tool = TL_SELECT)) And
            Not ((I = 2) And (Tool = TL_WINSEL)), Col);
  DrawCenteredText(X1, Y + 3, X2, Black, PanCaption[I]);
 End;
 { informations sur la selection }
 DrawBox3D(PANEL_X1 + 2, PNL_INFO_Y0 - 3, PANEL_X2 - 2, PNL_INFO_Y0 + 37, False, White);
 SelInfoLines(Info);
 SetColor(Black);
 For I := 0 To 3 Do OutTextXY(PANEL_X1 + 5, PNL_INFO_Y0 + I * 9, Copy(Info[I], 1, 18));
 { recherche voie / documents }
 DrawBox3D(PANEL_X1 + 2, PNL_SEARCH_Y, PANEL_X1 + 75, PNL_SEARCH_Y + PNL_BTN_H - 1, True, LightGray);
 DrawCenteredText(PANEL_X1 + 2, PNL_SEARCH_Y + 3, PANEL_X1 + 75, Black, 'Rech.voie');
 DrawBox3D(PANEL_X1 + 76, PNL_SEARCH_Y, PANEL_X2 - 2, PNL_SEARCH_Y + PNL_BTN_H - 1, True, LightGray);
 DrawCenteredText(PANEL_X1 + 76, PNL_SEARCH_Y + 3, PANEL_X2 - 2, Black, 'Documents');
 { bandeau de l'organisme }
 FillRect(PANEL_X1 + 2, PNL_LOGO_Y, PANEL_X2 - 2, MAP_Y2 - 1, Blue);
 DrawCenteredText(PANEL_X1 + 2, PNL_LOGO_Y + 2, PANEL_X2 - 2, White, Copy(PlanOrg, 1, 18));
 FillRect(PANEL_X1 + 2, MAP_Y2 - 3, PANEL_X1 + 52, MAP_Y2 - 1, White);
 FillRect(PANEL_X1 + 52, MAP_Y2 - 3, PANEL_X2 - 52, MAP_Y2 - 1, Red);
End;

{ ============================================================
  BARRE D'ETAT
  ============================================================ }

Procedure DrawStatusBar;
Var
 S, Sec: String;
 N: Integer;
 WX1, WY1, WX2, WY2: Real;
Begin
 FillRect(0, STATUS_Y, SCREEN_W - 1, SCREEN_H - 1, CLR_STATUS_BG);
 SetColor(CLR_STATUS_TEXT);
 OutTextXY(6, STATUS_Y + 4, Copy(StatusMsg, 1, 76));
 DrawHLine(0, SCREEN_W - 1, STATUS_Y + 15, Black);
 N := NearestNode(ViewCX, ViewCY);
 If N >= 0 Then Sec := SectorName[Nodes^[N].Sector] Else Sec := '-';
 SetColor(Yellow);
 OutTextXY(6, STATUS_Y + 20, Copy(Sec, 1, 18));
 SetColor(CLR_STATUS_TEXT);
 OutTextXY(170, STATUS_Y + 20, '1 : ' + FmtThousands(ScaleDenominator));
 S := '';
 If CurOnMap Then S := 'X ' + RealToStr(CurMapX, 0, 0) + '  Y ' + RealToStr(CurMapY, 0, 0);
 OutTextXY(290, STATUS_Y + 20, S);
 S2W(0, MAP_H, WX1, WY1);
 S2W(MAP_W, 0, WX2, WY2);
 S := RealToStr((WX2 - WX1) / 1000.0, 0, 2) + ' x ' + RealToStr((WY2 - WY1) / 1000.0, 0, 2) + ' km';
 OutTextXY(SCREEN_W - Length(S) * CHARW - 8, STATUS_Y + 20, S);
End;

Procedure SetStatus(Msg: String);
Begin
 StatusMsg := Msg;
 HideMouse;
 DrawStatusBar;
 ShowMouse;
End;

Procedure RedrawMapOnly;
Begin
 HideMouse;
 DrawMap;
 DrawStatusBar;
 ShowMouse;
End;

Procedure RedrawPanelOnly;
Begin
 HideMouse;
 DrawPanel;
 ShowMouse;
End;

Procedure RedrawAll;
Begin
 HideMouse;
 FillRect(0, MENUBAR_HEIGHT, SCREEN_W - 1, SCREEN_H - 1, CLR_BACKGROUND);
 DrawMenuBar;
 DrawToolbar;
 DrawMap;
 DrawPanel;
 DrawStatusBar;
 ShowMouse;
End;

{ ============================================================
  NAVIGATION, SELECTION, PICKING
  ============================================================ }

Procedure ClampView;
Begin
 If ViewScale < 0.15 Then ViewScale := 0.15;
 If ViewScale > 60 Then ViewScale := 60;
End;

Procedure ZoomBy(F: Real);
Begin
 ViewScale := ViewScale / F;
 ClampView;
 RedrawMapOnly;
End;

Procedure PanPixels(DX, DY: Real);
Begin
 ViewCX := ViewCX - DX * ViewScale;
 ViewCY := ViewCY + DY * ViewScale;
End;

Procedure CenterOn(WX, WY: Real);
Begin
 ViewCX := WX;
 ViewCY := WY;
End;

Procedure ZoomWindow(SX1, SY1, SX2, SY2: Real);
Var WX1, WY1, WX2, WY2: Real;
Begin
 If (RAbs(SX2 - SX1) < 6) Or (RAbs(SY2 - SY1) < 6) Then Begin
  ZoomBy(2.0);
  Exit;
 End;
 S2W(SX1, SY1, WX1, WY1);
 S2W(SX2, SY2, WX2, WY2);
 FitRect(RMin(WX1, WX2), RMin(WY1, WY2), RMax(WX1, WX2), RMax(WY1, WY2));
 ClampView;
 RedrawMapOnly;
End;

Function PointSegDist(PX, PY, AX, AY, BX, BY: Real): Real;
Var DX, DY, L2, T: Real;
Begin
 DX := BX - AX; DY := BY - AY;
 L2 := DX * DX + DY * DY;
 If L2 <= 0 Then T := 0 Else T := ((PX - AX) * DX + (PY - AY) * DY) / L2;
 If T < 0 Then T := 0;
 If T > 1 Then T := 1;
 PointSegDist := Sqrt(Sqr(PX - AX - T * DX) + Sqr(PY - AY - T * DY));
End;

Procedure SetSelection(K, Idx: Integer);
Begin
 ClearSelection;
 SelKind := K;
 SelIdx := Idx;
 If (K = SEL_NODE) And ValidNode(Idx) Then Nodes^[Idx].Sel := True
 Else If (K = SEL_PIPE) And ValidPipe(Idx) Then Pipes^[Idx].Sel := True;
End;

{ MX, MY : coordonnees relatives a la carte }
Function PickAt(MX, MY: Real; Var K, Idx: Integer): Boolean;
Var
 I, L, X, Y: Integer;
 SX, SY, X1, Y1, X2, Y2, D, Best: Real;
 Ok: Boolean;
Begin
 PickAt := False;
 K := SEL_NONE; Idx := -1;
 { marqueurs : etablissements, evenements, interventions }
 Best := 6.5;
 If Layers[L_ETAB].A And Layers[L_ETAB].R And (ViewScale < 12) Then
  For I := 0 To EstCnt - 1 Do
   If ValidNode(Estabs^[I].Node) Then Begin
    W2S(Nodes^[Estabs^[I].Node].X, Nodes^[Estabs^[I].Node].Y, SX, SY);
    D := Sqrt(Sqr(SX + 5 - MX) + Sqr(SY - 5 - MY));
    If D < Best Then Begin Best := D; K := SEL_ESTAB; Idx := I; End;
   End;
 For I := 0 To EvCnt - 1 Do
  If ((Events^[I].Status < 2) And Layers[L_EV_OUVERT].A And Layers[L_EV_OUVERT].R) Or
     ((Events^[I].Status = 2) And Layers[L_EV_CLOS].A And Layers[L_EV_CLOS].R) Then Begin
   MarkerPos(Events^[I].TKind, Events^[I].TIdx, 6, 6, X, Y, Ok);
   If Ok Then Begin
    D := Sqrt(Sqr(X - MX) + Sqr(Y - MY));
    If D < Best Then Begin Best := D; K := SEL_EVENT; Idx := I; End;
   End;
  End;
 For I := 0 To IvCnt - 1 Do
  If ((Intervs^[I].Status = 1) And Layers[L_CHANTIER].A And Layers[L_CHANTIER].R) Or
     ((Intervs^[I].Status = 0) And Layers[L_PLANIFIE].A And Layers[L_PLANIFIE].R) Or
     ((Intervs^[I].Status = 2) And Layers[L_IV_FINI].A And Layers[L_IV_FINI].R) Then Begin
   MarkerPos(Intervs^[I].TKind, Intervs^[I].TIdx, -6, 6, X, Y, Ok);
   If Ok Then Begin
    D := Sqrt(Sqr(X - MX) + Sqr(Y - MY));
    If D < Best Then Begin Best := D; K := SEL_INTERV; Idx := I; End;
   End;
  End;
 If K <> SEL_NONE Then Begin PickAt := True; Exit; End;
 { noeuds }
 Best := 8.0;
 For I := 0 To NodeCnt - 1 Do Begin
  L := NodeLayer(Nodes^[I].Kind);
  If Layers[L].A And Layers[L].R And
     ((Nodes^[I].Kind <> NK_REGARD) Or (ViewScale < 14)) Then Begin
   W2S(Nodes^[I].X, Nodes^[I].Y, SX, SY);
   D := Sqrt(Sqr(SX - MX) + Sqr(SY - MY));
   If D < Best Then Begin Best := D; K := SEL_NODE; Idx := I; End;
  End;
 End;
 If K <> SEL_NONE Then Begin PickAt := True; Exit; End;
 { conduites }
 Best := 5.5;
 For I := 0 To PipeCnt - 1 Do
  If PipeVisible(Pipes^[I]) And Layers[PipeLayer(Pipes^[I].Cls)].R Then Begin
   W2S(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y, X1, Y1);
   W2S(Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y, X2, Y2);
   D := PointSegDist(MX, MY, X1, Y1, X2, Y2);
   If D < Best Then Begin Best := D; K := SEL_PIPE; Idx := I; End;
  End;
 PickAt := K <> SEL_NONE;
End;

Function ObjectDescription(K, Idx: Integer): String;
Begin
 ObjectDescription := '';
 Case K Of
  SEL_NODE: If ValidNode(Idx) Then
   ObjectDescription := NodeKindName[Nodes^[Idx].Kind] + ' ' + Nodes^[Idx].Id + ' ' +
    Nodes^[Idx].Name + ' - Z ' + RealToStr(Nodes^[Idx].Cote, 0, 2) + ' m';
  SEL_PIPE: If ValidPipe(Idx) Then
   ObjectDescription := 'Troncon ' + Pipes^[Idx].Id + ' - ' + PipeClsName[Pipes^[Idx].Cls] +
    ' D' + IntToStr(Pipes^[Idx].Diam) + ' - L ' + RealToStr(Pipes^[Idx].Len, 0, 1) + ' m';
  SEL_ESTAB: If (Idx >= 0) And (Idx < EstCnt) Then
   ObjectDescription := 'Etablissement ' + Estabs^[Idx].Name;
  SEL_EVENT: If (Idx >= 0) And (Idx < EvCnt) Then
   ObjectDescription := 'Evenement ' + Events^[Idx].Id + ' - ' + EvKindName[Events^[Idx].Kind];
  SEL_INTERV: If (Idx >= 0) And (Idx < IvCnt) Then
   ObjectDescription := 'Intervention ' + Intervs^[Idx].Id + ' - ' + IvKindName[Intervs^[Idx].Kind];
 End;
End;

Procedure GotoObject(K, Idx: Integer);
Var WX, WY: Real; TK, TI: Integer;
Begin
 Case K Of
  SEL_NODE, SEL_PIPE: Begin
   SetSelection(K, Idx);
   If K = SEL_NODE Then ObjPos(1, Idx, WX, WY) Else ObjPos(2, Idx, WX, WY);
   CenterOn(WX, WY);
  End;
  SEL_ESTAB: If (Idx >= 0) And (Idx < EstCnt) And ValidNode(Estabs^[Idx].Node) Then Begin
   SetSelection(K, Idx);
   CenterOn(Nodes^[Estabs^[Idx].Node].X, Nodes^[Estabs^[Idx].Node].Y);
  End;
  SEL_EVENT: If (Idx >= 0) And (Idx < EvCnt) Then Begin
   SetSelection(K, Idx);
   ObjPos(Events^[Idx].TKind, Events^[Idx].TIdx, WX, WY);
   If Events^[Idx].TKind <> 0 Then CenterOn(WX, WY);
  End;
  SEL_INTERV: If (Idx >= 0) And (Idx < IvCnt) Then Begin
   SetSelection(K, Idx);
   ObjPos(Intervs^[Idx].TKind, Intervs^[Idx].TIdx, WX, WY);
   If Intervs^[Idx].TKind <> 0 Then CenterOn(WX, WY);
  End;
 End;
 If ViewScale > 8 Then ViewScale := 3.0;
 TK := K; TI := Idx;
 StatusMsg := ObjectDescription(TK, TI);
 RedrawAll;
End;

Procedure FrameSelection;
Var
 I, N: Integer;
 MinX, MinY, MaxX, MaxY: Real;
 Procedure Add(X, Y: Real);
 Begin
  If N = 0 Then Begin MinX := X; MaxX := X; MinY := Y; MaxY := Y; End
  Else Begin
   If X < MinX Then MinX := X;
   If X > MaxX Then MaxX := X;
   If Y < MinY Then MinY := Y;
   If Y > MaxY Then MaxY := Y;
  End;
  Inc(N);
 End;
Begin
 N := 0; MinX := 0; MaxX := 0; MinY := 0; MaxY := 0;
 For I := 0 To NodeCnt - 1 Do
  If Nodes^[I].Sel Or (TraceActive And TraceNode^[I]) Then Add(Nodes^[I].X, Nodes^[I].Y);
 If N = 0 Then Begin
  If (SelKind <> SEL_NONE) Then GotoObject(SelKind, SelIdx)
  Else SetStatus('Rien a cadrer : aucune selection.');
  Exit;
 End;
 If N = 1 Then Begin
  CenterOn(MinX, MinY);
  ViewScale := 2.0;
 End Else Begin
  MinX := MinX - 40; MaxX := MaxX + 40; MinY := MinY - 40; MaxY := MaxY + 40;
  FitRect(MinX, MinY, MaxX, MaxY);
 End;
 ClampView;
 RedrawAll;
End;

{ ============================================================
  DIALOGUES : proprietes des objets
  ============================================================ }

Function DlgNodeProps(I: Integer): Boolean;
Var
 R, eId, eName, eCote, eRad, eLoad, eArea, eYear, eSec, rKind, rState, K: Integer;
 S: String;
Begin
 DlgNodeProps := False;
 If Not ValidNode(I) Then Exit;
 DlgInit(Dlg, 'Proprietes - ' + Nodes^[I].Id, 440, 272);
 DlgAddLabel(Dlg, 10, 10, 'Identifiant');
 eId := DlgAddEdit(Dlg, 104, 6, 88, Nodes^[I].Id, 7);
 DlgAddLabel(Dlg, 10, 30, 'Cote TN (m)');
 eCote := DlgAddNumEdit(Dlg, 104, 26, 88, RealToStr(Nodes^[I].Cote, 0, 2), 9);
 DlgAddLabel(Dlg, 10, 50, 'Radier (m)');
 eRad := DlgAddNumEdit(Dlg, 104, 46, 88, RealToStr(Nodes^[I].Radier, 0, 2), 9);
 DlgAddLabel(Dlg, 10, 70, 'Debit (L/s)');
 eLoad := DlgAddNumEdit(Dlg, 104, 66, 88, RealToStr(Nodes^[I].Load, 0, 2), 9);
 DlgAddLabel(Dlg, 10, 90, 'Bassin (ha)');
 eArea := DlgAddNumEdit(Dlg, 104, 86, 88, RealToStr(Nodes^[I].Area, 0, 2), 9);
 DlgAddLabel(Dlg, 10, 110, 'Annee');
 eYear := DlgAddNumEdit(Dlg, 104, 106, 88, IntToStr(Nodes^[I].Year), 4);
 DlgAddLabel(Dlg, 10, 130, 'Secteur no');
 eSec := DlgAddNumEdit(Dlg, 104, 126, 88, IntToStr(Nodes^[I].Sector), 2);
 DlgAddLabel(Dlg, 10, 150, Copy(SectorName[Nodes^[I].Sector], 1, 24));
 DlgAddLabel(Dlg, 10, 164, 'Transit : ' + RealToStr(Nodes^[I].Flow, 0, 1) + ' L/s');
 DlgAddLabel(Dlg, 10, 188, 'Nom');
 eName := DlgAddEdit(Dlg, 104, 184, 324, Nodes^[I].Name, 23);
 DlgAddFrame(Dlg, 206, 2, 226, 76, 'Type d''ouvrage');
 rKind := Dlg.CtrlCount;
 For K := 0 To NK_COUNT - 1 Do
  DlgAddRadio(Dlg, 216 + (K Mod 2) * 106, 20 + (K Div 2) * 16, 100, NodeKindName[K], 1,
              K = Nodes^[I].Kind);
 DlgAddFrame(Dlg, 206, 88, 226, 52, 'Etat');
 rState := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddRadio(Dlg, 216 + (K Mod 2) * 106, 106 + (K Div 2) * 16, 100, StateName[K], 2,
              K = Nodes^[I].State);
 DlgAddButton(Dlg, 120, 218, 90, 'OK', 1, #0);
 DlgAddButton(Dlg, 230, 218, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  S := UpStr(TrimStr(Dlg.Ctrls[eId].Text));
  If (S <> '') And ((FindNodeById(S) < 0) Or (FindNodeById(S) = I)) Then Begin Nodes^[I].Id := S; HNodeOk := False; End
  Else ShowMessageBox('Identifiant', 'Identifiant vide ou deja utilise : conserve.');
  Nodes^[I].Name := Dlg.Ctrls[eName].Text;
  Nodes^[I].Cote := StrToRealDef(Dlg.Ctrls[eCote].Text, Nodes^[I].Cote);
  Nodes^[I].Radier := StrToRealDef(Dlg.Ctrls[eRad].Text, Nodes^[I].Radier);
  Nodes^[I].Load := StrToRealDef(Dlg.Ctrls[eLoad].Text, Nodes^[I].Load);
  Nodes^[I].Area := StrToRealDef(Dlg.Ctrls[eArea].Text, Nodes^[I].Area);
  Nodes^[I].Year := StrToIntDef(Dlg.Ctrls[eYear].Text, Nodes^[I].Year);
  Nodes^[I].Sector := IClamp(StrToIntDef(Dlg.Ctrls[eSec].Text, Nodes^[I].Sector), 0, MAX_SECTORS - 1);
  Nodes^[I].Kind := DlgRadioValue(Dlg, rKind, NK_COUNT);
  Nodes^[I].State := DlgRadioValue(Dlg, rState, 4);
  PlanDirty := True;
  ComputeHydraulics;
  DlgNodeProps := True;
 End;
End;

Function DlgPipeProps(I: Integer): Boolean;
Var
 R, eId, eDiam, eWid, eYear, cVis, rCls, rShape, rMat, rState, K: Integer;
 S: String;
Begin
 DlgPipeProps := False;
 If Not ValidPipe(I) Then Exit;
 DlgInit(Dlg, 'Proprietes - ' + Pipes^[I].Id, 500, 290);
 DlgAddLabel(Dlg, 10, 10, 'Identifiant');
 eId := DlgAddEdit(Dlg, 96, 6, 88, Pipes^[I].Id, 7);
 DlgAddLabel(Dlg, 10, 30, 'Haut. (mm)');
 eDiam := DlgAddNumEdit(Dlg, 96, 26, 88, IntToStr(Pipes^[I].Diam), 5);
 DlgAddLabel(Dlg, 10, 50, 'Larg. (mm)');
 eWid := DlgAddNumEdit(Dlg, 96, 46, 88, IntToStr(Pipes^[I].Width), 5);
 DlgAddLabel(Dlg, 10, 70, 'Annee');
 eYear := DlgAddNumEdit(Dlg, 96, 66, 88, IntToStr(Pipes^[I].Year), 4);
 cVis := DlgAddCheck(Dlg, 10, 90, 150, 'Visitable', Pipes^[I].Visit);
 DlgAddHLine(Dlg, 10, 110, 174);
 DlgAddLabel(Dlg, 10, 118, 'Amont ' + Nodes^[Pipes^[I].N1].Id);
 DlgAddLabel(Dlg, 10, 130, 'Aval  ' + Nodes^[Pipes^[I].N2].Id);
 DlgAddLabel(Dlg, 10, 142, 'Long. ' + RealToStr(Pipes^[I].Len, 0, 1) + ' m');
 DlgAddLabel(Dlg, 10, 154, 'Pente ' + RealToStr(Pipes^[I].Slope * 100, 0, 3) + ' %');
 DlgAddLabel(Dlg, 10, 166, 'Cap.  ' + RealToStr(Pipes^[I].QFull, 0, 0) + ' L/s');
 DlgAddLabel(Dlg, 10, 178, 'Debit ' + RealToStr(Pipes^[I].Flow, 0, 1) + ' L/s');
 DlgAddFrame(Dlg, 196, 2, 140, 78, 'Classe');
 rCls := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddRadio(Dlg, 204, 18 + K * 15, 124, PipeClsName[K], 1, K = Pipes^[I].Cls);
 DlgAddFrame(Dlg, 196, 90, 140, 78, 'Forme');
 rShape := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddRadio(Dlg, 204, 106 + K * 15, 124, ShapeName[K], 2, K = Pipes^[I].Shape);
 DlgAddFrame(Dlg, 346, 2, 144, 108, 'Materiau');
 rMat := Dlg.CtrlCount;
 For K := 0 To 5 Do
  DlgAddRadio(Dlg, 354, 18 + K * 15, 128, MatName[K], 3, K = Pipes^[I].Mat);
 DlgAddFrame(Dlg, 346, 118, 144, 78, 'Etat');
 rState := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddRadio(Dlg, 354, 134 + K * 15, 128, StateName[K], 4, K = Pipes^[I].State);
 DlgAddButton(Dlg, 150, 212, 90, 'OK', 1, #0);
 DlgAddButton(Dlg, 260, 212, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  S := UpStr(TrimStr(Dlg.Ctrls[eId].Text));
  If (S <> '') And ((FindPipeById(S) < 0) Or (FindPipeById(S) = I)) Then Begin Pipes^[I].Id := S; HPipeOk := False; End
  Else ShowMessageBox('Identifiant', 'Identifiant vide ou deja utilise : conserve.');
  Pipes^[I].Diam := IClamp(StrToIntDef(Dlg.Ctrls[eDiam].Text, Pipes^[I].Diam), 50, 9000);
  Pipes^[I].Width := IClamp(StrToIntDef(Dlg.Ctrls[eWid].Text, Pipes^[I].Width), 50, 12000);
  Pipes^[I].Year := StrToIntDef(Dlg.Ctrls[eYear].Text, Pipes^[I].Year);
  Pipes^[I].Visit := Dlg.Ctrls[cVis].Checked;
  Pipes^[I].Cls := DlgRadioValue(Dlg, rCls, 4);
  Pipes^[I].Shape := DlgRadioValue(Dlg, rShape, 4);
  Pipes^[I].Mat := DlgRadioValue(Dlg, rMat, 6);
  Pipes^[I].State := DlgRadioValue(Dlg, rState, 4);
  PlanDirty := True;
  ComputeHydraulics;
  DlgPipeProps := True;
 End;
End;

{ Edition d'un etablissement (Idx = EstCnt pour un nouvel enregistrement) }
Function DlgEstab(Idx: Integer): Boolean;
Var
 R, eName, eSap, eNaf, eCom, ePost, eNode, eFlow, N: Integer;
 NodeId: String;
 E: TEstab;
Begin
 DlgEstab := False;
 If Idx < EstCnt Then E := Estabs^[Idx]
 Else Begin
  E.Name := ''; E.Sap := ''; E.Naf := ''; E.Commune := ''; E.Post := '';
  E.Node := -1; E.Flow := 1.0;
  If SelKind = SEL_NODE Then E.Node := SelIdx;
 End;
 If ValidNode(E.Node) Then NodeId := Nodes^[E.Node].Id Else NodeId := '';
 DlgInit(Dlg, 'Etablissement', 430, 232);
 DlgAddLabel(Dlg, 10, 10, 'Raison sociale');
 eName := DlgAddEdit(Dlg, 140, 6, 272, E.Name, 39);
 DlgAddLabel(Dlg, 10, 32, 'Code SAP');
 eSap := DlgAddEdit(Dlg, 140, 28, 70, E.Sap, 5);
 DlgAddLabel(Dlg, 10, 54, 'Code NAF');
 eNaf := DlgAddEdit(Dlg, 140, 50, 80, E.Naf, 7);
 DlgAddLabel(Dlg, 10, 76, 'Commune');
 eCom := DlgAddEdit(Dlg, 140, 72, 200, E.Commune, 23);
 DlgAddLabel(Dlg, 10, 98, 'Code postal');
 ePost := DlgAddEdit(Dlg, 140, 94, 90, E.Post, 9);
 DlgAddLabel(Dlg, 10, 120, 'Regard raccorde');
 eNode := DlgAddEdit(Dlg, 140, 116, 90, NodeId, 7);
 DlgAddLabel(Dlg, 10, 142, 'Rejet (m3/jour)');
 eFlow := DlgAddNumEdit(Dlg, 140, 138, 90, RealToStr(E.Flow, 0, 1), 8);
 DlgAddButton(Dlg, 120, 170, 90, 'OK', 1, #0);
 DlgAddButton(Dlg, 230, 170, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  N := FindNodeById(Dlg.Ctrls[eNode].Text);
  If TrimStr(Dlg.Ctrls[eName].Text) = '' Then Begin
   ShowMessageBox('Etablissement', 'La raison sociale est obligatoire.');
   Exit;
  End;
  If N < 0 Then Begin
   ShowMessageBox('Etablissement', 'Regard introuvable : ' + Dlg.Ctrls[eNode].Text);
   Exit;
  End;
  If (Idx >= EstCnt) And (Not GrowEstabs(EstCnt + 1)) Then Begin
   ShowMessageBox('Etablissement', 'Nombre maximal d''etablissements atteint.');
   Exit;
  End;
  E.Name := UpStr(Dlg.Ctrls[eName].Text);
  E.Sap := Dlg.Ctrls[eSap].Text;
  E.Naf := Dlg.Ctrls[eNaf].Text;
  E.Commune := UpStr(Dlg.Ctrls[eCom].Text);
  E.Post := Dlg.Ctrls[ePost].Text;
  E.Node := N;
  E.Flow := StrToRealDef(Dlg.Ctrls[eFlow].Text, 0);
  If Idx >= EstCnt Then Begin
   Estabs^[EstCnt] := E;
   Inc(EstCnt);
  End Else Estabs^[Idx] := E;
  PlanDirty := True;
  ComputeHydraulics;
  DlgEstab := True;
 End;
End;

{ Nouvel evenement (Idx = EvCnt) ou edition }
Function DlgEvent(Idx: Integer): Boolean;
Var
 R, rKind, rStat, eDate, eDesc, K: Integer;
 E: TEvent;
Begin
 DlgEvent := False;
 If Idx < EvCnt Then E := Events^[Idx]
 Else Begin
  If Not GrowEvents(EvCnt + 1) Then Begin
   ShowMessageBox('Evenement', 'Nombre maximal d''evenements atteint.');
   Exit;
  End;
  E.Id := 'E' + PadZero(EvCnt + 1, 3);
  E.Kind := 0; E.Status := 0; E.Date := TodayStr; E.Desc := '';
  E.TKind := 0; E.TIdx := -1;
  If (SelKind = SEL_NODE) And ValidNode(SelIdx) Then Begin E.TKind := 1; E.TIdx := SelIdx; End
  Else If (SelKind = SEL_PIPE) And ValidPipe(SelIdx) Then Begin E.TKind := 2; E.TIdx := SelIdx; End;
 End;
 DlgInit(Dlg, 'Evenement ' + E.Id, 440, 250);
 DlgAddFrame(Dlg, 8, 2, 250, 66, 'Nature');
 rKind := Dlg.CtrlCount;
 For K := 0 To 5 Do
  DlgAddRadio(Dlg, 16 + (K Div 3) * 120, 18 + (K Mod 3) * 16, 114, EvKindName[K], 1, K = E.Kind);
 DlgAddFrame(Dlg, 268, 2, 160, 66, 'Statut');
 rStat := Dlg.CtrlCount;
 For K := 0 To 2 Do
  DlgAddRadio(Dlg, 276, 18 + K * 16, 146, EvStatName[K], 2, K = E.Status);
 DlgAddLabel(Dlg, 10, 84, 'Date (AAAA-MM-JJ)');
 eDate := DlgAddEdit(Dlg, 160, 80, 90, E.Date, 10);
 DlgAddLabel(Dlg, 10, 106, 'Description');
 eDesc := DlgAddEdit(Dlg, 10, 120, 416, E.Desc, 47);
 DlgAddLabel(Dlg, 10, 146, 'Ouvrage : ' + ObjLabel(E.TKind, E.TIdx));
 DlgAddButton(Dlg, 120, 172, 90, 'OK', 1, #0);
 DlgAddButton(Dlg, 230, 172, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  E.Kind := DlgRadioValue(Dlg, rKind, 6);
  E.Status := DlgRadioValue(Dlg, rStat, 3);
  E.Date := Dlg.Ctrls[eDate].Text;
  E.Desc := Dlg.Ctrls[eDesc].Text;
  If Idx >= EvCnt Then Begin
   Events^[EvCnt] := E;
   Inc(EvCnt);
  End Else Events^[Idx] := E;
  PlanDirty := True;
  DlgEvent := True;
 End;
End;

Function DlgInterv(Idx: Integer): Boolean;
Var
 R, rKind, rStat, eDate, eTeam, eCost, K: Integer;
 V: TInterv;
Begin
 DlgInterv := False;
 If Idx < IvCnt Then V := Intervs^[Idx]
 Else Begin
  If Not GrowIntervs(IvCnt + 1) Then Begin
   ShowMessageBox('Intervention', 'Nombre maximal d''interventions atteint.');
   Exit;
  End;
  V.Id := 'I' + PadZero(IvCnt + 1, 3);
  V.Kind := 0; V.Status := 0; V.Date := TodayStr; V.Team := 'Equipe A'; V.Cost := 0;
  V.TKind := 0; V.TIdx := -1;
  If (SelKind = SEL_NODE) And ValidNode(SelIdx) Then Begin V.TKind := 1; V.TIdx := SelIdx; End
  Else If (SelKind = SEL_PIPE) And ValidPipe(SelIdx) Then Begin V.TKind := 2; V.TIdx := SelIdx; End;
 End;
 DlgInit(Dlg, 'Intervention ' + V.Id, 490, 250);
 DlgAddFrame(Dlg, 8, 2, 306, 66, 'Nature');
 rKind := Dlg.CtrlCount;
 For K := 0 To 5 Do
  DlgAddRadio(Dlg, 16 + (K Div 3) * 150, 18 + (K Mod 3) * 16, 144, IvKindName[K], 1, K = V.Kind);
 DlgAddFrame(Dlg, 324, 2, 156, 66, 'Statut');
 rStat := Dlg.CtrlCount;
 For K := 0 To 2 Do
  DlgAddRadio(Dlg, 332, 18 + K * 16, 140, IvStatName[K], 2, K = V.Status);
 DlgAddLabel(Dlg, 10, 84, 'Date (AAAA-MM-JJ)');
 eDate := DlgAddEdit(Dlg, 160, 80, 90, V.Date, 10);
 DlgAddLabel(Dlg, 10, 106, 'Equipe');
 eTeam := DlgAddEdit(Dlg, 160, 102, 130, V.Team, 15);
 DlgAddLabel(Dlg, 10, 128, 'Cout estime');
 eCost := DlgAddNumEdit(Dlg, 160, 124, 90, RealToStr(V.Cost, 0, 0), 9);
 DlgAddLabel(Dlg, 10, 150, 'Ouvrage : ' + ObjLabel(V.TKind, V.TIdx));
 DlgAddButton(Dlg, 145, 172, 90, 'OK', 1, #0);
 DlgAddButton(Dlg, 255, 172, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R = 1 Then Begin
  V.Kind := DlgRadioValue(Dlg, rKind, 6);
  V.Status := DlgRadioValue(Dlg, rStat, 3);
  V.Date := Dlg.Ctrls[eDate].Text;
  V.Team := Dlg.Ctrls[eTeam].Text;
  V.Cost := StrToRealDef(Dlg.Ctrls[eCost].Text, 0);
  If Idx >= IvCnt Then Begin
   Intervs^[IvCnt] := V;
   Inc(IvCnt);
  End Else Intervs^[Idx] := V;
  PlanDirty := True;
  DlgInterv := True;
 End;
End;

{ ============================================================
  RECHERCHES
  ============================================================ }

Var
 ListKind : Array[0..MAX_LISTITEMS - 1] Of Byte;
 ListIdx  : Array[0..MAX_LISTITEMS - 1] Of Integer;

Procedure ListAddObj(S: String; K, Idx: Integer);
Begin
 If ListCnt < MAX_LISTITEMS Then Begin
  ListKind[ListCnt] := K;
  ListIdx[ListCnt] := Idx;
  ListAdd(S);
 End;
End;

Procedure FindObject;
Var
 Q: String;
 I, Sel: Integer;
Begin
 Q := '';
 If Not ShowInputBox('Rechercher un ouvrage', 'Identifiant ou nom (regard, troncon, etablissement)', Q, 40) Then Exit;
 Q := TrimStr(Q);
 If Q = '' Then Exit;
 I := FindNodeById(Q);
 If I >= 0 Then Begin GotoObject(SEL_NODE, I); Exit; End;
 I := FindPipeById(Q);
 If I >= 0 Then Begin GotoObject(SEL_PIPE, I); Exit; End;
 ListClear;
 For I := 0 To NodeCnt - 1 Do
  If (Nodes^[I].Name <> '') And ContainsText(Nodes^[I].Name, Q) Then
   ListAddObj(NodeKindName[Nodes^[I].Kind] + ' ' + Nodes^[I].Id + ' ' + Nodes^[I].Name, SEL_NODE, I);
 For I := 0 To EstCnt - 1 Do
  If ContainsText(Estabs^[I].Name, Q) Then
   ListAddObj('Etab. ' + Estabs^[I].Name, SEL_ESTAB, I);
 For I := 0 To EvCnt - 1 Do
  If ContainsText(Events^[I].Desc, Q) Or ContainsText(Events^[I].Id, Q) Then
   ListAddObj('Evt ' + Events^[I].Id + ' ' + Events^[I].Desc, SEL_EVENT, I);
 If ListCnt = 0 Then Begin
  ShowMessageBox('Recherche', 'Aucun ouvrage ne correspond a : ' + Q);
  Exit;
 End;
 If ListCnt = 1 Then Begin GotoObject(ListKind[0], ListIdx[0]); Exit; End;
 Sel := 0;
 If DlgPickList('Resultats de la recherche', IntToStr(ListCnt) + ' ouvrages trouves', 560, 260, Sel,
                'Aller a', 'Fermer') Then
  GotoObject(ListKind[Sel], ListIdx[Sel]);
End;

Procedure FindStreet;
Var
 Q: String;
 I, K, Sel, F, C: Integer;
 MinX, MinY, MaxX, MaxY: Real;
 Hits: Array[0..MAX_LISTITEMS - 1] Of Integer;
Begin
 Q := '';
 If Not ShowInputBox('Recherche voie', 'Nom de la voie (ou une partie du nom)', Q, 40) Then Exit;
 Q := TrimStr(Q);
 If Q = '' Then Exit;
 ListClear;
 For I := 0 To BgCnt - 1 Do
  If (Bgs^[I].Kind <> 2) And ContainsText(Bgs^[I].Name, Q) And (ListCnt < MAX_LISTITEMS) Then Begin
   Hits[ListCnt] := I;
   ListAdd(Bgs^[I].Name);
  End;
 If ListCnt = 0 Then Begin
  ShowMessageBox('Recherche voie', 'Voie introuvable : ' + Q);
  Exit;
 End;
 Sel := 0;
 If ListCnt > 1 Then
  If Not DlgPickList('Recherche voie', IntToStr(ListCnt) + ' voies trouvees', 400, 240, Sel, 'Cadrer', 'Annuler') Then
   Exit;
 I := Hits[Sel];
 F := Bgs^[I].First;
 C := Bgs^[I].Count;
 MinX := BgPts^[F].X; MaxX := MinX; MinY := BgPts^[F].Y; MaxY := MinY;
 For K := 1 To C - 1 Do Begin
  If BgPts^[F + K].X < MinX Then MinX := BgPts^[F + K].X;
  If BgPts^[F + K].X > MaxX Then MaxX := BgPts^[F + K].X;
  If BgPts^[F + K].Y < MinY Then MinY := BgPts^[F + K].Y;
  If BgPts^[F + K].Y > MaxY Then MaxY := BgPts^[F + K].Y;
 End;
 FitRect(MinX - 150, MinY - 150, MaxX + 150, MaxY + 150);
 ClampView;
 StatusMsg := 'Voie : ' + Bgs^[I].Name;
 Layers[L_VOIES].A := True;
 Layers[L_NOMS].A := True;
 RedrawAll;
End;

{ ============================================================
  SELECTIONS AVANCEES
  ============================================================ }

Procedure DlgSelectSpecific;
Var
 R, cCls, cState, eMin, eMax, K, I, N, DMin, DMax: Integer;
 Ok: Boolean;
Begin
 DlgInit(Dlg, 'Selection specifique des troncons', 420, 230);
 DlgAddFrame(Dlg, 8, 2, 190, 86, 'Classe');
 cCls := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddCheck(Dlg, 16, 18 + K * 16, 170, PipeClsName[K], True);
 DlgAddFrame(Dlg, 210, 2, 200, 86, 'Etat');
 cState := Dlg.CtrlCount;
 For K := 0 To 3 Do
  DlgAddCheck(Dlg, 218, 18 + K * 16, 180, StateName[K], True);
 DlgAddLabel(Dlg, 10, 106, 'Diametre min (mm)');
 eMin := DlgAddNumEdit(Dlg, 170, 102, 70, '0', 5);
 DlgAddLabel(Dlg, 10, 128, 'Diametre max (mm)');
 eMax := DlgAddNumEdit(Dlg, 170, 124, 70, '9999', 5);
 DlgAddButton(Dlg, 110, 156, 90, 'Selectionner', 1, #0);
 DlgAddButton(Dlg, 220, 156, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R <> 1 Then Exit;
 DMin := StrToIntDef(Dlg.Ctrls[eMin].Text, 0);
 DMax := StrToIntDef(Dlg.Ctrls[eMax].Text, 9999);
 ClearSelection;
 ClearTrace;
 N := 0;
 For I := 0 To PipeCnt - 1 Do Begin
  Ok := Dlg.Ctrls[cCls + Pipes^[I].Cls].Checked And
        Dlg.Ctrls[cState + Pipes^[I].State].Checked And
        (Pipes^[I].Diam >= DMin) And (Pipes^[I].Diam <= DMax);
  If Ok Then Begin
   Pipes^[I].Sel := True;
   Inc(N);
  End;
 End;
 StatusMsg := IntToStr(N) + ' troncons selectionnes (selection specifique).';
 RedrawAll;
End;

Procedure DlgSelectLogical;
Var
 R, rDir, K, NN, NP, Start: Integer;
 Len: Real;
Begin
 Start := TraceStartNode(1);
 If Not ValidNode(Start) Then Begin
  ShowMessageBox('Selection logique', 'Selectionnez d''abord un regard ou un troncon.');
  Exit;
 End;
 DlgInit(Dlg, 'Selection logique du reseau', 340, 170);
 DlgAddFrame(Dlg, 8, 2, 320, 82, 'Parcours a partir de ' + Nodes^[Start].Id);
 rDir := Dlg.CtrlCount;
 DlgAddRadio(Dlg, 16, 18, 300, 'Tout l''aval (vers l''exutoire)', 1, True);
 DlgAddRadio(Dlg, 16, 36, 300, 'Tout l''amont (bassin collecte)', 1, False);
 DlgAddRadio(Dlg, 16, 54, 300, 'Reseau connexe complet', 1, False);
 DlgAddButton(Dlg, 70, 98, 90, 'Selectionner', 1, #0);
 DlgAddButton(Dlg, 180, 98, 90, 'Annuler', -1, #0);
 R := DlgRun(Dlg);
 If R <> 1 Then Exit;
 K := DlgRadioValue(Dlg, rDir, 3);
 ClearTrace;
 If K = 0 Then TraceFrom(Start, 1, NN, NP, Len)
 Else If K = 1 Then TraceFrom(Start, -1, NN, NP, Len)
 Else TraceFrom(Start, 0, NN, NP, Len);
 SelectFromTrace;
 SelKind := SEL_NODE; SelIdx := Start;
 StatusMsg := 'Selection logique : ' + IntToStr(NN) + ' regards, ' + IntToStr(NP) +
              ' troncons, ' + RealToStr(Len / 1000.0, 0, 2) + ' km.';
 RedrawAll;
End;

Procedure ListSelection;
Var I, Sel: Integer;
Begin
 ListClear;
 For I := 0 To NodeCnt - 1 Do
  If Nodes^[I].Sel Then
   ListAddObj(PadRight('Regard ' + Nodes^[I].Id, 14) + NodeKindName[Nodes^[I].Kind] + ' ' +
              Nodes^[I].Name, SEL_NODE, I);
 For I := 0 To PipeCnt - 1 Do
  If Pipes^[I].Sel Then
   ListAddObj(PadRight('Troncon ' + Pipes^[I].Id, 14) + 'D' + IntToStr(Pipes^[I].Diam) + ' ' +
              PipeClsName[Pipes^[I].Cls] + ' L=' + RealToStr(Pipes^[I].Len, 0, 0) + 'm', SEL_PIPE, I);
 If (SelKind >= SEL_ESTAB) And (ListCnt = 0) Then
  ListAddObj(ObjectDescription(SelKind, SelIdx), SelKind, SelIdx);
 If ListCnt = 0 Then Begin
  ShowMessageBox('Lister', 'Aucun objet selectionne.');
  Exit;
 End;
 Sel := 0;
 If DlgPickList('Objets selectionnes', IntToStr(ListCnt) + ' objets', 560, 300, Sel, 'Aller a', 'Fermer') Then
  GotoObject(ListKind[Sel], ListIdx[Sel]);
End;

{ ============================================================
  ANALYSES ET RAPPORTS
  ============================================================ }

Procedure LineKV(K, V: String);
Begin
 ListAdd(PadRight(K, 30) + V);
End;

Function Pct(A, B: Real): String;
Begin
 If B <= 0 Then Pct := '0 %' Else Pct := RealToStr(100.0 * A / B, 0, 1) + ' %';
End;

Procedure BuildStatsReport;
Var
 I, Surch, High, Visit: Integer;
 LenCls: Array[0..3] Of Real;
 CntCls: Array[0..3] Of Integer;
 LenMat: Array[0..5] Of Real;
 LenSt: Array[0..3] Of Real;
 CntSt: Array[0..3] Of Integer;
 CntKind: Array[0..NK_COUNT - 1] Of Integer;
 Total, LenVis, SumAge, SumQ, CostTot: Real;
 CntIv: Array[0..2] Of Integer;
 OpenEv, AgeN: Integer;
Begin
 For I := 0 To 3 Do Begin LenCls[I] := 0; CntCls[I] := 0; LenSt[I] := 0; CntSt[I] := 0; End;
 For I := 0 To 5 Do LenMat[I] := 0;
 For I := 0 To NK_COUNT - 1 Do CntKind[I] := 0;
 Total := 0; LenVis := 0; SumAge := 0; AgeN := 0; Surch := 0; High := 0; Visit := 0;
 For I := 0 To PipeCnt - 1 Do Begin
  Total := Total + Pipes^[I].Len;
  LenCls[Pipes^[I].Cls] := LenCls[Pipes^[I].Cls] + Pipes^[I].Len;
  Inc(CntCls[Pipes^[I].Cls]);
  LenMat[Pipes^[I].Mat] := LenMat[Pipes^[I].Mat] + Pipes^[I].Len;
  LenSt[Pipes^[I].State] := LenSt[Pipes^[I].State] + Pipes^[I].Len;
  Inc(CntSt[Pipes^[I].State]);
  If Pipes^[I].Visit Then Begin LenVis := LenVis + Pipes^[I].Len; Inc(Visit); End;
  If Pipes^[I].Year > 1500 Then Begin
   SumAge := SumAge + (CurrentYear - Pipes^[I].Year);
   Inc(AgeN);
  End;
  If Pipes^[I].Fill > 1.0 Then Inc(Surch)
  Else If Pipes^[I].Fill > 0.8 Then Inc(High);
 End;
 For I := 0 To NodeCnt - 1 Do Inc(CntKind[Nodes^[I].Kind]);
 ListClear;
 ListAdd(Copy(PlanTitle, 1, 70));
 ListAdd(Copy(PlanOrg + ' - pluie de projet : ' + RealToStr(RainI, 0, 1) + ' mm/h', 1, 76));
 ListAdd('');
 ListAdd('--- OUVRAGES ---');
 LineKV('Regards (total)', IntToStr(NodeCnt));
 For I := 0 To NK_COUNT - 1 Do
  If CntKind[I] > 0 Then LineKV('  ' + NodeKindName[I], IntToStr(CntKind[I]));
 ListAdd('');
 ListAdd('--- CANALISATIONS ---');
 LineKV('Troncons', IntToStr(PipeCnt));
 LineKV('Longueur totale', RealToStr(Total / 1000.0, 0, 2) + ' km');
 For I := 0 To 3 Do
  If CntCls[I] > 0 Then
   LineKV('  ' + PipeClsName[I], RealToStr(LenCls[I] / 1000.0, 0, 2) + ' km (' + IntToStr(CntCls[I]) + ')  ' +
          Pct(LenCls[I], Total));
 ListAdd('Par materiau :');
 For I := 0 To 5 Do
  If LenMat[I] > 0 Then
   LineKV('  ' + MatName[I], RealToStr(LenMat[I] / 1000.0, 0, 2) + ' km  ' + Pct(LenMat[I], Total));
 ListAdd('Par etat :');
 For I := 0 To 3 Do
  LineKV('  ' + StateName[I], RealToStr(LenSt[I] / 1000.0, 0, 2) + ' km (' + IntToStr(CntSt[I]) + ')  ' +
         Pct(LenSt[I], Total));
 LineKV('Galeries visitables', RealToStr(LenVis / 1000.0, 0, 2) + ' km (' + IntToStr(Visit) + ')');
 If AgeN > 0 Then LineKV('Age moyen', RealToStr(SumAge / AgeN, 0, 0) + ' ans');
 ListAdd('');
 ListAdd('--- HYDRAULIQUE ---');
 LineKV('Troncons en charge', IntToStr(Surch));
 LineKV('Troncons remplis > 80 %', IntToStr(High));
 SumQ := 0;
 For I := 0 To NodeCnt - 1 Do
  If Nodes^[I].Kind = NK_EXUTOIRE Then SumQ := SumQ + Nodes^[I].Flow;
 LineKV('Debit aux exutoires', RealToStr(SumQ, 0, 0) + ' L/s');
 ListAdd('');
 ListAdd('--- ETABLISSEMENTS (CARINE) ---');
 SumQ := 0;
 For I := 0 To EstCnt - 1 Do SumQ := SumQ + Estabs^[I].Flow;
 LineKV('Etablissements', IntToStr(EstCnt));
 LineKV('Rejets declares', RealToStr(SumQ, 0, 1) + ' m3/jour');
 ListAdd('');
 ListAdd('--- EXPLOITATION ---');
 OpenEv := 0;
 For I := 0 To EvCnt - 1 Do If Events^[I].Status < 2 Then Inc(OpenEv);
 LineKV('Evenements', IntToStr(EvCnt) + ' (ouverts : ' + IntToStr(OpenEv) + ')');
 CntIv[0] := 0; CntIv[1] := 0; CntIv[2] := 0;
 CostTot := 0;
 For I := 0 To IvCnt - 1 Do Begin
  Inc(CntIv[Intervs^[I].Status]);
  CostTot := CostTot + Intervs^[I].Cost;
 End;
 LineKV('Interventions', IntToStr(IvCnt) + ' (plan. ' + IntToStr(CntIv[0]) + ', cours ' +
        IntToStr(CntIv[1]) + ', term. ' + IntToStr(CntIv[2]) + ')');
 LineKV('Cout cumule', RealToStr(CostTot, 0, 0));
End;

Procedure BuildConnectivity;
Var
 I, K, Comp, Head, Tail, N, NoOut, Isolated, Outf, Done: Integer;
 Mark: PIntArr;
 Queue: PIntArr;
 InDeg: PIntArr;
 M: Integer;
 Bad: Integer;
Begin
 BuildAdjacency;
 ClearTrace;
 GetMem(Mark, (NodeCnt + 1) * SizeOf(LongInt));
 GetMem(Queue, (NodeCnt + 1) * SizeOf(LongInt));
 GetMem(InDeg, (NodeCnt + 1) * SizeOf(LongInt));
 For I := 0 To NodeCnt - 1 Do Begin Mark^[I] := 0; InDeg^[I] := 0; End;
 Comp := 0;
 For I := 0 To NodeCnt - 1 Do
  If Mark^[I] = 0 Then Begin
   Inc(Comp);
   Head := 0; Tail := 0;
   Queue^[Tail] := I; Inc(Tail); Mark^[I] := Comp;
   While Head < Tail Do Begin
    N := Queue^[Head]; Inc(Head);
    K := FirstOut^[N];
    While K >= 0 Do Begin
     M := Pipes^[K].N2;
     If Mark^[M] = 0 Then Begin Mark^[M] := Comp; Queue^[Tail] := M; Inc(Tail); End;
     K := NextOut^[K];
    End;
    K := FirstIn^[N];
    While K >= 0 Do Begin
     M := Pipes^[K].N1;
     If Mark^[M] = 0 Then Begin Mark^[M] := Comp; Queue^[Tail] := M; Inc(Tail); End;
     K := NextIn^[K];
    End;
   End;
  End;
 NoOut := 0; Isolated := 0; Outf := 0; Bad := 0;
 For I := 0 To NodeCnt - 1 Do Begin
  If Nodes^[I].Kind = NK_EXUTOIRE Then Inc(Outf);
  If (FirstOut^[I] < 0) And (FirstIn^[I] < 0) Then Begin
   Inc(Isolated);
   TraceNode^[I] := True;
  End Else If (FirstOut^[I] < 0) And (Nodes^[I].Kind <> NK_EXUTOIRE) Then Begin
   Inc(NoOut);
   TraceNode^[I] := True;
  End;
 End;
 For I := 0 To PipeCnt - 1 Do Begin
  Inc(InDeg^[Pipes^[I].N2]);
  If Pipes^[I].Slope < 0 Then Begin Inc(Bad); TracePipe^[I] := True; End;
 End;
 { detection de cycles : algorithme de Kahn }
 Head := 0; Tail := 0;
 For I := 0 To NodeCnt - 1 Do
  If InDeg^[I] = 0 Then Begin Queue^[Tail] := I; Inc(Tail); End;
 Done := 0;
 While Head < Tail Do Begin
  N := Queue^[Head]; Inc(Head); Inc(Done);
  K := FirstOut^[N];
  While K >= 0 Do Begin
   M := Pipes^[K].N2;
   Dec(InDeg^[M]);
   If InDeg^[M] = 0 Then Begin Queue^[Tail] := M; Inc(Tail); End;
   K := NextOut^[K];
  End;
 End;
 FreeMem(Mark);
 FreeMem(Queue);
 FreeMem(InDeg);
 TraceActive := True;
 ListClear;
 ListAdd('Controle de connectivite du reseau');
 ListAdd('');
 LineKV('Regards', IntToStr(NodeCnt));
 LineKV('Troncons', IntToStr(PipeCnt));
 LineKV('Exutoires', IntToStr(Outf));
 LineKV('Composantes connexes', IntToStr(Comp));
 LineKV('Regards sans issue aval', IntToStr(NoOut));
 LineKV('Regards isoles', IntToStr(Isolated));
 LineKV('Troncons a pente inverse', IntToStr(Bad));
 LineKV('Regards pris dans un cycle', IntToStr(NodeCnt - Done));
 ListAdd('');
 If (NoOut = 0) And (Isolated = 0) And (Bad = 0) And (Done = NodeCnt) Then
  ListAdd('Reseau coherent : tous les ecoulements aboutissent a un exutoire.')
 Else ListAdd('Les ouvrages en defaut sont mis en evidence (vert) sur la carte.');
 If NoOut > 0 Then Begin
  ListAdd('');
  ListAdd('Regards sans issue aval :');
  K := 0;
  For I := 0 To NodeCnt - 1 Do
   If TraceNode^[I] And (FirstOut^[I] < 0) And (FirstIn^[I] >= 0) And (K < 40) Then Begin
    ListAdd('  ' + Nodes^[I].Id + ' ' + Nodes^[I].Name);
    Inc(K);
   End;
 End;
End;

Procedure DoAnomalies;
Var I, N, Sel: Integer;
Begin
 ClearTrace;
 ListClear;
 N := 0;
 For I := 0 To PipeCnt - 1 Do Begin
  If (Pipes^[I].Slope < 0.0005) Or (Pipes^[I].Slope > 0.05) Then Begin
   TracePipe^[I] := True;
   Inc(N);
   If Pipes^[I].Slope < 0 Then
    ListAddObj(PadRight(Pipes^[I].Id, 7) + 'PENTE INVERSE ' + RealToStr(Pipes^[I].Slope * 100, 6, 3) + '% L=' +
               RealToStr(Pipes^[I].Len, 0, 0) + 'm D' + IntToStr(Pipes^[I].Diam), SEL_PIPE, I)
   Else If Pipes^[I].Slope < 0.0005 Then
    ListAddObj(PadRight(Pipes^[I].Id, 7) + 'pente faible  ' + RealToStr(Pipes^[I].Slope * 100, 6, 3) + '% L=' +
               RealToStr(Pipes^[I].Len, 0, 0) + 'm D' + IntToStr(Pipes^[I].Diam), SEL_PIPE, I)
   Else
    ListAddObj(PadRight(Pipes^[I].Id, 7) + 'pente forte   ' + RealToStr(Pipes^[I].Slope * 100, 6, 3) + '% L=' +
               RealToStr(Pipes^[I].Len, 0, 0) + 'm D' + IntToStr(Pipes^[I].Diam), SEL_PIPE, I);
  End;
 End;
 TraceActive := N > 0;
 If N = 0 Then Begin
  ShowMessageBox('Pentes', 'Aucune pente anormale (< 0,05 % ou > 5 %).');
  Exit;
 End;
 Sel := 0;
 If DlgPickList('Pentes anormales', IntToStr(N) + ' troncons (mis en evidence sur la carte)', 560, 300, Sel,
                'Aller a', 'Fermer') Then
  GotoObject(SEL_PIPE, ListIdx[Sel])
 Else RedrawAll;
End;

Procedure DoTrace(Dir: Integer);
Var Start, NN, NP: Integer; Len: Real; S: String;
Begin
 Start := TraceStartNode(Dir);
 If Not ValidNode(Start) Then Begin
  ShowMessageBox('Trace', 'Selectionnez d''abord un regard, un troncon ou un etablissement.');
  Exit;
 End;
 ClearTrace;
 TraceFrom(Start, Dir, NN, NP, Len);
 If Dir > 0 Then S := 'Trace aval depuis ' Else S := 'Trace amont depuis ';
 StatusMsg := S + Nodes^[Start].Id + ' : ' + IntToStr(NN) + ' regards, ' + IntToStr(NP) + ' troncons, ' +
              RealToStr(Len / 1000.0, 0, 2) + ' km';
 RedrawAll;
End;

Procedure ShowCapacity;
Var A, R: Real; S: String; P: Integer;
Begin
 If (SelKind <> SEL_PIPE) Or (Not ValidPipe(SelIdx)) Then Begin
  ShowMessageBox('Capacite hydraulique', 'Selectionnez d''abord un troncon.');
  Exit;
 End;
 P := SelIdx;
 SectionProps(Pipes^[P].Shape, Pipes^[P].Diam, Pipes^[P].Width, A, R);
 S := 'Troncon ' + Pipes^[P].Id + ' : D' + IntToStr(Pipes^[P].Diam) + ' ' + ShapeName[Pipes^[P].Shape] +
      ' / ' + MatName[Pipes^[P].Mat] + #10 +
      'Section ' + RealToStr(A, 0, 3) + ' m2 - Rayon hydr. ' + RealToStr(R, 0, 3) + ' m' + #10 +
      'Pente ' + RealToStr(Pipes^[P].Slope * 100, 0, 3) + ' % - Longueur ' + RealToStr(Pipes^[P].Len, 0, 1) + ' m' + #10 +
      'Capacite pleine section : ' + RealToStr(Pipes^[P].QFull, 0, 0) + ' L/s (' +
      RealToStr(Pipes^[P].QFull / 1000.0 / A, 0, 2) + ' m/s)' + #10 +
      'Debit actuel : ' + RealToStr(Pipes^[P].Flow, 0, 1) + ' L/s' + #10;
 If Pipes^[P].Fill > 1.0 Then S := S + 'EN CHARGE (' + RealToStr(Pipes^[P].Fill * 100, 0, 0) + ' % de la capacite)'
 Else S := S + 'Remplissage : ' + RealToStr(Pipes^[P].Fill * 100, 0, 0) + ' % - vitesse ' +
           RealToStr(Pipes^[P].Vel, 0, 2) + ' m/s';
 If (Pipes^[P].Fill <= 1.0) And (Pipes^[P].Vel < 0.6) And (Pipes^[P].Flow > 0) Then
  S := S + #10 + 'Vitesse faible : risque de depots.';
 If Pipes^[P].Vel > 4.0 Then S := S + #10 + 'Vitesse elevee : risque d''abrasion.';
 ShowMessageBox('Capacite hydraulique', S);
End;

Procedure DlgRain;
Var S: String;
Begin
 S := RealToStr(RainI, 0, 1);
 If Not ShowInputBox('Pluie de projet', 'Intensite (mm/h) : 0 = temps sec, 20 = decennale', S, 8) Then Exit;
 RainI := StrToRealDef(S, RainI);
 If RainI < 0 Then RainI := 0;
 If RainI > 300 Then RainI := 300;
 ComputeHydraulics;
 StatusMsg := 'Pluie de projet : ' + RealToStr(RainI, 0, 1) + ' mm/h. Couche Occupation > Remplissage pour visualiser.';
 If RainI > 0 Then Layers[L_REMPLI].A := True;
 RedrawAll;
End;

{ ============================================================
  FICHE D'OUVRAGE (bouton Documents)
  ============================================================ }

Procedure BuildSheet;
Var I, K, C: Integer; A, R: Real; S: String;
Begin
 ListClear;
 Case SelKind Of
  SEL_NODE: If ValidNode(SelIdx) Then Begin
   I := SelIdx;
   ListAdd('FICHE D''OUVRAGE : ' + NodeKindName[Nodes^[I].Kind] + ' ' + Nodes^[I].Id);
   ListAdd('');
   LineKV('Nom', Nodes^[I].Name);
   LineKV('Secteur', SectorName[Nodes^[I].Sector]);
   LineKV('Coordonnees', RealToStr(Nodes^[I].X, 0, 1) + ' ; ' + RealToStr(Nodes^[I].Y, 0, 1));
   LineKV('Cote terrain naturel', RealToStr(Nodes^[I].Cote, 0, 2) + ' m');
   LineKV('Cote radier', RealToStr(Nodes^[I].Radier, 0, 2) + ' m');
   LineKV('Profondeur', RealToStr(Nodes^[I].Cote - Nodes^[I].Radier, 0, 2) + ' m');
   LineKV('Annee de construction', IntToStr(Nodes^[I].Year));
   LineKV('Etat', StateName[Nodes^[I].State]);
   LineKV('Debit sanitaire local', RealToStr(Nodes^[I].Load, 0, 2) + ' L/s');
   LineKV('Bassin versant local', RealToStr(Nodes^[I].Area, 0, 2) + ' ha');
   LineKV('Debit en transit', RealToStr(Nodes^[I].Flow, 0, 1) + ' L/s');
   C := 0; K := FirstIn^[I];
   While K >= 0 Do Begin Inc(C); K := NextIn^[K]; End;
   LineKV('Troncons amont', IntToStr(C));
   C := 0; K := FirstOut^[I];
   While K >= 0 Do Begin Inc(C); K := NextOut^[K]; End;
   LineKV('Troncons aval', IntToStr(C));
   ListAdd('');
   ListAdd('Etablissements raccordes :');
   C := 0;
   For K := 0 To EstCnt - 1 Do
    If Estabs^[K].Node = I Then Begin
     ListAdd('  ' + Estabs^[K].Name + ' (' + RealToStr(Estabs^[K].Flow, 0, 1) + ' m3/j)');
     Inc(C);
    End;
   If C = 0 Then ListAdd('  aucun');
   ListAdd('Evenements / interventions :');
   C := 0;
   For K := 0 To EvCnt - 1 Do
    If (Events^[K].TKind = 1) And (Events^[K].TIdx = I) Then Begin
     ListAdd('  ' + Events^[K].Id + ' ' + EvKindName[Events^[K].Kind] + ' (' + EvStatName[Events^[K].Status] + ')');
     Inc(C);
    End;
   For K := 0 To IvCnt - 1 Do
    If (Intervs^[K].TKind = 1) And (Intervs^[K].TIdx = I) Then Begin
     ListAdd('  ' + Intervs^[K].Id + ' ' + IvKindName[Intervs^[K].Kind] + ' (' + IvStatName[Intervs^[K].Status] + ')');
     Inc(C);
    End;
   If C = 0 Then ListAdd('  aucun');
  End;
  SEL_PIPE: If ValidPipe(SelIdx) Then Begin
   I := SelIdx;
   SectionProps(Pipes^[I].Shape, Pipes^[I].Diam, Pipes^[I].Width, A, R);
   ListAdd('FICHE D''OUVRAGE : Troncon ' + Pipes^[I].Id);
   ListAdd('');
   LineKV('Classe', PipeClsName[Pipes^[I].Cls]);
   LineKV('Forme', ShapeName[Pipes^[I].Shape]);
   LineKV('Dimensions (H x L)', IntToStr(Pipes^[I].Diam) + ' x ' + IntToStr(Pipes^[I].Width) + ' mm');
   LineKV('Materiau', MatName[Pipes^[I].Mat]);
   LineKV('Annee de pose', IntToStr(Pipes^[I].Year));
   LineKV('Etat', StateName[Pipes^[I].State]);
   If Pipes^[I].Visit Then S := 'oui' Else S := 'non';
   LineKV('Visitable', S);
   LineKV('Regard amont', Nodes^[Pipes^[I].N1].Id + ' (radier ' + RealToStr(Nodes^[Pipes^[I].N1].Radier, 0, 2) + ')');
   LineKV('Regard aval', Nodes^[Pipes^[I].N2].Id + ' (radier ' + RealToStr(Nodes^[Pipes^[I].N2].Radier, 0, 2) + ')');
   LineKV('Longueur', RealToStr(Pipes^[I].Len, 0, 1) + ' m');
   LineKV('Pente', RealToStr(Pipes^[I].Slope * 100, 0, 3) + ' %');
   LineKV('Section', RealToStr(A, 0, 3) + ' m2');
   LineKV('Capacite pleine section', RealToStr(Pipes^[I].QFull, 0, 0) + ' L/s');
   LineKV('Debit', RealToStr(Pipes^[I].Flow, 0, 1) + ' L/s');
   If Pipes^[I].Fill > 1.0 Then S := 'en charge' Else S := RealToStr(Pipes^[I].Fill * 100, 0, 0) + ' %';
   LineKV('Remplissage', S);
   LineKV('Vitesse', RealToStr(Pipes^[I].Vel, 0, 2) + ' m/s');
   ListAdd('');
   ListAdd('Evenements / interventions :');
   C := 0;
   For K := 0 To EvCnt - 1 Do
    If (Events^[K].TKind = 2) And (Events^[K].TIdx = I) Then Begin
     ListAdd('  ' + Events^[K].Id + ' ' + EvKindName[Events^[K].Kind] + ' (' + EvStatName[Events^[K].Status] + ')');
     Inc(C);
    End;
   For K := 0 To IvCnt - 1 Do
    If (Intervs^[K].TKind = 2) And (Intervs^[K].TIdx = I) Then Begin
     ListAdd('  ' + Intervs^[K].Id + ' ' + IvKindName[Intervs^[K].Kind] + ' (' + IvStatName[Intervs^[K].Status] + ')');
     Inc(C);
    End;
   If C = 0 Then ListAdd('  aucun');
  End;
  SEL_ESTAB: If (SelIdx >= 0) And (SelIdx < EstCnt) Then Begin
   I := SelIdx;
   ListAdd('FICHE ETABLISSEMENT (CARINE)');
   ListAdd('');
   LineKV('Raison sociale', Estabs^[I].Name);
   LineKV('Code SAP', Estabs^[I].Sap);
   LineKV('Code NAF', Estabs^[I].Naf);
   LineKV('Commune', Estabs^[I].Commune);
   LineKV('Code postal', Estabs^[I].Post);
   If ValidNode(Estabs^[I].Node) Then LineKV('Regard de rejet', Nodes^[Estabs^[I].Node].Id);
   LineKV('Rejet', RealToStr(Estabs^[I].Flow, 0, 1) + ' m3/jour');
  End;
  SEL_EVENT: If (SelIdx >= 0) And (SelIdx < EvCnt) Then Begin
   I := SelIdx;
   ListAdd('FICHE EVENEMENT ' + Events^[I].Id);
   ListAdd('');
   LineKV('Nature', EvKindName[Events^[I].Kind]);
   LineKV('Statut', EvStatName[Events^[I].Status]);
   LineKV('Date', Events^[I].Date);
   LineKV('Description', Events^[I].Desc);
   LineKV('Ouvrage', ObjLabel(Events^[I].TKind, Events^[I].TIdx));
  End;
  SEL_INTERV: If (SelIdx >= 0) And (SelIdx < IvCnt) Then Begin
   I := SelIdx;
   ListAdd('FICHE INTERVENTION ' + Intervs^[I].Id);
   ListAdd('');
   LineKV('Nature', IvKindName[Intervs^[I].Kind]);
   LineKV('Statut', IvStatName[Intervs^[I].Status]);
   LineKV('Date', Intervs^[I].Date);
   LineKV('Equipe', Intervs^[I].Team);
   LineKV('Cout estime', RealToStr(Intervs^[I].Cost, 0, 0));
   LineKV('Ouvrage', ObjLabel(Intervs^[I].TKind, Intervs^[I].TIdx));
  End;
 End;
End;

{ ============================================================
  EXPORTS
  ============================================================ }

Function ExportCSV: Boolean;
Var F: Text; I: Integer;
Begin
 ExportCSV := False;
 {$I-}
 Assign(F, 'REGARDS.CSV');
 Rewrite(F);
 {$I+}
 If IOResult <> 0 Then Exit;
 WriteLn(F, 'Id;Type;Nom;X;Y;Cote;Radier;Annee;Etat;Secteur;Debit_transit_Ls');
 For I := 0 To NodeCnt - 1 Do
  WriteLn(F, Nodes^[I].Id, ';', NodeKindName[Nodes^[I].Kind], ';', Nodes^[I].Name, ';',
          RealToStr(Nodes^[I].X, 0, 1), ';', RealToStr(Nodes^[I].Y, 0, 1), ';',
          RealToStr(Nodes^[I].Cote, 0, 2), ';', RealToStr(Nodes^[I].Radier, 0, 2), ';',
          Nodes^[I].Year, ';', StateName[Nodes^[I].State], ';', SectorName[Nodes^[I].Sector], ';',
          RealToStr(Nodes^[I].Flow, 0, 1));
 Close(F);
 {$I-}
 Assign(F, 'TRONCONS.CSV');
 Rewrite(F);
 {$I+}
 If IOResult <> 0 Then Exit;
 WriteLn(F, 'Id;Amont;Aval;Classe;Forme;Haut_mm;Larg_mm;Materiau;Annee;Etat;Visitable;Longueur_m;Pente_pct;' +
            'Capacite_Ls;Debit_Ls;Remplissage_pct');
 For I := 0 To PipeCnt - 1 Do
  WriteLn(F, Pipes^[I].Id, ';', Nodes^[Pipes^[I].N1].Id, ';', Nodes^[Pipes^[I].N2].Id, ';',
          PipeClsName[Pipes^[I].Cls], ';', ShapeName[Pipes^[I].Shape], ';', Pipes^[I].Diam, ';',
          Pipes^[I].Width, ';', MatName[Pipes^[I].Mat], ';', Pipes^[I].Year, ';',
          StateName[Pipes^[I].State], ';', Ord(Pipes^[I].Visit), ';',
          RealToStr(Pipes^[I].Len, 0, 1), ';', RealToStr(Pipes^[I].Slope * 100, 0, 3), ';',
          RealToStr(Pipes^[I].QFull, 0, 0), ';', RealToStr(Pipes^[I].Flow, 0, 1), ';',
          RealToStr(Pipes^[I].Fill * 100, 0, 0));
 Close(F);
 ExportCSV := True;
End;

Function ExportReport: Boolean;
Var F: Text; I: Integer;
Begin
 ExportReport := False;
 BuildStatsReport;
 {$I-}
 Assign(F, 'RAPPORT.TXT');
 Rewrite(F);
 {$I+}
 If IOResult <> 0 Then Exit;
 For I := 0 To ListCnt - 1 Do WriteLn(F, ListBuf^[I]);
 Close(F);
 ExportReport := True;
End;

{ ============================================================
  MACROS (bouton Macro)
  ============================================================ }

Procedure MacroCurage;
Var I, N, J: Integer; Has: Boolean;
Begin
 N := 0;
 For I := 0 To PipeCnt - 1 Do
  If (Pipes^[I].State >= 2) And GrowIntervs(IvCnt + 1) Then Begin
   Has := False;
   For J := 0 To IvCnt - 1 Do
    If (Intervs^[J].TKind = 2) And (Intervs^[J].TIdx = I) And (Intervs^[J].Status < 2) Then Has := True;
   If Not Has Then Begin
    Intervs^[IvCnt].Id := 'I' + PadZero(IvCnt + 1, 3);
    If Pipes^[I].State = 3 Then Intervs^[IvCnt].Kind := 2 Else Intervs^[IvCnt].Kind := 1;
    Intervs^[IvCnt].Status := 0;
    Intervs^[IvCnt].Date := TodayStr;
    Intervs^[IvCnt].Team := 'Equipe A';
    Intervs^[IvCnt].Cost := Pipes^[I].Len * 120.0;
    Intervs^[IvCnt].TKind := 2;
    Intervs^[IvCnt].TIdx := I;
    Inc(IvCnt);
    Inc(N);
   End;
  End;
 If N > 0 Then PlanDirty := True;
 StatusMsg := IntToStr(N) + ' interventions planifiees pour les troncons degrades ou critiques.';
 RedrawAll;
End;

Procedure MacroExportSel;
Var F: Text; I: Integer; N: Integer;
Begin
 N := 0;
 {$I-}
 Assign(F, 'SELECTION.CSV');
 Rewrite(F);
 {$I+}
 If IOResult <> 0 Then Begin
  ShowMessageBox('Macro', 'Impossible de creer SELECTION.CSV');
  Exit;
 End;
 WriteLn(F, 'Type;Id;Description;X;Y');
 For I := 0 To NodeCnt - 1 Do
  If Nodes^[I].Sel Then Begin
   WriteLn(F, 'Regard;', Nodes^[I].Id, ';', Nodes^[I].Name, ';', RealToStr(Nodes^[I].X, 0, 1), ';',
           RealToStr(Nodes^[I].Y, 0, 1));
   Inc(N);
  End;
 For I := 0 To PipeCnt - 1 Do
  If Pipes^[I].Sel Then Begin
   WriteLn(F, 'Troncon;', Pipes^[I].Id, ';D', Pipes^[I].Diam, ' ', PipeClsName[Pipes^[I].Cls], ';',
           RealToStr(Nodes^[Pipes^[I].N1].X, 0, 1), ';', RealToStr(Nodes^[Pipes^[I].N1].Y, 0, 1));
   Inc(N);
  End;
 Close(F);
 ShowMessageBox('Macro', IntToStr(N) + ' objets exportes dans SELECTION.CSV');
End;

Procedure DlgMacro;
Var Sel: Integer;
Begin
 ListClear;
 ListAdd('1. Verification complete du reseau (connectivite)');
 ListAdd('2. Planifier les curages (troncons degrades)');
 ListAdd('3. Exporter la selection en SELECTION.CSV');
 ListAdd('4. Simuler une pluie decennale (20 mm/h)');
 ListAdd('5. Revenir en temps sec (0 mm/h)');
 Sel := 0;
 If Not DlgPickList('Macro', 'Choisir la macro a executer', 440, 200, Sel, 'Executer', 'Annuler') Then Exit;
 Case Sel Of
  0: Begin BuildConnectivity; ShowReport('Verification du reseau'); RedrawAll; End;
  1: If ShowConfirmBox('Macro', 'Planifier une intervention sur chaque troncon degrade ou critique ?') Then
      MacroCurage;
  2: MacroExportSel;
  3: Begin RainI := 20.0; ComputeHydraulics; Layers[L_REMPLI].A := True;
      StatusMsg := 'Pluie decennale simulee (20 mm/h).'; RedrawAll; End;
  4: Begin RainI := 0.0; ComputeHydraulics;
      StatusMsg := 'Retour en temps sec.'; RedrawAll; End;
 End;
End;

{ ============================================================
  CARINE : liste des etablissements (rejets industriels)
  ============================================================ }

Const
 CAR_W     = 568;
 CAR_H     = 322;
 CAR_ROWS  = 18;
 CAR_ROW_H = 10;
 CarColX : Array[0..4] Of Integer = (8, 184, 264, 344, 432);
 CarColW : Array[0..4] Of Integer = (176, 80, 80, 88, 108);
 CarColName : Array[0..4] Of String[14] =
  ('Raison sociale', 'Code SAP', 'Code NAF', 'Commune', 'Code postal');
 CarBtnCap : Array[0..4] Of String[14] =
  ('Ajouter', 'Editer', 'Supprimer', 'Localiser', 'Annuler filtre');

Var
 CarX1, CarY1 : Integer;
 EstView      : Array[0..MAX_ESTAB - 1] Of Integer;
 EstViewCnt   : Integer;
 CarTop, CarSel : Integer;
 CarSortCol   : Integer;
 CarSortDesc  : Boolean;
 CarFilter    : Array[0..4] Of TStr23;

Function EstField(I, C: Integer): String;
Begin
 Case C Of
  0: EstField := Estabs^[I].Name;
  1: EstField := Estabs^[I].Sap;
  2: EstField := Estabs^[I].Naf;
  3: EstField := Estabs^[I].Commune;
 Else EstField := Estabs^[I].Post;
 End;
End;

Procedure CarineBuildView;
Var I, J, C, T: Integer; Ok: Boolean; A, B: String;
Begin
 EstViewCnt := 0;
 For I := 0 To EstCnt - 1 Do Begin
  Ok := True;
  For C := 0 To 4 Do
   If (CarFilter[C] <> '') And (Not ContainsText(EstField(I, C), CarFilter[C])) Then Ok := False;
  If Ok Then Begin
   EstView[EstViewCnt] := I;
   Inc(EstViewCnt);
  End;
 End;
 If CarSortCol >= 0 Then
  For I := 1 To EstViewCnt - 1 Do Begin
   T := EstView[I];
   A := UpStr(EstField(T, CarSortCol));
   J := I - 1;
   While J >= 0 Do Begin
    B := UpStr(EstField(EstView[J], CarSortCol));
    If (Not CarSortDesc And (B > A)) Or (CarSortDesc And (B < A)) Then Begin
     EstView[J + 1] := EstView[J];
     Dec(J);
    End Else Break;
   End;
   EstView[J + 1] := T;
  End;
 If CarSel >= EstViewCnt Then CarSel := EstViewCnt - 1;
 If CarSel < 0 Then CarSel := 0;
 If CarTop > CarSel Then CarTop := CarSel;
 If CarSel >= CarTop + CAR_ROWS Then CarTop := CarSel - CAR_ROWS + 1;
 If CarTop < 0 Then CarTop := 0;
End;

Function CarBtnX1(I: Integer): Integer;
Begin
 Case I Of
  0: CarBtnX1 := 8;
  1: CarBtnX1 := 78;
  2: CarBtnX1 := 140;
  3: CarBtnX1 := 230;
 Else CarBtnX1 := CAR_W - 8 - (Length(CarBtnCap[4]) * CHARW + 12);
 End;
End;

Function CarBtnX2(I: Integer): Integer;
Begin
 Case I Of
  0: CarBtnX2 := 74;
  1: CarBtnX2 := 134;
  2: CarBtnX2 := 224;
  3: CarBtnX2 := 320;
 Else CarBtnX2 := CAR_W - 8;
 End;
End;

Procedure CarineDraw;
Var
 I, R, C, Y, Idx, Pages, Page, TY: Integer;
 S: String;
 TotFlow: Real;
Begin
 HideMouse;
 DrawShadow(CarX1, CarY1, CarX1 + CAR_W, CarY1 + CAR_H);
 DrawBox3D(CarX1, CarY1, CarX1 + CAR_W, CarY1 + CAR_H, True, LightGray);
 { barre de titre }
 FillRect(CarX1 + 3, CarY1 + 3, CarX1 + CAR_W - 3, CarY1 + 19, Blue);
 SetColor(White);
 OutTextXY(CarX1 + 10, CarY1 + 8, Copy(PlanOrg, 1, 24));
 SetColor(LightCyan);
 OutTextXY(CarX1 + 14 + Length(Copy(PlanOrg, 1, 24)) * CHARW + 16, CarY1 + 8, 'CARINE.');
 { sous-titre }
 SetColor(Black);
 OutTextXY(CarX1 + 8, CarY1 + 26, 'Liste des etablissements');
 S := IntToStr(EstViewCnt) + ' / ' + IntToStr(EstCnt);
 OutTextXY(CarX1 + CAR_W - 8 - Length(S) * CHARW, CarY1 + 26, S);
 DrawHLine(CarX1 + 4, CarX1 + CAR_W - 4, CarY1 + 37, CLR_BORDER);
 { boutons }
 For I := 0 To 4 Do Begin
  DrawBox3D(CarX1 + CarBtnX1(I), CarY1 + 41, CarX1 + CarBtnX2(I), CarY1 + 59, True, LightGray);
  DrawCenteredText(CarX1 + CarBtnX1(I), CarY1 + 46, CarX1 + CarBtnX2(I), Black, CarBtnCap[I]);
 End;
 { en-tete du tableau }
 Y := CarY1 + 64;
 For C := 0 To 4 Do Begin
  DrawBox3D(CarX1 + CarColX[C], Y, CarX1 + CarColX[C] + CarColW[C] - 1, Y + 13, True, LightGray);
  SetColor(Black);
  OutTextXY(CarX1 + CarColX[C] + 4, Y + 3, Copy(CarColName[C], 1, (CarColW[C] - 8) Div CHARW));
  If CarSortCol = C Then Begin
   If CarSortDesc Then OutTextXY(CarX1 + CarColX[C] + CarColW[C] - 10, Y + 3, #31)
   Else OutTextXY(CarX1 + CarColX[C] + CarColW[C] - 10, Y + 3, #30);
  End Else If CarFilter[C] <> '' Then Begin
   SetColor(Red);
   OutTextXY(CarX1 + CarColX[C] + CarColW[C] - 12, Y + 3, '*');
  End;
 End;
 { lignes }
 Y := CarY1 + 79;
 FillRect(CarX1 + 8, Y, CarX1 + CAR_W - 20, Y + CAR_ROWS * CAR_ROW_H + 1, White);
 For R := 0 To CAR_ROWS - 1 Do Begin
  Idx := CarTop + R;
  If Idx < EstViewCnt Then Begin
   TY := Y + 1 + R * CAR_ROW_H;
   If Idx = CarSel Then Begin
    FillRect(CarX1 + 8, TY - 1, CarX1 + CAR_W - 20, TY + CAR_ROW_H - 2, Blue);
    SetColor(White);
   End Else SetColor(Black);
   For C := 0 To 4 Do
    OutTextXY(CarX1 + CarColX[C] + 4, TY, Copy(EstField(EstView[Idx], C), 1, (CarColW[C] - 6) Div CHARW));
  End;
 End;
 DrawRect(CarX1 + 8, Y, CarX1 + CAR_W - 20, Y + CAR_ROWS * CAR_ROW_H + 1, CLR_BORDER);
 { colonnes }
 SetColor(LightGray);
 For C := 1 To 4 Do Line(CarX1 + CarColX[C], Y + 1, CarX1 + CarColX[C], Y + CAR_ROWS * CAR_ROW_H);
 { ascenseur }
 FillRect(CarX1 + CAR_W - 18, Y, CarX1 + CAR_W - 8, Y + CAR_ROWS * CAR_ROW_H + 1, LightGray);
 If EstViewCnt > CAR_ROWS Then Begin
  I := ((CAR_ROWS * CAR_ROW_H - 6) * CAR_ROWS) Div EstViewCnt;
  If I < 8 Then I := 8;
  TY := Y + 3 + ((CAR_ROWS * CAR_ROW_H - 6 - I) * CarTop) Div (EstViewCnt - CAR_ROWS);
  DrawBox3D(CarX1 + CAR_W - 18, TY, CarX1 + CAR_W - 8, TY + I, True, LightGray);
 End;
 { pied de page }
 Y := CarY1 + CAR_H - 30;
 DrawBox3D(CarX1 + 8, Y, CarX1 + 30, Y + 18, True, LightGray);
 DrawCenteredText(CarX1 + 8, Y + 5, CarX1 + 30, Black, '<');
 DrawBox3D(CarX1 + 34, Y, CarX1 + 56, Y + 18, True, LightGray);
 DrawCenteredText(CarX1 + 34, Y + 5, CarX1 + 56, Black, '>');
 Pages := (EstViewCnt + CAR_ROWS - 1) Div CAR_ROWS;
 If Pages < 1 Then Pages := 1;
 Page := CarTop Div CAR_ROWS + 1;
 SetColor(Black);
 OutTextXY(CarX1 + 66, Y + 5, 'Page ' + IntToStr(Page) + ' sur ' + IntToStr(Pages));
 SetColor(DarkGray);
 TotFlow := 0;
 For I := 0 To EstViewCnt - 1 Do TotFlow := TotFlow + Estabs^[EstView[I]].Flow;
 OutTextXY(CarX1 + 190, Y + 5, 'Rejets : ' + RealToStr(TotFlow, 0, 1) + ' m3/j');
 DrawBox3D(CarX1 + CAR_W - 88, Y, CarX1 + CAR_W - 8, Y + 18, True, LightGray);
 DrawCenteredText(CarX1 + CAR_W - 88, Y + 5, CarX1 + CAR_W - 8, Black, 'Fermer');
 ShowMouse;
End;

Procedure CarineRefresh;
Begin
 RedrawAll;
 CarineDraw;
End;

{ Menu local d'une colonne : tri croissant / decroissant / filtre }
Procedure CarineHeaderMenu(C: Integer);
Const
 Caps : Array[0..2] Of String[15] = ('Tri croissant', 'Tri decroissant', 'Filtrer...');
Var
 Ev: TUIEvent;
 X, Y, I, Hit: Integer;
 Done: Boolean;
 S: String;
Begin
 X := CarX1 + CarColX[C];
 If X + 140 > CarX1 + CAR_W Then X := CarX1 + CAR_W - 144;
 Y := CarY1 + 78;
 HideMouse;
 DrawShadow(X, Y, X + 136, Y + 46);
 DrawBox3D(X, Y, X + 136, Y + 46, True, White);
 For I := 0 To 2 Do Begin
  SetColor(Black);
  OutTextXY(X + 8, Y + 5 + I * 14, Caps[I]);
 End;
 ShowMouse;
 Done := False;
 Hit := -1;
 Repeat
  PollEvents(Ev);
  If Ev.Kind = EV_NONE Then Delay(8)
  Else If Ev.Kind = EV_MOUSE_DOWN Then Begin
   If (Ev.MouseX >= X) And (Ev.MouseX <= X + 136) And (Ev.MouseY >= Y) And (Ev.MouseY <= Y + 46) Then
    Hit := (Ev.MouseY - Y - 2) Div 14;
   Done := True;
  End Else If (Ev.Kind = EV_KEY_CHAR) And (Ev.KeyChar = #27) Then Done := True;
 Until Done;
 If (Hit >= 0) And (Hit <= 2) Then Begin
  If Hit = 0 Then Begin CarSortCol := C; CarSortDesc := False; End
  Else If Hit = 1 Then Begin CarSortCol := C; CarSortDesc := True; End
  Else Begin
   S := CarFilter[C];
   If ShowInputBox('Filtrer : ' + CarColName[C], 'Texte contenu dans la colonne (vide = tout)', S, 23) Then
    CarFilter[C] := TrimStr(S);
  End;
 End;
 CarineBuildView;
 CarineRefresh;
End;

Procedure CarineWindow;
Var
 Ev: TUIEvent;
 Done: Boolean;
 I, X, Y, Idx, C, GotoIdx: Integer;

 Procedure DoEdit;
 Begin
  If (EstViewCnt > 0) And (CarSel < EstViewCnt) Then Begin
   DlgEstab(EstView[CarSel]);
   CarineBuildView;
   CarineRefresh;
  End;
 End;

 Procedure DoAdd;
 Begin
  If DlgEstab(EstCnt) Then Begin
   CarineBuildView;
   CarSel := EstViewCnt - 1;
   CarineBuildView;
  End;
  CarineRefresh;
 End;

 Procedure DoDelete;
 Begin
  If (EstViewCnt > 0) And (CarSel < EstViewCnt) Then Begin
   If ShowConfirmBox('Supprimer', 'Supprimer l''etablissement ' + Estabs^[EstView[CarSel]].Name + ' ?') Then Begin
    DeleteEstab(EstView[CarSel]);
    ComputeHydraulics;
   End;
   CarineBuildView;
  End;
  CarineRefresh;
 End;

 Procedure ClearFilters;
 Var K: Integer;
 Begin
  For K := 0 To 4 Do CarFilter[K] := '';
  CarSortCol := -1;
  CarineBuildView;
  CarineDraw;
 End;

Begin
 CarX1 := (SCREEN_W - CAR_W) Div 2;
 CarY1 := (SCREEN_H - CAR_H) Div 2;
 If CarSel < 0 Then CarSel := 0;
 CarineBuildView;
 CarineDraw;
 Done := False;
 GotoIdx := -1;
 Repeat
  PollEvents(Ev);
  If Ev.Kind = EV_NONE Then Delay(8)
  Else Begin
   If Ev.Kind = EV_KEY_CHAR Then Begin
    Case Ev.KeyChar Of
     #27: Done := True;
     #13: DoEdit;
     'a', 'A': DoAdd;
    End;
   End Else If Ev.Kind = EV_KEY_DOWN Then Begin
    Case Ev.KeyCode Of
     72: If CarSel > 0 Then Dec(CarSel);
     80: If CarSel < EstViewCnt - 1 Then Inc(CarSel);
     73: Dec(CarSel, CAR_ROWS);
     81: Inc(CarSel, CAR_ROWS);
     71: CarSel := 0;
     79: CarSel := EstViewCnt - 1;
     83: DoDelete;
    End;
    If CarSel > EstViewCnt - 1 Then CarSel := EstViewCnt - 1;
    If CarSel < 0 Then CarSel := 0;
    If CarSel < CarTop Then CarTop := CarSel;
    If CarSel >= CarTop + CAR_ROWS Then CarTop := CarSel - CAR_ROWS + 1;
    If (Ev.KeyCode = 73) Or (Ev.KeyCode = 81) Then CarTop := (CarSel Div CAR_ROWS) * CAR_ROWS;
    CarineDraw;
   End Else If (Ev.Kind = EV_MOUSE_DOWN) Or (Ev.Kind = EV_MOUSE_DBLCLICK) Then Begin
    X := Ev.MouseX - CarX1;
    Y := Ev.MouseY - CarY1;
    { boutons du haut }
    For I := 0 To 4 Do
     If (X >= CarBtnX1(I)) And (X <= CarBtnX2(I)) And (Y >= 41) And (Y <= 59) Then Begin
      Case I Of
       0: DoAdd;
       1: DoEdit;
       2: DoDelete;
       3: If (EstViewCnt > 0) And (CarSel < EstViewCnt) Then Begin
           GotoIdx := EstView[CarSel];
           Done := True;
          End;
       4: ClearFilters;
      End;
     End;
    { en-tetes de colonnes }
    If (Y >= 64) And (Y <= 77) Then
     For C := 0 To 4 Do
      If (X >= CarColX[C]) And (X < CarColX[C] + CarColW[C]) Then CarineHeaderMenu(C);
    { lignes }
    If (Y >= 79) And (Y < 79 + CAR_ROWS * CAR_ROW_H) And (X >= 8) And (X < CAR_W - 20) Then Begin
     Idx := CarTop + (Y - 80) Div CAR_ROW_H;
     If (Idx >= 0) And (Idx < EstViewCnt) Then Begin
      CarSel := Idx;
      CarineDraw;
      If Ev.Kind = EV_MOUSE_DBLCLICK Then DoEdit;
     End;
    End;
    { pied de page }
    If (Y >= CAR_H - 30) And (Y <= CAR_H - 12) Then Begin
     If (X >= 8) And (X <= 30) Then Begin
      Dec(CarTop, CAR_ROWS); If CarTop < 0 Then CarTop := 0;
      CarSel := CarTop;
      CarineDraw;
     End Else If (X >= 34) And (X <= 56) Then Begin
      If CarTop + CAR_ROWS < EstViewCnt Then Begin
       Inc(CarTop, CAR_ROWS);
       CarSel := CarTop;
       CarineDraw;
      End;
     End Else If (X >= CAR_W - 88) And (X <= CAR_W - 8) Then Done := True;
    End;
   End;
  End;
 Until Done;
 RedrawAll;
 If GotoIdx >= 0 Then GotoObject(SEL_ESTAB, GotoIdx);
End;

Procedure CarineBySector;
Var
 I, S: Integer;
 Cnt: Array[0..MAX_SECTORS - 1] Of Integer;
 Flow: Array[0..MAX_SECTORS - 1] Of Real;
Begin
 For I := 0 To MAX_SECTORS - 1 Do Begin Cnt[I] := 0; Flow[I] := 0; End;
 For I := 0 To EstCnt - 1 Do
  If ValidNode(Estabs^[I].Node) Then Begin
   S := Nodes^[Estabs^[I].Node].Sector;
   Inc(Cnt[S]);
   Flow[S] := Flow[S] + Estabs^[I].Flow;
  End;
 ListClear;
 ListAdd('REJETS INDUSTRIELS PAR SECTEUR');
 ListAdd('');
 ListAdd(PadRight('Secteur', 28) + PadLeft('Etabl.', 8) + PadLeft('m3/jour', 12));
 For I := 0 To MAX_SECTORS - 1 Do
  If Cnt[I] > 0 Then
   ListAdd(PadRight(SectorName[I], 28) + PadLeft(IntToStr(Cnt[I]), 8) + PadLeft(RealToStr(Flow[I], 0, 1), 12));
 ShowReport('Rejets par secteur - CARINE');
End;

Procedure CarineOfNode;
Var I, N: Integer;
Begin
 If (SelKind <> SEL_NODE) Or (Not ValidNode(SelIdx)) Then Begin
  ShowMessageBox('Carine', 'Selectionnez d''abord un regard.');
  Exit;
 End;
 ListClear;
 N := 0;
 For I := 0 To EstCnt - 1 Do
  If Estabs^[I].Node = SelIdx Then Begin
   ListAdd(PadRight(Estabs^[I].Name, 40) + ' ' + Estabs^[I].Naf + ' ' + RealToStr(Estabs^[I].Flow, 0, 1) + ' m3/j');
   Inc(N);
  End;
 If N = 0 Then ListAdd('Aucun etablissement raccorde a ' + Nodes^[SelIdx].Id);
 ShowReport('Etablissements du regard ' + Nodes^[SelIdx].Id);
End;

{ ============================================================
  FICHIERS : ouvrir / enregistrer
  ============================================================ }

Procedure CollectPlanFiles;
Var SR: SearchRec; I, J: Integer; S: TStr79;
Begin
 ListClear;
 FindFirst(SamplesDir + '*.TGR', AnyFile, SR);
 While DosError = 0 Do Begin
  ListAdd(SamplesDir + SR.Name);
  FindNext(SR);
 End;
 {$IFDEF FPC}
  FindClose(SR);
 {$ENDIF}
 FindFirst('*.TGR', AnyFile, SR);
 While DosError = 0 Do Begin
  ListAdd(SR.Name);
  FindNext(SR);
 End;
 {$IFDEF FPC}
  FindClose(SR);
 {$ENDIF}
 { tri alphabetique }
 For I := 1 To ListCnt - 1 Do Begin
  S := ListBuf^[I];
  J := I - 1;
  While (J >= 0) And (UpStr(ListBuf^[J]) > UpStr(S)) Do Begin
   ListBuf^[J + 1] := ListBuf^[J];
   Dec(J);
  End;
  ListBuf^[J + 1] := S;
 End;
End;

Procedure OpenPlanFile(FName: String);
Begin
 If Not LoadPlan(FName) Then Begin
  ShowMessageBox('Ouvrir', 'Impossible de lire le plan : ' + FName);
  Exit;
 End;
 FinishLoad;
 StatusMsg := 'Plan charge : ' + PlanTitle;
 RedrawAll;
End;

Function SaveCurrent: Boolean;
Begin
 SaveCurrent := False;
 If PlanFile = '' Then PlanFile := 'TIGRE.TGR';
 If SavePlan(PlanFile) Then Begin
  StatusMsg := 'Plan enregistre : ' + PlanFile;
  SaveCurrent := True;
 End Else ShowMessageBox('Enregistrer', 'Impossible d''ecrire : ' + PlanFile);
 RedrawAll;
End;

Procedure SaveAs;
Var S: String;
Begin
 S := PlanFile;
 If Not ShowInputBox('Enregistrer sous', 'Nom du fichier (.TGR)', S, 60) Then Exit;
 S := TrimStr(S);
 If S = '' Then Exit;
 If Pos('.', S) = 0 Then S := S + '.TGR';
 PlanFile := S;
 SaveCurrent;
End;

{ True si l'on peut poursuivre (donnees sauvegardees ou abandonnees) }
Function ConfirmDiscard: Boolean;
Begin
 ConfirmDiscard := True;
 If PlanDirty Then Begin
  If ShowConfirmBox('Plan modifie', 'Enregistrer les modifications du plan ?') Then SaveCurrent;
 End;
End;

Procedure DlgOpenPlan;
Var R, L: Integer; S: String;
Begin
 If Not ConfirmDiscard Then Exit;
 CollectPlanFiles;
 DlgInit(Dlg, 'Ouvrir un plan', 480, 270);
 DlgAddLabel(Dlg, 10, 6, 'Plans disponibles (' + IntToStr(ListCnt) + ')');
 L := DlgAddList(Dlg, 10, 20, 458, 150);
 DlgAddButton(Dlg, 90, 190, 90, 'Ouvrir', 1, #0);
 DlgAddButton(Dlg, 195, 190, 90, 'Autre...', 2, #0);
 DlgAddButton(Dlg, 300, 190, 90, 'Annuler', -1, #0);
 Dlg.Focus := L;
 R := DlgRun(Dlg);
 If (R = 1) And (ListCnt > 0) Then OpenPlanFile(ListBuf^[Dlg.Ctrls[L].ListSel])
 Else If R = 2 Then Begin
  S := '';
  If ShowInputBox('Ouvrir un plan', 'Nom du fichier (.TGR)', S, 60) Then
   If TrimStr(S) <> '' Then OpenPlanFile(TrimStr(S));
 End;
End;

{ ============================================================
  AIDE
  ============================================================ }

Procedure ShowUsage;
Begin
 ListClear;
 ListAdd('TIGRE - Traitement Informatise de la Gestion du Reseau des Egouts');
 ListAdd('');
 ListAdd('La carte (a gauche) montre le reseau d''assainissement : regards,');
 ListAdd('canalisations, ouvrages speciaux, voies, fleuve et parcs.');
 ListAdd('');
 ListAdd('Panneau de droite :');
 ListAdd('  - les sections (Ouvrages, Occupation, Fond de plan...) ouvrent');
 ListAdd('    la liste des couches ; A = affichee, R = reperable (cliquable),');
 ListAdd('    T = texte (etiquettes).');
 ListAdd('  - Select./Spatial/Logique/Specif. : modes de selection (clic,');
 ListAdd('    fenetre, parcours amont/aval, attributs).');
 ListAdd('  - Cadrer, Emprise : zoom sur la selection / sur tout le plan.');
 ListAdd('  - Lister, Sauver, Entete, Macro, Tout, Reinit.');
 ListAdd('  - Rech. voie : recherche d''une rue ; Documents : fiche d''ouvrage.');
 ListAdd('');
 ListAdd('Souris : clic gauche = outil actif ; clic droit + glisser = deplacer ;');
 ListAdd('double-clic = proprietes de l''ouvrage.');
 ListAdd('');
 ListAdd('Occupation > Remplissage colore les troncons selon leur taux de');
 ListAdd('remplissage (formule de Manning) ; Analyse > Pluie de projet fait');
 ListAdd('varier le debit pluvial.');
 ListAdd('');
 ListAdd('Les plans sont des fichiers texte .TGR (voir SAMPLES\TIGRE).');
 ShowReport('Mode d''emploi');
End;

Procedure ShowKeys;
Begin
 ListClear;
 ListAdd('Fleches            Deplacer la carte');
 ListAdd('+ / -  PgUp/PgDn  Zoom avant / arriere');
 ListAdd('Home               Emprise totale du plan');
 ListAdd('C                  Cadrer sur la selection');
 ListAdd('Entree / F4        Proprietes de l''ouvrage selectionne');
 ListAdd('Suppr              Supprimer la selection');
 ListAdd('Echap              Annuler l''outil, la selection et les traces');
 ListAdd('F2                 Rechercher un ouvrage');
 ListAdd('F3                 Rechercher une voie');
 ListAdd('F5                 Redessiner');
 ListAdd('F6                 Carine : liste des etablissements');
 ListAdd('F7 / F8            Tracer l''aval / l''amont');
 ListAdd('F9                 Statistiques du reseau');
 ListAdd('Ctrl+O / Ctrl+S    Ouvrir / enregistrer le plan');
 ListAdd('Alt+lettre         Ouvrir un menu (F V O E I A C H)');
 ListAdd('Alt+X              Quitter');
 ShowReport('Raccourcis clavier');
End;

Procedure ShowAbout;
Begin
 ShowMessageBox('A propos de TIGRE',
  'TIGRE ' + TIGRE_VERSION + ' - clone du logiciel de gestion du reseau des egouts.' + #10 +
  'Plans d''exemple : Paris, Montreal, Londres (SAMPLES\TIGRE).' + #10 +
  '(c) 2026 Sylvain Maltais - www.gladir.com');
End;

{ ============================================================
  COMMANDES
  ============================================================ }

Const
 TAG_FILE_OPEN   = 110;
 TAG_FILE_SAVE   = 111;
 TAG_FILE_SAVEAS = 112;
 TAG_FILE_CSV    = 113;
 TAG_FILE_REPORT = 114;
 TAG_FILE_QUIT   = 119;
 TAG_VIEW_ZIN    = 120;
 TAG_VIEW_ZOUT   = 121;
 TAG_VIEW_EXTENT = 122;
 TAG_VIEW_FRAME  = 123;
 TAG_VIEW_REDRAW = 124;
 TAG_VIEW_GRID   = 126;
 TAG_VIEW_HEADER = 127;
 TAG_OUV_FIND    = 130;
 TAG_OUV_PROPS   = 131;
 TAG_OUV_ADDNODE = 132;
 TAG_OUV_ADDPIPE = 133;
 TAG_OUV_DELETE  = 134;
 TAG_OUV_LIST    = 135;
 TAG_OUV_SHEET   = 136;
 TAG_EV_NEW      = 140;
 TAG_EV_LIST     = 141;
 TAG_IV_NEW      = 150;
 TAG_IV_LIST     = 151;
 TAG_IV_FINISH   = 152;
 TAG_AN_DOWN     = 160;
 TAG_AN_UP       = 161;
 TAG_AN_CLEAR    = 162;
 TAG_AN_CAPA     = 163;
 TAG_AN_RAIN     = 164;
 TAG_AN_SLOPES   = 165;
 TAG_AN_CONN     = 166;
 TAG_AN_STATS    = 167;
 TAG_CAR_LIST    = 170;
 TAG_CAR_ADD     = 171;
 TAG_CAR_SECTOR  = 172;
 TAG_CAR_NODE    = 173;
 TAG_HELP_USAGE  = 180;
 TAG_HELP_KEYS   = 181;
 TAG_HELP_ABOUT  = 182;

Procedure SetTool(T: Integer);
Begin
 Tool := T;
 PendingNode := -1;
 Case T Of
  TL_SELECT: StatusMsg := 'Selection : cliquez sur un ouvrage.';
  TL_PAN: StatusMsg := 'Deplacement : glissez la carte avec la souris.';
  TL_ZOOMWIN: StatusMsg := 'Zoom fenetre : tracez un rectangle.';
  TL_MEASURE: StatusMsg := 'Mesure : cliquez les points, clic droit pour terminer.';
  TL_ADDNODE: StatusMsg := 'Ajout de regard : cliquez a l''emplacement voulu.';
  TL_ADDPIPE: StatusMsg := 'Ajout de troncon : cliquez le regard amont puis le regard aval.';
  TL_WINSEL: StatusMsg := 'Selection spatiale : tracez un rectangle autour des ouvrages.';
 End;
 If T <> TL_MEASURE Then Begin MeasCnt := 0; MeasLen := 0; End;
 DrawToolbar;
 DrawPanel;
 DrawStatusBar;
End;

Procedure DeleteSelection;
Var I, N: Integer;
Begin
 N := SelCount;
 If N > 1 Then Begin
  If Not ShowConfirmBox('Supprimer', 'Supprimer les ' + IntToStr(N) + ' ouvrages selectionnes ?') Then Exit;
  For I := PipeCnt - 1 Downto 0 Do If Pipes^[I].Sel Then DeletePipe(I);
  For I := NodeCnt - 1 Downto 0 Do If Nodes^[I].Sel Then DeleteNode(I);
  ClearSelection;
 End Else Begin
  Case SelKind Of
   SEL_NODE: If ValidNode(SelIdx) Then Begin
    If Not ShowConfirmBox('Supprimer', 'Supprimer le regard ' + Nodes^[SelIdx].Id + ' et ses troncons ?') Then Exit;
    DeleteNode(SelIdx);
   End;
   SEL_PIPE: If ValidPipe(SelIdx) Then Begin
    If Not ShowConfirmBox('Supprimer', 'Supprimer le troncon ' + Pipes^[SelIdx].Id + ' ?') Then Exit;
    DeletePipe(SelIdx);
   End;
   SEL_ESTAB: If Not ShowConfirmBox('Supprimer', 'Supprimer cet etablissement ?') Then Exit Else DeleteEstab(SelIdx);
   SEL_EVENT: If Not ShowConfirmBox('Supprimer', 'Supprimer cet evenement ?') Then Exit Else DeleteEvent(SelIdx);
   SEL_INTERV: If Not ShowConfirmBox('Supprimer', 'Supprimer cette intervention ?') Then Exit Else DeleteInterv(SelIdx);
  Else Begin
   SetStatus('Aucun objet selectionne.');
   Exit;
  End;
  End;
  ClearSelection;
 End;
 ComputeHydraulics;
 StatusMsg := 'Objet(s) supprime(s).';
 RedrawAll;
End;

Procedure EditSelection;
Begin
 Case SelKind Of
  SEL_NODE: DlgNodeProps(SelIdx);
  SEL_PIPE: DlgPipeProps(SelIdx);
  SEL_ESTAB: DlgEstab(SelIdx);
  SEL_EVENT: DlgEvent(SelIdx);
  SEL_INTERV: DlgInterv(SelIdx);
 Else SetStatus('Aucun objet selectionne.');
 End;
 RedrawAll;
End;

Procedure ListEvents;
Var I, Sel: Integer;
Begin
 ListClear;
 For I := 0 To EvCnt - 1 Do
  ListAddObj(PadRight(Events^[I].Id, 6) + PadRight(Events^[I].Date, 11) + PadRight(EvKindName[Events^[I].Kind], 13) +
             PadRight(EvStatName[Events^[I].Status], 14) + Events^[I].Desc, SEL_EVENT, I);
 If ListCnt = 0 Then Begin
  ShowMessageBox('Evenements', 'Aucun evenement enregistre.');
  Exit;
 End;
 Sel := 0;
 If DlgPickList('Evenements', IntToStr(EvCnt) + ' evenements', 600, 300, Sel, 'Aller a', 'Fermer') Then
  GotoObject(SEL_EVENT, Sel);
End;

Procedure ListIntervs;
Var I, Sel: Integer;
Begin
 ListClear;
 For I := 0 To IvCnt - 1 Do
  ListAddObj(PadRight(Intervs^[I].Id, 6) + PadRight(Intervs^[I].Date, 11) + PadRight(IvKindName[Intervs^[I].Kind], 17) +
             PadRight(IvStatName[Intervs^[I].Status], 10) + PadRight(Intervs^[I].Team, 13) +
             RealToStr(Intervs^[I].Cost, 0, 0), SEL_INTERV, I);
 If ListCnt = 0 Then Begin
  ShowMessageBox('Interventions', 'Aucune intervention enregistree.');
  Exit;
 End;
 Sel := 0;
 If DlgPickList('Interventions', IntToStr(IvCnt) + ' interventions', 600, 300, Sel, 'Aller a', 'Fermer') Then
  GotoObject(SEL_INTERV, Sel);
End;

Procedure FinishIntervention;
Var Sel: Integer; I, N: Integer;
Begin
 If (SelKind = SEL_INTERV) And (SelIdx >= 0) And (SelIdx < IvCnt) Then Begin
  Intervs^[SelIdx].Status := 2;
  PlanDirty := True;
  StatusMsg := 'Intervention ' + Intervs^[SelIdx].Id + ' terminee.';
  RedrawAll;
  Exit;
 End;
 ListClear;
 For I := 0 To IvCnt - 1 Do
  If Intervs^[I].Status < 2 Then
   ListAddObj(PadRight(Intervs^[I].Id, 6) + PadRight(IvKindName[Intervs^[I].Kind], 17) +
              PadRight(IvStatName[Intervs^[I].Status], 10) + ObjLabel(Intervs^[I].TKind, Intervs^[I].TIdx),
              SEL_INTERV, I);
 If ListCnt = 0 Then Begin
  ShowMessageBox('Interventions', 'Aucune intervention a terminer.');
  Exit;
 End;
 Sel := 0;
 If DlgPickList('Terminer une intervention', 'Choisir l''intervention terminee', 520, 260, Sel,
                'Terminer', 'Annuler') Then Begin
  N := ListIdx[Sel];
  Intervs^[N].Status := 2;
  PlanDirty := True;
  StatusMsg := 'Intervention ' + Intervs^[N].Id + ' terminee.';
  RedrawAll;
 End;
End;

Procedure SelectAllVisible;
Var I, N: Integer;
Begin
 ClearSelection;
 N := 0;
 For I := 0 To NodeCnt - 1 Do
  If Layers[NodeLayer(Nodes^[I].Kind)].A Then Begin Nodes^[I].Sel := True; Inc(N); End;
 For I := 0 To PipeCnt - 1 Do
  If PipeVisible(Pipes^[I]) Then Begin Pipes^[I].Sel := True; Inc(N); End;
 StatusMsg := IntToStr(N) + ' ouvrages selectionnes.';
 RedrawAll;
End;

Procedure ResetAll;
Begin
 ClearSelection;
 ClearTrace;
 MeasCnt := 0; MeasLen := 0;
 PendingNode := -1;
 Layers[L_REMPLI].A := False;
 Layers[L_PENTE].A := False;
 Layers[L_DIAM].A := False;
 Tool := TL_SELECT;
 StatusMsg := 'Affichage reinitialise.';
 RedrawAll;
End;

Procedure DoCommand(Tag: LongInt);
Begin
 Case Tag Of
  TAG_FILE_OPEN: DlgOpenPlan;
  TAG_FILE_SAVE: SaveCurrent;
  TAG_FILE_SAVEAS: SaveAs;
  TAG_FILE_CSV: Begin
   If ExportCSV Then ShowMessageBox('Export CSV', 'Fichiers REGARDS.CSV et TRONCONS.CSV crees.')
   Else ShowMessageBox('Export CSV', 'Erreur d''ecriture.');
  End;
  TAG_FILE_REPORT: Begin
   If ExportReport Then ShowMessageBox('Rapport', 'Rapport statistique ecrit dans RAPPORT.TXT.')
   Else ShowMessageBox('Rapport', 'Erreur d''ecriture.');
  End;
  TAG_FILE_QUIT: If ConfirmDiscard Then QuitRequested := True;
  TAG_VIEW_ZIN: ZoomBy(2.0);
  TAG_VIEW_ZOUT: ZoomBy(0.5);
  TAG_VIEW_EXTENT: Begin FitExtent; RedrawAll; End;
  TAG_VIEW_FRAME: FrameSelection;
  TAG_VIEW_REDRAW: RedrawAll;
  TAG_VIEW_GRID: Begin Layers[L_GRILLE].A := Not Layers[L_GRILLE].A; RedrawAll; End;
  TAG_VIEW_HEADER: Begin ShowHeader := Not ShowHeader; RedrawAll; End;
  TAG_OUV_FIND: FindObject;
  TAG_OUV_PROPS: EditSelection;
  TAG_OUV_ADDNODE: SetTool(TL_ADDNODE);
  TAG_OUV_ADDPIPE: SetTool(TL_ADDPIPE);
  TAG_OUV_DELETE: DeleteSelection;
  TAG_OUV_LIST: ListSelection;
  TAG_OUV_SHEET: Begin
   BuildSheet;
   If ListCnt = 0 Then SetStatus('Aucun objet selectionne : selectionnez un ouvrage.')
   Else ShowReport('Documents');
  End;
  TAG_EV_NEW: Begin
   If DlgEvent(EvCnt) Then StatusMsg := 'Evenement enregistre.';
   RedrawAll;
  End;
  TAG_EV_LIST: ListEvents;
  TAG_IV_NEW: Begin
   If DlgInterv(IvCnt) Then StatusMsg := 'Intervention enregistree.';
   RedrawAll;
  End;
  TAG_IV_LIST: ListIntervs;
  TAG_IV_FINISH: FinishIntervention;
  TAG_AN_DOWN: DoTrace(1);
  TAG_AN_UP: DoTrace(-1);
  TAG_AN_CLEAR: Begin ClearTrace; StatusMsg := 'Traces effacees.'; RedrawAll; End;
  TAG_AN_CAPA: ShowCapacity;
  TAG_AN_RAIN: DlgRain;
  TAG_AN_SLOPES: DoAnomalies;
  TAG_AN_CONN: Begin BuildConnectivity; ShowReport('Connectivite du reseau'); RedrawAll; End;
  TAG_AN_STATS: Begin BuildStatsReport; ShowReport('Statistiques du reseau'); End;
  TAG_CAR_LIST: CarineWindow;
  TAG_CAR_ADD: Begin
   If DlgEstab(EstCnt) Then StatusMsg := 'Etablissement ajoute.';
   RedrawAll;
  End;
  TAG_CAR_SECTOR: CarineBySector;
  TAG_CAR_NODE: CarineOfNode;
  TAG_HELP_USAGE: ShowUsage;
  TAG_HELP_KEYS: ShowKeys;
  TAG_HELP_ABOUT: ShowAbout;
 End;
End;

Procedure ExecuteMenuItem(Var Item: TMenuItem);
Begin
 DoCommand(Item.Tag);
End;

{ ============================================================
  CONSTRUCTION DES MENUS ET DES COUCHES
  ============================================================ }

Procedure BuildMainMenu;
Begin
 MainMenuBar.MenuCount := 0;
 MainMenuBar.Y := 0;
 MainMenuBar.Height := MENUBAR_HEIGHT;

 InitMenu(MainMenuBar.Menus[0], 'Fichier');
 AddMenuItem(MainMenuBar.Menus[0], 'Ouvrir un plan...',  'Ctrl+O', TAG_FILE_OPEN);
 AddMenuItem(MainMenuBar.Menus[0], 'Enregistrer',        'Ctrl+S', TAG_FILE_SAVE);
 AddMenuItem(MainMenuBar.Menus[0], 'Enregistrer sous...', '',      TAG_FILE_SAVEAS);
 AddMenuSeparator(MainMenuBar.Menus[0]);
 AddMenuItem(MainMenuBar.Menus[0], 'Exporter en CSV',    '',       TAG_FILE_CSV);
 AddMenuItem(MainMenuBar.Menus[0], 'Exporter le rapport', '',      TAG_FILE_REPORT);
 AddMenuSeparator(MainMenuBar.Menus[0]);
 AddMenuItem(MainMenuBar.Menus[0], 'Quitter',            'Alt+X',  TAG_FILE_QUIT);
 MainMenuBar.Menus[0].Width := MenuItemWidth(MainMenuBar.Menus[0]);

 InitMenu(MainMenuBar.Menus[1], 'Vue');
 AddMenuItem(MainMenuBar.Menus[1], 'Zoom avant',         '+',      TAG_VIEW_ZIN);
 AddMenuItem(MainMenuBar.Menus[1], 'Zoom arriere',       '-',      TAG_VIEW_ZOUT);
 AddMenuItem(MainMenuBar.Menus[1], 'Emprise totale',     'Home',   TAG_VIEW_EXTENT);
 AddMenuItem(MainMenuBar.Menus[1], 'Cadrer la selection', 'C',     TAG_VIEW_FRAME);
 AddMenuSeparator(MainMenuBar.Menus[1]);
 AddMenuItem(MainMenuBar.Menus[1], 'Redessiner',         'F5',     TAG_VIEW_REDRAW);
 AddMenuItem(MainMenuBar.Menus[1], 'Grille',             '',       TAG_VIEW_GRID);
 AddMenuItem(MainMenuBar.Menus[1], 'En-tete de plan',    '',       TAG_VIEW_HEADER);
 MainMenuBar.Menus[1].Width := MenuItemWidth(MainMenuBar.Menus[1]);

 InitMenu(MainMenuBar.Menus[2], 'Ouvrages');
 AddMenuItem(MainMenuBar.Menus[2], 'Rechercher...',      'F2',     TAG_OUV_FIND);
 AddMenuItem(MainMenuBar.Menus[2], 'Proprietes...',      'Entree', TAG_OUV_PROPS);
 AddMenuItem(MainMenuBar.Menus[2], 'Fiche (documents)',  '',       TAG_OUV_SHEET);
 AddMenuSeparator(MainMenuBar.Menus[2]);
 AddMenuItem(MainMenuBar.Menus[2], 'Ajouter un regard',  '',       TAG_OUV_ADDNODE);
 AddMenuItem(MainMenuBar.Menus[2], 'Ajouter un troncon', '',       TAG_OUV_ADDPIPE);
 AddMenuItem(MainMenuBar.Menus[2], 'Supprimer',          'Suppr',  TAG_OUV_DELETE);
 AddMenuSeparator(MainMenuBar.Menus[2]);
 AddMenuItem(MainMenuBar.Menus[2], 'Lister la selection...', '',   TAG_OUV_LIST);
 MainMenuBar.Menus[2].Width := MenuItemWidth(MainMenuBar.Menus[2]);

 InitMenu(MainMenuBar.Menus[3], 'Evenements');
 AddMenuItem(MainMenuBar.Menus[3], 'Nouvel evenement...', '',      TAG_EV_NEW);
 AddMenuItem(MainMenuBar.Menus[3], 'Liste des evenements...', '',  TAG_EV_LIST);
 MainMenuBar.Menus[3].Width := MenuItemWidth(MainMenuBar.Menus[3]);

 InitMenu(MainMenuBar.Menus[4], 'Interventions');
 AddMenuItem(MainMenuBar.Menus[4], 'Nouvelle intervention...', '', TAG_IV_NEW);
 AddMenuItem(MainMenuBar.Menus[4], 'Liste des interventions...', '', TAG_IV_LIST);
 AddMenuItem(MainMenuBar.Menus[4], 'Terminer une intervention', '', TAG_IV_FINISH);
 MainMenuBar.Menus[4].Width := MenuItemWidth(MainMenuBar.Menus[4]);

 InitMenu(MainMenuBar.Menus[5], 'Analyse');
 AddMenuItem(MainMenuBar.Menus[5], 'Tracer l''aval',     'F7',     TAG_AN_DOWN);
 AddMenuItem(MainMenuBar.Menus[5], 'Tracer l''amont',    'F8',     TAG_AN_UP);
 AddMenuItem(MainMenuBar.Menus[5], 'Effacer les traces', '',       TAG_AN_CLEAR);
 AddMenuSeparator(MainMenuBar.Menus[5]);
 AddMenuItem(MainMenuBar.Menus[5], 'Capacite hydraulique...', '',  TAG_AN_CAPA);
 AddMenuItem(MainMenuBar.Menus[5], 'Pluie de projet...', '',       TAG_AN_RAIN);
 AddMenuItem(MainMenuBar.Menus[5], 'Pentes anormales...', '',      TAG_AN_SLOPES);
 AddMenuItem(MainMenuBar.Menus[5], 'Connectivite...',    '',       TAG_AN_CONN);
 AddMenuItem(MainMenuBar.Menus[5], 'Statistiques...',    'F9',     TAG_AN_STATS);
 MainMenuBar.Menus[5].Width := MenuItemWidth(MainMenuBar.Menus[5]);

 InitMenu(MainMenuBar.Menus[6], 'Carine');
 AddMenuItem(MainMenuBar.Menus[6], 'Etablissements...',  'F6',     TAG_CAR_LIST);
 AddMenuItem(MainMenuBar.Menus[6], 'Ajouter...',         '',       TAG_CAR_ADD);
 AddMenuSeparator(MainMenuBar.Menus[6]);
 AddMenuItem(MainMenuBar.Menus[6], 'Rejets par secteur...', '',    TAG_CAR_SECTOR);
 AddMenuItem(MainMenuBar.Menus[6], 'Etabl. du regard...', '',      TAG_CAR_NODE);
 MainMenuBar.Menus[6].Width := MenuItemWidth(MainMenuBar.Menus[6]);

 InitMenu(MainMenuBar.Menus[7], 'Aide');
 AddMenuItem(MainMenuBar.Menus[7], 'Mode d''emploi...',  '',       TAG_HELP_USAGE);
 AddMenuItem(MainMenuBar.Menus[7], 'Raccourcis clavier...', '',    TAG_HELP_KEYS);
 AddMenuSeparator(MainMenuBar.Menus[7]);
 AddMenuItem(MainMenuBar.Menus[7], 'A propos...',        '',       TAG_HELP_ABOUT);
 MainMenuBar.Menus[7].Width := MenuItemWidth(MainMenuBar.Menus[7]);

 MainMenuBar.MenuCount := 8;
End;

Procedure SetLayer(I: Integer; N: String; Sec: Integer; A, R, T: Boolean);
Begin
 Layers[I].Name := N;
 Layers[I].Sec := Sec;
 Layers[I].A := A;
 Layers[I].R := R;
 Layers[I].T := T;
End;

Procedure InitLayers;
Begin
 SetLayer(L_REGARD,   'Regards',     0, True,  True,  False);
 SetLayer(L_UNIT,     'Unitaire',    0, True,  True,  False);
 SetLayer(L_EU,       'Eaux usees',  0, True,  True,  False);
 SetLayer(L_EP,       'Pluvial',     0, True,  True,  False);
 SetLayer(L_COLL,     'Collecteurs', 0, True,  True,  False);
 SetLayer(L_VANNE,    'Vannes',      0, True,  True,  False);
 SetLayer(L_POMP,     'Pompages',    0, True,  True,  True);
 SetLayer(L_BASSIN,   'Bassins',     0, True,  True,  True);
 SetLayer(L_DEVERS,   'Deversoirs',  0, True,  True,  False);
 SetLayer(L_EXUT,     'Exutoires',   0, True,  True,  True);
 SetLayer(L_CHANTIER, 'Chantiers',   1, True,  True,  False);
 SetLayer(L_PLANIFIE, 'Planifies',   1, True,  True,  False);
 SetLayer(L_EV_OUVERT,'Ouverts',     2, True,  True,  False);
 SetLayer(L_EV_CLOS,  'Resolus',     2, False, True,  False);
 SetLayer(L_IV_FINI,  'Terminees',   3, False, True,  False);
 SetLayer(L_VISITABLE,'Visitables',  4, False, False, False);
 SetLayer(L_DEGRADE,  'Deg./Crit.',  4, False, False, False);
 SetLayer(L_REMPLI,   'Remplissage', 5, False, False, False);
 SetLayer(L_PENTE,    'Pentes',      5, False, False, False);
 SetLayer(L_DIAM,     'Diametres',   5, False, False, False);
 SetLayer(L_VOIES,    'Voies',       6, True,  False, False);
 SetLayer(L_NOMS,     'Noms voies',  6, True,  False, False);
 SetLayer(L_FLEUVE,   'Fleuve',      6, True,  False, False);
 SetLayer(L_PARCS,    'Parcs',       6, True,  False, False);
 SetLayer(L_ETAB,     'Etablisst.',  6, True,  True,  False);
 SetLayer(L_GRILLE,   'Grille',      6, False, False, False);
End;

{ ============================================================
  GESTION DE LA SOURIS ET DU CLAVIER
  ============================================================ }

Var
 DragMode   : Integer;      { 0=aucun 1=deplacement 2=rectangle }
 DragX0, DragY0 : Integer;  { position ecran du debut }
 DragCX0, DragCY0 : Real;
 DragLastX, DragLastY : Integer;
 RubX2, RubY2 : Integer;

Procedure DrawRubber(X1, Y1, X2, Y2: Integer);
Begin
 HideMouse;
 SetWriteMode(XORPut);
 SetColor(White);
 Rectangle(X1, Y1, X2, Y2);
 SetWriteMode(NormalPut);
 ShowMouse;
End;

Function InMap(X, Y: Integer): Boolean;
Begin
 InMap := (X >= MAP_X1) And (X <= MAP_X2) And (Y >= MAP_Y1) And (Y <= MAP_Y2);
End;

Procedure HandleToolbarClick(MX, MY: Integer);
Var I: Integer;
Begin
 For I := 0 To NTOOLBTN - 1 Do
  If (MX >= ToolBtnX1(I)) And (MX <= ToolBtnX2(I)) And (MY >= TOOLBAR_Y + 2) And
     (MY <= TOOLBAR_Y + TOOLBAR_H - 3) Then Begin
   If ToolOfButton(I) >= 0 Then SetTool(ToolOfButton(I))
   Else Case I Of
    3: ZoomBy(2.0);
    4: ZoomBy(0.5);
    5: Begin FitExtent; RedrawAll; End;
   End;
   Exit;
  End;
End;

Procedure HandlePanelButton(I: Integer);
Begin
 Case I Of
  0: SetTool(TL_SELECT);
  1: FrameSelection;
  2: SetTool(TL_WINSEL);
  3: Begin FitExtent; RedrawAll; End;
  4: DlgSelectLogical;
  5: ListSelection;
  6: DlgSelectSpecific;
  7: SaveCurrent;
  8: Begin ShowHeader := Not ShowHeader; RedrawMapOnly; End;
  9: DlgMacro;
  10: SelectAllVisible;
  11: ResetAll;
 End;
End;

Procedure HandlePanelClick(MX, MY: Integer);
Var I, Row, Li, X1, Y: Integer;
Begin
 { sections }
 For I := 0 To NSECTIONS - 1 Do Begin
  Y := PNL_SEC_Y0 + I * PNL_SEC_H;
  If (MY >= Y) And (MY < Y + PNL_SEC_H - 1) Then Begin
   OpenSection := I;
   RedrawPanelOnly;
   Exit;
  End;
 End;
 { couches }
 If (MY >= PNL_LAYER_Y0) And (MY < PNL_LAYER_Y0 + 12 * PNL_ROW_H) Then Begin
  Row := (MY - PNL_LAYER_Y0) Div PNL_ROW_H;
  Li := LayerOfRow(OpenSection, Row);
  If Li >= 0 Then Begin
   If (MX >= COL_A_X - 2) And (MX <= COL_A_X + 11) Then Layers[Li].A := Not Layers[Li].A
   Else If (MX >= COL_R_X - 2) And (MX <= COL_R_X + 11) Then Layers[Li].R := Not Layers[Li].R
   Else If (MX >= COL_T_X - 2) And (MX <= COL_T_X + 11) Then Layers[Li].T := Not Layers[Li].T
   Else If MX < COL_A_X - 2 Then Layers[Li].A := Not Layers[Li].A
   Else Exit;
   RedrawAll;
  End;
  Exit;
 End;
 { boutons }
 For I := 0 To NPANBTN - 1 Do Begin
  X1 := PANEL_X1 + 2 + (I Mod 2) * 74;
  Y := PNL_BTN_Y0 + (I Div 2) * (PNL_BTN_H + 1);
  If (MX >= X1) And (MX <= X1 + 72) And (MY >= Y) And (MY < Y + PNL_BTN_H) Then Begin
   HandlePanelButton(I);
   Exit;
  End;
 End;
 { recherche voie / documents }
 If (MY >= PNL_SEARCH_Y) And (MY < PNL_SEARCH_Y + PNL_BTN_H) Then Begin
  If MX < PANEL_X1 + 76 Then FindStreet
  Else DoCommand(TAG_OUV_SHEET);
 End;
End;

Procedure MapClick(Var Ev: TUIEvent);
Var
 MX, MY, WX, WY: Real;
 K, Idx, N: Integer;
Begin
 MX := Ev.MouseX - MAP_X1;
 MY := Ev.MouseY - MAP_Y1;
 S2W(MX, MY, WX, WY);
 Case Tool Of
  TL_SELECT: Begin
   If PickAt(MX, MY, K, Idx) Then Begin
    SetSelection(K, Idx);
    StatusMsg := ObjectDescription(K, Idx);
   End Else Begin
    ClearSelection;
    StatusMsg := 'Aucun objet a cet endroit.';
   End;
   If (Ev.Kind = EV_MOUSE_DBLCLICK) And (SelKind <> SEL_NONE) Then Begin
    RedrawMapOnly;
    RedrawPanelOnly;
    EditSelection;
   End Else Begin
    RedrawMapOnly;
    RedrawPanelOnly;
   End;
  End;
  TL_MEASURE: Begin
   If MeasCnt < MAX_MEAS Then Begin
    MeasPts[MeasCnt].X := Round(WX);
    MeasPts[MeasCnt].Y := Round(WY);
    If MeasCnt > 0 Then
     MeasLen := MeasLen + Dist2(MeasPts[MeasCnt - 1].X, MeasPts[MeasCnt - 1].Y,
                                MeasPts[MeasCnt].X, MeasPts[MeasCnt].Y);
    Inc(MeasCnt);
    StatusMsg := 'Distance mesuree : ' + RealToStr(MeasLen, 0, 1) + ' m';
    RedrawMapOnly;
   End;
  End;
  TL_ADDNODE: Begin
   Idx := AddNodeAt(WX, WY, NK_REGARD);
   If Idx >= 0 Then Begin
    ComputeHydraulics;
    SetSelection(SEL_NODE, Idx);
    StatusMsg := 'Regard ' + Nodes^[Idx].Id + ' ajoute.';
   End Else StatusMsg := 'Nombre maximal de regards atteint.';
   RedrawMapOnly;
   RedrawPanelOnly;
  End;
  TL_ADDPIPE: Begin
   If PickAt(MX, MY, K, Idx) And (K = SEL_NODE) Then Begin
    If PendingNode < 0 Then Begin
     PendingNode := Idx;
     SetSelection(SEL_NODE, Idx);
     StatusMsg := 'Regard amont ' + Nodes^[Idx].Id + ' : cliquez le regard aval.';
    End Else Begin
     N := AddPipeBetween(PendingNode, Idx);
     If N >= 0 Then Begin
      ComputeHydraulics;
      SetSelection(SEL_PIPE, N);
      StatusMsg := 'Troncon ' + Pipes^[N].Id + ' ajoute.';
     End Else StatusMsg := 'Troncon impossible (doublon ou limite atteinte).';
     PendingNode := -1;
    End;
    RedrawMapOnly;
    RedrawPanelOnly;
   End Else SetStatus('Cliquez sur un regard.');
  End;
 End;
End;

Procedure FinishRubber(X1, Y1, X2, Y2: Integer);
Var
 SX1, SY1, SX2, SY2, XA, YA, XB, YB, PX, PY: Real;
 I, N: Integer;
 Tmp: Real;
Begin
 SX1 := X1 - MAP_X1; SY1 := Y1 - MAP_Y1;
 SX2 := X2 - MAP_X1; SY2 := Y2 - MAP_Y1;
 If Tool = TL_ZOOMWIN Then ZoomWindow(SX1, SY1, SX2, SY2)
 Else Begin
  If SX1 > SX2 Then Begin Tmp := SX1; SX1 := SX2; SX2 := Tmp; End;
  If SY1 > SY2 Then Begin Tmp := SY1; SY1 := SY2; SY2 := Tmp; End;
  ClearSelection;
  N := 0;
  For I := 0 To NodeCnt - 1 Do
   If Layers[NodeLayer(Nodes^[I].Kind)].A And Layers[NodeLayer(Nodes^[I].Kind)].R Then Begin
    W2S(Nodes^[I].X, Nodes^[I].Y, PX, PY);
    If (PX >= SX1) And (PX <= SX2) And (PY >= SY1) And (PY <= SY2) Then Begin
     Nodes^[I].Sel := True; Inc(N);
    End;
   End;
  For I := 0 To PipeCnt - 1 Do
   If PipeVisible(Pipes^[I]) And Layers[PipeLayer(Pipes^[I].Cls)].R Then Begin
    W2S(Nodes^[Pipes^[I].N1].X, Nodes^[Pipes^[I].N1].Y, XA, YA);
    W2S(Nodes^[Pipes^[I].N2].X, Nodes^[Pipes^[I].N2].Y, XB, YB);
    If (XA >= SX1) And (XA <= SX2) And (YA >= SY1) And (YA <= SY2) And
       (XB >= SX1) And (XB <= SX2) And (YB >= SY1) And (YB <= SY2) Then Begin
     Pipes^[I].Sel := True; Inc(N);
    End;
   End;
  StatusMsg := IntToStr(N) + ' ouvrages dans la fenetre (selection spatiale).';
  RedrawMapOnly;
  RedrawPanelOnly;
 End;
End;

Procedure HandleMouse(Var Ev: TUIEvent);
Var DX, DY: Integer;
Begin
 Case Ev.Kind Of
  EV_MOUSE_DOWN, EV_MOUSE_DBLCLICK: Begin
   If Ev.MouseY < MENUBAR_HEIGHT Then HandleMenuEvent(Ev)
   Else If Ev.MouseY < MAP_Y1 - 1 Then HandleToolbarClick(Ev.MouseX, Ev.MouseY)
   Else If InMap(Ev.MouseX, Ev.MouseY) Then Begin
    If Ev.MouseBtn = MB_RIGHT Then Begin
     If Tool = TL_MEASURE Then Begin
      StatusMsg := 'Distance totale : ' + RealToStr(MeasLen, 0, 1) + ' m';
      MeasCnt := 0; MeasLen := 0;
      RedrawMapOnly;
     End Else Begin
      DragMode := 1;
      DragX0 := Ev.MouseX; DragY0 := Ev.MouseY;
      DragCX0 := ViewCX; DragCY0 := ViewCY;
      DragLastX := Ev.MouseX; DragLastY := Ev.MouseY;
     End;
    End Else If Ev.MouseBtn = MB_LEFT Then Begin
     If Tool = TL_PAN Then Begin
      DragMode := 1;
      DragX0 := Ev.MouseX; DragY0 := Ev.MouseY;
      DragCX0 := ViewCX; DragCY0 := ViewCY;
      DragLastX := Ev.MouseX; DragLastY := Ev.MouseY;
     End Else If (Tool = TL_ZOOMWIN) Or (Tool = TL_WINSEL) Then Begin
      DragMode := 2;
      DragX0 := Ev.MouseX; DragY0 := Ev.MouseY;
      RubX2 := Ev.MouseX; RubY2 := Ev.MouseY;
     End Else MapClick(Ev);
    End;
   End
   Else If Ev.MouseX >= PANEL_X1 Then HandlePanelClick(Ev.MouseX, Ev.MouseY);
  End;
  EV_MOUSE_MOVE: Begin
   If DragMode = 1 Then Begin
    DX := Ev.MouseX - DragX0;
    DY := Ev.MouseY - DragY0;
    ViewCX := DragCX0 - DX * ViewScale;
    ViewCY := DragCY0 + DY * ViewScale;
    If (Abs(Ev.MouseX - DragLastX) >= 6) Or (Abs(Ev.MouseY - DragLastY) >= 6) Then Begin
     DragLastX := Ev.MouseX; DragLastY := Ev.MouseY;
     RedrawMapOnly;
    End;
   End Else If DragMode = 2 Then Begin
    DrawRubber(DragX0, DragY0, RubX2, RubY2);
    RubX2 := IClamp(Ev.MouseX, MAP_X1, MAP_X2);
    RubY2 := IClamp(Ev.MouseY, MAP_Y1, MAP_Y2);
    DrawRubber(DragX0, DragY0, RubX2, RubY2);
   End Else If InMap(Ev.MouseX, Ev.MouseY) Then Begin
    S2W(Ev.MouseX - MAP_X1, Ev.MouseY - MAP_Y1, CurMapX, CurMapY);
    CurOnMap := True;
    If (Abs(Ev.MouseX - DragLastX) >= 3) Or (Abs(Ev.MouseY - DragLastY) >= 3) Then Begin
     DragLastX := Ev.MouseX; DragLastY := Ev.MouseY;
     HideMouse;
     DrawStatusBar;
     ShowMouse;
    End;
   End Else If CurOnMap Then Begin
    CurOnMap := False;
    HideMouse;
    DrawStatusBar;
    ShowMouse;
   End;
  End;
  EV_MOUSE_UP: Begin
   If DragMode = 1 Then Begin
    DragMode := 0;
    RedrawMapOnly;
   End Else If DragMode = 2 Then Begin
    DrawRubber(DragX0, DragY0, RubX2, RubY2);
    DragMode := 0;
    FinishRubber(DragX0, DragY0, RubX2, RubY2);
   End;
  End;
 End;
End;

Procedure HandleKeys(Var Ev: TUIEvent);
Begin
 If Ev.Kind = EV_KEY_CHAR Then Begin
  Case Ev.KeyChar Of
   '+', '=': ZoomBy(2.0);
   '-', '_': ZoomBy(0.5);
   #13: EditSelection;
   #27: Begin
    ClearSelection; ClearTrace; PendingNode := -1; MeasCnt := 0; MeasLen := 0;
    If Tool <> TL_SELECT Then Tool := TL_SELECT;
    StatusMsg := '';
    RedrawAll;
   End;
   'c', 'C': FrameSelection;
   'g', 'G': DoCommand(TAG_VIEW_GRID);
   #19: SaveCurrent;
   #15: DlgOpenPlan;
  End;
 End Else If Ev.Kind = EV_KEY_DOWN Then Begin
  Case Ev.KeyCode Of
   72: Begin PanPixels(0, MAP_H / 4.0); RedrawMapOnly; End;
   80: Begin PanPixels(0, -MAP_H / 4.0); RedrawMapOnly; End;
   75: Begin PanPixels(MAP_W / 4.0, 0); RedrawMapOnly; End;
   77: Begin PanPixels(-MAP_W / 4.0, 0); RedrawMapOnly; End;
   71: Begin FitExtent; RedrawAll; End;
   73: ZoomBy(2.0);
   81: ZoomBy(0.5);
   83: DeleteSelection;
   59: ShowUsage;
   60: FindObject;
   61: FindStreet;
   62: EditSelection;
   63: RedrawAll;
   64: CarineWindow;
   65: DoTrace(1);
   66: DoTrace(-1);
   67: DoCommand(TAG_AN_STATS);
   45: DoCommand(TAG_FILE_QUIT);
  End;
 End;
End;

Procedure MainLoop;
Var Ev: TUIEvent;
Begin
 DragMode := 0;
 DragLastX := 0; DragLastY := 0;
 Repeat
  PollEvents(Ev);
  If Ev.Kind = EV_NONE Then Delay(6)
  Else If (DragMode = 0) And MenuActive Then HandleMenuEvent(Ev)
  Else Begin
   Case Ev.Kind Of
    EV_MOUSE_DOWN, EV_MOUSE_DBLCLICK, EV_MOUSE_MOVE, EV_MOUSE_UP: Begin
     If (Ev.Kind = EV_MOUSE_MOVE) And (DragMode = 0) And (Ev.MouseY < MENUBAR_HEIGHT) And MenuActive Then
      HandleMenuEvent(Ev)
     Else HandleMouse(Ev);
    End;
    EV_KEY_DOWN, EV_KEY_CHAR: Begin
     HandleMenuEvent(Ev);
     If Not MenuActive Then HandleKeys(Ev);
    End;
   End;
  End;
 Until QuitRequested;
End;

{ ============================================================
  PROGRAMME PRINCIPAL
  ============================================================ }

Procedure InitState;
Begin
 QuitRequested := False;
 PrevMouseX := 0; PrevMouseY := 0; PrevMouseBtn := 0;
 LastClickX := 0; LastClickY := 0; LastClickTime := 0; LastClickBtn := MB_NONE;
 OpenMenuIdx := -1; SelItemIdx := -1; MenuActive := False;
 MenuBgBuf := Nil; MenuBgSaved := False;
 NodeCnt := 0; PipeCnt := 0; EstCnt := 0; EvCnt := 0; IvCnt := 0;
 BgCnt := 0; BgPtCnt := 0; SectorCnt := 0;
 Tool := TL_SELECT;
 OpenSection := 0;
 ShowHeader := False;
 RainI := 0.0;
 StatusMsg := '';
 PendingNode := -1;
 MeasCnt := 0; MeasLen := 0;
 CurOnMap := False; CurMapX := 0; CurMapY := 0;
 SelKind := SEL_NONE; SelIdx := -1;
 CarSortCol := -1; CarSortDesc := False; CarSel := 0; CarTop := 0;
 CarFilter[0] := ''; CarFilter[1] := ''; CarFilter[2] := '';
 CarFilter[3] := ''; CarFilter[4] := '';
 PlanFile := '';
 ViewCX := 0; ViewCY := 0; ViewScale := 5.0;
 ClearTrace;
 InitLayers;
End;

{ Charge le plan demande en ligne de commande ou PARIS par defaut }
Procedure LoadStartupPlan;
Var Arg: String; Loaded: Boolean;
Begin
 Loaded := False;
 Arg := ParamStr(1);
 If Arg <> '' Then Begin
  If Pos('.', Arg) = 0 Then Begin
   Arg := UpStr(Arg);
   If Arg = 'LONDRES' Then Arg := 'LONDON';
   If (Arg = 'NEW-YORK') Or (Arg = 'NEW_YORK') Or (Arg = 'NY') Then Arg := 'NEWYORK';
   If (Arg = 'LOS-ANGELES') Or (Arg = 'LOS_ANGELES') Or (Arg = 'LA') Then Arg := 'LOSANGELES';
   If (Arg = 'QUEBEC-CITY') Or (Arg = 'VILLE-DE-QUEBEC') Then Arg := 'QUEBEC';
   Loaded := LoadPlan(SamplesDir + Arg + '.TGR');
   If Not Loaded Then Loaded := LoadPlan(Arg + '.TGR');
  End Else Loaded := LoadPlan(Arg);
 End;
 If Not Loaded Then Loaded := LoadPlan(SamplesDir + 'PARIS.TGR');
 If Not Loaded Then Loaded := LoadPlan('PARIS.TGR');
 If Not Loaded Then Loaded := LoadPlan('..' + SepChar + SamplesDir + 'PARIS.TGR');
 If Not Loaded Then GenerateDemo;
 FinishLoad;
 StatusMsg := PlanTitle;
 If LoadTrunc Then StatusMsg := 'ATTENTION : plan tronque (memoire insuffisante)';
End;

BEGIN
 If(ParamStr(1)='/?')or(ParamStr(1)='--help')or(ParamStr(1)='-h')or
   (ParamStr(1)='/h')or(ParamStr(1)='/H')Then Begin
  WriteLn('TIGRE : Cette commande permet de lancer l''application ',
                   'de gestion du reseau des egouts ',
                   '(Traitement Informatise de la Gestion du Reseau des Egouts).');
  WriteLn;
  WriteLn('Syntaxe : TIGRE [fichier.TGR | ville] [/?]');
  WriteLn('Villes : PARIS, MONTREAL, LONDON, LAVAL, NEWYORK, LOSANGELES, TORONTO,');
  WriteLn('         OTTAWA, QUEBEC');
  WriteLn;
  Halt(0);
 End
  Else
 Begin
  AllocData;
  InitState;
  InitializeGraphics;
  If MouseDriverFound Then ShowMouse;
  LoadStartupPlan;
  BuildMainMenu;
  RedrawAll;
  MainLoop;
  If MouseDriverFound Then HideMouse;
  CloseGraph;
 End;
END.
