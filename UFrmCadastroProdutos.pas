unit UFrmCadastroProdutos;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UFrmCadastroProdutos.pas: Gestão de Produtos, Departamentos e RDC 429       }
{  Permite cadastrar, atualizar preços, validades e enviar direto para balanças}
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.Generics.Collections,
  System.UITypes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Vcl.FileCtrl,
  UModelBalanca,
  URepositoryBalanca,
  UComunicadorBalanca,
  UDMConexao;

type
  TFrmCadastroProdutos = class(TForm)
    pnlHeader: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlAcoes: TPanel;
    btnNovo: TButton;
    btnSalvar: TButton;
    btnExcluir: TButton;
    btnTransmitir: TButton;
    btnCargaUSB: TButton;
    btnRecarregar: TButton;
    btnFechar: TButton;
    pnlPrincipal: TPanel;
    pnlEsquerdo: TPanel;
    pnlFiltros: TPanel;
    lblBusca: TLabel;
    lblFiltroDepto: TLabel;
    edtBusca: TEdit;
    cboFiltroDepto: TComboBox;
    chkApenasPLU: TCheckBox;
    lvProdutos: TListView;
    pnlTotalizadores: TPanel;
    lblTotalItens: TLabel;
    splVertical: TSplitter;
    pnlDireito: TPanel;
    pgcProduto: TPageControl;
    tabGeral: TTabSheet;
    tabPreco: TTabSheet;
    tabNutricional: TTabSheet;
    tabIngredientes: TTabSheet;
    lblPLU: TLabel;
    lblBarras: TLabel;
    lblDescricao: TLabel;
    lblDescricaoCurta: TLabel;
    lblDepto: TLabel;
    lblTipoVenda: TLabel;
    lblTecla: TLabel;
    edtPLU: TEdit;
    edtBarras: TEdit;
    edtDescricao: TEdit;
    edtDescricaoCurta: TEdit;
    cboDepto: TComboBox;
    cboTipoVenda: TComboBox;
    edtTecla: TEdit;
    chkAtivo: TCheckBox;
    lblPreco: TLabel;
    lblValidade: TLabel;
    lblConservacao: TLabel;
    lblUltimaAlteracao: TLabel;
    lblDataAlteracao: TLabel;
    edtPreco: TEdit;
    edtValidade: TEdit;
    edtConservacao: TEdit;
    lblPorcaoQtde: TLabel;
    lblValorEnerg: TLabel;
    lblCarbo: TLabel;
    lblAcucarTot: TLabel;
    lblAcucarAdic: TLabel;
    lblProteina: TLabel;
    lblGordTot: TLabel;
    lblGordSat: TLabel;
    lblGordTrans: TLabel;
    lblFibra: TLabel;
    lblSodio: TLabel;
    edtPorcaoQtde: TEdit;
    edtValorEnerg: TEdit;
    edtCarbo: TEdit;
    edtAcucarTot: TEdit;
    edtAcucarAdic: TEdit;
    edtProteina: TEdit;
    edtGordTot: TEdit;
    edtGordSat: TEdit;
    edtGordTrans: TEdit;
    edtFibra: TEdit;
    edtSodio: TEdit;
    pnlLupas: TPanel;
    lblTituloLupas: TLabel;
    chkLupaAcucar: TCheckBox;
    chkLupaGordSat: TCheckBox;
    chkLupaSodio: TCheckBox;
    lblReceita: TLabel;
    lblAlergicos: TLabel;
    lblAvisoAlergico: TLabel;
    memReceita: TMemo;
    memAlergicos: TMemo;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edtBuscaChange(Sender: TObject);
    procedure cboFiltroDeptoChange(Sender: TObject);
    procedure chkApenasPLUClick(Sender: TObject);
    procedure lvProdutosSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure btnNovoClick(Sender: TObject);
    procedure btnSalvarClick(Sender: TObject);
    procedure btnExcluirClick(Sender: TObject);
    procedure btnTransmitirClick(Sender: TObject);
    procedure btnCargaUSBClick(Sender: TObject);
    procedure btnRecarregarClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
    procedure CalcularLupasNutricionais(Sender: TObject);
  private
    FListaProdutos: TObjectList<TProdutoPLU>;
    FListaDepartamentos: TObjectList<TDepartamento>;
    FProdutoSelecionado: TProdutoPLU;
    FCarregandoDados: Boolean;

    procedure CarregarDepartamentos;
    procedure CarregarListaProdutos;
    procedure FiltrarListaGrid;
    procedure ExibirProdutoNosCampos(AProd: TProdutoPLU);
    procedure LimparCamposEdicao;
    function ObterIdDepartamentoSelecionado: Integer;
    procedure DefinirDepartamentoNoCombo(const AID: Integer);
    function StrToDoubleDefSafe(const AStr: string; const ADef: Double): Double;
    function StrToCurrDefSafe(const AStr: string; const ADef: Currency): Currency;
  public
  end;

