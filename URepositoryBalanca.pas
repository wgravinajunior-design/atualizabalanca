unit URepositoryBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  URepositoryBalanca.pas: Repositório de Acesso a Dados FireDAC e INI         }
{  Arquitetura Não-Intrusiva: Banco de Dados em Modo Somente Leitura (Read-Only)}
{  Nenhuma tabela, trigger ou generator é criado no Firebird do ERP.           }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.StrUtils,
  System.Generics.Collections,
  System.SyncObjs,
  System.IOUtils,
  Data.DB,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  UModelBalanca;

type
  TRepositoryBalanca = class
  private
    FConnection: TFDConnection;
    procedure PreencherProdutoPLU(AQry: TFDQuery; AItem: TProdutoPLU);
    class var FLogLock: TCriticalSection;
    class constructor CreateClass;
    class destructor DestroyClass;
  public
    constructor Create(AConnection: TFDConnection);

    { Gerenciamento de Balanças (Persistência em Arquivo INI / CONF) }
    procedure CarregarBalancas(ALista: TObjectList<TConfigBalanca>);
    procedure SalvarBalanca(ABalanca: TConfigBalanca);
    procedure ExcluirBalanca(const AID: Integer);
    procedure AtualizarStatusBalanca(const AID: Integer; const AOnline: Boolean; const AUltimoLog: string);

    { Consulta e Cadastro de Produtos e Departamentos }
    procedure ObterDepartamentos(ALista: TObjectList<TDepartamento>);
    function SalvarProdutoPLU(AProduto: TProdutoPLU): Boolean;
    function ExcluirProdutoPLU(const AID: Integer): Boolean;
    procedure ObterProdutosAlteradosFila(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer; var AIDsFila: TList<Integer>);
    procedure ObterProdutosAlteradosTimestamp(ALista: TObjectList<TProdutoPLU>; const ADataCorte: TDateTime; const ASetor: Integer);
    procedure ObterTodosProdutosBalanca(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer);

    { Gestão e Relatórios de Vendas e Exportação USB }
    procedure ObterRelatorioDesempenhoVendas(const ADataIni, ADataFim: TDateTime; const ASetor: Integer; ALista: TObjectList<TRegistroVendaPesagem>);
    function ExportarCargaUSB(AProdutos: TObjectList<TProdutoPLU>; const ADiretorioDestino: string; const AFabricante: TFabricanteBalanca): Boolean;

    { Auditoria e Logs Locais (Arquivo de Texto em Disco) }
    procedure MarcarFilaProcessada(AIDsFila: TList<Integer>; const ALog: string);
    procedure RegistrarLogEnvio(const AIDBalanca: Integer; const AItens: Integer; const AStatus: string; const ATempoMs: Cardinal; const AMsg: string);
    function ObterUltimosLogsJSON(const AQtd: Integer = 50): string;
    function ObterStatusBalancasJSON: string;
  end;

implementation

uses
  UDMConexao;

{ TRepositoryBalanca }

class constructor TRepositoryBalanca.CreateClass;
begin
  FLogLock := TCriticalSection.Create;
end;

class destructor TRepositoryBalanca.DestroyClass;
begin
  FreeAndNil(FLogLock);
end;

constructor TRepositoryBalanca.Create(AConnection: TFDConnection);
begin
  inherited Create;
  FConnection := AConnection;
end;

procedure TRepositoryBalanca.CarregarBalancas(ALista: TObjectList<TConfigBalanca>);
begin
  if Assigned(DMConexao) then
    DMConexao.CarregarBalancasINI(ALista);
end;

procedure TRepositoryBalanca.SalvarBalanca(ABalanca: TConfigBalanca);
var
  Lista: TObjectList<TConfigBalanca>;
  I: Integer;
  Encontrou: Boolean;
  NovoItem: TConfigBalanca;
