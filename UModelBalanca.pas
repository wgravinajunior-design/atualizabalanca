unit UModelBalanca;

{******************************************************************************}
{  GoUp Sistemas - Módulo AtualizaBalança                                      }
{  UModelBalanca.pas: Modelos de dados e entidades para integração de balanças }
{******************************************************************************}

interface

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections;

type
  { Enumerações Completas de Fabricantes do Mercado Nacional }
  TFabricanteBalanca = (
    fbBalmak,
    fbFilizola,
    fbToledo,
    fbUrano,
    fbElgin,
    fbRamuza,
    fbSystel
  );

  { Modelos Específicos de Balanças de Etiquetagem / Rede }
  TModeloBalanca = (
    { Balmak }
    mbBalmakAthena,
    mbBalmakAthenaLight,
    mbBalmakOrion,
    mbBalmakOrionTouch,
    { Filizola }
    mbFilizolaPlatina,
    mbFilizolaPlatinaPlus,
    mbFilizolaCS,
    { Toledo }
    mbToledoPrix4,
    mbToledoPrix4Uno,
    mbToledoPrix5,
    mbToledoPrix5Plus,
    mbToledoPrix6,
    mbToledoPrix6Touch,
    { Urano }
    mbUranoTop,
    mbUranoTopMax,
    mbUranoIntegra,
    { Elgin }
    mbElginWind,
    mbElginDP30,
    { Ramuza }
    mbRamuzaDCRCL,
    { Systel }
    mbSystelCuora
  );

  TTipoVendaPLU = (tvPeso, tvUnidade);
  TStatusOperacao = (soPendente, soSincronizado, soErro);

  { Informações Nutricionais Completas (RDC 429 e IN 75 Anvisa) }
  TInfoNutricional = class
  private
    FPorcaoQtde: Integer;
    FPorcaoUnidade: string;
    FValorEnergetico: Integer;
    FCarboidratos: Double;
    FAcucaresTotais: Double;
    FAcucaresAdicionados: Double;
    FProteinas: Double;
    FGordurasTotais: Double;
    FGordurasSaturadas: Double;
    FGordurasTrans: Double;
    FFibraAlimentar: Double;
    FSodio: Double;
  public
    constructor Create;
    property PorcaoQtde: Integer read FPorcaoQtde write FPorcaoQtde;
    property PorcaoUnidade: string read FPorcaoUnidade write FPorcaoUnidade;
    property ValorEnergetico: Integer read FValorEnergetico write FValorEnergetico;
    property Carboidratos: Double read FCarboidratos write FCarboidratos;
    property AcucaresTotais: Double read FAcucaresTotais write FAcucaresTotais;
    property AcucaresAdicionados: Double read FAcucaresAdicionados write FAcucaresAdicionados;
    property Proteinas: Double read FProteinas write FProteinas;
    property GordurasTotais: Double read FGordurasTotais write FGordurasTotais;
    property GordurasSaturadas: Double read FGordurasSaturadas write FGordurasSaturadas;
    property GordurasTrans: Double read FGordurasTrans write FGordurasTrans;
    property FibraAlimentar: Double read FFibraAlimentar write FFibraAlimentar;
    property Sodio: Double read FSodio write FSodio;
  end;

  { Representação do Produto PLU com Receita e Alergênicos }
  TProdutoPLU = class
  private
    FID: Integer;
    FCodigoPLU: Integer;
    FCodigoBarras: string;
    FDescricao: string;
    FDescricaoCurta: string;
    FPrecoVenda: Currency;
    FValidadeDias: Integer;
    FTipoVenda: TTipoVendaPLU;
    FTeclaAcesso: Integer;
    FSetor: Integer;
    FAtivo: Boolean;
    FUltimaAlteracao: TDateTime;
    FReceita: string;
    FAlergenicos: string;
    FConservacao: string;
    FNutricional: TInfoNutricional;
  public
    constructor Create;
    destructor Destroy; override;

    property ID: Integer read FID write FID;
    property CodigoPLU: Integer read FCodigoPLU write FCodigoPLU;
    property CodigoBarras: string read FCodigoBarras write FCodigoBarras;
    property Descricao: string read FDescricao write FDescricao;
    property DescricaoCurta: string read FDescricaoCurta write FDescricaoCurta;
    property PrecoVenda: Currency read FPrecoVenda write FPrecoVenda;
    property ValidadeDias: Integer read FValidadeDias write FValidadeDias;
    property TipoVenda: TTipoVendaPLU read FTipoVenda write FTipoVenda;
    property TeclaAcesso: Integer read FTeclaAcesso write FTeclaAcesso;
    property Setor: Integer read FSetor write FSetor;
    property Ativo: Boolean read FAtivo write FAtivo;
    property UltimaAlteracao: TDateTime read FUltimaAlteracao write FUltimaAlteracao;
    property Receita: string read FReceita write FReceita;
    property Alergenicos: string read FAlergenicos write FAlergenicos;
    property Conservacao: string read FConservacao write FConservacao;
    property Nutricional: TInfoNutricional read FNutricional;
  end;

  { Cadastro e Configuração de cada Balança de Rede }
  TConfigBalanca = class
  private
    FID: Integer;
    FNome: string;
    FFabricante: TFabricanteBalanca;
    FModelo: TModeloBalanca;
    FIP: string;
    FPorta: Integer;
    FSetor: Integer;
    FAtivo: Boolean;
    FCaminhoDLL: string;
    FOnline: Boolean;
    FUltimaSincronizacao: TDateTime;
    FUltimoLog: string;
    FFalhasConsecutivas: Integer;
  public
    constructor Create;
    property ID: Integer read FID write FID;
    property Nome: string read FNome write FNome;
    property Fabricante: TFabricanteBalanca read FFabricante write FFabricante;
    property Modelo: TModeloBalanca read FModelo write FModelo;
    property IP: string read FIP write FIP;
    property Porta: Integer read FPorta write FPorta;
    property Setor: Integer read FSetor write FSetor;
    property Ativo: Boolean read FAtivo write FAtivo;
    property CaminhoDLL: string read FCaminhoDLL write FCaminhoDLL;
    property Online: Boolean read FOnline write FOnline;
    property UltimaSincronizacao: TDateTime read FUltimaSincronizacao write FUltimaSincronizacao;
    property UltimoLog: string read FUltimoLog write FUltimoLog;
    property FalhasConsecutivas: Integer read FFalhasConsecutivas write FFalhasConsecutivas;

    function ObterDescricaoFabricante: string;
    function ObterDescricaoModelo: string;
  end;

  { Configuração e Layout de Impressão de Etiquetas para Balanças }
  TConfigEtiqueta = class
  private
    FFormatoID: Integer;
    FTamanhoDescricao: string;
    FNomeLoja: string;
    FMensagemRodape: string;
    FImprimirLoja: Boolean;
    FImprimirPLU: Boolean;
    FImprimirDescricao: Boolean;
    FImprimirDataEmbalagem: Boolean;
    FImprimirDataValidade: Boolean;
    FImprimirHora: Boolean;
    FImprimirTara: Boolean;
    FImprimirPrecoUnitario: Boolean;
    FImprimirPeso: Boolean;
    FImprimirTotal: Boolean;
    FImprimirCodigoBarras: Boolean;
    FImprimirNutricional: Boolean;
    FImprimirReceitaAlergicos: Boolean;
    FImprimirRodape: Boolean;
    FTipoCodigoBarras: Integer;
  public
    constructor Create;
    procedure CarregarPadrao;

    property FormatoID: Integer read FFormatoID write FFormatoID;
    property TamanhoDescricao: string read FTamanhoDescricao write FTamanhoDescricao;
    property NomeLoja: string read FNomeLoja write FNomeLoja;
    property MensagemRodape: string read FMensagemRodape write FMensagemRodape;
    property ImprimirLoja: Boolean read FImprimirLoja write FImprimirLoja;
    property ImprimirPLU: Boolean read FImprimirPLU write FImprimirPLU;
    property ImprimirDescricao: Boolean read FImprimirDescricao write FImprimirDescricao;
    property ImprimirDataEmbalagem: Boolean read FImprimirDataEmbalagem write FImprimirDataEmbalagem;
    property ImprimirDataValidade: Boolean read FImprimirDataValidade write FImprimirDataValidade;
    property ImprimirHora: Boolean read FImprimirHora write FImprimirHora;
    property ImprimirTara: Boolean read FImprimirTara write FImprimirTara;
    property ImprimirPrecoUnitario: Boolean read FImprimirPrecoUnitario write FImprimirPrecoUnitario;
    property ImprimirPeso: Boolean read FImprimirPeso write FImprimirPeso;
    property ImprimirTotal: Boolean read FImprimirTotal write FImprimirTotal;
    property ImprimirCodigoBarras: Boolean read FImprimirCodigoBarras write FImprimirCodigoBarras;
    property ImprimirNutricional: Boolean read FImprimirNutricional write FImprimirNutricional;
    property ImprimirReceitaAlergicos: Boolean read FImprimirReceitaAlergicos write FImprimirReceitaAlergicos;
    property ImprimirRodape: Boolean read FImprimirRodape write FImprimirRodape;
    property TipoCodigoBarras: Integer read FTipoCodigoBarras write FTipoCodigoBarras;
  end;

  { Registro de Retorno da Operação de Envio }
  TResultadoEnvio = record
    Sucesso: Boolean;
    Mensagem: string;
    QuantidadeItens: Integer;
    DataHora: TDateTime;
    TempoMs: Cardinal;
  end;

  { Funções utilitárias de conversão de tipos }
  function FabricanteToString(const AFabricante: TFabricanteBalanca): string;
  function StringToFabricante(const AValor: string): TFabricanteBalanca;
  function ModeloToString(const AModelo: TModeloBalanca): string;
  function StringToModelo(const AValor: string): TModeloBalanca;

