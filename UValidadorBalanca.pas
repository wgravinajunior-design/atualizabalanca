unit UValidadorBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UValidadorBalanca.pas: Diagnóstico e Validação de Cadastros de PLU e EAN-13}
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client;

type
  TValidadorBalanca = class
  public
    class function DetectarPLUsDuplicados(AConnection: TFDConnection; ALog: TStrings): Integer;
    class function DetectarProdutosSemPreco(AConnection: TFDConnection; ALog: TStrings): Integer;
    class function DetectarProdutosSemValidade(AConnection: TFDConnection; ALog: TStrings): Integer;
    class function DetectarProdutosSemCodigoBalanca(AConnection: TFDConnection; ALog: TStrings): Integer;
    class function ExecutarDiagnosticoCompleto(AConnection: TFDConnection; ALog: TStrings): Integer;
    class function ExportarDiagnosticoCSV(AConnection: TFDConnection; const ACaminhoArquivo: string; out ATotalInconsistencias: Integer): Boolean;
  end;

implementation

{ TValidadorBalanca }

class function TValidadorBalanca.DetectarPLUsDuplicados(AConnection: TFDConnection; ALog: TStrings): Integer;
var
  Qry: TFDQuery;
begin
  Result := 0;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := AConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  COUNT(*) AS TOTAL ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_STATUS = ''A'' ' +
      'GROUP BY P.PRD_BALANCA_CODIGO ' +
      'HAVING COUNT(*) > 1 ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(Result);
      if Assigned(ALog) then
        ALog.Add(Format('⚠️ [CONFLITO] Código PLU %d está duplicado em %d produtos ativos.',
          [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger, Qry.FieldByName('TOTAL').AsInteger]));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class function TValidadorBalanca.DetectarProdutosSemPreco(AConnection: TFDConnection; ALog: TStrings): Integer;
var
  Qry: TFDQuery;
begin
  Result := 0;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := AConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_PRECO_VENDA ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_PRECO_VENDA IS NULL OR P.PRD_PRECO_VENDA <= 0) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(Result);
      if Assigned(ALog) then
        ALog.Add(Format('❌ [PREÇO ZERADO] PLU %d (%s) está sem preço de venda ou com valor R$ 0,00.',
          [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger, Trim(Qry.FieldByName('PRD_DESCRICAO').AsString)]));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class function TValidadorBalanca.DetectarProdutosSemValidade(AConnection: TFDConnection; ALog: TStrings): Integer;
var
  Qry: TFDQuery;
begin
  Result := 0;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := AConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_BALANCA_CODIGO, ' +
      '  P.PRD_DESCRICAO ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO IS NOT NULL ' +
      '  AND P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_BALANCA_VALIDADE IS NULL OR P.PRD_BALANCA_VALIDADE = 0) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO ASC';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(Result);
      if Assigned(ALog) then
        ALog.Add(Format('ℹ️ [SEM VALIDADE] PLU %d (%s) está com 0 dias de validade.',
          [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger, Trim(Qry.FieldByName('PRD_DESCRICAO').AsString)]));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class function TValidadorBalanca.DetectarProdutosSemCodigoBalanca(AConnection: TFDConnection; ALog: TStrings): Integer;
var
  Qry: TFDQuery;
begin
  Result := 0;
  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := AConnection;
    Qry.SQL.Text :=
      'SELECT ' +
      '  P.PRD_ID, ' +
      '  P.PRD_CODIGO, ' +
      '  P.PRD_DESCRICAO, ' +
      '  P.PRD_PRECO_VENDA, ' +
      '  P.PRD_SETOR ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_BALANCA_CODIGO IS NULL OR P.PRD_BALANCA_CODIGO <= 0) ' +
      '  AND ((P.PRD_BALANCA_VALIDADE > 0) OR (P.PRD_BALANCA_TIPO IS NOT NULL) OR (P.PRD_SETOR > 0)) ' +
      'ORDER BY P.PRD_DESCRICAO ASC';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(Result);
      if Assigned(ALog) then
        ALog.Add(Format('⚠️ [FALTA PREENCHER CÓDIGO DA BALANÇA] Código ERP %s - %s (R$ %s) está ativo mas sem Código de Balança!',
          [Trim(Qry.FieldByName('PRD_CODIGO').AsString),
           Trim(Qry.FieldByName('PRD_DESCRICAO').AsString),
           FormatFloat('0.00', Qry.FieldByName('PRD_PRECO_VENDA').AsFloat)]));
      Qry.Next;
    end;
  finally
    Qry.Free;
  end;
end;