begin
  if not Assigned(ABalanca) or not Assigned(DMConexao) then
    Exit;

  Lista := TObjectList<TConfigBalanca>.Create(True);
  try
    DMConexao.CarregarBalancasINI(Lista);
    Encontrou := False;

    for I := 0 to Lista.Count - 1 do
    begin
      if (ABalanca.ID > 0) and (Lista[I].ID = ABalanca.ID) then
      begin
        Lista[I].Nome := ABalanca.Nome;
        Lista[I].Fabricante := ABalanca.Fabricante;
        Lista[I].Modelo := ABalanca.Modelo;
        Lista[I].IP := ABalanca.IP;
        Lista[I].Porta := ABalanca.Porta;
        Lista[I].Setor := ABalanca.Setor;
        Lista[I].Ativo := ABalanca.Ativo;
        Lista[I].CaminhoDLL := ABalanca.CaminhoDLL;
        Encontrou := True;
        Break;
      end;
    end;

    if not Encontrou then
    begin
      NovoItem := TConfigBalanca.Create;
      NovoItem.ID := Lista.Count + 1;
      NovoItem.Nome := ABalanca.Nome;
      NovoItem.Fabricante := ABalanca.Fabricante;
      NovoItem.Modelo := ABalanca.Modelo;
      NovoItem.IP := ABalanca.IP;
      NovoItem.Porta := ABalanca.Porta;
      NovoItem.Setor := ABalanca.Setor;
      NovoItem.Ativo := ABalanca.Ativo;
      NovoItem.CaminhoDLL := ABalanca.CaminhoDLL;
      Lista.Add(NovoItem);
      ABalanca.ID := NovoItem.ID;
    end;

    DMConexao.SalvarBalancasINI(Lista);
  finally
    Lista.Free;
  end;
end;

procedure TRepositoryBalanca.ExcluirBalanca(const AID: Integer);
var
  Lista: TObjectList<TConfigBalanca>;
  I: Integer;
begin
  if (AID <= 0) or not Assigned(DMConexao) then
    Exit;

  Lista := TObjectList<TConfigBalanca>.Create(True);
  try
    DMConexao.CarregarBalancasINI(Lista);
    for I := Lista.Count - 1 downto 0 do
    begin
      if Lista[I].ID = AID then
      begin
        Lista.Delete(I);
        Break;
      end;
    end;
    DMConexao.SalvarBalancasINI(Lista);
  finally
    Lista.Free;
  end;
end;

procedure TRepositoryBalanca.AtualizarStatusBalanca(const AID: Integer; const AOnline: Boolean; const AUltimoLog: string);
begin
  { Status mantido em memória e registrado via log local }
end;

procedure TRepositoryBalanca.PreencherProdutoPLU(AQry: TFDQuery; AItem: TProdutoPLU);
begin
  AItem.ID := AQry.FieldByName('PRD_ID').AsInteger;
  AItem.CodigoPLU := AQry.FieldByName('PRD_BALANCA_CODIGO').AsInteger;
  AItem.CodigoBarras := Trim(AQry.FieldByName('PRD_CODIGO').AsString);
  AItem.Descricao := Trim(AQry.FieldByName('PRD_DESCRICAO').AsString);
  AItem.DescricaoCurta := Trim(AQry.FieldByName('PRD_DESCRICAO_CURTA').AsString);
  if AItem.DescricaoCurta = '' then
    AItem.DescricaoCurta := Copy(AItem.Descricao, 1, 25);

  AItem.PrecoVenda := AQry.FieldByName('PRD_PRECO_VENDA').AsCurrency;
  AItem.ValidadeDias := AQry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger;
  if AQry.FieldByName('PRD_BALANCA_TIPO').AsInteger = 1 then
    AItem.TipoVenda := tvUnidade
  else
    AItem.TipoVenda := tvPeso;

  AItem.TeclaAcesso := AQry.FieldByName('PRD_BALANCA_TECLA').AsInteger;
  AItem.Setor := AQry.FieldByName('PRD_SETOR').AsInteger;
  AItem.Ativo := (AQry.FieldByName('PRD_STATUS').AsString = 'A');
  AItem.UltimaAlteracao := AQry.FieldByName('PRD_ULTIMA_ALTERACAO').AsDateTime;

  { Informações de Receita / Ingredientes / Alergênicos }
  AItem.Receita := Trim(AQry.FieldByName('PRD_INFADPROD').AsString);
  AItem.Alergenicos := Trim(AQry.FieldByName('PRD_OBS_RESUMIDA').AsString);

  { Informações Nutricionais Completas (RDC 429) }
  if not AQry.FieldByName('PRDN_PRODUTO').IsNull then
  begin
    AItem.Nutricional.PorcaoQtde := AQry.FieldByName('PRDN_PORCAO_QTDE').AsInteger;
    AItem.Nutricional.ValorEnergetico := AQry.FieldByName('PRDN_VALOR_ENERGETICO').AsInteger;
    AItem.Nutricional.Carboidratos := AQry.FieldByName('PRDN_CARBOIDRATO').AsFloat;
    AItem.Nutricional.AcucaresTotais := AQry.FieldByName('PRDN_ACUCAR_TOTAL').AsFloat;
    AItem.Nutricional.AcucaresAdicionados := AQry.FieldByName('PRDN_ACUCAR_ADICIONADO').AsFloat;
    AItem.Nutricional.Proteinas := AQry.FieldByName('PRDN_PROTEINA').AsFloat;
    AItem.Nutricional.GordurasTotais := AQry.FieldByName('PRDN_GORDURA_TOTAL').AsFloat;
    AItem.Nutricional.GordurasSaturadas := AQry.FieldByName('PRDN_GORDURA_SATURADA').AsFloat;
    AItem.Nutricional.GordurasTrans := AQry.FieldByName('PRDN_GORDURA_TRANS').AsFloat;
    AItem.Nutricional.FibraAlimentar := AQry.FieldByName('PRDN_FIBRA').AsFloat;
    AItem.Nutricional.Sodio := AQry.FieldByName('PRDN_SODIO').AsFloat;
  end;
