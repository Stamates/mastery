alias Mastery.Examples.Math
alias Mastery.Boundary.QuizSession
now = DateTime.utc_now()
five_seconds_from_now = DateTime.add(now, 5)
one_minute_from_now = DateTime.add(now, 60)

# # Schedule a quiz
# Mastery.schedule_quiz(Math.quiz_fields(), [Math.template_fields()], five_seconds_from_now, one_minute_from_now)
# session = Mastery.take_quiz(Math.quiz_fields().title, "james@graysoftinc.com")
# QuizSession.active_sessions_for(Math.quiz_fields().title)

# # Take quiz
# Mastery.select_question session
# Mastery.answer_question session, "wrong"