implementation

function FabricanteToString(const AFabricante: TFabricanteBalanca): string;
begin
  case AFabricante of
    fbBalmak:   Result := 'Balmak';
    fbFilizola: Result := 'Filizola';
    fbToledo:   Result := 'Toledo';
    fbUrano:    Result := 'Urano';
    fbElgin:    Result := 'Elgin';
    fbRamuza:   Result := 'Ramuza';
    fbSystel:   Result := 'Systel';
  else
    Result := 'Balmak';
  end;
end;

function StringToFabricante(const AValor: string): TFabricanteBalanca;
var
  S: string;
begin
  S := UpperCase(Trim(AValor));
  if S = 'TOLEDO' then
    Result := fbToledo
  else if S = 'FILIZOLA' then
    Result := fbFilizola
  else if S = 'URANO' then
    Result := fbUrano
  else if S = 'ELGIN' then
    Result := fbElgin
  else if S = 'RAMUZA' then
    Result := fbRamuza
  else if S = 'SYSTEL' then
    Result := fbSystel
  else
    Result := fbBalmak;
end;

function ModeloToString(const AModelo: TModeloBalanca): string;
begin
  case AModelo of
    mbBalmakAthena:       Result := 'Balmak Athena';
    mbBalmakAthenaLight:  Result := 'Balmak Athena Light';
    mbBalmakOrion:        Result := 'Balmak Orion';
    mbBalmakOrionTouch:   Result := 'Balmak Orion Touch';

    mbFilizolaPlatina:    Result := 'Filizola Platina';
    mbFilizolaPlatinaPlus:Result := 'Filizola Platina Plus';
    mbFilizolaCS:         Result := 'Filizola CS';

    mbToledoPrix4:        Result := 'Toledo Prix 4';
    mbToledoPrix4Uno:     Result := 'Toledo Prix 4 Uno / Due';
    mbToledoPrix5:        Result := 'Toledo Prix 5';
    mbToledoPrix5Plus:    Result := 'Toledo Prix 5 Plus';
    mbToledoPrix6:        Result := 'Toledo Prix 6';
    mbToledoPrix6Touch:   Result := 'Toledo Prix 6 Touch';

    mbUranoTop:           Result := 'Urano Top';
    mbUranoTopMax:        Result := 'Urano TopMax';
    mbUranoIntegra:       Result := 'Urano Integra';

    mbElginWind:          Result := 'Elgin Wind';
    mbElginDP30:          Result := 'Elgin DP-30';

    mbRamuzaDCRCL:        Result := 'Ramuza DCR-CL';

    mbSystelCuora:        Result := 'Systel Cuora / Croma';
  else
    Result := 'Balmak Athena';
  end;
