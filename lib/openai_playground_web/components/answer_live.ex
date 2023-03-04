defmodule OpenaiPlaygroundWeb.AnswerLive do
  use OpenaiPlaygroundWeb, :live_view

  import OpenaiPlaygroundWeb.CoreComponents

  @impl true
  def mount(_session, _params, socket) do
    socket =
      socket
      |> assign(:question, "")
      |> assign(:answer, "")
      |> assign(:state, :waiting_for_question)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col max-w-4xl min-h-screen items-center">
      <h1 class="text-2xl">Ask Me Anything</h1>
      <.simple_form :let={f} for={%{}} as={:question} phx-submit="answer_question" class="w-full">
        <%!-- <.input
          disabled={@state != :waiting_for_question}
          field={{f, :question}}
          value={@question}
          type="text"
        /> --%>
        <.button
          type="submit"
          disabled={@state != :waiting_for_question}
          phx-disabled-with="Answering..."
        >
          Answer Question
        </.button>
      </.simple_form>
      <div class="mt-4 text-md">
        <p><span class="font-semibold">Question:</span> <%= @question %></p>
        <p><span class="font-semibold">Answer:</span><%= @answer %></p>
      </div>
    </div>
    """
  end
end
