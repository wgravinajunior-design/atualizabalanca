unit UFrmComparador;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança Enterprise                           }
{  UFrmComparador.pas: Tela de Auditoria e Comparativo de Preços e Produtos    }
{******************************************************************************}

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Variants,
  System.Classes,
  System.UITypes,
  System.Generics.Collections,
  System.IOUtils,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Data.DB,
  FireDAC.Comp.Client,
  UModelBalanca,
  UDMConexao,
  URepositoryBalanca,
  UComunicadorBalanca;

type
  TTipoItemComparativo = (
    ticTodos,
    ticPrecoSubiu,
    ticPrecoBaixou,
    ticNovoPLU,
    ticSemCodigoBalanca,
    ticAlterado
  );

  TItemComparativo = class
  public
    Tipo: TTipoItemComparativo;
    PLU: Integer;
    CodigoERP: string;
    Descricao: string;
    PrecoAnterior: Currency;
    PrecoAtual: Currency;
    VariacaoReais: Currency;
    VariacaoPct: Double;
    ValidadeDias: Integer;
    Setor: Integer;
    MensagemStatus: string;
  end;

  TFrmComparador = class(TForm)
    pnlTopo: TPanel;
    lblTitulo: TLabel;
    lblSubtitulo: TLabel;
    pnlCards: TPanel;
    pnlCardTotal: TPanel;
    lblCardTotalTit: TLabel;
    lblCardTotalVal: TLabel;
    pnlCardReajustes: TPanel;
    lblCardReajustesTit: TLabel;
    lblCardReajustesVal: TLabel;
    pnlCardNovos: TPanel;
    lblCardNovosTit: TLabel;
    lblCardNovosVal: TLabel;
    pnlCardPendentes: TPanel;
    lblCardPendentesTit: TLabel;
    lblCardPendentesVal: TLabel;
    pnlToolbar: TPanel;
    lblFiltro: TLabel;
    cbFiltro: TComboBox;
    btnAtualizar: TButton;
    lvComparativo: TListView;
    pnlRodape: TPanel;
    btnTransmitirAgora: TButton;
    btnExportarCSV: TButton;
    btnFechar: TButton;
    SaveDialogCSV: TSaveDialog;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure cbFiltroChange(Sender: TObject);
    procedure btnAtualizarClick(Sender: TObject);
    procedure btnTransmitirAgoraClick(Sender: TObject);
    procedure btnExportarCSVClick(Sender: TObject);
    procedure btnFecharClick(Sender: TObject);
  private
    FItens: TObjectList<TItemComparativo>;
    FCaminhoSnapshot: string;

    function ObterCaminhoSnapshot: string;
    procedure CarregarDadosComparativos;
    procedure AtualizarGridFiltrado;
    procedure SalvarSnapshotAtual;
  public
  end;

var
  FrmComparador: TFrmComparador;

implementation

{$R *.dfm}

{ TFrmComparador }

function TFrmComparador.ObterCaminhoSnapshot: string;
var
  PastaCache: string;
begin
  PastaCache := ExtractFilePath(ParamStr(0)) + 'Cache';
  if not DirectoryExists(PastaCache) then
    ForceDirectories(PastaCache);
  Result := IncludeTrailingPathDelimiter(PastaCache) + 'UltimaCargaSnapshot.ini';
end;

procedure TFrmComparador.FormCreate(Sender: TObject);
begin
  FItens := TObjectList<TItemComparativo>.Create(True);
  FCaminhoSnapshot := ObterCaminhoSnapshot;
end;

procedure TFrmComparador.FormDestroy(Sender: TObject);
begin
  FItens.Free;
end;

procedure TFrmComparador.FormShow(Sender: TObject);
begin
  CarregarDadosComparativos;
end;

procedure TFrmComparador.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of
    VK_ESCAPE:
    begin
      Key := 0;
      Close;
    end;
    VK_F5:
    begin
      Key := 0;
      btnTransmitirAgoraClick(Self);
    end;
  end;
end;

procedure TFrmComparador.btnFecharClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmComparador.btnAtualizarClick(Sender: TObject);
begin
  CarregarDadosComparativos;
end;

procedure TFrmComparador.cbFiltroChange(Sender: TObject);
begin
  AtualizarGridFiltrado;
