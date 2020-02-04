defmodule Lgrpc.EResultCode do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :ERC_SUCCESS | :ERC_FAIL

  field :ERC_SUCCESS, 0
  field :ERC_FAIL, 1
end

defmodule Lgrpc.Result do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          result_code: Lgrpc.EResultCode.t()
        }
  defstruct [:result_code]

  field :result_code, 1, type: Lgrpc.EResultCode, enum: true
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

defmodule Lgrpc.Layton.Service do
  @moduledoc false
  use GRPC.Service, name: "lgrpc.Layton"

  rpc :CreateAccount, Lgrpc.AccountCredentials, Lgrpc.Result
  rpc :Login, Lgrpc.AccountCredentials, Lgrpc.Result
end

defmodule Lgrpc.Layton.Stub do
  @moduledoc false
  use GRPC.Stub, service: Lgrpc.Layton.Service
end
