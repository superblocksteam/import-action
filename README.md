# import-action

This repo contains the GitHub Action that can be used to push Superblocks application changes from a connected GitHub repo to Superblocks.

See the [Source Control documentation](https://docs.superblocks.com/development-lifecycle/source-control/) for more information.

## Description

<!-- AUTO-DOC-DESCRIPTION:START - Do not remove or modify this section -->

Push applications to Superblocks

<!-- AUTO-DOC-DESCRIPTION:END -->

## Usage

```yaml
name: Sync application changes to Superblocks
on: [push]

jobs:
  superblocks-push:
    runs-on: ubuntu-latest
    name: Push to Superblocks
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Push
        uses: superblocksteam/import-action@v1
        id: push
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
```

The above shows a standalone workflow. If you want to incorporate it as part of an existing workflow/job, simply copy the checkout and push steps into your workflow.

You can also pin to a [specific release version](https://github.com/superblocksteam/import-action/releases) in the format @v1.x.x.

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|                                INPUT                                 |  TYPE  | REQUIRED |              DEFAULT              |                                         DESCRIPTION                                          |
|----------------------------------------------------------------------|--------|----------|-----------------------------------|----------------------------------------------------------------------------------------------|
|  <a name="input_cli_version"></a>[cli_version](#input_cli_version)   | string |  false   |       `"branch-awareness"`        |                                 The Superblocks CLI version                                  |
|          <a name="input_domain"></a>[domain](#input_domain)          | string |  false   |      `"app.superblocks.com"`      |                  The Superblocks domain where applications <br>are hosted                    |
| <a name="input_github_token"></a>[github_token](#input_github_token) | string |   true   |                                   | The GitHub package registry access <br>token to use when installing <br>the Superblocks CLI  |
|             <a name="input_path"></a>[path](#input_path)             | string |  false   | `".superblocks/superblocks.json"` |                    The relative path to the <br>Superblocks config file                      |
|              <a name="input_sha"></a>[sha](#input_sha)               | string |  false   |             `"HEAD"`              |                                  Commit to push changes for                                  |
|           <a name="input_token"></a>[token](#input_token)            | string |   true   |                                   |                           The Superblocks access token to <br>use                            |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
