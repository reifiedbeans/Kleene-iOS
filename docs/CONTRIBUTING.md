# Kleene Contribution Guidelines
Thank you for taking the time to contribute to Kleene. Before you get started, review these guidelines to ensure that our community and project stay clean!
Any proposals for amendments to any of the documents referenced or this document itself can be submitted in the form of a pull request.

## Code of Conduct
This project and everyone participating in it are governed by the [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Any concerns can be reported to one of the project maintainers.

## Getting Started

### Reporting Bugs
If you find a bug in the application, follow these steps to ensure that we have enough information to fix the issue:

1. Check our [issues list](https://github.com/search?q=+is%3Aissue+user%3AKleeneApp) to see if the bug has already been reported. If it is, see if you can provide any more information by leaving a comment on the issue.

2. Try to find the minimal way to recreate the issue. Make note of this as it will be important to your description of the bug.

3. If you are comfortable doing so and are able, clone the repository and try to debug the issue in XCode. If you've found the issue and can fix it, read the [pull request guidelines](#pull-requests) before opening a pull request. If you cannot fix the problem, any information such as file names and line numbers where the error occurred can help us!

Once you've completed these steps to the best of your ability, open an [issue](https://github.com/KleeneApp/Kleene-iOS/issues/new) detailing what happened and someone will take a look at it. Make sure to tag your issue correctly and use the [issue template](ISSUE_TEMPLATE.md) when filling out issues.

### Pull Requests
All the code needed to contribute is included in the repository. We use CocoaPods for our dependencies, and all pods (including the linter) are included in the repo.

If you would like to contribute to the project, there are a couple of things to keep in mind:

- All checks must pass on the pull request for merging to be considered. This includes linter errors and test failures. If you believe the linter or tests are configured incorrectly, please open an [issue](https://github.com/KleeneApp/Kleene-iOS/issues/new).

- Follow the style guides already used in the project. You can refer to code that has been committed by a maintainer, or test your code by using the linter included as a Pod.

- If you are adding enhancements, make sure to extensively test the app not only manually, but also with the build-time tests.

When opening a pull request, make sure to use the [pull request template](PULL_REQUEST_TEMPLATE.md).

When merging into `master`, we use the "squash and merge" method. This takes all of your commits on your branch and merges them into one commit, keeping the repository clean. Readers and contributors can still view your changes by selecting the pull request ID automatically added in the commit message.

### Labels
Below is a list of labels that we use in the repo and how we use them.

| Label           | Description                                                                           |
|-----------------|---------------------------------------------------------------------------------------|
| `bug`           | A bug concerning functionality in the app. (e.g. Users cannot sign into a service)    |
| `ui bug`        | A bug concerning UI elements. (e.g. The Search bar does not display properly)         |
| `enhancement`   | A new feature or change in the way a portion of the app functions or looks.           |
| `help wanted`   | Issues that the Kleene team is looking for outside help on.                           |
| `documentation` | Improvements or additions to documentation.                                           |
| `invalid`       | A non-issue or something that is working as intended.                                 |
| `duplicate`     | A duplicate of another issue or pull request. Most likely will be closed.             |
| `wontfix`       | Something the team has deemed unimportant for the time being. May be addressed later. |
