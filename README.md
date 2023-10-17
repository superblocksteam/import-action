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

### EU region

If your organization uses Superblocks EU, set the `domain` to `eu.superblocks.com` in the `Push` step.

```yaml
      ...

      - name: Push
        uses: superblocksteam/import-action@v1
        id: push
        with:
          token: ${{ secrets.SUPERBLOCKS_TOKEN }}
          domain: eu.superblocks.com
```

## Inputs

<!-- AUTO-DOC-INPUT:START - Do not remove or modify this section -->

|    INPUT    |  TYPE  | REQUIRED |              DEFAULT              |                        DESCRIPTION                        |
|-------------|--------|----------|-----------------------------------|-----------------------------------------------------------|
| cli_version | string |  false   |            `"^1.1.0"`             |                The Superblocks CLI version                |
|   domain    | string |  false   |      `"app.superblocks.com"`      | The Superblocks domain where applications are <br>hosted  |
|    path     | string |  false   | `".superblocks/superblocks.json"` |   The relative path to the Superblocks <br>config file    |
|     sha     | string |  false   |             `"HEAD"`              |                Commit to push changes for                 |
|    token    | string |   true   |                                   |            The Superblocks access token to use            |

<!-- AUTO-DOC-INPUT:END -->

## Outputs

<!-- AUTO-DOC-OUTPUT:START - Do not remove or modify this section -->
No outputs.
<!-- AUTO-DOC-OUTPUT:END -->