end;

function StringToModelo(const AValor: string): TModeloBalanca;
var
  S: string;
begin
  S := UpperCase(Trim(AValor));
  if Pos('PRIX 6 TOUCH', S) > 0 then
    Result := mbToledoPrix6Touch
  else if Pos('PRIX 6', S) > 0 then
    Result := mbToledoPrix6
  else if Pos('PRIX 5 PLUS', S) > 0 then
    Result := mbToledoPrix5Plus
  else if Pos('PRIX 5', S) > 0 then
    Result := mbToledoPrix5
  else if Pos('PRIX 4 UNO', S) > 0 then
    Result := mbToledoPrix4Uno
  else if Pos('PRIX 4', S) > 0 then
    Result := mbToledoPrix4
  else if Pos('PLATINA PLUS', S) > 0 then
    Result := mbFilizolaPlatinaPlus
  else if Pos('PLATINA', S) > 0 then
    Result := mbFilizolaPlatina
  else if Pos('CS', S) > 0 then
    Result := mbFilizolaCS
  else if Pos('TOPMAX', S) > 0 then
    Result := mbUranoTopMax
  else if Pos('INTEGRA', S) > 0 then
    Result := mbUranoIntegra
  else if Pos('URANO', S) > 0 then
    Result := mbUranoTop
  else if Pos('WIND', S) > 0 then
    Result := mbElginWind
  else if Pos('DP-30', S) > 0 then
    Result := mbElginDP30
  else if Pos('RAMUZA', S) > 0 then
    Result := mbRamuzaDCRCL
  else if Pos('SYSTEL', S) > 0 then
    Result := mbSystelCuora
  else if Pos('ORION TOUCH', S) > 0 then
    Result := mbBalmakOrionTouch
  else if Pos('ORION', S) > 0 then
    Result := mbBalmakOrion
  else if Pos('ATHENA LIGHT', S) > 0 then
    Result := mbBalmakAthenaLight
  else
    Result := mbBalmakAthena;
