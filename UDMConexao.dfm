object DMConexao: TDMConexao
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 220
  Width = 320
  object FDConnection: TFDConnection
    Params.Strings = (
      'DriverID=FB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'Database=C:\GoUpSistemas\Dados\DADOS.FDB'
      'Server=localhost'
      'Port=3050'
      'CharacterSet=WIN1252')
    LoginPrompt = False
    Left = 56
    Top = 32
  end
  object FDPhysFBDriverLink: TFDPhysFBDriverLink
    Left = 168
    Top = 32
  end
  object FDGUIxWaitCursor: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 88
    Top = 112
  end
end