class function TValidadorBalanca.ExecutarDiagnosticoCompleto(AConnection: TFDConnection; ALog: TStrings): Integer;
var
  Duplicados, SemPreco, SemValidade, SemCodigoBalanca: Integer;
begin
  if not Assigned(AConnection) or not AConnection.Connected then
  begin
    if Assigned(ALog) then
    begin
      ALog.Clear;
      ALog.Add('❌ [ERRO] Conexão com o banco Firebird não está ativa.');
    end;
    Exit(0);
  end;

  if Assigned(ALog) then
  begin
    ALog.Clear;
    ALog.Add('================================================================');
    ALog.Add(' DIAGNÓSTICO DE INTEGRIDADE DOS CADASTROS DE BALANÇA');
    ALog.Add(' Data/Hora: ' + FormatDateTime('dd/mm/yyyy hh:nn:ss', Now));
    ALog.Add('================================================================');
  end;

  Duplicados := DetectarPLUsDuplicados(AConnection, ALog);
  SemPreco := DetectarProdutosSemPreco(AConnection, ALog);
  SemValidade := DetectarProdutosSemValidade(AConnection, ALog);
  SemCodigoBalanca := DetectarProdutosSemCodigoBalanca(AConnection, ALog);

  Result := Duplicados + SemPreco + SemCodigoBalanca;

  if Assigned(ALog) then
  begin
    ALog.Add('----------------------------------------------------------------');
    ALog.Add(Format('Resultado: %d PLUs duplicados, %d produtos sem preço, %d sem validade, %d sem código de balança.',
      [Duplicados, SemPreco, SemValidade, SemCodigoBalanca]));
    if Result = 0 then
      ALog.Add('✅ Sucesso: Nenhum erro crítico encontrado nos cadastros de balança!')
    else
      ALog.Add('⚠️ Atenção: Corrija os erros acima no ERP para evitar divergências nas balanças.');
    ALog.Add('================================================================');
  end;
end;

class function TValidadorBalanca.ExportarDiagnosticoCSV(AConnection: TFDConnection; const ACaminhoArquivo: string; out ATotalInconsistencias: Integer): Boolean;
var
  Qry: TFDQuery;
  Linhas: TStringList;
  Linha: string;
  PrecoStr: string;
