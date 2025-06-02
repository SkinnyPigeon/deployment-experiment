# POC for using `act` and `gh-signoff`

The point of this repo was to do a quick POC in using [act](https://github.com/nektos/act?tab=readme-ov-file) and [gh-signoff](https://github.com/basecamp/gh-signoff) as a means to reduce the time spent using GitHub Runners.

## act

`act` is a CLI tool that is capable of running GitHub workflows on the local machine. In the short time spent on this POC, it was observed that there is a bit of funny business running workflows for both AMD64 and ARM64 chip sets. Nothing that can't be overcome with a bit of planning. However, as more experimentation is carried out, we should bare in mind that we may find cases which we can't solve. I would recommend not losing too much time with stubborn issues as the cost savings are somewhat limited. However, it does all add up.

To install on MacOS:
```bash
brew install act
```
For other installation options, [checkout their installation guides](https://nektosact.com/installation/index.html).

## gh-signoff

`gh-signoff` is a GitHub CLI extension that enables users to _signoff_ their work. The point of this being that we can remove the need for CI checks for pull requests and use these as required checks before the PR can be merged. Of course, there is a limitation to the security of doing this, and a need for trust in our developers that they are acting honestly and sticking to the requirements that we have laid of for them.

For instance, in this setup, I have four required checks which need to be signed-off. _Hopefully_, the users of this repo are using the `Make` recipes to trigger the each signoff. If they do, they are presented with a confirmation box that asks them to type `'yes'` to confirm they have run the checks for the target architecture. This should prevent accidental signing of checks before the users wants to as well as acting as a final barrier to submitting the signoff.

To install:
```bash
gh extension install basecamp/gh-signoff 
```

> [!NOTE]
> To install this extension, you must [first install the gh CLI tool](https://github.com/cli/cli)

Once it is installed, you can set one or more checks which must be signed-off with the following:
```bash
gh signoff install <check 1> <check 2>...
```

For this repo's example:
```bash
gh signoff install unit-tests lint style type-check
```

Each of these can then be signed-off individually or via the `make signoff-all` recipe

## To test

1. Clone repo
2. Run the unit test/style checks to see how act behaves locally
3. Create a PR on a branch based on develop
4. Signoff the various checks