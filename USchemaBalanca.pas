unit USchemaBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  USchemaBalanca.pas: Módulo Não-Intrusivo (Read-Only)                        }
{  Nenhuma tabela, trigger ou generator é criado no banco de dados Firebird.   }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  Data.DB,
  FireDAC.Comp.Client;

type
  TSchemaBalanca = class
  public
    class function TabelaExiste(AConnection: TFDConnection; const ATabela: string): Boolean;
    class function GeneratorExiste(AConnection: TFDConnection; const AGen: string): Boolean;
    class function TriggerExiste(AConnection: TFDConnection; const ATrigger: string): Boolean;

    class procedure InstalarEstruturaCompleta(AConnection: TFDConnection);
    class procedure InserirBalancasIniciaisSeVazio(AConnection: TFDConnection);
    class function ObterScriptSQLCompleto: string;
  end;

implementation

{ TSchemaBalanca }

class function TSchemaBalanca.TabelaExiste(AConnection: TFDConnection; const ATabela: string): Boolean;
begin
  Result := False;
end;

class function TSchemaBalanca.GeneratorExiste(AConnection: TFDConnection; const AGen: string): Boolean;
begin
  Result := False;
end;

class function TSchemaBalanca.TriggerExiste(AConnection: TFDConnection; const ATrigger: string): Boolean;
begin
  Result := False;
end;

class procedure TSchemaBalanca.InstalarEstruturaCompleta(AConnection: TFDConnection);
begin
  { Modo Não-Intrusivo: Nenhuma tabela, trigger ou generator é criado no banco do cliente }
  Exit;
end;

class procedure TSchemaBalanca.InserirBalancasIniciaisSeVazio(AConnection: TFDConnection);
begin
  { As balanças são gerenciadas e armazenadas no arquivo ConfigBalanca.ini }
  Exit;
end;

class function TSchemaBalanca.ObterScriptSQLCompleto: string;
begin
  Result := '-- Modo Não-Intrusivo: O AtualizaBalança consulta diretamente as tabelas TB_PRODUTO e TB_PRODUTO_NUTRICIONAL sem triggers.';
end;

end.