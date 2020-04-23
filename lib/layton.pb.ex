defmodule Lgrpc.ResultCode do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :RC_ERROR | :RC_SUCCESS | :RC_FAIL

  field :RC_ERROR, 0
  field :RC_SUCCESS, 1
  field :RC_FAIL, 2
end

defmodule Lgrpc.LobbyStreamAction do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :LSA_NONE | :LSA_LEAVE_LOBBY | :LSA_START_GAME

  field :LSA_NONE, 0
  field :LSA_LEAVE_LOBBY, 1
  field :LSA_START_GAME, 2
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

defmodule Lgrpc.Empty do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.PlayerInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field :username, 2, type: :string
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
          auth_token: String.t()
        }
  defstruct [:result_code, :auth_token]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :auth_token, 2, type: :string
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
          lobby_uuid: String.t()
        }
  defstruct [:result_code, :lobby_uuid]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :lobby_uuid, 2, type: :string
end

defmodule Lgrpc.SendChatMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: String.t()
        }
  defstruct [:message]

  field :message, 1, type: :string
end

defmodule Lgrpc.ReceiveChatMessage do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t(),
          message: String.t()
        }
  defstruct [:username, :message]

  field :username, 1, type: :string
  field :message, 2, type: :string
end

defmodule Lgrpc.PlayerJoined do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          playerInfo: Lgrpc.PlayerInfo.t() | nil
        }
  defstruct [:playerInfo]

  field :playerInfo, 1, type: Lgrpc.PlayerInfo
end

defmodule Lgrpc.PlayerLeft do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field :username, 1, type: :string
end

defmodule Lgrpc.LobbyStreamInitialize do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.ResultCode.t(),
          lobby_name: String.t(),
          map_name: String.t(),
          players: [Lgrpc.PlayerInfo.t()],
          max_players: non_neg_integer,
          lobby_state: Lgrpc.LobbyState.t()
        }
  defstruct [:result_code, :lobby_name, :map_name, :players, :max_players, :lobby_state]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :lobby_name, 2, type: :string
  field :map_name, 3, type: :string
  field :players, 4, repeated: true, type: Lgrpc.PlayerInfo
  field :max_players, 5, type: :uint32
  field :lobby_state, 6, type: Lgrpc.LobbyState, enum: true
end

defmodule Lgrpc.LobbyStreamClient do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }
  defstruct [:message]

  oneof :message, 0
  field :action, 1, type: Lgrpc.LobbyStreamAction, enum: true, oneof: 0
  field :send_chat_message, 2, type: Lgrpc.SendChatMessage, oneof: 0
end

defmodule Lgrpc.LobbyStreamServer do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          message: {atom, any}
        }
  defstruct [:message]

  oneof :message, 0
  field :init, 1, type: Lgrpc.LobbyStreamInitialize, oneof: 0
  field :action, 2, type: Lgrpc.LobbyStreamAction, enum: true, oneof: 0
  field :receive_chat_message, 3, type: Lgrpc.ReceiveChatMessage, oneof: 0
  field :player_joined, 4, type: Lgrpc.PlayerJoined, oneof: 0
  field :player_left, 5, type: Lgrpc.PlayerLeft, oneof: 0
end

defmodule Lgrpc.LobbyInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          lobby_uuid: String.t(),
          lobby_name: String.t(),
          map_name: String.t(),
          max_players: non_neg_integer,
          lobby_state: Lgrpc.LobbyState.t()
        }
  defstruct [:lobby_uuid, :lobby_name, :map_name, :max_players, :lobby_state]

  field :lobby_uuid, 1, type: :string
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
  rpc :LobbyStream, stream(Lgrpc.LobbyStreamClient), stream(Lgrpc.LobbyStreamServer)
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
