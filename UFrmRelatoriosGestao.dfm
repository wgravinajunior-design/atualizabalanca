object FrmRelatoriosGestao: TFrmRelatoriosGestao
  Left = 0
  Top = 0
  Caption = 'GoUp Sistemas - Gest'#227'o Anal'#237'tica e Relat'#243'rios de Pesagem'
  ClientHeight = 670
  ClientWidth = 1080
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 15
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1080
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 2758415
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 8
      Width = 472
      Height = 21
      Caption = 'Gest'#227'o Anal'#237'tica, Vendas por Pesagem e Controle de Etiquetas'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 16
      Top = 32
      Width = 638
      Height = 15
      Caption = 'Acompanhe vendas por peso e pre'#231'o, faturamento, transa'#231#245'es, etiquetas emitidas por balan'#231'a e exporte para Excel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlFiltros: TPanel
    Left = 0
    Top = 60
    Width = 1080
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 15724527
    ParentBackground = False
    TabOrder = 1
    object lblDataIni: TLabel
      Left = 16
      Top = 8
      Width = 61
      Height = 15
      Caption = 'Data Inicial:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDataFim: TLabel
      Left = 145
      Top = 8
      Width = 55
      Height = 15
      Caption = 'Data Final:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDepto: TLabel
      Left = 275
      Top = 8
      Width = 79
      Height = 15
      Caption = 'Departamento:'
    end
    object lblTipoRelatorio: TLabel
      Left = 475
      Top = 8
      Width = 96
      Height = 15
      Caption = 'Tipo de Relat'#243'rio:'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object dtpDataIni: TDateTimePicker
      Left = 16
      Top = 27
      Width = 115
      Height = 25
      Date = 46320.000000000000000000
      Time = 0.710000000000000000
      TabOrder = 0
    end
    object dtpDataFim: TDateTimePicker
      Left = 145
      Top = 27
      Width = 115
      Height = 25
      Date = 46320.000000000000000000
      Time = 0.710000000000000000
      TabOrder = 1
    end
    object cboFiltroSetor: TComboBox
      Left = 275
      Top = 27
      Width = 185
      Height = 23
      Style = csDropDownList
      TabOrder = 2
    end
    object cboTipoRelatorio: TComboBox
      Left = 475
      Top = 27
      Width = 300
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 3
      Text = '1. Desempenho de Vendas e Pesagens por Produto'
      OnChange = cboTipoRelatorioChange
      Items.Strings = (
        '1. Desempenho de Vendas e Pesagens por Produto'
        '2. Desempenho Consolidado por Departamento'
        '3. Controle de Etiquetas Impressas por Balan'#231'a'
        '4. Diagn'#243'stico e Auditoria de Inconsist'#234'ncias de PLUs')
    end
    object btnFiltrar: TButton
      Left = 790
      Top = 23
      Width = 110
      Height = 32
      Caption = 'Gerar (F5)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 4
      OnClick = btnFiltrarClick
    end
    object btnExportarExcel: TButton
      Left = 908
      Top = 23
      Width = 140
      Height = 32
      Caption = 'Exportar Excel (F6)'
      TabOrder = 5
      OnClick = btnExportarExcelClick
    end
  end
  object pnlCardsKPI: TPanel
    Left = 0
    Top = 125
    Width = 1080
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = 16382457
    ParentBackground = False
    TabOrder = 2
    object pnlCard1: TPanel
      Left = 16
      Top = 10
      Width = 245
      Height = 60
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblCard1Titulo: TLabel
        Left = 12
        Top = 8
        Width = 146
        Height = 15
        Caption = 'Faturamento Estimado (R$):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCard1Valor: TLabel
        Left = 12
        Top = 26
        Width = 72
        Height = 25
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2272283
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCard2: TPanel
      Left = 277
      Top = 10
      Width = 245
      Height = 60
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblCard2Titulo: TLabel
        Left = 12
        Top = 8
        Width = 123
        Height = 15
        Caption = 'Volume Total Pesado:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCard2Valor: TLabel
        Left = 12
        Top = 26
        Width = 63
        Height = 25
        Caption = '0,00 kg'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 11162880
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCard3: TPanel
      Left = 538
      Top = 10
      Width = 245
      Height = 60
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblCard3Titulo: TLabel
        Left = 12
        Top = 8
        Width = 146
        Height = 15
        Caption = 'Total de Etiquetas Impressas:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCard3Valor: TLabel
        Left = 12
        Top = 26
        Width = 61
        Height = 25
        Caption = '0 etiq.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 33023
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCard4: TPanel
      Left = 799
      Top = 10
      Width = 250
      Height = 60
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 3
      object lblCard4Titulo: TLabel
        Left = 12
        Top = 8
        Width = 138
        Height = 15
        Caption = 'M'#233'dia por Pesagem / Ticket:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGrayText
        Font.Height = -11
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCard4Valor: TLabel
        Left = 12
        Top = 26
        Width = 72
        Height = 25
        Caption = 'R$ 0,00'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 7105644
        Font.Height = -19
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object lvRelatorio: TListView
    Left = 0
    Top = 205
    Width = 1080
    Height = 425
    Align = alClient
    Columns = <>
    GridLines = True
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 3
    ViewStyle = vsReport
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 630
    Width = 1080
    Height = 40
    Align = alBottom
    BevelOuter = bvNone
    Color = 15132390
    ParentBackground = False
    TabOrder = 4
    object lblStatusRegistros: TLabel
      Left = 16
      Top = 12
      Width = 145
      Height = 15
      Caption = '0 registros encontrados'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnImprimir: TButton
      Left = 825
      Top = 5
      Width = 140
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Visualizar / HTML'
      TabOrder = 0
      OnClick = btnImprimirClick
    end
    object btnFechar: TButton
      Left = 975
      Top = 5
      Width = 90
      Height = 30
      Anchors = [akTop, akRight]
      Caption = 'Fechar (Esc)'
      TabOrder = 1
      OnClick = btnFecharClick
    end
  end
  object dlgSalvarCSV: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Arquivo Excel / CSV (*.csv)|*.csv|Todos os arquivos (*.*)|*.*'
    Title = 'Salvar Relat'#243'rio em Formato Excel / CSV'
    Left = 712
    Top = 152
  end
end
