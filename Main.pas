unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask, Vcl.ComCtrls;

type
  TViewWindow = record
    XMin: Double;
    YMin: Double;
    XMax: Double;
    YMax: Double;
  private
    function GetHeight: Double;
    function GetWidth: Double;
  public
    constructor Create(const XMin, XMax, YMin, YMax: Double);
    property Width: Double read GetWidth;
    property Height: Double read GetHeight;
  end;

  TOpenPanel = class(TPanel)
  end;

  TFormMain = class(TForm)
    PaintBoxGraph: TPaintBox;
    Panel1: TPanel;
    PanelGraph: TPanel;
    EditXMin: TLabeledEdit;
    EditXMax: TLabeledEdit;
    EditYMin: TLabeledEdit;
    EditYMax: TLabeledEdit;
    EditFunction: TLabeledEdit;
    ButtonApply: TButton;
    StatusBar: TStatusBar;
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxGraphPaint(Sender: TObject);
    procedure PaintBoxGraphMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxGraphMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxGraphMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure EditViewChange(Sender: TObject);
    procedure EditFunctionChange(Sender: TObject);
  private
    ViewWindow: TViewWindow;
    Expression: string;
    IsDragGraph: Boolean;
    OldDragGraphPoint: TPoint;
    IsViewWindowUpdate: Boolean;
    procedure ShowViewWindow;
    procedure DrawGraph(const Canvas: TCanvas; const Width, Height: Integer);
    procedure PaintBoxGraphMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
  public
  end;

var
  FormMain: TFormMain;

implementation

uses
  MathParser, Math, GDIPAPI, GDIPOBJ, GDIPUTIL;

{$R *.dfm}

function Interpolate(const SrcMin, SrcMax, SrcValue: Double; const DstMin, DstMax: Double): Double;
begin
  if Math.IsZero(SrcMax - SrcMin) then
    Exit(0);
  Result := DstMin + ((DstMax - DstMin) / (SrcMax - SrcMin)) * (SrcValue - SrcMin);
end;

{ TFormMain }

// XMin....XMax
// -2      2
// -------------
// Canvas:
// 0       100

procedure TFormMain.DrawGraph(const Canvas: TCanvas; const Width, Height: Integer);
  function MakeGraphPoints: TPointFDynArray;
  var
    Parser: TMathParser;
    ScreenX: Integer;
    ScreenY: Double;
    X, Y: Double;
  begin
    //SetLength(Result, Width);

    Parser := TMathParser.Create;
    try
      Parser.Expression := Expression;

      for ScreenX := 0 to Width - 1 do
      begin
        try
          X := Interpolate(0, Width, ScreenX, ViewWindow.XMin, ViewWindow.XMax);
          Parser.Constants['X'] := X;
          Y := Parser.Calculate;

          if IsNan(Y) then
            Continue;

          ScreenY := Interpolate(ViewWindow.YMin, ViewWindow.YMax, Y, Height, 0);
          Result := Result + [MakePoint(ScreenX, ScreenY)];
        except
          on E: EParserError do
           ;
        end;
      end;
    finally
      Parser.Free;
    end;
  end;

var
  GraphPoints: TPointFDynArray;
  Graphis: TGPGraphics;
  Pen: TGPPen;
  AxesPen: TGPPen;
  ScreenX, ScreenY: Integer;
begin

  Graphis := nil;
  Pen := nil;
  AxesPen := nil;
  try
    Graphis := TGPGraphics.Create(Canvas.Handle);
    Graphis.SetSmoothingMode(SmoothingModeAntiAlias);

    // draw axes
    AxesPen := TGPPen.Create($FF000000);
    AxesPen.SetDashStyle(DashStyleDash);
    // Y
    ScreenX := Round(Interpolate(ViewWindow.XMin, ViewWindow.XMax, 0, 0, Width));
    if (ScreenX >= 0) and (ScreenX < Width) then
      Graphis.DrawLine(AxesPen, ScreenX, 0, ScreenX, Height);
    // X
    ScreenY := Round(Interpolate(ViewWindow.YMin, ViewWindow.YMax, 0, Height, 0));
    if (ScreenY >= 0) and (ScreenY < Height) then
      Graphis.DrawLine(AxesPen, 0, ScreenY, Width, ScreenY);

    // draw graph
    Pen := TGPPen.Create($FF0000FF, 2);
    GraphPoints := MakeGraphPoints();
    Graphis.DrawLines(Pen, PGPPointF(GraphPoints), Length(GraphPoints));

  finally
    Graphis.Free;
    Pen.Free;
    AxesPen.Free;
  end;
