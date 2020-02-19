defmodule Lgrpc.ResultCode do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :RC_ERROR | :RC_SUCCESS | :RC_FAIL

  field :RC_ERROR, 0
  field :RC_SUCCESS, 1
  field :RC_FAIL, 2
end

defmodule Lgrpc.LobbyState do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :LS_ERROR | :LS_PENDING | :LS_WAITING_FOR_MATCH | :LS_IN_PROGRESS

  field :LS_ERROR, 0
  field :LS_PENDING, 1
  field :LS_WAITING_FOR_MATCH, 2
  field :LS_IN_PROGRESS, 3
end

defmodule Lgrpc.Result do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.ResultCode.t()
        }
  defstruct [:result_code]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
end

defmodule Lgrpc.CreateAccountRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field :username, 1, type: :string
end

defmodule Lgrpc.LoginRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field :username, 1, type: :string
end

defmodule Lgrpc.LoginResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.ResultCode.t(),
          auth_token: binary
        }
  defstruct [:result_code, :auth_token]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :auth_token, 2, type: :bytes
end

defmodule Lgrpc.CreateLobbyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lobby_name: String.t(),
          map_name: String.t(),
          max_players: non_neg_integer
        }
  defstruct [:lobby_name, :map_name, :max_players]

  field :lobby_name, 1, type: :string
  field :map_name, 2, type: :string
  field :max_players, 3, type: :uint32
end

defmodule Lgrpc.CreateLobbyResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.ResultCode.t(),
          lobby_uuid: binary
        }
  defstruct [:result_code, :lobby_uuid]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :lobby_uuid, 2, type: :bytes
end

defmodule Lgrpc.JoinLobbyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lobby_uuid: binary
        }
  defstruct [:lobby_uuid]

  field :lobby_uuid, 1, type: :bytes
end

defmodule Lgrpc.LeaveLobbyRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lobby_uuid: binary
        }
  defstruct [:lobby_uuid]

  field :lobby_uuid, 1, type: :bytes
end

defmodule Lgrpc.ChatMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: String.t()
        }
  defstruct [:message]

  field :message, 1, type: :string
end

defmodule Lgrpc.LobbyStreamClient do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          chat_message: Lgrpc.ChatMessage.t() | nil
        }
  defstruct [:chat_message]

  field :chat_message, 2, type: Lgrpc.ChatMessage
end

defmodule Lgrpc.LobbyStreamServer do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          chat_message: Lgrpc.ChatMessage.t() | nil
        }
  defstruct [:chat_message]

  field :chat_message, 2, type: Lgrpc.ChatMessage
end

defmodule Lgrpc.LobbyInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lobby_uuid: binary,
          lobby_name: String.t(),
          map_name: String.t(),
          max_players: non_neg_integer,
          lobby_state: Lgrpc.LobbyState.t()
        }
  defstruct [:lobby_uuid, :lobby_name, :map_name, :max_players, :lobby_state]

  field :lobby_uuid, 1, type: :bytes
  field :lobby_name, 2, type: :string
  field :map_name, 3, type: :string
  field :max_players, 4, type: :uint32
  field :lobby_state, 5, type: Lgrpc.LobbyState, enum: true
end

defmodule Lgrpc.FindLobbiesRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.FindLobbiesResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.ResultCode.t(),
          lobbies: [Lgrpc.LobbyInfo.t()]
        }
  defstruct [:result_code, :lobbies]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :lobbies, 2, repeated: true, type: Lgrpc.LobbyInfo
end

defmodule Lgrpc.RegisterSessionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          port: non_neg_integer
        }
  defstruct [:port]

  field :port, 1, type: :uint32
end

defmodule Lgrpc.UnregisterSessionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.LaytonClient.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.LaytonClient"

  rpc :CreateAccount, Lgrpc.CreateAccountRequest, Lgrpc.Result
  rpc :Login, Lgrpc.LoginRequest, Lgrpc.LoginResponse
  rpc :CreateLobby, Lgrpc.CreateLobbyRequest, Lgrpc.CreateLobbyResponse
  rpc :JoinLobby, Lgrpc.JoinLobbyRequest, Lgrpc.Result
  rpc :LeaveLobby, Lgrpc.LeaveLobbyRequest, Lgrpc.Result
  rpc :StreamLobby, stream(Lgrpc.LobbyStreamClient), stream(Lgrpc.LobbyStreamServer)
  rpc :FindLobbies, Lgrpc.FindLobbiesRequest, Lgrpc.FindLobbiesResponse
end

defmodule Lgrpc.LaytonClient.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.LaytonClient.Service
end

defmodule Lgrpc.LaytonGameSession.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.LaytonGameSession"

  rpc :RegisterSession, Lgrpc.RegisterSessionRequest, Lgrpc.Result
  rpc :UnregisterSession, Lgrpc.UnregisterSessionRequest, Lgrpc.Result
end

defmodule Lgrpc.LaytonGameSession.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.LaytonGameSession.Service
end