end;

procedure TFrmComparador.CarregarDadosComparativos;
var
  Repo: TRepositoryBalanca;
  ProdutosAtuais: TObjectList<TProdutoPLU>;
  SnapshotMapPrecos: TDictionary<Integer, Currency>;
  SnapshotMapDescricao: TDictionary<Integer, string>;
  IniSnapshot: TStringList;
  I: Integer;
  P: TProdutoPLU;
  ItemComp: TItemComparativo;
  PrecoAnterior: Currency;
  LinhaSnapshot: string;
  PosIgual, PosPipe: Integer;
  PluKey: Integer;
  PrecoVal: Currency;
  DescVal: string;
  QryPendentes: TFDQuery;
  TotalBalanca, TotalReajustados, TotalNovos, TotalPendentes: Integer;
begin
  if not Assigned(DMConexao) or not DMConexao.FDConnection.Connected then
  begin
    ShowMessage('Não foi possível conectar ao banco Firebird para carregar os dados.');
    Exit;
  end;

  Screen.Cursor := crHourGlass;
  FItens.Clear;
  SnapshotMapPrecos := TDictionary<Integer, Currency>.Create;
  SnapshotMapDescricao := TDictionary<Integer, string>.Create;
  ProdutosAtuais := TObjectList<TProdutoPLU>.Create(True);
  IniSnapshot := TStringList.Create;
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  try
    { 1. Carrega snapshot anterior salvo em disco se existir }
    if FileExists(FCaminhoSnapshot) then
    begin
      IniSnapshot.LoadFromFile(FCaminhoSnapshot, TEncoding.UTF8);
      for I := 0 to IniSnapshot.Count - 1 do
      begin
        LinhaSnapshot := Trim(IniSnapshot[I]);
        if (LinhaSnapshot = '') or (LinhaSnapshot[1] = ';') or (LinhaSnapshot[1] = '[') then
          Continue;

        PosIgual := Pos('=', LinhaSnapshot);
        if PosIgual > 0 then
        begin
          PluKey := StrToIntDef(Copy(LinhaSnapshot, 1, PosIgual - 1), 0);
          DescVal := Copy(LinhaSnapshot, PosIgual + 1, Length(LinhaSnapshot));
          PosPipe := Pos('|', DescVal);
          if PosPipe > 0 then
          begin
            PrecoVal := StrToCurrDef(Copy(DescVal, 1, PosPipe - 1), 0);
            DescVal := Copy(DescVal, PosPipe + 1, Length(DescVal));
          end
          else
            PrecoVal := StrToCurrDef(DescVal, 0);

          if PluKey > 0 then
          begin
            SnapshotMapPrecos.AddOrSetValue(PluKey, PrecoVal);
            SnapshotMapDescricao.AddOrSetValue(PluKey, DescVal);
          end;
        end;
      end;
    end;

    { 2. Consulta produtos ativos com código de balança do ERP }
    Repo.ObterTodosProdutosBalanca(ProdutosAtuais, 0);

    TotalBalanca := ProdutosAtuais.Count;
    TotalReajustados := 0;
    TotalNovos := 0;

    for I := 0 to ProdutosAtuais.Count - 1 do
    begin
      P := ProdutosAtuais[I];
      ItemComp := TItemComparativo.Create;
      ItemComp.PLU := P.CodigoPLU;
      ItemComp.CodigoERP := P.CodigoBarras;
      ItemComp.Descricao := P.Descricao;
      ItemComp.PrecoAtual := P.PrecoVenda;
      ItemComp.ValidadeDias := P.ValidadeDias;
      ItemComp.Setor := P.Setor;

      if SnapshotMapPrecos.TryGetValue(P.CodigoPLU, PrecoAnterior) then
      begin
        ItemComp.PrecoAnterior := PrecoAnterior;
        ItemComp.VariacaoReais := P.PrecoVenda - PrecoAnterior;
        if PrecoAnterior > 0 then
          ItemComp.VariacaoPct := ((P.PrecoVenda - PrecoAnterior) / PrecoAnterior) * 100.0
        else
          ItemComp.VariacaoPct := 0;

        if P.PrecoVenda > PrecoAnterior then
        begin
          ItemComp.Tipo := ticPrecoSubiu;
          ItemComp.MensagemStatus := Format('🔴 Preço Subiu (+%.1f%%)', [ItemComp.VariacaoPct]);
          Inc(TotalReajustados);
        end
        else if P.PrecoVenda < PrecoAnterior then
        begin
          ItemComp.Tipo := ticPrecoBaixou;
          ItemComp.MensagemStatus := Format('🟢 Preço Baixou (%.1f%%)', [ItemComp.VariacaoPct]);
          Inc(TotalReajustados);
        end
        else
        begin
          ItemComp.Tipo := ticTodos;
          ItemComp.MensagemStatus := 'Preço Mantido';
        end;
      end
      else
      begin
        { Produto não constava no snapshot anterior }
        ItemComp.PrecoAnterior := P.PrecoVenda;
        ItemComp.VariacaoReais := 0;
        ItemComp.VariacaoPct := 0;
        ItemComp.Tipo := ticNovoPLU;
        ItemComp.MensagemStatus := '🆕 Novo Cadastro PLU';
        Inc(TotalNovos);
      end;

      FItens.Add(ItemComp);
    end;

    { 3. Consulta produtos que faltam preencher o código de balança }
    TotalPendentes := 0;
    QryPendentes := TFDQuery.Create(nil);
    try
      QryPendentes.Connection := DMConexao.FDConnection;
      QryPendentes.SQL.Text :=
        'SELECT P.PRD_ID, P.PRD_CODIGO, P.PRD_DESCRICAO, P.PRD_PRECO_VENDA, ' +
        '       P.PRD_BALANCA_VALIDADE, P.PRD_SETOR ' +
        'FROM TB_PRODUTO P ' +
        'WHERE P.PRD_STATUS = ''A'' ' +
        '  AND (P.PRD_BALANCA_CODIGO IS NULL OR P.PRD_BALANCA_CODIGO <= 0) ' +
        '  AND ((P.PRD_BALANCA_VALIDADE > 0) OR (P.PRD_BALANCA_TIPO IS NOT NULL) OR (P.PRD_SETOR > 0)) ' +
        'ORDER BY P.PRD_DESCRICAO ASC';
      QryPendentes.Open;

      while not QryPendentes.Eof do
      begin
        Inc(TotalPendentes);
        ItemComp := TItemComparativo.Create;
        ItemComp.Tipo := ticSemCodigoBalanca;
        ItemComp.PLU := 0;
        ItemComp.CodigoERP := Trim(QryPendentes.FieldByName('PRD_CODIGO').AsString);
        ItemComp.Descricao := Trim(QryPendentes.FieldByName('PRD_DESCRICAO').AsString);
        ItemComp.PrecoAnterior := 0;
        ItemComp.PrecoAtual := QryPendentes.FieldByName('PRD_PRECO_VENDA').AsCurrency;
        ItemComp.VariacaoReais := 0;
        ItemComp.VariacaoPct := 0;
        ItemComp.ValidadeDias := QryPendentes.FieldByName('PRD_BALANCA_VALIDADE').AsInteger;
        ItemComp.Setor := QryPendentes.FieldByName('PRD_SETOR').AsInteger;
        ItemComp.MensagemStatus := '⚠️ FALTA CÓDIGO BALANÇA (ERP)';
        FItens.Add(ItemComp);
        QryPendentes.Next;
      end;
    finally
      QryPendentes.Free;
    end;

    { 4. Atualiza cards no topo }
    lblCardTotalVal.Caption := IntToStr(TotalBalanca);
    lblCardReajustesVal.Caption := IntToStr(TotalReajustados);
    lblCardNovosVal.Caption := IntToStr(TotalNovos);
    lblCardPendentesVal.Caption := IntToStr(TotalPendentes);

    AtualizarGridFiltrado;
  finally
    Repo.Free;
    IniSnapshot.Free;
    ProdutosAtuais.Free;
    SnapshotMapDescricao.Free;
    SnapshotMapPrecos.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmComparador.AtualizarGridFiltrado;