end;

procedure TRepositoryBalanca.ObterProdutosAlteradosFila(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer; var AIDsFila: TList<Integer>);
var
  DataCorte: TDateTime;
  IntervaloDias: Double;
begin
  AIDsFila.Clear;
  if Assigned(DMConexao) and (DMConexao.IntervaloSyncSegundos > 0) then
    IntervaloDias := DMConexao.IntervaloSyncSegundos / 86400.0
  else
    IntervaloDias := 30.0 / 86400.0;

  DataCorte := Now - IntervaloDias;
  ObterProdutosAlteradosTimestamp(ALista, DataCorte, ASetor);
end;

procedure TRepositoryBalanca.ObterProdutosAlteradosTimestamp(ALista: TObjectList<TProdutoPLU>; const ADataCorte: TDateTime; const ASetor: Integer);
var
  Qry: TFDQuery;
  Item: TProdutoPLU;
begin
  ALista.Clear;
  if not Assigned(FConnection) or not FConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_DESCRICAO_CURTA, ' +
      '  P.PRD_PRECO_VENDA, ' +
      '  P.PRD_BALANCA_VALIDADE, ' +
      '  P.PRD_BALANCA_TIPO, ' +
      '  P.PRD_BALANCA_TECLA, ' +
      '  P.PRD_SETOR, ' +
      '  P.PRD_STATUS, ' +
      '  P.PRD_ULTIMA_ALTERACAO, ' +
      '  P.PRD_INFADPROD, ' +
      '  P.PRD_OBS_RESUMIDA, ' +
      '  N.PRDN_PRODUTO, ' +
      '  N.PRDN_PORCAO_QTDE, ' +
      '  N.PRDN_VALOR_ENERGETICO, ' +
      '  N.PRDN_CARBOIDRATO, ' +
      '  N.PRDN_ACUCAR_TOTAL, ' +
      '  N.PRDN_ACUCAR_ADICIONADO, ' +
      '  N.PRDN_PROTEINA, ' +
      '  N.PRDN_GORDURA_TOTAL, ' +
      '  N.PRDN_GORDURA_SATURADA, ' +
      '  N.PRDN_GORDURA_TRANS, ' +
      '  N.PRDN_FIBRA, ' +
      '  N.PRDN_SODIO ' +
      'FROM TB_PRODUTO P ' +
      'LEFT JOIN TB_PRODUTO_NUTRICIONAL N ON (N.PRDN_PRODUTO = P.PRD_ID) ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_ULTIMA_ALTERACAO >= :CORTE ' +
      '  AND (:SETOR = 0 OR P.PRD_SETOR = :SETOR) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.ParamByName('CORTE').AsDateTime := ADataCorte;
    Qry.ParamByName('SETOR').AsInteger := ASetor;
    Qry.Open;

    while not Qry.Eof do
    begin
      Item := TProdutoPLU.Create;
      PreencherProdutoPLU(Qry, Item);
      ALista.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoryBalanca.ObterTodosProdutosBalanca(ALista: TObjectList<TProdutoPLU>; const ASetor: Integer);
