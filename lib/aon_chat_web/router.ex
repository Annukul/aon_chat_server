defmodule AonChatWeb.Router do
  use AonChatWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AonChatWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AonChatWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  pipeline :jwt_authenticated do
    plug AonChatWeb.AuthPipeline
  end

  scope "/api/v1", AonChatWeb.Api.V1 do
    pipe_through [:api]
    # User authentication
    post "/sign-up", AuthController, :sign_up
    post "/sign-in", AuthController, :sign_in
    post "/reset-password", AuthController, :reset_password_request
    post "/reset-password/:token", AuthController, :change_password
  end

  scope "/api/v1", AonChatWeb.Api.V1 do
    pipe_through [:api, :jwt_authenticated]

    get "/me", AuthController, :index_user
  end

  # Other scopes may use custom stacks.
  # scope "/api", AonChatWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:aon_chat, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AonChatWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