begin
  Result := False;
  ATotalInconsistencias := 0;

  if not Assigned(AConnection) or not AConnection.Connected then
    Exit;

  Linhas := TStringList.Create;
  Qry := TFDQuery.Create(nil);
  try
    Qry.Connection := AConnection;

    Linhas.Add('TIPO_PROBLEMA;PLU_BALANCA;PRD_ID;DESCRICAO;PRECO_VENDA;VALIDADE_DIAS;SETOR;STATUS;ACAO_RECOMENDADA');

    Qry.SQL.Text :=
      'SELECT P.PRD_ID, P.PRD_BALANCA_CODIGO, P.PRD_DESCRICAO, P.PRD_PRECO_VENDA, ' +
      '       P.PRD_BALANCA_VALIDADE, P.PRD_SETOR, P.PRD_STATUS ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO IN ( ' +
      '  SELECT P2.PRD_BALANCA_CODIGO ' +
      '  FROM TB_PRODUTO P2 ' +
      '  WHERE P2.PRD_BALANCA_CODIGO > 0 AND P2.PRD_STATUS = ''A'' ' +
      '  GROUP BY P2.PRD_BALANCA_CODIGO ' +
      '  HAVING COUNT(*) > 1 ' +
      ') AND P.PRD_STATUS = ''A'' ' +
      'ORDER BY P.PRD_BALANCA_CODIGO, P.PRD_ID';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(ATotalInconsistencias);
      PrecoStr := FormatFloat('0.00', Qry.FieldByName('PRD_PRECO_VENDA').AsFloat);
      Linha := Format('CONFLITO DE PLU DUPLICADO;%d;%d;"%s";%s;%d;%d;%s;"Alterar o codigo de balanca no ERP pois ha outro produto com o mesmo PLU"',
        [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger,
         Qry.FieldByName('PRD_ID').AsInteger,
         StringReplace(Trim(Qry.FieldByName('PRD_DESCRICAO').AsString), '"', '""', [rfReplaceAll]),
         PrecoStr,
         Qry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger,
         Qry.FieldByName('PRD_SETOR').AsInteger,
         Qry.FieldByName('PRD_STATUS').AsString]);
      Linhas.Add(Linha);
      Qry.Next;
    end;
    Qry.Close;

    Qry.SQL.Text :=
      'SELECT P.PRD_ID, P.PRD_BALANCA_CODIGO, P.PRD_DESCRICAO, P.PRD_PRECO_VENDA, ' +
      '       P.PRD_BALANCA_VALIDADE, P.PRD_SETOR, P.PRD_STATUS ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_PRECO_VENDA IS NULL OR P.PRD_PRECO_VENDA <= 0) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(ATotalInconsistencias);
      PrecoStr := FormatFloat('0.00', Qry.FieldByName('PRD_PRECO_VENDA').AsFloat);
      Linha := Format('PRECO ZERADO OU NULO;%d;%d;"%s";%s;%d;%d;%s;"Cadastrar preco de venda valido no ERP para permitir a pesagem"',
        [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger,
         Qry.FieldByName('PRD_ID').AsInteger,
         StringReplace(Trim(Qry.FieldByName('PRD_DESCRICAO').AsString), '"', '""', [rfReplaceAll]),
         PrecoStr,
         Qry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger,
         Qry.FieldByName('PRD_SETOR').AsInteger,
         Qry.FieldByName('PRD_STATUS').AsString]);
      Linhas.Add(Linha);
      Qry.Next;
    end;
    Qry.Close;

    Qry.SQL.Text :=
      'SELECT P.PRD_ID, P.PRD_BALANCA_CODIGO, P.PRD_DESCRICAO, P.PRD_PRECO_VENDA, ' +
      '       P.PRD_BALANCA_VALIDADE, P.PRD_SETOR, P.PRD_STATUS ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_BALANCA_CODIGO > 0 ' +
      '  AND P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_BALANCA_VALIDADE IS NULL OR P.PRD_BALANCA_VALIDADE = 0) ' +
      'ORDER BY P.PRD_BALANCA_CODIGO';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(ATotalInconsistencias);
      PrecoStr := FormatFloat('0.00', Qry.FieldByName('PRD_PRECO_VENDA').AsFloat);
      Linha := Format('SEM PRAZO DE VALIDADE;%d;%d;"%s";%s;%d;%d;%s;"Informar os dias de validade caso o produto seja perecivel ou refrigerado"',
        [Qry.FieldByName('PRD_BALANCA_CODIGO').AsInteger,
         Qry.FieldByName('PRD_ID').AsInteger,
         StringReplace(Trim(Qry.FieldByName('PRD_DESCRICAO').AsString), '"', '""', [rfReplaceAll]),
         PrecoStr,
         Qry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger,
         Qry.FieldByName('PRD_SETOR').AsInteger,
         Qry.FieldByName('PRD_STATUS').AsString]);
      Linhas.Add(Linha);
      Qry.Next;
    end;
    Qry.Close;

    Qry.SQL.Text :=
      'SELECT P.PRD_ID, P.PRD_CODIGO, P.PRD_DESCRICAO, P.PRD_PRECO_VENDA, ' +
      '       P.PRD_BALANCA_VALIDADE, P.PRD_SETOR, P.PRD_STATUS ' +
      'FROM TB_PRODUTO P ' +
      'WHERE P.PRD_STATUS = ''A'' ' +
      '  AND (P.PRD_BALANCA_CODIGO IS NULL OR P.PRD_BALANCA_CODIGO <= 0) ' +
      '  AND ((P.PRD_BALANCA_VALIDADE > 0) OR (P.PRD_BALANCA_TIPO IS NOT NULL) OR (P.PRD_SETOR > 0)) ' +
      'ORDER BY P.PRD_DESCRICAO';
    Qry.Open;

    while not Qry.Eof do
    begin
      Inc(ATotalInconsistencias);
      PrecoStr := FormatFloat('0.00', Qry.FieldByName('PRD_PRECO_VENDA').AsFloat);
      Linha := Format('FALTA PREENCHER CODIGO BALANCA;0;%d;"%s";%s;%d;%d;%s;"Preencher o campo PRD_BALANCA_CODIGO no ERP para permitir a transmissao para a balanca"',
        [Qry.FieldByName('PRD_ID').AsInteger,
         StringReplace(Trim(Qry.FieldByName('PRD_DESCRICAO').AsString), '"', '""', [rfReplaceAll]),
         PrecoStr,
         Qry.FieldByName('PRD_BALANCA_VALIDADE').AsInteger,
         Qry.FieldByName('PRD_SETOR').AsInteger,
         Qry.FieldByName('PRD_STATUS').AsString]);
      Linhas.Add(Linha);
      Qry.Next;
    end;
    Qry.Close;

    Linhas.SaveToFile(ACaminhoArquivo, TEncoding.UTF8);
    Result := True;
  finally
    Qry.Free;
    Linhas.Free;
  end;
end;

end.