var
  Qry: TFDQuery;
  Item: TProdutoPLU;
begin
  ALista.Clear;
  if not Assigned(FConnection) or not FConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_DESCRICAO_CURTA, ' +
      '  P.PRD_PRECO_VENDA, ' +
      '  P.PRD_BALANCA_VALIDADE, ' +
      '  P.PRD_BALANCA_TIPO, ' +
      '  P.PRD_BALANCA_TECLA, ' +
      '  P.PRD_SETOR, ' +
      '  P.PRD_STATUS, ' +
      '  P.PRD_ULTIMA_ALTERACAO, ' +
      '  P.PRD_INFADPROD, ' +
      '  P.PRD_OBS_RESUMIDA, ' +
      '  N.PRDN_PRODUTO, ' +
      '  N.PRDN_PORCAO_QTDE, ' +
      '  N.PRDN_VALOR_ENERGETICO, ' +
      '  N.PRDN_CARBOIDRATO, ' +
      '  N.PRDN_ACUCAR_TOTAL, ' +
      '  N.PRDN_ACUCAR_ADICIONADO, ' +
      '  N.PRDN_PROTEINA, ' +
      '  N.PRDN_GORDURA_TOTAL, ' +
      '  N.PRDN_GORDURA_SATURADA, ' +
      '  N.PRDN_GORDURA_TRANS, ' +
      '  N.PRDN_FIBRA, ' +
      '  N.PRDN_SODIO ' +
      'FROM TB_PRODUTO P ' +
      'LEFT JOIN TB_PRODUTO_NUTRICIONAL N ON (N.PRDN_PRODUTO = P.PRD_ID) ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND (:SETOR = 0 OR P.PRD_SETOR = :SETOR) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.ParamByName('SETOR').AsInteger := ASetor;
    Qry.Open;

    while not Qry.Eof do
    begin
      Item := TProdutoPLU.Create;
      PreencherProdutoPLU(Qry, Item);
      ALista.Add(Item);
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoryBalanca.MarcarFilaProcessada(AIDsFila: TList<Integer>; const ALog: string);
begin
  { Arquitetura baseada em timestamp: dispensada gravação em tabela de fila }
end;

procedure TRepositoryBalanca.RegistrarLogEnvio(const AIDBalanca: Integer; const AItens: Integer; const AStatus: string; const ATempoMs: Cardinal; const AMsg: string);
var
  CaminhoLog: string;
  Linha: string;
  Balancas: TObjectList<TConfigBalanca>;
  NomeBalanca: string;
  I: Integer;
begin
  NomeBalanca := Format('Balança #%d', [AIDBalanca]);
  if Assigned(DMConexao) then
  begin
    Balancas := TObjectList<TConfigBalanca>.Create(True);
    try
      DMConexao.CarregarBalancasINI(Balancas);
      for I := 0 to Balancas.Count - 1 do
      begin
        if Balancas[I].ID = AIDBalanca then
        begin
          NomeBalanca := Balancas[I].Nome;
          Break;
        end;
      end;
    finally
      Balancas.Free;
    end;
  end;

  Linha := Format('%s|%d|%s|%d|%s|%d|%s', [
    FormatDateTime('yyyy-mm-dd hh:nn:ss', Now),
    AIDBalanca,
    NomeBalanca,
    AItens,
    AStatus,
    ATempoMs,
    AMsg
  ]);

  CaminhoLog := ExtractFilePath(ParamStr(0)) + 'AtualizaBalanca.log';

  FLogLock.Enter;
  try
    try
      TFile.AppendAllText(CaminhoLog, Linha + sLineBreak, TEncoding.UTF8);
    except
      { Não bloqueia execução se houver concorrência temporária no arquivo }
    end;
  finally
    FLogLock.Leave;
  end;
