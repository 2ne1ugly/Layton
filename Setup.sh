#!/bin/bash
protoc --proto_path=proto --elixir_out=plugins=grpc:lib layton.proto