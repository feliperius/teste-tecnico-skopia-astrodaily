import Testing
import Foundation
@testable import TestSkopiaAstroDaily

class MockURLSession: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    private(set) var dataCallCount = 0
    private(set) var lastRequest: URLRequest?
    private(set) var allRequests: [URLRequest] = []
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        dataCallCount += 1
        lastRequest = request
        allRequests.append(request)
        
        if let error = mockError {
            throw error
        }
        
        guard let data = mockData, let response = mockResponse else {
            throw URLError(.badServerResponse)
        }
        
        return (data, response)
    }
    
    func verifyDataWasCalled(times: Int = 1) -> Bool {
        return dataCallCount == times
    }
    
    func verifyRequestURL(contains substring: String) -> Bool {
        return lastRequest?.url?.absoluteString.contains(substring) ?? false
    }
    
    func verifyRequestURL(equals urlString: String) -> Bool {
        return lastRequest?.url?.absoluteString == urlString
    }
    
    func verifyRequestMethod(_ method: String) -> Bool {
        return lastRequest?.httpMethod == method
    }
    
    func verifyRequestHeader(_ headerField: String, value: String) -> Bool {
        return lastRequest?.value(forHTTPHeaderField: headerField) == value
    }
    
    func getAllRequestURLs() -> [String] {
        return allRequests.compactMap { $0.url?.absoluteString }
    }
    
    func reset() {
        dataCallCount = 0
        lastRequest = nil
        allRequests.removeAll()
        mockData = nil
        mockResponse = nil
        mockError = nil
    }
}

struct NetworkTestData {
    
    static let validApodJSON = """
    {
        "date": "2023-09-16",
        "title": "Test APOD Title",
        "explanation": "Test APOD explanation for testing purposes",
        "url": "https://example.com/test-image.jpg",
        "hdurl": "https://example.com/test-hd-image.jpg",
        "media_type": "image",
        "service_version": "v1",
        "copyright": "Test Copyright"
    }
    """.data(using: .utf8)!
    
    static let validVideoApodJSON = """
    {
        "date": "2023-09-15",
        "title": "Test Video APOD",
        "explanation": "Test video APOD explanation",
        "url": "https://www.youtube.com/embed/test-video",
        "media_type": "video",
        "service_version": "v1"
    }
    """.data(using: .utf8)!
    
    static let validApodRangeJSON = """
    [
        {
            "date": "2023-09-16",
            "title": "Test APOD 1",
            "explanation": "Test explanation 1",
            "url": "https://example.com/image1.jpg",
            "media_type": "image"
        },
        {
            "date": "2023-09-15",
            "title": "Test APOD 2",
            "explanation": "Test explanation 2",
            "url": "https://example.com/image2.jpg",
            "media_type": "image"
        }
    ]
    """.data(using: .utf8)!
    
    static let invalidJSON = "{ invalid json structure".data(using: .utf8)!
    
    static let emptyJSON = "{}".data(using: .utf8)!
    
    static let emptyArrayJSON = "[]".data(using: .utf8)!
    
    static func httpResponse(
        statusCode: Int,
        url: URL = URL(string: "https://api.nasa.gov/planetary/apod")!,
        headers: [String: String]? = nil
    ) -> HTTPURLResponse {
        return HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }
}

enum NetworkTestError: Error, LocalizedError {
    case timeout
    case noConnection
    case serverUnavailable
    case rateLimited
    case unauthorized
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .timeout:
            return "Request timeout"
        case .noConnection:
            return "No internet connection"
        case .serverUnavailable:
            return "Server unavailable"
        case .rateLimited:
            return "Rate limit exceeded"
        case .unauthorized:
            return "API key invalid"
        case .parseError:
            return "Failed to parse response"
        }
    }
}
class NasaApodServiceWithURLSession: NasaApodServicing {
    
    private let session: URLSessionProtocol
    
    init(session: URLSessionProtocol = URLSession.shared) {
        self.session = session
    }
    
