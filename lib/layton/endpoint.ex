# Client Service Endpoint
defmodule Layton.Client.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.Lgrpc.Server)
end

# Session Service Endpoint
defmodule Layton.GameServer.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.Lgrpc.Server)
end
