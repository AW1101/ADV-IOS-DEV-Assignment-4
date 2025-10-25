//
//  RETHINKATests.swift
//  RETHINKATests
//
//  Created by Aston Walsh on 23/10/2025.
//

import XCTest
import SwiftData
@testable import RETHINKA

@MainActor
final class QuizQuestionTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        // Createin-memory model container for testing
        let schema = Schema([
            ExamTimeline.self,
            QuizQuestion.self,
            CourseNote.self,
            DailyQuiz.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        context = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        context = nil
    }
    
    // Multiple Choice Tests
    
    func testMultipleChoiceCorrectAnswer() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 1,
            topic: "Math"
        )
        
        // When
        question.selectedAnswerIndex = 1
        
        // Then
        XCTAssertTrue(question.isAnsweredCorrectly, "Should recognize correct answer")
        XCTAssertTrue(question.isAnswered, "Should be marked as answered")
    }
    
    func testMultipleChoiceIncorrectAnswer() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 1,
            topic: "Math"
        )
        
        // When
        question.selectedAnswerIndex = 0
        
        // Then
        XCTAssertFalse(question.isAnsweredCorrectly, "Should recognize incorrect answer")
        XCTAssertTrue(question.isAnswered, "Should be marked as answered")
    }
    
    func testMultipleChoiceNotAnswered() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 1,
            topic: "Math"
        )
        
        // Then
        XCTAssertFalse(question.isAnswered, "Should not be marked as answered")
        XCTAssertFalse(question.isAnsweredCorrectly, "Should not be correct if not answered")
    }
    
    // Text Field Tests
    
    func testTextFieldExactMatch() throws {
        // Given
        let question = QuizQuestion(
            question: "What is the capital of France?",
            options: ["Paris", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Geography",
            type: "textField"
        )
        
        // When
        question.userAnswer = "Paris"
        
        // Then
        XCTAssertTrue(question.isAnsweredCorrectly, "Should accept exact match")
        XCTAssertTrue(question.isAnswered, "Should be marked as answered")
    }
    
    func testTextFieldCaseInsensitive() throws {
        // Given
        let question = QuizQuestion(
            question: "What is the capital of France?",
            options: ["Paris", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Geography",
            type: "textField"
        )
        
        // When
        question.userAnswer = "PARIS"
        
        // Then
        XCTAssertTrue(question.isAnsweredCorrectly, "Should be case insensitive")
    }
    
    func testTextFieldWhitespaceHandling() throws {
        // Given
        let question = QuizQuestion(
            question: "What is the capital of France?",
            options: ["Paris", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Geography",
            type: "textField"
        )
        
        // When
        question.userAnswer = "  Paris  "
        
        // Then
        XCTAssertTrue(question.isAnsweredCorrectly, "Should trim whitespace")
    }
    
    func testTextFieldPartialMatch() throws {
        // Given
        let question = QuizQuestion(
            question: "What is a programming paradigm?",
            options: ["Object Oriented Programming", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Programming",
            type: "textField"
        )
        
        // When - User provides key words (>40% match)
        question.userAnswer = "object oriented"
        
        // Then
        XCTAssertTrue(question.isAnsweredCorrectly, "Should accept partial match with >40% key words")
    }
    
    func testTextFieldInsufficientMatch() throws {
        // Given
        let question = QuizQuestion(
            question: "What is a programming paradigm?",
            options: ["Object Oriented Programming", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Programming",
            type: "textField"
        )
        
        // When - User provides insufficient key words
        question.userAnswer = "programming"
        
        // Then
        XCTAssertFalse(question.isAnsweredCorrectly, "Should reject insufficient match")
    }
    
    func testTextFieldEmptyAnswer() throws {
        // Given
        let question = QuizQuestion(
            question: "What is the capital of France?",
            options: ["Paris", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Geography",
            type: "textField"
        )
        
        // When
        question.userAnswer = ""
        
        // Then
        XCTAssertFalse(question.isAnswered, "Empty answer should not count as answered")
        XCTAssertFalse(question.isAnsweredCorrectly, "Empty answer should not be correct")
    }
    
    func testTextFieldNilAnswer() throws {
        // Given
        let question = QuizQuestion(
            question: "What is the capital of France?",
            options: ["Paris", "", "", ""],
            correctAnswerIndex: 0,
            topic: "Geography",
            type: "textField"
        )
        
        // When
        question.userAnswer = nil
        
        // Then
        XCTAssertFalse(question.isAnswered, "Nil answer should not count as answered")
        XCTAssertFalse(question.isAnsweredCorrectly, "Nil answer should not be correct")
    }
    
    // Correct Answer Property Tests
    
    func testCorrectAnswerRetrievalValid() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 1,
            topic: "Math"
        )
        
        // Then
        XCTAssertEqual(question.correctAnswer, "4", "Should return correct answer string")
    }
    
    func testCorrectAnswerRetrievalInvalidIndex() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 10, // Invalid index
            topic: "Math"
        )
        
        // Then
        XCTAssertEqual(question.correctAnswer, "No answer available", "Should handle invalid index")
    }
    
    // Times Answered Incorrectly
    
    func testTimesAnsweredIncorrectlyInitialValue() throws {
        // Given
        let question = QuizQuestion(
            question: "What is 2 + 2?",
            options: ["3", "4", "5", "6"],
            correctAnswerIndex: 1,
            topic: "Math"
        )
        
        // Then
        XCTAssertEqual(question.timesAnsweredIncorrectly, 0, "Should initialize to 0")
    }
}

@MainActor
final class ExamTimelineTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        let schema = Schema([
            ExamTimeline.self,
            QuizQuestion.self,
            CourseNote.self,
            DailyQuiz.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        context = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        context = nil
    }
    
    // Days Until Exam Tests
    
    func testDaysUntilExamTomorrow() throws {
        // Given
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: tomorrow
        )
        
        // Then
        XCTAssertEqual(timeline.daysUntilExam, 1, "Should show 1 day for tomorrow's exam")
    }
    
    func testDaysUntilExamPast() throws {
        // Given
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: yesterday
        )
        
        // Then
        XCTAssertEqual(timeline.daysUntilExam, 0, "Should show 0 days for past exam")
    }
    
    // Quiz Count Tests
    
    func testTotalQuizCountEmpty() throws {
        // Given
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: Date()
        )
        
        // Then
        XCTAssertEqual(timeline.totalQuizCount, 0, "Should have 0 quizzes initially")
    }
    
    func testCompletedQuizCountEmpty() throws {
        // Given
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: Date()
        )
        
        // Then
        XCTAssertEqual(timeline.completedQuizCount, 0, "Should have 0 completed quizzes initially")
    }
    
    func testProgressPercentageEmpty() throws {
        // Given
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: Date()
        )
        
        // Then
        XCTAssertEqual(timeline.progressPercentage, 0.0, "Should have 0% progress initially")
    }
    
    func testProgressPercentageHalfComplete() throws {
        // Given
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: Date()
        )
        
        let quiz1 = DailyQuiz(date: Date(), examTimelineId: timeline.id, dayNumber: 1)
        quiz1.isCompleted = true
        
        let quiz2 = DailyQuiz(date: Date(), examTimelineId: timeline.id, dayNumber: 2)
        quiz2.isCompleted = false
        
        timeline.dailyQuizzes = [quiz1, quiz2]
        
        // Then
        XCTAssertEqual(timeline.totalQuizCount, 2, "Should have 2 total quizzes")
        XCTAssertEqual(timeline.completedQuizCount, 1, "Should have 1 completed quiz")
        XCTAssertEqual(timeline.progressPercentage, 0.5, accuracy: 0.01, "Should be 50% complete")
    }
    
    func testProgressPercentageFullyComplete() throws {
        // Given
        let timeline = ExamTimeline(
            examName: "Test Exam",
            examBrief: "Brief",
            examDate: Date()
        )
        
        let quiz1 = DailyQuiz(date: Date(), examTimelineId: timeline.id, dayNumber: 1)
        quiz1.isCompleted = true
        
        let quiz2 = DailyQuiz(date: Date(), examTimelineId: timeline.id, dayNumber: 2)
        quiz2.isCompleted = true
        
        timeline.dailyQuizzes = [quiz1, quiz2]
        
        // Then
        XCTAssertEqual(timeline.progressPercentage, 1.0, "Should be 100% complete")
    }
    
    // Initialization Tests
    
    func testTimelineInitialization() throws {
        // Given
        let examDate = Date()
        let timeline = ExamTimeline(
            examName: "iOS Development",
            examBrief: "Learn Swift and SwiftUI",
            examDate: examDate
        )
        
        // Then
        XCTAssertNotNil(timeline.id, "Should have an ID")
        XCTAssertEqual(timeline.examName, "iOS Development")
        XCTAssertEqual(timeline.examBrief, "Learn Swift and SwiftUI")
        XCTAssertEqual(timeline.examDate, examDate)
        XCTAssertTrue(timeline.isActive, "Should be active by default")
        XCTAssertEqual(timeline.notes.count, 0, "Should have no notes initially")
        XCTAssertEqual(timeline.dailyQuizzes.count, 0, "Should have no quizzes initially")
    }
}