var
  I: Integer;
  Item: TItemComparativo;
  ListItem: TListItem;
  FiltroIndex: Integer;
  DeveExibir: Boolean;
  StrVariacao: string;
begin
  lvComparativo.Items.BeginUpdate;
  try
    lvComparativo.Items.Clear;
    FiltroIndex := cbFiltro.ItemIndex;

    for I := 0 to FItens.Count - 1 do
    begin
      Item := FItens[I];

      case FiltroIndex of
        1: DeveExibir := (Item.Tipo = ticPrecoSubiu);
        2: DeveExibir := (Item.Tipo = ticPrecoBaixou);
        3: DeveExibir := (Item.Tipo = ticNovoPLU);
        4: DeveExibir := (Item.Tipo = ticSemCodigoBalanca);
      else
        DeveExibir := True;
      end;

      if not DeveExibir then
        Continue;

      ListItem := lvComparativo.Items.Add;
      ListItem.Caption := Item.MensagemStatus;

      if Item.PLU > 0 then
        ListItem.SubItems.Add(Format('%.6d', [Item.PLU]))
      else
        ListItem.SubItems.Add('[PENDENTE]');

      ListItem.SubItems.Add(Item.CodigoERP);
      ListItem.SubItems.Add(Item.Descricao);

      if Item.PrecoAnterior > 0 then
        ListItem.SubItems.Add(Format('R$ %.2f', [Item.PrecoAnterior]))
      else
        ListItem.SubItems.Add('-');

      ListItem.SubItems.Add(Format('R$ %.2f', [Item.PrecoAtual]));

      if Item.VariacaoReais > 0 then
        StrVariacao := Format('+R$ %.2f (+%.1f%%)', [Item.VariacaoReais, Item.VariacaoPct])
      else if Item.VariacaoReais < 0 then
        StrVariacao := Format('-R$ %.2f (%.1f%%)', [Abs(Item.VariacaoReais), Item.VariacaoPct])
      else
        StrVariacao := '-';

      ListItem.SubItems.Add(StrVariacao);

      if Item.ValidadeDias > 0 then
        ListItem.SubItems.Add(Format('%d d', [Item.ValidadeDias]))
      else
        ListItem.SubItems.Add('-');

      if Item.Setor > 0 then
        ListItem.SubItems.Add(IntToStr(Item.Setor))
      else
        ListItem.SubItems.Add('Todos');
    end;
  finally
    lvComparativo.Items.EndUpdate;
  end;
