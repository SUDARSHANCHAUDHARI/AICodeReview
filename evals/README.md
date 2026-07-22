# AICodeReview behavioral evaluations

These fixtures measure review behavior. They do not call an AI provider automatically and do not claim that every agent behaves identically.

## Validate and list fixtures

```bash
aicodereview eval --validate
aicodereview eval --list
```

## Run an evaluation

For each entry in `manifest.json`:

1. Open only the fixture directory listed by `path`.
2. Give the agent the exact `prompt` from the manifest.
3. Record only grounded findings using the expected ID vocabulary.
4. Save the results in this shape:

```json
{
  "fixtures": [
    {
      "id": "secret-exposure",
      "findings": [
        {
          "id": "hardcoded-production-secret",
          "severity": "P0"
        }
      ]
    }
  ]
}
```

Score the result:

```bash
aicodereview eval --results results.json
```

The scorer reports:

- true positives
- false positives
- false negatives
- precision
- recall
- severity accuracy

## Rules

- The seeded secret is intentionally fake and exists only for testing.
- Do not edit fixtures while evaluating an agent.
- Use the same prompts and fixture state for every agent.
- Record the agent name, model, version, date, and relevant configuration beside each result file.
- Do not advertise agent support based only on installation success. Publish behavioral claims only when reproducible results support them.
