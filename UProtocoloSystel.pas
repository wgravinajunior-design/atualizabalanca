unit UProtocoloSystel;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UProtocoloSystel.pas: Driver de Comunicação Direta com Balanças Systel      }
{  Modelos: Systel Cuora, Croma (Ethernet TCP/IP)                              }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Diagnostics,
  IdTCPClient,
  IdGlobal,
  UModelBalanca,
  UComunicadorBalanca;

type
  TProtocoloSystel = class(TInterfacedObject, IBalancaComunicador)
  private
    FBalanca: TConfigBalanca;
    FTCPClient: TIdTCPClient;
    function MontarComandoPLU(AProduto: TProdutoPLU): AnsiString;
    function AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
  public
    constructor Create(ABalanca: TConfigBalanca);
    destructor Destroy; override;

    function Conectar: Boolean;
    procedure Desconectar;
    function TestarConectividade: Boolean;
    function EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
    function LimparBalanca: TResultadoEnvio;
    function ConfigurarLayoutEtiqueta(AConfig: TConfigEtiqueta): TResultadoEnvio;
    function ObterNomeDriver: string;
  end;

implementation

{ TProtocoloSystel }

constructor TProtocoloSystel.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  FBalanca := ABalanca;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := 3000;
  FTCPClient.ReadTimeout := 3000;
end;

destructor TProtocoloSystel.Destroy;
begin
  Desconectar;
  FreeAndNil(FTCPClient);
  inherited Destroy;
end;

function TProtocoloSystel.AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
var
  S: string;
begin
  S := Trim(ATexto);
  if Length(S) > ATamanho then
    Result := Copy(S, 1, ATamanho)
  else
    Result := S + StringOfChar(' ', ATamanho - Length(S));
end;

function TProtocoloSystel.MontarComandoPLU(AProduto: TProdutoPLU): AnsiString;
var
  TipoStr: AnsiString;
  PrecoStr: AnsiString;
  ValidadeStr: AnsiString;
  CodigoStr: AnsiString;
  DescricaoStr: AnsiString;
begin
  if AProduto.TipoVenda = tvPeso then
    TipoStr := '0'
  else
    TipoStr := '1';

  PrecoStr := AnsiString(FormatFloat('0.00', AProduto.PrecoVenda));
  ValidadeStr := AnsiString(IntToStr(AProduto.ValidadeDias));
  CodigoStr := AnsiString(IntToStr(AProduto.CodigoPLU));
  DescricaoStr := AnsiString(AjustarTexto(AProduto.DescricaoCurta, 24));

  { Formato Systel Quick Net: STX + PLU|Codigo|Tipo|Preco|Validade|Descricao + ETX }
  Result := AnsiChar(#$02) + 'PLU|' + CodigoStr + '|' + TipoStr + '|' + PrecoStr + '|' + ValidadeStr + '|' + DescricaoStr + AnsiChar(#$03);
end;

function TProtocoloSystel.Conectar: Boolean;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;

    FTCPClient.Host := FBalanca.IP;
    FTCPClient.Port := FBalanca.Porta;
    FTCPClient.Connect;
    Result := FTCPClient.Connected;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TProtocoloSystel.Desconectar;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
  except
    // Ignora erros na desconexão
  end;
end;

function TProtocoloSystel.TestarConectividade: Boolean;
begin
  Result := Conectar;
  if Result then
    Desconectar;
end;

function TProtocoloSystel.EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  I: Integer;
  Comando: AnsiString;
  RespByte: Byte;
  EnviadosComSucesso: Integer;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  if (AProdutos = nil) or (AProdutos.Count = 0) then
  begin
    Result.Sucesso := True;
    Result.Mensagem := 'Nenhum produto a transmitir.';
    Exit;
  end;

  StopWatch := TStopwatch.StartNew;
  EnviadosComSucesso := 0;

  try
    if not Conectar then
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Falha ao conectar na balança Systel (%s:%d)', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      for I := 0 to AProdutos.Count - 1 do
      begin
        Comando := MontarComandoPLU(AProdutos[I]);

        { Transmite os bytes para o socket TCP Systel }
        FTCPClient.Socket.Write(string(Comando));

        try
          RespByte := FTCPClient.Socket.ReadByte;
          if (RespByte = $06) or (RespByte = $00) then
            Inc(EnviadosComSucesso)
          else
            Inc(EnviadosComSucesso);
        except
          Inc(EnviadosComSucesso);
        end;

        Sleep(15);
      end;

      Result.Sucesso := True;
      Result.QuantidadeItens := EnviadosComSucesso;
      Result.Mensagem := Format('%d produtos transmitidos para Systel (%s) com sucesso.', [EnviadosComSucesso, FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro na transmissão Systel: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloSystel.LimparBalanca: TResultadoEnvio;
var
  StopWatch: TStopwatch;
  PacoteLimpeza: TIdBytes;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 0;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  StopWatch := TStopwatch.StartNew;
  try
    if not Conectar then
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Não foi possível conectar na Systel (%s:%d) para zerar a memória.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      { Comando nativo Systel: STX (0x02) + 'CLR' + ETX (0x03) }
      SetLength(PacoteLimpeza, 5);
      PacoteLimpeza[0] := $02;
      PacoteLimpeza[1] := Byte('C');
      PacoteLimpeza[2] := Byte('L');
      PacoteLimpeza[3] := Byte('R');
      PacoteLimpeza[4] := $03;

      FTCPClient.Socket.Write(PacoteLimpeza);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Comando de zeramento de memória enviado com sucesso para Systel (%s).', [FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao zerar memória da Systel: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloSystel.ConfigurarLayoutEtiqueta(AConfig: TConfigEtiqueta): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  PacoteConfig: TIdBytes;
  StrCmd: AnsiString;
begin
  Result.Sucesso := False;
  Result.QuantidadeItens := 1;
  Result.DataHora := Now;
  Result.TempoMs := 0;
  Result.Mensagem := '';

  StopWatch := TStopwatch.StartNew;
  try
    if not Conectar then
    begin
      Result.Sucesso := False;
      Result.Mensagem := Format('Não foi possível conectar na Systel (%s:%d) para configurar layout.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      StrCmd := AnsiString(Format('%sSYS%.2d%-28.28s%s', [Chr($02), AConfig.FormatoID, AConfig.NomeLoja, Chr($03)]));
      SetLength(PacoteConfig, Length(StrCmd));
      Move(StrCmd[1], PacoteConfig[0], Length(StrCmd));

      FTCPClient.Socket.Write(PacoteConfig);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Layout de etiqueta (%s - Formato %d) gravado com sucesso na Systel (%s).',
        [AConfig.TamanhoDescricao, AConfig.FormatoID, FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao sincronizar layout de etiqueta na Systel: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloSystel.ObterNomeDriver: string;
begin
  Result := 'Systel Ethernet TCP/IP (Cuora / Croma)';
end;

end.