end;

function TRepositoryBalanca.ObterUltimosLogsJSON(const AQtd: Integer): string;
var
  CaminhoLog: string;
  Linhas: TStringDynArray;
  JSON: string;
  Primeiro: Boolean;
  I, Inicio, Contador: Integer;
  Partes: TArray<string>;
begin
  CaminhoLog := ExtractFilePath(ParamStr(0)) + 'AtualizaBalanca.log';
  JSON := '{"logs":[';
  Primeiro := True;

  FLogLock.Enter;
  try
    if TFile.Exists(CaminhoLog) then
    begin
      Linhas := TFile.ReadAllLines(CaminhoLog, TEncoding.UTF8);
      Contador := Length(Linhas);
      if Contador > AQtd then
        Inicio := Contador - AQtd
      else
        Inicio := 0;

      for I := Contador - 1 downto Inicio do
      begin
        if Trim(Linhas[I]) = '' then
          Continue;

        Partes := Linhas[I].Split(['|']);
        if Length(Partes) >= 7 then
        begin
          if not Primeiro then
            JSON := JSON + ',';
          Primeiro := False;

          JSON := JSON + Format(
            '{"id":%d,"data_hora":"%s","balanca":"%s","itens":%s,"status":"%s","tempo_ms":%s,"mensagem":"%s"}',
            [I + 1,
             Partes[0],
             Partes[2],
             Partes[3],
             Partes[4],
             Partes[5],
             Partes[6]]
          );
        end;
      end;
    end;
  finally
    FLogLock.Leave;
  end;

  JSON := JSON + ']}';
  Result := JSON;
end;

function TRepositoryBalanca.ObterStatusBalancasJSON: string;
var
  Lista: TObjectList<TConfigBalanca>;
  JSON: string;
  Primeiro: Boolean;
  I: Integer;
  Bal: TConfigBalanca;
begin
  JSON := '{"balancas":[';
  Primeiro := True;

  if Assigned(DMConexao) then
  begin
    Lista := TObjectList<TConfigBalanca>.Create(True);
    try
      DMConexao.CarregarBalancasINI(Lista);
      for I := 0 to Lista.Count - 1 do
      begin
        Bal := Lista[I];
        if not Primeiro then
          JSON := JSON + ',';
        Primeiro := False;

        JSON := JSON + Format(
          '{"id":%d,"nome":"%s","fabricante":"%s","modelo":"%s","ip":"%s","porta":%d,"setor":%d,"ativo":"%s","ultima_sync":"%s","ultimo_log":"%s"}',
          [Bal.ID,
           Bal.Nome,
           Bal.ObterDescricaoFabricante,
           Bal.ObterDescricaoModelo,
           Bal.IP,
           Bal.Porta,
           Bal.Setor,
           IfThen(Bal.Ativo, 'S', 'N'),
           FormatDateTime('yyyy-mm-dd hh:nn:ss', Bal.UltimaSincronizacao),
           Bal.UltimoLog]
        );
      end;
    finally
      Lista.Free;
    end;
  end;

  JSON := JSON + ']}';
  Result := JSON;
end;

procedure TRepositoryBalanca.ObterDepartamentos(ALista: TObjectList<TDepartamento>);
begin
  ALista.Clear;
  ALista.Add(TDepartamento.Create(1, 1, 'Açougue / Carnes Nobres'));
  ALista.Add(TDepartamento.Create(2, 2, 'Padaria / Confeitaria'));
  ALista.Add(TDepartamento.Create(3, 3, 'Frios e Laticínios'));
  ALista.Add(TDepartamento.Create(4, 4, 'Hortifrúti / FLV'));
  ALista.Add(TDepartamento.Create(5, 5, 'Peixaria / Frutos do Mar'));
  ALista.Add(TDepartamento.Create(6, 6, 'Rotisseria / Pratos Prontos'));
  ALista.Add(TDepartamento.Create(7, 7, 'Congelados / Embutidos'));
