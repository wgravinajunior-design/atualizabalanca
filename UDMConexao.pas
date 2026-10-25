unit UDMConexao;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UDMConexao.pas: Data Module de Conexão FireDAC, INI e Autostart Windows     }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  System.Win.Registry,
  Winapi.Windows,
  Data.DB,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,
  FireDAC.VCLUI.Wait,
  FireDAC.Comp.UI,
  FireDAC.Stan.Param,
  FireDAC.DatS,
  FireDAC.DApt.Intf,
  FireDAC.DApt,
  FireDAC.Comp.Client,
  System.Generics.Collections,
  UModelBalanca;

type
  TDMConexao = class(TDataModule)
    FDConnection: TFDConnection;
    FDPhysFBDriverLink: TFDPhysFBDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;
    procedure DataModuleCreate(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
  private
    FHost: string;
    FPorta: Integer;
    FCaminhoBanco: string;
    FUsuario: string;
    FSenha: string;

    FIntervaloSyncSegundos: Integer;
    FModoFila: Boolean;
    FMinimizarBandeja: Boolean;
    FIniciarComWindows: Boolean;

    { Notificações Telegram }
    FTelegramAtivo: Boolean;
    FTelegramToken: string;
    FTelegramChatID: string;

    { Micro-API REST Embutida }
    FApiRestAtiva: Boolean;
    FApiRestPorta: Integer;

    { Agendamento Carga Total }
    FAgendamentoAtivo: Boolean;
    FHorarioCargaTotal: string;

    FArquivoIni: string;
  public
    procedure CarregarConfiguracoes;
    procedure SalvarConfiguracoes;
    procedure CarregarBalancasINI(ALista: TObjectList<TConfigBalanca>);
    procedure SalvarBalancasINI(ALista: TObjectList<TConfigBalanca>);
    function Conectar: Boolean;
    procedure Desconectar;
    procedure AplicarInicializacaoWindows(const AHabilitar: Boolean);

    property Host: string read FHost write FHost;
    property Porta: Integer read FPorta write FPorta;
    property CaminhoBanco: string read FCaminhoBanco write FCaminhoBanco;
    property Usuario: string read FUsuario write FUsuario;
    property Senha: string read FSenha write FSenha;
    property IntervaloSyncSegundos: Integer read FIntervaloSyncSegundos write FIntervaloSyncSegundos;
    property ModoFila: Boolean read FModoFila write FModoFila;
    property MinimizarBandeja: Boolean read FMinimizarBandeja write FMinimizarBandeja;
    property IniciarComWindows: Boolean read FIniciarComWindows write FIniciarComWindows;

    property TelegramAtivo: Boolean read FTelegramAtivo write FTelegramAtivo;
    property TelegramToken: string read FTelegramToken write FTelegramToken;
    property TelegramChatID: string read FTelegramChatID write FTelegramChatID;

    property ApiRestAtiva: Boolean read FApiRestAtiva write FApiRestAtiva;
    property ApiRestPorta: Integer read FApiRestPorta write FApiRestPorta;

    property AgendamentoAtivo: Boolean read FAgendamentoAtivo write FAgendamentoAtivo;
    property HorarioCargaTotal: string read FHorarioCargaTotal write FHorarioCargaTotal;

    property ArquivoIni: string read FArquivoIni;
  end;

var
  DMConexao: TDMConexao;

implementation

uses
  System.StrUtils;

{$R *.dfm}

procedure TDMConexao.DataModuleCreate(Sender: TObject);
begin
  FArquivoIni := ExtractFilePath(ParamStr(0)) + 'ConfigBalanca.ini';
  CarregarConfiguracoes;
end;

procedure TDMConexao.DataModuleDestroy(Sender: TObject);
begin
  Desconectar;
end;

procedure TDMConexao.CarregarConfiguracoes;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FArquivoIni, TEncoding.UTF8);
  try
    FHost := Ini.ReadString('BANCO', 'Host', 'localhost');
    FPorta := Ini.ReadInteger('BANCO', 'Porta', 3050);
    FCaminhoBanco := Ini.ReadString('BANCO', 'Caminho', 'C:\GoUpSistemas\Dados\DADOS.FDB');
    FUsuario := Ini.ReadString('BANCO', 'Usuario', 'SYSDBA');
    FSenha := Ini.ReadString('BANCO', 'Senha', 'masterkey');

    FIntervaloSyncSegundos := Ini.ReadInteger('SISTEMA', 'IntervaloSegundos', 15);
    FModoFila := (Ini.ReadString('SISTEMA', 'ModoFila', 'S') = 'S');
    FMinimizarBandeja := (Ini.ReadString('SISTEMA', 'MinimizarBandeja', 'S') = 'S');
    FIniciarComWindows := (Ini.ReadString('SISTEMA', 'IniciarComWindows', 'S') = 'S');

    FTelegramAtivo := (Ini.ReadString('NOTIFICACOES', 'TelegramAtivo', 'N') = 'S');
    FTelegramToken := Ini.ReadString('NOTIFICACOES', 'TelegramToken', '');
    FTelegramChatID := Ini.ReadString('NOTIFICACOES', 'TelegramChatID', '');

    FApiRestAtiva := (Ini.ReadString('API_REST', 'Ativa', 'S') = 'S');
    FApiRestPorta := Ini.ReadInteger('API_REST', 'Porta', 8085);

    FAgendamentoAtivo := (Ini.ReadString('AGENDAMENTO', 'Ativo', 'S') = 'S');
    FHorarioCargaTotal := Ini.ReadString('AGENDAMENTO', 'Horario', '23:00');
  finally
    Ini.Free;
  end;