var
  FrmCadastroProdutos: TFrmCadastroProdutos;

implementation

{$R *.dfm}

{ TFrmCadastroProdutos }

procedure TFrmCadastroProdutos.FormCreate(Sender: TObject);
begin
  FCarregandoDados := False;
  FProdutoSelecionado := nil;
  FListaProdutos := TObjectList<TProdutoPLU>.Create(True);
  FListaDepartamentos := TObjectList<TDepartamento>.Create(True);
end;

procedure TFrmCadastroProdutos.FormDestroy(Sender: TObject);
begin
  FListaProdutos.Free;
  FListaDepartamentos.Free;
end;

procedure TFrmCadastroProdutos.FormShow(Sender: TObject);
begin
  CarregarDepartamentos;
  CarregarListaProdutos;
  if lvProdutos.Items.Count > 0 then
  begin
    lvProdutos.Items[0].Selected := True;
    lvProdutos.Items[0].Focused := True;
  end
  else
    LimparCamposEdicao;
end;

procedure TFrmCadastroProdutos.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;
        Close;
      end;
    VK_F2:
      begin
        Key := 0;
        btnNovoClick(Sender);
      end;
    VK_F5:
      begin
        Key := 0;
        btnTransmitirClick(Sender);
      end;
    VK_F6:
      begin
        Key := 0;
        btnCargaUSBClick(Sender);
      end;
    VK_F8:
      begin
        Key := 0;
        btnRecarregarClick(Sender);
      end;
    VK_DELETE:
      begin
        if ActiveControl = lvProdutos then
        begin
          Key := 0;
          btnExcluirClick(Sender);
        end;
      end;
    Ord('S'):
      begin
        if ssCtrl in Shift then
        begin
          Key := 0;
          btnSalvarClick(Sender);
        end;
      end;
  end;
end;

procedure TFrmCadastroProdutos.CarregarDepartamentos;
var
  Repo: TRepositoryBalanca;
  I: Integer;
  Depto: TDepartamento;
begin
  cboFiltroDepto.Items.Clear;
  cboDepto.Items.Clear;

  cboFiltroDepto.Items.Add('Todos os Setores (ERP)');

  Repo := TRepositoryBalanca.Create(nil);
  try
    Repo.ObterDepartamentos(FListaDepartamentos);
    for I := 0 to FListaDepartamentos.Count - 1 do
    begin
      Depto := FListaDepartamentos[I];
      cboFiltroDepto.Items.AddObject(Format('%d - %s', [Depto.Codigo, Depto.Nome]), TObject(IntPtr(Depto.Codigo)));
      cboDepto.Items.AddObject(Format('%d - %s', [Depto.Codigo, Depto.Nome]), TObject(IntPtr(Depto.Codigo)));
    end;
  finally
    Repo.Free;
  end;

  cboFiltroDepto.ItemIndex := 0;
  if cboDepto.Items.Count > 0 then
    cboDepto.ItemIndex := 0;
end;

procedure TFrmCadastroProdutos.CarregarListaProdutos;
var
  Repo: TRepositoryBalanca;
begin
  FCarregandoDados := True;
  try
    Repo := TRepositoryBalanca.Create(nil);
    try
      Repo.ObterTodosProdutosBalanca(FListaProdutos, 0);
    finally
      Repo.Free;
    end;
    FiltrarListaGrid;
  finally
    FCarregandoDados := False;
  end;
end;

