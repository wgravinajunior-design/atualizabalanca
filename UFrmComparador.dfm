object FrmComparador: TFrmComparador
  Left = 0
  Top = 0
  Caption = 'Auditoria de Altera'#231#245'es de Pre'#231'os e Produtos'
  ClientHeight = 620
  ClientWidth = 1000
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
  object pnlTopo: TPanel
    Left = 0
    Top = 0
    Width = 1000
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 5384214
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 10
      Width = 425
      Height = 21
      Caption = 'Auditoria de Altera'#231#245'es e Pr'#233'via de Sincroniza'#231#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 20
      Top = 36
      Width = 473
      Height = 15
      Caption = 'Compare os pre'#231'os anteriores com os pre'#231'os atuais do ERP antes de enviar para as balan'#231'as'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlCards: TPanel
    Left = 0
    Top = 65
    Width = 1000
    Height = 75
    Align = alTop
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 1
    object pnlCardTotal: TPanel
      Left = 15
      Top = 10
      Width = 225
      Height = 55
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 0
      object lblCardTotalTit: TLabel
        Left = 12
        Top = 8
        Width = 105
        Height = 15
        Caption = 'Produtos na Balan'#231'a:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardTotalVal: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 21
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlack
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardReajustes: TPanel
      Left = 255
      Top = 10
      Width = 225
      Height = 55
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 1
      object lblCardReajustesTit: TLabel
        Left = 12
        Top = 8
        Width = 115
        Height = 15
        Caption = 'Pre'#231'os Reajustados:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardReajustesVal: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 21
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 32896
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardNovos: TPanel
      Left = 495
      Top = 10
      Width = 225
      Height = 55
      BevelOuter = bvNone
      Color = clWhite
      ParentBackground = False
      TabOrder = 2
      object lblCardNovosTit: TLabel
        Left = 12
        Top = 8
        Width = 110
        Height = 15
        Caption = 'Novos Cadastros PLU:'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object lblCardNovosVal: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 21
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clNavy
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
    object pnlCardPendentes: TPanel
      Left = 735
      Top = 10
      Width = 250
      Height = 55
      BevelOuter = bvNone
      Color = 15461375
      ParentBackground = False
      TabOrder = 3
      object lblCardPendentesTit: TLabel
        Left = 12
        Top = 8
        Width = 135
        Height = 15
        Caption = 'Falta C'#243'digo Balan'#231'a (ERP):'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clMaroon
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblCardPendentesVal: TLabel
        Left = 12
        Top = 26
        Width = 11
        Height = 21
        Caption = '0'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clRed
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 140
    Width = 1000
    Height = 42
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 2
    object lblFiltro: TLabel
      Left = 15
      Top = 12
      Width = 63
      Height = 15
      Caption = 'Filtrar Lista:'
    end
    object cbFiltro: TComboBox
      Left = 85
      Top = 8
      Width = 260
      Height = 23
      Style = csDropDownList
      ItemIndex = 0
      TabOrder = 0
      Text = '[Todos os Registros]'
      OnChange = cbFiltroChange
      Items.Strings = (
        '[Todos os Registros]'
        '[Apenas Pre'#231'os que Subiram]'
        '[Apenas Pre'#231'os que Baixaram]'
        '[Apenas Novos PLUs]'
        '[Apenas Cadastros Sem C'#243'digo Balan'#231'a]')
    end
    object btnAtualizar: TButton
      Left = 360
      Top = 7
      Width = 130
      Height = 27
      Caption = 'Atualizar Dados'
      TabOrder = 1
      OnClick = btnAtualizarClick
    end
  end
  object lvComparativo: TListView
    Left = 0
    Top = 182
    Width = 1000
    Height = 378
    Align = alClient
    Columns = <
      item
        Caption = 'Status / Diagn'#243'stico'
        Width = 180
      end
      item
        Caption = 'PLU Balan'#231'a'
        Width = 90
      end
      item
        Caption = 'C'#243'digo ERP'
        Width = 90
      end
      item
        Caption = 'Descri'#231#227'o do Produto'
        Width = 250
      end
      item
        Alignment = taRightJustify
        Caption = 'Pre'#231'o Anterior'
        Width = 100
      end
      item
        Alignment = taRightJustify
        Caption = 'Pre'#231'o Atual'
        Width = 100
      end
      item
        Alignment = taCenter
        Caption = 'Varia'#231#227'o'
        Width = 100
      end
      item
        Alignment = taCenter
        Caption = 'Validade'
        Width = 75
      end
      item
        Alignment = taCenter
        Caption = 'Setor'
        Width = 60
      end>
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ViewStyle = vsReport
    TabOrder = 3
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 560
    Width = 1000
    Height = 60
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 4
    object btnTransmitirAgora: TButton
      Left = 15
      Top = 12
      Width = 240
      Height = 36
      Caption = 'Transmitir Altera'#231#245'es Agora (F5)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnTransmitirAgoraClick
    end
    object btnExportarCSV: TButton
      Left = 270
      Top = 12
      Width = 200
      Height = 36
      Caption = 'Exportar Planilha (CSV / Excel)'
      TabOrder = 1
      OnClick = btnExportarCSVClick
    end
    object btnFechar: TButton
      Left = 880
      Top = 12
      Width = 105
      Height = 36
      Caption = 'Fechar (Esc)'
      TabOrder = 2
      OnClick = btnFecharClick
    end
  end
  object SaveDialogCSV: TSaveDialog
    DefaultExt = 'csv'
    Filter = 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*'
    Title = 'Exportar Relat'#243'rio de Altera'#231#245'es e Pre'#231'os'
    Left = 700
    Top = 8
  end
end