end;

procedure TDMConexao.SalvarConfiguracoes;
var
  Ini: TMemIniFile;
begin
  Ini := TMemIniFile.Create(FArquivoIni, TEncoding.UTF8);
  try
    Ini.WriteString('BANCO', 'Host', FHost);
    Ini.WriteInteger('BANCO', 'Porta', FPorta);
    Ini.WriteString('BANCO', 'Caminho', FCaminhoBanco);
    Ini.WriteString('BANCO', 'Usuario', FUsuario);
    Ini.WriteString('BANCO', 'Senha', FSenha);

    Ini.WriteInteger('SISTEMA', 'IntervaloSegundos', FIntervaloSyncSegundos);
    if FModoFila then
      Ini.WriteString('SISTEMA', 'ModoFila', 'S')
    else
      Ini.WriteString('SISTEMA', 'ModoFila', 'N');

    if FMinimizarBandeja then
      Ini.WriteString('SISTEMA', 'MinimizarBandeja', 'S')
    else
      Ini.WriteString('SISTEMA', 'MinimizarBandeja', 'N');

    if FIniciarComWindows then
      Ini.WriteString('SISTEMA', 'IniciarComWindows', 'S')
    else
      Ini.WriteString('SISTEMA', 'IniciarComWindows', 'N');

    if FTelegramAtivo then
      Ini.WriteString('NOTIFICACOES', 'TelegramAtivo', 'S')
    else
      Ini.WriteString('NOTIFICACOES', 'TelegramAtivo', 'N');
    Ini.WriteString('NOTIFICACOES', 'TelegramToken', FTelegramToken);
    Ini.WriteString('NOTIFICACOES', 'TelegramChatID', FTelegramChatID);

    if FApiRestAtiva then
      Ini.WriteString('API_REST', 'Ativa', 'S')
    else
      Ini.WriteString('API_REST', 'Ativa', 'N');
    Ini.WriteInteger('API_REST', 'Porta', FApiRestPorta);

    if FAgendamentoAtivo then
      Ini.WriteString('AGENDAMENTO', 'Ativo', 'S')
    else
      Ini.WriteString('AGENDAMENTO', 'Ativo', 'N');
    Ini.WriteString('AGENDAMENTO', 'Horario', FHorarioCargaTotal);

    Ini.UpdateFile;
  finally
    Ini.Free;
  end;

  AplicarInicializacaoWindows(FIniciarComWindows);
end;

procedure TDMConexao.AplicarInicializacaoWindows(const AHabilitar: Boolean);
var
  Reg: TRegistry;
  ExePath: string;
begin
  Reg := TRegistry.Create;
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Run', True) then
    begin
      ExePath := ParamStr(0);
      if AHabilitar then
        Reg.WriteString('GoUpAtualizaBalanca', '"' + ExePath + '" /minimized')
      else if Reg.ValueExists('GoUpAtualizaBalanca') then
        Reg.DeleteValue('GoUpAtualizaBalanca');
    end;
  finally
    Reg.Free;
  end;
end;