procedure TFrmCadastroProdutos.FiltrarListaGrid;
var
  I: Integer;
  Prod: TProdutoPLU;
  TextoFiltro: string;
  SetorFiltro: Integer;
  Item: TListItem;
  MatchTexto: Boolean;
  MatchSetor: Boolean;
  MatchPLU: Boolean;
  TotalVisiveis: Integer;
  SetorDescricao: string;
begin
  lvProdutos.Items.BeginUpdate;
  try
    lvProdutos.Items.Clear;
    TextoFiltro := AnsiUpperCase(Trim(edtBusca.Text));

    if cboFiltroDepto.ItemIndex > 0 then
      SetorFiltro := Integer(IntPtr(cboFiltroDepto.Items.Objects[cboFiltroDepto.ItemIndex]))
    else
      SetorFiltro := 0;

    TotalVisiveis := 0;

    for I := 0 to FListaProdutos.Count - 1 do
    begin
      Prod := FListaProdutos[I];

      MatchTexto := (TextoFiltro = '') or
                    (Pos(TextoFiltro, AnsiUpperCase(Prod.Descricao)) > 0) or
                    (Pos(TextoFiltro, IntToStr(Prod.CodigoPLU)) > 0) or
                    (Pos(TextoFiltro, Prod.CodigoBarras) > 0);

      MatchSetor := (SetorFiltro = 0) or (Prod.Setor = SetorFiltro);

      if chkApenasPLU.Checked then
        MatchPLU := (Prod.CodigoPLU > 0)
      else
        MatchPLU := True;

      if MatchTexto and MatchSetor and MatchPLU then
      begin
        Item := lvProdutos.Items.Add;
        Item.Caption := IntToStr(Prod.CodigoPLU);
        Item.SubItems.Add(Prod.Descricao);

        if Trim(Prod.NomeSetor) <> '' then
          SetorDescricao := Prod.NomeSetor
        else if Prod.Setor > 0 then
          SetorDescricao := Format('Setor %d', [Prod.Setor])
        else
          SetorDescricao := '-';

        Item.SubItems.Add(SetorDescricao);
        Item.SubItems.Add(FormatFloat('R$ #,##0.00', Prod.PrecoVenda));
        Item.SubItems.Add(IntToStr(Prod.ValidadeDias) + ' d');
        Item.Data := Prod;
        Inc(TotalVisiveis);
      end;
    end;

    lblTotalItens.Caption := Format('%d produtos localizados (%d no total)', [TotalVisiveis, FListaProdutos.Count]);
  finally
    lvProdutos.Items.EndUpdate;
  end;
end;

procedure TFrmCadastroProdutos.edtBuscaChange(Sender: TObject);
begin
  FiltrarListaGrid;
end;

procedure TFrmCadastroProdutos.cboFiltroDeptoChange(Sender: TObject);
begin
  FiltrarListaGrid;
end;

procedure TFrmCadastroProdutos.chkApenasPLUClick(Sender: TObject);
begin
  FiltrarListaGrid;
end;

procedure TFrmCadastroProdutos.lvProdutosSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected and Assigned(Item) and Assigned(Item.Data) then
  begin
    FProdutoSelecionado := TProdutoPLU(Item.Data);
    ExibirProdutoNosCampos(FProdutoSelecionado);
  end;
end;

