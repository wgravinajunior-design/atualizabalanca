object FrmCadastroProdutos: TFrmCadastroProdutos
  Left = 0
  Top = 0
  Caption = 'GoUp Sistemas - Cadastro de Produtos e Departamentos (RDC 429)'
  ClientHeight = 670
  ClientWidth = 1060
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
    Width = 1060
    Height = 60
    Align = alTop
    BevelOuter = bvNone
    Color = 2758415
    ParentBackground = False
    TabOrder = 0
    object lblTitulo: TLabel
      Left = 16
      Top = 8
      Width = 478
      Height = 21
      Caption = 'Cadastro de Produtos, Departamentos e Tabela Nutricional'
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
      Width = 590
      Height = 15
      Caption = 'Gerencie PLUs, departamentos, pre'#231'os, validade, nutrientes RDC 429 e transmita direto para as balan'#231'as'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGainsboro
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
    end
  end
  object pnlAcoes: TPanel
    Left = 0
    Top = 60
    Width = 1060
    Height = 44
    Align = alTop
    BevelOuter = bvNone
    Color = 16185078
    ParentBackground = False
    TabOrder = 1
    object btnNovo: TButton
      Left = 8
      Top = 6
      Width = 90
      Height = 32
      Caption = 'Novo (F2)'
      TabOrder = 0
      OnClick = btnNovoClick
    end
    object btnSalvar: TButton
      Left = 104
      Top = 6
      Width = 110
      Height = 32
      Caption = 'Salvar (Ctrl+S)'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 1
      OnClick = btnSalvarClick
    end
    object btnExcluir: TButton
      Left = 220
      Top = 6
      Width = 90
      Height = 32
      Caption = 'Excluir (Del)'
      TabOrder = 2
      OnClick = btnExcluirClick
    end
    object btnTransmitir: TButton
      Left = 316
      Top = 6
      Width = 170
      Height = 32
      Caption = 'Transmitir Balan'#231'a (F5)'
      TabOrder = 3
      OnClick = btnTransmitirClick
    end
    object btnCargaUSB: TButton
      Left = 492
      Top = 6
      Width = 145
      Height = 32
      Caption = 'Exportar USB (F6)'
      TabOrder = 4
      OnClick = btnCargaUSBClick
    end
    object btnRecarregar: TButton
      Left = 643
      Top = 6
      Width = 110
      Height = 32
      Caption = 'Recarregar (F8)'
      TabOrder = 5
      OnClick = btnRecarregarClick
    end
    object btnFechar: TButton
      Left = 955
      Top = 6
      Width = 95
      Height = 32
      Anchors = [akTop, akRight]
      Caption = 'Fechar (Esc)'
      TabOrder = 6
      OnClick = btnFecharClick
    end
  end
  object pnlPrincipal: TPanel
    Left = 0
    Top = 104
    Width = 1060
    Height = 566
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object pnlEsquerdo: TPanel
      Left = 0
      Top = 0
      Width = 380
      Height = 566
      Align = alLeft
      BevelOuter = bvNone
      TabOrder = 0
      object pnlFiltros: TPanel
        Left = 0
        Top = 0
        Width = 380
        Height = 110
        Align = alTop
        BevelOuter = bvNone
        Color = 15724527
        ParentBackground = False
        TabOrder = 0
        object lblBusca: TLabel
          Left = 10
          Top = 8
          Width = 127
          Height = 15
          Caption = 'Buscar PLU ou Descri'#231#227'o:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblFiltroDepto: TLabel
          Left = 10
          Top = 56
          Width = 79
          Height = 15
          Caption = 'Departamento:'
        end
        object edtBusca: TEdit
          Left = 10
          Top = 27
          Width = 360
          Height = 23
          TabOrder = 0
          OnChange = edtBuscaChange
        end
        object cboFiltroDepto: TComboBox
          Left = 10
          Top = 75
          Width = 200
          Height = 23
          Style = csDropDownList
          TabOrder = 1
          OnChange = cboFiltroDeptoChange
        end
        object chkApenasPLU: TCheckBox
          Left = 220
          Top = 77
          Width = 150
          Height = 19
          Caption = 'Apenas c/ PLU v'#225'lido'
          Checked = True
          State = cbChecked
          TabOrder = 2
          OnClick = chkApenasPLUClick
        end
      end
      object lvProdutos: TListView
        Left = 0
        Top = 110
        Width = 380
        Height = 428
        Align = alClient
        Columns = <
          item
            Caption = 'PLU'
            Width = 55
          end
          item
            Caption = 'Descri'#231#227'o'
            Width = 175
          end
          item
            Alignment = taRightJustify
            Caption = 'Pre'#231'o R$'
            Width = 75
          end
          item
            Alignment = taCenter
            Caption = 'Val.'
            Width = 45
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 1
        ViewStyle = vsReport
        OnSelectItem = lvProdutosSelectItem
      end
      object pnlTotalizadores: TPanel
        Left = 0
        Top = 538
        Width = 380
        Height = 28
        Align = alBottom
        BevelOuter = bvNone
        Color = 15132390
        ParentBackground = False
        TabOrder = 2
        object lblTotalItens: TLabel
          Left = 10
          Top = 6
          Width = 120
          Height = 15
          Caption = '0 produtos localizados'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGrayText
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = [fsItalic]
          ParentFont = False
        end
      end
    end
    object splVertical: TSplitter
      Left = 380
      Top = 0
      Width = 5
      Height = 566
      Color = clBtnFace
      ParentColor = False
    end
    object pnlDireito: TPanel
      Left = 385
      Top = 0
      Width = 675
      Height = 566
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 1
      object pgcProduto: TPageControl
        Left = 0
        Top = 0
        Width = 675
        Height = 566
        ActivePage = tabGeral
        Align = alClient
        TabOrder = 0
        object tabGeral: TTabSheet
          Caption = '1. Dados Gerais & Balan'#231'a'
          object lblPLU: TLabel
            Left = 16
            Top = 16
            Width = 99
            Height = 15
            Caption = 'C'#243'digo PLU Balan'#231'a:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblBarras: TLabel
            Left = 180
            Top = 16
            Width = 111
            Height = 15
            Caption = 'C'#243'digo Barras / EAN:'
          end
          object lblDescricao: TLabel
            Left = 16
            Top = 72
            Width = 107
            Height = 15
            Caption = 'Descri'#231#227'o Completa:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblDescricaoCurta: TLabel
            Left = 16
            Top = 128
            Width = 241
            Height = 15
            Caption = 'Descri'#231#227'o Reduzida Balan'#231'a (At'#233' 25 caracteres):'
          end
          object lblDepto: TLabel
            Left = 16
            Top = 184
            Width = 127
            Height = 15
            Caption = 'Departamento / Setor:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblTipoVenda: TLabel
            Left = 300
            Top = 184
            Width = 79
            Height = 15
            Caption = 'Tipo de Venda:'
          end
          object lblTecla: TLabel
            Left = 470
            Top = 184
            Width = 103
            Height = 15
            Caption = 'Tecla Acesso (1-99):'
          end
          object edtPLU: TEdit
            Left = 16
            Top = 35
            Width = 140
            Height = 25
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
          end
          object edtBarras: TEdit
            Left = 180
            Top = 35
            Width = 200
            Height = 23
            TabOrder = 1
          end
          object edtDescricao: TEdit
            Left = 16
            Top = 91
            Width = 560
            Height = 25
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -13
            Font.Name = 'Segoe UI'
            Font.Style = []
            ParentFont = False
            TabOrder = 2
          end
          object edtDescricaoCurta: TEdit
            Left = 16
            Top = 147
            Width = 350
            Height = 23
            MaxLength = 25
            TabOrder = 3
          end
          object cboDepto: TComboBox
            Left = 16
            Top = 203
            Width = 260
            Height = 23
            Style = csDropDownList
            TabOrder = 4
          end
          object cboTipoVenda: TComboBox
            Left = 300
            Top = 203
            Width = 150
            Height = 23
            Style = csDropDownList
            ItemIndex = 0
            TabOrder = 5
            Text = 'Por Peso (kg)'
            Items.Strings = (
              'Por Peso (kg)'
              'Por Unidade (un)')
          end
          object edtTecla: TEdit
            Left = 470
            Top = 203
            Width = 100
            Height = 23
            TabOrder = 6
            Text = '0'
          end
          object chkAtivo: TCheckBox
            Left = 16
            Top = 250
            Width = 240
            Height = 19
            Caption = 'Produto Ativo para Envio '#224' Balan'#231'a'
            Checked = True
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            State = cbChecked
            TabOrder = 7
          end
        end
        object tabPreco: TTabSheet
          Caption = '2. Pre'#231'o & Conserva'#231#227'o'
          ImageIndex = 1
          object lblPreco: TLabel
            Left = 20
            Top = 20
            Width = 111
            Height = 15
            Caption = 'Pre'#231'o de Venda (R$):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblValidade: TLabel
            Left = 220
            Top = 20
            Width = 83
            Height = 15
            Caption = 'Validade (dias):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblConservacao: TLabel
            Left = 20
            Top = 85
            Width = 149
            Height = 15
            Caption = 'Instru'#231#245'es de Conserva'#231#227'o:'
          end
          object lblUltimaAlteracao: TLabel
            Left = 20
            Top = 155
            Width = 145
            Height = 15
            Caption = #218'ltima Altera'#231#227'o no ERP:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGrayText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblDataAlteracao: TLabel
            Left = 180
            Top = 155
            Width = 5
            Height = 15
            Caption = '-'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clHighlight
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtPreco: TEdit
            Left = 20
            Top = 40
            Width = 160
            Height = 28
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 0
            Text = '0,00'
          end
          object edtValidade: TEdit
            Left = 220
            Top = 40
            Width = 120
            Height = 28
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -15
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
            TabOrder = 1
            Text = '0'
          end
          object edtConservacao: TEdit
            Left = 20
            Top = 105
            Width = 500
            Height = 23
            TabOrder = 2
            Text = 'Manter sob refrigera'#231#227'o'
          end
        end
        object tabNutricional: TTabSheet
          Caption = '3. Tabela Nutricional (RDC 429)'
          ImageIndex = 2
          object lblPorcaoQtde: TLabel
            Left = 16
            Top = 12
            Width = 98
            Height = 15
            Caption = 'Por'#231#227'o (g ou ml):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblValorEnerg: TLabel
            Left = 150
            Top = 12
            Width = 104
            Height = 15
            Caption = 'Valor Energ. (kcal):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblCarbo: TLabel
            Left = 280
            Top = 12
            Width = 89
            Height = 15
            Caption = 'Carboidratos (g):'
          end
          object lblAcucarTot: TLabel
            Left = 410
            Top = 12
            Width = 104
            Height = 15
            Caption = 'A'#231#250'cares Totais (g):'
          end
          object lblAcucarAdic: TLabel
            Left = 16
            Top = 64
            Width = 124
            Height = 15
            Caption = 'A'#231#250'c. Adicionados (g):'
          end
          object lblProteina: TLabel
            Left = 150
            Top = 64
            Width = 71
            Height = 15
            Caption = 'Prote'#237'nas (g):'
          end
          object lblGordTot: TLabel
            Left = 280
            Top = 64
            Width = 100
            Height = 15
            Caption = 'Gorduras Totais (g):'
          end
          object lblGordSat: TLabel
            Left = 410
            Top = 64
            Width = 120
            Height = 15
            Caption = 'Gorduras Saturadas (g):'
          end
          object lblGordTrans: TLabel
            Left = 16
            Top = 116
            Width = 99
            Height = 15
            Caption = 'Gorduras Trans (g):'
          end
          object lblFibra: TLabel
            Left = 150
            Top = 116
            Width = 104
            Height = 15
            Caption = 'Fibra Alimentar (g):'
          end
          object lblSodio: TLabel
            Left = 280
            Top = 116
            Width = 62
            Height = 15
            Caption = 'S'#243'dio (mg):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object edtPorcaoQtde: TEdit
            Left = 16
            Top = 32
            Width = 110
            Height = 23
            TabOrder = 0
            Text = '100'
            OnChange = CalcularLupasNutricionais
          end
          object edtValorEnerg: TEdit
            Left = 150
            Top = 32
            Width = 110
            Height = 23
            TabOrder = 1
            Text = '0'
          end
          object edtCarbo: TEdit
            Left = 280
            Top = 32
            Width = 110
            Height = 23
            TabOrder = 2
            Text = '0,0'
          end
          object edtAcucarTot: TEdit
            Left = 410
            Top = 32
            Width = 110
            Height = 23
            TabOrder = 3
            Text = '0,0'
          end
          object edtAcucarAdic: TEdit
            Left = 16
            Top = 84
            Width = 110
            Height = 23
            TabOrder = 4
            Text = '0,0'
            OnChange = CalcularLupasNutricionais
          end
          object edtProteina: TEdit
            Left = 150
            Top = 84
            Width = 110
            Height = 23
            TabOrder = 5
            Text = '0,0'
          end
          object edtGordTot: TEdit
            Left = 280
            Top = 84
            Width = 110
            Height = 23
            TabOrder = 6
            Text = '0,0'
          end
          object edtGordSat: TEdit
            Left = 410
            Top = 84
            Width = 110
            Height = 23
            TabOrder = 7
            Text = '0,0'
            OnChange = CalcularLupasNutricionais
          end
          object edtGordTrans: TEdit
            Left = 16
            Top = 136
            Width = 110
            Height = 23
            TabOrder = 8
            Text = '0,0'
          end
          object edtFibra: TEdit
            Left = 150
            Top = 136
            Width = 110
            Height = 23
            TabOrder = 9
            Text = '0,0'
          end
          object edtSodio: TEdit
            Left = 280
            Top = 136
            Width = 110
            Height = 23
            TabOrder = 10
            Text = '0,0'
            OnChange = CalcularLupasNutricionais
          end
          object pnlLupas: TPanel
            Left = 16
            Top = 180
            Width = 530
            Height = 120
            BevelOuter = bvNone
            Color = 15724527
            ParentBackground = False
            TabOrder = 11
            object lblTituloLupas: TLabel
              Left = 12
              Top = 8
              Width = 350
              Height = 15
              Caption = 'Rotulagem Nutricional Frontal Obrigat'#243'ria (Lupas RDC 429 Anvisa):'
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clWindowText
              Font.Height = -12
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
            end
            object chkLupaAcucar: TCheckBox
              Left = 16
              Top = 32
              Width = 300
              Height = 20
              Caption = 'ALTO EM A'#199#218'CAR ADICIONADO (> 15g/100g)'
              Enabled = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 0
            end
            object chkLupaGordSat: TCheckBox
              Left = 16
              Top = 58
              Width = 300
              Height = 20
              Caption = 'ALTO EM GORDURA SATURADA (> 6g/100g)'
              Enabled = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 1
            end
            object chkLupaSodio: TCheckBox
              Left = 16
              Top = 84
              Width = 300
              Height = 20
              Caption = 'ALTO EM S'#211'DIO (> 600mg/100g)'
              Enabled = False
              Font.Charset = DEFAULT_CHARSET
              Font.Color = clRed
              Font.Height = -11
              Font.Name = 'Segoe UI'
              Font.Style = [fsBold]
              ParentFont = False
              TabOrder = 2
            end
          end
        end
        object tabIngredientes: TTabSheet
          Caption = '4. Ingredientes & Alerg'#234'nicos'
          ImageIndex = 3
          object lblReceita: TLabel
            Left = 16
            Top = 12
            Width = 277
            Height = 15
            Caption = 'Ingredientes e Receita (Etiqueta T'#233'rmica Estendida):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblAlergicos: TLabel
            Left = 16
            Top = 180
            Width = 345
            Height = 15
            Caption = 'Declara'#231#227'o de Alerg'#234'nicos Obrigat'#243'ria (RDC 727/2022 Anvisa):'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Segoe UI'
            Font.Style = [fsBold]
            ParentFont = False
          end
          object lblAvisoAlergico: TLabel
            Left = 16
            Top = 310
            Width = 473
            Height = 15
            Caption = 'Exemplo: AL'#201'RGICOS: CONT'#201'M DERIVADOS DE TRIGO E LEITE. CONT'#201'M GL'#218'TEN.'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGrayText
            Font.Height = -11
            Font.Name = 'Segoe UI'
            Font.Style = [fsItalic]
            ParentFont = False
          end
          object memReceita: TMemo
            Left = 16
            Top = 32
            Width = 580
            Height = 135
            ScrollBars = ssVertical
            TabOrder = 0
          end
          object memAlergicos: TMemo
            Left = 16
            Top = 200
            Width = 580
            Height = 100
            ScrollBars = ssVertical
            TabOrder = 1
          end
        end
      end
    end
  end
end
