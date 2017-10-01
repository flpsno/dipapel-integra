unit uIPedidoDAO;

interface

uses
  Pedido, System.Generics.Collections;

type
  IPedidoDAO = interface
  ['{4D591142-2A3D-4C66-A5A5-67D25F53E6F2}']

    function Inserir(pPedido: TPedido): Boolean;
    function Atualizar(pPedido: TPedido): Boolean;
    function ObterTodos: TObjectList<TPedido>;
    function ObterPorDataImportacao(pDataDe, pDataAte: TDate): TObjectList<TPedido>;
    function ObterPorCodigo(pCodigo: string): TObjectList<TPedido>;

  end;

implementation

end.
