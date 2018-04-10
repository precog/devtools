# devtools
Development tools for SlamData

## Merge Instructions
How to get up and running with `sdmerge`.

1. Git clone the slamdata/devtools repo using: 

```
→ git clone https://github.com/slamdata/devtools.git
```

2. The `sdmerge` script depends on python 3.

3. You also need to exchange ssh keys with github. This requires two steps:
  * Generate ssh [keys](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
  * Exchage public key with [github](https://help.github.com/articles/adding-a-new-ssh-key-to-your-github-account/)

4. To merge a PR from private repository, you need to get github access token from [here](https://github.com/settings/tokens). Provide it to the script through GITHUB_TOKEN env variable.

5. In addition ensure the PR has a version label assigned to it.

6. Now run the `sdmerge` script as follows:

```
→ sdmerge REPO-NAME PR-NUMBER
```

replacing `REPO-NAME` by the name of a repository, for exapmle `quasar-analytics/quasar`. 

`REPO-NAME` may be skipped if script is run from target repo directory and has remote named `upstream`.
