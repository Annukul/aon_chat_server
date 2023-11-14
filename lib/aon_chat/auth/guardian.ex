defmodule AonChat.Auth.Guardian do
  use Guardian, otp_app: :aon_chat

  @impl true
  def build_claims(claims, user, _opts) do
    {:ok, Map.put(claims, "version", user.access_token_version)}
  end

  @impl true
  def subject_for_token(user, _claims) do
    sub = to_string(user.id)
    {:ok, sub}
  end

  @impl true
  def resource_from_claims(claims) do
    id = claims["sub"]
    version = claims["version"]

    case AonChat.Users.get_user!(id) do
      nil ->
        {:error, :not_found}

      user ->
        if user.access_token_version != version || is_nil(user.access_token_version) do
          {:error, :unauthorized}
        else
          {:ok, user}
        end
    end
  end
end
