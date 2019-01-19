title: Notes on Version Control Methodology

In the course of normal programming, the history of a repo is not very important.
During root cause analysis or forensics, the history of the repo becomes much more important, as it is a source of evidence.
A more structured history is more useful for forensics, and more structure implies a larger history.
Therefore, do not rebase.

Simply not rebasing is not sufficient to achieve structure in the repository.
One rule I have heard is "each commit should either add a new failing test, or contain the smallest source change that makes a test pass", though I'm not sure I'm entirely sold on it.
The obvious missing commit type is a refactoring commit, though those have their own issues what with requiring coordination.
