defmodule Layton.Types.Credentials do
  defstruct username: "Unnamed"
end

defmodule Layton.Types.RequestHeader do
  defstruct username: "Unnamed", token: ""
end

defmodule Layton.Types.SessionSettings do
  defstruct name: "Unnamed", ip_address: "127.0.0.1"
end
