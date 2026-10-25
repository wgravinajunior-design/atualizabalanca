program AtualizaBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança Enterprise                           }
{  AtualizaBalanca.dpr: Ponto de entrada do sistema Delphi                     }
{******************************************************************************}

uses
  Vcl.Forms,
  FireDAC.DApt,
  UDMConexao in 'UDMConexao.pas' {DMConexao: TDataModule},
  UFrmPrincipal in 'UFrmPrincipal.pas' {FrmPrincipal},
  UFrmConfig in 'UFrmConfig.pas' {FrmConfig},
  UFrmComparador in 'UFrmComparador.pas' {FrmComparador},
  UFrmNutricional in 'UFrmNutricional.pas' {FrmNutricional},
  UFrmSobreNovidades in 'UFrmSobreNovidades.pas' {FrmSobreNovidades},
  UModelBalanca in 'UModelBalanca.pas',
  USchemaBalanca in 'USchemaBalanca.pas',
  URepositoryBalanca in 'URepositoryBalanca.pas',
  UComunicadorBalanca in 'UComunicadorBalanca.pas',
  UProtocoloBalmak in 'UProtocoloBalmak.pas',
  UProtocoloFilizola in 'UProtocoloFilizola.pas',
  UProtocoloToledo in 'UProtocoloToledo.pas',
  UProtocoloUrano in 'UProtocoloUrano.pas',
  UProtocoloElgin in 'UProtocoloElgin.pas',
  UProtocoloRamuza in 'UProtocoloRamuza.pas',
  UProtocoloSystel in 'UProtocoloSystel.pas',
  UServicoNotificacao in 'UServicoNotificacao.pas',
  UServidorRest in 'UServidorRest.pas',
  UValidadorBalanca in 'UValidadorBalanca.pas',
  UThreadMonitor in 'UThreadMonitor.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'GoUp Sistemas - AtualizaBalança Enterprise';
  Application.CreateForm(TDMConexao, DMConexao);
  Application.CreateForm(TFrmPrincipal, FrmPrincipal);
  Application.Run;
end.