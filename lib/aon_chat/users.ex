defmodule AonChat.Users do
  require Logger

  import Ecto.Query, warn: false
  alias AonChat.Repo

  alias AonChat.Schema.{
    User
  }

  alias AonChat.Auth.Guardian

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> Ecto.Changeset.change(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  def get_user_by_email!(email), do: Repo.get_by(User, email: email)

  def update_reset_token(%User{} = user, token) do
    Ecto.Changeset.change(user, reset_token: token) |> Repo.update()
  end

  def update_password(%User{} = user, password) do
    Ecto.Changeset.change(user, password: Comeonin.Bcrypt.hashpwsalt(password)) |> Repo.update()
  end

  def sign_in_and_get_token(email, password) do
    case email_password_auth(email, password) do
      {:ok, user} ->
        Guardian.encode_and_sign(user)

      _ ->
        {:error, :unauthorized}
    end
  end

  defp email_password_auth(email, password) when is_binary(email) and is_binary(password) do
    with {:ok, user} <- get_by_email(email) do
      verify_password(password, user)
    end
  end

  defp get_by_email(email) when is_binary(email) do
    case Repo.get_by(User, email: email) do
      nil ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, "No user found with this email!"}

      user ->
        {:ok, user}
    end
  end

  defp verify_password(password, %User{} = user) when is_binary(password) do
    if Comeonin.Bcrypt.checkpw(password, user.password) do
      {:ok, user}
    else
      {:error, :invalid_password}
    end
  end
end