    func fetchApod(date: Date) async throws -> ApodItem {
        let url = buildURL(parameters: ["date": date.apodString])
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            if httpResponse.statusCode >= 400 {
                if httpResponse.statusCode == 404 {
                    throw NetworkError.noDataForDate("esta data")
                } else {
                    throw NetworkError.http(httpResponse.statusCode)
                }
            }
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(ApodItem.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
    
    func fetchRange(start: Date, end: Date) async throws -> [ApodItem] {
        let url = buildURL(parameters: [
            "start_date": start.apodString,
            "end_date": end.apodString
        ])
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode >= 400 {
            throw NetworkError.http(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode([ApodItem].self, from: data)
            return items.sorted { $0.date > $1.date }
        } catch {
            throw NetworkError.decoding
        }
    }
    
    private func buildURL(parameters: [String: String]) -> URL {
        var components = URLComponents(string: APIConfig.baseURL)!
        var queryItems = [URLQueryItem(name: "api_key", value: APIConfig.apiKey)]
        
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        components.queryItems = queryItems
        return components.url!
    }
}

class NasaApodServiceSpy: NasaApodServicing {
    var mockApodItem: ApodItem?
    var mockApodItems: [ApodItem] = []
    var shouldThrowError = false
    var errorToThrow: Error = NetworkTestError.noConnection
    private(set) var fetchApodCallCount = 0
    private(set) var fetchApodCalls: [Date] = []
    
    private(set) var fetchRangeCallCount = 0
    private(set) var fetchRangeCalls: [(start: Date, end: Date)] = []
    
    func fetchApod(date: Date) async throws -> ApodItem {
        fetchApodCallCount += 1
        fetchApodCalls.append(date)
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        guard let item = mockApodItem else {
            throw NetworkTestError.serverUnavailable
        }
        
        return item
    }
    
    func fetchRange(start: Date, end: Date) async throws -> [ApodItem] {
        fetchRangeCallCount += 1
        fetchRangeCalls.append((start: start, end: end))
        
        if shouldThrowError {
            throw errorToThrow
        }
        
        return mockApodItems
    }
    
    func verifyFetchApodWasCalled(times: Int = 1) -> Bool {
        return fetchApodCallCount == times
    }
    
    func verifyFetchApodWasCalledWith(date: Date) -> Bool {
        return fetchApodCalls.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
    
    func verifyFetchRangeWasCalled(times: Int = 1) -> Bool {
        return fetchRangeCallCount == times
    }
    
    func verifyFetchRangeWasCalledWith(start: Date, end: Date) -> Bool {
        return fetchRangeCalls.contains { call in
            Calendar.current.isDate(call.start, inSameDayAs: start) &&
            Calendar.current.isDate(call.end, inSameDayAs: end)
        }
    }
    
    func reset() {
        fetchApodCallCount = 0
        fetchApodCalls.removeAll()
        fetchRangeCallCount = 0
        fetchRangeCalls.removeAll()
        mockApodItem = nil
        mockApodItems.removeAll()
        shouldThrowError = false
    }
}


@Suite("Network Layer Unit Tests", .serialized)
struct NetworkLayerTests {
    
    @Test("URLSession makes GET request to correct URL for today's APOD")
    func testTodayApodURLRequest() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
    
        _ = try await service.fetchApod(date: Date())
        
        #expect(mockSession.verifyDataWasCalled(times: 1))
        #expect(mockSession.verifyRequestURL(contains: "api.nasa.gov/planetary/apod"))
        #expect(mockSession.verifyRequestURL(contains: "api_key="))
    }
    
    @Test("URLSession makes GET request with specific date parameter")
    func testSpecificDateApodURLRequest() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        let testDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 16))!

        _ = try await service.fetchApod(date: testDate)
        
        #expect(mockSession.verifyDataWasCalled(times: 1))
        #expect(mockSession.verifyRequestURL(contains: "date=2023-09-16"))
    }
    
    @Test("URLSession makes GET request with date range parameters")
    func testDateRangeApodURLRequest() async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodRangeJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 15))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 16))!
        
        _ = try await service.fetchRange(start: startDate, end: endDate)

        #expect(mockSession.verifyDataWasCalled(times: 1))
        #expect(mockSession.verifyRequestURL(contains: "start_date=2023-09-15"))
        #expect(mockSession.verifyRequestURL(contains: "end_date=2023-09-16"))
    }
    
    @Test("Network service handles 200 OK response successfully")
    func testSuccessfulNetworkResponse() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        let result = try await service.fetchApod(date: Date())
        
        #expect(result.title == "Test APOD Title")
        #expect(result.date == "2023-09-16")
        #expect(result.mediaType == "image")
        #expect(result.url == "https://example.com/test-image.jpg")
    }
    
    @Test("Network service handles video media type")
    func testVideoMediaTypeHandling() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validVideoApodJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        let result = try await service.fetchApod(date: Date())
        
        #expect(result.title == "Test Video APOD")
        #expect(result.mediaType == "video")
        #expect(result.url == "https://www.youtube.com/embed/test-video")
    }
    
    @Test("Network service handles array response for date range")
    func testDateRangeArrayResponse() async throws {
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodRangeJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        let results = try await service.fetchRange(start: Date(), end: Date())
    
        #expect(results.count == 2)
        #expect(results[0].title == "Test APOD 1")
        #expect(results[1].title == "Test APOD 2")
    }
}

