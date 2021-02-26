defmodule Mastery.Core.Quiz do
  alias Mastery.Core.{Template, Question, Response}

  defstruct title: nil,
            mastery: 3,
            templates: %{},
            used: [],
            current_question: nil,
            last_response: nil,
            record: %{},
            mastered: []

  def new(fields) do
    struct!(__MODULE__, fields)
  end

  def add_template(quiz, fields) do
    template = Template.new(fields)

    templates = update_in(quiz.templates, [template.category], &add_to_list_or_nil(&1, template))
    %{quiz | templates: templates}
  end

  def answer_question(quiz, %Response{correct: true} = response) do
    new_quiz =
      quiz
      |> inc_record()
      |> save_response(response)

    maybe_advance(new_quiz, mastered?(new_quiz))
  end

  def answer_question(quiz, %Response{correct: false} = response) do
    quiz
    |> reset_record()
    |> save_response(response)
  end

  def mastered?(quiz) do
    score = Map.get(quiz.record, template(quiz).name, 0)
    score == quiz.mastery
  end

  def save_response(quiz, response), do: Map.put(quiz, :last_response, response)

  def select_question(%__MODULE__{templates: t}) when map_size(t) == 0, do: nil

  def select_question(quiz) do
    quiz
    |> pick_current_question()
    |> move_template(:used)
    |> reset_template_cycle()
  end

  defp advance(quiz), do: quiz |> move_template(:mastered) |> reset_record() |> reset_used()

  defp add_template_to_field(quiz, field) do
    template = template(quiz)
    %{quiz | used: [template | Map.get(quiz, field)]}
  end

  defp add_to_list_or_nil(nil, template), do: [template]
  defp add_to_list_or_nil(templates, template), do: [template | templates]

  defp inc_record(quiz) do
    template = template(quiz)
    updated_record = Map.update(quiz.record, template.name, 1, &(&1 + 1))
    %{quiz | record: updated_record}
  end

  defp pick_current_question(quiz) do
    Map.put(quiz, :current_question, select_a_random_question(quiz))
  end

  defp maybe_advance(quiz, true = _mastered), do: advance(quiz)
  defp maybe_advance(quiz, false = _mastered), do: quiz

  defp move_template(quiz, field) do
    quiz
    |> remove_template_from_category()
    |> add_template_to_field(field)
  end

  defp remove_template_from_category(quiz) do
    template = template(quiz)

    new_category_templates =
      quiz.templates |> Map.fetch!(template.category) |> List.delete(template)

    new_templates =
      if new_category_templates == [] do
        Map.delete(quiz.templates, template.category)
      else
        Map.put(quiz.templates, template.category, new_category_templates)
      end

    %{quiz | templates: new_templates}
  end

  defp reset_record(quiz) do
    template = template(quiz)
    updated_record = Map.delete(quiz.record, template.name)
    %{quiz | record: updated_record}
  end

  defp reset_template_cycle(%{templates: templates, used: used} = quiz)
       when map_size(templates) == 0 do
    %{quiz | templates: Enum.group_by(used, & &1.category), used: []}
  end

  defp reset_template_cycle(quiz), do: quiz

  defp reset_used(quiz) do
    template = template(quiz)
    updated_used = List.delete(quiz.used, template)
    %{quiz | used: updated_used}
  end

  defp select_a_random_question(quiz) do
    quiz.templates
    |> Enum.random()
    |> elem(1)
    |> Enum.random()
    |> Question.new()
  end

  defp template(%__MODULE__{current_question: %Question{template: template}}), do: template
end