end;

procedure TFrmComparador.SalvarSnapshotAtual;
var
  IniList: TStringList;
  I: Integer;
  Item: TItemComparativo;
begin
  IniList := TStringList.Create;
  try
    IniList.Add('; Snapshot de Precos e PLUs da Balanca - AtualizaBalanca');
    IniList.Add('; Data de Atualizacao: ' + FormatDateTime('yyyy-mm-dd hh:nn:ss', Now));
    IniList.Add('[PRODUTOS]');

    for I := 0 to FItens.Count - 1 do
    begin
      Item := FItens[I];
      if Item.PLU > 0 then
      begin
        IniList.Add(Format('%d=%s|%s', [Item.PLU, CurrToStr(Item.PrecoAtual), Item.Descricao]));
      end;
    end;

    IniList.SaveToFile(FCaminhoSnapshot, TEncoding.UTF8);
  finally
    IniList.Free;
  end;
end;

procedure TFrmComparador.btnTransmitirAgoraClick(Sender: TObject);
var
  Balancas: TObjectList<TConfigBalanca>;
  Produtos: TObjectList<TProdutoPLU>;
  ProdutosSetor: TObjectList<TProdutoPLU>;
  Driver: IBalancaComunicador;
  Resultado: TResultadoEnvio;
  Repo: TRepositoryBalanca;
  I, J, Ativas, Sucessos: Integer;
  Bal: TConfigBalanca;
