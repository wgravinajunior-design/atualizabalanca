unit UProtocoloFilizola;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UProtocoloFilizola.pas: Driver de Comunicação Direta com Filizola Platina   }
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
  TProtocoloFilizola = class(TInterfacedObject, IBalancaComunicador)
  private
    FBalanca: TConfigBalanca;
    FTCPClient: TIdTCPClient;
    function CalcularChecksumBCC(const ADados: TIdBytes): Byte;
    function MontarPacotePLU(AProduto: TProdutoPLU): TIdBytes;
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
    procedure GerarArquivoCargaPlatina(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
  end;

implementation

{ TProtocoloFilizola }

constructor TProtocoloFilizola.Create(ABalanca: TConfigBalanca);
begin
  inherited Create;
  FBalanca := ABalanca;
  FTCPClient := TIdTCPClient.Create(nil);
  FTCPClient.ConnectTimeout := 3000;
  FTCPClient.ReadTimeout := 3000;
end;

destructor TProtocoloFilizola.Destroy;
begin
  Desconectar;
  FreeAndNil(FTCPClient);
  inherited Destroy;
end;

function TProtocoloFilizola.AjustarTexto(const ATexto: string; const ATamanho: Integer): string;
var
  S: string;
begin
  S := Trim(ATexto);
  if Length(S) > ATamanho then
    Result := Copy(S, 1, ATamanho)
  else
    Result := S + StringOfChar(' ', ATamanho - Length(S));
end;

function TProtocoloFilizola.CalcularChecksumBCC(const ADados: TIdBytes): Byte;
var
  I: Integer;
  Soma: Cardinal;
begin
  Soma := 0;
  for I := 0 to Length(ADados) - 1 do
    Soma := Soma + ADados[I];
  Result := Byte(Soma mod 256);
end;

function TProtocoloFilizola.MontarPacotePLU(AProduto: TProdutoPLU): TIdBytes;
var
  StrPayload: AnsiString;
  TipoChar: AnsiChar;
  PrecoCentavos: Integer;
  StrPreco: AnsiString;
  StrValidade: AnsiString;
  StrCodigo: AnsiString;
  StrDescricao: AnsiString;
  PayloadBytes: TIdBytes;
  BCC: Byte;
  Idx: Integer;
begin
  if AProduto.TipoVenda = tvPeso then
    TipoChar := '0'
  else
    TipoChar := '1';

  PrecoCentavos := Round(AProduto.PrecoVenda * 100);
  StrPreco := AnsiString(Format('%.6d', [PrecoCentavos]));
  StrValidade := AnsiString(Format('%.3d', [AProduto.ValidadeDias]));
  StrCodigo := AnsiString(Format('%.6d', [AProduto.CodigoPLU]));
  StrDescricao := AnsiString(AjustarTexto(AProduto.DescricaoCurta, 20));

  { Comando Filizola: 'C' + Código(6) + Tipo(1) + Preço(6) + Validade(3) + Descrição(20) }
  StrPayload := 'C' + StrCodigo + TipoChar + StrPreco + StrValidade + StrDescricao;

  SetLength(PayloadBytes, Length(StrPayload));
  for Idx := 1 to Length(StrPayload) do
    PayloadBytes[Idx - 1] := Byte(StrPayload[Idx]);

  BCC := CalcularChecksumBCC(PayloadBytes);

  { Pacote: STX (0x02) + Payload + ETX (0x03) + Checksum BCC }
  SetLength(Result, Length(PayloadBytes) + 3);
  Result[0] := $02; { STX }
  for Idx := 0 to Length(PayloadBytes) - 1 do
    Result[Idx + 1] := PayloadBytes[Idx];
  Result[Length(Result) - 2] := $03; { ETX }
  Result[Length(Result) - 1] := BCC;
end;

function TProtocoloFilizola.Conectar: Boolean;
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

procedure TProtocoloFilizola.Desconectar;
begin
  try
    if FTCPClient.Connected then
      FTCPClient.Disconnect;
  except
    // Ignora erros na desconexão
  end;
end;

function TProtocoloFilizola.TestarConectividade: Boolean;
begin
  Result := Conectar;
  if Result then
    Desconectar;
end;

function TProtocoloFilizola.EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
var
  StopWatch: TStopwatch;
  I: Integer;
  Pacote: TIdBytes;
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
      Result.Mensagem := Format('Falha ao conectar na Filizola Platina (%s:%d)', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      for I := 0 to AProdutos.Count - 1 do
      begin
        Pacote := MontarPacotePLU(AProdutos[I]);

        { Transmite os bytes para a porta TCP da Filizola }
        FTCPClient.Socket.Write(Pacote);

        { Aguarda resposta ACK/NAK }
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
      Result.Mensagem := Format('%d produtos transmitidos para Filizola Platina com sucesso.', [EnviadosComSucesso]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Erro na transmissão Filizola: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

procedure TProtocoloFilizola.GerarArquivoCargaPlatina(AProdutos: TObjectList<TProdutoPLU>; const ACaminhoArquivo: string);
var
  SL: TStringList;
  I: Integer;
  P: TProdutoPLU;
  TipoStr: string;
  PrecoStr: string;
  Linha: string;
begin
  SL := TStringList.Create;
  try
    for I := 0 to AProdutos.Count - 1 do
    begin
      P := AProdutos[I];
      if P.TipoVenda = tvPeso then
        TipoStr := 'P'
      else
        TipoStr := 'U';

      PrecoStr := FormatFloat('000000', Round(P.PrecoVenda * 100));
      Linha := Format('%.6d', [P.CodigoPLU]) + TipoStr + AjustarTexto(P.DescricaoCurta, 20) + PrecoStr + Format('%.3d', [P.ValidadeDias]);
      SL.Add(Linha);
    end;
    SL.SaveToFile(ACaminhoArquivo, TEncoding.ANSI);
  finally
    SL.Free;
  end;
end;

function TProtocoloFilizola.LimparBalanca: TResultadoEnvio;
var
  StopWatch: TStopwatch;
  PacoteLimpeza: TIdBytes;
  BCC: Byte;
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
      Result.Mensagem := Format('Não foi possível conectar na Filizola Platina (%s:%d) para zerar a memória.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      { Comando nativo Filizola Platina: STX (0x02) + 'Z' + ETX (0x03) + BCC }
      SetLength(PacoteLimpeza, 4);
      PacoteLimpeza[0] := $02;
      PacoteLimpeza[1] := Byte('Z');
      PacoteLimpeza[2] := $03;
      BCC := Byte('Z') xor $03;
      PacoteLimpeza[3] := BCC;

      FTCPClient.Socket.Write(PacoteLimpeza);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Comando de zeramento de memória enviado com sucesso para Filizola Platina (%s).', [FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao zerar memória da Filizola: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloFilizola.ConfigurarLayoutEtiqueta(AConfig: TConfigEtiqueta): TResultadoEnvio;
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
      Result.Mensagem := Format('Não foi possível conectar na Filizola (%s:%d) para configurar layout.', [FBalanca.IP, FBalanca.Porta]);
      Exit;
    end;

    try
      StrCmd := AnsiString(Format('%sFMT%.2d%-28.28s%s', [Chr($02), AConfig.FormatoID, AConfig.NomeLoja, Chr($03)]));
      SetLength(PacoteConfig, Length(StrCmd));
      Move(StrCmd[1], PacoteConfig[0], Length(StrCmd));

      FTCPClient.Socket.Write(PacoteConfig);
      Sleep(100);

      Result.Sucesso := True;
      Result.Mensagem := Format('Layout de etiqueta (%s - Formato %d) gravado com sucesso na Filizola (%s).',
        [AConfig.TamanhoDescricao, AConfig.FormatoID, FBalanca.IP]);
    finally
      Desconectar;
    end;
  except
    on E: Exception do
    begin
      Result.Sucesso := False;
      Result.Mensagem := 'Falha ao sincronizar layout de etiqueta na Filizola: ' + E.Message;
    end;
  end;

  StopWatch.Stop;
  Result.TempoMs := StopWatch.ElapsedMilliseconds;
end;

function TProtocoloFilizola.ObterNomeDriver: string;
begin
  Result := 'Filizola Platina / Platina Plus (Ethernet TCP/IP)';
end;

end.