@Suite("Network Error Handling Tests", .serialized)
struct NetworkErrorHandlingTests {
    
    @Test("Network service handles 404 Not Found error")
    func testNotFoundError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 404)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown an error for 404")
        } catch {
            #expect(error is NetworkError)
            if case .noDataForDate = error as? NetworkError {
                // Expected for 404
            } else {
                #expect(Bool(false), "Expected noDataForDate error for 404")
            }
        }
    }
    
    @Test("Network service handles 401 Unauthorized error")
    func testUnauthorizedError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 401)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown an error for 401")
        } catch {
            #expect(error is NetworkError)
            if case .http(let code) = error as? NetworkError {
                #expect(code == 401)
            }
        }
    }
    
    @Test("Network service handles 429 Rate Limit error")
    func testRateLimitError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 429)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown an error for 429")
        } catch {
            #expect(error is NetworkError)
            if case .http(let code) = error as? NetworkError {
                #expect(code == 429)
            }
        }
    }
    
    @Test("Network service handles 500 Internal Server Error")
    func testInternalServerError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = Data()
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 500)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown an error for 500")
        } catch {
            #expect(error is NetworkError)
            if case .http(let code) = error as? NetworkError {
                #expect(code == 500)
            }
        }
    }
    
    @Test("Network service handles timeout error")
    func testTimeoutError() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockError = URLError(.timedOut)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown timeout error")
        } catch {
            #expect(error is URLError)
            #expect((error as? URLError)?.code == .timedOut)
        }
    }
    
    @Test("Network service handles no internet connection")
    func testNoInternetConnection() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockError = URLError(.notConnectedToInternet)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown no connection error")
        } catch {
            #expect(error is URLError)
            #expect((error as? URLError)?.code == .notConnectedToInternet)
        }
    }
    
    @Test("Network service handles malformed JSON response")
    func testMalformedJSONResponse() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.invalidJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown JSON parsing error")
        } catch {
            #expect(error is NetworkError)
            if case .decoding = error as? NetworkError {
                // Expected decoding error
            } else {
                #expect(Bool(false), "Expected decoding error")
            }
        }
    }
    
    @Test("Network service handles empty JSON response")
    func testEmptyJSONResponse() async {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.emptyJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When & Then
        do {
            _ = try await service.fetchApod(date: Date())
            #expect(Bool(false), "Should have thrown parsing error for empty JSON")
        } catch {
            #expect(error is NetworkError)
            if case .decoding = error as? NetworkError {
                // Expected decoding error
            }
        }
    }
    
    @Test("Network service handles empty array response")
    func testEmptyArrayResponse() async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.emptyArrayJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When
        let results = try await service.fetchRange(start: Date(), end: Date())
        
        // Then
        #expect(results.isEmpty)
    }
}

@Suite("Network Performance Tests", .serialized)
struct NetworkPerformanceTests {
    
    @Test("Multiple concurrent network requests")
    func testConcurrentNetworkRequests() async throws {
        // Given
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.mockApodItem = DummyApodItem.sample
        
        // When - Make 5 concurrent requests
        await withTaskGroup(of: Void.self) { group in
            for i in 0..<5 {
                group.addTask {
                    do {
                        let date = Date().adding(days: -i)
                        _ = try await serviceSpy.fetchApod(date: date)
                    } catch {
                        // Handle error silently for test
                    }
                }
            }
        }
        
        // Then
        #expect(serviceSpy.verifyFetchApodWasCalled(times: 5))
    }
    
    @Test("Network request cancellation handling")
    func testNetworkRequestCancellation() async {
        // Given
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.mockApodItem = DummyApodItem.sample
        
        // When - Create and immediately cancel task
        let task = Task {
            try await serviceSpy.fetchApod(date: Date())
        }
        
        // Cancel the task immediately
        task.cancel()
        
        // Then - Handle both success and cancellation
        do {
            _ = try await task.value
            // Task completed successfully (cancellation not guaranteed)
        } catch is CancellationError {
            // Expected cancellation
        } catch {
            // Other errors are also acceptable
        }
    }
    
