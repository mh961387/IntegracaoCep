unit uPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, System.JSON, FireDAC.Comp.Client,
  REST.Client, IPPeerClient, ACBrBase, ACBrValidador;

type
  TForm2 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    edtEndereco: TEdit;
    Label3: TLabel;
    edtBairro: TEdit;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtmaskFone01: TMaskEdit;
    Label8: TLabel;
    edtMsk02: TMaskEdit;
    Label9: TLabel;
    edtMskWpp: TMaskEdit;
    Label10: TLabel;
    edtMskCep: TMaskEdit;
    Button1: TButton;
    edtEstado: TEdit;
    edtCidade: TEdit;
    Label11: TLabel;
    edtComplemento: TEdit;
    Validador: TACBrValidador;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  CEP: string;
  Endereco: TStringList;
  CEPValido, CEPFoiMudado: Boolean;
  NovoCEP, FCEPAtual: Integer;
  function BuscarCEPNoViaCEP(UmCEP: string): TStringList;
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

function TForm2.BuscarCEPNoViaCEP(UmCEP: string): TStringList;
var
  data: TJSONObject;
  RESTClient1: TRESTClient;
  RESTRequest1: TRESTRequest;
  RESTResponse1: TRESTResponse;
  Endereco: TStringList;
begin
  RESTClient1 := TRESTClient.Create(nil);
  RESTRequest1 := TRESTRequest.Create(nil);
  RESTResponse1 := TRESTResponse.Create(nil);
  RESTRequest1.Client := RESTClient1;
  RESTRequest1.Response := RESTResponse1;
  RESTClient1.BaseURL := 'https://viacep.com.br/ws/' + UmCEP + '/json';
  RESTRequest1.Execute;
  data := RESTResponse1.JSONValue as TJSONObject;
  try
    Endereco := TStringList.Create;
    if Assigned(data) then
    begin
        try
          Endereco.Add(data.Values['logradouro'].Value);
        except
        on Exception do
            Endereco.Add('');
        end;
        try
          Endereco.Add(data.Values['bairro'].Value);
        except
        on Exception do
           Endereco.Add('');
        end;
        try
          Endereco.Add(data.Values['uf'].Value);
        except
        on Exception do
           Endereco.Add('');
        end;
        try
          Endereco.Add(data.Values['localidade'].Value);
        except
        on Exception do
           Endereco.Add('');
        end;
        try
          Endereco.Add(data.Values['complemento'].Value);
        except
        on Exception do
           Endereco.Add('');
        end;
      end;
  finally
    FreeAndNil(data);
  end;
  Result := Endereco;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  Endereco: TStringList;
begin
  Validador.TipoDocto := docCEP;
  Validador.Documento := StringReplace(edtMskCep.Text, '-', '', [rfReplaceAll]);
  if Validador.Validar then
  begin
    try
      Endereco := TStringList.Create;
      Endereco := BuscarCEPNoViaCEP(StringReplace(edtMskCep.Text, '-', '', [rfReplaceAll]));
      edtEndereco.Text    := Endereco[0];
      edtBairro.Text      := Endereco[1];
      edtEstado.Text      := Endereco[2];
      edtCidade.Text      := Endereco[3];
      edtComplemento.Text := Endereco[4];
    finally
      FreeAndNil(Endereco);
    end;
  end
  else
    MessageDlg('Cep invalido!', mtWarning, [mbOk], 0);
end;

end.
