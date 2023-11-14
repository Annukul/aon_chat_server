defmodule AonChatWeb.Api.V1.AuthController do
  use AonChatWeb, :controller

  alias AonChat.Auth.Guardian

  alias AonChat.Schema.User
  alias AonChat.Users
  alias AonChat.GenerateMail

  require Logger

  def index_user(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    json(conn, %{
      user: user
    })
  end

  def sign_up(conn, params) do
    with {:ok, %User{} = user} <- Users.create_user(params),
         {:ok, token, _claims} <- Guardian.encode_and_sign(user, %{}, ttl: {7, :days}) do
      json(conn, %{token: token})
    else
      {:error, changeset} ->
        error = Enum.at(changeset.errors, 0)

        case error do
          {:password_virtual, _} ->
            conn
            |> put_status(:bad_request)
            |> json(%{message: "Opps! Your password should be at least 8 characters."})

          {:email, _} ->
            conn
            |> put_status(:conflict)
            |> json(%{message: "Opps! Email already in use. Please login or use another email."})

          _ ->
            conn |> put_status(:bad_request) |> json(%{message: "Invalid parameters."})
        end
    end
  end

  def sign_in(conn, %{"email" => email, "password" => password}) do
    case Users.sign_in_and_get_token(email, password) do
      {:ok, token, _claims} ->
        json(conn, %{token: token})

      _ ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "Invalid email or password"})
    end
  end

  def reset_password_request(conn, %{"email" => email}) do
    if user = Users.get_user_by_email!(email) do
      {:ok, token, _} = Guardian.encode_and_sign(user, %{}, ttl: {10, :minute})
      Users.update_reset_token(user, token)
      GenerateMail.send_reset_password_mail(user, token)
    end

    json(conn, %{
      message:
        "You will receive instructions on your email to reset your password shortly. Link will be valid for 10 minutes."
    })
  end

  def change_password(conn, %{"password" => password, "token" => token}) do
    case Guardian.decode_and_verify(token) do
      {:ok, claims} ->
        id = claims["sub"]

        {:ok, _user} =
          id
          |> Users.get_user!()
          |> Users.update_password(password)

        conn
        |> put_status(:ok)
        |> json(%{message: "Password changed successfully. Please proceed to sign in."})

      {:error, :token_expired} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "This link has expired. Please request a new link."})

      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "This link is invalid. Please request a new link."})
    end
  end
end
