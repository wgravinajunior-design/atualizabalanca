object FrmNutricional: TFrmNutricional
  Left = 0
  Top = 0
  Caption = 'Tabela Nutricional do Produto - Padr'#227'o Anvisa RDC 429'
  ClientHeight = 580
  ClientWidth = 650
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 5384214
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 10
      Width = 373
      Height = 21
      Caption = 'Informa'#231#227'o Nutricional Oficial (RDC 429 / IN 75)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblProdutoInfo: TLabel
      Left = 20
      Top = 36
      Width = 237
      Height = 15
      Caption = 'Produto: Selecione um produto para visualizar'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlLupas: TPanel
    Left = 0
    Top = 65
    Width = 650
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 1
    object lblRotulagemFrontalTit: TLabel
      Left = 15
      Top = 8
      Width = 247
      Height = 15
      Caption = 'Rotulagem Nutricional Frontal Obrigat'#243'ria:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblLupaAcucar: TLabel
      Left = 15
      Top = 30
      Width = 180
      Height = 22
      Alignment = taCenter
      AutoSize = False
      Caption = 'ALTO EM A'#199#218'CAR'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
    end
    object lblLupaGordura: TLabel
      Left = 210
      Top = 30
      Width = 190
      Height = 22
      Alignment = taCenter
      AutoSize = False
      Caption = 'ALTO EM GORD. SATURADA'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
    end
    object lblLupaSodio: TLabel
      Left = 415
      Top = 30
      Width = 180
      Height = 22
      Alignment = taCenter
      AutoSize = False
      Caption = 'ALTO EM S'#211'DIO'
      Color = clSilver
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentColor = False
      ParentFont = False
      Transparent = False
      Layout = tlCenter
    end
  end
  object pnlPorcao: TPanel
    Left = 0
    Top = 130
    Width = 650
    Height = 35
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lblPorcaoTexto: TLabel
      Left = 15
      Top = 9
      Width = 285
      Height = 15
      Caption = 'Por'#231#227'o: 50 g (1/2 x'#237'cara) | Total de por'#231#245'es: cerca de 10'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 5384214
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
  end
  object lvNutricional: TListView
    Left = 0
    Top = 165
    Width = 650
    Height = 360
    Align = alClient
    Columns = <
      item
        Caption = 'Nutriente / Componente'
        Width = 250
      end
      item
        Alignment = taRightJustify
        Caption = '100 g'
        Width = 120
      end
      item
        Alignment = taRightJustify
        Caption = 'Por'#231#227'o (g/ml)'
        Width = 130
      end
      item
        Alignment = taCenter
        Caption = '% VD*'
        Width = 100
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ViewStyle = vsReport
    TabOrder = 3
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 525
    Width = 650
    Height = 55
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 4
    object lblObsAnvisa: TLabel
      Left = 15
      Top = 8
      Width = 380
      Height = 13
      Caption = '*Percentual de valores di'#225'rios fornecidos pela por'#231#227'o (base 2.000 kcal / 8.400 kJ).'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object btnCopiarTabela: TButton
      Left = 15
      Top = 23
      Width = 160
      Height = 26
      Caption = 'Copiar Dados da Tabela'
      TabOrder = 0
      OnClick = btnCopiarTabelaClick
    end
    object btnFechar: TButton
      Left = 540
      Top = 15
      Width = 95
      Height = 32
      Caption = 'Fechar (Esc)'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
end
