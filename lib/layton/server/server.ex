defmodule Layton.Lgrpc.Server do
  use GRPC.Server, service: Lgrpc.Layton.Service

  ##
  ##  IDENTITY
  ##
  def create_account(request, _stream) do
    changeset = Layton.Schema.Account.changeset(request)

    case Layton.Repo.insert(changeset) do
      {:ok, _} -> Lgrpc.Result.new(result_code: :ERC_SUCCESS)
      {:error, _} -> Lgrpc.Result.new(result_code: :ERC_FAIL)
    end
  end

  def login(request, _stream) do
    # Check If it's inside the database and return true/false
    case Layton.Repo.get_by(Layton.Schema.Account, Map.from_struct(request)) do
      nil -> Lgrpc.Result.new(result_code: :ERC_FAIL)
      _account -> Lgrpc.Result.new(result_code: :ERC_SUCCESS)
    end
  end

  ##
  ##  Session
  ##
  def create_session(request, _stream) do
    session = %Layton.Types.Session{session_name: request.session_name}

    case Layton.Lgrpc.Server.Session.create_session(session) do
      :ok -> Lgrpc.Result.new(result_code: :ERC_SUCCESS)
      {:error, :already_exists} -> Lgrpc.Result.new(result_code: :ERC_FAIL)
    end
  end

  def find_sessions(request, _stream) do
    Lgrpc.FindSessionsResponse.new(result_code: :ERC_ERROR)
  end

  def join_session(request, _stream) do
    Lgrpc.Result.new(result_code: :ERC_ERROR)
  end

  def start_session(request, _stream) do
    Lgrpc.Result.new(result_code: :ERC_ERROR)
  end
end
