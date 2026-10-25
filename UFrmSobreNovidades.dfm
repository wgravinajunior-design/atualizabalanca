object FrmSobreNovidades: TFrmSobreNovidades
  Left = 0
  Top = 0
  Caption = 'Sobre o Sistema e Atualiza'#231#245'es'
  ClientHeight = 560
  ClientWidth = 700
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
    Width = 700
    Height = 80
    Align = alTop
    BevelOuter = bvNone
    Color = 5384214
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 12
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
    object lblVersao: TLabel
      Left = 20
      Top = 38
      Width = 277
      Height = 15
      Caption = 'Vers'#227'o 2.5.0 Enterprise - Build Oficial (Outubro/2026)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblStatusUpdate: TLabel
      Left = 20
      Top = 56
      Width = 345
      Height = 13
      Caption = 'Comunica'#231#227'o Direta via Rede | Sockets TCP Nativos | Padr'#227'o RDC 429'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 14474460
      Font.Height = -11
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object grpNovidades: TGroupBox
    Left = 15
    Top = 90
    Width = 670
    Height = 410
    Caption = ' O que h'#225' de novo nesta vers'#227'o '
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -12
    Font.Name = 'Segoe UI'
    Font.Style = [fsBold]
    ParentFont = False
    TabOrder = 1
    object mmoNovidades: TMemo
      Left = 15
      Top = 25
      Width = 640
      Height = 370
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
  object pnlRodape: TPanel
    Left = 0
    Top = 505
    Width = 700
    Height = 55
    Align = alBottom
    BevelOuter = bvNone
    Color = 15921906
    ParentBackground = False
    TabOrder = 2
    object btnVerificarAtualizacao: TButton
      Left = 15
      Top = 10
      Width = 260
      Height = 35
      Caption = 'Verificar Atualiza'#231#245'es no GitHub'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      OnClick = btnVerificarAtualizacaoClick
    end
    object btnVerRepositorio: TButton
      Left = 285
      Top = 10
      Width = 190
      Height = 35
      Caption = 'Abrir Reposit'#243'rio GitHub'
      TabOrder = 1
      OnClick = btnVerRepositorioClick
    end
    object btnFechar: TButton
      Left = 590
      Top = 10
      Width = 95
      Height = 35
      Caption = 'Fechar'
      TabOrder = 2
      OnClick = btnFecharClick
    end
  end
end