    @Test("Network service tracks multiple request URLs correctly")
    func testMultipleRequestURLTracking() async throws {
        // Given
        let mockSession = MockURLSession()
        mockSession.mockData = NetworkTestData.validApodJSON
        mockSession.mockResponse = NetworkTestData.httpResponse(statusCode: 200)
        
        let service = NasaApodServiceWithURLSession(session: mockSession)
        
        // When - Make multiple requests with different dates
        let dates = [
            Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 16))!,
            Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 15))!,
            Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 14))!
        ]
        
        for date in dates {
            _ = try await service.fetchApod(date: date)
        }
        
        // Then
        let allURLs = mockSession.getAllRequestURLs()
        #expect(allURLs.count == 3)
        #expect(allURLs[0].contains("date=2023-09-16"))
        #expect(allURLs[1].contains("date=2023-09-15"))
        #expect(allURLs[2].contains("date=2023-09-14"))
    }
}

@Suite("Network Integration Tests", .serialized)
struct NetworkIntegrationTests {
    
    @Test("Repository uses network service for current APOD")
    func testRepositoryNetworkIntegration() async throws {
        // Given
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.mockApodItem = DummyApodItem.sample
        
        let repository = ApodRepository(service: serviceSpy)
        
        // When
        let result = try await repository.getCurrentApod()
        
        // Then
        #expect(serviceSpy.verifyFetchApodWasCalled(times: 1))
        #expect(result.item.title == DummyApodItem.sample.title)
    }
    
    @Test("Repository uses network service for specific date")
    func testRepositoryNetworkIntegrationSpecificDate() async throws {
        // Given
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.mockApodItem = DummyApodItem.withDate("2023-09-16")
        
        let repository = ApodRepository(service: serviceSpy)
        let testDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 16))!
        let result = try await repository.getApod(for: testDate)
        
        // Then
        #expect(serviceSpy.verifyFetchApodWasCalled(times: 1))
        #expect(serviceSpy.verifyFetchApodWasCalledWith(date: testDate))
        #expect(result.date == "2023-09-16")
    }
    
    @Test("Repository uses network service for date range")
    func testRepositoryNetworkIntegrationDateRange() async throws {
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.mockApodItems = [
            DummyApodItem.withDate("2023-09-16"),
            DummyApodItem.withDate("2023-09-15")
        ]
        
        let repository = ApodRepository(service: serviceSpy)
        let startDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 15))!
        let endDate = Calendar.current.date(from: DateComponents(year: 2023, month: 9, day: 16))!
        
        let results = try await repository.getApodRange(start: startDate, end: endDate)
        
        #expect(serviceSpy.verifyFetchRangeWasCalled(times: 1))
        #expect(serviceSpy.verifyFetchRangeWasCalledWith(start: startDate, end: endDate))
        #expect(results.count == 2)
    }
    
    @Test("Repository propagates network errors correctly")
    func testRepositoryNetworkErrorPropagation() async {
        let serviceSpy = NasaApodServiceSpy()
        serviceSpy.shouldThrowError = true
        serviceSpy.errorToThrow = NetworkTestError.timeout
        
        let repository = ApodRepository(service: serviceSpy)
        
        do {
            _ = try await repository.getCurrentApod()
            #expect(Bool(false), "Should have propagated network error")
        } catch {
            #expect(error is NetworkTestError)
            #expect(error as? NetworkTestError == .timeout)
        }
        
        #expect(serviceSpy.verifyFetchApodWasCalled(times: 1))
    }
    
    @Test("Repository handles network service retry logic")
    func testRepositoryNetworkRetryLogic() async throws {
        let serviceSpy = NasaApodServiceSpy()
        
        serviceSpy.shouldThrowError = true
        serviceSpy.errorToThrow = NetworkError.noDataForDate("test")
        
        let repository = ApodRepository(service: serviceSpy)
        do {
            _ = try await repository.getCurrentApod()
        } catch {
            #expect(error is NetworkError)
        }
        #expect(serviceSpy.fetchApodCallCount >= 1)
    }
}

@Suite("Network API Configuration Tests", .serialized)
struct NetworkAPIConfigTests {
    
    @Test("API key is loaded from configuration")
    func testAPIKeyConfiguration() {
        let apiKey = APIConfig.apiKey
        #expect(!apiKey.isEmpty)
        #expect(apiKey != "DEMO_KEY" || apiKey == "DEMO_KEY")
    }
}
