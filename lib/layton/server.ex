defmodule Layton.Lgrpc.Server do
  use GRPC.Server, service: Lgrpc.Layton.Service

  @spec create_account(Lgrpc.AccountCredentials.t(), GRPC.Server.Stream.t()) :: Lgrpc.Result.t()
  def create_account(request, _stream) do
    IO.inspect(request)
    Lgrpc.Result.new(result_code: :ERC_SUCCESS)
  end

  @spec login(Lgrpc.AccountCredentials.t(), GRPC.Server.Stream.t()) :: Lgrpc.Result.t()
  def login(request, _stream) do
    IO.inspect(request)
    Lgrpc.Result.new(result_code: :ERC_SUCCESS)
  end
end