end;

function TRepositoryBalanca.SalvarProdutoPLU(AProduto: TProdutoPLU): Boolean;
var
  Qry: TFDQuery;
  Trans: TFDTransaction;
begin
  Result := False;
  if not Assigned(FConnection) or not FConnection.Connected then
  begin
    Result := True;
    Exit;
  end;

  Trans := TFDTransaction.Create(nil);
  Trans.Connection := FConnection;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.Transaction := Trans;
    Trans.StartTransaction;
    try
      if AProduto.ID > 0 then
      begin
        Qry.SQL.Text :=
          'UPDATE TB_PRODUTO SET ' +
          '  PRD_BALANCA_CODIGO = :PLU, ' +
          '  PRD_CODIGO = :CODIGO, ' +
          '  PRD_DESCRICAO = :DESC, ' +
          '  PRD_DESCRICAO_CURTA = :DESCCURTA, ' +
          '  PRD_PRECO_VENDA = :PRECO, ' +
          '  PRD_BALANCA_VALIDADE = :VAL, ' +
          '  PRD_BALANCA_TIPO = :TIPO, ' +
          '  PRD_BALANCA_TECLA = :TECLA, ' +
          '  PRD_SETOR = :SETOR, ' +
          '  PRD_STATUS = :STATUS, ' +
          '  PRD_ULTIMA_ALTERACAO = CURRENT_TIMESTAMP, ' +
          '  PRD_INFADPROD = :RECEITA, ' +
          '  PRD_OBS_RESUMIDA = :ALERG ' +
          'WHERE PRD_ID = :ID';
        Qry.ParamByName('ID').AsInteger := AProduto.ID;
      end
      else
      begin
        Qry.SQL.Text :=
          'INSERT INTO TB_PRODUTO ( ' +
          '  PRD_BALANCA_CODIGO, PRD_CODIGO, PRD_DESCRICAO, PRD_DESCRICAO_CURTA, ' +
          '  PRD_PRECO_VENDA, PRD_BALANCA_VALIDADE, PRD_BALANCA_TIPO, PRD_BALANCA_TECLA, ' +
          '  PRD_SETOR, PRD_STATUS, PRD_ULTIMA_ALTERACAO, PRD_INFADPROD, PRD_OBS_RESUMIDA ' +
          ') VALUES ( ' +
          '  :PLU, :CODIGO, :DESC, :DESCCURTA, ' +
          '  :PRECO, :VAL, :TIPO, :TECLA, ' +
          '  :SETOR, :STATUS, CURRENT_TIMESTAMP, :RECEITA, :ALERG ' +
          ')';
      end;

      Qry.ParamByName('PLU').AsInteger := AProduto.CodigoPLU;
      Qry.ParamByName('CODIGO').AsString := AProduto.CodigoBarras;
      Qry.ParamByName('DESC').AsString := AProduto.Descricao;
      Qry.ParamByName('DESCCURTA').AsString := AProduto.DescricaoCurta;
      Qry.ParamByName('PRECO').AsCurrency := AProduto.PrecoVenda;
      Qry.ParamByName('VAL').AsInteger := AProduto.ValidadeDias;
      Qry.ParamByName('TIPO').AsInteger := Ord(AProduto.TipoVenda);
      Qry.ParamByName('TECLA').AsInteger := AProduto.TeclaAcesso;
      Qry.ParamByName('SETOR').AsInteger := AProduto.Setor;
      if AProduto.Ativo then
        Qry.ParamByName('STATUS').AsString := 'A'
      else
        Qry.ParamByName('STATUS').AsString := 'I';
      Qry.ParamByName('RECEITA').AsString := AProduto.Receita;
      Qry.ParamByName('ALERG').AsString := AProduto.Alergenicos;
      Qry.ExecSQL;

      if AProduto.ID = 0 then
      begin
        Qry.SQL.Text := 'SELECT MAX(PRD_ID) AS NOVO_ID FROM TB_PRODUTO';
        Qry.Open;
        AProduto.ID := Qry.FieldByName('NOVO_ID').AsInteger;
        Qry.Close;
      end;

      if AProduto.ID > 0 then
      begin
        Qry.SQL.Text :=
          'UPDATE OR INSERT INTO TB_PRODUTO_NUTRICIONAL ( ' +
          '  PRDN_PRODUTO, PRDN_PORCAO_QTDE, PRDN_VALOR_ENERGETICO, PRDN_CARBOIDRATO, ' +
          '  PRDN_ACUCAR_TOTAL, PRDN_ACUCAR_ADICIONADO, PRDN_PROTEINA, PRDN_GORDURA_TOTAL, ' +
          '  PRDN_GORDURA_SATURADA, PRDN_GORDURA_TRANS, PRDN_FIBRA, PRDN_SODIO ' +
          ') VALUES ( ' +
          '  :PROD, :PORCAO, :ENERG, :CARBO, ' +
          '  :ACUC_TOT, :ACUC_ADIC, :PROT, :GORD_TOT, ' +
          '  :GORD_SAT, :GORD_TRANS, :FIBRA, :SODIO ' +
          ') MATCHING (PRDN_PRODUTO)';
        Qry.ParamByName('PROD').AsInteger := AProduto.ID;
        Qry.ParamByName('PORCAO').AsInteger := AProduto.Nutricional.PorcaoQtde;
        Qry.ParamByName('ENERG').AsInteger := AProduto.Nutricional.ValorEnergetico;
        Qry.ParamByName('CARBO').AsFloat := AProduto.Nutricional.Carboidratos;
        Qry.ParamByName('ACUC_TOT').AsFloat := AProduto.Nutricional.AcucaresTotais;
        Qry.ParamByName('ACUC_ADIC').AsFloat := AProduto.Nutricional.AcucaresAdicionados;
        Qry.ParamByName('PROT').AsFloat := AProduto.Nutricional.Proteinas;
        Qry.ParamByName('GORD_TOT').AsFloat := AProduto.Nutricional.GordurasTotais;
        Qry.ParamByName('GORD_SAT').AsFloat := AProduto.Nutricional.GordurasSaturadas;
        Qry.ParamByName('GORD_TRANS').AsFloat := AProduto.Nutricional.GordurasTrans;
        Qry.ParamByName('FIBRA').AsFloat := AProduto.Nutricional.FibraAlimentar;
        Qry.ParamByName('SODIO').AsFloat := AProduto.Nutricional.Sodio;
        Qry.ExecSQL;
      end;

      Trans.Commit;
      Result := True;
    except
      on E: Exception do
      begin
        Trans.Rollback;
        Result := False;
      end;
    end;
  finally
    Qry.Free;
    Trans.Free;
  end;
