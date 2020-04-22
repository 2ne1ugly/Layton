defmodule Layton.Utils do
  @doc """
  gets header from header containing username & auth token
  """
  def fetch_online_player_from_stream(stream) do
    headers = GRPC.Stream.get_headers(stream)

    case Layton.System.PlayerServer.fetch_online_player(
           headers["custom-username"],
           headers["custom-auth-token"]
         ) do
      :error -> :error
      {:ok, player} -> {:ok, player}
    end
  end
end
