defmodule PentoWeb.WrongLive do
    use Phoenix.LiveView

    def mount(_params,session, socket) do
        {
            :ok, 
            assign(socket, 
            score: 0, 
            message: "Guess a number.", 
            time: time(), 
            number: number(), 
            winner: false,
            user: Pento.Accounts.get_user_by_session_token(session["user_token"]), 
            session_id: session["live_socket_id"])
        }
    end

    def render(assigns) do
        ~L"""
        <h1>Your score: <%= @score %></h1>
        <h2>
            <%= @message %>
            Date <%= @time %>
        </h2>

        <%= if @winner do %>
        <button phx-click="restart">
          Restart
        </button>
        <% end %>

        <%= if !@winner do %>
        <h2>
            <%= for n <- 1..10 do%>
                <a href="#" phx-click="guess" phx-value-number="<%= n %>"><%= n %></a>
            <% end %>
        </h2>
        <% end %>
        <pre>
        <%= @user.email %>
        <%= @session_id %>
        </pre>
        """
    end

    def time() do
        DateTime.utc_now |> to_string
    end

    def number() do
        Enum.random(1..10)
        |> to_string
    end

    def handle_event("guess", %{"number" => guess}=data, socket) do
        IO.inspect data
        IO.inspect number()
        if guess == number() do
          message = "!!!!Congratulations you guessed the number..."
          winner = true
          score = socket.assigns.score + 10
          {:noreply, assign(socket, score: score, message: message, number: number(), winner: winner)}
        else
        message = "Your guess: #{guess}. Wrong. Guess again."
        score = socket.assigns.score - 1
        {
            :noreply,
            assign(socket, message: message, score: score)
        }
        end
    end
    def handle_event("restart", %{"value" => _}, socket) do
        {
            :noreply,
            assign(socket, score: 0, message: "Guess a number.", number: number(), winner: false)
        }
    end
end