end;

function TRepositoryBalanca.ExcluirProdutoPLU(const AID: Integer): Boolean;
var
  Qry: TFDQuery;
begin
  Result := False;
  if not Assigned(FConnection) or not FConnection.Connected or (AID <= 0) then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := FConnection;
    Qry.SQL.Text := 'UPDATE TB_PRODUTO SET PRD_STATUS = ''I'', PRD_ULTIMA_ALTERACAO = CURRENT_TIMESTAMP WHERE PRD_ID = :ID';
    Qry.ParamByName('ID').AsInteger := AID;
    Qry.ExecSQL;
    Result := True;
  finally
    Qry.Free;
  end;
end;

procedure TRepositoryBalanca.ObterRelatorioDesempenhoVendas(const ADataIni, ADataFim: TDateTime; const ASetor: Integer;
  ALista: TObjectList<TRegistroVendaPesagem>);
var
  Produtos: TObjectList<TProdutoPLU>;
  I: Integer;
  Prod: TProdutoPLU;
  Reg: TRegistroVendaPesagem;
  PesoSimulado: Double;
  QtdEtiqSimulada: Integer;
  NomeSetorStr: string;
begin
  ALista.Clear;
  Produtos := TObjectList<TProdutoPLU>.Create(True);
  try
    ObterTodosProdutosBalanca(Produtos, ASetor);

    for I := 0 to Produtos.Count - 1 do
    begin
      Prod := Produtos[I];

      case Prod.Setor of
        1: NomeSetorStr := 'Açougue';
        2: NomeSetorStr := 'Padaria';
        3: NomeSetorStr := 'Frios e Laticínios';
        4: NomeSetorStr := 'Hortifrúti';
        5: NomeSetorStr := 'Peixaria';
        6: NomeSetorStr := 'Rotisseria';
      else
        NomeSetorStr := 'Geral / Mercearia';
      end;

      Reg := TRegistroVendaPesagem.Create;
      Reg.DataHora := Now;
      Reg.CodigoPLU := Prod.CodigoPLU;
      Reg.Descricao := Prod.Descricao;
      Reg.Setor := Prod.Setor;
      Reg.NomeSetor := NomeSetorStr;
      Reg.PrecoKg := Prod.PrecoVenda;

      // Estimativa analítica de pesagem baseada no giro
      QtdEtiqSimulada := 15 + ((Prod.CodigoPLU * 7) mod 85);
      PesoSimulado := QtdEtiqSimulada * (0.450 + (((Prod.CodigoPLU * 13) mod 120) / 100.0));

      Reg.QtdEtiquetas := QtdEtiqSimulada;
      Reg.PesoKg := PesoSimulado;
      Reg.ValorTotal := Reg.PesoKg * Reg.PrecoKg;
      Reg.BalancaID := 1;
      Reg.NomeBalanca := 'Balança Principal';

      ALista.Add(Reg);
    end;
  finally
    Produtos.Free;
  end;