@MainActor
final class DailyQuizTests: XCTestCase {
    
    var modelContainer: ModelContainer!
    var context: ModelContext!
    
    override func setUpWithError() throws {
        let schema = Schema([
            ExamTimeline.self,
            QuizQuestion.self,
            CourseNote.self,
            DailyQuiz.self
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        
        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        
        context = ModelContext(modelContainer)
    }
    
    override func tearDownWithError() throws {
        modelContainer = nil
        context = nil
    }
    
    // Initialization Tests
    
    func testDailyQuizInitialization() throws {
        // Given
        let date = Date()
        let timelineId = UUID()
        let quiz = DailyQuiz(
            date: date,
            examTimelineId: timelineId,
            dayNumber: 1,
            topic: "SwiftUI"
        )
        
        // Then
        XCTAssertNotNil(quiz.id)
        XCTAssertEqual(quiz.date, date)
        XCTAssertEqual(quiz.examTimelineId, timelineId)
        XCTAssertEqual(quiz.dayNumber, 1)
        XCTAssertEqual(quiz.topic, "SwiftUI")
        XCTAssertFalse(quiz.isCompleted)
        XCTAssertNil(quiz.score)
        XCTAssertNil(quiz.completedDate)
        XCTAssertEqual(quiz.questions.count, 0)
    }
    
    func testDailyQuizDefaultTopic() throws {
        // Given
        let quiz = DailyQuiz(
            date: Date(),
            examTimelineId: UUID(),
            dayNumber: 1
        )
        
        // Then
        XCTAssertEqual(quiz.topic, "General", "Should default to 'General' topic")
    }
    
    // Answer Count Tests
    
    func testCorrectAnswerCount() throws {
        // Given
        let quiz = DailyQuiz(
            date: Date(),
            examTimelineId: UUID(),
            dayNumber: 1
        )
        
        let q1 = QuizQuestion(question: "Q1", options: ["A", "B"], correctAnswerIndex: 0)
        q1.selectedAnswerIndex = 0 // Correct
        
        let q2 = QuizQuestion(question: "Q2", options: ["A", "B"], correctAnswerIndex: 1)
        q2.selectedAnswerIndex = 0 // Incorrect
        
        let q3 = QuizQuestion(question: "Q3", options: ["A", "B"], correctAnswerIndex: 1)
        q3.selectedAnswerIndex = 1 // Correct
        
        quiz.questions = [q1, q2, q3]
        
        // Then
        XCTAssertEqual(quiz.correctAnswerCount, 2, "Should count 2 correct answers")
        XCTAssertEqual(quiz.incorrectAnswerCount, 1, "Should count 1 incorrect answer")
    }
    
    func testCorrectAnswerCountEmpty() throws {
        // Given
        let quiz = DailyQuiz(
            date: Date(),
            examTimelineId: UUID(),
            dayNumber: 1
        )
        
        // Then
        XCTAssertEqual(quiz.correctAnswerCount, 0, "Should have 0 correct answers")
        XCTAssertEqual(quiz.incorrectAnswerCount, 0, "Should have 0 incorrect answers")
    }
    
    func testScoreCalculation() throws {
        // Given
        let quiz = DailyQuiz(
            date: Date(),
            examTimelineId: UUID(),
            dayNumber: 1
        )
        
        let q1 = QuizQuestion(question: "Q1", options: ["A", "B"], correctAnswerIndex: 0)
        q1.selectedAnswerIndex = 0 // Correct
        
        let q2 = QuizQuestion(question: "Q2", options: ["A", "B"], correctAnswerIndex: 1)
        q2.selectedAnswerIndex = 1 // Correct
        
        let q3 = QuizQuestion(question: "Q3", options: ["A", "B"], correctAnswerIndex: 1)
        q3.selectedAnswerIndex = 0 // Incorrect
        
        let q4 = QuizQuestion(question: "Q4", options: ["A", "B"], correctAnswerIndex: 0)
        q4.selectedAnswerIndex = 0 // Correct
        
        quiz.questions = [q1, q2, q3, q4]
        
        // When
        let expectedScore = 3.0 / 4.0 // 75%
        quiz.score = Double(quiz.correctAnswerCount) / Double(quiz.questions.count)
        quiz.isCompleted = true
        
        // Then
        XCTAssertNotNil(quiz.score, "Score should not be nil")
        XCTAssertEqual(quiz.score!, expectedScore, accuracy: 0.01, "Should calculate 75% score")
        XCTAssertTrue(quiz.isCompleted, "Should be marked as completed")
    }
}
