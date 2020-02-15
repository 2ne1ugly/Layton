defmodule Lgrpc.ResultCode do
  @moduledoc false
  use Protobuf, enum: true, syntax: :proto3

  @type t :: integer | :RC_ERROR | :RC_SUCCESS | :RC_FAIL

  field :RC_ERROR, 0
  field :RC_SUCCESS, 1
  field :RC_FAIL, 2
end