procedure TFrmCadastroProdutos.ExibirProdutoNosCampos(AProd: TProdutoPLU);
begin
  if not Assigned(AProd) then
    Exit;

  FCarregandoDados := True;
  try
    { Geral }
    edtPLU.Text := IntToStr(AProd.CodigoPLU);
    edtBarras.Text := AProd.CodigoBarras;
    edtDescricao.Text := AProd.Descricao;
    edtDescricaoCurta.Text := AProd.DescricaoCurta;
    DefinirDepartamentoNoCombo(AProd.Setor);
    cboTipoVenda.ItemIndex := Ord(AProd.TipoVenda);
    edtTecla.Text := IntToStr(AProd.TeclaAcesso);
    chkAtivo.Checked := AProd.Ativo;

    { Preço & Validade }
    edtPreco.Text := FormatFloat('0.00', AProd.PrecoVenda);
    edtValidade.Text := IntToStr(AProd.ValidadeDias);
    edtConservacao.Text := AProd.Conservacao;
    if AProd.UltimaAlteracao > 0 then
      lblDataAlteracao.Caption := DateTimeToStr(AProd.UltimaAlteracao)
    else
      lblDataAlteracao.Caption := 'Não sincronizado';

    { Nutricional RDC 429 }
    if Assigned(AProd.Nutricional) then
    begin
      edtPorcaoQtde.Text := IntToStr(AProd.Nutricional.PorcaoQtde);
      edtValorEnerg.Text := IntToStr(AProd.Nutricional.ValorEnergetico);
      edtCarbo.Text := FormatFloat('0.0', AProd.Nutricional.Carboidratos);
      edtAcucarTot.Text := FormatFloat('0.0', AProd.Nutricional.AcucaresTotais);
      edtAcucarAdic.Text := FormatFloat('0.0', AProd.Nutricional.AcucaresAdicionados);
      edtProteina.Text := FormatFloat('0.0', AProd.Nutricional.Proteinas);
      edtGordTot.Text := FormatFloat('0.0', AProd.Nutricional.GordurasTotais);
      edtGordSat.Text := FormatFloat('0.0', AProd.Nutricional.GordurasSaturadas);
      edtGordTrans.Text := FormatFloat('0.0', AProd.Nutricional.GordurasTrans);
      edtFibra.Text := FormatFloat('0.0', AProd.Nutricional.FibraAlimentar);
      edtSodio.Text := FormatFloat('0.0', AProd.Nutricional.Sodio);
    end
    else
    begin
      edtPorcaoQtde.Text := '100';
      edtValorEnerg.Text := '0';
      edtCarbo.Text := '0,0';
      edtAcucarTot.Text := '0,0';
      edtAcucarAdic.Text := '0,0';
      edtProteina.Text := '0,0';
      edtGordTot.Text := '0,0';
      edtGordSat.Text := '0,0';
      edtGordTrans.Text := '0,0';
      edtFibra.Text := '0,0';
      edtSodio.Text := '0,0';
    end;

    { Ingredientes & Alergênicos }
    memReceita.Text := AProd.Receita;
    memAlergicos.Text := AProd.Alergenicos;

    CalcularLupasNutricionais(nil);
  finally
    FCarregandoDados := False;
  end;
end;

procedure TFrmCadastroProdutos.LimparCamposEdicao;
begin
  FProdutoSelecionado := nil;
  FCarregandoDados := True;
  try
    edtPLU.Text := '';
    edtBarras.Text := '';
    edtDescricao.Text := '';
    edtDescricaoCurta.Text := '';
    if cboDepto.Items.Count > 0 then
      cboDepto.ItemIndex := 0;
    cboTipoVenda.ItemIndex := 0;
    edtTecla.Text := '0';
    chkAtivo.Checked := True;

    edtPreco.Text := '0,00';
    edtValidade.Text := '3';
    edtConservacao.Text := 'Manter sob refrigeração de 0°C a 4°C';
    lblDataAlteracao.Caption := 'Novo item (ainda não salvo)';

    edtPorcaoQtde.Text := '100';
    edtValorEnerg.Text := '0';
    edtCarbo.Text := '0,0';
    edtAcucarTot.Text := '0,0';
    edtAcucarAdic.Text := '0,0';
    edtProteina.Text := '0,0';
    edtGordTot.Text := '0,0';
    edtGordSat.Text := '0,0';
    edtGordTrans.Text := '0,0';
    edtFibra.Text := '0,0';
    edtSodio.Text := '0,0';

    memReceita.Clear;
    memAlergicos.Text := 'ALÉRGICOS: NÃO CONTÉM GLÚTEN.';

    chkLupaAcucar.Checked := False;
    chkLupaGordSat.Checked := False;
    chkLupaSodio.Checked := False;

    pgcProduto.ActivePageIndex := 0;
    if edtPLU.CanFocus then
      edtPLU.SetFocus;
  finally
    FCarregandoDados := False;
  end;
end;

procedure TFrmCadastroProdutos.btnNovoClick(Sender: TObject);
begin
  LimparCamposEdicao;
end;

procedure TFrmCadastroProdutos.CalcularLupasNutricionais(Sender: TObject);
var
  Porcao: Double;
  AcucarAdic: Double;
  GordSat: Double;
  Sodio: Double;
  Fator100g: Double;
  AcucarPor100g: Double;
  GordSatPor100g: Double;
  SodioPor100g: Double;
