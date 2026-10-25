object FrmEditorEtiquetas: TFrmEditorEtiquetas
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMaximize]
  Caption = 'GoUp Sistemas - Editor de Etiquetas T'#233'rmicas para Balan'#231'as'
  ClientHeight = 680
  ClientWidth = 1040
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
    Width = 1040
    Height = 65
    Align = alTop
    BevelOuter = bvNone
    Color = 2758415
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 20
      Top = 10
      Width = 445
      Height = 21
      Caption = 'Editor de Etiquetas T'#233'rmicas Integrado com Balan'#231'as de Rede'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblSubtitulo: TLabel
      Left = 20
      Top = 35
      Width = 530
      Height = 15
      Caption = 'Edite visualmente o layout da etiqueta e sincronize diretamente na mem'#243'ria de qualquer balan'#231'a'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlEsquerda: TPanel
    Left = 0
    Top = 65
    Width = 520
    Height = 615
    Align = alLeft
    BevelOuter = bvNone
    TabOrder = 1
    object grpBalancaFormato: TGroupBox
      Left = 15
      Top = 10
      Width = 490
      Height = 110
      Caption = ' Balan'#231'a Alvo e Modelo de Etiqueta '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      object lblBalancaAlvo: TLabel
        Left = 15
        Top = 22
        Width = 71
        Height = 15
        Caption = 'Balan'#231'a Alvo:'
        Font.Style = []
      end
      object lblTamanhoEtiqueta: TLabel
        Left = 15
        Top = 62
        Width = 115
        Height = 15
        Caption = 'Formato / Dimens'#245'es:'
        Font.Style = []
      end
      object cbBalancaAlvo: TComboBox
        Left = 15
        Top = 38
        Width = 460
        Height = 23
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cbBalancaAlvoChange
      end
      object cbTamanhoEtiqueta: TComboBox
        Left = 15
        Top = 78
        Width = 460
        Height = 23
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnChange = cbTamanhoEtiquetaChange
      end
    end
    object grpTextos: TGroupBox
      Left = 15
      Top = 125
      Width = 490
      Height = 110
      Caption = ' Cabe'#231'alho e Rodap'#233' da Etiqueta '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      object lblNomeLoja: TLabel
        Left = 15
        Top = 22
        Width = 237
        Height = 15
        Caption = 'Nome do Estabelecimento / Loja (Cabe'#231'alho):'
        Font.Style = []
      end
      object lblRodape: TLabel
        Left = 15
        Top = 62
        Width = 220
        Height = 15
        Caption = 'Mensagem de Rodap'#233' / Conserva'#231#227'o:'
        Font.Style = []
      end
      object edtNomeLoja: TEdit
        Left = 15
        Top = 38
        Width = 460
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = edtNomeLojaChange
      end
      object edtRodape: TEdit
        Left = 15
        Top = 78
        Width = 460
        Height = 23
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnChange = edtRodapeChange
      end
    end
    object grpCampos: TGroupBox
      Left = 15
      Top = 240
      Width = 490
      Height = 200
      Caption = ' Elementos Impressos na Etiqueta '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 2
      object chkImprimirLoja: TCheckBox
        Left = 15
        Top = 24
        Width = 220
        Height = 17
        Caption = 'Imprimir Nome da Loja'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 0
        OnClick = chkElementoClick
      end
      object chkImprimirPLU: TCheckBox
        Left = 15
        Top = 48
        Width = 220
        Height = 17
        Caption = 'Imprimir C'#243'digo PLU'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 1
        OnClick = chkElementoClick
      end
      object chkImprimirDescricao: TCheckBox
        Left = 15
        Top = 72
        Width = 220
        Height = 17
        Caption = 'Imprimir Descri'#231#227'o do Produto'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 2
        OnClick = chkElementoClick
      end
      object chkImprimirDatas: TCheckBox
        Left = 15
        Top = 96
        Width = 220
        Height = 17
        Caption = 'Imprimir Data Embalagem / Validade'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 3
        OnClick = chkElementoClick
      end
      object chkImprimirHora: TCheckBox
        Left = 15
        Top = 120
        Width = 220
        Height = 17
        Caption = 'Imprimir Hora da Pesagem'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 4
        OnClick = chkElementoClick
      end
      object chkImprimirTara: TCheckBox
        Left = 15
        Top = 144
        Width = 220
        Height = 17
        Caption = 'Imprimir Peso da Tara'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 5
        OnClick = chkElementoClick
      end
      object chkImprimirPrecoKg: TCheckBox
        Left = 250
        Top = 24
        Width = 220
        Height = 17
        Caption = 'Imprimir Pre'#231'o Unit'#225'rio (R$/kg)'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 6
        OnClick = chkElementoClick
      end
      object chkImprimirPeso: TCheckBox
        Left = 250
        Top = 48
        Width = 220
        Height = 17
        Caption = 'Imprimir Peso L'#237'quido (kg)'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 7
        OnClick = chkElementoClick
      end
      object chkImprimirTotal: TCheckBox
        Left = 250
        Top = 72
        Width = 220
        Height = 17
        Caption = 'Imprimir Total a Pagar em Destaque'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 8
        OnClick = chkElementoClick
      end
      object chkImprimirBarras: TCheckBox
        Left = 250
        Top = 96
        Width = 220
        Height = 17
        Caption = 'Imprimir C'#243'digo de Barras EAN-13'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 9
        OnClick = chkElementoClick
      end
      object chkImprimirNutricional: TCheckBox
        Left = 250
        Top = 120
        Width = 220
        Height = 17
        Caption = 'Imprimir Tabela Nutricional RDC 429'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 10
        OnClick = chkElementoClick
      end
      object chkImprimirReceita: TCheckBox
        Left = 250
        Top = 144
        Width = 220
        Height = 17
        Caption = 'Imprimir Ingredientes e Alerg'#234'nicos'
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 11
        OnClick = chkElementoClick
      end
      object chkImprimirRodape: TCheckBox
        Left = 15
        Top = 168
        Width = 220
        Height = 17
        Caption = 'Imprimir Mensagem de Rodap'#233
        Checked = True
        Font.Style = []
        State = cbChecked
        TabOrder = 12
        OnClick = chkElementoClick
      end
    end
    object grpPadraoBarras: TGroupBox
      Left = 15
      Top = 445
      Width = 490
      Height = 70
      Caption = ' Padr'#227'o do C'#243'digo de Barras EAN-13 '
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 3
      object cbPadraoBarras: TComboBox
        Left = 15
        Top = 28
        Width = 460
        Height = 23
        Style = csDropDownList
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        OnChange = cbPadraoBarrasChange
      end
    end
    object pnlAcoesEsquerda: TPanel
      Left = 15
      Top = 525
      Width = 490
      Height = 80
      BevelOuter = bvNone
      TabOrder = 4
      object btnEnviarBalanca: TButton
        Left = 0
        Top = 5
        Width = 490
        Height = 36
        Caption = 'Gravar e Atualizar Layout na Balan'#231'a Agora'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Segoe UI'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 0
        OnClick = btnEnviarBalancaClick
      end
      object btnSalvarPadrao: TButton
        Left = 0
        Top = 46
        Width = 240
        Height = 30
        Caption = 'Salvar Como Padr'#227'o do Sistema'
        TabOrder = 1
        OnClick = btnSalvarPadraoClick
      end
      object btnFechar: TButton
        Left = 250
        Top = 46
        Width = 240
        Height = 30
        Caption = 'Fechar'
        TabOrder = 2
        OnClick = btnFecharClick
      end
    end
  end
  object pnlDireita: TPanel
    Left = 520
    Top = 65
    Width = 520
    Height = 615
    Align = alClient
    BevelOuter = bvNone
    Color = 15724527
    ParentBackground = False
    TabOrder = 2
    object lblPreviaTitulo: TLabel
      Left = 20
      Top = 15
      Width = 356
      Height = 15
      Caption = 'PR'#201'-VISUALIZA'#199#195'O EM TEMPO REAL DA ETIQUETA ADESIVA'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 4210752
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object sbPrevia: TScrollBox
      Left = 15
      Top = 40
      Width = 490
      Height = 560
      BevelInner = bvNone
      BevelOuter = bvNone
      BorderStyle = bsNone
      Color = 15724527
      ParentColor = False
      TabOrder = 0
      object pnlEtiquetaFisica: TPanel
        Left = 20
        Top = 10
        Width = 440
        Height = 530
        BevelOuter = bvNone
        Color = clWhite
        ParentBackground = False
        TabOrder = 0
        object lblPreviaLoja: TLabel
          Left = 15
          Top = 12
          Width = 410
          Height = 19
          Alignment = taCenter
          AutoSize = False
          Caption = 'SUPERMERCADO BOM PRE'#199'O LTDA'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -13
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblPreviaProduto: TLabel
          Left = 15
          Top = 35
          Width = 410
          Height = 22
          Alignment = taCenter
          AutoSize = False
          Caption = 'PICANHA BOVINA RESFRIADA KG'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblPreviaPLU: TLabel
          Left = 15
          Top = 60
          Width = 410
          Height = 15
          Alignment = taCenter
          AutoSize = False
          Caption = 'C'#211'DIGO PLU: 101'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblPreviaDatas: TLabel
          Left = 15
          Top = 80
          Width = 410
          Height = 15
          Alignment = taCenter
          AutoSize = False
          Caption = 'EMB: 25/10/2026   VAL: 30/10/2026 16:45   TARA: 0.020 kg'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clBlack
          Font.Height = -11
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object pnlPreviaValores: TPanel
          Left = 15
          Top = 105
          Width = 410
          Height = 65
          BevelInner = bvNone
          Color = 16382457
          ParentBackground = False
          TabOrder = 0
          object lblPreviaPrecoUnit: TLabel
            Left = 10
            Top = 10
            Width = 125
            Height = 17
            Caption = 'PRE'#199'O / kg: R$ 69,90'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaPesoLiq: TLabel
            Left = 10
            Top = 35
            Width = 118
            Height = 17
            Caption = 'PESO L'#205'Q.: 1,250 kg'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaTotalTit: TLabel
            Left = 180
            Top = 6
            Width = 220
            Height = 15
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'TOTAL A PAGAR (R$)'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaTotalVal: TLabel
            Left = 180
            Top = 22
            Width = 220
            Height = 35
            Alignment = taRightJustify
            AutoSize = False
            Caption = 'R$ 87,38'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -24
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object pnlPreviaBarras: TPanel
          Left = 15
          Top = 180
          Width = 410
          Height = 65
          BevelOuter = bvNone
          Color = clWhite
          ParentBackground = False
          TabOrder = 1
          object lblPreviaBarrasDesenho: TLabel
            Left = 0
            Top = 5
            Width = 410
            Height = 35
            Alignment = taCenter
            AutoSize = False
            Caption = '||| | || |||| | ||||| ||| || | |||| | ||||| || |||'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -26
            Font.Name = 'Consolas'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaBarrasNumero: TLabel
            Left = 0
            Top = 42
            Width = 410
            Height = 18
            Alignment = taCenter
            AutoSize = False
            Caption = '2  001010  087385'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -13
            Font.Name = 'Consolas'
            Font.Style = [fsBold]
            ParentFont = False
          end
        end
        object pnlPreviaNutricional: TPanel
          Left = 15
          Top = 255
          Width = 410
          Height = 135
          BevelOuter = bvNone
          Color = 16579836
          ParentBackground = False
          TabOrder = 2
          object lblPreviaNutriTit: TLabel
            Left = 10
            Top = 5
            Width = 390
            Height = 15
            AutoSize = False
            Caption = 'INFORMA'#199#195'O NUTRICIONAL (RDC 429 Anvisa) Por'#231#227'o 50g'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -10
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaNutriLupas: TLabel
            Left = 10
            Top = 22
            Width = 390
            Height = 18
            AutoSize = False
            Caption = '[ALTO EM GORDURA SATURADA]  [ALTO EM S'#211'DIO]'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clMaroon
            Font.Height = -10
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblPreviaNutriLinhas: TLabel
            Left = 10
            Top = 42
            Width = 390
            Height = 85
            AutoSize = False
            Caption = 'Valor Energ'#233'tico: 180 kcal (9% VD) | Carboidratos: 0g (0% VD)'#13#10'A'#231#250'cares: 0g (0% VD) | Prote'#237'nas: 18g (36% VD)'#13#10'Gorduras Totais: 12g (18% VD) | Gorduras Saturadas: 5g (25% VD)'#13#10'S'#243'dio: 350mg (18% VD) | Gorduras Trans: 0g'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 2105376
            Font.Height = -10
            Font.Name = 'Consolas'
            Font.Style = []
            ParentFont = False
          end
        end
        object lblPreviaIngredientes: TLabel
          Left = 15
          Top = 400
          Width = 410
          Height = 45
          AutoSize = False
          Caption = 'Ingredientes: Carne bovina resfriada in natura. AL'#201'RGICOS: N'#195'O CONT'#201'M GL'#218'TEN.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 3289650
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
          WordWrap = True
        end
        object lblPreviaRodape: TLabel
          Left = 15
          Top = 455
          Width = 410
          Height = 35
          Alignment = taCenter
          AutoSize = False
          Caption = 'Conserve em local refrigerado de 0'#176'C a 4'#176'C. Obrigado pela prefer'#234'ncia!'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -10
          Font.Name = 'Segoe UI'
          Font.Style = [fsItalic]
          ParentFont = False
          WordWrap = True
        end
      end
    end
  end
end
