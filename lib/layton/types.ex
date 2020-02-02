defmodule Layton.Types.Credentials do
  defstruct username: "Unnamed"
end

defmodule Layton.Types.RequestHeader do
  defstruct username: "Unnamed", token: ""
end

defmodule Layton.Types.Session do
  defstruct name: "Unnamed", iPAddress: "127.0.0.1", maxPlayers: 0
end
