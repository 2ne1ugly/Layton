defmodule Layton.GameSession.Service do
  use GRPC.Server, service: Lgrpc.LaytonGameSession.Service
end