end;

procedure TFormMain.EditFunctionChange(Sender: TObject);
begin
  Expression := EditFunction.Text;
  PaintBoxGraph.Invalidate;
end;

procedure TFormMain.EditViewChange(Sender: TObject);
begin
  if IsViewWindowUpdate then
    Exit;

  StatusBar.Panels[0].Text := '';
  try
    ViewWindow.XMin := StrToFloat(EditXMin.Text, TFormatSettings.Invariant);
    ViewWindow.XMax := StrToFloat(EditXMax.Text, TFormatSettings.Invariant);
    ViewWindow.YMin := StrToFloat(EditYMin.Text, TFormatSettings.Invariant);
    ViewWindow.YMax := StrToFloat(EditYMax.Text, TFormatSettings.Invariant);
  except
    StatusBar.Panels[0].Text := 'Неверно заданны координаты!';
  end;
  PaintBoxGraph.Invalidate;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  ViewWindow := TViewWindow.Create(-5, 5, -2, 2);
  Expression := 'Sin(x) * Cos(2*x)';

  EditFunction.Text := Expression;
  ShowViewWindow;

  TOpenPanel(PanelGraph).OnMouseWheel := Self.PaintBoxGraphMouseWheel;
end;

procedure TFormMain.PaintBoxGraphMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then
  begin
    IsDragGraph := True;
    OldDragGraphPoint := TPoint.Create(X, Y);
  end;
end;

procedure TFormMain.PaintBoxGraphMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  DX, DY: Double;
begin
  if not IsDragGraph then
    Exit;

  DX := (OldDragGraphPoint.X - X) * (ViewWindow.Width / Max(PaintBoxGraph.ClientWidth, 1));
  DY := -(OldDragGraphPoint.Y - Y) * (ViewWindow.Height / Max(PaintBoxGraph.ClientHeight, 1));

  ViewWindow.XMin := ViewWindow.XMin + DX;
  ViewWindow.XMax := ViewWindow.XMax + DX;
  ViewWindow.YMin := ViewWindow.YMin + DY;
  ViewWindow.YMax := ViewWindow.YMax + DY;

  OldDragGraphPoint := TPoint.Create(X, Y);

  ShowViewWindow;
  PaintBoxGraph.Invalidate;
end;

procedure TFormMain.PaintBoxGraphMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if Button = TMouseButton.mbLeft then
    IsDragGraph := False;
end;

procedure TFormMain.PaintBoxGraphMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
const
  Step = 0.0002;
var
  DeltaX, DeltaY: Double;
begin
  DeltaX := WheelDelta * ViewWindow.Width * Step;
  DeltaY := WheelDelta * ViewWindow.Height * Step;
  ViewWindow.XMin := ViewWindow.XMin - DeltaX;
  ViewWindow.XMax := ViewWindow.XMax + DeltaX;
  ViewWindow.YMin := ViewWindow.YMin - DeltaY;
  ViewWindow.YMax := ViewWindow.YMax + DeltaY;

  ShowViewWindow;
  PaintBoxGraph.Invalidate;
end;

procedure TFormMain.PaintBoxGraphPaint(Sender: TObject);
begin
  DrawGraph(
    PaintBoxGraph.Canvas,
    PaintBoxGraph.ClientWidth,
    PaintBoxGraph.ClientHeight
  );
end;

procedure TFormMain.ShowViewWindow;
begin
  IsViewWindowUpdate := True;
  try
    EditXMin.Text := ViewWindow.XMin.ToString(TFormatSettings.Invariant);
    EditXMax.Text := ViewWindow.XMax.ToString(TFormatSettings.Invariant);
    EditYMin.Text := ViewWindow.YMin.ToString(TFormatSettings.Invariant);
    EditYMax.Text := ViewWindow.YMax.ToString(TFormatSettings.Invariant);
  finally
    IsViewWindowUpdate := False;
  end;
end;

{ TViewWindow }

constructor TViewWindow.Create(const XMin, XMax, YMin, YMax: Double);
begin
  Self.XMin := XMin;
  Self.XMax := XMax;
  Self.YMin := YMin;
  Self.YMax := YMax;
end;

function TViewWindow.GetHeight: Double;
begin
  Result := YMax - YMin;
end;

function TViewWindow.GetWidth: Double;
begin
  Result := XMax - XMin;
end;

end.