begin
  if FCarregandoDados then
    Exit;

  Porcao := StrToDoubleDefSafe(edtPorcaoQtde.Text, 100.0);
  if Porcao <= 0 then
    Porcao := 100.0;

  AcucarAdic := StrToDoubleDefSafe(edtAcucarAdic.Text, 0.0);
  GordSat := StrToDoubleDefSafe(edtGordSat.Text, 0.0);
  Sodio := StrToDoubleDefSafe(edtSodio.Text, 0.0);

  Fator100g := 100.0 / Porcao;
  AcucarPor100g := AcucarAdic * Fator100g;
  GordSatPor100g := GordSat * Fator100g;
  SodioPor100g := Sodio * Fator100g;

  { Regras RDC 429/2020 para Alimentos Sólidos/Gerais }
  { Alto em Açúcar Adicionado: >= 15g por 100g }
  chkLupaAcucar.Checked := (AcucarPor100g >= 15.0);

  { Alto em Gordura Saturada: >= 6g por 100g }
  chkLupaGordSat.Checked := (GordSatPor100g >= 6.0);

  { Alto em Sódio: >= 600mg por 100g }
  chkLupaSodio.Checked := (SodioPor100g >= 600.0);
end;

procedure TFrmCadastroProdutos.btnSalvarClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
  Prod: TProdutoPLU;
  Novo: Boolean;
  PLUVal: Integer;
begin
  PLUVal := StrToIntDef(Trim(edtPLU.Text), 0);
  if PLUVal <= 0 then
  begin
    MessageDlg('Por favor, informe um Código PLU válido maior que zero.', mtWarning, [mbOK], 0);
    pgcProduto.ActivePage := tabGeral;
    if edtPLU.CanFocus then
      edtPLU.SetFocus;
    Exit;
  end;

  if Trim(edtDescricao.Text) = '' then
  begin
    MessageDlg('A descrição do produto é obrigatória.', mtWarning, [mbOK], 0);
    pgcProduto.ActivePage := tabGeral;
    if edtDescricao.CanFocus then
      edtDescricao.SetFocus;
    Exit;
  end;

  Novo := (FProdutoSelecionado = nil);
  if Novo then
    Prod := TProdutoPLU.Create
  else
    Prod := FProdutoSelecionado;

  try
    Prod.CodigoPLU := PLUVal;
    Prod.CodigoBarras := Trim(edtBarras.Text);
    Prod.Descricao := Trim(edtDescricao.Text);
    if Trim(edtDescricaoCurta.Text) <> '' then
      Prod.DescricaoCurta := Trim(edtDescricaoCurta.Text)
    else
      Prod.DescricaoCurta := Copy(Prod.Descricao, 1, 25);

    Prod.Setor := ObterIdDepartamentoSelecionado;
    Prod.TipoVenda := TTipoVendaPLU(cboTipoVenda.ItemIndex);
    Prod.TeclaAcesso := StrToIntDef(Trim(edtTecla.Text), 0);
    Prod.Ativo := chkAtivo.Checked;

    Prod.PrecoVenda := StrToCurrDefSafe(edtPreco.Text, 0.0);
    Prod.ValidadeDias := StrToIntDef(Trim(edtValidade.Text), 1);
    Prod.Conservacao := Trim(edtConservacao.Text);
    Prod.Receita := Trim(memReceita.Text);
    Prod.Alergenicos := Trim(memAlergicos.Text);

    { Tabela Nutricional }
    Prod.Nutricional.PorcaoQtde := StrToIntDef(Trim(edtPorcaoQtde.Text), 100);
    Prod.Nutricional.ValorEnergetico := StrToIntDef(Trim(edtValorEnerg.Text), 0);
    Prod.Nutricional.Carboidratos := StrToDoubleDefSafe(edtCarbo.Text, 0.0);
    Prod.Nutricional.AcucaresTotais := StrToDoubleDefSafe(edtAcucarTot.Text, 0.0);
    Prod.Nutricional.AcucaresAdicionados := StrToDoubleDefSafe(edtAcucarAdic.Text, 0.0);
    Prod.Nutricional.Proteinas := StrToDoubleDefSafe(edtProteina.Text, 0.0);
    Prod.Nutricional.GordurasTotais := StrToDoubleDefSafe(edtGordTot.Text, 0.0);
    Prod.Nutricional.GordurasSaturadas := StrToDoubleDefSafe(edtGordSat.Text, 0.0);
    Prod.Nutricional.GordurasTrans := StrToDoubleDefSafe(edtGordTrans.Text, 0.0);
    Prod.Nutricional.FibraAlimentar := StrToDoubleDefSafe(edtFibra.Text, 0.0);
    Prod.Nutricional.Sodio := StrToDoubleDefSafe(edtSodio.Text, 0.0);

    Repo := TRepositoryBalanca.Create(nil);
    try
      if Repo.SalvarProdutoPLU(Prod) then
      begin
        if Novo then
          FListaProdutos.Add(Prod);

        MessageDlg(Format('Produto PLU %d ("%s") gravado com sucesso!', [Prod.CodigoPLU, Prod.Descricao]),
          mtInformation, [mbOK], 0);

        CarregarListaProdutos;
      end
      else
        MessageDlg('Erro ao gravar o produto no banco de dados Firebird.', mtError, [mbOK], 0);
    finally
      Repo.Free;
    end;
  except
    on E: Exception do
    begin
      if Novo then
        Prod.Free;
      MessageDlg('Falha ao salvar produto: ' + E.Message, mtError, [mbOK], 0);
    end;
  end;
