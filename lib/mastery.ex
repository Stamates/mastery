defmodule Mastery do
  @moduledoc """
  Documentation for `Mastery`.
  """
  alias Mastery.Boundary.{QuizSession, QuizManager}
  alias Mastery.Boundary.{TemplateValidator, QuizValidator}
  alias Mastery.Core.Quiz

  def start_quiz_manager() do
    GenServer.start_link(QuizManager, %{}, name: QuizManager)
  end

  def build_quiz(fields) do
    with :ok <- QuizValidator.errors(fields),
         :ok <- QuizManager.build_quiz(fields),
         do: :ok
  end

  def add_template(title, fields) do
    with :ok <- TemplateValidator.errors(fields),
         :ok <- QuizManager.add_template(title, fields),
         do: :ok
  end

  def take_quiz(title, email) do
    with %Quiz{} = quiz <- QuizManager.lookup_quiz_by_title(title),
         {:ok, session} <- GenServer.start_link(QuizSession, {quiz, email}),
         do: session
  end

  def select_question(session), do: QuizSession.select_question(session)
  def answer_question(session, answer), do: QuizSession.answer_question(session, answer)
end
