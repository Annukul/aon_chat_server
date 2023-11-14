defmodule AonChatWeb.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :aon_chat,
    module: AonChat.Auth.Guardian,
    error_handler: AonChatWeb.AuthErrorHandler

  plug Guardian.Plug.VerifyHeader, claims: %{typ: "access"}
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
