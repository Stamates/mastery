defmodule Mastery.Boundary.QuizSession do
  alias Mastery.Core.{Quiz, Response}
  use GenServer

  def child_spec({quiz, email}) do
    %{
      id: {__MODULE__, {quiz.title, email}},
      start: {__MODULE__, :start_link, [{quiz, email}]},
      restart: :temporary
    }
  end

  def init({quiz, email}), do: {:ok, {quiz, email}}

  # Client functions
  def start_link({quiz, email}) do
    GenServer.start_link(__MODULE__, {quiz, email}, name: via({quiz.title, email}))
  end

  def take_quiz(quiz, email) do
    DynamicSupervisor.start_child(Mastery.Supervisor.QuizSession, {__MODULE__, {quiz, email}})
  end

  def select_question(name), do: name |> via() |> GenServer.call(:select_question)

  def answer_question(name, answer),
    do: name |> via() |> GenServer.call({:answer_question, answer})

  defp via({_titel, _email} = name), do: {:via, Registry, {Mastery.Registry.QuizSession, name}}

  # Server functions
  def handle_call(:select_question, _from, {quiz, email}) do
    quiz = Quiz.select_question(quiz)
    {:reply, quiz.current_question.asked, {quiz, email}}
  end

  def handle_call({:answer_question, answer}, _from, {quiz, email}) do
    quiz
    |> Quiz.answer_question(Response.new(quiz, email, answer))
    |> Quiz.select_question()
    |> maybe_finish(email)
  end

  defp maybe_finish(nil, _email), do: {:stop, :normal, :finished, nil}

  defp maybe_finish(quiz, email) do
    {
      :reply,
      {quiz.current_question.asked, quiz.last_response.correct},
      {quiz, email}
    }
  end
end