end;

procedure TFrmCadastroProdutos.btnExcluirClick(Sender: TObject);
var
  Repo: TRepositoryBalanca;
begin
  if not Assigned(FProdutoSelecionado) then
  begin
    MessageDlg('Selecione um produto na lista para excluir.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format('Deseja realmente inativar o produto PLU %d ("%s")?',
    [FProdutoSelecionado.CodigoPLU, FProdutoSelecionado.Descricao]),
    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    Repo := TRepositoryBalanca.Create(nil);
    try
      if Repo.ExcluirProdutoPLU(FProdutoSelecionado.ID) then
      begin
        MessageDlg('Produto inativado com sucesso.', mtInformation, [mbOK], 0);
        CarregarListaProdutos;
        LimparCamposEdicao;
      end
      else
        MessageDlg('Não foi possível inativar o produto.', mtError, [mbOK], 0);
    finally
      Repo.Free;
    end;
  end;
end;

procedure TFrmCadastroProdutos.btnTransmitirClick(Sender: TObject);
var
  Balancas: TObjectList<TConfigBalanca>;
  Repo: TRepositoryBalanca;
  Driver: IBalancaComunicador;
  Res: TResultadoEnvio;
  ListaEnvio: TObjectList<TProdutoPLU>;
  I, Sucessos, Falhas: Integer;
  Bal: TConfigBalanca;
  MsgLog: string;