end;

{ TInfoNutricional }

constructor TInfoNutricional.Create;
begin
  inherited Create;
  FPorcaoQtde := 0;
  FPorcaoUnidade := 'g';
  FValorEnergetico := 0;
  FCarboidratos := 0.0;
  FAcucaresTotais := 0.0;
  FAcucaresAdicionados := 0.0;
  FProteinas := 0.0;
  FGordurasTotais := 0.0;
  FGordurasSaturadas := 0.0;
  FGordurasTrans := 0.0;
  FFibraAlimentar := 0.0;
  FSodio := 0.0;
end;

{ TProdutoPLU }

constructor TProdutoPLU.Create;
begin
  inherited Create;
  FID := 0;
  FCodigoPLU := 0;
  FCodigoBarras := '';
  FDescricao := '';
  FDescricaoCurta := '';
  FPrecoVenda := 0.0;
  FValidadeDias := 0;
  FTipoVenda := tvPeso;
  FTeclaAcesso := 0;
  FSetor := 0;
  FAtivo := True;
  FUltimaAlteracao := Now;
  FReceita := '';
  FAlergenicos := '';
  FConservacao := '';
  FNutricional := TInfoNutricional.Create;
end;

destructor TProdutoPLU.Destroy;
begin
  FreeAndNil(FNutricional);
  inherited Destroy;
end;

{ TConfigBalanca }

constructor TConfigBalanca.Create;
begin
  inherited Create;
  FID := 0;
  FNome := '';
  FFabricante := fbBalmak;
  FModelo := mbBalmakAthena;
  FIP := '';
  FPorta := 0;
  FSetor := 0;
  FAtivo := True;
  FCaminhoDLL := '';
  FOnline := False;
  FUltimaSincronizacao := 0;
  FUltimoLog := '';
  FFalhasConsecutivas := 0;
end;

function TConfigBalanca.ObterDescricaoFabricante: string;
begin
  Result := FabricanteToString(FFabricante);
end;

function TConfigBalanca.ObterDescricaoModelo: string;
begin
  Result := ModeloToString(FModelo);
end;

{ TConfigEtiqueta }

constructor TConfigEtiqueta.Create;
begin
  inherited Create;
  CarregarPadrao;
end;

procedure TConfigEtiqueta.CarregarPadrao;
begin
  FFormatoID := 3;
  FTamanhoDescricao := '60 x 40 mm (Padrão de Mercado)';
  FNomeLoja := 'GOUP SUPERMERCADOS';
  FMensagemRodape := 'Conserve em local fresco. Obrigado pela preferência!';
  FImprimirLoja := True;
  FImprimirPLU := True;
  FImprimirDescricao := True;
  FImprimirDataEmbalagem := True;
  FImprimirDataValidade := True;
  FImprimirHora := True;
  FImprimirTara := True;
  FImprimirPrecoUnitario := True;
  FImprimirPeso := True;
  FImprimirTotal := True;
  FImprimirCodigoBarras := True;
  FImprimirNutricional := True;
  FImprimirReceitaAlergicos := True;
  FImprimirRodape := True;
  FTipoCodigoBarras := 0;
end;

end.