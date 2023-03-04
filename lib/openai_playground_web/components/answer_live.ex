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

  defp stream_response(stream) do
    target = self()

    Task.Supervisor.async(OpenaiPlayground.TaskSupervisor, fn ->
      for chunk <- stream, into: <<>> do
        send(target, {:render_response_chunk, chunk})
        chunk
      end
    end)
  end

  @impl true
  def handle_event("answer_question", %{"question" => question}, socket) do
    prompt = prompt(question)
    stream = OpenaiPlayground.OpenAI.stream(prompt)

    socket =
      socket
      |> assign(:question, question)
      |> assign(:state, :answering_question)
      |> assign(:response_task, stream_response(stream))

    {:noreply, socket}
  end

  defp prompt(question) do
    """
    Answer the following question.
    Question: #{question}
    Answer:
    """
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex flex-col max-w-4xl min-h-screen items-center">
      <h1 class="text-2xl">Ask Me Anything</h1>
      <.simple_form :let={f} for={%{}} as={:question} phx-submit="answer_question" class="w-full">
        <%!-- field={{f, :question}}
          value={@question} disabled={@state != :waiting_for_question}  --%>
        <%!-- <input type="text" /> --%>
        <%!-- <.input name="some_input" /> --%>
        <%!-- <.input field={@form[:email]} label="Email"/> --%>
        <%!-- disabled={@state != :waiting_for_question} --%>
        <.input name="question" value={@question} label="Username" />
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

  @impl true
  def handle_info({:render_response_chunk, chunk}, socket) do
    answer = socket.assigns.answer <> chunk
    {:noreply, assign(socket, :answer, answer)}
  end

  def handle_info({ref, answer}, socket) when socket.assigns.response_task.ref == ref do
    socket =
      socket
      |> assign(:answer, answer)
      |> assign(:state, :waiting_for_question)

    {:noreply, socket}
  end

  def handle_info(_message, socket) do
    {:noreply, socket}
  end
end
