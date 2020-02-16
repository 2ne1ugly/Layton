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

  @type t :: integer | :LS_ERROR | :LS_IN_PROGRESS

  field :LS_ERROR, 0
  field :LS_IN_PROGRESS, 1
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

defmodule Lgrpc.AccountCredentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field :username, 1, type: :string
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
          session_uuid: String.t()
        }
  defstruct [:result_code, :session_uuid]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :session_uuid, 2, type: :string
end

defmodule Lgrpc.JoinSessionRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session_uuid: String.t()
        }
  defstruct [:session_uuid]

  field :session_uuid, 1, type: :string
end

defmodule Lgrpc.JoinSessionResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.LobbyStreamRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          stream_message: {atom, any}
        }
  defstruct [:stream_message]

  oneof :stream_message, 0
  field :create_lobby, 1, type: Lgrpc.CreateLobbyRequest, oneof: 0
  field :join_lobby, 2, type: Lgrpc.JoinSessionRequest, oneof: 0
end

defmodule Lgrpc.LobbyStreamResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          stream_message: {atom, any}
        }
  defstruct [:stream_message]

  oneof :stream_message, 0
  field :create_lobby, 1, type: Lgrpc.CreateLobbyRequest, oneof: 0
  field :join_lobby, 2, type: Lgrpc.JoinSessionResponse, oneof: 0
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
          sessions: [Lgrpc.LobbyInfo.t()]
        }
  defstruct [:result_code, :sessions]

  field :result_code, 1, type: Lgrpc.ResultCode, enum: true
  field :sessions, 2, repeated: true, type: Lgrpc.LobbyInfo
end

defmodule Lgrpc.RegisterServerRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          port: non_neg_integer
        }
  defstruct [:port]

  field :port, 1, type: :uint32
end

defmodule Lgrpc.UnregisterServerRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.LaytonClient.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.LaytonClient"

  rpc :CreateAccount, Lgrpc.AccountCredentials, Lgrpc.Result
  rpc :Login, Lgrpc.AccountCredentials, Lgrpc.Result
  rpc :JoinLobbyStream, stream(Lgrpc.LobbyStreamRequest), stream(Lgrpc.LobbyStreamResponse)
  rpc :FindLobbies, Lgrpc.FindLobbiesRequest, Lgrpc.FindLobbiesResponse
end

defmodule Lgrpc.LaytonClient.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.LaytonClient.Service
end

defmodule Lgrpc.LaytonGameSession.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.LaytonGameSession"

  rpc :RegisterServer, Lgrpc.RegisterServerRequest, Lgrpc.Result
  rpc :UnregisterServer, Lgrpc.UnregisterServerRequest, Lgrpc.Result
end

defmodule Lgrpc.LaytonGameSession.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.LaytonGameSession.Service
end