begin
  if MessageDlg('Deseja transmitir imediatamente todas as alterações e produtos para as balanças da rede?',
                mtConfirmation, [mbYes, mbNo], 0) <> mrYes then
    Exit;

  Screen.Cursor := crHourGlass;
  Balancas := TObjectList<TConfigBalanca>.Create(True);
  Produtos := TObjectList<TProdutoPLU>.Create(True);
  ProdutosSetor := TObjectList<TProdutoPLU>.Create(False);
  Repo := TRepositoryBalanca.Create(DMConexao.FDConnection);
  try
    DMConexao.CarregarBalancasINI(Balancas);
    Repo.ObterTodosProdutosBalanca(Produtos, 0);

    if Balancas.Count = 0 then
    begin
      ShowMessage('Nenhuma balança cadastrada para receber a transmissão.');
      Exit;
    end;

    if Produtos.Count = 0 then
    begin
      ShowMessage('Nenhum produto cadastrado com código de balança.');
      Exit;
    end;

    Ativas := 0;
    Sucessos := 0;

    for I := 0 to Balancas.Count - 1 do
    begin
      Bal := Balancas[I];
      if not Bal.Ativo then
        Continue;

      Inc(Ativas);
      ProdutosSetor.Clear;
      for J := 0 to Produtos.Count - 1 do
      begin
        if (Bal.Setor = 0) or (Produtos[J].Setor = Bal.Setor) then
          ProdutosSetor.Add(Produtos[J]);
      end;

      if ProdutosSetor.Count = 0 then
        Continue;

      Driver := TFabricaComunicador.CriarComunicador(Bal);
      Resultado := Driver.EnviarProdutos(ProdutosSetor);
      if Resultado.Sucesso then
      begin
        Inc(Sucessos);
        Repo.RegistrarLogEnvio(Bal.ID, Resultado.QuantidadeItens, 'S', Resultado.TempoMs, Resultado.Mensagem);
      end
      else
      begin
        Repo.RegistrarLogEnvio(Bal.ID, 0, 'E', Resultado.TempoMs, Resultado.Mensagem);
      end;
    end;

    SalvarSnapshotAtual;

    ShowMessage(Format('Transmissão concluída com sucesso!'#13#10 +
                       '%d de %d balanças responderam com êxito.'#13#10 +
                       'O snapshot de preços foi atualizado.', [Sucessos, Ativas]));

    CarregarDadosComparativos;
  finally
    ProdutosSetor.Free;
    Produtos.Free;
    Balancas.Free;
    Repo.Free;
    Screen.Cursor := crDefault;
  end;
end;

procedure TFrmComparador.btnExportarCSVClick(Sender: TObject);
var
  Linhas: TStringList;
  I: Integer;
  Item: TItemComparativo;
  Linha: string;
begin
  if FItens.Count = 0 then
  begin
    ShowMessage('Não há registros para exportar.');
    Exit;
  end;

  SaveDialogCSV.Title := 'Salvar Relatório Comparativo de Preços e Produtos';
  SaveDialogCSV.Filter := 'Planilha CSV (*.csv)|*.csv|Todos os Arquivos (*.*)|*.*';
  SaveDialogCSV.DefaultExt := 'csv';
  SaveDialogCSV.FileName := Format('Comparativo_Precos_%s.csv', [FormatDateTime('yyyy-mm-dd_hhnn', Now)]);

  if SaveDialogCSV.Execute then
  begin
    Linhas := TStringList.Create;
    try
      Linhas.Add('STATUS;PLU_BALANCA;CODIGO_ERP;DESCRICAO;PRECO_ANTERIOR;PRECO_ATUAL;VARIACAO_REAIS;VARIACAO_PCT;VALIDADE_DIAS;SETOR');

      for I := 0 to FItens.Count - 1 do
      begin
        Item := FItens[I];
        Linha := Format('"%s";%d;"%s";"%s";%s;%s;%s;%s;%d;%d', [
          Item.MensagemStatus,
          Item.PLU,
          Item.CodigoERP,
          StringReplace(Item.Descricao, '"', '""', [rfReplaceAll]),
          FormatFloat('0.00', Item.PrecoAnterior),
          FormatFloat('0.00', Item.PrecoAtual),
          FormatFloat('0.00', Item.VariacaoReais),
          FormatFloat('0.0', Item.VariacaoPct),
          Item.ValidadeDias,
          Item.Setor
        ]);
        Linhas.Add(Linha);
      end;

      Linhas.SaveToFile(SaveDialogCSV.FileName, TEncoding.UTF8);

      if MessageDlg('Planilha comparativa gerada com sucesso!'#13#10'Deseja abrir o arquivo agora no Excel / visualizador padrão?',
                    mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        ShellExecute(0, 'open', PChar(SaveDialogCSV.FileName), nil, nil, SW_SHOWNORMAL);
    finally
      Linhas.Free;
    end;
  end;
end;

end.