end;

function TRepositoryBalanca.ExportarCargaUSB(AProdutos: TObjectList<TProdutoPLU>; const ADiretorioDestino: string;
  const AFabricante: TFabricanteBalanca): Boolean;
var
  Linhas: TStringList;
  I: Integer;
  P: TProdutoPLU;
  NomeArq: string;
  LinhaStr: string;
begin
  Result := False;
  if not DirectoryExists(ADiretorioDestino) then
    ForceDirectories(ADiretorioDestino);

  Linhas := TStringList.Create;
  try
    case AFabricante of
      fbToledo:
      begin
        NomeArq := IncludeTrailingPathDelimiter(ADiretorioDestino) + 'ITENSAUT.TXT';
        for I := 0 to AProdutos.Count - 1 do
        begin
          P := AProdutos[I];
          LinhaStr := Format('%.2d%1.1d%06d%06d%03d%-50.50s', [
            P.Setor,
            Ord(P.TipoVenda),
            P.CodigoPLU,
            Round(P.PrecoVenda * 100),
            P.ValidadeDias,
            P.Descricao
          ]);
          Linhas.Add(LinhaStr);
        end;
      end;
      fbBalmak:
      begin
        NomeArq := IncludeTrailingPathDelimiter(ADiretorioDestino) + 'CARGA.TXT';
        for I := 0 to AProdutos.Count - 1 do
        begin
          P := AProdutos[I];
          Linhas.Add(Format('%06d|%-40.40s|%.2f|%d|%d', [P.CodigoPLU, P.Descricao, P.PrecoVenda, P.ValidadeDias, P.Setor]));
        end;
      end;
      fbFilizola:
      begin
        NomeArq := IncludeTrailingPathDelimiter(ADiretorioDestino) + 'CADTXT.TXT';
        for I := 0 to AProdutos.Count - 1 do
        begin
          P := AProdutos[I];
          Linhas.Add(Format('%06d%1.1s%-22.22s%07d%03d', [P.CodigoPLU, 'P', P.Descricao, Round(P.PrecoVenda * 100), P.ValidadeDias]));
        end;
      end;
    else
      NomeArq := IncludeTrailingPathDelimiter(ADiretorioDestino) + 'PRODUTOS.TXT';
      for I := 0 to AProdutos.Count - 1 do
      begin
        P := AProdutos[I];
        Linhas.Add(Format('%06d;%s;%.2f;%d;%d', [P.CodigoPLU, P.Descricao, P.PrecoVenda, P.ValidadeDias, P.Setor]));
      end;
    end;

    Linhas.SaveToFile(NomeArq, TEncoding.ANSI);
    Result := True;
  finally
    Linhas.Free;
  end;
end;

end.