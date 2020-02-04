defmodule Layton.Endpoint do
  use GRPC.Endpoint

  intercept GRPC.Logger.Server
  run Layton.Lgrpc.Server
end
