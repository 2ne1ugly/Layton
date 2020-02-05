defmodule Layton.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.Lgrpc.Server)
end
