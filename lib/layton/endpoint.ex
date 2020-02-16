# Client Service Endpoint
defmodule Layton.Client.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.Client.Server)
end

# Session Service Endpoint
defmodule Layton.GameSession.Endpoint do
  use GRPC.Endpoint

  GRPC.Logger

  intercept(GRPC.Logger.Server)
  run(Layton.GameSession.Server)
end