function TDMConexao.Conectar: Boolean;
begin
  try
    Desconectar;

    FDConnection.Params.Clear;
    FDConnection.Params.DriverID := 'FB';
    FDConnection.Params.Database := FCaminhoBanco;
    FDConnection.Params.UserName := FUsuario;
    FDConnection.Params.Password := FSenha;
    FDConnection.Params.Values['Server'] := FHost;
    FDConnection.Params.Values['Port'] := IntToStr(FPorta);
    FDConnection.Params.Values['CharacterSet'] := 'WIN1252';

    FDConnection.Connected := True;
    Result := FDConnection.Connected;
  except
    on E: Exception do
      Result := False;
  end;
end;

procedure TDMConexao.Desconectar;
begin
  if FDConnection.Connected then
    FDConnection.Connected := False;
end;

procedure TDMConexao.CarregarBalancasINI(ALista: TObjectList<TConfigBalanca>);
var
  Ini: TMemIniFile;
  Total, I, IdBal: Integer;
  Bal: TConfigBalanca;
  Secao: string;
begin
  if not Assigned(ALista) then
    Exit;

  ALista.Clear;
  Ini := TMemIniFile.Create(FArquivoIni, TEncoding.UTF8);
  try
    Total := Ini.ReadInteger('BALANCAS', 'Total', 0);
    if Total <= 0 then
      Exit;

    for I := 1 to Total do
    begin
      Secao := Format('BALANCA_%d', [I]);
      IdBal := Ini.ReadInteger(Secao, 'ID', I);
      Bal := TConfigBalanca.Create;
      Bal.ID := IdBal;
      Bal.Nome := Ini.ReadString(Secao, 'Nome', Format('Balança %d', [I]));
      Bal.Fabricante := StringToFabricante(Ini.ReadString(Secao, 'Fabricante', 'Toledo'));
      Bal.Modelo := StringToModelo(Ini.ReadString(Secao, 'Modelo', 'Prix 5'));
      Bal.IP := Ini.ReadString(Secao, 'IP', '192.168.1.201');
      Bal.Porta := Ini.ReadInteger(Secao, 'Porta', 6500);
      Bal.Setor := Ini.ReadInteger(Secao, 'Setor', 0);
      Bal.Ativo := (Ini.ReadString(Secao, 'Ativo', 'S') = 'S');
      Bal.CaminhoDLL := Ini.ReadString(Secao, 'CaminhoDLL', '');
      ALista.Add(Bal);
    end;
  finally
    Ini.Free;
  end;
end;

procedure TDMConexao.SalvarBalancasINI(ALista: TObjectList<TConfigBalanca>);
var
  Ini: TMemIniFile;
  I: Integer;
  Bal: TConfigBalanca;
  Secao: string;
  Secoes: TStringList;
begin
  if not Assigned(ALista) then
    Exit;

  Ini := TMemIniFile.Create(FArquivoIni, TEncoding.UTF8);
  Secoes := TStringList.Create;
  try
    { Limpa seções antigas de balança do INI para evitar lixo residual }
    Ini.ReadSections(Secoes);
    for I := 0 to Secoes.Count - 1 do
    begin
      if StartsText('BALANCA_', Secoes[I]) then
        Ini.EraseSection(Secoes[I]);
    end;

    Ini.WriteInteger('BALANCAS', 'Total', ALista.Count);

    for I := 0 to ALista.Count - 1 do
    begin
      Bal := ALista[I];
      Bal.ID := I + 1;
      Secao := Format('BALANCA_%d', [Bal.ID]);

      Ini.WriteInteger(Secao, 'ID', Bal.ID);
      Ini.WriteString(Secao, 'Nome', Bal.Nome);
      Ini.WriteString(Secao, 'Fabricante', FabricanteToString(Bal.Fabricante));
      Ini.WriteString(Secao, 'Modelo', ModeloToString(Bal.Modelo));
      Ini.WriteString(Secao, 'IP', Bal.IP);
      Ini.WriteInteger(Secao, 'Porta', Bal.Porta);
      Ini.WriteInteger(Secao, 'Setor', Bal.Setor);
      if Bal.Ativo then
        Ini.WriteString(Secao, 'Ativo', 'S')
      else
        Ini.WriteString(Secao, 'Ativo', 'N');
      Ini.WriteString(Secao, 'CaminhoDLL', Bal.CaminhoDLL);
    end;

    Ini.UpdateFile;
  finally
    Secoes.Free;
    Ini.Free;
  end;
end;

end.