object FormMain: TFormMain
  Left = 0
  Top = 0
  Caption = 'FormMain'
  ClientHeight = 489
  ClientWidth = 726
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Panel1: TPanel
    Left = 543
    Top = 0
    Width = 183
    Height = 470
    Align = alRight
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitLeft = 869
    ExplicitHeight = 552
    object EditXMin: TLabeledEdit
      Left = 6
      Top = 72
      Width = 82
      Height = 23
      EditLabel.Width = 28
      EditLabel.Height = 15
      EditLabel.Caption = 'XMin'
      TabOrder = 0
      Text = ''
      OnChange = EditViewChange
    end
    object EditXMax: TLabeledEdit
      Left = 94
      Top = 72
      Width = 82
      Height = 23
      EditLabel.Width = 30
      EditLabel.Height = 15
      EditLabel.Caption = 'XMax'
      TabOrder = 1
      Text = ''
      OnChange = EditViewChange
    end
    object EditYMin: TLabeledEdit
      Left = 6
      Top = 120
      Width = 82
      Height = 23
      EditLabel.Width = 28
      EditLabel.Height = 15
      EditLabel.Caption = 'YMin'
      TabOrder = 2
      Text = ''
      OnChange = EditViewChange
    end
    object EditYMax: TLabeledEdit
      Left = 94
      Top = 120
      Width = 82
      Height = 23
      EditLabel.Width = 30
      EditLabel.Height = 15
      EditLabel.Caption = 'YMax'
      TabOrder = 3
      Text = ''
      OnChange = EditViewChange
    end
    object EditFunction: TLabeledEdit
      Left = 6
      Top = 24
      Width = 170
      Height = 23
      EditLabel.Width = 42
      EditLabel.Height = 15
      EditLabel.Caption = 'Y = F(X)'
      TabOrder = 4
      Text = ''
      OnChange = EditFunctionChange
    end
    object ButtonApply: TButton
      Left = 455
      Top = 24
      Width = 75
      Height = 25
      Caption = 'Draw'
      TabOrder = 5
    end
  end
  object PanelGraph: TPanel
    Left = 0
    Top = 0
    Width = 543
    Height = 470
    Align = alClient
    BevelKind = bkSoft
    BevelOuter = bvNone
    BorderWidth = 4
    DoubleBuffered = True
    ParentBackground = False
    ParentDoubleBuffered = False
    TabOrder = 1
    ExplicitLeft = 136
    ExplicitTop = 168
    ExplicitWidth = 185
    ExplicitHeight = 41
    object PaintBoxGraph: TPaintBox
      Left = 4
      Top = 4
      Width = 531
      Height = 458
      Align = alClient
      OnMouseDown = PaintBoxGraphMouseDown
      OnMouseMove = PaintBoxGraphMouseMove
      OnMouseUp = PaintBoxGraphMouseUp
      OnPaint = PaintBoxGraphPaint
      ExplicitLeft = -268
      ExplicitWidth = 613
      ExplicitHeight = 412
    end
  end
  object StatusBar: TStatusBar
    Left = 0
    Top = 470
    Width = 726
    Height = 19
    Panels = <
      item
        Width = 50
      end>
    ExplicitWidth = 183
  end
end
