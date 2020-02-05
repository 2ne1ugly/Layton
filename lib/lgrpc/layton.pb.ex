defmodule Lgrpc.EResultCode do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :ERC_ERROR | :ERC_SUCCESS | :ERC_FAIL

  field(:ERC_ERROR, 0)
  field(:ERC_SUCCESS, 1)
  field(:ERC_FAIL, 2)
end

defmodule Lgrpc.Result do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.EResultCode.t()
        }
  defstruct [:result_code]

  field(:result_code, 1, type: Lgrpc.EResultCode, enum: true)
end

defmodule Lgrpc.AccountCredentials do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          username: String.t()
        }
  defstruct [:username]

  field(:username, 1, type: :string)
end

defmodule Lgrpc.SessionInfo do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          session_name: String.t()
        }
  defstruct [:session_name]

  field(:session_name, 1, type: :string)
end

defmodule Lgrpc.FindSessionsRequest do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{}
  defstruct []
end

defmodule Lgrpc.FindSessionsResponse do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.EResultCode.t(),
          sessions: [Lgrpc.SessionInfo.t()]
        }
  defstruct [:result_code, :sessions]

  field(:result_code, 1, type: Lgrpc.EResultCode, enum: true)
  field(:sessions, 2, repeated: true, type: Lgrpc.SessionInfo)
end

defmodule Lgrpc.Layton.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.Layton"

  rpc(:CreateAccount, Lgrpc.AccountCredentials, Lgrpc.Result)
  rpc(:Login, Lgrpc.AccountCredentials, Lgrpc.Result)
  rpc(:CreateSession, Lgrpc.SessionInfo, Lgrpc.Result)
  rpc(:FindSessions, Lgrpc.FindSessionsRequest, Lgrpc.FindSessionsResponse)
  rpc(:JoinSession, Lgrpc.SessionInfo, Lgrpc.Result)
  rpc(:StartSession, Lgrpc.SessionInfo, Lgrpc.Result)
end

defmodule Lgrpc.Layton.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.Layton.Service
end
