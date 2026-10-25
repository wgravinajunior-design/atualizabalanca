unit UServidorRest;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UServidorRest.pas: Micro-API REST Embutida para Integração com o ERP        }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  IdHTTPServer,
  IdCustomHTTPServer,
  IdContext,
  IdGlobal,
  IdSocketHandle,
  UModelBalanca;

type
  TOnRequisicaoSincronizacao = function(const ATotal: Boolean): string of object;
  TOnObterStatusJSON = function: string of object;
  TOnObterLogsJSON = function: string of object;

  TServidorRest = class
  private
    FServer: TIdHTTPServer;
    FPorta: Integer;
    FAtivo: Boolean;
    FUltimoErro: string;

    FOnSincronizar: TOnRequisicaoSincronizacao;
    FOnObterStatus: TOnObterStatusJSON;
    FOnObterLogs: TOnObterLogsJSON;

    procedure OnCommandGetHandler(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
  public
    constructor Create(const APorta: Integer = 8085);
    destructor Destroy; override;

    function Iniciar: Boolean;
    procedure Parar;

    property Porta: Integer read FPorta write FPorta;
    property Ativo: Boolean read FAtivo;
    property UltimoErro: string read FUltimoErro;

    property OnSincronizar: TOnRequisicaoSincronizacao read FOnSincronizar write FOnSincronizar;
    property OnObterStatus: TOnObterStatusJSON read FOnObterStatus write FOnObterStatus;
    property OnObterLogs: TOnObterLogsJSON read FOnObterLogs write FOnObterLogs;
  end;

implementation

{ TServidorRest }

constructor TServidorRest.Create(const APorta: Integer);
begin
  inherited Create;
  FPorta := APorta;
  FAtivo := False;
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := FPorta;
  FServer.OnCommandGet := OnCommandGetHandler;
  FServer.KeepAlive := True;
end;

destructor TServidorRest.Destroy;
begin
  Parar;
  FreeAndNil(FServer);
  inherited Destroy;
end;

function TServidorRest.Iniciar: Boolean;
var
  Binding: TIdSocketHandle;
begin
  Result := False;
  FUltimoErro := '';
  try
    if FServer.Active then
      FServer.Active := False;

    FServer.DefaultPort := FPorta;
    FServer.Bindings.Clear;
    Binding := FServer.Bindings.Add;
    Binding.IP := '0.0.0.0';
    Binding.Port := FPorta;

    FServer.Active := True;
    FAtivo := FServer.Active;
    Result := FAtivo;
  except
    on E: Exception do
    begin
      FUltimoErro := E.Message;
      FAtivo := False;
    end;
  end;
end;

procedure TServidorRest.Parar;
begin
  try
    if FServer.Active then
      FServer.Active := False;
  except
    // Ignora erros ao parar o servidor HTTP
  end;
  FAtivo := False;
end;

procedure TServidorRest.OnCommandGetHandler(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  Doc: string;
  Metodo: string;
  RespostaJson: string;
begin
  { Configura cabeçalhos de resposta HTTP com suporte a CORS }
  AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Origin', '*');
  AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  AResponseInfo.CustomHeaders.AddValue('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  AResponseInfo.ContentType := 'application/json; charset=utf-8';

  Doc := LowerCase(Trim(ARequestInfo.Document));
  Metodo := UpperCase(Trim(ARequestInfo.Command));

  { Trata requisições OPTIONS pré-voo de navegadores }
  if Metodo = 'OPTIONS' then
  begin
    AResponseInfo.ResponseNo := 200;
    AResponseInfo.ContentText := '';
    Exit;
  end;

  try
    if (Doc = '/') or (Doc = '/status') then
    begin
      if Assigned(FOnObterStatus) then
        RespostaJson := FOnObterStatus
      else
        RespostaJson := '{"sistema":"GoUp AtualizaBalanca","status":"online"}';

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := RespostaJson;
    end
    else if (Doc = '/sincronizar') and (Metodo = 'POST') then
    begin
      if Assigned(FOnSincronizar) then
        RespostaJson := FOnSincronizar(False)
      else
        RespostaJson := '{"sucesso":true,"mensagem":"Sincronizacao disparada com sucesso."}';

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := RespostaJson;
    end
    else if (Doc = '/carga-total') and (Metodo = 'POST') then
    begin
      if Assigned(FOnSincronizar) then
        RespostaJson := FOnSincronizar(True)
      else
        RespostaJson := '{"sucesso":true,"mensagem":"Carga total disparada com sucesso."}';

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := RespostaJson;
    end
    else if Doc = '/logs' then
    begin
      if Assigned(FOnObterLogs) then
        RespostaJson := FOnObterLogs
      else
        RespostaJson := '{"logs":[]}';

      AResponseInfo.ResponseNo := 200;
      AResponseInfo.ContentText := RespostaJson;
    end
    else
    begin
      AResponseInfo.ResponseNo := 404;
      AResponseInfo.ContentText := '{"erro":"Endpoint nao encontrado. Utilize /status, /sincronizar, /carga-total ou /logs"}';
    end;
  except
    on E: Exception do
    begin
      AResponseInfo.ResponseNo := 500;
      AResponseInfo.ContentText := Format('{"erro":"Erro interno: %s"}', [E.Message]);
    end;
  end;
end;

end.