object FrmSobreNovidades: TFrmSobreNovidades
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'GoUp Sistemas - Novidades da Build e Atualiza'#231#245'es'
  ClientHeight = 620
  ClientWidth = 760
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
    Width = 760
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = 2758415
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 15
      Width = 354
      Height = 21
      Caption = 'GoUp Sistemas - Atualizador de dados Balan'#231'a'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 20
      Top = 40
      Width = 368
      Height = 15
      Caption = 'Central de Novidades da Build e Atualiza'#231#227'o Autom'#225'tica'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
    object pnlBadgeVersao: TPanel
      Left = 600
      Top = 15
      Width = 140
      Height = 48
      BevelOuter = bvNone
      Color = 3815994
      ParentBackground = False
      TabOrder = 0
      object lblVersaoTit: TLabel
        Left = 0
        Top = 6
        Width = 140
        Height = 13
        Align = alTop
        Alignment = taCenter
        Caption = 'BUILD INSTALADA'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clSilver
        Font.Height = -10
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
      object lblVersaoVal: TLabel
        Left = 0
        Top = 21
        Width = 140
        Height = 21
        Align = alBottom
        Alignment = taCenter
        Caption = 'v1.0.2'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 6210850
        Font.Height = -16
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
      end
    end
  end
  object pnlCardUpdate: TPanel
    Left = 15
    Top = 90
    Width = 730
    Height = 70
    BevelOuter = bvNone
    Color = clWhite
    ParentBackground = False
    TabOrder = 1
    object lblUpdateStatusTit: TLabel
      Left = 15
      Top = 12
      Width = 138
      Height = 13
      Caption = 'STATUS DA ATUALIZA'#199#195'O'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -10
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblUpdateStatusMsg: TLabel
      Left = 15
      Top = 32
      Width = 430
      Height = 15
      Caption = 'Sistema rodando na vers'#227'o 1.0.2. Clique para checar novas atualiza'#231#245'es.'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 2105376
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object btnVerificarAtualizacao: TButton
      Left = 455
      Top = 18
      Width = 125
      Height = 34
      Caption = 'Verificar Vers'#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnVerificarAtualizacaoClick
    end
    object btnBaixarAtualizacao: TButton
      Left = 590
      Top = 18
      Width = 125
      Height = 34
      Caption = 'Baixar Nova Vers'#227'o'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGreen
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      Visible = False
      OnClick = btnBaixarAtualizacaoClick
    end
  end
  object pcNovidades: TPageControl
    Left = 15
    Top = 170
    Width = 730
    Height = 385
    ActivePage = tsResumoVisual
    TabOrder = 2
    object tsResumoVisual: TTabSheet
      Caption = ' O Que Foi Feito Nesta Build '
      object lvNovidades: TListView
        Left = 0
        Top = 0
        Width = 722
        Height = 355
        Align = alClient
        Columns = <
          item
            Caption = 'Recurso / M'#243'dulo Implementado'
            Width = 260
          end
          item
            Caption = 'Categoria'
            Width = 110
          end
          item
            Caption = 'Impacto e Benef'#237'cio Direto no Operador / Loja'
            Width = 330
          end>
        GridLines = True
        ReadOnly = True
        RowSelect = True
        ViewStyle = vsReport
      end
    end
    object tsNotasDetalhadas: TTabSheet
      Caption = ' Notas T'#233'cnicas Completas '
      ImageIndex = 1
      object mmoNovidades: TMemo
        Left = 0
        Top = 0
        Width = 722
        Height = 355
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 2105376
        Font.Height = -12
        Font.Name = 'Consolas'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object pnlRodape: TPanel
    Left = 0
    Top = 565
    Width = 760
    Height = 55
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 3
    object btnFechar: TButton
      Left = 645
      Top = 10
      Width = 100
      Height = 35
      Caption = 'Fechar'
      TabOrder = 0
      OnClick = btnFecharClick
    end
  end
end
