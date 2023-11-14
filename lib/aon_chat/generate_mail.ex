defmodule AonChat.GenerateMail do
  import Swoosh.Email
  alias AonChat.Mailer

  def send_reset_password_mail(user, token) do
    email =
      new()
      |> to({user.name, user.email})
      |> from({"Aon Chat", Application.get_env(:aon_chat, :support_mail)})
      |> subject("Password reset request")
      |> html_body("<h1>Hello #{user.name}</h1>")
      |> html_body(
        "Please <a href='#{Application.get_env(:aon_chat, :web_base_url)}/reset-password/#{token}'>click here</a> to reset your password"
      )

    {:ok, _metadata} = Mailer.deliver(email)
    :ok
  end
end
