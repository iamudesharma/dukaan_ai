# Backend development with uv

Use uv 0.9.17. Python 3.13.5 is pinned in `.python-version`; uv downloads it if needed.
The project configuration enforces the uv version to keep local and hosted environments consistent.

From this directory:

```sh
uv sync --locked
uv run --locked python manage.py migrate
uv run --locked python manage.py runserver
uv run --locked pytest
uv run --locked ruff check .
```

uv manages `.venv` automatically. Do not activate it manually or install packages with pip.
Load environment variables using the root local-development runbook, or pass
`--env-file ../../.env` to `uv run` when that local file exists.

Dependency changes:

```sh
uv add package-name
uv add --dev package-name
uv remove package-name
uv lock --upgrade-package package-name
uv sync --locked
```

Review and commit both `pyproject.toml` and `uv.lock`. Version ranges express compatibility;
the lockfile fixes exact versions, transitive dependencies, and distribution hashes.
CI and deployment use `--locked` so stale lockfiles fail instead of changing silently.
Production uses `--no-dev` to exclude test and lint tools.

To update runtimes, change `.python-version` and Render's `PYTHON_VERSION` together.
Update `[tool.uv].required-version`, CI setup-uv versions, Render's `UV_VERSION`, and
these instructions together when upgrading uv. Regenerate the lockfile and run `make api-check`.

References: [uv project workflow](https://docs.astral.sh/uv/concepts/projects/sync/),
[Render uv support](https://render.com/docs/uv-version).
