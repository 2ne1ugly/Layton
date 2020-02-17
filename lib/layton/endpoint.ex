# Client Service Endpoint
defmodule Layton.Client.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.Client.Service)
end

# Session Service Endpoint
defmodule Layton.GameSession.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.GameSession.Service)
end
