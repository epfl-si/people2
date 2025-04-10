# Testing Guide

## Objective

Write clean, isolated, stable, and understandable tests.  
Every public method must be tested without external dependencies.

---

## Basic Rules

### One test per behavior
Each test checks only one thing.

### No external calls (API, DB, network, etc.)
Everything must be stubbed using `define_singleton_method`.

### Use `ensure` to restore original methods
Never leave a stub active after a test.

### No special test gems
Use native Ruby (`assert`, `refute`, etc.).

### No fixtures
Create objects directly inside the test.

### Clear test names
The test name must clearly describe what it verifies.

---

## Example Test

```ruby
test "admin_for_profile? returns true if user is admin" do
  original_method = APIAuthGetter.method(:call)

  APIAuthGetter.define_singleton_method(:call) do |_params|
    [{ "persid" => "123456" }]
  end

  user = User.new(sciper: "123456")
  profile = OpenStruct.new(sciper: "654321")

  assert user.admin_for_profile?(profile)
ensure
  APIAuthGetter.define_singleton_method(:call, original_method)
end
```

---

## This test does:

- Stubs a method (`APIAuthGetter.call`).
- Creates objects directly (no fixtures).
- Verifies **only one behavior**.
- Restores the original method after the test.

---

## One-line Summary

> **"Test each method in isolation, without external calls, using clean and restored stubs."**

---

## Checklist for Each Test

| Rule                                      | Done?                    |
|:------------------------------------------|:-------------------------:|
| One behavior per test                     |<input type="checkbox" />|
| No real API call                          |<input type="checkbox" />|
| `define_singleton_method` + `ensure` used |<input type="checkbox" />|
| No fixture                                |<input type="checkbox" />|
| Explicit test name                        |<input type="checkbox" />|

*(Check each box before considering the test complete.)*

---

## Test File Template

Copy and paste this to start a new test file:

```ruby
# frozen_string_literal: true

require "test_helper"
require "ostruct"

class MyClassTest < ActiveSupport::TestCase
  test "behavior_name" do
    # 1. Save the original method
    original_method = MyClass.method(:method_to_stub)

    # 2. Stub the method
    MyClass.define_singleton_method(:method_to_stub) do |_arguments|
      "fake_value"
    end

    # 3. Create the objects to test
    object = MyClass.new
    result = object.method_to_test

    # 4. Check the result
    assert_equal "expected_value", result
  ensure
    # 5. Always restore the original method
    MyClass.define_singleton_method(:method_to_stub, original_method)
  end
end
```

---