# Testing Setup Guide

This guide explains how to set up tests for the PC Controller macOS app so the GitHub Actions test workflow can be enabled.

## Current Status

The test workflow is currently disabled because the project doesn't have tests configured. To enable testing:

1. Add test targets to your Xcode project
2. Configure the scheme for testing
3. Enable the test workflow

## Setting Up Tests

### 1. Add Test Target in Xcode

1. Open your project in Xcode
2. Go to **File → New → Target**
3. Choose **macOS → Unit Testing Bundle**
4. Name it `PC ControllerTests`
5. Make sure it's added to your main app target

### 2. Configure Scheme for Testing

1. In Xcode, go to **Product → Scheme → Edit Scheme**
2. Select **Test** from the left sidebar
3. Click the **+** button to add a test target
4. Select your test target (`PC ControllerTests`)
5. Click **Close**

### 3. Create Basic Tests

Create a test file in your test target:

```swift
import XCTest
@testable import PC_Controller

final class PCControllerTests: XCTestCase {
    
    func testExample() throws {
        // This is an example test case
        XCTAssertTrue(true)
    }
    
    func testNetworkManager() throws {
        // Test your NetworkManager class
        let networkManager = NetworkManager()
        // Add your test logic here
    }
}
```

### 4. Enable Test Workflow

Once tests are set up, enable the test workflow by changing this line in `.github/workflows/build.yml`:

```yaml
if: false  # Disabled until tests are added to the project
```

to:

```yaml
if: true  # Enable tests
```

## Test Structure

### Unit Tests
- Test individual components (NetworkManager, PCStatusChecker, etc.)
- Mock network calls for testing
- Test data models and utilities

### Integration Tests
- Test the full app workflow
- Test menu bar integration
- Test popover functionality

### Example Test Cases

```swift
// Test NetworkManager
func testNetworkManagerInitialization() {
    let manager = NetworkManager()
    XCTAssertNotNil(manager)
}

// Test PC Status Checker
func testPCStatusChecker() {
    let checker = PCStatusChecker()
    // Test status checking logic
}

// Test Wake-on-LAN
func testWakeOnLAN() {
    let wol = WakeOnLAN()
    // Test magic packet generation
}
```

## Running Tests Locally

```bash
# Run tests from command line
xcodebuild test \
  -project "PC Controller.xcodeproj" \
  -scheme "PC Controller" \
  -destination 'platform=macOS'

# Run specific test
xcodebuild test \
  -project "PC Controller.xcodeproj" \
  -scheme "PC Controller" \
  -only-testing:PC_ControllerTests/PCControllerTests/testExample
```

## Test Dependencies

Consider adding these testing dependencies:

```swift
// In your test target
import XCTest
@testable import PC_Controller

// For mocking network calls
class MockURLSession: URLSession {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        // Return mock data
        completionHandler(mockData, mockResponse, mockError)
        return MockURLSessionDataTask()
    }
}
```

## Continuous Integration

Once tests are set up, the GitHub Actions workflow will:

1. **Run tests** on every push and pull request
2. **Upload test results** as artifacts
3. **Fail the build** if tests fail
4. **Provide test coverage** reports

## Best Practices

1. **Test early and often** - Write tests as you develop features
2. **Mock external dependencies** - Don't rely on network calls in tests
3. **Test edge cases** - Include error conditions and boundary cases
4. **Keep tests fast** - Tests should run quickly for CI/CD
5. **Use descriptive test names** - Make it clear what each test validates

## Troubleshooting

### Common Issues

1. **Scheme not configured for testing**
   - Edit scheme and add test target
   - Ensure test target is selected

2. **Tests not found**
   - Check that test files are in the test target
   - Verify test class inherits from `XCTestCase`

3. **Import errors**
   - Use `@testable import PC_Controller` to access internal members
   - Check target membership of source files

### Debug Commands

```bash
# List available schemes
xcodebuild -list -project "PC Controller.xcodeproj"

# Show scheme details
xcodebuild -showBuildSettings -project "PC Controller.xcodeproj" -scheme "PC Controller"
``` 