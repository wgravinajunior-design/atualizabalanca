unit UComunicadorBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UComunicadorBalanca.pas: Interface e Fábrica de Comunicação com Balanças    }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  UModelBalanca;

type
  { Interface base para todos os drivers de comunicação com balanças }
  IBalancaComunicador = interface
    ['{B94B1B3C-681C-4B7C-A5D7-F7E64DE8E4A0}']
    function Conectar: Boolean;
    procedure Desconectar;
    function TestarConectividade: Boolean;
    function EnviarProdutos(AProdutos: TObjectList<TProdutoPLU>): TResultadoEnvio;
    function LimparBalanca: TResultadoEnvio;
    function ObterNomeDriver: string;
  end;

  { Fábrica de instâncias de comunicadores por fabricante }
  TFabricaComunicador = class
  public
    class function CriarComunicador(ABalanca: TConfigBalanca): IBalancaComunicador;
  end;

implementation

uses
  UProtocoloBalmak,
  UProtocoloFilizola,
  UProtocoloToledo,
  UProtocoloUrano,
  UProtocoloElgin,
  UProtocoloRamuza,
  UProtocoloSystel;

{ TFabricaComunicador }

class function TFabricaComunicador.CriarComunicador(ABalanca: TConfigBalanca): IBalancaComunicador;
begin
  case ABalanca.Fabricante of
    fbBalmak:
      Result := TProtocoloBalmak.Create(ABalanca);
    fbFilizola:
      Result := TProtocoloFilizola.Create(ABalanca);
    fbToledo:
      Result := TProtocoloToledo.Create(ABalanca);
    fbUrano:
      Result := TProtocoloUrano.Create(ABalanca);
    fbElgin:
      Result := TProtocoloElgin.Create(ABalanca);
    fbRamuza:
      Result := TProtocoloRamuza.Create(ABalanca);
    fbSystel:
      Result := TProtocoloSystel.Create(ABalanca);
  else
    Result := TProtocoloBalmak.Create(ABalanca);
  end;
end;

end.