begin
  if FListaProdutos.Count = 0 then
  begin
    MessageDlg('Nenhum produto cadastrado para transmitir.', mtWarning, [mbOK], 0);
    Exit;
  end;

  if MessageDlg(Format('Confirma a transmissão direta via rede de %d produtos para todas as balanças cadastradas?',
    [FListaProdutos.Count]), mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Balancas := TObjectList<TConfigBalanca>.Create(True);
  Repo := TRepositoryBalanca.Create(nil);
  ListaEnvio := TObjectList<TProdutoPLU>.Create(False);
  try
    Repo.CarregarBalancas(Balancas);

    for I := 0 to FListaProdutos.Count - 1 do
      if FListaProdutos[I].Ativo and (FListaProdutos[I].CodigoPLU > 0) then
        ListaEnvio.Add(FListaProdutos[I]);

    Sucessos := 0;
    Falhas := 0;

    for I := 0 to Balancas.Count - 1 do
    begin
      Bal := Balancas[I];
      if not Bal.Ativo then
        Continue;

      Driver := TFabricaComunicador.CriarComunicador(Bal);
      if Driver <> nil then
      begin
        Res := Driver.EnviarProdutos(ListaEnvio);
        if Res.Sucesso then
        begin
          Inc(Sucessos);
          Repo.RegistrarLogEnvio(Bal.ID, ListaEnvio.Count, 'SUCESSO', Res.TempoMs, 'Transmissão manual concluída com êxito');
        end
        else
        begin
          Inc(Falhas);
          Repo.RegistrarLogEnvio(Bal.ID, ListaEnvio.Count, 'ERRO', Res.TempoMs, Res.Mensagem);
        end;
      end;
    end;

    MsgLog := Format('Transmissão finalizada!' + sLineBreak +
                     'Balanças atualizadas com sucesso: %d' + sLineBreak +
                     'Balanças com falha de conexão: %d', [Sucessos, Falhas]);

    if Falhas = 0 then
      MessageDlg(MsgLog, mtInformation, [mbOK], 0)
    else
      MessageDlg(MsgLog, mtWarning, [mbOK], 0);

  finally
    ListaEnvio.Free;
    Repo.Free;
    Balancas.Free;
  end;
end;

procedure TFrmCadastroProdutos.btnCargaUSBClick(Sender: TObject);
var
  Diretorio: string;
  Repo: TRepositoryBalanca;
  Fabr: TFabricanteBalanca;
  ItemEscolhido: Integer;
begin
  if FListaProdutos.Count = 0 then
  begin
    MessageDlg('Nenhum produto disponível para exportar.', mtWarning, [mbOK], 0);
    Exit;
  end;

  Diretorio := 'C:\';
  if not SelectDirectory('Selecione a unidade do Pen Drive (USB) para salvar a carga:', '', Diretorio) then
    Exit;

  { Opções de Fabricante }
  ItemEscolhido := MessageDlg(
    'Qual o formato do arquivo para o Pen Drive da Balança?' + sLineBreak +
    '[Sim] = Toledo (ITENSAUT.TXT)' + sLineBreak +
    '[Não] = Balmak (CARGA.TXT)' + sLineBreak +
    '[Cancelar] = Filizola (CADTXT.TXT)',
    mtConfirmation, [mbYes, mbNo, mbCancel], 0
  );

  case ItemEscolhido of
    mrYes: Fabr := fbToledo;
    mrNo: Fabr := fbBalmak;
    mrCancel: Fabr := fbFilizola;
  else
    Fabr := fbUrano;
  end;

  Repo := TRepositoryBalanca.Create(nil);
  try
    if Repo.ExportarCargaUSB(FListaProdutos, Diretorio, Fabr) then
    begin
      MessageDlg(
        'Arquivo de Carga USB gerado com sucesso no Pen Drive!' + sLineBreak + sLineBreak +
        'Localização: ' + Diretorio + sLineBreak +
        'Insira o Pen Drive na porta USB da balança e acesse o menu "Importar Carga".',
        mtInformation, [mbOK], 0
      );
    end
    else
      MessageDlg('Erro ao gerar o arquivo de carga USB.', mtError, [mbOK], 0);
  finally
    Repo.Free;
  end;
end;

procedure TFrmCadastroProdutos.btnRecarregarClick(Sender: TObject);
begin
  CarregarListaProdutos;
end;

procedure TFrmCadastroProdutos.btnFecharClick(Sender: TObject);
begin
  Close;
end;

function TFrmCadastroProdutos.ObterIdDepartamentoSelecionado: Integer;
begin
  if (cboDepto.ItemIndex >= 0) and (cboDepto.Items.Objects[cboDepto.ItemIndex] <> nil) then
    Result := Integer(IntPtr(cboDepto.Items.Objects[cboDepto.ItemIndex]))
  else
    Result := 1;
end;

procedure TFrmCadastroProdutos.DefinirDepartamentoNoCombo(const AID: Integer);
var
  I: Integer;
begin
  for I := 0 to cboDepto.Items.Count - 1 do
  begin
    if Integer(IntPtr(cboDepto.Items.Objects[I])) = AID then
    begin
      cboDepto.ItemIndex := I;
      Exit;
    end;
  end;
  if cboDepto.Items.Count > 0 then
    cboDepto.ItemIndex := 0;
end;

function TFrmCadastroProdutos.StrToDoubleDefSafe(const AStr: string; const ADef: Double): Double;
var
  S: string;
begin
  S := StringReplace(Trim(AStr), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToFloatDef(S, ADef);
end;

function TFrmCadastroProdutos.StrToCurrDefSafe(const AStr: string; const ADef: Currency): Currency;
var
  S: string;
begin
  S := StringReplace(Trim(AStr), '.', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  S := StringReplace(S, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
  Result := StrToCurrDef(S, ADef);
end;

end.
